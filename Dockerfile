# kernel list https://github.com/jupyter/jupyter/wiki/Jupyter-kernels

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
COPY --from=GO /go /go
COPY --from=GO /usr/local/go /usr/local/go
ENV GOVERSION="go1.20.1" GCCGO="gccgo" GOENV=/home/${NB_USER}/.config/go/env GOROOT=/usr/local/go GOPATH=/go GOMODCACHE=/go/pkg/mod GOTOOLDIR=/usr/local/go/pkg/tool/linux_amd64
COPY --from=DOTNET /usr/share/dotnet/ /usr/share/dotnet/
COPY --from=DOTNET /root/.dotnet/ /home/${NB_USER}/.dotnet/
# RUN sudo find / -type f -name "dotnet"
ENV DOTNET_ROOT=/usr/share/dotnet
# PATH 单列项
ENV PATH=$PATH:/usr/share/dotnet/:/home/${NB_USER}/.dotnet/tools/:/usr/local/go/bin/:/go/bin/
# jupyter .NET (C# F# PowerShell) kernel
RUN dotnet interactive jupyter install
# jupyter GO kernel
RUN go install github.com/janpfeifer/gonb@latest \
&& go install golang.org/x/tools/cmd/goimports@latest \
&& go install golang.org/x/tools/gopls@latest \
&& gonb --install
COPY environment.yml /tmp/environment.yml
COPY .gitignore.txt /home/${NB_USER}/.gitignore
RUN sudo rm -rf environment.yml \
&& sudo rm -rf .gitignore \
&& sudo rm -rf .gitignore.txt \
&& sudo rm -rf /home/${NB_USER}/work
# 注意顺序
COPY . /home/${NB_USER}
# 删除 jupyter/scipy-notebook 引入的文件夹 work
#
RUN mamba env update -n base --file /tmp/environment.yml \
  && mamba clean -yaf
#
# Encountered problems while solving by manba ! need pip
# ignore warn, can not work if use sudo -H
RUN pip install digautoprofiler -q \
&& pip install jupyter-wysiwyg -q \
&& pip install nbtools -q \
&& pip install jupyterlab_rise -q \
&& pip install nbgitpuller -q
# ref https://github.com/damianavila/RISE/pull/605#issuecomment-1345599744
#
# nbgitpuller 用于内容仓库与环境仓库分离，需要 git 环境
# 暂不可用 https://github.com/jupyterhub/nbgitpuller/issues/292
# RUN pip install nbgitpuller -q
#
# jupyter node.js kernel
# RUN npm install -g npm@9.5.1 # npm ERR! engine Not compatible with your version of node/npm: npm@9.5.1
RUN npm install uuid@9.0.0 \
&& npm install -g ijavascript@5.2.1 && ijsinstall \
&& npm install -g tslab && tslab install --version && tslab install --python=python3 \
&& npm install -g typescript-language-server typescript
# auto run initial work
RUN nbdime config-git --enable --global \
&& conda init
RUN chown -R ${NB_UID} ${HOME}
CMD ["sh", "-c", "git remote remove origin"]
USER ${NB_USER}