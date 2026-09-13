#!/bin/bash

# AGS が起動していない場合は自動起動
if ! pgrep -f "gjs.*ags" >/dev/null && ! pgrep -x "ags" >/dev/null; then
    hyprctl dispatch exec "ags run"
    sleep 0.6
fi

# クリックされた画面（カーソル位置 or フォーカス）のモニター名を取得
TARGET_MON=$(python3 -c '
import json, subprocess
try:
    mons = json.loads(subprocess.check_output(["hyprctl", "monitors", "-j"]))
    pos = [int(x) for x in subprocess.check_output(["hyprctl", "cursorpos"]).decode().strip().split(",")]
    cx, cy = pos[0], pos[1]
    match = [m["name"] for m in mons if m["x"] <= cx <= m["x"] + m["width"] and m["y"] <= cy <= m["y"] + m["height"]]
    if match:
        print(match[0])
    else:
        focused = [m["name"] for m in mons if m.get("focused")]
        print(focused[0] if focused else "")
except Exception:
    pass
' 2>/dev/null)

if [ -n "$TARGET_MON" ]; then
    ags request "toggle $TARGET_MON" 2>/dev/null || ags request "toggle" 2>/dev/null
else
    ags request "toggle" 2>/dev/null
fi
