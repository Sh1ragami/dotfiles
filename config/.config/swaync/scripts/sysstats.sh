#!/usr/bin/env bash

python3 -c '
import json, subprocess

def make_bar(percent, length=12):
    filled = int(round(length * percent / 100))
    return "█" * filled + "░" * (length - filled)

try:
    cpu_val = float(subprocess.check_output("top -bn1 | grep \"Cpu(s)\" | sed \"s/.*, *\\([0-9.]*\\)%* id.*/\\1/\" | awk \"{print 100 - \$1}\"", shell=True).decode().strip())
    
    mem_out = subprocess.check_output("free -m | awk \"NR==2{print \$3, \$2, \$3*100/\$2}\"", shell=True).decode().split()
    mem_used_gib = float(mem_out[0]) / 1024
    mem_total_gib = float(mem_out[1]) / 1024
    mem_pct = float(mem_out[2])

    disk_out = subprocess.check_output("df -h / | awk \"NR==2{print \$3, \$2, \$5}\"", shell=True).decode().split()
    disk_used = disk_out[0]
    disk_total = disk_out[1]
    disk_pct = float(disk_out[2].replace("%", ""))

    cpu_bar = make_bar(cpu_val)
    mem_bar = make_bar(mem_pct)
    disk_bar = make_bar(disk_pct)

    text = f"<span font=\"12\" weight=\"bold\" foreground=\"#d8a657\">📊 パフォーマンス・モニター</span>\n" \
           f"<span font=\"10\" foreground=\"#787c99\">────────────────────────────────────────────</span>\n" \
           f"<span font=\"11\" weight=\"bold\" foreground=\"#ea6962\">󰍛 CPU   </span> <span font=\"10\" foreground=\"#ea6962\">[{cpu_bar}]  {cpu_val:.1f}%</span>\n" \
           f"<span font=\"11\" weight=\"bold\" foreground=\"#7aa2f7\">󰘚 RAM   </span> <span font=\"10\" foreground=\"#7aa2f7\">[{mem_bar}]  {mem_pct:.1f}% ({mem_used_gib:.1f}G / {mem_total_gib:.1f}G)</span>\n" \
           f"<span font=\"11\" weight=\"bold\" foreground=\"#a9b665\">󰋊 DISK  </span> <span font=\"10\" foreground=\"#a9b665\">[{disk_bar}]  {disk_pct:.0f}% ({disk_used} / {disk_total})</span>"

    print(json.dumps({"text": text}))
except Exception as e:
    print(json.dumps({"text": "📊 パフォーマンス情報"}))
'
