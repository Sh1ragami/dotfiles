#!/bin/bash
# toggle_opacity.sh - Kittyの透過度を 0.3 -> 0.6 -> 0.8 -> 1.0 にローテーション切り替えするスクリプト

CONF_FILE="$HOME/.config/kitty/opacity.conf"

if [ -f "$CONF_FILE" ]; then
    OPACITY=$(grep "background_opacity" "$CONF_FILE" | awk '{print $2}')
else
    OPACITY="0.80"
fi

# 次の不透明度を判定 (0.3 -> 0.6 -> 0.8 -> 1.0)
case "$OPACITY" in
    0.3*) NEW_OPACITY="0.60" ;;
    0.6*) NEW_OPACITY="0.80" ;;
    0.8*) NEW_OPACITY="1.0" ;;
    *) NEW_OPACITY="0.30" ;;
esac

# 書き込み
echo "background_opacity $NEW_OPACITY" > "$CONF_FILE"

# メイン設定ファイルの更新日時を更新し、再読み込みを強制トリガー
touch "$HOME/.config/kitty/kitty.conf"

# すべてのKittyプロセスに適用通知シグナルを送信
pkill -USR1 kitty || true
