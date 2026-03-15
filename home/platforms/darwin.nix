{ stablePkgs, lib, ... }:

lib.mkIf stablePkgs.stdenv.isDarwin {
  home.sessionPath = lib.mkAfter [
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    "/Applications/Postgres.app/Contents/Versions/latest/bin"
  ];

  targets.darwin.copyApps.enableChecks = false;

  services.syncthing.enable = lib.mkForce false;
  services.syncthing.tray.enable = lib.mkForce false;

  programs.ssh.extraConfig = ''
    Include ~/.orbstack/ssh/config
  '';
}
