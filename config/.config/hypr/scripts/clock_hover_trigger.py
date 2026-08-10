#!/usr/bin/env python3
import time
import subprocess
import json

def get_cursor():
    try:
        out = subprocess.check_output("hyprctl cursorpos", shell=True).decode().strip()
        parts = [int(p.strip()) for p in out.split(",")]
        return parts[0], parts[1]
    except Exception:
        return -1, -1

def get_monitor_width():
    try:
        out = subprocess.check_output("hyprctl monitors -j", shell=True).decode()
        mons = json.loads(out)
        return mons[0]["width"]
    except Exception:
        return 1440

width = get_monitor_width()
min_x = (width // 2) - 160
max_x = (width // 2) + 160

was_inside = False

while True:
    cx, cy = get_cursor()
    if 0 <= cy <= 44 and min_x <= cx <= max_x:
        if not was_inside:
            subprocess.run("swaync-client -s", shell=True)
            was_inside = True
    else:
        if was_inside and cy > 44:
            was_inside = False
    time.sleep(0.12)
