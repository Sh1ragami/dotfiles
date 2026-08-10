#!/usr/bin/env bash

python3 -c '
import datetime, calendar, json

now = datetime.datetime.now()
year, month, day = now.year, now.month, now.day
month_name = now.strftime("%B %Y")
cal = calendar.monthcalendar(year, month)

header = f"<span font=\"JetBrainsMono Nerd Font 13\" weight=\"bold\" foreground=\"#d8a657\">🗓️  {month_name}</span>\n"
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

print(json.dumps({"text": "\n".join(lines)}))
'
