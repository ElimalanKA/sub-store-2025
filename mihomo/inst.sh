#!/bin/bash
set -e

BIN_NAME="mihomo"
INSTALL_DIR="/usr/local/bin"
TMP_DIR="/tmp/mihomo_install"
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

download_binary() {
  ARCH=$(detect_arch)
  VERSION="$1"
  FILE="${BIN_NAME}-linux-${ARCH}"
  URL="https://github.com/${REPO}/releases/download/${VERSION}/${FILE}"

  echo "📦 下载 $BIN_NAME $VERSION ($ARCH)..."
  mkdir -p "$TMP_DIR"
  curl -L "$URL" -o "$TMP_DIR/$BIN_NAME"

  if [ ! -s "$TMP_DIR/$BIN_NAME" ]; then
    echo "❌ 下载失败，文件为空或不存在。请检查版本号是否正确：$VERSION"
    exit 1
  fi

  chmod +x "$TMP_DIR/$BIN_NAME"
}

install_binary() {
  sudo mv "$TMP_DIR/$BIN_NAME" "$INSTALL_DIR/$BIN_NAME"
  echo "✅ 安装完成：$(which mihomo)"
}

uninstall_binary() {
  echo "🧹 卸载 mihomo ..."
  sudo rm -f "$INSTALL_DIR/$BIN_NAME"
  echo "✅ 已卸载 mihomo"
}

cleanup() {
  rm -rf "$TMP_DIR"
}

interactive_menu() {
  echo "=============================="
  echo " mihomo 安装脚本（交互模式）"
  echo "=============================="
  echo "请选择操作："
  echo "1) 安装最新版"
  echo "2) 安装指定版本"
  echo "3) 卸载 mihomo"
  echo "4) 退出"
  echo "------------------------------"
  read -rp "请输入选项 [1-4]: " choice

  case "$choice" in
    1)
      VERSION=$(get_latest_version)
      echo "📌 最新版本为: $VERSION"
      download_binary "$VERSION"
      install_binary
      cleanup
      ;;
    2)
      read -rp "请输入要安装的版本号（例如 v1.19.14）: " VERSION
      download_binary "$VERSION"
      install_binary
      cleanup
      ;;
    3)
      uninstall_binary
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

