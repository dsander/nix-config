{ unstablePkgs, stablePkgs, modulesPath, lib, ... }:
{

  home.file = {
    paru = {
      source = ./config/paru/paru.conf;
      target = ".config/paru/paru.conf";
    };
    ghotty = {
      source = ./config/ghostty/config;
      target = ".config/ghostty/config";
    };
  };

}

