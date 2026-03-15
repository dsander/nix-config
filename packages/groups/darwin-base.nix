{ stablePkgs, unstablePkgs, lib ? stablePkgs.lib }:

with stablePkgs;
[
  exiftool
  unstablePkgs.lima
]
++ lib.optionals (stablePkgs.system == "aarch64-darwin") [
  unstablePkgs.macmon
]
