#!/bin/bash

# 1. Cấu hình username GitHub
TARGET_USER="tmcuong2408"

# Tự động lấy tên user Windows
WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
[ -z "$WIN_USER" ] && WIN_USER="cuong"

DEST_DIR="/mnt/c/Users/$WIN_USER/Desktop/github_backup"

mkdir -p "$DEST_DIR"
cd "$DEST_DIR" || exit 1

echo "=== Đang lấy danh sách repository của $TARGET_USER... ==="

# Kiểm tra và cài đặt jq nếu thiếu
if ! command -v jq &> /dev/null; then
    sudo apt update && sudo apt install jq -y
fi

# Thêm github.com vào known_hosts để tránh hỏi xác nhận SSH
mkdir -p ~/.ssh
ssh-keyscan -t ed25519,rsa github.com >> ~/.ssh/known_hosts 2>/dev/null

# Lấy danh sách repo qua GitHub REST API
PAGE=1
REPOS=""

while :; do
    RESPONSE=$(curl -s "https://api.github.com/users/$TARGET_USER/repos?per_page=100&page=$PAGE")
    PAGE_REPOS=$(echo "$RESPONSE" | jq -r '.[].name' 2>/dev/null)
    
    if [ -z "$PAGE_REPOS" ] || [ "$PAGE_REPOS" == "null" ]; then
        break
    fi
    
    REPOS="$REPOS $PAGE_REPOS"
    ((PAGE++))
done

if [ -z "$REPOS" ]; then
    echo "Không tìm thấy repository nào hoặc vượt quá API rate limit."
    exit 1
fi

for REPO in $REPOS; do
    echo "--------------------------------------------------"
    if [ -d "$REPO" ]; then
        echo "[UPDATE] $REPO đã tồn tại, đang git pull..."
        git -C "$REPO" pull
    else
        echo "[CLONE] Đang clone $REPO..."
        git clone "git@github.com:$TARGET_USER/$REPO.git"
    fi
done

echo "--------------------------------------------------"
echo "=== Hoàn tất! Tất cả repo đã được lưu tại: $DEST_DIR ==="