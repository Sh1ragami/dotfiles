#!/usr/bin/env python3
import os
import json
import datetime
import calendar
import subprocess

PAGE_FILE = "/tmp/swaync_page.txt"

def get_current_page():
    if os.path.exists(PAGE_FILE):
        try:
            val = open(PAGE_FILE).read().strip()
            if val in ["dashboard", "media", "performance", "themes"]:
                return val
        except Exception:
            pass
    return "dashboard"

def make_bar(percent, length=10):
    filled = int(round(length * percent / 100))
    return "█" * filled + "░" * (length - filled)

page = get_current_page()

if page == "media":
    # 󰎈 Media Player Page
    try:
        artist = subprocess.check_output("playerctl metadata artist 2>/dev/null || echo 'No media playing'", shell=True).decode().strip()
        title = subprocess.check_output("playerctl metadata title 2>/dev/null || echo 'Spotify / Media Player'", shell=True).decode().strip()
        status = subprocess.check_output("playerctl status 2>/dev/null || echo 'Stopped'", shell=True).decode().strip()
    except Exception:
        artist = "No media playing"
        title = "Spotify / Media Player"
        status = "Stopped"

    status_icon = "󰐊" if status == "Playing" else "󰏤"

    content = f"<span font=\"13\" weight=\"bold\" foreground=\"#d8a657\">󰎈  Media Playback View</span>\n" \
              f"<span font=\"9\" foreground=\"#787c99\">────────────────────────────────────────────</span>\n\n" \
              f"<span font=\"12\" weight=\"bold\" foreground=\"#ea6962\">{status_icon} {title}</span>\n" \
              f"<span font=\"10\" foreground=\"#a89984\">󰠃 Artist: {artist}</span>  |  <span font=\"10\" foreground=\"#7aa2f7\">Status: {status}</span>\n\n" \
              f"<span font=\"10\" foreground=\"#928374\">[ Select media actions from drop-down menu above ]</span>"

elif page == "performance":
    # 󰓅 Performance Page
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

        content = f"<span font=\"13\" weight=\"bold\" foreground=\"#d8a657\">󰓅  Performance Stats View</span>\n" \
                  f"<span font=\"9\" foreground=\"#787c99\">────────────────────────────────────────────</span>\n\n" \
                  f"<span font=\"10\" weight=\"bold\" foreground=\"#ea6962\">󰍛 CPU  </span> <span font=\"10\" foreground=\"#ea6962\">[{cpu_bar}] {cpu_val:.1f}%</span>\n" \
                  f"<span font=\"10\" weight=\"bold\" foreground=\"#7aa2f7\">󰘚 RAM  </span> <span font=\"10\" foreground=\"#7aa2f7\">[{mem_bar}] {mem_pct:.1f}% ({mem_used_gib:.1f}G/{mem_total_gib:.1f}G)</span>\n" \
                  f"<span font=\"10\" weight=\"bold\" foreground=\"#a9b665\">󰋊 DISK </span> <span font=\"10\" foreground=\"#a9b665\">[{disk_bar}] {disk_pct:.0f}% ({disk_used}/{disk_total})</span>"
    except Exception:
        content = "<span font=\"11\" weight=\"bold\">󰓅  Performance View</span>"

elif page == "themes":
    # 󰔎 Themes Page
    content = f"<span font=\"13\" weight=\"bold\" foreground=\"#d8a657\">󰔎  Themes Selection View</span>\n" \
              f"<span font=\"9\" foreground=\"#787c99\">────────────────────────────────────────────</span>\n\n" \
              f"<span font=\"10\" weight=\"bold\" foreground=\"#ea6962\">󰖔 Sunset</span>   <span font=\"10\" weight=\"bold\" foreground=\"#bb9af7\">󰄛 Catppuccin</span>   <span font=\"10\" weight=\"bold\" foreground=\"#7aa2f7\">󰄛 Tokyo Night</span>   <span font=\"10\" weight=\"bold\" foreground=\"#a9b665\">󰂺 Study</span>"

else:
    # 󰋜 Dashboard Page (Default Hub: Calendar + Volume / Brightness Status)
    now = datetime.datetime.now()
    year, month, day = now.year, now.month, now.day
    month_name = now.strftime("%B %Y")
    cal = calendar.monthcalendar(year, month)

    header = f"<span font=\"JetBrainsMono Nerd Font 12\" weight=\"bold\" foreground=\"#d8a657\">󰃭  {month_name}</span>\n"
    weekdays = "<span font=\"JetBrainsMono Nerd Font 10\" weight=\"bold\" foreground=\"#ea6962\"> Mo  Tu  We  Th  Fr  Sa  Su</span>"

    lines = [header, weekdays]
    for week in cal:
        line_strs = []
        for d in week:
            if d == 0:
                line_strs.append("    ")
            elif d == day:
                line_strs.append(f"<span background=\"#ea6962\" foreground=\"#1e1e1e\" weight=\"bold\"> {d:2d} </span>")
            else:
                line_strs.append(f"<span font=\"JetBrainsMono Nerd Font 10\" foreground=\"#dfd0b2\"> {d:2d} </span>")
        lines.append("".join(line_strs))

    cal_text = "\n".join(lines)

    try:
        vol = subprocess.check_output("wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk \"{print \$2*100}\"", shell=True).decode().strip()
        vol_val = f"{float(vol):.0f}%" if vol else "N/A"
    except Exception:
        vol_val = "N/A"

    try:
        bright = subprocess.check_output("brightnessctl -m 2>/dev/null | cut -d, -f4", shell=True).decode().strip()
    except Exception:
        bright = "N/A"

    content = f"{cal_text}\n\n" \
              f"<span font=\"9\" foreground=\"#787c99\">────────────────────────────────────────────</span>\n" \
              f"<span font=\"10\" foreground=\"#ea6962\">󰕾 Volume: {vol_val}</span>   |   <span font=\"10\" foreground=\"#d8a657\">󰃠 Brightness: {bright}</span>"

print(json.dumps({"text": content}))
