#!/bin/bash

# Hyprland のワークスペース切り替えイベントを監視して nmtui-float を自動クローズ
hyprctl event | while read -r line; do
  if [[ $line == workspace* ]]; then
    pkill -f "kitty --class nmtui-float" >/dev/null 2>&1 || true
    pkill -f "nmtui-float" >/dev/null 2>&1 || true
  fi
done
