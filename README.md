# A31 Booster — Turbo + Blur (Magisk module)

A **Magisk module** for the Samsung Galaxy A31 (**SM-A315F / MT6768**, Mali-G52) that does two
unrelated things, both toggleable, both safe to remove:

1. **Turbo** — an on-demand, one-tap *maximum performance* mode (CPU + GPU + I/O) with a thermal
   safety guard, triggered from Magisk's **Action** button.
2. **Blur / lighter UI** — boot-time props that enable AOSP background blur and a few smoothness
   tweaks (useful on AOSP-based ROMs and OneOS guests; One UI's own QS blur is Samsung-controlled).

> Self-contained README: a person or an AI assistant with no prior context should be able to
> understand, rebuild, and extend this module from it.

---

## How it works

### Turbo (`scripts/turbo.sh`, triggered by `action.sh`)
Pressing **Action** in the Magisk app toggles Turbo. On enable:

- **Safety first:** aborts if `battery/temp` ≥ **52.0 °C** (temp is in tenths of a degree, so the
  check is `>= 520`).
- **Snapshot:** every node it is about to change is saved under `/data/adb/a31booster.state` so
  **Normal** can restore the exact previous values.
- **CPU:** governor → `performance` and `scaling_min_freq = cpuinfo_max_freq` on both clusters —
  `policy0` (6× Cortex-A55) and `policy6` (2× Cortex-A75) — i.e. clock locked at max.
- **MTK PPM/PBM power cap:** `echo 0 > /proc/ppm/enabled` (removes the power-budget throttle).
- **GPU (Mali-G52 via MTK GED):** DVFS off (`ged/parameters/gpu_dvfs_enable=0`), floor to the top
  OPP (`custom_boost_gpu_freq=0`, `gpufreq_opp_freq=0`, `gpufreqv2/fix_target_opp_index`).
- **Thermal:** temporarily relaxed (`stop thermald`/`mtk_thermal`, thermal zones → `disabled`).
  The 52 °C start-guard above is what keeps this safe.
- **I/O:** best available scheduler (`none`/`mq-deadline`/`kyber`), larger `read_ahead_kb` /
  `nr_requests`, `swappiness=10`.

### Normal (`scripts/normal.sh`)
Restores the snapshot and re-enables thermal protection. **Key fix (v1.1):** `/proc/ppm/enabled` and
`ged/gpu_dvfs_enable` *read back* as a sentence/flag but only accept `0|1` on **write**. Replaying a
snapshotted string silently writes 0 and left the phone throttled. Normal therefore **force-writes
the known-good `1`** instead of replaying the snapshot for those two nodes, then restores CPU
governor/min from the snapshot, restarts `thermald`/`mtk_thermal`, re-enables thermal zones,
`swappiness=60`, and deletes the state dir.

### Blur / lighter UI (`system.prop`, applied by Magisk `resetprop` at boot)
- `ro.surface_flinger.supports_background_blur=1`, `persist.sys.sf.disable_blurs=0` → AOSP background
  blur (QS / window). On stock One UI the QS blur is Samsung-controlled and these have no effect;
  they take effect on AOSP ROMs and OneOS guests.
- `debug.hwui.use_buffer_age=true`, `persist.sys.usap_pool_enabled=true`,
  `ro.config.avoid_gfx_accel=false` → lighter/smoother rendering.

---

## Files

```
module.prop        # id=a31booster, name "A31 Booster (Turbo + Blur)", author Mouhamad10
system.prop        # boot-time props (blur + smoothness) — applied by Magisk
action.sh          # Magisk Action button -> toggles Turbo (uses a .turbo_on flag file)
scripts/turbo.sh   # apply max performance (with snapshot + 52C guard)
scripts/normal.sh  # restore snapshot + re-enable thermal (+ the ppm/gpu force-1 fix)
service.sh         # late_start hook
customize.sh       # install-time setup
update.json        # Magisk in-app updates -> points at the GitHub release
CHANGELOG.md
.github/workflows/package.yml   # CI: zips the module and attaches it to a release
```

## Install & use
1. Flash the latest **`a31-booster.zip`** from *Releases* in the Magisk app (or TWRP).
2. Reboot.
3. Open **Magisk → Modules → A31 Booster → Action** to toggle **Turbo** on/off. Toggle it off (or
   just reboot) to return to Normal; thermal protection is always restored on Normal.

Requirements: rooted A31 (Magisk), MT6768 nodes as listed (paths degrade gracefully if absent).

## Build / release
`.github/workflows/package.yml` zips the module and publishes it as `a31-booster.zip` (+ a versioned
copy and `SHA256SUMS.txt`) on a tag. Current: **v1.1.1** (versionCode 3). `update.json` lets Magisk
offer in-app updates.

## Safety notes
- Turbo disables thermal throttling while active — the 52 °C start-guard prevents enabling it when
  already hot, but don't run heavy loads on Turbo for long. Normal restores full thermal protection.
- Everything is snapshot/restore based and the module is removable; nothing is written to firmware.

## Future ideas
- A periodic watchdog that auto-drops Turbo if the battery crosses a hotter threshold while active.
- Per-app Turbo profiles; a Quick Settings tile toggle.
- Expose the GPU/thermal tunables as module options (`edit-options`-style).
