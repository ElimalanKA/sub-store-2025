#!/bin/bash

echo "请选择安装类型："
echo "1. 最新稳定版"
echo "2. 最新测试版（beta）"
echo "3. 指定版本"
read -p "输入选项 [1/2/3]: " choice

case "$choice" in
  1)
    curl -fsSL https://sing-box.app/install.sh | sh
    ;;
  2)
    curl -fsSL https://sing-box.app/install.sh | sh -s -- --beta
    ;;
  3)
    read -p "请输入版本号（例如 1.11.0）: " version
    curl -fsSL https://sing-box.app/install.sh | sh -s -- --version "$version"
    ;;
  *)
    echo "无效选项，退出。"
    exit 1
    ;;
esac
