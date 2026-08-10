#!/usr/bin/env python3
import os
import sys
import math
import subprocess
import gi

gi.require_version("Gtk", "3.0")
gi.require_version("GdkPixbuf", "2.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gtk, Gdk, GdkPixbuf, GtkLayerShell, GLib

if len(sys.argv) < 3:
    print("Usage: circle_transition.py <wallpaper_path> <theme_name>")
    sys.exit(1)

wallpaper_path = sys.argv[1]
theme_name = sys.argv[2]

# Launch theme application script IMMEDIATELY in parallel for instant Waybar/Kitty/Hyprland updates!
theme_script = os.path.expanduser("~/.config/hypr/scripts/theme_selector_direct.sh")
subprocess.Popen([theme_script, theme_name])

pixbuf = GdkPixbuf.Pixbuf.new_from_file(wallpaper_path)

class CircleTransitionWindow(Gtk.Window):
    def __init__(self):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)

        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
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

        self.connect("draw", self.on_draw)

        self.radius = 0.0
        self.max_radius = math.sqrt((1920 ** 2) + (1080 ** 2))
        self.start_time = GLib.get_monotonic_time()
        self.duration = 380000.0  # 380ms fast ripple animation

        self.scaled_pixbuf = None
        self.connect("configure-event", self.on_configure)

        GLib.timeout_add(16, self.animate)

    def on_configure(self, widget, event):
        w, h = event.width, event.height
        self.max_radius = math.sqrt((w ** 2) + (h ** 2))
        if pixbuf:
            self.scaled_pixbuf = pixbuf.scale_simple(w, h, GdkPixbuf.InterpType.BILINEAR)

    def animate(self):
        now = GLib.get_monotonic_time()
        elapsed = now - self.start_time
        progress = min(1.0, elapsed / self.duration)
        
        # Cubic ease-out curve
        ease_progress = 1.0 - math.pow(1.0 - progress, 3)
        self.radius = ease_progress * self.max_radius

        self.queue_draw()

        if progress >= 1.0:
            GLib.timeout_add(50, Gtk.main_quit)
            return False
        return True

    def on_draw(self, widget, cr):
        w = self.get_allocated_width()
        h = self.get_allocated_height()

        cr.set_operator(Gdk.CairoOperator.CLEAR)
        cr.paint()
        cr.set_operator(Gdk.CairoOperator.OVER)

        if self.scaled_pixbuf and self.radius > 0:
            cr.save()
            cr.arc(w / 2.0, h / 2.0, self.radius, 0, 2 * math.pi)
            cr.clip()
            Gdk.cairo_set_source_pixbuf(cr, self.scaled_pixbuf, 0, 0)
            cr.paint()
            cr.restore()
        return False

win = CircleTransitionWindow()
win.show_all()
Gtk.main()
