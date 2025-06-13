#!/bin/bash

# 配置区
DATE=$(date +%Y%m%d_%H%M)
BACKUP_NAME="sub-store-backup-$DATE.tar.gz"
LOCAL_BACKUP_DIR="/root"
LOCAL_ARCHIVE="$LOCAL_BACKUP_DIR/$BACKUP_NAME"
REMOTE_USER="root"
REMOTE_HOST="192.168.2.240"
REMOTE_DIR="/mnt/usb/images/100"
BACKUP_SOURCE="/etc/sub-store"

# 功能选择
echo -e "\n🔧 请选择操作类型："
echo "1) 备份 sub-store 配置"
echo "2) 恢复最近一次备份"
read -p "输入数字选择 [1/2]: " choice

case "$choice" in
  1)
    echo -e "\n📦 正在打包配置目录..."
    tar -czf "$LOCAL_ARCHIVE" "$BACKUP_SOURCE"

    echo -e "\n🚀 正在上传到远程备份目录..."
    scp "$LOCAL_ARCHIVE" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"

    if [ $? -eq 0 ]; then
        echo -e "\n✅ 备份成功：$BACKUP_NAME 已上传到 $REMOTE_HOST:$REMOTE_DIR"
    else
        echo -e "\n❌ 备份失败，请检查网络或权限设置"
    fi
    ;;

  2)
    echo -e "\n📥 正在列出远程备份列表..."
    ssh $REMOTE_USER@$REMOTE_HOST "ls -t $REMOTE_DIR/sub-store-backup-*.tar.gz | head -n 1" > /tmp/latest_backup.txt
    LATEST_BACKUP=$(cat /tmp/latest_backup.txt | awk -F/ '{print $NF}')

    if [ -z "$LATEST_BACKUP" ]; then
        echo "⚠️ 未找到远程备份文件，无法恢复。"
        exit 1
    fi

    echo -e "\n📥 正在下载最新备份：$LATEST_BACKUP"
    scp "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/$LATEST_BACKUP" "$LOCAL_BACKUP_DIR/"

    echo -e "\n🛠️ 正在解压还原..."
    tar -xzf "$LOCAL_BACKUP_DIR/$LATEST_BACKUP" -C /

    echo -e "\n✅ 恢复完成！已使用 $LATEST_BACKUP 还原 sub-store 配置。"
    ;;

  *)
    echo "❌ 无效的选择，请输入 1 或 2"
    ;;
esac
