#!/usr/bin/env python3
import sys
import os
import hashlib
import subprocess
import time
import gi

gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk

MOUNT_DIR = os.path.expanduser("~/スマホ写真")
PIN_FILE = os.path.expanduser("~/.config/rclone/.photos_vault_pin")
os.makedirs(os.path.expanduser("~/.config/rclone"), exist_ok=True)

def is_mounted():
    try:
        res = subprocess.run(["mountpoint", "-q", MOUNT_DIR], capture_output=True)
        return res.returncode == 0
    except Exception:
        return False

def verify_pin(pin):
    try:
        if not os.path.exists(PIN_FILE):
            return False
        with open(PIN_FILE, 'r') as f:
            stored = f.read().strip()
        salt, h = stored.split(':', 1)
        return hashlib.sha256((salt + pin).encode('utf-8')).hexdigest() == h
    except Exception:
        return False

def save_pin(pin):
    salt = os.urandom(16).hex()
    h = hashlib.sha256((salt + pin).encode('utf-8')).hexdigest()
    with open(PIN_FILE, 'w') as f:
        f.write(f"{salt}:{h}")
    os.chmod(PIN_FILE, 0o600)

def notify(summary, body, icon="security-high", urgency="normal"):
    try:
        subprocess.run(["notify-send", "-u", urgency, "-i", icon, summary, body])
    except Exception:
        pass

def mount_photos():
    if not os.path.exists(MOUNT_DIR):
        os.makedirs(MOUNT_DIR, exist_ok=True)
    try:
        os.chmod(MOUNT_DIR, 0o755)
    except Exception:
        pass
        
    subprocess.Popen([
        "rclone", "mount", "gdrive:スマホ写真", MOUNT_DIR,
        "--vfs-cache-mode", "full",
        "--vfs-cache-max-size", "10G",
        "--vfs-cache-max-age", "24h",
        "--dir-cache-time", "72h",
        "--daemon"
    ])
    for _ in range(15):
        if is_mounted():
            break
        time.sleep(0.3)
    subprocess.Popen(["thunar", MOUNT_DIR])
    notify("スマホ写真", "🔓 ロック解除しました\n見終わったらもう一度アプリや右クリックから施錠できます", "security-low")

def unmount_photos():
    # 1. Thunar がフォルダを掴んでいるとビジーになるため、ホームに移動させる
    try:
        subprocess.Popen(["thunar", os.path.expanduser("~")])
    except Exception:
        pass
    time.sleep(0.3)
    
    # 2. 強制遅延アンマウント (-u -z)
    subprocess.run(["fusermount3", "-u", "-z", MOUNT_DIR], capture_output=True)
    subprocess.run(["pkill", "-f", "rclone mount gdrive:スマホ写真"], capture_output=True)
    time.sleep(0.3)
    
    # 3. 未マウント時は他人が中身やフォルダを開けないよう権限を閉鎖
    if not is_mounted():
        try:
            os.chmod(MOUNT_DIR, 0o000)
        except Exception:
            pass
        notify("スマホ写真", "🔒 ロックしました（施錠完了）", "security-high")
    else:
        notify("スマホ写真", "⚠️ ロックに失敗しました。再度お試しください。", "dialog-error", "critical")

def prompt_pin_dialog(prompt_text="PINを入力してください:"):
    dialog = Gtk.MessageDialog(
        flags=Gtk.DialogFlags.MODAL,
        type=Gtk.MessageType.QUESTION,
        buttons=Gtk.ButtonsType.OK_CANCEL,
        message_format="🔒 スマホ写真のロック解除"
    )
    dialog.format_secondary_text(prompt_text)
    dialog.set_position(Gtk.WindowPosition.CENTER)
    dialog.set_default_size(360, 140)

    entry = Gtk.Entry()
    entry.set_visibility(False)
    entry.set_activates_default(True)
    entry.set_margin_top(10)
    entry.set_margin_bottom(10)
    entry.set_margin_start(20)
    entry.set_margin_end(20)

    content_box = dialog.get_message_area()
    content_box.pack_end(entry, False, False, 0)
    dialog.set_default_response(Gtk.ResponseType.OK)
    dialog.show_all()

    response = dialog.run()
    text = entry.get_text()
    dialog.destroy()

    if response == Gtk.ResponseType.OK:
        return text
    return None

def prompt_unlocked_dialog():
    dialog = Gtk.MessageDialog(
        flags=Gtk.DialogFlags.MODAL,
        type=Gtk.MessageType.INFO,
        buttons=Gtk.ButtonsType.NONE,
        message_format="🔒 スマホ写真（現在ロック解除中）"
    )
    dialog.format_secondary_text("スマホ写真は現在閲覧可能です。どうしますか？")
    dialog.set_position(Gtk.WindowPosition.CENTER)
    dialog.add_button("📂 フォルダを開く", Gtk.ResponseType.APPLY)
    dialog.add_button("🔒 今すぐロックする (施錠)", Gtk.ResponseType.CLOSE)
    dialog.add_button("キャンセル", Gtk.ResponseType.CANCEL)
    
    dialog.show_all()
    response = dialog.run()
    dialog.destroy()
    return response

def main():
    if is_mounted():
        resp = prompt_unlocked_dialog()
        if resp == Gtk.ResponseType.CLOSE:
            unmount_photos()
        elif resp == Gtk.ResponseType.APPLY:
            subprocess.Popen(["thunar", MOUNT_DIR])
        return

    # Check if PIN is configured
    if not os.path.exists(PIN_FILE):
        pin = prompt_pin_dialog("初めての使用です。新しいPIN/パスワードを設定してください:")
        if not pin:
            return
        confirm = prompt_pin_dialog("確認のためもう一度PINを入力してください:")
        if pin != confirm:
            notify("スマホ写真", "❌ PINが一致しませんでした。設定を中止します。", "dialog-error", "critical")
            return
        save_pin(pin)
        notify("スマホ写真", "PINを設定しました。ロック解除を開始します。", "security-high")
        mount_photos()
        return

    # Existing PIN prompt
    pin = prompt_pin_dialog("PIN / パスワードを入力してください:")
    if pin is None:
        return
    if verify_pin(pin):
        mount_photos()
    else:
        notify("スマホ写真", "❌ PINが間違っています", "dialog-error", "critical")

if __name__ == "__main__":
    main()
