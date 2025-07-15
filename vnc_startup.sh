#!/bin/bash

# 设置默认分辨率
GEOMETRY="1920x1080"

# **关键改动**: 明确配置VNC服务器允许无密码访问
# 1. 创建配置目录
mkdir -p /root/.vnc

# 2. 写入配置，指定不使用任何安全类型
echo "securitytypes=None" > /root/.vnc/config

# 启动VNC服务器，并保持在前台运行
# 使用 -fg (foreground) 模式
# VNC服务器会读取上面的config文件
vncserver :1 -geometry ${GEOMETRY} -depth 24 -xstartup /usr/bin/startxfce4 -fg
```**改动详解**：
*   我们不再创建密码文件 (`vncpasswd`)。
*   我们创建了一个VNC的配置文件 `/root/.vnc/config`，并在里面写入了 `securitytypes=None`。这是 `TigerVNC` 的官方配置，用于关闭所有认证。

**2. 修改 `supervisord.conf`**

这个文件需要修改 `websockify` 的启动参数，告诉noVNC网页不要显示密码框。

**请用以下内容完全替换** `supervisord.conf` 文件：
```ini
[supervisord]
nodaemon=true
user=root

[program:vnc]
command=/vnc_startup.sh
autostart=true
autorestart=true
priority=10

[program:websockify]
# **关键改动**: 在命令末尾添加了 --no-auth
command=/usr/share/novnc/utils/websockify/run --web /usr/share/novnc/ 6080 localhost:5901 --no-auth
autostart=true
autorestart=true
priority=20