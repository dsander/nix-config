{ config, pkgs, lib, unstablePkgs, ... }:
let
  systemSpecific =
    if pkgs.stdenv.isDarwin then
      ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
        # This seems to be necessary now to install psych (we also need libyaml)
        export CPATH=$(brew --prefix)/include
        export LIBRARY_PATH=$(brew --prefix)/lib

        # enable colored output from ls, etc. on FreeBSD-based systems
        export CLICOLOR=1

        zstyle ":completion:*" list-colors “''${(s.:.)LS_COLORS}”

        zinit ice wait pick'init.zsh' compile'*.zsh' lucid
        zinit load laggardkernel/zsh-iterm2

      ''
    else
      ''
        zinit ice atclone"dircolors -b LS_COLORS > clrs.zsh" \
            atpull'%atclone' pick"clrs.zsh" nocompile'!' \
            atload'zstyle ":completion:*" list-colors “''${(s.:.)LS_COLORS}”'
        zinit load trapd00r/LS_COLORS
      '';
in

{
  home.packages = with pkgs; [
    asdf-vm
    lua
  ];

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    history = {
      extended = true;
      save = 100000000;
      size = 100000000;
      share = true;
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
    };
    localVariables = {
      POWERLEVEL9K_LEFT_PROMPT_ELEMENTS = [
        "context" # user@hostname
        "dir" # current directory
        "vcs" # git status
      ];
      POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS = [
        "status" # exit code of the last command
        "command_execution_time" # duration of the last command
        "terraform" # terraform workspace
      ];
      POWERLEVEL9K_MODE = "nerdfont-complete";
      POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING = false;
      POWERLEVEL9K_VCS_GIT_ICON = "";
      POWERLEVEL9K_HOME_ICON = "";
      POWERLEVEL9K_HOME_SUB_ICON = "";
      POWERLEVEL9K_ETC_ICON = "";
    };
    shellAliases = {
      diffscreens = "cd ~/Dropbox/Screenshots && compare - density 300 \"`ls -tr | tail -2|head -1`\" \"`ls -tr | tail -1`\" - compose src diff.png; open diff.png";
      mux = "tmuxinator";
      nhssh = "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
      nhscp = "scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
      cleanup = "find . -name '*.DS_Store' -type f -ls -delete";
      vim = "nvim";
      dokku = "bash ~/code/infrastructure/dokku/contrib/dokku_client.sh";
    };
    initExtraFirst = ''
      # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
      # Initialization code that may require console input (password prompts, [y/n]
      # confirmations, etc.) must go above this block, everything else may go below.
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';

    initExtra = ''
      setopt incappendhistory
      setopt promptsubst

      # handy keybindings
      bindkey "^s" beginning-of-line
      bindkey "^e" end-of-line
      bindkey "^f" forward-char
      bindkey "^b" backward-char
      bindkey "^k" kill-line
      bindkey "^d" delete-char
      bindkey "^p" history-search-backward
      bindkey "^n" history-search-forward
      bindkey "^y" accept-and-hold
      bindkey "^w" backward-kill-word
      bindkey "^u" backward-kill-line
      bindkey "\e[3~" delete-char

      # Use vim keys in tab complete menu:
      zmodload -i zsh/complist
      bindkey -M menuselect 'h' vi-backward-char
      bindkey -M menuselect 'k' vi-up-line-or-history
      bindkey -M menuselect 'l' vi-forward-char
      bindkey -M menuselect 'j' vi-down-line-or-history

      # Open current command in Vim
      autoload -z edit-command-line
      zle -N edit-command-line
      bindkey "^x^e" edit-command-line

      # makes color constants available
      autoload -U colors
      colors
    '' + (builtins.readFile ./config/zshrc) + systemSpecific;
    plugins = [{
      name = "zinit";
      file = "zinit.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "zdharma-continuum";
        repo = "zinit";
        rev = "v3.13.1";
        hash = "sha256-AiYK1pRFD4CGvBcQg9QwgFjc5Z564TVlWW0MzxoxdWU=";
      };
    }];
  };
}
