#!/bin/bash
set -e -o pipefail

# 🧠 系统架构识别
ARCH_RAW=$(uname -m)
case "${ARCH_RAW}" in
    'x86_64') ARCH='amd64' ;;
    'x86' | 'i686' | 'i386') ARCH='386' ;;
    'aarch64' | 'arm64') ARCH='arm64' ;;
    'armv7l') ARCH='armv7' ;;
    *) echo "❌ 不支持的架构: ${ARCH_RAW}"; exit 1 ;;
esac
echo "✅ 当前系统架构: ${ARCH_RAW}"

# 🔍 本地版本检测
if command -v mihomo >/dev/null 2>&1; then
    LOCAL_VERSION=$(mihomo -v | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
else
    LOCAL_VERSION="未安装"
fi
echo "📦 当前运行版本: ${LOCAL_VERSION}"

# 📋 操作菜单
echo
echo "请选择操作："
echo "1. 安装最新稳定版"
echo "2. 安装最新测试版（alpha）"
echo "3. 安装指定版本"
echo "4. 检查是否需要升级到最新稳定版"
echo "5. 卸载 mihomo"
read -rp "输入选项 [1/2/3/4/5]: " OPTION

# 🌐 GitHub 源（可替换为镜像）
GH_API="https://api.github.com/repos/MetaCubeX/mihomo/releases"
GH_RAW="https://github.com/MetaCubeX/mihomo/releases/download"

# 🎯 版本选择逻辑
case "$OPTION" in
    1)
        VERSION=$(curl -s "${GH_API}/latest" | grep tag_name | cut -d '"' -f4)
        ;;
    2)
        VERSION="Prerelease-Alpha"
        ;;
    3)
        read -rp "请输入你要安装的版本号（例如 v1.19.15）: " VERSION
        ;;
    4)
        VERSION=$(curl -s "${GH_API}/latest" | grep tag_name | cut -d '"' -f4)
        if [ "$LOCAL_VERSION" != "${VERSION#v}" ]; then
            echo "🔄 发现新版本: ${VERSION}，准备更新"
        else
            echo "✅ 已是最新稳定版本，无需更新"
            exit 0
        fi
        ;;
    5)
        echo "🧹 正在卸载 mihomo..."
        pkill -f "mihomo run" || true
        rm -f /usr/local/bin/mihomo
        echo "✅ 卸载完成"
        exit 0
        ;;
    *)
        echo "❌ 无效选项，退出"
        exit 1
        ;;
esac

echo "📦 将安装版本: ${VERSION}"

# 🛡️ 备份旧配置（如存在）
if [ -f /root/data/anytls/config/config.yaml ]; then
    cp /root/data/anytls/config/config.yaml "/root/data/anytls/config/config.yaml.bak.$(date +%s)"
    echo "🗂️ 已备份旧配置文件"
fi

# ⬇️ 下载并安装 .gz 可执行文件
BIN_NAME="mihomo"
FILE="${BIN_NAME}-linux-${ARCH}-${VERSION}.gz"
URL="${GH_RAW}/${VERSION}/${FILE}"

echo "⬇️ 正在下载: ${URL}"
curl -fSL "$URL" -o "/tmp/${FILE}" || { echo "❌ 下载失败，请检查版本号或架构"; exit 1; }

gunzip -c "/tmp/${FILE}" > "/tmp/${BIN_NAME}"
chmod +x "/tmp/${BIN_NAME}"
mv "/tmp/${BIN_NAME}" /usr/local/bin/${BIN_NAME}
rm -f "/tmp/${FILE}"

echo "🚀 启动 mihomo（如需）: nohup mihomo run -c /root/data/anytls/config/config.yaml &"
echo "🎉 安装完成，当前版本: $(mihomo -v | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
