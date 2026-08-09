#!/bin/bash

# 最初に今のワークスペースIDを覚える
LAST_WS=$(hyprctl activeworkspace -j | jq '.id')

while true; do
  # 現在のワークスペースIDを取得
  CURRENT_WS=$(hyprctl activeworkspace -j | jq '.id')

  # もしIDが変わっていたら（＝ワークスペース移動したら）
  if [ "$CURRENT_WS" != "$LAST_WS" ]; then
    # 確実に、かつ確認画面を出さずにプロセスを殺す
    pkill -f "nmtui-float" >/dev/null 2>&1

    # 覚えているIDを更新
    LAST_WS=$CURRENT_WS
  fi

  # 0.2秒待機（CPU負荷を抑える）
  #!/bin/bash

  # Hyprland公式のイベントモニターを開始
  hyprctl event | while read -r line; do
    # "workspace>>" (ワークスペース移動) という文字列が含まれていたら
    if [[ $line == workspace* ]]; then
      # nmtui-float を強制終了
      pkill -f "kitty --class nmtui-float" >/dev/null 2>&1
    fi
  done
  sleep 0.2
done
