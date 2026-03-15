{ stablePkgs, unstablePkgs, lib ? stablePkgs.lib }:

lib.unique (
  (import ./development.nix { inherit stablePkgs unstablePkgs lib; })
  ++
  (with stablePkgs; [
    intel-gpu-tools
    libva-utils
    intel-media-driver
    jellyfin-ffmpeg
    hddtemp
    synergy
  ])
)
