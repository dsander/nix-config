{ pkgs, lib, ... }:
# `clip`: copy stdin (or the given files) to the system clipboard on every host.
#
# Picks the backend at runtime:
#   SSH session -> OSC 52, so the text lands on the machine in front of you
#   macOS       -> pbcopy
#   WSL         -> clip.exe (fed UTF-16LE, otherwise non-ASCII gets mangled)
#   Wayland     -> wl-copy
#   X11         -> xclip / xsel
#   otherwise   -> OSC 52
# Inside tmux OSC 52 goes through `tmux load-buffer -w`, which also fills the
# tmux buffer and lets tmux talk to the outer terminal.
let
  clip = pkgs.writeShellApplication {
    name = "clip";
    runtimeInputs = [ pkgs.coreutils pkgs.iconv ];
    text = ''
      osc52() {
        if [ -n "''${TMUX:-}" ]; then
          tmux load-buffer -w -
        else
          printf '\033]52;c;%s\a' "$(base64 | tr -d '\n')" > /dev/tty
        fi
      }

      is_wsl() {
        [ -n "''${WSL_DISTRO_NAME:-}" ] || [ -e /proc/sys/fs/binfmt_misc/WSLInterop ]
      }

      copy() {
        if [ -n "''${SSH_CONNECTION:-}''${SSH_TTY:-}" ]; then
          osc52
        elif [ "$(uname -s)" = Darwin ]; then
          pbcopy
        elif is_wsl; then
          iconv -f UTF-8 -t UTF-16LE | "$(command -v clip.exe || echo /mnt/c/Windows/System32/clip.exe)"
        ${lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
          elif [ -n "''${WAYLAND_DISPLAY:-}" ]; then
            ${pkgs.wl-clipboard}/bin/wl-copy
        ''}
        elif [ -n "''${DISPLAY:-}" ] && command -v xclip >/dev/null; then
          xclip -selection clipboard
        elif [ -n "''${DISPLAY:-}" ] && command -v xsel >/dev/null; then
          xsel --clipboard --input
        else
          osc52
        fi
      }

      cat "$@" | copy
    '';
  };
in
{
  home.packages = [ clip ];
}
