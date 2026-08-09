#!/bin/bash

# tmuxサーバーが動いていない場合は何も表示しない
if ! tmux has-session 2>/dev/null; then
  exit 0
fi

# #S: セッション名
# #I: ウィンドウ番号
# #W: ウィンドウ名
# 例: "my-session [1:zsh]" のような形式で取得
INFO=$(tmux display-message -p '#S:#I')

if [ -n "$INFO" ]; then
  echo "󰆍 $INFO"
fi
