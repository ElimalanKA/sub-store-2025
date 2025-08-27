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
if command -v sing-box >/dev/null 2>&1; then
    LOCAL_VERSION=$(sing-box version | grep version | cut -d " " -f3)
else
    LOCAL_VERSION="未安装"
fi
echo "📦 当前运行版本: ${LOCAL_VERSION}"

# 🌐 GitHub 可达性检测与镜像切换
GH_BASE="https://github.com"
echo "🌐 正在检测 GitHub 连接..."
if ! curl -s --connect-timeout 10 https://github.com >/dev/null; then
    echo "⚠️ GitHub 无法访问，尝试使用 ghproxy 镜像源"
    GH_BASE="https://ghproxy.com/https://github.com"
fi

# 📋 操作菜单
echo
echo "请选择操作："
echo "1. 安装最新稳定版"
echo "2. 安装最新测试版（beta）"
echo "3. 安装指定版本"
echo "4. 检查是否需要升级到最新稳定版"
echo "5. 卸载 sing-box"
read -rp "输入选项 [1/2/3/4/5]: " OPTION

# 🎯 版本选择逻辑
case "$OPTION" in
    1)
        VERSION=$(curl -s "${GH_BASE}/SagerNet/sing-box/releases/latest" \
            | grep tag_name | cut -d ":" -f2 | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')
        ;;
    2)
        VERSION=$(curl -s "${GH_BASE}/SagerNet/sing-box/releases?per_page=1&page=0" \
            | grep tag_name | head -n1 | cut -d ":" -f2 | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')
        ;;
    3)
        read -rp "请输入你要安装的版本号（例如 1.11.0）: " VERSION
        ;;
    4)
        VERSION=$(curl -s "${GH_BASE}/SagerNet/sing-box/releases/latest" \
            | grep tag_name | cut -d ":" -f2 | sed 's/\"//g;s/\,//g;s/\ //g;s/v//')
        if [ "$LOCAL_VERSION" != "$VERSION" ]; then
            echo "🔄 发现新版本: ${VERSION}，准备更新"
        else
            echo "✅ 已是最新稳定版本，无需更新"
            exit 0
        fi
        ;;
    5)
        echo "🧹 正在卸载 sing-box..."
        systemctl stop sing-box || true
        apt remove --purge -y sing-box || echo "sing-box 未安装或已手动移除"
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
if [ -f /etc/sing-box/config.json ]; then
    cp /etc/sing-box/config.json "/etc/sing-box/config.json.bak.$(date +%s)"
    echo "🗂️ 已备份旧配置文件"
fi

# ⬇️ 下载并安装 .deb 包
DEB_URL="${GH_BASE}/SagerNet/sing-box/releases/download/v${VERSION}/sing-box_${VERSION}_linux_${ARCH}.deb"
echo "⬇️ 正在下载: ${DEB_URL}"
curl -Lo sing-box.deb "$DEB_URL" || { echo "❌ 下载失败，请检查网络或手动下载"; exit 1; }

dpkg -i sing-box.deb
rm -f sing-box.deb

# 🚀 启动服务
systemctl daemon-reexec
systemctl restart sing-box && echo "✅ 已启动 sing-box 服务"

# 🔄 UI Git 更新（可选）
if [ -d /var/lib/sing-box/ui ]; then
    git -C /var/lib/sing-box/ui pull -r || echo "⚠️ git pull 失败，可忽略"
fi

echo "🎉 安装完成，当前版本: $(sing-box version | grep version | cut -d ' ' -f3)"
