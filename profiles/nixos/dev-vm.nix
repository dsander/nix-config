{ stablePkgs, unstablePkgs, lib, ... }:

let
  packageGroups = import ../../packages { inherit stablePkgs unstablePkgs lib; };
in
{
  environment.systemPackages = packageGroups.development;
}
