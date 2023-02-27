FROM mcr.microsoft.com/dotnet/sdk:7.0 as DOTNET
RUN dotnet --info

FROM jupyter/scipy-notebook:python-3.9.13 as JUPYTER
ARG NB_USER=jovyan
ARG NB_UID=1000
# FROM 包含了创建 jovyan 用户
# from=JUPYTER 已存在 jovyan 用户
# RUN adduser --disabled-password \
#     --gecos "Default user" \
#     --uid ${NB_UID} \
#     ${NB_USER}
USER root
COPY --from=DOTNET /usr/share/dotnet/ /usr/share/dotnet/
COPY --from=DOTNET /root/.dotnet/ /root/.dotnet/
# RUN sudo find / -type f -name "dotnet"
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=$PATH:/usr/share/dotnet/:/root/.dotnet/tools/
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}
# 删除 jupyter/scipy-notebook 引入的文件夹
RUN sudo rm -rf /home/${NB_USER}/work
COPY . /home/${NB_USER}
COPY environment.yml /tmp/environment.yml
RUN sudo rm -rf environment.yml
RUN mamba env update -n base --file /tmp/environment.yml \
  && mamba clean -yaf
# jupyter .NET (C# F# PowerShell) kernel
RUN dotnet tool install Microsoft.dotnet-interactive --global \
&& dotnet interactive jupyter install
# Encountered problems while solving by manba ! need pip
# ignore warn, can not work if use sudo -H
RUN pip install digautoprofiler -q
RUN pip install jupyter-wysiwyg -q
RUN pip install nbtools -q
# nbgitpuller 用于内容仓库与环境仓库分离
# 暂不可用 https://github.com/jupyterhub/nbgitpuller/issues/292
# RUN pip install nbgitpuller -q
# jupyter node.js kernel
# RUN npm install -g npm@9.5.1 # npm ERR! engine Not compatible with your version of node/npm: npm@9.5.1
RUN npm install uuid@9.0.0
RUN npm install -g ijavascript@5.2.1
RUN ijsinstall
# auto run initial work
RUN nbdime config-git --enable --global
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}
