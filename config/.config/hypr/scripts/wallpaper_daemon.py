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
        # Hyprland wallpaper layer is Layer.BOTTOM (Layer 1)
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
        if os.path.exists(wall_path):
            try:
                alloc = self.get_allocation()
                w = alloc.width if alloc.width > 100 else 1920
                h = alloc.height if alloc.height > 100 else 1080
                
                pb = GdkPixbuf.Pixbuf.new_from_file_at_scale(wall_path, w, h, False)
                self.img.set_from_pixbuf(pb)
            except Exception:
                pass
        self.queue_draw()

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
            win.reload_wallpaper()
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
