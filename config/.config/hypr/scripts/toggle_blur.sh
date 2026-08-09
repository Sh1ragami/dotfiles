#!/bin/bash
# toggle_blur.sh - Hyprlandのウィンドウブラー(すりガラス効果)を動的にON/OFFトグルするスクリプト

CONFIG_FILE="$HOME/.config/hypr/hyprland.conf"

# 現在の有効状態を取得 (1 = 有効, 0 = 無効)
CURRENT_STATUS=$(hyprctl getoption decoration:blur:enabled | grep "int:" | awk '{print $2}')

if [ "$CURRENT_STATUS" == "1" ]; then
    # 現在有効なので、無効(false)にする
    hyprctl keyword decoration:blur:enabled false
    # 設定ファイルの書き換え (enabled = true -> false)
    if [ -f "$CONFIG_FILE" ]; then
        sed -i 's/enabled = true/enabled = false/g' "$CONFIG_FILE"
    fi
else
    # 現在無効なので、有効(true)にする
    hyprctl keyword decoration:blur:enabled true
    if [ -f "$CONFIG_FILE" ]; then
        sed -i 's/enabled = false/enabled = true/g' "$CONFIG_FILE"
    fi
fi
