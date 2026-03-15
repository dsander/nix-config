{ stablePkgs, unstablePkgs, lib ? stablePkgs.lib }:

import ./desktop-base.nix { inherit stablePkgs unstablePkgs lib; }
