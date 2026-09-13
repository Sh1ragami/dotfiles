#!/usr/bin/env bash
set -euo pipefail

# 二重起動防止：すでに wofi が開いていれば閉じて終了
if pgrep -x "wofi" >/dev/null; then
    pkill -x "wofi"
    exit 0
fi

python3 - << 'PYEOF'
import subprocess
import sys
import os

def run_cmd(cmd, **kwargs):
    return subprocess.run(cmd, capture_output=True, text=True, **kwargs)

def run_nmcli(args, **kwargs):
    env = os.environ.copy()
    env["LC_ALL"] = "C"
    return subprocess.run(["nmcli"] + args, capture_output=True, text=True, env=env, encoding="utf-8", errors="replace", **kwargs)

def notify(summary, body, icon="network-wireless", urgency="normal"):
    subprocess.run(["notify-send", "-u", urgency, "-i", icon, summary, body])

# 1. Wi-Fi の有効・無効状態を確認 (LC_ALL=C で判定)
res_wifi_status = run_nmcli(["-fields", "WIFI", "g"])
wifi_enabled = "enabled" in res_wifi_status.stdout.lower()

if not wifi_enabled:
    menu_items = ["󰤨  Wi-Fi をオンにする"]
    res_choice = run_cmd([
        "wofi", "--dmenu",
        "--prompt", "Wi-Fi (現在オフ)",
        "--width", "350",
        "--height", "150",
        "--cache-file", "/dev/null",
        "--hide-scroll",
        "--define", "key_exit=Escape"
    ], input="\n".join(menu_items))
    choice = res_choice.stdout.strip()
    
    if "オンにする" in choice:
        run_nmcli(["r", "wifi", "on"])
        notify("Wi-Fi", "Wi-Fi をオンにしました")
    sys.exit(0)

# 2. 周辺 Wi-Fi のスキャンと取得
res_scan = run_nmcli(["-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list"])
lines = res_scan.stdout.strip().split("\n")

networks = {}
for line in lines:
    if not line:
        continue
    parts = line.split(":")
    if len(parts) >= 4:
        in_use = parts[0].strip() == "*"
        ssid = ":".join(parts[1:-2]).strip()
        signal_str = parts[-2].strip()
        signal = int(signal_str) if signal_str.isdigit() else 0
        security = parts[-1].strip()
        if not ssid or ssid == "--":
            continue
        if ssid not in networks or signal > networks[ssid]["signal"]:
            networks[ssid] = {"in_use": in_use, "signal": signal, "security": security}

# 保存済みの接続プロファイル一覧を取得
res_saved = run_nmcli(["-t", "-f", "NAME", "con", "show"])
saved_connections = set(res_saved.stdout.strip().split("\n"))

# メニューの作成
display_to_ssid = {}
menu_lines = []

# 固定アクション
menu_lines.append("󰑐  再スキャン (Rescan)")
menu_lines.append("󰤮  Wi-Fi をオフにする")
menu_lines.append("──────────────────────────────")

# ネットワーク一覧（接続中を最上段、次いで電波強度順）
sorted_ssids = sorted(networks.items(), key=lambda x: (not x[1]["in_use"], -x[1]["signal"]))

for ssid, info in sorted_ssids:
    signal = info["signal"]
    icon = "󰤨" if signal > 75 else ("󰤥" if signal > 50 else ("󰤢" if signal > 25 else "󰤟"))
    sec = "󰌾" if info["security"] and info["security"] != "--" else "  "
    prefix = "󰄴 " if info["in_use"] else "   "
    
    display_text = f"{prefix}{icon}  {ssid:<24} {signal:>3}%  {sec}"
    menu_lines.append(display_text)
    display_to_ssid[display_text] = (ssid, info)

# 3. Wofi でメニューを表示
res_wofi = run_cmd([
    "wofi", "--dmenu",
    "--prompt", "Select Wi-Fi Network",
    "--width", "420",
    "--height", "450",
    "--cache-file", "/dev/null",
    "--hide-scroll",
    "--define", "key_exit=Escape"
], input="\n".join(menu_lines))

selected = res_wofi.stdout.strip()
if not selected or selected.startswith("───"):
    sys.exit(0)

if "再スキャン" in selected:
    notify("Wi-Fi", "周辺のネットワークを再スキャン中...")
    run_nmcli(["dev", "wifi", "rescan"])
    # スクリプト再実行
    script_path = os.path.expanduser("~/.config/waybar/scripts/wifi-menu.sh")
    os.execv(script_path, [script_path])
    sys.exit(0)

if "オフにする" in selected:
    run_nmcli(["r", "wifi", "off"])
    notify("Wi-Fi", "Wi-Fi をオフにしました", icon="network-wireless-offline")
    sys.exit(0)

if selected not in display_to_ssid:
    sys.exit(0)

target_ssid, target_info = display_to_ssid[selected]

if target_info["in_use"]:
    notify("Wi-Fi", f"すでに「{target_ssid}」に接続されています")
    sys.exit(0)

# 4. 接続処理
notify("Wi-Fi", f"「{target_ssid}」に接続を試みています...")

if target_ssid in saved_connections:
    # 保存済みプロファイルで接続
    res_conn = run_nmcli(["con", "up", target_ssid])
    if res_conn.returncode == 0:
        notify("Wi-Fi", f"「{target_ssid}」に接続しました！", icon="network-wireless")
    else:
        notify("Wi-Fi", f"「{target_ssid}」への接続に失敗しました", icon="network-wireless-offline", urgency="critical")
else:
    # 新規接続
    is_secured = target_info["security"] and target_info["security"] != "--"
    if is_secured:
        # パスワード入力プロンプト
        res_pass = run_cmd([
            "wofi", "--dmenu", "--password",
            "--prompt", f"Password for {target_ssid}:",
            "--width", "360",
            "--cache-file", "/dev/null",
            "--define", "key_exit=Escape"
        ])
        pwd = res_pass.stdout.strip()
        if not pwd:
            sys.exit(0)
        res_conn = run_nmcli(["dev", "wifi", "connect", target_ssid, "password", pwd])
    else:
        # オープンネットワーク
        res_conn = run_nmcli(["dev", "wifi", "connect", target_ssid])

    if res_conn.returncode == 0:
        notify("Wi-Fi", f"「{target_ssid}」に接続しました！", icon="network-wireless")
    else:
        notify("Wi-Fi", f"「{target_ssid}」への接続に失敗しました。\nパスワード等をご確認ください。", icon="network-wireless-offline", urgency="critical")

PYEOF
