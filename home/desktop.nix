{ config, unstablePkgs, stablePkgs, modulesPath, lib, ... }:
let
  onePasswordAgent = "${config.home.homeDirectory}/.1password/agent.sock";
in
{
  # Use the 1Password SSH agent in the graphical session. Shells pick their
  # agent in initContent below so SSH logins keep their forwarded agent.
  systemd.user.sessionVariables.SSH_AUTH_SOCK = onePasswordAgent;

  programs.zsh.initContent = ''
    [[ -z $SSH_CONNECTION ]] && export SSH_AUTH_SOCK=${onePasswordAgent}

    # tmux and herdr panes outlive the client that started them. Follow the agent
    # of the most recently attached client, or 1Password once that one is gone.
    _agent_sock_use() {
      if [[ -S $1 ]]; then
        export SSH_AUTH_SOCK=$1
      else
        export SSH_AUTH_SOCK=${onePasswordAgent}
      fi
    }

    if [[ -n $TMUX ]]; then
      # tmux stores the attaching client's SSH_AUTH_SOCK (update-environment)
      _tmux_refresh_agent() {
        local line=$(tmux show-environment SSH_AUTH_SOCK 2>/dev/null)
        [[ $line == SSH_AUTH_SOCK=* ]] && _agent_sock_use ''${line#SSH_AUTH_SOCK=}
      }
      precmd_functions+=(_tmux_refresh_agent)
    fi

    # herdr has no update-environment, so attaching clients record their agent
    _herdr_agent_file=''${XDG_RUNTIME_DIR:-$HOME/.cache}/herdr-ssh-auth-sock
    if [[ -n $HERDR_ENV ]]; then
      _herdr_refresh_agent() {
        [[ -r $_herdr_agent_file ]] && _agent_sock_use "$(<$_herdr_agent_file)"
      }
      precmd_functions+=(_herdr_refresh_agent)
    else
      herdr() {
        [[ -n $SSH_AUTH_SOCK ]] && print -r -- $SSH_AUTH_SOCK >| $_herdr_agent_file
        command herdr "$@"
      }
    fi
  '';

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
