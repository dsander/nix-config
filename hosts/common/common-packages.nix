{ unstablePkgs, stablePkgs, ... }:

with stablePkgs; [
  ## unstable
  unstablePkgs.yt-dlp
  unstablePkgs.act
  unstablePkgs.rbw
  unstablePkgs._1password-cli
  unstablePkgs.rclone
  unstablePkgs.lazydocker
  unstablePkgs.pinentry-gtk2

  nodejs_22
  ## stable
  nixpkgs-fmt
  nil
  ansible
  ansible-lint
  sshpass
  asciinema
  unstablePkgs.btop
  # bitwarden-cli
  coreutils
  diffr # Modern Unix `diff`
  difftastic # Modern Unix `diff`
  dua # Modern Unix `du`
  duf # Modern Unix `df`
  du-dust # Modern Unix `du`
  # direnv # programs.direnv
  #docker
  drill
  du-dust
  dua
  duf
  entr # Modern Unix `watch`
  esptool
  ffmpeg
  # fira-code
  # fira-mono
  fd
  #fzf # programs.fzf
  git # programs.git
  gitflow
  unstablePkgs.git-absorb
  # gh
  # go
  gnused
  #htop # programs.htop
  htop
  bottom
  iperf3
  # hub
  # hugo
  # ipmitool
  # jetbrains-mono # font
  just
  jq
  mc
  mosh
  neofetch
  nmap
  # ripgrep # programs.ripgrep
  # skopeo
  smartmontools
  unstablePkgs.terraform
  unstablePkgs.opentofu
  unstablePkgs.opentofu-ls
  tree
  unzip
  watch
  wget
  wireguard-tools
  vim
  sshfs
  clang-tools # openscad formatting
  s3cmd
  awscli
  go
  golangci-lint

  unstablePkgs.gg-jj
  unstablePkgs.jjui
  unstablePkgs.jj-fzf
  unstablePkgs.lazyjj

  # requires nixpkgs.config.allowUnfree = true;
  # vscode-extensions.ms-vscode-remote.remote-ssh

  # lib.optionals boolean stdenv is darwin
  #mas # mac app store cli
]
