# Changelog

## v1.1.0
- TURBO now **snapshots every node it changes** and NORMAL restores the exact previous values.
- Added a **52 °C battery-temp cutoff**: TURBO refuses to start (and won't disable thermal) when hot.
- Explicit CPU policy0 (A55) + policy6 (A75) handling; proper GED GPU path
  (`/sys/kernel/ged/hal/custom_boost_gpu_freq`, released with -1 on NORMAL).

## v1.0.0
- First release for Galaxy A31 (SM-A315F, MT6768).
- On-demand TURBO (CPU + Mali-G52 GPU + I/O max, thermal relaxed) via Magisk Action button.
- Quick Settings / window background blur + smoother-UI props at boot.
