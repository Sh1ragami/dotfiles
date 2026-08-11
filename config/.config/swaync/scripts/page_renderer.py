#!/usr/bin/env python3
import os
import json
import subprocess

PAGE_FILE = "/tmp/swaync_page.txt"

def get_current_page():
    if os.path.exists(PAGE_FILE):
        try:
            val = open(PAGE_FILE).read().strip()
            if val in ["control", "notifications", "performance"]:
                return val
        except Exception:
            pass
    return "control"

page = get_current_page()

def make_bar(percent, length=16):
    filled = int(round(length * percent / 100))
    return "█" * filled + "░" * (length - filled)

def render_control():
    try:
        vol = subprocess.check_output("wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print $2*100}'", shell=True).decode().strip()
        vol_str = f"{float(vol):.0f}%" if vol else "N/A"
    except Exception:
        vol_str = "N/A"

    try:
        bright = subprocess.check_output("brightnessctl -m 2>/dev/null | cut -d, -f4", shell=True).decode().strip()
    except Exception:
        bright = "N/A"

    try:
        wifi = subprocess.check_output("nmcli radio wifi 2>/dev/null", shell=True).decode().strip()
        wifi_str = "ON 󰤨" if wifi == "enabled" else "OFF 󰤭"
    except Exception:
        wifi_str = "N/A"

    try:
        dnd = subprocess.check_output("swaync-client -D 2>/dev/null", shell=True).decode().strip()
        dnd_str = "ON 󰍶 (Muted)" if dnd == "true" else "OFF (Normal)"
    except Exception:
        dnd_str = "OFF"

    text = f"<span font=\"13\" weight=\"bold\" foreground=\"#ea6962\">🎛️  Control Center Overview</span>\n" \
           f"<span font=\"10\" foreground=\"#787c99\">────────────────────────────────────────────────────────────</span>\n\n" \
           f"<span font=\"11\" weight=\"bold\" foreground=\"#d8a657\">󰌽 User Profile  </span>  <span font=\"11\" foreground=\"#dfd0b2\">sh1ragami (Host: Arch Linux)</span>\n" \
           f"<span font=\"11\" weight=\"bold\" foreground=\"#7aa2f7\">󰕾 Audio Volume  </span>  <span font=\"11\" foreground=\"#7aa2f7\">{vol_str}</span>     |  <span font=\"11\" weight=\"bold\" foreground=\"#d8a657\">󰃠 Brightness </span> <span font=\"11\" foreground=\"#d8a657\">{bright}</span>\n" \
           f"<span font=\"11\" weight=\"bold\" foreground=\"#a9b665\">󰤨 Wi-Fi Network </span>  <span font=\"11\" foreground=\"#a9b665\">{wifi_str}</span> |  <span font=\"11\" weight=\"bold\" foreground=\"#ea6962\">󰍶 Do Not Disturb </span> <span font=\"11\" foreground=\"#ea6962\">{dnd_str}</span>\n\n" \
           f"<span font=\"10\" foreground=\"#928374\">[ Use quick toggle buttons below for direct adjustments ]</span>"
    return text

def render_performance():
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

        text = f"<span font=\"13\" weight=\"bold\" foreground=\"#d8a657\">📊  System Performance Widget</span>\n" \
               f"<span font=\"10\" foreground=\"#787c99\">────────────────────────────────────────────────────────────</span>\n\n" \
               f"<span font=\"11\" weight=\"bold\" foreground=\"#ea6962\">󰍛 CPU Usage   </span> <span font=\"11\" foreground=\"#ea6962\">[{cpu_bar}]  {cpu_val:.1f}%</span>\n\n" \
               f"<span font=\"11\" weight=\"bold\" foreground=\"#7aa2f7\">󰘚 RAM Memory  </span> <span font=\"11\" foreground=\"#7aa2f7\">[{mem_bar}]  {mem_pct:.1f}% ({mem_used_gib:.1f} GiB / {mem_total_gib:.1f} GiB)</span>\n\n" \
               f"<span font=\"11\" weight=\"bold\" foreground=\"#a9b665\">󰋊 Disk Storage </span> <span font=\"11\" foreground=\"#a9b665\">[{disk_bar}]  {disk_pct:.0f}% ({disk_used} / {disk_total})</span>"
        return text
    except Exception as e:
        return "<span font=\"12\" weight=\"bold\">📊  Performance Info</span>"

def render_notifications():
    text = f"<span font=\"13\" weight=\"bold\" foreground=\"#7aa2f7\">🔔  Notifications Stream Log</span>\n" \
           f"<span font=\"10\" foreground=\"#787c99\">────────────────────────────────────────────────────────────</span>"
    return text

if page == "performance":
    content = render_performance()
elif page == "notifications":
    content = render_notifications()
else:
    content = render_control()

print(json.dumps({"text": content}))
