#!/bin/bash

# 安装脚本
INSTALL_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"

echo "正在安装 ThinkPad 散热控制..."

# 创建目录（如果不存在）
mkdir -p "$INSTALL_DIR"
mkdir -p "$APP_DIR"

# 复制文件
cp fan-control.sh "$INSTALL_DIR/fan-control.sh"
cp fan-control.desktop "$APP_DIR/fan-control.desktop"

# 设置权限
chmod +x "$INSTALL_DIR/fan-control.sh"

# 检查依赖
if ! command -v yad &> /dev/null; then
    echo "提示: 未检测到 yad，请安装它以确保界面正常运行。"
    echo "例如: sudo apt install yad"
fi

echo "安装完成! 现在可以在应用菜单中找到 '散热控制' 了。"
