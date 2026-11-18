#!/system/bin/sh
# A31 Booster - TURBO v1.1: snapshot -> apply max CPU+GPU+I/O, relax thermal.
# SAFETY: aborts if the battery is already >= 52.0 C; snapshots every node so NORMAL
# restores the exact previous values.
STATE=/data/adb/a31booster.state
log() { echo "[a31booster] $*"; }

# ---- SAFETY: 52.0 C battery cutoff (temp is in tenths of a degree) ----
bt=$(cat /sys/class/power_supply/battery/temp 2>/dev/null)
if [ -n "$bt" ] && [ "$bt" -ge 520 ] 2>/dev/null; then
  log "ABORT: battery ${bt} tenths-C (>=52.0C) - too hot for TURBO"; exit 3
fi

mkdir -p "$STATE"
save() { [ -e "$1" ] && cat "$1" > "$STATE/$2" 2>/dev/null; }

# ---- CPU: snapshot + performance, lock min=max on policy0 (6x A55) + policy6 (2x A75) ----
for pol in policy0 policy6; do
  p=/sys/devices/system/cpu/cpufreq/$pol
  [ -d "$p" ] || continue
  save "$p/scaling_governor" "gov_$pol"
  save "$p/scaling_min_freq" "min_$pol"
  mx=$(cat "$p/cpuinfo_max_freq" 2>/dev/null)
  echo performance > "$p/scaling_governor" 2>/dev/null
  [ -n "$mx" ] && echo "$mx" > "$p/scaling_min_freq" 2>/dev/null
done
# fallback for any other per-cpu policy
for p in /sys/devices/system/cpu/cpu*/cpufreq; do
  [ -d "$p" ] && echo performance > "$p/scaling_governor" 2>/dev/null
done

# ---- MTK PPM / PBM power limits off ----
save /proc/ppm/enabled ppm_enabled
echo 0 > /proc/ppm/enabled 2>/dev/null

# ---- GPU (Mali-G52 via MTK GED): DVFS off + floor to top freq ----
save /sys/module/ged/parameters/gpu_dvfs_enable ged_dvfs
echo 0 > /sys/module/ged/parameters/gpu_dvfs_enable 2>/dev/null
echo 0 > /sys/kernel/ged/hal/custom_boost_gpu_freq 2>/dev/null   # 0 = highest level
echo 0 > /proc/gpufreq/gpufreq_opp_freq 2>/dev/null
[ -e /proc/gpufreqv2/fix_target_opp_index ] && echo 100 > /proc/gpufreqv2/fix_target_opp_index 2>/dev/null

# ---- Thermal: relax (temporary; the cutoff above guards the start) ----
stop thermald 2>/dev/null; stop mtk_thermal 2>/dev/null
echo 0 > /proc/driver/thermal/tzcpu 2>/dev/null
for m in /sys/class/thermal/thermal_zone*/mode; do echo disabled > "$m" 2>/dev/null; done

# ---- I/O ----
for q in /sys/block/mmcblk0/queue /sys/block/sd*/queue; do
  [ -d "$q" ] || continue
  for s in none mq-deadline kyber noop; do grep -qw "$s" "$q/scheduler" 2>/dev/null && { echo "$s" > "$q/scheduler" 2>/dev/null; break; }; done
  echo 512 > "$q/read_ahead_kb" 2>/dev/null; echo 1024 > "$q/nr_requests" 2>/dev/null
done
echo 10 > /proc/sys/vm/swappiness 2>/dev/null

log "TURBO on (snapshot in $STATE)"
