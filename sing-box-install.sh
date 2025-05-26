#!/bin/bash

set -e -o pipefail

# 检测架构
ARCH_RAW=$(uname -m)
case "${ARCH_RAW}" in
    'x86_64')    ARCH='amd64' ;;
    'x86' | 'i686' | 'i386') ARCH='386' ;;
    'aarch64' | 'arm64') ARCH='arm64' ;;
    'armv7l') ARCH='armv7' ;;
    's390x') ARCH='s390x' ;;
    *) echo "不支持的架构: ${ARCH_RAW}" && exit 1 ;;
esac
echo "当前设备架构: ${ARCH_RAW}"

# 获取 GitHub 上的最新版本（包括 beta）
LATEST_VERSION=$(curl -s "https://api.github.com/repos/SagerNet/sing-box/releases?per_page=1" \
  | grep '"tag_name":' | head -n1 \
  | cut -d '"' -f4 | sed 's/^v//')

# 用户可通过参数指定版本
INSTALL_VERSION="${1:-${LATEST_VERSION}}"

echo "GitHub 最新版本: ${LATEST_VERSION}"
echo "你将安装的版本: ${INSTALL_VERSION}"

# 提示确认
read -p "是否安装版本 ${INSTALL_VERSION}？（y/n）: " choice
if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
    echo "安装已取消"
    exit 0
fi

# 下载并安装
echo "正在下载 sing-box_${INSTALL_VERSION}_linux_${ARCH}.deb ..."
curl -Lo sing-box.deb "https://github.com/SagerNet/sing-box/releases/download/v${INSTALL_VERSION}/sing-box_${INSTALL_VERSION}_linux_${ARCH}.deb"

echo "下载完成，开始安装..."
sudo dpkg -i sing-box.deb

# 清理
rm sing-box.deb
echo "安装完成。你可以自行测试配置或重启服务"
