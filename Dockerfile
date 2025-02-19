FROM ubuntu:latest

# 設定環境變數，避免交互式安裝
ENV DEBIAN_FRONTEND=noninteractive

# 安裝必要工具
RUN apt-get update && apt-get install -y curl bzip2 git && rm -rf /var/lib/apt/lists/*

# 設定 root 密碼為 root
RUN echo "root:root" | chpasswd

# 建立非 root 使用者 appuser
RUN useradd -m -s /bin/bash appuser && echo "appuser:appuser" | chpasswd

# 切換到 appuser
USER appuser
WORKDIR /home/appuser

# 下載並安裝 Miniconda
RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh \
    && bash miniconda.sh -b -p /home/appuser/miniconda \
    && rm miniconda.sh

# 設定 Conda 環境變數
ENV PATH="/home/appuser/miniconda/bin:$PATH"

# 初始化 Conda 讓 base 環境自動啟用
RUN conda init bash

# 確保 Conda 設定已生效
SHELL ["/bin/bash", "-c"]

# 創建 Conda 環境 webapp 並安裝 Python
RUN conda create -y --name webapp python=3.9 && conda clean -afy

# **關鍵修正：使用 `conda run` 來執行 pip 安裝**
RUN conda run -n webapp pip install django djangorestframework

# 預設啟動時進入 webapp 環境
RUN echo "conda activate webapp" >> /home/appuser/.bashrc

# 設定容器啟動時自動載入 webapp 環境
CMD ["bash", "-i"]
