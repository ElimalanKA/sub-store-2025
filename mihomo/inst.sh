#!/bin/bash
set -e

BIN_NAME="mihomo"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/mihomo"
CERT_DIR="$CONFIG_DIR/certs"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
PORT="44401"
PASSWORD="9aB7xD3pQwL2eF6z"
REPO="MetaCubeX/mihomo"
REPO_API="https://api.github.com/repos/${REPO}/releases"

detect_arch() {
  case "$(uname -m)" in
    x86_64) echo "amd64" ;;
    aarch64) echo "arm64" ;;
    armv7l|armv6l) echo "armv7" ;;
    *) echo "Unsupported architecture" && exit 1 ;;
  esac
}

get_latest_version() {
  curl -s "${REPO_API}/latest" | grep -oP '"tag_name": "\K(.*)(?=")'
}

get_installed_version() {
  if command -v "$BIN_NAME" >/dev/null 2>&1; then
    "$BIN_NAME" -v 2>/dev/null || echo "未知版本"
  else
    echo "未安装"
  fi
}

check_cert_files() {
  echo "🔐 检查密钥文件路径："
  echo "  - 证书文件: $CERT_DIR/xyz.crt"
  echo "  - 私钥文件: $CERT_DIR/xyz.key"
  if [[ -f "$CERT_DIR/xyz.crt" && -f "$CERT_DIR/xyz.key" ]]; then
    echo "✅ 密钥文件已存在"
  else
    echo "⚠️ 证书或私钥文件不存在，请将 xyz.crt 和 xyz.key 放入上述路径后再运行脚本"
    exit 1
  fi
}

generate_config() {
  echo "🧩 生成配置文件 config.yaml ..."
  sudo mkdir -p "$CERT_DIR"
  sudo tee "$CONFIG_FILE" > /dev/null <<EOF
listeners:
  - name: anytls-in-1
    type: anytls
    port: $PORT
    listen: 0.0.0.0
    users:
      hkanytls01: $PASSWORD
      hkanytls02: $PASSWORD
    certificate: $CERT_DIR/xyz.crt
    private-key: $CERT_DIR/xyz.key
    padding-scheme: |
      stop=8
      0=30-30
      1=100-400
      2=400-500,c,500-1000,c,500-1000,c,500-1000,c,500-1000
      3=9-9,500-1000
      4=500-1000
      5=500-1000
      6=500-1000
      7=500-1000
EOF
}

download_binary() {
  ARCH=$(detect_arch)
  VERSION="$1"
  FILE="${BIN_NAME}-linux-${ARCH}"
  URL="https://github.com/${REPO}/releases/download/${VERSION}/${FILE}"

  echo "📦 下载 $BIN_NAME $VERSION ($ARCH)..."
  curl -L "$URL" -o "/tmp/$BIN_NAME"
  chmod +x "/tmp/$BIN_NAME"
  sudo mv "/tmp/$BIN_NAME" "$INSTALL_DIR/$BIN_NAME"
}

start_mihomo() {
  echo "🚀 启动 mihomo 服务 ..."
  nohup "$INSTALL_DIR/$BIN_NAME" run -c "$CONFIG_FILE" > /var/log/mihomo.log 2>&1 &
  echo "✅ mihomo 已启动"
  echo "📡 当前监听端口: $PORT"
  echo "🔐 使用证书路径: $CERT_DIR/xyz.crt"
  echo "🔐 使用私钥路径: $CERT_DIR/xyz.key"
}

interactive_menu() {
  ARCH=$(detect_arch)
  INSTALLED=$(get_installed_version)
  LATEST=$(get_latest_version)

  echo "=============================="
  echo " mihomo 安装脚本（交互模式）"
  echo "=============================="
  echo "📌 当前架构: $ARCH"
  echo "📦 已安装版本: $INSTALLED"
  echo "🌐 最新版本: $LATEST"
  echo "🔐 密钥路径: $CERT_DIR/xyz.crt / xyz.key"
  echo "📡 默认监听端口: $PORT"
  echo "------------------------------"
  echo "请选择操作："
  echo "1) 安装最新版并启动"
  echo "2) 安装指定版本并启动"
  echo "3) 卸载 mihomo"
  echo "4) 退出"
  echo "------------------------------"
  read -rp "请输入选项 [1-4]: " choice

  case "$choice" in
    1)
      check_cert_files
      download_binary "$LATEST"
      generate_config
      start_mihomo
      ;;
    2)
      read -rp "请输入要安装的版本号（例如 v1.19.14）: " VERSION
      check_cert_files
      download_binary "$VERSION"
      generate_config
      start_mihomo
      ;;
    3)
      echo "🧹 卸载 mihomo ..."
      sudo rm -f "$INSTALL_DIR/$BIN_NAME"
      echo "✅ 已卸载 mihomo"
      ;;
    4)
      echo "👋 已退出"
      exit 0
      ;;
    *)
      echo "❌ 无效选项，请重新运行脚本"
      exit 1
      ;;
  esac
}

interactive_menu
