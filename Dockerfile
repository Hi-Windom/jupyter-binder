# kernel list https://github.com/jupyter/jupyter/wiki/Jupyter-kernels

FROM rust:alpine3.17 as RUST
# RUN find / -type f -name "cargo" && find / -type f -name "rustc" && find / -type f -name "rustup" && printenv CARGO_HOME && printenv RUSTUP_HOME
RUN cargo install evcxr_jupyter && find / -type f -name "evcxr_jupyter"

FROM golang:1.20.1-bullseye as GO
# debian env
RUN go env
# RUN find / -type f -name "go"

FROM mcr.microsoft.com/dotnet/sdk:7.0 as DOTNET
# https://learn.microsoft.com/zh-cn/dotnet/core/tools/dotnet-tool-install
RUN dotnet --info && dotnet tool install Microsoft.dotnet-interactive --global

FROM jupyter/scipy-notebook:python-3.9.13 as JUPYTER
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER=${NB_USER} NB_UID=${NB_UID}
ENV HOME=/home/${NB_USER}
# FROM 包含了创建 jovyan 用户
# from=JUPYTER 已存在 jovyan 用户
# RUN adduser --disabled-password \
#     --gecos "Default user" \
#     --uid ${NB_UID} \
#     ${NB_USER}
USER root
COPY --from=RUST /usr/local/cargo /usr/local/cargo
COPY --from=RUST /usr/local/rustup /usr/local/rustup
COPY --from=GO /go /go
COPY --from=GO /usr/local/go /usr/local/go
ENV GOVERSION="go1.20.1" GCCGO="gccgo" GOENV=/home/${NB_USER}/.config/go/env GOROOT=/usr/local/go GOPATH=/go GOMODCACHE=/go/pkg/mod GOTOOLDIR=/usr/local/go/pkg/tool/linux_amd64
COPY --from=DOTNET /usr/share/dotnet/ /usr/share/dotnet/
COPY --from=DOTNET /root/.dotnet/ /home/${NB_USER}/.dotnet/
# RUN sudo find / -type f -name "dotnet"
ENV DOTNET_ROOT=/usr/share/dotnet RUSTUP_HOME=/usr/local/rustup
# PATH 单列项
ENV PATH=$PATH:/usr/local/cargo/bin/:/usr/share/dotnet/:/home/${NB_USER}/.dotnet/tools/:/usr/local/go/bin/:/go/bin/
# jupyter .NET (C# F# PowerShell) kernel
RUN dotnet interactive jupyter install
# jupyter GO kernel
RUN go install github.com/janpfeifer/gonb@latest \
&& go install golang.org/x/tools/cmd/goimports@latest \
&& go install golang.org/x/tools/gopls@latest \
&& gonb --install
# jupyter Rust kernel
RUN rustup component add rust-src && evcxr_jupyter --install
COPY . /home/${NB_USER}
COPY environment.yml /tmp/environment.yml
RUN sudo rm -rf environment.yml \
&& sudo rm -rf /home/${NB_USER}/work
# 删除 jupyter/scipy-notebook 引入的文件夹 work
#
RUN mamba env update -n base --file /tmp/environment.yml \
  && mamba clean -yaf
#
# Encountered problems while solving by manba ! need pip
# ignore warn, can not work if use sudo -H
RUN pip install digautoprofiler -q \
&& pip install jupyter-wysiwyg -q \
&& pip install nbtools -q
#
# nbgitpuller 用于内容仓库与环境仓库分离
# 暂不可用 https://github.com/jupyterhub/nbgitpuller/issues/292
# RUN pip install nbgitpuller -q
#
# jupyter node.js kernel
# RUN npm install -g npm@9.5.1 # npm ERR! engine Not compatible with your version of node/npm: npm@9.5.1
RUN npm install uuid@9.0.0 \
&& npm install -g ijavascript@5.2.1 \
&& ijsinstall
# auto run initial work
RUN nbdime config-git --enable --global \
&& conda init
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}