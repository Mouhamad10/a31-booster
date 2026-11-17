# A31 Booster (Turbo + Blur)

A single Magisk module for the **Samsung Galaxy A31 (SM-A315F, MediaTek MT6768)** that does two things:

1. **On-demand TURBO** — pushes the CPU, the **Mali-G52 MC2 GPU** and I/O to maximum and relaxes thermal throttling, toggled from **Magisk's Action button**. For bursts: gaming, heavy exports, builds.
2. **Lighter cosmetics** — enables **Quick Settings / window background blur** and a few smoother-UI props, meant to feel lighter than stock One UI.

> Root with **Magisk** required. Built for the A31; it installs on other MT6768 phones but some sysfs paths may differ (the scripts fail safe).

## Install
1. Download `a31-booster.zip` from [Releases](https://github.com/Mouhamad10/a31-booster/releases/latest).
2. Magisk app → **Modules** → **Install from storage** → pick the zip → reboot.

## Use
- **TURBO on/off:** Magisk app → **Modules** → **A31 Booster** → **Action**.
  Each tap toggles between TURBO and NORMAL. The phone always boots in NORMAL.
- **Blur / UI props:** applied automatically every boot (no action needed).

## ⚠️ Heat warning
TURBO **disables thermal throttling** while it is ON. The phone will get hot under load.
Use it in short bursts and toggle it **OFF** when done. NORMAL restores full thermal protection.
Safety nets in v1.1: TURBO **refuses to start above 52 °C** battery temp, and **snapshots** every value
it changes so NORMAL restores your exact previous state.

## About the blur
`ro.surface_flinger.supports_background_blur=1` only **arms** AOSP background blur — SystemUI still has
to request it. It renders on **AOSP-based ROMs and OneOS guest systems**. On **stock One UI**, Samsung's
SystemUI won't honour it, so for real QS depth/blur on One UI use **[Iconify](https://github.com/Mahmud0808/Iconify)**
(QS overlays, no SystemUI recompile). The genuinely "lighter than One UI" blur realistically lands on a
light **GSI** (see the [a31-nethunter](https://github.com/Mouhamad10/a31-nethunter) ROM guide), not patched stock One UI.

## What TURBO changes
- CPU: `performance` governor, `scaling_min_freq = max`, MTK PPM / hotplug off.
- GPU: top Mali OPP, GED DVFS off, devfreq governor `performance`.
- Thermal: `thermald` / `mtk_thermal` stopped, thermal zones disabled (temporary).
- I/O: `none`/`mq-deadline` scheduler, larger read-ahead and queue depth.
- VM: lower swappiness, scheduler/top-app boost.

NORMAL reverses every one of these.

## Build
The flashable zip is built by GitHub Actions ([`.github/workflows/package.yml`](.github/workflows/package.yml)) —
push to `main` or run the workflow, and it packages `a31-booster.zip` and attaches it to a release.

## License
MIT — see [LICENSE](LICENSE).
