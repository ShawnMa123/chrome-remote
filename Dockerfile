# 使用Ubuntu作为基础镜像
FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive

# 1. 更新软件包列表并安装所有需要的依赖
# **主要改动: 在这里添加了 gnupg**
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    gnupg \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libnspr4 \
    libnss3 \
    xdg-utils \
    fonts-wqy-zenhei \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# 2. 安装Google Chrome (使用更现代和安全的方法)
# **主要改动: 不再使用 apt-key**
RUN mkdir -p /etc/apt/keyrings && \
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# 安装uBlock Origin插件 (此部分无变化)
ARG UBLOCK_ID=cjpalhdlnbpafiamejdnhcphjbkeiagm
ARG UBLOCK_VERSION=1.58.0
RUN mkdir -p /opt/google/chrome/extensions/ && \
    wget -O /opt/google/chrome/extensions/ublock.crx "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=98.0&x=id%3D${UBLOCK_ID}%26uc" && \
    echo '{ "external_crx": "/opt/google/chrome/extensions/ublock.crx", "external_version": "'${UBLOCK_VERSION}'" }' > /opt/google/chrome/extensions/${UBLOCK_ID}.json

# 创建一个用于持久化用户数据的目录 (此部分无变化)
RUN mkdir /data

# 暴露远程调试端口 (此部分无变化)
EXPOSE 9222

# 设置容器的默认启动命令 (此部分无变化)
CMD [ "google-chrome-stable", \
      "--headless", \
      "--no-sandbox", \
      "--disable-gpu", \
      "--user-data-dir=/data", \
      "--remote-debugging-port=9222", \
      "--remote-debugging-address=0.0.0.0" \
    ]