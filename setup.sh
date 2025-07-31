#!/bin/bash

# 确保脚本在出错时退出
set -e

# 获取基于git描述的最新版本号（格式：tag-commits-hash）
VERSION=$(git describe --tags --always)
if [ -z "$VERSION" ]; then
    VERSION="v0.0-$(git rev-parse --short HEAD)"
fi

echo "构建版本: $VERSION"

# 检查并准备MySQL数据目录
echo "设置MySQL数据目录 /opt/mysql..."
if [ ! -d "/opt/mysql" ]; then
    echo "目录不存在，创建新目录..."
    sudo mkdir -p /opt/mysql
    #sudo chown -R 999:999 /opt/mysql
    #sudo chmod 755 /opt/mysql
else
    echo "目录已存在，跳过创建，仅验证权限..."
    # sudo chown -R 999:999 /opt/mysql >/dev/null 2>&1 || true
    # sudo chmod 755 /opt/mysql >/dev/null 2>&1 || true
fi

# 验证目录状态
if [ ! -w "/opt/mysql" ]; then
    echo "错误：/opt/mysql 不可写，请检查权限"
    exit 1
fi

# 构建mysql镜像
echo "正在构建 mysql 镜像..."
docker build -t mysql:$VERSION -f Dockerfile.mysql .

# 构建webserver镜像
echo "正在构建 webserver 镜像..."
docker build -t webserver:$VERSION -f Dockerfile.webserver .

# 停止并删除旧容器（如果存在）
echo "清理旧容器..."
docker rm -f mysql webserver 2>/dev/null || true

# 启动mysql容器
echo "启动 mysql 容器..."
docker run -d \
    --name mysql \
    -v /opt/mysql:/var/lib/mysql \
    -p 13306:3306 \
    mysql:$VERSION

# 等待mysql初始化完成（简单版）
echo "等待mysql准备就绪..."
sleep 15  # 实际生产环境建议用健康检查替代

# 启动webserver容器
echo "启动 webserver 容器..."
docker run -d \
    --name webserver \
    --network="host" \
    webserver:$VERSION

echo "部署完成！"
echo -e "MySQL端口: 13306\nWebserver运行在host网络模式"