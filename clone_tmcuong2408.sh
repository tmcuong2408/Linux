#!/bin/bash

# 1. Cấu hình username và thư mục đích trên Windows Desktop
TARGET_USER="tmcuong2408"
DEST_DIR="/mnt/c/Users/cuong/Desktop/github_backup"

# Tạo thư mục lưu trữ trên Desktop nếu chưa có
mkdir -p "$DEST_DIR"
cd "$DEST_DIR" || exit

echo "=== Đang lấy danh sách repository của $TARGET_USER... ==="

# Kiểm tra và cài đặt jq nếu thiếu
if ! command -v jq &> /dev/null; then
    sudo apt update && sudo apt install jq -y
fi

# Lấy danh sách danh sách repo qua GitHub REST API
REPOS=$(curl -s "https://api.github.com/users/$TARGET_USER/repos?per_page=1000" | jq -r '.[].name 2>/dev/null')

if [ -z "$REPOS" ] || [ "$REPOS" == "null" ]; then
    echo "Không tìm thấy repository nào hoặc đạt giới hạn API rate limit."
    exit 1
fi

for REPO in $REPOS; do
    echo "--------------------------------------------------"
    if [ -d "$REPO" ]; then
        echo "[UPDATE] $REPO đã tồn tại trên Desktop, đang git pull..."
        cd "$REPO" && git pull && cd ..
    else
        echo "[CLONE] Đang clone $REPO qua SSH..."
        git clone "git@github.com:$TARGET_USER/$REPO.git"
    fi
done

echo "--------------------------------------------------"
echo "=== Hoàn tất! Tất cả repo đã được lưu tại: $DEST_DIR ==="
