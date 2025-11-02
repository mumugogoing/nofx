#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# NOFX 简易部署脚本
# ═══════════════════════════════════════════════════════════════
# 
# 使用方法：
#   1. 复制 deploy-config.example.sh 为 deploy-config.sh
#   2. 编辑 deploy-config.sh 填入你的服务器信息
#   3. 运行此脚本: ./deploy.sh
#
# 或者直接使用命令行参数：
#   ./deploy.sh <服务器IP> <SSH用户>
# ═══════════════════════════════════════════════════════════════

# 检查deploy-remote.sh是否存在
if [ ! -f "deploy-remote.sh" ]; then
    echo "错误: 找不到 deploy-remote.sh"
    exit 1
fi

# 如果提供了命令行参数，直接传递
if [ $# -ge 1 ]; then
    ./deploy-remote.sh "$@"
elif [ -f "deploy-config.sh" ]; then
    # 使用配置文件
    echo "使用 deploy-config.sh 中的配置..."
    ./deploy-remote.sh
else
    echo "请提供服务器信息："
    echo ""
    echo "方式一：使用配置文件（推荐）"
    echo "  1. cp deploy-config.example.sh deploy-config.sh"
    echo "  2. 编辑 deploy-config.sh 填入服务器信息"
    echo "  3. ./deploy.sh"
    echo ""
    echo "方式二：使用命令行参数"
    echo "  ./deploy.sh <服务器IP> <SSH用户> [SSH端口]"
    echo ""
    echo "示例："
    echo "  ./deploy.sh 47.108.148.251 root"
    exit 1
fi
