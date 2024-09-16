{ unstablePkgs, stablePkgs, modulesPath, ... }:
let
  darwinPathOverrides = [
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    "/Applications/Postgres.app/Contents/Versions/latest/bin"
  ];
  pathOverrides = stablePkgs.lib.lists.optionals stablePkgs.stdenv.isDarwin darwinPathOverrides ++ [
    "$HOME/.cargo/bin"
    "$HOME/bin"
  ];
in
{
  imports = [
    ./programs/zsh.nix
  ];
  home.stateVersion = "24.05";
  disabledModules = [ "${modulesPath}/services/syncthing.nix" ];

  # list of programs
  # https://mipmip.github.io/home-manager-option-search

  home.sessionVariables = {
    EDITOR = "nvim";
    # This breaks vim in non tmux terminal on WSL
    # TERM = "screen-256color";
    DEFAULT_USER = "dominik";
    BUNDLER_EDITOR = "nvim";
    GIT_EDITOR = "nvim";
    COMPOSE_MENU = "0";
  };
  home.sessionPath = pathOverrides;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = false; # If we enable this, remove the junegunn/fzf plugins
    tmux.enableShellIntegration = true;
    package = unstablePkgs.fzf;
  };

  programs.gh = {
    enable = true;
  };

  programs.ripgrep = {
    enable = true;
    package = unstablePkgs.ripgrep;
    arguments = [
      "--max-columns=5000"
      "--max-columns-preview"
      "--type-add"
      "ruby:*.{haml,feature,scss,coffee}*"
      "--smart-case"
      "--glob=!vendor"
      "--glob=!log"
      "--glob=!tmp"
      "--glob=!doc"
      "--glob=!coverage"
      "--glob=!.cargo"
      "--glob=!.git"
      "--hidden"
    ];
  };

  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = { max-line-length = 2048; };
    };
    lfs.enable = true;
    userEmail = "git@dsander.de";
    userName = "Dominik Sander";
    extraConfig = {
      push.default = "simple";
      fetch.prune = true;
      merge.ff = "only";
      init.templateDir = "~/.git_template";
      # color.ui = true; # We probably want the default of auto
      init.defaultBranch = "main";
      merge.conflictstyle = "zdiff3";
      rebase.autosquash = true;
      commit.verbose = true;
      rerere.enabled = true;
      diff.algorithm = "histogram";
      # transfer.fsckobjects = true;
      # fetch.fsckobjects = true;
      # receive.fsckObjects = true;
      status.submoduleSummary = true;
      diff.submodule = "log";
      diff.ansible-vault = {
        textconv = "f() { ansible-vault view \"$1\" 2>/dev/null || cat \"$1\"; }; f";
        cachetextconv = false;
      };
      rebase.updateRefs = true;
      url = {
        "ssh://git@github.com/" = {
          pushInsteadOf = "https://github.com/";
        };
        "ssh://git@gitlab.com/" = {
          pushInsteadOf = "https://gitlab.com/";
        };
        "ssh://git@gitlab.office.flavoursys.com/" = {
          pushInsteadOf = "https://gitlab.office.flavoursys.com/";
        };
      };
    };
    aliases = {
      co = "checkout";
      ec = "config --global -e";
      up = "!git pull --rebase --prune $@ && git submodule update --init --recursive";
      cob = "checkout -b";
      cm = "!git add -A && git commit -m";
      save = "!git add -A && git commit -m 'SAVEPOINT'";
      wip = "!git add -u && git commit -m 'WIP'";
      undo = "reset HEAD~1 --mixed";
      amend = "commit -a --amend";
      wipe = "!git add -A && git commit -qm 'WIPE SAVEPOINT' && git reset HEAD~1 --hard";
      bclean = "!f() { git branch --merged \${1-master} | grep -v \" \${1-master}$\" | xargs -r git branch -d; }; f";
      bdone = "!f() { git checkout \${1-master} && git up && git bclean \${1-master}; }; f";
      wdiff = "diff --color-words";
      lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
      dc = "diff --cached";
      pushb = "!git push --set-upstream origin `git rev-parse --abbrev-ref HEAD`";
      branch-history = "for-each-ref --sort=committerdate refs/heads/ --format='%(color: yellow)%(committerdate:short) %(color: cyan)%(refname:short)  %(color: reset)%(subject)'";
      du = "!git diff @{u}";
    };
    ignores = [
      ".DS_Store"
      "*.sw[nop]"
      ".bundle"
      ".byebug_history"
      ".env"
      "db/*.sqlite3"
      "log/*.log"
      "rerun.txt"
      "tags"
      "!tags/"
      "tmp/**/*"
      "!tmp/cache/.keep"
      "*.pyc"
      ".project-notes"
    ];
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # nvim plugin providers
    withNodeJs = true;
    withRuby = true;
    withPython3 = true;
    extraConfig = ''
      set runtimepath+=~/.vim,~/.vim/after
      set packpath+=~/.vim
      source ~/.vimrc
    '';
  };

  programs.tmux = {
    enable = true;
    extraConfig = (builtins.readFile ./config/tmux.conf);
  };

  programs.atuin = {
    enable = true;
    package = unstablePkgs.atuin;
    settings = {
      # This should be more efficient, lets try to learn it
      enter_accept = true;
      filter_mode_shell_up_key_binding = "session";
      sync = {
        records = true;
      };
    };
  };

  home.file = {
    # hammerspoon = lib.mkIf pkgs.stdenvNoCC.isDarwin {
    #   source = ./hammerspoon;
    #   target = ".hammerspoon";
    #   recursive = true;
    # };
    vim = {
      source = ./config/vim;
      target = ".vim";
      recursive = true;
    };
    vimrc = {
      source = ./config/vimrc;
      target = ".vimrc";
    };
    pgclirc = {
      source = ./config/pgclirc;
      target = ".pgclirc";
    };
    # npmrc = {
    #   text = ''
    #     prefix = ${config.home.sessionVariables.NODE_PATH};
    #   '';
    #   target = ".npmrc";
    # };
  };

  programs.lazygit = {
    enable = true;
    package = unstablePkgs.lazygit;
    settings = {
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format=\"vscode://file/{path}:{line}\"";
        };
      };
    };
  };

  services.syncthing =
    if stablePkgs.stdenv.isDarwin then
      { enable = false; }
    else {
      enable = true;
      tray.enable = true;
      package = unstablePkgs.syncthing;
    };

  programs.home-manager.enable = true;
}

