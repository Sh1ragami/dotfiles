#!/usr/bin/env python3
import os
import sys
import socket
import signal
import gi

SOCKET_PATH = "/tmp/hypr_wallpaper.sock"
PID_FILE = "/tmp/hypr_wallpaper.pid"

if os.path.exists(PID_FILE):
    try:
        old_pid = int(open(PID_FILE).read().strip())
        if old_pid != os.getpid():
            os.kill(old_pid, signal.SIGTERM)
            os.remove(PID_FILE)
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

class WallpaperWindow(Gtk.Window):
    def __init__(self):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)

        GtkLayerShell.init_for_window(self)
        # Hyprland wallpaper layer is Layer.BOTTOM
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.BOTTOM)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.BOTTOM, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.LEFT, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.RIGHT, True)
        GtkLayerShell.set_exclusive_zone(self, -1)

        self.set_app_paintable(True)
        screen = Gdk.Screen.get_default()
        visual = screen.get_rgba_visual()
        if visual:
            self.set_visual(visual)

        self.img = Gtk.Image()
        self.add(self.img)

        self.connect("configure-event", self.on_configure)
        self.reload_wallpaper()

    def reload_wallpaper(self):
        wall_path = os.path.expanduser("~/.config/hypr/wallpaper.png")
        if not os.path.exists(wall_path):
            return

        try:
            # モニターの解像度を正確に取得
            screen = Gdk.Screen.get_default()
            monitor_num = screen.get_primary_monitor()
            if monitor_num < 0:
                monitor_num = 0
            geom = screen.get_monitor_geometry(monitor_num)

            alloc = self.get_allocation()
            w = max(geom.width, alloc.width if alloc.width > 100 else 0, 1920)
            h = max(geom.height, alloc.height if alloc.height > 100 else 0, 1080)

            pixbuf = GdkPixbuf.Pixbuf.new_from_file(wall_path)
            orig_w = pixbuf.get_width()
            orig_h = pixbuf.get_height()

            # アスペクト比を維持して画面全体をカバー (Fill / Cover モード)
            scale_w = w / orig_w
            scale_h = h / orig_h
            scale = max(scale_w, scale_h)

            target_w = max(1, int(orig_w * scale))
            target_h = max(1, int(orig_h * scale))

            scaled = pixbuf.scale_simple(target_w, target_h, GdkPixbuf.InterpType.BILINEAR)

            # 中央寄せトリミング
            offset_x = (target_w - w) // 2
            offset_y = (target_h - h) // 2

            sub_pb = GdkPixbuf.Pixbuf.new(
                pixbuf.get_colorspace(),
                pixbuf.get_has_alpha(),
                pixbuf.get_bits_per_sample(),
                w,
                h
            )
            scaled.copy_area(offset_x, offset_y, w, h, sub_pb, 0, 0)

            self.img.set_from_pixbuf(sub_pb)
        except Exception as e:
            try:
                pb = GdkPixbuf.Pixbuf.new_from_file_at_scale(wall_path, 1920, 1080, False)
                self.img.set_from_pixbuf(pb)
            except Exception:
                pass

        self.queue_draw()

    def schedule_reload(self):
        self.reload_wallpaper()
        # レイアウト確定後の遅延リロード（拡大ズレの防止）
        GLib.timeout_add(150, self.reload_wallpaper_once)

    def reload_wallpaper_once(self):
        self.reload_wallpaper()
        return False

    def on_configure(self, widget, event):
        self.reload_wallpaper()

def start_ipc_server(win):
    if os.path.exists(SOCKET_PATH):
        try:
            os.remove(SOCKET_PATH)
        except Exception:
            pass
    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(SOCKET_PATH)
    server.listen(5)
    server.setblocking(False)

    def on_connect(source, condition):
        try:
            conn, _ = server.accept()
            conn.recv(1024)
            conn.close()
            win.schedule_reload()
        except Exception:
            pass
        return True

    GLib.io_add_watch(server.fileno(), GLib.IO_IN, on_connect)

if __name__ == "__main__":
    try:
        win = WallpaperWindow()
        win.show_all()
        start_ipc_server(win)
        Gtk.main()
    finally:
        cleanup()
