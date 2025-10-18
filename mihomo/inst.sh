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
  FILE="${BIN_NAME}-linux-${ARCH}.tar.gz"
  URL="https://github.com/${REPO}/releases/download/${VERSION}/${FILE}"

  echo "📦 下载 $BIN_NAME $VERSION ($ARCH)..."
  mkdir -p "$TMP_DIR"
  curl -L "$URL" -o "$TMP_DIR/$FILE"
  tar -xzf "$TMP_DIR/$FILE" -C "$TMP_DIR"
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

main() {
  case "$1" in
    install)
      VERSION="${2:-$(get_latest_version)}"
      download_binary "$VERSION"
      install_binary
      cleanup
      ;;
    uninstall)
      uninstall_binary
      ;;
    *)
      echo "用法: $0 install [版本号] | uninstall"
      exit 1
      ;;
  esac
}

main "$@"
