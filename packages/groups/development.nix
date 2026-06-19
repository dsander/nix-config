{ stablePkgs, unstablePkgs, lib ? stablePkgs.lib }:

lib.unique (
  (import ./core.nix { inherit stablePkgs unstablePkgs lib; })
  ++
  (with stablePkgs; [
    yt-dlp
    unstablePkgs.act
    unstablePkgs.rbw
    unstablePkgs._1password-cli
    unstablePkgs.rclone
    unstablePkgs.lazydocker
    unstablePkgs.pinentry-gtk2

    nodejs_22
    nixpkgs-fmt
    nil
    ansible
    ansible-lint
    sshpass
    asciinema
    diffr
    difftastic
    entr
    esptool
    ffmpeg
    gitflow
    unstablePkgs.git-absorb
    gnused
    just
    fastfetch
    unstablePkgs.terraform
    unstablePkgs.opentofu
    unstablePkgs.tofu-ls
    sshfs
    clang-tools
    s3cmd
    awscli2
    go
    golangci-lint
    git-filter-repo
    dive
    shellcheck
    unstablePkgs.jjui
    unstablePkgs.lazyjj
  ])
)
