{ stablePkgs, unstablePkgs, lib ? stablePkgs.lib }:

with stablePkgs; [
  unstablePkgs.btop
  bottom
  coreutils
  drill
  dua
  duf
  dust
  fd
  git
  htop
  iperf3
  jq
  mc
  mosh
  nmap
  smartmontools
  tree
  unzip
  vim
  watch
  wget
  wireguard-tools
]
