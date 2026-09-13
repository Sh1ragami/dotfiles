#!/usr/bin/env bash

# 二重起動の防止 (すでに slurp や grim が実行中なら即終了)
if pgrep -x slurp >/dev/null || pgrep -x grim >/dev/null; then
    exit 0
fi

# 保存先ディレクトリの作成
SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"

FILENAME="Screenshot_$(date +'%Y%m%d_%H%M%S').png"
FILEPATH="$SAVE_DIR/$FILENAME"

MODE="${1:-region}"

case "$MODE" in
    region)
        # 範囲選択 (slurp で座標取得 -> grim で撮影)
        GEOM=$(slurp -b "00000044" -c "89b4fa" -w 2)
        if [ -z "$GEOM" ]; then
            exit 0
        fi
        # slurp の選択枠・オーバーレイが画面から完全に消えるのを待ってから撮影
        sleep 0.15
        grim -g "$GEOM" "$FILEPATH"
        ;;
    window)
        # アクティブウィンドウの範囲取得
        GEOM=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' 2>/dev/null)
        if [ -z "$GEOM" ] || [ "$GEOM" = "null,null nullxnull" ]; then
            exit 0
        fi
        grim -g "$GEOM" "$FILEPATH"
        ;;
    full)
        # 全画面撮影
        grim "$FILEPATH"
        ;;
    gui)
        # Flameshot (詳細編集用)
        env XDG_CURRENT_DESKTOP=sway flameshot gui
        exit 0
        ;;
esac

# クリップボードへのコピーとリッチ画像プレビュー通知
if [ -f "$FILEPATH" ]; then
    wl-copy < "$FILEPATH"
    (
        ACTION=$(notify-send -a "Screenshot" \
            -A default="エクスプローラーで開く" \
            " " \
            "<img src=\"$FILEPATH\" />" \
            -t 4000 2>/dev/null)

        if [ -n "$ACTION" ]; then
            thunar "$SAVE_DIR" &
            # ウィンドウが表示可能になるまで少し待機して special:thunar を表示・フォーカス
            for i in {1..10}; do
                if hyprctl clients -j | jq -e '.[] | select(.class == "thunar")' >/dev/null 2>&1; then
                    break
                fi
                sleep 0.1
            done
            IS_SPECIAL_OPEN=$(hyprctl monitors -j | jq -r ".[] | select(.specialWorkspace.name == \"special:thunar\") | .specialWorkspace.name")
            if [ -z "$IS_SPECIAL_OPEN" ]; then
                hyprctl dispatch togglespecialworkspace thunar
            fi
            hyprctl dispatch focuswindow "class:^thunar$" >/dev/null 2>&1
        fi
    ) &
fi
