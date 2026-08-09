#!/bin/bash

# 1. すでに wofi が起動している場合は、それを終了してスクリプトを閉じる（二重起動防止）
if pgrep -x "wofi" >/dev/null; then
  pkill -x "wofi"
  exit 0
fi

# 設定ファイルのパス
VOL_FILE="$HOME/.config/wayvibes/vol"
PACK_FILE="$HOME/.config/wayvibes/pack"

# 現在の設定を読み込み
CUR_VOL=$(cat "$VOL_FILE" 2>/dev/null || echo "2.5")
CUR_PACK=$(cat "$PACK_FILE" 2>/dev/null || echo "$HOME/.local/share/soundpacks/nk-cream")

# メニューの選択肢
OPTIONS="󰓅 Toggle ON/OFF
󰝝 Volume Up (+0.5)
󰝞 Volume Down (-0.5)
󰌌 Switch: NK-Cream
󰌌 Switch: Banana Split (Lubed)
󰌌 Switch: Banana Split (Stock)
󰌌 Switch: Razer Green
󰌌 Switch: Crystal Purple"

# 2. wofi の実行
# --hide-scroll: スクロールバーを隠す
# --key_exit: 特定のキーで閉じる設定（必要に応じて）
CHOICE=$(echo -e "$OPTIONS" | wofi --dmenu \
  --prompt "Keyboard Sound Control" \
  --width 350 \
  --height 400 \
  --cache-file /dev/null \
  --hide-scroll \
  --define "key_exit=Escape")

# 選択されなかった（Escや枠外クリックで閉じられた）場合は終了
if [ -z "$CHOICE" ]; then
  exit 0
fi

# 3. 共通の実行関数（コードの重複を削減）
run_wayvibes() {
  pkill wayvibes
  PIPEWIRE_LATENCY="32/48000" wayvibes "$1" -v "$2" -bg
}

case "$CHOICE" in
*"Toggle"*)
  pgrep wayvibes && pkill wayvibes || run_wayvibes "$CUR_PACK" "$CUR_VOL"
  ;;
*"Volume Up"*)
  NEW_VOL=$(echo "$CUR_VOL + 0.5" | bc)
  echo "$NEW_VOL" >"$VOL_FILE"
  run_wayvibes "$CUR_PACK" "$NEW_VOL"
  ;;
*"Volume Down"*)
  NEW_VOL=$(echo "$CUR_VOL - 0.5" | bc)
  [ $(echo "$NEW_VOL < 0" | bc) -eq 1 ] && NEW_VOL=0
  echo "$NEW_VOL" >"$VOL_FILE"
  run_wayvibes "$CUR_PACK" "$NEW_VOL"
  ;;
*"NK-Cream"*)
  NEW_PACK="$HOME/.local/share/soundpacks/nk-cream"
  echo "$NEW_PACK" >"$PACK_FILE"
  run_wayvibes "$NEW_PACK" "$CUR_VOL"
  ;;
*"Banana Split (Lubed)"*)
  NEW_PACK="$HOME/.local/share/soundpacks/banana-lubed"
  echo "$NEW_PACK" >"$PACK_FILE"
  run_wayvibes "$NEW_PACK" "$CUR_VOL"
  ;;
*"Banana Split (Stock)"*)
  NEW_PACK="$HOME/.local/share/soundpacks/banana-stock"
  echo "$NEW_PACK" >"$PACK_FILE"
  run_wayvibes "$NEW_PACK" "$CUR_VOL"
  ;;
*"Razer Green"*)
  NEW_PACK="$HOME/.local/share/soundpacks/razer-green"
  echo "$NEW_PACK" >"$PACK_FILE"
  run_wayvibes "$NEW_PACK" "$CUR_VOL"
  ;;
*"Crystal Purple"*)
  # パスがディレクトリ止まりだったので修正が必要かもしれません
  NEW_PACK="$HOME/.local/share/soundpacks/crystal-purple"
  echo "$NEW_PACK" >"$PACK_FILE"
  run_wayvibes "$NEW_PACK" "$CUR_VOL"
  ;;
esac

# Waybar のアイコン表示を更新
pkill -RTMIN+8 waybar
