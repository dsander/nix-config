{ stablePkgs, unstablePkgs, lib ? stablePkgs.lib }:

with stablePkgs;
[
  exiftool
  unstablePkgs.lima
]
++ lib.optionals (stablePkgs.stdenv.hostPlatform.system == "aarch64-darwin") [
  unstablePkgs.macmon
]
