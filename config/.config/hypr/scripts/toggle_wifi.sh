#!/bin/bash

CLASS="nmtui-float"

# すでに起動しているかプロセス名でチェック
if pgrep -f "kitty --class $CLASS" >/dev/null; then
  # 起動していれば強制終了（これで確認画面が出ない）
  pkill -f "kitty --class $CLASS"
else
  # 起動していなければ、確認設定をオフにして起動
  kitty --class "$CLASS" -o confirm_os_window_close=0 nmtui
fi
