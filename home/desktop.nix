{ unstablePkgs, stablePkgs, modulesPath, lib, ... }:
{

  home.file = {
    paru = {
      source = ./config/paru/paru.conf;
      target = ".config/paru/paru.conf";
    };
    ghotty = {
      target = ".config/ghostty/config";
      text =
        builtins.readFile ./config/ghostty/config
        + ''

          # Linux overrides
          keybind = ctrl+arrow_left=previous_tab
          keybind = ctrl+arrow_right=next_tab
          keybind = ctrl+t=new_tab
        '';
    };
    electron = {
      source = ./config/electron-flags.conf;
      target = ".config/electron-flags.conf";
    };
  };

}
