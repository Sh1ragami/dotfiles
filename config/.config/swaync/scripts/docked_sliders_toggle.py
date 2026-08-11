#!/usr/bin/env python3
import subprocess

proc = subprocess.run(["pgrep", "-f", "docked_sliders.py"], capture_output=True)
if proc.returncode == 0:
    subprocess.run(["pkill", "-f", "docked_sliders.py"])
else:
    subprocess.Popen(["python3", "/home/sh1ragami/.config/swaync/scripts/docked_sliders.py"])
