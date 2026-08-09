#!/usr/bin/env python3
# opacity_slider.py - Kittyの透過度を調整するスライダーGUI

import sys
import os
import subprocess
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk

class OpacitySlider(Gtk.Window):
    def __init__(self):
        super().__init__(title="Opacity Slider")
        self.set_border_width(12)
        self.set_default_size(240, 60)
        self.set_keep_above(True)
        
        # ウィンドウデコレーションを無効化 (タイトルバーなしのミニマルデザイン)
        self.set_decorated(False)
        self.set_type_hint(Gdk.WindowTypeHint.UTILITY)
        
        # 画面の右上 (SwayNCサイドバーの左隣) に配置
        display = Gdk.Display.get_default()
        monitor = display.get_primary_monitor()
        geometry = monitor.get_geometry()
        # 右上端 (x: 画面幅 - ウィンドウ幅 - 410px (SwayNCマージン込の幅), y: 80px)
        self.move(geometry.width - 240 - 410, 80)

        # 現在の透過度を opacity.conf からロード
        self.conf_file = os.path.expanduser("~/.config/kitty/opacity.conf")
        current_opacity = 0.82
        if os.path.exists(self.conf_file):
            try:
                with open(self.conf_file, "r") as f:
                    for line in f:
                        if line.startswith("background_opacity"):
                            current_opacity = float(line.split()[1])
            except Exception:
                pass

        # スライダー (Gtk.Scale)
        # 0.3 (かなり透明) から 1.0 (不透明)
        self.scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0.3, 1.0, 0.02)
        self.scale.set_value(current_opacity)
        self.scale.set_digits(2)
        self.scale.set_value_pos(Gtk.PositionType.RIGHT)
        self.scale.connect("value-changed", self.on_value_changed)

        # ラベル
        self.label = Gtk.Label(label="Terminal Opacity")
        self.label.set_margin_bottom(6)

        # ボックスレイアウト
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        box.pack_start(self.label, True, True, 0)
        box.pack_start(self.scale, True, True, 0)
        self.add(box)

        # フォーカスが外れたら自動で終了してウィンドウを閉じる
        self.connect("focus-out-event", lambda w, e: self.destroy())
        self.connect("destroy", Gtk.main_quit)
        
        # UIスタイリング
        self.apply_css()
        self.show_all()

        # ウィンドウ表示後にフォーカスを当てる (フォーカスアウトを検知させるため)
        self.present()

    def on_value_changed(self, scroll):
        val = round(self.scale.get_value(), 2)
        # 設定ファイル書き込み
        with open(self.conf_file, "w") as f:
            f.write(f"background_opacity {val}\n")
        # 起動中のKittyにリロードシグナル送信
        subprocess.run(["pkill", "-USR1", "kitty"])

    def apply_css(self):
        screen = Gdk.Screen.get_default()
        css_provider = Gtk.CssProvider()
        css = """
        window {
            background-color: rgba(26, 20, 18, 0.95);
            border: 1px solid rgba(234, 105, 98, 0.35);
            border-radius: 12px;
        }
        label {
            color: #dfd0b2;
            font-family: 'JetBrainsMono Nerd Font', 'Ubuntu Nerd Font', sans-serif;
            font-weight: bold;
            font-size: 11px;
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
    app = OpacitySlider()
    Gtk.main()
