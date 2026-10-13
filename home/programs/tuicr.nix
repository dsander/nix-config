{ stablePkgs, ... }:
{
  # dracula.toml references dracula.tmTheme next to it, so link the whole dir.
  xdg.configFile."tuicr/themes".source = stablePkgs.tuicr-dracula-themes;

  xdg.configFile."tuicr/config.toml".text = ''
    theme = "dracula"
  '';
}
