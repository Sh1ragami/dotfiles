#!/bin/bash
# toggle_position.sh - Waybarの配置を上(top)と左(left)でトグルするスクリプト

CONFIG_FILE="$HOME/.config/waybar/config.jsonc"

if [ ! -f "$CONFIG_FILE" ]; then
    exit 1
fi

# 現在のポジションを取得
CURRENT_POS=$(grep -po '"position":\s*"\K[^"]+' "$CONFIG_FILE")

if [ "$CURRENT_POS" == "top" ]; then
    NEW_POS="left"
else
    NEW_POS="top"
fi

# 置換して保存
sed -i "s/\"position\":\s*\"$CURRENT_POS\"/\"position\": \"$NEW_POS\"/g" "$CONFIG_FILE"

# Waybarの再起動
pkill waybar
sleep 0.5
hyprctl dispatch exec waybar
