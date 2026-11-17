#!/system/bin/sh
# A31 Booster - NORMAL: restore balanced power + thermal protection.
log() { echo "[a31booster] $*"; }

# ---- CPU: back to a balanced governor, unlock min ----
for p in /sys/devices/system/cpu/cpu*/cpufreq; do
  [ -d "$p" ] || continue
  mn=$(cat "$p/cpuinfo_min_freq" 2>/dev/null)
  for g in schedutil ondemand interactive; do
    grep -qw "$g" "$p/scaling_available_governors" 2>/dev/null && { echo "$g" > "$p/scaling_governor" 2>/dev/null; break; }
  done
  [ -n "$mn" ] && echo "$mn" > "$p/scaling_min_freq" 2>/dev/null
done

# ---- MTK power management back on ----
echo 1 > /proc/ppm/enabled 2>/dev/null
echo 1 > /sys/devices/system/cpu/cpuhotplug/enabled 2>/dev/null

# ---- GPU DVFS back on ----
echo 1 > /sys/module/ged/parameters/gpu_dvfs_enable 2>/dev/null
echo 0 > /sys/kernel/ged/hal/gpu_boost_level 2>/dev/null

# ---- Thermal protection back on ----
start thermald 2>/dev/null
start mtk_thermal 2>/dev/null
echo 1 > /proc/driver/thermal/tzcpu 2>/dev/null
for m in /sys/class/thermal/thermal_zone*/mode; do echo enabled > "$m" 2>/dev/null; done

# ---- VM back to defaults ----
echo 60 > /proc/sys/vm/swappiness 2>/dev/null
echo 0  > /proc/sys/kernel/sched_boost 2>/dev/null
echo 0  > /dev/stune/top-app/schedtune.boost 2>/dev/null

log "restored normal"
