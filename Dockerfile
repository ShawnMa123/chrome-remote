# (最终内网优化版 - 插件烘焙)
# 使用一个稳定的Ubuntu作为基础镜像
FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive

# 1. 更新并安装所有依赖
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

# 2. 安装 noVNC
RUN wget -O noVNC.zip "https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.zip" && \
    unzip noVNC.zip -d /usr/share && \
    mv /usr/share/noVNC-1.4.0 /usr/share/novnc && \
    ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html && \
    rm noVNC.zip && \
    git clone https://github.com/novnc/websockify /usr/share/novnc/utils/websockify

# 3. 安装Google Chrome
RUN mkdir -p /etc/apt/keyrings && \
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# 4. **关键步骤: 复制本地插件文件到镜像中**
COPY extensions/ /opt/extensions/

# 5. **关键步骤: 使用Chrome策略从本地文件路径强制安装插件**
RUN mkdir -p /etc/opt/chrome/policies/managed
RUN echo '{ "ExtensionInstallForcelist": [ "cjpalhdlnbpafiamejdnhcphjbkeiagm;/opt/extensions/ublock.crx" ] }' > /etc/opt/chrome/policies/managed/offline_install_policy.json

# 6. 替换Chrome的可执行文件以确保稳定启动
COPY chrome-launcher.sh /
RUN mv /usr/bin/google-chrome-stable /usr/bin/google-chrome-stable.original && \
    mv /chrome-launcher.sh /usr/bin/google-chrome-stable && \
    chmod +x /usr/bin/google-chrome-stable

# 7. 复制 Supervisor 配置文件和VNC启动脚本
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY vnc_startup.sh /
RUN chmod +x /vnc_startup.sh

# 暴露Web端口
EXPOSE 6080

# 使用 supervisor 作为容器的入口点
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]