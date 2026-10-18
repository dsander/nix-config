intel_card=/dev/dri/by-path/pci-0000:00:02.0-card
if [ -e "$intel_card" ]; then
  export KWIN_DRM_DEVICES="$(readlink -f "$intel_card")"
fi
unset intel_card
