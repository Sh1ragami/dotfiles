#!/bin/bash

# Waybarからクリックされた時の処理（トグル）
if [ "$1" == "toggle" ]; then
  if systemctl is-active --quiet keyd; then
    sudo systemctl stop keyd
  else
    sudo systemctl start keyd
  fi
  # トグル後、Waybarに即座に表示を更新させるシグナルを送信
  pkill -RTMIN+8 waybar
  exit 0
fi

# Waybarに現在の状態を表示する処理（JSON出力）
if systemctl is-active --quiet keyd; then
  # ONの時
  echo '{"text": "ON", "class": "active", "tooltip": "keyd is running"}'
else
  # OFFの時
  echo '{"text": "NO", "class": "inactive", "tooltip": "keyd is stopped"}'
fi
