import app from "ags/gtk4/app"
import style from "./style.scss"
import ControlCenter from "./widget/ControlCenter"

app.start({
  css: style,
  main() {
    app.get_monitors().map(ControlCenter)
  },
  requestHandler(argv, res) {
    const cmd = Array.isArray(argv) ? argv.join(" ") : String(argv)
    const parts = cmd.trim().split(/\s+/)
    const action = parts[0]
    const target = parts[1] // monitor connector name, e.g. "HDMI-A-1" or "eDP-1"

    if (action === "toggle") {
      let panel: any = null
      if (target) {
        panel = app.get_window(`control-center-${target}`)
      }
      if (!panel) {
        panel = app.windows.find(
          (w) => w.name && w.name.startsWith("control-center-") && !w.name.startsWith("cc-scrim")
        ) || app.get_window("control-center")
      }

      if (panel) {
        if (!panel.visible) {
          // Close other control-center panels if open
          for (const w of app.windows) {
            if (w !== panel && w.name && w.name.startsWith("control-center")) {
              w.visible = false
            }
          }
        }
        panel.visible = !panel.visible
      }
      res("ok")
    } else if (action === "close") {
      for (const w of app.windows) {
        if (w.name && (w.name.startsWith("control-center") || w.name.startsWith("cc-scrim"))) {
          w.visible = false
        }
      }
      res("ok")
    } else if (action === "visible") {
      const anyVisible = app.windows.some(
        (w) => w.name && w.name.startsWith("control-center") && w.visible
      )
      res(String(anyVisible))
    } else if (action.startsWith("theme")) {
      res("ok")
    } else {
      res("ok")
    }
  },
})
