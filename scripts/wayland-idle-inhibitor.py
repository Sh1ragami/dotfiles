#!/usr/bin/env python3
import sys
from dataclasses import dataclass
from signal import SIGINT, SIGTERM, signal
from threading import Event

from pywayland.client.display import Display

# Python 3.14+ vs older pywayland module import compatibility
try:
    from pywayland.protocol.wayland import WlCompositor, WlRegistryProxy, WlSurface
    from pywayland.protocol.idle_inhibit_unstable_v1 import ZwpIdleInhibitManagerV1
except ImportError:
    from pywayland.protocol.wayland.wl_compositor import WlCompositor
    from pywayland.protocol.wayland.wl_registry import WlRegistryProxy
    from pywayland.protocol.wayland.wl_surface import WlSurface
    from pywayland.protocol.idle_inhibit_unstable_v1.zwp_idle_inhibit_manager_v1 import (
        ZwpIdleInhibitManagerV1,
    )

@dataclass
class GlobalRegistry:
    surface: WlSurface = None
    inhibit_manager: ZwpIdleInhibitManagerV1 = None

def handle_registry_global(wl_registry, id_num, iface_name, version):
    global_registry = wl_registry.user_data or GlobalRegistry()

    if iface_name == "wl_compositor":
        compositor = wl_registry.bind(id_num, WlCompositor, version)
        global_registry.surface = compositor.create_surface()
    elif iface_name == "zwp_idle_inhibit_manager_v1":
        global_registry.inhibit_manager = wl_registry.bind(
            id_num, ZwpIdleInhibitManagerV1, version
        )

def main():
    done = Event()
    signal(SIGINT, lambda _, __: done.set())
    signal(SIGTERM, lambda _, __: done.set())

    global_registry = GlobalRegistry()

    display = Display()
    display.connect()

    registry = display.get_registry()
    registry.user_data = global_registry
    registry.dispatcher["global"] = handle_registry_global

    def shutdown():
        try:
            display.dispatch()
            display.roundtrip()
            display.disconnect()
        except Exception:
            pass

    display.dispatch()
    display.roundtrip()

    if global_registry.surface is None or global_registry.inhibit_manager is None:
        print("Wayland seems not to support idle_inhibit_unstable_v1 protocol.")
        shutdown()
        sys.exit(1)

    inhibitor = global_registry.inhibit_manager.create_inhibitor(
        global_registry.surface
    )

    display.dispatch()
    display.roundtrip()

    done.wait()

    try:
        inhibitor.destroy()
    except Exception:
        pass
    shutdown()

if __name__ == "__main__":
    main()
