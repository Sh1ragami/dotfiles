#!/usr/bin/env python3
# docked_sliders.py - iPhone (iOS) スタイルのターミナル・Waybar・SwayNC連動 透明度・ブラー調整パネル (Resetボタン付き)

import sys
import os
import json
import re
import subprocess
import gi
gi.require_version('Gtk', '3.0')
gi.require_version('GtkLayerShell', '0.1')
from gi.repository import Gtk, Gdk, GLib, GtkLayerShell

class DockedSliders(Gtk.Window):
    def __init__(self):
        super().__init__(title="iOS Style Adjust Panel")
        
        # GtkLayerShell 初期化
        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_namespace(self, "docked-sliders")
        
        # 画面右上 / 中央右側に固定アンカー
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.RIGHT, True)
        
        # マージン設定 (画面上から65px, 右から65px)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, 65)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.RIGHT, 65)

        self.set_border_width(18)
        self.set_default_size(300, 200)

        # レイアウト
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)

        header = Gtk.Label(label="🎚️ Display Adjust")
        header.set_halign(Gtk.Align.START)
        header.get_style_context().add_class("header-title")

        # リセットボタン (デフォルト値: Opacity 0.75 / Blur 8 に復元)
        reset_btn = Gtk.Button(label="↺ Reset")
        reset_btn.set_halign(Gtk.Align.END)
        reset_btn.get_style_context().add_class("reset-btn")
        reset_btn.connect("clicked", self.on_reset_clicked)

        # 閉じるボタン
        close_btn = Gtk.Button(label="✕ Close")
        close_btn.set_halign(Gtk.Align.END)
        close_btn.connect("clicked", lambda w: Gtk.main_quit())

        top_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        top_box.pack_start(header, True, True, 0)
        top_box.pack_end(close_btn, False, False, 0)
        top_box.pack_end(reset_btn, False, False, 0)

        # 1. ターミナル・Waybar・SwayNC 透過度連動スライダー
        self.opacity_label = Gtk.Label(label="󰞌 Terminal & Bar & Menu Opacity")
        self.opacity_label.set_halign(Gtk.Align.START)
        
        self.opacity_conf = os.path.expanduser("~/.config/kitty/opacity.conf")
        cur_opacity = self.load_opacity()
        
        self.opacity_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0.1, 1.0, 0.05)
        self.opacity_scale.set_value(cur_opacity)
        self.opacity_scale.set_digits(2)
        self.opacity_scale.connect("value-changed", self.on_opacity_changed)

        # 2. ブラー調整スライダー
        self.blur_label = Gtk.Label(label="󱡁 Window & Menu Blur Strength")
        self.blur_label.set_halign(Gtk.Align.START)
        
        cur_blur = self.load_blur()
        
        self.blur_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 16, 1)
        self.blur_scale.set_value(cur_blur)
        self.blur_scale.set_digits(0)
        self.blur_scale.connect("value-changed", self.on_blur_changed)

        vbox.pack_start(top_box, False, False, 0)
        vbox.pack_start(self.opacity_label, False, False, 0)
        vbox.pack_start(self.opacity_scale, False, False, 0)
        vbox.pack_start(self.blur_label, False, False, 0)
        vbox.pack_start(self.blur_scale, False, False, 0)
        self.add(vbox)

        self.apply_css()
        self.show_all()

    def load_opacity(self):
        if os.path.exists(self.opacity_conf):
            try:
                with open(self.opacity_conf, "r") as f:
                    for line in f:
                        if line.startswith("background_opacity"):
                            return float(line.split()[1])
            except:
                pass
        return 0.75

    def load_blur(self):
        try:
            val = subprocess.check_output(["hyprctl", "getoption", "decoration:blur:size"]).decode()
            for line in val.split("\n"):
                if "int:" in line:
                    return int(line.split()[1])
        except:
            pass
        return 8

    def on_reset_clicked(self, widget):
        self.opacity_scale.set_value(0.75)
        self.blur_scale.set_value(8)

    def update_styles_opacity(self, opacity_val):
        # 1. Waybar の透明度同期
        waybar_css = os.path.expanduser("~/.config/waybar/style.css")
        if os.path.exists(waybar_css):
            try:
                with open(waybar_css, "r") as f:
                    content = f.read()
                
                def replacer(match):
                    r, g, b, _ = match.groups()
                    return f"rgba({r}, {g}, {b}, {opacity_val})"
                
                new_css = re.sub(r'rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*[\d\.]+\s*\)', replacer, content)
                
                with open(waybar_css, "w") as f:
                    f.write(new_css)
                
                subprocess.Popen(["pkill", "-SIGUSR2", "waybar"], stderr=subprocess.DEVNULL)
            except Exception:
                pass

        # 2. SwayNC (タップ時のメニューバー) の透明度同期
        swaync_css = os.path.expanduser("~/.config/swaync/style.css")
        if os.path.exists(swaync_css):
            try:
                with open(swaync_css, "r") as f:
                    content = f.read()
                
                def replacer(match):
                    r, g, b, _ = match.groups()
                    return f"rgba({r}, {g}, {b}, {opacity_val})"
                
                new_css = re.sub(r'rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*[\d\.]+\s*\)', replacer, content)
                
                with open(waybar_css, "w") as f:
                    f.write(new_css)
                
                subprocess.Popen(["swaync-client", "-R"], stderr=subprocess.DEVNULL)
                subprocess.Popen(["swaync-client", "-rs"], stderr=subprocess.DEVNULL)
            except Exception:
                pass

    def on_opacity_changed(self, scale):
        val = round(scale.get_value(), 2)
        with open(self.opacity_conf, "w") as f:
            f.write(f"background_opacity {val}\n")
        
        kitty_conf = os.path.expanduser("~/.config/kitty/kitty.conf")
        if os.path.exists(kitty_conf):
            try:
                os.utime(kitty_conf, None)
            except:
                pass
        
        subprocess.Popen(["pkill", "-USR1", "kitty"], stderr=subprocess.DEVNULL)
        self.update_styles_opacity(val)

    def on_blur_changed(self, scale):
        val = int(scale.get_value())
        if val == 0:
            subprocess.Popen(["hyprctl", "keyword", "decoration:blur:enabled", "false"], stderr=subprocess.DEVNULL)
        else:
            subprocess.Popen(["hyprctl", "keyword", "decoration:blur:enabled", "true"], stderr=subprocess.DEVNULL)
            subprocess.Popen(["hyprctl", "keyword", "decoration:blur:size", str(val)], stderr=subprocess.DEVNULL)
            passes = max(1, val // 2)
            subprocess.Popen(["hyprctl", "keyword", "decoration:blur:passes", str(passes)], stderr=subprocess.DEVNULL)
        
        subprocess.Popen(["pkill", "-SIGUSR2", "waybar"], stderr=subprocess.DEVNULL)
        subprocess.Popen(["swaync-client", "-R"], stderr=subprocess.DEVNULL)

    def apply_css(self):
        screen = Gdk.Screen.get_default()
        css_provider = Gtk.CssProvider()
        css = """
        window {
            background-color: rgba(28, 22, 24, 0.96);
            border: 1px solid rgba(234, 105, 98, 0.4);
            border-radius: 20px;
            box-shadow: 0 12px 32px rgba(0, 0, 0, 0.6);
        }
        .header-title {
            color: #d8a657;
            font-family: 'JetBrainsMono Nerd Font', 'Inter', sans-serif;
            font-weight: 800;
            font-size: 14px;
        }
        button {
            background-color: rgba(234, 105, 98, 0.2);
            color: #ea6962;
            border-radius: 10px;
            border: 1px solid rgba(234, 105, 98, 0.3);
            padding: 2px 8px;
            font-size: 11px;
            font-weight: bold;
        }
        button:hover {
            background-color: #ea6962;
            color: #1e1e1e;
        }
        .reset-btn {
            background-color: rgba(216, 166, 87, 0.2);
            color: #d8a657;
            border: 1px solid rgba(216, 166, 87, 0.3);
        }
        .reset-btn:hover {
            background-color: #d8a657;
            color: #1e1e1e;
        }
        label {
            color: #dfd0b2;
            font-family: 'JetBrainsMono Nerd Font', 'Inter', sans-serif;
            font-weight: bold;
            font-size: 12px;
            margin-top: 4px;
        }
        scale trough {
            background-color: rgba(255, 255, 255, 0.1);
            border-radius: 8px;
            min-height: 12px;
        }
        scale highlight {
            background: linear-gradient(90deg, #ea6962, #d8a657);
            border-radius: 8px;
        }
        scale slider {
            background-color: #dfd0b2;
            min-width: 18px;
            min-height: 18px;
            border-radius: 50%;
            border: none;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.4);
        }
        """
        css_provider.load_from_data(css.encode())
        Gtk.StyleContext.add_provider_for_screen(screen, css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

if __name__ == "__main__":
    app = DockedSliders()
    Gtk.main()
