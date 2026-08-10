#!/bin/bash

THUNAR_CLASS="thunar"

# すでに Thunar のウィンドウが存在するか確認
if ! hyprctl clients -j | jq -e ".[] | select(.class == \"$THUNAR_CLASS\")" > /dev/null; then
    # 存在しなければバックグラウンド起動
    thunar &
    
    # ウィンドウが識別されるまで待機（最大2秒）
    for i in {1..20}; do
        if hyprctl clients -j | jq -e ".[] | select(.class == \"$THUNAR_CLASS\")" > /dev/null; then
            break
        fi
        sleep 0.1
    done
fi

# Hyprland の special workspace "thunar" をトグル表示 / 退避
hyprctl dispatch togglespecialworkspace thunar
