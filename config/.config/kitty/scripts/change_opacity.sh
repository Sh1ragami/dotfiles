#!/bin/bash
# change_opacity.sh - Kittyの透過度を動的に調整するスクリプト

CONF_FILE="$HOME/.config/kitty/opacity.conf"

# 現在の設定値を取得
if [ -f "$CONF_FILE" ]; then
    OPACITY=$(grep "background_opacity" "$CONF_FILE" | awk '{print $2}')
else
    OPACITY="0.82"
fi

if [ -z "$OPACITY" ]; then
    OPACITY="0.82"
fi

# 加減算の実行
if [ "$1" == "up" ]; then
    # 不透明度を上げる (透過度を下げる)
    NEW_OPACITY=$(echo "$OPACITY + 0.05" | bc)
    # 浮動小数の比較
    if (( $(echo "$NEW_OPACITY > 1.0" | bc -l) )); then
        NEW_OPACITY="1.0"
    fi
elif [ "$1" == "down" ]; then
    # 不透明度を下げる (透過度を上げる)
    NEW_OPACITY=$(echo "$OPACITY - 0.05" | bc)
    if (( $(echo "$NEW_OPACITY < 0.3" | bc -l) )); then
        NEW_OPACITY="0.3"
    fi
else
    exit 1
fi

# 新しい設定値を書き込み
echo "background_opacity $NEW_OPACITY" > "$CONF_FILE"

# 起動中のすべてのKittyに適用通知シグナルを送る
pkill -USR1 kitty || true
