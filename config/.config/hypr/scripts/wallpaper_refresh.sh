#!/bin/bash

# あなたの壁紙のパス（ここを書き換えてください）
WALLPAPER="/home/sh1ragami/Pictures/wallpaper3.jpg"

# Hyprlandのイベントを監視
hyprctl event | while read -r line; do

  # 1. モニターが追加されたら壁紙を再適用
  if [[ $line == monitoradded* ]]; then
    # モニターが認識されるまで少し待機
    sleep 2
    swww img "$WALLPAPER"
  fi

done
