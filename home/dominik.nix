{ config, pkgs, lib, unstablePkgs, ... }:
{
  home.stateVersion = "23.05";

  # list of programs
  # https://mipmip.github.io/home-manager-option-search

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
  };

  programs.git = {
    enable = true;
    delta.enable = true;
    lfs.enable = true;
    userEmail = "git@dsander.de";
    userName = "Dominik Sander";
    extraConfig = {
      push.default = "simple";
      fetch.prune = true;
      rebase.autoStash = true;
      mrge.ff = "only";
      init.templateDir = "~/.git_template";
      # color.ui = true; # We probably want the default of auto
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

  # We need this for the env setup, but can't do it at the moment because dot files are managed by rcm
  # Scratch that even with this enabled /run/current-system/sw/bin isn't in the PATH, this is how it always treats us :/

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    initExtra = (builtins.readFile ./mac-dot-zshrc);
  };

  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    duf
  ];
}
