#!/bin/bash
# toggle_position.sh - Waybarの配置を上(top)と左(left)でトグルするスクリプト

DIR="$HOME/.config/waybar"
CONFIG_LINK="$DIR/config.jsonc"
TOP_CONFIG="$DIR/config_top.jsonc"
LEFT_CONFIG="$DIR/config_left.jsonc"

if [ ! -L "$CONFIG_LINK" ] && [ ! -f "$CONFIG_LINK" ]; then
    ln -sf "$TOP_CONFIG" "$CONFIG_LINK"
fi

# リンク先を判定してトグル切り替え
TARGET=$(readlink -f "$CONFIG_LINK")

if [[ "$TARGET" == *config_top.jsonc ]]; then
    ln -sf "$LEFT_CONFIG" "$CONFIG_LINK"
else
    ln -sf "$TOP_CONFIG" "$CONFIG_LINK"
fi

# Waybarの再起動
pkill waybar
sleep 0.5
hyprctl dispatch exec waybar
