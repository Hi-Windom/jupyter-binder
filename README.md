![GitHub repo size](https://img.shields.io/github/repo-size/Hi-Windom/jupyter-binder?logo=github&style=flat-square) [![Build Binder Container & Gen Release](https://github.com/Hi-Windom/jupyter-binder/actions/workflows/ci.yaml/badge.svg?branch=main)](https://github.com/Hi-Windom/jupyter-binder/actions/workflows/ci.yaml) [![Docker](https://img.shields.io/badge/Docker-585899?logo=docker&style=flat-square)](https://hub.docker.com/repository/docker/soltus/jupyter-binder) ![Docker Pulls](https://img.shields.io/docker/pulls/soltus/jupyter-binder?style=flat-square) ![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/soltus/jupyter-binder?style=flat-square)

# 简介

此仓库托管在 [Github](https://github.com/Hi-Windom/jupyter-binder) ，是一八六战略二期工程项目，绛亽新学习融创示范项目

姊妹仓库：[jupyter-binder-python](https://github.com/Hi-Windom/jupyter-binder-python) 体积小巧，对于仅需要 ipykernel 和基本 Lab 插件的需求来说非常适合

# 使用

## 在 [Binder (mybinder.org)](https://mybinder.org/) 使用

> 已集成以下内核：
>
> 1. [.Net Interactive](https://github.com/dotnet/interactive/)
> 2. [GoNB](https://github.com/janpfeifer/gonb)
> 3. [tslab](https://github.com/yunabe/tslab)
> 4. [IJavascript](https://github.com/n-riesco/ijavascript)
>
> 是否考虑集成 C++ 内核？不会考虑，C++ 并不适合 notebook ，集成的意义不明显
>
> 已内置以下插件：
>
> *作者很懒，这里什么也没写*

打开链接 [快速开始](https://mybinder.org/v2/gh/Hi-Windom/jupyter-binder/HEAD?urlpath=lab/tree/binder.ipynb)

假如你有一个远端仓库（比如 Github），使用 [克隆 ](https://mybinder.org/v2/gh/Hi-Windom/jupyter-binder/HEAD?urlpath=lab/tree/loader.ipynb)链接；如果只是想运行单个文件，直接从本地上传是最好的选择

~~任意 ipynb 公开仓库可 [在线生成链接](https://hub.jupyter.org/nbgitpuller/link?tab=binder) ，而无需提供额外配置~~（暂不可用，故障排查中）

基于 Binder 实现，可以在 `Dockerfile` 中 `FROM soltus/jupyter-binder:latest` 开始构建自定义的环境镜像

更多内容参考 [binder.ipynb](https://github.com/Hi-Windom/jupyter-binder/blob/main/binder.ipynb)

## 在 Windows 本地复苏

> 如果需要镜像加速下载，请参考 [Python镜像 (yuque.com)](https://www.yuque.com/cnbc/py3/image)
>
> 只考虑 windows AMD64 平台
>
> 非 Python 内核需自行安装

前置准备：

1. `conda info -e` 命令应对输出而不是报错

在 README.md 文件所在路径打开终端，运行以下命令：(应当使用 PowerShell 而不是 CMD 以避免意外发生)

```powershell
conda create -n lab python=3.10
conda actiavte lab
```

```powershell
pip install pip-tools -i https://mirrors.tencent.com/pypi/simple
```

```powershell
pip-sync win.requirements.txt --pip-args "--quiet --retries 10 --timeout 30"
```

```powershell
jupyter lab --port='6969' --ip='*' --no-browser --allow-root --notebook-dir='D:\\TEMP\\jlab\\notebook'
```

--notebook-dir 传参因人而异，不出意外的话复苏成功。在终端 CTRL + 单击链接或者手动打开浏览器访问 [http://127.0.0.1:6969/lab](http://127.0.0.1:6969/lab) ，时间交给你了

# 初始化工作

参考 [index.ipynb](https://github.com/Hi-Windom/jupyter-binder/blob/main/index.ipynb)
