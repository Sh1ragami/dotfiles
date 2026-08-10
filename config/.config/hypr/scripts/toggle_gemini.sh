#!/bin/bash

GEMINI_CLASS="chrome-gemini.google.com__-Default"

# すでに Gemini のウィンドウが存在するか確認
if ! hyprctl clients -j | jq -e ".[] | select(.class == \"$GEMINI_CLASS\")" > /dev/null; then
    # 存在しなければバックグラウンド起動
    google-chrome-stable --app=https://gemini.google.com/ &
    
    # ウィンドウが識別されるまで待機（最大2秒）
    for i in {1..20}; do
        if hyprctl clients -j | jq -e ".[] | select(.class == \"$GEMINI_CLASS\")" > /dev/null; then
            break
        fi
        sleep 0.1
    done
fi

# Hyprland の special workspace "gemini" をトグル表示 / 非表示
hyprctl dispatch togglespecialworkspace gemini
