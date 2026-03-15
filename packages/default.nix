{ stablePkgs, unstablePkgs, lib ? stablePkgs.lib }:

let
  core = import ./groups/core.nix { inherit stablePkgs unstablePkgs lib; };
  development = import ./groups/development.nix { inherit stablePkgs unstablePkgs lib; };
  desktopBase = import ./groups/desktop-base.nix { inherit stablePkgs unstablePkgs lib; };
  desktopPlasma = import ./groups/desktop-plasma.nix { inherit stablePkgs unstablePkgs lib; };
  desktopNiri = import ./groups/desktop-niri.nix { inherit stablePkgs unstablePkgs lib; };
  darwinBase = import ./groups/darwin-base.nix { inherit stablePkgs unstablePkgs lib; };

  groups = {
    inherit core development desktopBase desktopPlasma desktopNiri darwinBase;
  };
in
groups
  // {
  combine = names: lib.unique (lib.concatMap (name: groups.${name}) names);
}
