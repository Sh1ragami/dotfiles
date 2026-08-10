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
            return open(PAGE_FILE).read().strip()
        except Exception:
            pass
    return "dashboard"

page = get_current_page()

def render_dashboard():
    now = datetime.datetime.now()
    year, month, day = now.year, now.month, now.day
    month_name = now.strftime("%B %Y")
    cal = calendar.monthcalendar(year, month)

    header = f"<span font=\"JetBrainsMono Nerd Font 13\" weight=\"bold\" foreground=\"#d8a657\">󰃭  {month_name}</span>\n"
    weekdays = "<span font=\"JetBrainsMono Nerd Font 11\" weight=\"bold\" foreground=\"#ea6962\"> Mo  Tu  We  Th  Fr  Sa  Su</span>"

    lines = [header, weekdays]
    for week in cal:
        line_strs = []
        for d in week:
            if d == 0:
                line_strs.append("    ")
            elif d == day:
                line_strs.append(f"<span background=\"#ea6962\" foreground=\"#1e1e1e\" weight=\"bold\"> {d:2d} </span>")
            else:
                line_strs.append(f"<span font=\"JetBrainsMono Nerd Font 11\" foreground=\"#dfd0b2\"> {d:2d} </span>")
        lines.append("".join(line_strs))

    cal_text = "\n".join(lines)

    # Uptime
    try:
        upt = subprocess.check_output("uptime -p | sed 's/up //'", shell=True).decode().strip()
    except Exception:
        upt = "online"

    output_text = f"{cal_text}\n\n" \
                  f"<span font=\"10\" foreground=\"#928374\">────────────────────────────────────────────────────────────</span>\n" \
                  f"<span font=\"11\" weight=\"bold\" foreground=\"#7aa2f7\">󰌽 User: sh1ragami</span>   |   <span font=\"10\" foreground=\"#a9b665\">󰅐 Uptime: {upt}</span>"
    return output_text

def make_bar(percent, length=14):
    filled = int(round(length * percent / 100))
    return "█" * filled + "░" * (length - filled)

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

        text = f"<span font=\"13\" weight=\"bold\" foreground=\"#d8a657\">󰓅  System Performance Monitor</span>\n" \
               f"<span font=\"10\" foreground=\"#928374\">────────────────────────────────────────────────────────────</span>\n" \
               f"<span font=\"11\" weight=\"bold\" foreground=\"#ea6962\">󰍛 CPU Usage   </span> <span font=\"11\" foreground=\"#ea6962\">[{cpu_bar}]  {cpu_val:.1f}%</span>\n\n" \
               f"<span font=\"11\" weight=\"bold\" foreground=\"#7aa2f7\">󰘚 RAM Memory  </span> <span font=\"11\" foreground=\"#7aa2f7\">[{mem_bar}]  {mem_pct:.1f}% ({mem_used_gib:.1f}G / {mem_total_gib:.1f}G)</span>\n\n" \
               f"<span font=\"11\" weight=\"bold\" foreground=\"#a9b665\">󰋊 Storage Disk</span> <span font=\"11\" foreground=\"#a9b665\">[{disk_bar}]  {disk_pct:.0f}% ({disk_used} / {disk_total})</span>"
        return text
    except Exception as e:
        return "<span font=\"12\" weight=\"bold\">󰓅  Performance Stats Unavailable</span>"

def render_settings():
    text = f"<span font=\"13\" weight=\"bold\" foreground=\"#d8a657\">󰒓  Quick Toggles & Connectivity</span>\n" \
           f"<span font=\"10\" foreground=\"#928374\">────────────────────────────────────────────────────────────</span>\n" \
           f"<span font=\"11\" foreground=\"#7aa2f7\">󰤨  Wi-Fi Connection</span>       <span font=\"11\" foreground=\"#a9b665\">󰂯  Bluetooth Status</span>\n" \
           f"<span font=\"11\" foreground=\"#ea6962\">󰍶  Do Not Disturb (Mute)</span>  <span font=\"11\" foreground=\"#d8a657\">󰌐  Mechanical Key Sounds</span>"
    return text

def render_themes():
    text = f"<span font=\"13\" weight=\"bold\" foreground=\"#d8a657\">󰔎  Desktop Theme Preset Selection</span>\n" \
           f"<span font=\"10\" foreground=\"#928374\">────────────────────────────────────────────────────────────</span>\n" \
           f"<span font=\"11\" foreground=\"#ea6962\">󰖔 Sunset Theme</span>       <span font=\"11\" foreground=\"#bb9af7\">󰄛 Catppuccin Theme</span>\n" \
           f"<span font=\"11\" foreground=\"#7aa2f7\">󰄛 Tokyo Night Theme</span>  <span font=\"11\" foreground=\"#a9b665\">󰂺 Study Mode Theme</span>"
    return text

if page == "performance":
    content = render_performance()
elif page == "settings":
    content = render_settings()
elif page == "themes":
    content = render_themes()
else:
    content = render_dashboard()

print(json.dumps({"text": content}))
