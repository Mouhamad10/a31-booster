#!/system/bin/sh
# Magisk "Action" button -> toggle TURBO on/off.
MODDIR=${0%/*}
FLAG="$MODDIR/.turbo_on"
if [ -f "$FLAG" ]; then
  sh "$MODDIR/scripts/normal.sh"
  rm -f "$FLAG"
  echo "A31 Booster: TURBO OFF - balanced power + thermal protection restored."
else
  sh "$MODDIR/scripts/turbo.sh"
  touch "$FLAG"
  echo "A31 Booster: TURBO ON - max CPU/GPU, thermal throttle OFF. Watch the heat!"
fi
