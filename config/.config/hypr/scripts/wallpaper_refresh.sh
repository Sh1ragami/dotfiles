#!/bin/bash

# 壁紙のパス
WALLPAPER="$HOME/.config/hypr/wallpaper.png"

# 初期起動時の壁紙確実適用（hyprpaper デーモン起動待ち）
sleep 1
hyprctl hyprpaper unload all || true
hyprctl hyprpaper preload "$WALLPAPER" || true
hyprctl hyprpaper wallpaper ",$WALLPAPER" || true

# Hyprlandのイベントを監視
hyprctl event | while read -r line; do
  # モニターが追加されたら壁紙を再適用
  if [[ $line == monitoradded* ]]; then
    sleep 2
    hyprctl hyprpaper preload "$WALLPAPER" || true
    hyprctl hyprpaper wallpaper ",$WALLPAPER" || true
  fi
done

