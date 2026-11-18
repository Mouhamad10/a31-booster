# Changelog

## v1.1.1
- Fix (found by live on-device test on the A31): NORMAL left MediaTek PPM **disabled** because
  `/proc/ppm/enabled` reads back as a sentence but only accepts `0|1` on write — NORMAL now forces
  `ppm=1` / `gpu_dvfs=1` instead of replaying the snapshotted string.
- TURBO: guard the optional `gpufreqv2` node so it no longer prints a "can't create" error on A31.

## v1.1.0
- TURBO now **snapshots every node it changes** and NORMAL restores the exact previous values.
- Added a **52 °C battery-temp cutoff**: TURBO refuses to start (and won't disable thermal) when hot.
- Explicit CPU policy0 (A55) + policy6 (A75) handling; proper GED GPU path
  (`/sys/kernel/ged/hal/custom_boost_gpu_freq`, released with -1 on NORMAL).

## v1.0.0
- First release for Galaxy A31 (SM-A315F, MT6768).
- On-demand TURBO (CPU + Mali-G52 GPU + I/O max, thermal relaxed) via Magisk Action button.
- Quick Settings / window background blur + smoother-UI props at boot.
