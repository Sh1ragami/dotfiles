import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { createState } from "gnim"
import GLib from "gi://GLib?version=2.0"

function getThemeRgb(theme: string): string {
  switch (theme) {
    case "sunset": return "36, 27, 25"
    case "catppuccin": return "30, 30, 46"
    case "tokyonight": return "26, 27, 38"
    case "study": return "40, 42, 58"
    default: return "36, 27, 25"
  }
}

/* ═══════════════════════════════════════════════════════════
   Scrim — Fullscreen invisible click target for close
   ═══════════════════════════════════════════════════════════ */
function Scrim(gdkmonitor: Gdk.Monitor, connector: string) {
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor
  return (
    <window
      name={`cc-scrim-${connector}`}
      namespace="cc-scrim"
      gdkmonitor={gdkmonitor}
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.TOP}
      application={app}
      visible={false}
      class="ScrimWindow"
      $={(self) => {
        const click = new Gtk.GestureClick()
        click.set_button(0)
        click.connect("pressed", () => {
          self.visible = false
          const cc = app.get_window(`control-center-${connector}`)
          if (cc) cc.visible = false
        })
        self.add_controller(click)
      }}
    >
      <button
        class="scrim"
        hexpand
        vexpand
        canFocus={false}
        $={(btn) => {
          const click = new Gtk.GestureClick()
          click.set_button(0)
          click.connect("pressed", () => {
            const scrim = app.get_window(`cc-scrim-${connector}`)
            const cc = app.get_window(`control-center-${connector}`)
            if (scrim) scrim.visible = false
            if (cc) cc.visible = false
          })
          btn.add_controller(click)
        }}
        onClicked={() => {
          const scrim = app.get_window(`cc-scrim-${connector}`)
          const cc = app.get_window(`control-center-${connector}`)
          if (scrim) scrim.visible = false
          if (cc) cc.visible = false
        }}
      />
    </window>
  )
}

/* ═══════════════════════════════════════════════════════════
   Control Center — Dynamic Island that expands from top
   ═══════════════════════════════════════════════════════════ */
export default function ControlCenter(gdkmonitor: Gdk.Monitor) {
  const { TOP } = Astal.WindowAnchor
  const [activeTab, setActiveTab] = createState(0)
  const [currentTheme, setCurrentTheme] = createState("sunset")

  // Slider states
  const [volume, setVolume] = createState(50)
  const [brightness, setBrightness] = createState(50)
  const [opacity, setOpacity] = createState(75)
  const [blur, setBlur] = createState(8)
  const [gaps, setGaps] = createState(6)

  // Dynamic background
  const [cardBg, setCardBg] = createState("background-color: rgba(36, 27, 25, 0.75);")

  function updateCardBg(op?: number, th?: string) {
    const o = op !== undefined ? op : opacity()
    const t = th !== undefined ? th : currentTheme()
    const alpha = (o / 100).toFixed(2)
    const rgb = getThemeRgb(t)
    setCardBg(`background-color: rgba(${rgb}, ${alpha});`)
  }

  // Toggle states
  const [wifiEnabled, setWifiEnabled] = createState(true)
  const [btEnabled, setBtEnabled] = createState(true)
  const [dndEnabled, setDndEnabled] = createState(false)
  const [keySoundEnabled, setKeySoundEnabled] = createState(false)
  const [powerProfile, setPowerProfile] = createState("balanced")

  // Time display for the island pill
  const [clockText, setClockText] = createState("")

  function updateClock() {
    const now = new Date()
    const hh = String(now.getHours()).padStart(2, "0")
    const mm = String(now.getMinutes()).padStart(2, "0")
    const mo = now.getMonth() + 1
    const dd = now.getDate()
    const icon = dndEnabled() ? "" : ""
    setClockText(`${icon}  ${hh}:${mm}  |    ${mo}月${dd}日`)
  }
  updateClock()
  GLib.timeout_add(GLib.PRIORITY_DEFAULT, 10000, () => { updateClock(); return true })

  function loadTheme() {
    execAsync("sh -c 'cat /tmp/current_theme.txt 2>/dev/null || echo sunset'")
      .then((out) => {
        const t = out.trim()
        if (t && ["sunset", "catppuccin", "tokyonight", "study"].includes(t)) {
          setCurrentTheme(t)
          updateCardBg(undefined, t)
        }
      })
      .catch(() => {})
  }

  function loadSystemValues() {
    execAsync("wpctl get-volume @DEFAULT_AUDIO_SINK@")
      .then((out) => {
        const m = out.match(/Volume:\s+([0-9.]+)/)
        if (m) setVolume(Math.round(parseFloat(m[1]) * 100))
      })
      .catch(() => {})

    execAsync("brightnessctl -m")
      .then((out) => {
        const parts = out.split(",")
        if (parts[3]) setBrightness(parseInt(parts[3]))
      })
      .catch(() => {})

    execAsync("sh -c 'cat ~/.config/kitty/opacity.conf 2>/dev/null || echo 0.75'")
      .then((out) => {
        const m = out.match(/background_opacity\s+([0-9.]+)/)
        if (m) {
          const op = Math.round(parseFloat(m[1]) * 100)
          setOpacity(op)
          updateCardBg(op, undefined)
        }
      })
      .catch(() => {})

    execAsync("hyprctl getoption decoration:blur:size")
      .then((out) => {
        const m = out.match(/int:\s+(\d+)/)
        if (m) setBlur(parseInt(m[1]))
      })
      .catch(() => {})

    // Load wifi state
    execAsync("nmcli radio wifi")
      .then((out) => setWifiEnabled(out.trim() === "enabled"))
      .catch(() => {})

    // Load bluetooth state
    execAsync("sh -c 'bluetoothctl show | grep Powered | awk \"{print \\$2}\"'")
      .then((out) => setBtEnabled(out.trim() === "yes"))
      .catch(() => {})

    // Load DND state
    execAsync("swaync-client -D")
      .then((out) => setDndEnabled(out.trim() === "true"))
      .catch(() => {})

    // Load key sound (wayvibes) state
    execAsync("pgrep -x wayvibes")
      .then(() => setKeySoundEnabled(true))
      .catch(() => setKeySoundEnabled(false))

    // Load power profile
    execAsync("powerprofilesctl get")
      .then((out) => {
        const p = out.trim()
        if (p) setPowerProfile(p)
      })
      .catch(() => {})

    // Load gaps
    execAsync("hyprctl getoption general:gaps_in")
      .then((out) => {
        const m = out.match(/custom type:\s+(\d+)/)
        if (m) setGaps(parseInt(m[1]))
      })
      .catch(() => {})
  }

  loadTheme()
  loadSystemValues()

  const connector = (gdkmonitor.get_connector && gdkmonitor.get_connector()) || "default"

  // ─── Handlers ─── 
  function closeAll() {
    const scrim = app.get_window(`cc-scrim-${connector}`)
    const panel = app.get_window(`control-center-${connector}`)
    if (scrim) scrim.visible = false
    if (panel) panel.visible = false
  }

  function toggleWifi() {
    const next = !wifiEnabled()
    execAsync(`nmcli radio wifi ${next ? "on" : "off"}`)
      .then(() => setWifiEnabled(next))
      .catch(console.error)
  }

  function toggleBt() {
    const next = !btEnabled()
    execAsync(`bluetoothctl power ${next ? "on" : "off"}`)
      .then(() => setBtEnabled(next))
      .catch(console.error)
  }

  function toggleDnd() {
    execAsync("swaync-client -d")
      .then(() => {
        const next = !dndEnabled()
        setDndEnabled(next)
        if (!next) {
          // おやすみモードOFF（音が出る状態）
          execAsync("notify-send -u normal -i preferences-system-notifications '通知設定' 'おやすみモード: OFF (通知音が有効です)'").catch(() => {})
          execAsync("canberra-gtk-play -i message 2>/dev/null || pw-play /usr/share/sounds/freedesktop/stereo/message.oga 2>/dev/null").catch(() => {})
        } else {
          // おやすみモードON（消音中）
          execAsync("notify-send -u normal -i preferences-system-notifications-silent '通知設定' 'おやすみモード: ON (消音中)'").catch(() => {})
        }
      })
      .catch(console.error)
  }

  function toggleKeySound() {
    execAsync("sh -c '~/.config/waybar/scripts/wayvibes_toggle.sh'")
      .then(() => {
        setTimeout(() => {
          execAsync("pgrep -x wayvibes")
            .then(() => setKeySoundEnabled(true))
            .catch(() => setKeySoundEnabled(false))
        }, 200)
      })
      .catch(console.error)
  }

  function setPowerMode(mode: string) {
    execAsync(`powerprofilesctl set ${mode}`)
      .then(() => {
        setPowerProfile(mode)
        const names: Record<string, string> = {
          "power-saver": "省電力モード (発熱抑制)",
          "balanced": "バランスモード",
          "performance": "高出力モード",
        }
        execAsync(`notify-send -u low -i preferences-system-power "電源モード" "${names[mode] || mode}に切り替えました"`).catch(() => {})
      })
      .catch(console.error)
  }

  function onVolumeChange(val: number) {
    if (Math.abs(volume() - val) < 0.5) return
    setVolume(val)
    execAsync(`wpctl set-volume @DEFAULT_AUDIO_SINK@ ${Math.round(val)}%`).catch(() => {})
  }

  function onBrightnessChange(val: number) {
    if (Math.abs(brightness() - val) < 0.5) return
    setBrightness(val)
    execAsync(`brightnessctl s ${Math.round(val)}%`).catch(() => {})
  }

  function onOpacityChange(val: number) {
    if (Math.abs(opacity() - val) < 0.5) return
    setOpacity(val)
    updateCardBg(val, undefined)
    const op = (val / 100).toFixed(2)
    execAsync(`sh -c 'echo "background_opacity ${op}" > ~/.config/kitty/opacity.conf; pkill -SIGUSR2 waybar'`).catch(() => {})
  }

  function onBlurChange(val: number) {
    if (Math.abs(blur() - val) < 0.5) return
    setBlur(val)
    execAsync(`hyprctl keyword decoration:blur:size ${Math.round(val)}`).catch(() => {})
  }

  function onGapsChange(val: number) {
    if (Math.abs(gaps() - val) < 0.5) return
    const rounded = Math.round(val)
    setGaps(rounded)
    const out = rounded * 2
    execAsync(`sh -c 'hyprctl keyword general:gaps_in ${rounded}; hyprctl keyword general:gaps_out ${out}'`).catch(() => {})
  }

  function resetEffects() {
    setOpacity(75)
    setBlur(8)
    setGaps(6)
    updateCardBg(75, undefined)
    execAsync("sh -c 'echo \"background_opacity 0.75\" > ~/.config/kitty/opacity.conf; pkill -SIGUSR2 waybar; hyprctl keyword decoration:blur:size 8; hyprctl keyword general:gaps_in 6; hyprctl keyword general:gaps_out 12'").catch(() => {})
  }

  // Build the scrim
  Scrim(gdkmonitor, connector)

  return (
    <window
      name={`control-center-${connector}`}
      namespace="control-center"
      class={currentTheme((t) => `ControlCenterWindow theme-${t}`)}
      gdkmonitor={gdkmonitor}
      anchor={TOP}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.OVERLAY}
      keymode={Astal.Keymode.ON_DEMAND}
      application={app}
      visible={false}
      $={(self) => {
        const keyCtrl = new Gtk.EventControllerKey()
        keyCtrl.connect("key-pressed", (_, keyval) => {
          if (keyval === Gdk.KEY_Escape) {
            closeAll()
            return true
          }
          return false
        })
        self.add_controller(keyCtrl)

        self.connect("notify::visible", () => {
          const scrim = app.get_window(`cc-scrim-${connector}`)
          if (self.visible) {
            loadTheme()
            loadSystemValues()
            updateClock()
            if (scrim) scrim.visible = true
          } else {
            if (scrim) scrim.visible = false
          }
        })
      }}
    >
      {/* ── Main island column ── */}
      <box
        orientation={Gtk.Orientation.VERTICAL}
        halign={Gtk.Align.CENTER}
        valign={Gtk.Align.START}
        class="island-container"
        widthRequest={360}
      >
        {/* The pill — clock display, visually covers waybar's island */}
        <button
          class="island-pill"
          halign={Gtk.Align.FILL}
          hexpand
          onClicked={closeAll}
        >
          <label label={clockText} hexpand halign={Gtk.Align.CENTER} />
        </button>

        {/* Expanding content card */}
        <box
          orientation={Gtk.Orientation.VERTICAL}
          class="cc-card"
          spacing={10}
          widthRequest={360}
          css={cardBg}
        >
          {/* Tab bar */}
          <box class="tab-bar" halign={Gtk.Align.CENTER} spacing={0} homogeneous>
            <button
              class={activeTab((t) => (t === 0 ? "tab-btn active" : "tab-btn"))}
              onClicked={() => setActiveTab(0)}
            >
              <label label="󰤨  設定" />
            </button>
            <button
              class={activeTab((t) => (t === 1 ? "tab-btn active" : "tab-btn"))}
              onClicked={() => setActiveTab(1)}
            >
              <label label="󱡁  効果" />
            </button>
            <button
              class={activeTab((t) => (t === 2 ? "tab-btn active" : "tab-btn"))}
              onClicked={() => setActiveTab(2)}
            >
              <label label="󰸗  カレンダー" />
            </button>
          </box>

          {/* ─── Page 1: Quick Settings ─── */}
          <box
            orientation={Gtk.Orientation.VERTICAL}
            spacing={8}
            visible={activeTab((t) => t === 0)}
          >
            <box spacing={6} homogeneous>
              <button class={wifiEnabled((w) => w ? "tile-btn active" : "tile-btn")} onClicked={toggleWifi}>
                <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
                  <label class="tile-icon" label="󰤨" />
                  <label class="tile-label" label="Wi-Fi" />
                </box>
              </button>
              <button class={btEnabled((b) => b ? "tile-btn active" : "tile-btn")} onClicked={toggleBt}>
                <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
                  <label class="tile-icon" label="󰂯" />
                  <label class="tile-label" label="BT" />
                </box>
              </button>
              <button class={dndEnabled((d) => d ? "tile-btn active" : "tile-btn")} onClicked={toggleDnd}>
                <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
                  <label class="tile-icon" label="󰍶" />
                  <label class="tile-label" label="おやすみ" />
                </box>
              </button>
            </box>
            <box spacing={6} homogeneous>
              <button class="tile-btn" onClicked={() => { execAsync("pwvucontrol"); closeAll() }}>
                <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
                  <label class="tile-icon" label="󰕾" />
                  <label class="tile-label" label="音量" />
                </box>
              </button>
              <button class={keySoundEnabled((k) => k ? "tile-btn active" : "tile-btn")} onClicked={toggleKeySound}>
                <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
                  <label class="tile-icon" label="󰌌" />
                  <label class="tile-label" label="打鍵音" />
                </box>
              </button>
              <button class="tile-btn" onClicked={() => { execAsync("wlogout"); closeAll() }}>
                <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
                  <label class="tile-icon" label="" />
                  <label class="tile-label" label="電源" />
                </box>
              </button>
            </box>

            {/* Power Profile Selector */}
            <box class="power-profile-bar" spacing={4} homogeneous>
              <button
                class={powerProfile((p) => p === "power-saver" ? "power-btn active saver" : "power-btn")}
                onClicked={() => setPowerMode("power-saver")}
              >
                <box spacing={6} halign={Gtk.Align.CENTER}>
                  <label class="power-icon" label="󰌪" />
                  <label class="power-label" label="省電力" />
                </box>
              </button>
              <button
                class={powerProfile((p) => p === "balanced" ? "power-btn active balanced" : "power-btn")}
                onClicked={() => setPowerMode("balanced")}
              >
                <box spacing={6} halign={Gtk.Align.CENTER}>
                  <label class="power-icon" label="󰾅" />
                  <label class="power-label" label="バランス" />
                </box>
              </button>
              <button
                class={powerProfile((p) => p === "performance" ? "power-btn active perf" : "power-btn")}
                onClicked={() => setPowerMode("performance")}
              >
                <box spacing={6} halign={Gtk.Align.CENTER}>
                  <label class="power-icon" label="󰓅" />
                  <label class="power-label" label="高出力" />
                </box>
              </button>
            </box>

            {/* Volume */}
            <box orientation={Gtk.Orientation.VERTICAL} class="slider-group" spacing={2}>
              <box spacing={8}>
                <label label="󰕾  音量" hexpand halign={Gtk.Align.START} />
                <label label={volume((v) => `${Math.round(v)}%`)} halign={Gtk.Align.END} />
              </box>
              <slider
                hexpand min={0} max={100} value={volume}
                onValueChanged={(self: any) => onVolumeChange(self.value)}
              />
            </box>

            {/* Brightness */}
            <box orientation={Gtk.Orientation.VERTICAL} class="slider-group" spacing={2}>
              <box spacing={8}>
                <label label="󰃠  明るさ" hexpand halign={Gtk.Align.START} />
                <label label={brightness((b) => `${Math.round(b)}%`)} halign={Gtk.Align.END} />
              </box>
              <slider
                hexpand min={1} max={100} value={brightness}
                onValueChanged={(self: any) => onBrightnessChange(self.value)}
              />
            </box>
          </box>

          {/* ─── Page 2: Effects ─── */}
          <box
            orientation={Gtk.Orientation.VERTICAL}
            spacing={8}
            visible={activeTab((t) => t === 1)}
          >
            <box orientation={Gtk.Orientation.VERTICAL} class="slider-group" spacing={2}>
              <box spacing={8}>
                <label label="󰞌  透過度" hexpand halign={Gtk.Align.START} />
                <label label={opacity((o) => `${Math.round(o)}%`)} halign={Gtk.Align.END} />
              </box>
              <slider
                hexpand min={10} max={100} value={opacity}
                onValueChanged={(self: any) => onOpacityChange(self.value)}
              />
            </box>

            <box orientation={Gtk.Orientation.VERTICAL} class="slider-group" spacing={2}>
              <box spacing={8}>
                <label label="󱡁  ブラー" hexpand halign={Gtk.Align.START} />
                <label label={blur((b) => `${Math.round(b)} px`)} halign={Gtk.Align.END} />
              </box>
              <slider
                hexpand min={0} max={20} value={blur}
                onValueChanged={(self: any) => onBlurChange(self.value)}
              />
            </box>

            <box orientation={Gtk.Orientation.VERTICAL} class="slider-group" spacing={2}>
              <box spacing={8}>
                <label label="󰍍  ウィンドウの隙間" hexpand halign={Gtk.Align.START} />
                <label label={gaps((g) => `${Math.round(g)} px`)} halign={Gtk.Align.END} />
              </box>
              <slider
                hexpand min={0} max={30} value={gaps}
                onValueChanged={(self: any) => onGapsChange(self.value)}
              />
            </box>

            <button class="reset-btn" onClicked={resetEffects}>
              <label label="↺ デフォルトに戻す" />
            </button>
          </box>

          {/* ─── Page 3: Calendar & Media ─── */}
          <box
            orientation={Gtk.Orientation.VERTICAL}
            spacing={8}
            visible={activeTab((t) => t === 2)}
          >
            <Gtk.Calendar class="modern-calendar" />

            <box class="media-controls" spacing={12} halign={Gtk.Align.CENTER}>
              <button class="media-btn" onClicked={() => execAsync("playerctl previous")}>
                <label label="󰒮" />
              </button>
              <button class="media-btn play" onClicked={() => execAsync("playerctl play-pause")}>
                <label label="󰐊" />
              </button>
              <button class="media-btn" onClicked={() => execAsync("playerctl next")}>
                <label label="󰒭" />
              </button>
            </box>
          </box>
        </box>
      </box>
    </window>
  )
}
