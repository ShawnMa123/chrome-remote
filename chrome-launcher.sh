#!/bin/bash
# 终极版Chrome启动器脚本

# 定义Chrome用户配置文件的路径
PROFILE_DIR="/root/chrome-data"

# **终极修正**: 强制删除上一次非正常关闭时残留的锁文件。
# 这是解决 "Profile appears to be in use" 错误的根本方法。
rm -f "$PROFILE_DIR/SingletonLock"
rm -f "$PROFILE_DIR/SingletonCookie"
rm -f "$PROFILE_DIR/SingletonSocket"

# 现在，用正确的参数执行真正的Chrome程序。
# "$@" 会将所有传递给此脚本的参数（例如要打开的URL）原封不动地传递给原始的Chrome程序。
exec /usr/bin/google-chrome-stable.original --no-sandbox --user-data-dir="$PROFILE_DIR" "$@"