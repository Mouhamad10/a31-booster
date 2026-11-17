#!/system/bin/sh
# A31 Booster - TURBO: push CPU + Mali-G52 GPU + I/O to maximum, relax thermal.
# WARNING: this disables thermal throttling while ON. The phone WILL get hot.
# Use it in bursts (gaming, heavy tasks) and toggle it back OFF.
log() { echo "[a31booster] $*"; }

# ---- CPU: performance governor, lock min = max ----
for p in /sys/devices/system/cpu/cpu*/cpufreq; do
  [ -d "$p" ] || continue
  mx=$(cat "$p/cpuinfo_max_freq" 2>/dev/null)
  echo performance > "$p/scaling_governor" 2>/dev/null
  [ -n "$mx" ] && echo "$mx" > "$p/scaling_min_freq" 2>/dev/null
done

# ---- MediaTek PPM / power limits off (let all cores run) ----
echo 0 > /proc/ppm/enabled 2>/dev/null
echo 0 > /sys/devices/system/cpu/cpuhotplug/enabled 2>/dev/null

# ---- GPU (Mali-G52 MC2 via MTK GED) - try the known MT6768 paths ----
echo 0 > /proc/gpufreq/gpufreq_opp_freq 2>/dev/null          # 0 = top OPP on many MTK
echo 100 > /proc/gpufreqv2/fix_target_opp_index 2>/dev/null
echo 0 > /sys/module/ged/parameters/gpu_dvfs_enable 2>/dev/null   # 0 = DVFS off -> stays high
echo 1 > /sys/kernel/ged/hal/gpu_boost_level 2>/dev/null
for g in /sys/class/devfreq/*gpu*/governor /sys/class/kgsl/kgsl-3d0/devfreq/governor; do
  [ -e "$g" ] && echo performance > "$g" 2>/dev/null
done

# ---- Thermal: relax (TEMPORARY) ----
stop thermald 2>/dev/null
stop mtk_thermal 2>/dev/null
echo 0 > /proc/driver/thermal/tzcpu 2>/dev/null
for m in /sys/class/thermal/thermal_zone*/mode; do echo disabled > "$m" 2>/dev/null; done

# ---- I/O: deeper queues ----
for q in /sys/block/mmcblk0/queue /sys/block/sd*/queue /sys/block/dm-*/queue; do
  [ -d "$q" ] || continue
  for s in none noop mq-deadline kyber; do
    grep -qw "$s" "$q/scheduler" 2>/dev/null && { echo "$s" > "$q/scheduler" 2>/dev/null; break; }
  done
  echo 512  > "$q/read_ahead_kb" 2>/dev/null
  echo 1024 > "$q/nr_requests"   2>/dev/null
done

# ---- VM / scheduler toward foreground ----
echo 10 > /proc/sys/vm/swappiness 2>/dev/null
echo 1  > /proc/sys/kernel/sched_boost 2>/dev/null
echo 1  > /dev/stune/top-app/schedtune.boost 2>/dev/null

log "TURBO on"
