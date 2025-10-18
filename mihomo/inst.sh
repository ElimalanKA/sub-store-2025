#!/bin/bash

# mihomo installer/uninstaller for Linux
# Author: Copilot for Tia

set -e

INSTALL_DIR="/usr/local/bin"
TMP_DIR="/tmp/mihomo_install"
BIN_NAME="mihomo"
REPO_API="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest"

detect_arch() {
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64) echo "amd64" ;;
    aarch64) echo "arm64" ;;
    armv7l|armv6l) echo "armv7" ;;
    *) echo "Unsupported architecture: $ARCH" && exit 1 ;;
  esac
}

get_latest_version() {
  curl -s "$REPO_API" | grep -oP '"tag_name": "\K(.*)(?=")'
}

download_binary() {
  ARCH=$(detect_arch)
  VERSION=$(get_latest_version)
  FILE_NAME="${BIN_NAME}-linux-${ARCH}"
  URL="https://github.com/MetaCubeX/mihomo/releases/download/${VERSION}/${FILE_NAME}.tar.gz"

  echo "📦 下载 $FILE_NAME ($VERSION)..."
  mkdir -p "$TMP_DIR"
  curl -L "$URL" -o "$TMP_DIR/${FILE_NAME}.tar.gz"

  echo "📂 解压..."
  tar -xzf "$TMP_DIR/${FILE_NAME}.tar.gz" -C "$TMP_DIR"
  chmod +x "$TMP_DIR/$BIN_NAME"
}

install_binary() {
  echo "🚀 安装 mihomo 到 $INSTALL_DIR ..."
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

main() {
  case "$1" in
    install)
      download_binary
      install_binary
      cleanup
      ;;
    uninstall)
      uninstall_binary
      ;;
    *)
      echo "用法: $0 {install|uninstall}"
      exit 1
      ;;
  esac
}

main "$@"
