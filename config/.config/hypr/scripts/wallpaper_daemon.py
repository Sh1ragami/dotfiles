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
    def __init__(self, monitor):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)
        self.monitor = monitor
        self.pixbuf = None

        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_monitor(self, monitor)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.BOTTOM)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.BOTTOM, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.LEFT, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.RIGHT, True)
        GtkLayerShell.set_exclusive_zone(self, -1)

        self.set_app_paintable(True)
        visual = self.get_screen().get_rgba_visual()
        if visual:
            self.set_visual(visual)

        self.connect("draw", self.on_draw)
        self.connect("configure-event", self.on_configure)
        self.reload_wallpaper()

    def on_draw(self, widget, cr):
        if self.pixbuf:
            Gdk.cairo_set_source_pixbuf(cr, self.pixbuf, 0, 0)
            cr.paint()
        return True

    def reload_wallpaper(self):
        wall_path = os.path.expanduser("~/.config/hypr/wallpaper.png")
        if not os.path.exists(wall_path):
            return

        try:
            geom = self.monitor.get_geometry()
            w = max(geom.width, 100)
            h = max(geom.height, 100)

            pixbuf = GdkPixbuf.Pixbuf.new_from_file(wall_path)
            orig_w = pixbuf.get_width()
            orig_h = pixbuf.get_height()

            scale_w = w / orig_w
            scale_h = h / orig_h
            scale = max(scale_w, scale_h)

            target_w = max(1, int(orig_w * scale))
            target_h = max(1, int(orig_h * scale))

            scaled = pixbuf.scale_simple(target_w, target_h, GdkPixbuf.InterpType.BILINEAR)

            offset_x = max(0, (target_w - w) // 2)
            offset_y = max(0, (target_h - h) // 2)

            sub_pb = GdkPixbuf.Pixbuf.new(
                pixbuf.get_colorspace(),
                pixbuf.get_has_alpha(),
                pixbuf.get_bits_per_sample(),
                w,
                h
            )
            scaled.copy_area(offset_x, offset_y, w, h, sub_pb, 0, 0)
            self.pixbuf = sub_pb
        except Exception:
            try:
                self.pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(wall_path, 1920, 1080, False)
            except Exception:
                pass

        self.queue_draw()

    def on_configure(self, widget, event):
        self.reload_wallpaper()

class WallpaperManager:
    def __init__(self):
        self.windows = []
        self.setup_monitors()

        display = Gdk.Display.get_default()
        display.connect("monitor-added", lambda d, m: GLib.idle_add(self.setup_monitors))
        display.connect("monitor-removed", lambda d, m: GLib.idle_add(self.setup_monitors))

    def setup_monitors(self):
        for win in self.windows:
            win.destroy()
        self.windows.clear()

        display = Gdk.Display.get_default()
        for i in range(display.get_n_monitors()):
            mon = display.get_monitor(i)
            win = WallpaperWindow(mon)
            win.show_all()
            self.windows.append(win)
        return False

    def reload_all(self):
        display = Gdk.Display.get_default()
        if len(self.windows) != display.get_n_monitors():
            self.setup_monitors()
            return
        for win in self.windows:
            win.reload_wallpaper()

def start_ipc_server(manager):
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
            manager.reload_all()
        except Exception:
            pass
        return True

    GLib.io_add_watch(server.fileno(), GLib.IO_IN, on_connect)

if __name__ == "__main__":
    try:
        manager = WallpaperManager()
        start_ipc_server(manager)
        Gtk.main()
    finally:
        cleanup()
