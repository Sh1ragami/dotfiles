#!/usr/bin/env python3
# docked_sliders.py - SwayNCサイドバーの開閉と100%シンクロして表示される透過度・ブラー調整スライダーパネル

import sys
import os
import json
import subprocess
import threading
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GLib

class DockedSliders(Gtk.Window):
    def __init__(self):
        super().__init__(title="Desktop Adjust Panel")
        self.set_border_width(16)
        self.set_default_size(240, 160)
        self.set_keep_above(True)
        
        # ウィンドウ装飾なし
        self.set_decorated(False)
        self.set_type_hint(Gdk.WindowTypeHint.UTILITY)
        self.set_skip_taskbar_hint(True)

        # 初期配置
        self.update_position()

        # レイアウトの構築
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)

        # 1. 透過度調整スライダー
        self.opacity_label = Gtk.Label(label="Terminal Opacity")
        self.opacity_label.set_halign(Gtk.Align.START)
        
        self.opacity_conf = os.path.expanduser("~/.config/kitty/opacity.conf")
        cur_opacity = self.load_opacity()
        
        self.opacity_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0.3, 1.0, 0.05)
        self.opacity_scale.set_value(cur_opacity)
        self.opacity_scale.set_digits(2)
        self.opacity_scale.connect("value-changed", self.on_opacity_changed)

        # 2. ブラー（すりガラス効果）調整スライダー
        self.blur_label = Gtk.Label(label="Window Blur Strength")
        self.blur_label.set_halign(Gtk.Align.START)
        
        cur_blur = self.load_blur()
        
        self.blur_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 16, 1)
        self.blur_scale.set_value(cur_blur)
        self.blur_scale.set_digits(0)
        self.blur_scale.connect("value-changed", self.on_blur_changed)

        vbox.pack_start(self.opacity_label, False, False, 0)
        vbox.pack_start(self.opacity_scale, False, False, 0)
        vbox.pack_start(self.blur_label, False, False, 0)
        vbox.pack_start(self.blur_scale, False, False, 0)
        self.add(vbox)

        # スタイルの適用
        self.apply_css()
        
        # 初期状態は非表示
        self.hide()

        # SwayNCの通知センター開閉イベントを監視するスレッドを開始
        self.monitor_thread = threading.Thread(target=self.monitor_swaync, daemon=True)
        self.monitor_thread.start()

    def update_position(self):
        # swaync の config から positionX を取得
        position_x = "right"
        swaync_conf = os.path.expanduser("~/.config/swaync/config.json")
        if os.path.exists(swaync_conf):
            try:
                with open(swaync_conf, "r") as f:
                    data = json.load(f)
                    position_x = data.get("positionX", "right")
            except:
                pass

        display = Gdk.Display.get_default()
        monitor = display.get_primary_monitor() if display else None
        
        win_x = 1200
        win_y = 80
        
        if monitor:
            try:
                geom = monitor.get_geometry()
                if position_x == "left":
                    # 左端にサイドバーがある場合
                    win_x = 405
                elif position_x == "center":
                    # 中央上部にパネルがある場合：中央パネルの右側に配置
                    win_x = int((geom.width + 820) / 2) + 16
                else:
                    win_x = geom.width - 240 - 415
                win_y = 45
            except Exception:
                pass
        else:
            screen = Gdk.Screen.get_default()
            if screen:
                try:
                    width = screen.get_width()
                    if position_x == "left":
                        win_x = 405
                    elif position_x == "center":
                        win_x = int((width + 820) / 2) + 16
                    else:
                        win_x = width - 240 - 415
                    win_y = 45
                except:
                    pass
        self.move(win_x, win_y)

    def load_opacity(self):
        if os.path.exists(self.opacity_conf):
            try:
                with open(self.opacity_conf, "r") as f:
                    for line in f:
                        if line.startswith("background_opacity"):
                            return float(line.split()[1])
            except:
                pass
        return 0.82

    def load_blur(self):
        # 現在のHyprland設定からブラーサイズを取得
        try:
            val = subprocess.check_output(["hyprctl", "getoption", "decoration:blur:size"]).decode()
            for line in val.split("\n"):
                if "int:" in line:
                    return int(line.split()[1])
        except:
            pass
        return 8

    def on_opacity_changed(self, scale):
        val = round(scale.get_value(), 2)
        # 設定ファイル書き込み
        with open(self.opacity_conf, "w") as f:
            f.write(f"background_opacity {val}\n")
        
        # kitty.conf を touch して再読み込みトリガー
        kitty_conf = os.path.expanduser("~/.config/kitty/kitty.conf")
        if os.path.exists(kitty_conf):
            try:
                os.utime(kitty_conf, None)
            except:
                pass
        
        # 起動中のすべてのKittyにシグナル送信
        subprocess.run(["pkill", "-USR1", "kitty"], stderr=subprocess.DEVNULL)

    def on_blur_changed(self, scale):
        val = int(scale.get_value())
        if val == 0:
            # 強度0のときはブラーを無効化
            subprocess.run(["hyprctl", "keyword", "decoration:blur:enabled", "false"])
            self.update_hypr_config(False, 0)
        else:
            # 1以上のときはブラーを有効にして強度を変更
            subprocess.run(["hyprctl", "keyword", "decoration:blur:enabled", "true"])
            subprocess.run(["hyprctl", "keyword", "decoration:blur:size", str(val)])
            passes = max(1, val // 2)
            subprocess.run(["hyprctl", "keyword", "decoration:blur:passes", str(passes)])
            self.update_hypr_config(True, val)

    def update_hypr_config(self, enabled, size):
        # hyprland.conf の設定も永続化のために書き換え
        conf_path = os.path.expanduser("~/.config/hypr/hyprland.conf")
        if not os.path.exists(conf_path):
            return
        try:
            with open(conf_path, "r") as f:
                content = f.read()
            
            # enabledトグル置換
            if enabled:
                # 最初の enabled = false を置換 (blurセクション内のものを狙う)
                content = content.replace("enabled = false", "enabled = true", 1)
            else:
                content = content.replace("enabled = true", "enabled = false", 1)
            
            # size置換
            # 古いsize定義行を特定して書き換える
            lines = content.split("\n")
            for i, line in enumerate(lines):
                if "size = " in line and "blur" in lines[i-2]:  # blurセクション内のsize行
                    lines[i] = f"        size = {size}"
                    break
            
            with open(conf_path, "w") as f:
                f.write("\n".join(lines))
        except:
            pass

    def monitor_swaync(self):
        # swaync-client -sw でイベント監視
        proc = subprocess.Popen(["swaync-client", "-sw"], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
        for line in proc.stdout:
            try:
                data = json.loads(line.strip())
                visible = data.get("visible", False)
                # メインスレッドに表示・非表示の反映を委譲
                GLib.idle_add(self.set_visible_state, visible)
            except Exception as e:
                pass

    def set_visible_state(self, visible):
        if visible:
            self.update_position()
            self.show_all()
            self.present()
        else:
            self.hide()

    def apply_css(self):
        screen = Gdk.Screen.get_default()
        css_provider = Gtk.CssProvider()
        css = """
        window {
            background-color: rgba(26, 20, 18, 0.96);
            border: 1px solid rgba(234, 105, 98, 0.35);
            border-radius: 14px;
        }
        label {
            color: #dfd0b2;
            font-family: 'JetBrainsMono Nerd Font', 'Ubuntu Nerd Font', sans-serif;
            font-weight: bold;
            font-size: 11px;
            margin-top: 4px;
        }
        scale trough {
            background-color: rgba(255, 255, 255, 0.1);
            border-radius: 6px;
            min-height: 8px;
        }
        scale highlight {
            background-color: #ea6962;
            border-radius: 6px;
        }
        scale slider {
            background-color: #d8a657;
            min-width: 14px;
            min-height: 14px;
            border-radius: 50%;
            border: none;
            box-shadow: none;
        }
        """
        css_provider.load_from_data(css.encode())
        Gtk.StyleContext.add_provider_for_screen(screen, css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

if __name__ == "__main__":
    app = DockedSliders()
    # GLibスレッドセーフ設定
    GLib.threads_init()
    Gtk.main()
