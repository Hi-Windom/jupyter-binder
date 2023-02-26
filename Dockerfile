FROM jupyter/scipy-notebook:python-3.9.13
ARG NB_USER=jovyan
ARG NB_UID=1000
# ENV USER ${NB_USER}
# ENV NB_UID ${NB_UID}
# ENV HOME /home/${NB_USER}
USER root
# 删除 jupyter/scipy-notebook 引入的文件夹
RUN sudo rm -rf /home/${NB_USER}/work
COPY . /home/${NB_USER}
COPY environment.yml /tmp/environment.yml
COPY ./scripts/dotnet-install.sh /tmp/dotnet-install.sh
RUN sudo rm -rf environment.yml
RUN mamba env update -n base --file /tmp/environment.yml \
  && mamba clean -yaf
# Encountered problems while solving by manba ! need pip
# ignore warn, can not work if use sudo -H
RUN pip install digautoprofiler -q
RUN pip install jupyter-wysiwyg -q
RUN pip install nbtools -q
# nbgitpuller 用于内容仓库与环境仓库分离
RUN pip install nbgitpuller -q
# jupyter node.js kernel
# RUN npm install -g npm@9.5.1 # npm ERR! engine Not compatible with your version of node/npm: npm@9.5.1
RUN npm install uuid@9.0.0
RUN npm install -g ijavascript@5.2.1
RUN ijsinstall
# jupyter .NET (C# F# PowerShell JavaScript SQL KQL HTML* Mermaid*) kernel (* Variable sharing not available.)
# RUN sudo apt-get update
# RUN sudo apt-get install -y dotnet-sdk-6.0
RUN sudo chmod +x /tmp/dotnet-install.sh
RUN /tmp/dotnet-install.sh --channel 7.0
RUN export DOTNET_ROOT=/home/jovyan/.dotnet
RUN dotnet tool install -g Microsoft.dotnet-interactive
RUN dotnet interactive jupyter install
# auto run initial work
RUN nbdime config-git --enable --global
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}