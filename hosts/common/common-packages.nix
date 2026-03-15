{ stablePkgs, unstablePkgs, lib ? stablePkgs.lib }:

(import ../../packages { inherit stablePkgs unstablePkgs lib; }).development
