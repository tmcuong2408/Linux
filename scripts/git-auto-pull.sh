#!/bin/bash
USER_NAME="admin" # ⚠️ THAY BẰNG USERNAME THỰC TẾ CỦA BẠN
USER_HOME="/home/$USER_NAME"

# Danh sách các repo cần pull
REPOS=(
    "$USER_HOME/mu"
    "$USER_HOME/Linux"
    "$USER_HOME/mu_document"
    "$USER_HOME/tuvi"
    "$USER_HOME/uncertain_number_theory"
    "$USER_HOME/uncertain_set_theory"
)

exec > /dev/tty1 2>&1

echo ""
echo "=================================================="
echo "🚀 [BOOT] BẮT ĐẦU TỰ ĐỘNG GIT PULL CÁC REPO..."
echo "=================================================="

# 1. Thử chờ mạng tối đa 15 giây (mỗi lần thử cách nhau 2 giây)
echo "🌐 Đang kiểm tra kết nối mạng..."
CONNECTED=0
for i in {1..8}; do
    if ping -c 1 -W 2 github.com > /dev/null 2>&1; then
        CONNECTED=1
        break
    fi
    echo "⏳ Đang chờ card mạng/Wi-Fi nhận IP... ($i/8)"
    sleep 2
done

if [ $CONNECTED -eq 0 ]; then
    echo "❌ Bỏ qua auto-pull: Không thể kết nối tới GitHub (Chưa có mạng)."
    echo "=================================================="
    sleep 3
    exit 0
fi

echo "✅ Mạng đã sẵn sàng!"

# 2. Chạy pull dưới danh nghĩa User chính (để dùng đúng SSH key/Credential của user)
for repo in "${REPOS[@]}"; do
    if [ -d "$repo/.git" ]; then
        echo "🔄 Đang kéo code tại: $repo"
        su - "$USER_NAME" -c "git -C \"$repo\" pull --ff-only"
    else
        echo "⏭️ Bỏ qua (Không tìm thấy): $repo"
    fi
done

echo "=================================================="
echo "✅ HOÀN TẤT CẬP NHẬT GIT!"
echo "⏳ TẠM DỪNG 5 GIÂY ĐỂ XEM KẾT QUẢ..."
echo "=================================================="
sleep 5
