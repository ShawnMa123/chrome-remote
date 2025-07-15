# 使用一个稳定的Ubuntu作为基础镜像
FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive

# 1. 更新并安装所有依赖 (无变化)
RUN apt-get update && apt-get install -y \
    supervisor \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    dbus-x11 \
    wget \
    git \
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

# 2. 安装 noVNC (无变化)
RUN wget -O noVNC.zip "https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.zip" && \
    unzip noVNC.zip -d /usr/share && \
    mv /usr/share/noVNC-1.4.0 /usr/share/novnc && \
    ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html && \
    rm noVNC.zip && \
    git clone https://github.com/novnc/websockify /usr/share/novnc/utils/websockify

# 3. 安装Google Chrome (无变化)
RUN mkdir -p /etc/apt/keyrings && \
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# 4. **最终关键修正：修改Chrome的启动器文件**
#    在所有 "Exec=" 行的末尾加上 --no-sandbox 和 --user-data-dir=/root/chrome-data
RUN sed -i 's#^Exec=/usr/bin/google-chrome-stable#Exec=/usr/bin/google-chrome-stable --no-sandbox --user-data-dir=/root/chrome-data#g' /usr/share/applications/google-chrome.desktop

# 5. 安装uBlock Origin插件 (无变化)
ARG UBLOCK_ID=cjpalhdlnbpafiamejdnhcphjbkeiagm
ARG UBLOCK_VERSION=1.58.0
RUN mkdir -p /opt/google/chrome/extensions/ && \
    wget -O /opt/google/chrome/extensions/ublock.crx "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=98.0&x=id%3D${UBLOCK_ID}%26uc" && \
    echo '{ "external_crx": "/opt/google/chrome/extensions/ublock.crx", "external_version": "'${UBLOCK_VERSION}'" }' > /opt/google/chrome/extensions/${UBLOCK_ID}.json

# 6. 复制 Supervisor 配置文件和VNC启动脚本 (无变化)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY vnc_startup.sh /
RUN chmod +x /vnc_startup.sh

# 暴露Web端口 (无变化)
EXPOSE 6080

# 使用 supervisor 作为容器的入口点 (无变化)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]