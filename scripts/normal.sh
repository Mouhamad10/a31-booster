#!/system/bin/sh
# A31 Booster - NORMAL v1.1: restore the exact pre-TURBO values from the snapshot
# (falls back to sane defaults if no snapshot exists), re-enable thermal protection.
STATE=/data/adb/a31booster.state
log() { echo "[a31booster] $*"; }
rst() { [ -f "$STATE/$2" ] && cat "$STATE/$2" > "$1" 2>/dev/null; }

for pol in policy0 policy6; do
  p=/sys/devices/system/cpu/cpufreq/$pol
  [ -d "$p" ] || continue
  if [ -f "$STATE/gov_$pol" ]; then rst "$p/scaling_governor" "gov_$pol"; else
    for g in schedutil ondemand interactive; do grep -qw "$g" "$p/scaling_available_governors" 2>/dev/null && { echo "$g" > "$p/scaling_governor" 2>/dev/null; break; }; done
  fi
  if [ -f "$STATE/min_$pol" ]; then rst "$p/scaling_min_freq" "min_$pol"; else
    mn=$(cat "$p/cpuinfo_min_freq" 2>/dev/null); [ -n "$mn" ] && echo "$mn" > "$p/scaling_min_freq" 2>/dev/null
  fi
done

# /proc/ppm/enabled and gpu_dvfs_enable read back as sentences / flags but only accept 0|1 on
# write, so always force the known-good "on" value rather than replaying a snapshotted string.
echo 1 > /proc/ppm/enabled 2>/dev/null
echo 1 > /sys/module/ged/parameters/gpu_dvfs_enable 2>/dev/null
echo -1 > /sys/kernel/ged/hal/custom_boost_gpu_freq 2>/dev/null   # release GPU floor
echo -1 > /proc/gpufreq/gpufreq_opp_freq 2>/dev/null

start thermald 2>/dev/null; start mtk_thermal 2>/dev/null
echo 1 > /proc/driver/thermal/tzcpu 2>/dev/null
for m in /sys/class/thermal/thermal_zone*/mode; do echo enabled > "$m" 2>/dev/null; done
echo 60 > /proc/sys/vm/swappiness 2>/dev/null

rm -rf "$STATE" 2>/dev/null
log "restored normal (thermal protection back on)"
