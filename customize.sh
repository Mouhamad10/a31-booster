#!/system/bin/sh
# A31 Booster install-time setup
ui_print " "
ui_print "  A31 Booster (Turbo + Blur)"
ui_print "  by Mouhamad10 - Galaxy A31 (SM-A315F, MT6768)"
ui_print " "

MODEL=$(getprop ro.product.model)
case "$MODEL" in
  *A315*) ui_print "- Detected $MODEL (A31) - OK" ;;
  *)      ui_print "! Device is $MODEL, not an A31." ;
          ui_print "! Installing anyway; some sysfs paths may differ." ;;
esac

ui_print "- Setting permissions"
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$MODPATH/scripts" 0 0 0755 0755
set_perm "$MODPATH/action.sh"  0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755

ui_print " "
ui_print "- Installed. Reboot, then:"
ui_print "  Magisk app > Modules > A31 Booster > Action"
ui_print "  to toggle TURBO (max performance) on/off."
ui_print "- Blur + smoother-UI props apply automatically on boot."
ui_print " "
