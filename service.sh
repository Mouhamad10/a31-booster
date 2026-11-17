#!/system/bin/sh
# Runs late_start service. Cosmetics come from system.prop; TURBO stays on-demand.
MODDIR=${0%/*}
# Always boot in NORMAL power state (clear any stale turbo flag from last session).
rm -f "$MODDIR/.turbo_on" 2>/dev/null
