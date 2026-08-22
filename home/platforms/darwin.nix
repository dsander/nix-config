{ stablePkgs, lib, ... }:

lib.mkIf stablePkgs.stdenv.isDarwin {
  home.sessionPath = lib.mkAfter [
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    "/Applications/Postgres.app/Contents/Versions/latest/bin"
  ];

  # Same theme as the Linux config (home/config/ghostty/config), which already
  # mirrors the "Hack Dracula" iTerm2 profile's palette/background/foreground.
  # Layer macOS-specific overrides on top: font-family/size to match iTerm's
  # profile, and macos-option-as-alt so Option acts as Esc+ like we set up in
  # iTerm (Ghostty config is single-value-last-wins, so these override the
  # shared file's font-family/font-size).
  home.file.".config/ghostty/config".text =
    builtins.readFile ../config/ghostty/config
    + ''

      # macOS overrides
      font-family = Hack Nerd Font Mono
      font-size = 12
      macos-option-as-alt = true
      macos-titlebar-style = tabs
      macos-icon = retro
    '';

  targets.darwin.copyApps.enableChecks = false;

  services.syncthing.enable = lib.mkForce false;
  services.syncthing.tray.enable = lib.mkForce false;

  programs.ssh.extraConfig = ''
    Include ~/.orbstack/ssh/config
  '';
}
