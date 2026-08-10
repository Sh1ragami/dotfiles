#!/usr/bin/env python3
import os
import sys
import socket
import signal
import subprocess
import gi

SOCKET_PATH = "/tmp/theme_selector.sock"
PID_FILE = "/tmp/theme_selector_gui.pid"

def send_socket_command(cmd):
    if os.path.exists(SOCKET_PATH):
        try:
            client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            client.connect(SOCKET_PATH)
            client.sendall(cmd.encode("utf-8"))
            client.close()
            return True
        except Exception:
            pass
    return False

# Command-line argument handling
action = sys.argv[1] if len(sys.argv) > 1 else "toggle"

if action == "left":
    if not send_socket_command("left"):
        subprocess.run("hyprctl dispatch movefocus l", shell=True)
    sys.exit(0)

elif action == "right":
    if not send_socket_command("right"):
        subprocess.run("hyprctl dispatch movefocus r", shell=True)
    sys.exit(0)

elif action == "select" or action == "enter":
    if send_socket_command("select"):
        sys.exit(0)

elif action == "toggle":
    if os.path.exists(PID_FILE):
        try:
            old_pid = int(open(PID_FILE).read().strip())
            if old_pid != os.getpid():
                os.kill(old_pid, signal.SIGTERM)
                os.remove(PID_FILE)
                if os.path.exists(SOCKET_PATH):
                    os.remove(SOCKET_PATH)
                sys.exit(0)
        except Exception:
            pass

open(PID_FILE, "w").write(str(os.getpid()))

def cleanup():
    if os.path.exists(PID_FILE):
        try:
            os.remove(PID_FILE)
        except Exception:
            pass
    if os.path.exists(SOCKET_PATH):
        try:
            os.remove(SOCKET_PATH)
        except Exception:
            pass

gi.require_version("Gtk", "3.0")
gi.require_version("GdkPixbuf", "2.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gtk, Gdk, GdkPixbuf, GtkLayerShell, GLib

CACHE_DIR = os.path.expanduser("~/.cache/hypr_theme_thumbnails")
os.makedirs(CACHE_DIR, exist_ok=True)

THEMES = [
    {"name": "sunset", "path": os.path.expanduser("~/dotfiles/themes/sunset/hypr/wallpaper.png")},
    {"name": "catppuccin", "path": os.path.expanduser("~/dotfiles/themes/catppuccin/hypr/wallpaper.png")},
    {"name": "tokyonight", "path": os.path.expanduser("~/dotfiles/themes/tokyonight/hypr/wallpaper.png")},
    {"name": "study", "path": os.path.expanduser("~/dotfiles/themes/study/hypr/wallpaper.png")},
]

def get_current_active_theme():
    cur_file = "/tmp/current_theme.txt"
    if os.path.exists(cur_file):
        try:
            return open(cur_file).read().strip()
        except Exception:
            pass
    return "sunset"

def get_thumbnail_path(theme):
    thumb_path = os.path.join(CACHE_DIR, f"{theme['name']}.png")
    orig_path = theme['path']
    if not os.path.exists(thumb_path) or (os.path.exists(orig_path) and os.path.getmtime(orig_path) > os.path.getmtime(thumb_path)):
        try:
            pb = GdkPixbuf.Pixbuf.new_from_file_at_scale(orig_path, 240, 135, False)
            pb.savev(thumb_path, "png", [], [])
        except Exception:
            return orig_path
    return thumb_path

class ThemeSelectorWindow(Gtk.Window):
    def __init__(self):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)

        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.BOTTOM, True)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.BOTTOM, 28)
        GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.EXCLUSIVE)

        self.set_app_paintable(True)
        screen = Gdk.Screen.get_default()
        visual = screen.get_rgba_visual()
        if visual:
            self.set_visual(visual)

        self.connect("key-press-event", self.on_key_press)
        self.connect("focus-out-event", self.on_focus_out)
        self.connect("button-press-event", self.on_button_press)

        current_theme = get_current_active_theme()

        self.selected_index = 0
        for i, t in enumerate(THEMES):
            if t["name"] == current_theme:
                self.selected_index = i

        css = b"""
        * {
            font-family: "JetBrainsMono Nerd Font", "Inter", sans-serif;
            transition: none;
        }
        .selector-box {
            background: transparent;
            border: none;
            box-shadow: none;
            padding: 0px;
        }
        button.card-button {
            background-color: transparent;
            border-style: solid;
            border-width: 2px;
            border-color: transparent;
            border-radius: 16px;
            padding: 0px;
            margin: 0px 10px;
            box-shadow: none;
        }
        button.card-button-sunset {
            border-width: 2px;
            border-color: #ea6962;
            box-shadow: 0 4px 20px rgba(234, 105, 98, 0.45);
        }
        button.card-button-catppuccin {
            border-width: 2px;
            border-color: #cba6f7;
            box-shadow: 0 4px 20px rgba(203, 166, 247, 0.45);
        }
        button.card-button-tokyonight {
            border-width: 2px;
            border-color: #7aa2f7;
            box-shadow: 0 4px 20px rgba(122, 162, 247, 0.45);
        }
        button.card-button-study {
            border-width: 2px;
            border-color: #a9b665;
            box-shadow: 0 4px 20px rgba(169, 182, 101, 0.45);
        }
        .active-icon {
            color: #ffffff;
            background-color: rgba(234, 105, 98, 0.9);
            border-radius: 50%;
            font-size: 18px;
            font-weight: bold;
            padding: 6px 10px;
        }
        """
        provider = Gtk.CssProvider()
        provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(screen, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

        main_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=16)
        main_box.get_style_context().add_class("selector-box")

        self.buttons = []

        for i, theme in enumerate(THEMES):
            btn = Gtk.Button()
            btn.get_style_context().add_class("card-button")

            overlay = Gtk.Overlay()

            is_active = (theme["name"] == current_theme)

            img = Gtk.Image()
            thumb_path = get_thumbnail_path(theme)
            if os.path.exists(thumb_path):
                img.set_from_file(thumb_path)
            overlay.add(img)

            if is_active:
                badge = Gtk.Label(label="󰄬")
                badge.get_style_context().add_class("active-icon")
                badge.set_halign(Gtk.Align.CENTER)
                badge.set_valign(Gtk.Align.CENTER)
                overlay.add_overlay(badge)

            btn.add(overlay)
            btn.connect("clicked", self.on_theme_clicked, theme)
            main_box.pack_start(btn, False, False, 0)

            self.buttons.append(btn)

        self.add(main_box)
        self.update_card_focus()
        self.start_socket_server()

    def start_socket_server(self):
        if os.path.exists(SOCKET_PATH):
            try:
                os.remove(SOCKET_PATH)
            except Exception:
                pass
        self.server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.server.bind(SOCKET_PATH)
        self.server.listen(5)
        self.server.setblocking(False)
        GLib.io_add_watch(self.server.fileno(), GLib.IO_IN, self.on_socket_connect)

    def on_socket_connect(self, source, condition):
        try:
            conn, _ = self.server.accept()
            data = conn.recv(1024).decode("utf-8").strip()
            conn.close()

            if data == "left":
                self.selected_index = (self.selected_index - 1) % len(THEMES)
                self.update_card_focus()
            elif data == "right":
                self.selected_index = (self.selected_index + 1) % len(THEMES)
                self.update_card_focus()
            elif data == "select":
                theme = THEMES[self.selected_index]
                self.apply_theme(theme)
        except Exception:
            pass
        return True

    def update_card_focus(self):
        for i, btn in enumerate(self.buttons):
            ctx = btn.get_style_context()
            theme_cls = f"card-button-{THEMES[i]['name']}"
            if i == self.selected_index:
                ctx.add_class(theme_cls)
            else:
                ctx.remove_class(theme_cls)
            btn.queue_draw()

    def on_key_press(self, widget, event):
        kv = event.keyval
        if kv in [Gdk.KEY_h, Gdk.KEY_H, Gdk.KEY_Left]:
            self.selected_index = (self.selected_index - 1) % len(THEMES)
            self.update_card_focus()
            return True
        elif kv in [Gdk.KEY_l, Gdk.KEY_L, Gdk.KEY_Right]:
            self.selected_index = (self.selected_index + 1) % len(THEMES)
            self.update_card_focus()
            return True
        elif kv in [Gdk.KEY_Return, Gdk.KEY_KP_Enter, Gdk.KEY_space]:
            theme = THEMES[self.selected_index]
            self.apply_theme(theme)
            return True
        elif kv == Gdk.KEY_Escape:
            cleanup()
            Gtk.main_quit()
            return True
        return False

    def on_focus_out(self, widget, event):
        cleanup()
        Gtk.main_quit()

    def on_button_press(self, widget, event):
        x, y = event.x, event.y
        allocation = widget.get_allocation()
        if x < 0 or y < 0 or x > allocation.width or y > allocation.height:
            cleanup()
            Gtk.main_quit()

    def apply_theme(self, theme):
        cleanup()
        script_dir = os.path.expanduser("~/.config/hypr/scripts")
        circle_script = os.path.join(script_dir, "circle_transition.py")
        subprocess.Popen(["python3", circle_script, theme["path"], theme["name"]])
        Gtk.main_quit()

    def on_theme_clicked(self, button, theme):
        self.apply_theme(theme)

if __name__ == "__main__":
    try:
        win = ThemeSelectorWindow()
        win.show_all()
        Gtk.main()
    finally:
        cleanup()
