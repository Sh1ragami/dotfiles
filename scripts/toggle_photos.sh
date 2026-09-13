#!/usr/bin/env bash
set -euo pipefail

MOUNT_DIR="$HOME/スマホ写真"
PIN_FILE="$HOME/.config/rclone/.photos_vault_pin"
mkdir -p "$HOME/.config/rclone"

# Python 認証ヘルパー関数
verify_pin() {
    local input="$1"
    python3 -c "
import sys, hashlib
try:
    with open('$PIN_FILE', 'r') as f:
        stored = f.read().strip()
    salt, h = stored.split(':', 1)
    if hashlib.sha256((salt + sys.argv[1]).encode('utf-8')).hexdigest() == h:
        sys.exit(0)
    else:
        sys.exit(1)
except Exception:
    sys.exit(2)
" "$input"
}

save_pin() {
    local pin="$1"
    python3 -c "
import sys, os, hashlib
salt = os.urandom(16).hex()
h = hashlib.sha256((salt + sys.argv[1]).encode('utf-8')).hexdigest()
with open('$PIN_FILE', 'w') as f:
    f.write(f'{salt}:{h}')
os.chmod('$PIN_FILE', 0o600)
" "$pin"
}

# 1. 既にマウント中（ロック解除中）の場合
if mountpoint -q "$MOUNT_DIR"; then
    CHOICE=$(printf "🔒 スマホ写真をロックする (閉じる)\n📂 フォルダを開く (Thunar)" | wofi --dmenu --prompt "スマホ写真 (現在ロック解除中)" --lines 2 --width 350)
    if [ "$CHOICE" = "🔒 スマホ写真をロックする (閉じる)" ]; then
        fusermount3 -u "$MOUNT_DIR"
        rmdir "$MOUNT_DIR" 2>/dev/null || true
        notify-send -i security-high "スマホ写真" "🔒 ロックしました（マウント解除）"
    elif [ "$CHOICE" = "📂 フォルダを開く (Thunar)" ]; then
        thunar "$MOUNT_DIR" &
    fi
    exit 0
fi

# 2. 未マウント（ロック中）の場合：PINの確認または初期設定
if [ ! -f "$PIN_FILE" ]; then
    # 初回設定
    NEW_PIN=$(echo "" | wofi --dmenu --password --prompt "新しいPIN/パスワードを設定:" --lines 1 --width 380)
    if [ -z "$NEW_PIN" ]; then
        exit 0
    fi
    CONFIRM_PIN=$(echo "" | wofi --dmenu --password --prompt "確認のため再入力:" --lines 1 --width 380)
    if [ "$NEW_PIN" != "$CONFIRM_PIN" ]; then
        notify-send -u critical -i dialog-error "スマホ写真" "PINが一致しませんでした。設定を中止します。"
        exit 1
    fi
    save_pin "$NEW_PIN"
    notify-send -i security-high "スマホ写真" "PINを設定しました。ロック解除を開始します。"
else
    # 既存PIN入力
    ENTERED_PIN=$(echo "" | wofi --dmenu --password --prompt "PINを入力してください:" --lines 1 --width 350)
    if [ -z "$ENTERED_PIN" ]; then
        exit 0
    fi
    if ! verify_pin "$ENTERED_PIN"; then
        notify-send -u critical -i dialog-error "スマホ写真" "❌ PINが間違っています"
        exit 1
    fi
fi

# 3. ロック解除（マウント実行）
mkdir -p "$MOUNT_DIR"
rclone mount gdrive:スマホ写真 "$MOUNT_DIR" \
    --vfs-cache-mode full \
    --vfs-cache-max-size 10G \
    --vfs-cache-max-age 24h \
    --dir-cache-time 72h \
    --daemon

# マウント完了待機（最大5秒）
for i in {1..10}; do
    if mountpoint -q "$MOUNT_DIR"; then
        break
    fi
    sleep 0.5
done

thunar "$MOUNT_DIR" &
notify-send -i security-low "スマホ写真" "🔓 ロック解除しました\n見終わったらもう一度アプリを開いて施錠できます"
