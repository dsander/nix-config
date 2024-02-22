# nix-macos-testing


## Testing flake on a ubuntu VM

```
# Manually edit the config file and make the home directroy writable
limactl create --mount-type 9p --arch=x86_64 template://ubuntu-lts
limactl shell ubuntu-lts
sudo apt-get install -y make
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --extra-conf "warn-dirty = false"
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
make
```

## Getting started on a new Mac

Give full disk access to Terminal.

Install homebrew
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Install nix
```
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```


Clone the repo

```
git clone https://github.com/dsander/nix-testing
cd nix-testing
eval "$(/opt/homebrew/bin/brew shellenv)"
make
```

Clean the dock

```
defaults write com.apple.dock persistent-apps -array && killall Dock
```

Sync Thunderbird Profile

```
rsync -av --progress  --delete ~/Library/Thunderbird/ thorax.local:Library/Thunderbird/
```

Sublime
```
rsync -av --progress --delete  ~/Library/Application\ Support/Sublime\ Text/ thorax.local:"Library/Application\ Support/Sublime\ Text/"
```
Then delete Package (but User) and installed packages https://packagecontrol.io/docs/syncing

iTerm

To apply go to `Settings` -> `General` -> `Preferences` and load from
`/Users/dominik/.config/iterm2`

Import uBlock filters from `data/ublock-static-filters.txt`

Import Tampermonkey scripts from Google Drive

## Nix being nix

Looks like nobody uses it like this, we have home-manager and still use asdf to manage node and ruby
version. This does not really work with how Nix installs neovim and the nodejs integration. `vim
$(which nvim)` does wrap the binary and adjusts the PATH but appends the nodejs path, this causes
nvim to fail if there is a non working `node` binary anywhere "before" the nix store node path ...
`node_host_prog` does NOT overwrite the node path, it only is some sort of binary neovim still tries
to execute node, this fails if asdf is installed but no global node binary is configured ...

Soo just do `asdf global nodejs 20.11.1` and be done with it, very "immutable" ... maybe we can
somehow manually prepend the nixpgs node path in the neovim config?

Why does this suffix and not postfix the nix store path?!? https://github.com/NixOS/nixpkgs/blob/5eeded8e3518579daa13887297efa79f5be74b41/pkgs/applications/editors/neovim/utils.nix#L98

## Proxmox NixOS research / resources

As per usual there isn't a working guide out there, what we want to do

* Auto deploy new LXC/VMs based on Nix
* Update their configuration
* Maybe / potentially tie this into our existing Ansible repository because there will always be non
  nix systems

### Getting an LXC working (ish)

nixos-rebuild switch doesn't work
https://hydra.nixos.org/job/nixos/trunk-combined/nixos.proxmoxLXC.x86_64-linux#tabs-status
https://nixos.wiki/wiki/Proxmox_Virtual_Environment
https://mtlynch.io/notes/nixos-proxmox/
Maybe with this?
https://hydra.nixos.org/job/nixos/release-23.11/nixos.proxmoxLXC.x86_64-linux
https://discourse.nixos.org/t/proxmox-lxc-systemd-networkd-container-image/38586/2
Same error:
```
WARNING: /boot being on a different filesystem not supported by init-script-builder.sh
'/nix/store/88rz72frvbwlps025d6jxwmgih9d459z-system-path/bin/busctl --json=short call org.freedesktop.systemd1 /org/freedesktop/systemd1 org.freedesktop.systemd1.Manager ListUnitsByPatterns asas 0 0' exited with value 1 at /nix/store/cm6cf6b6k2sbny490k5h92snnv4my947-nixos-system-unnamed-23.11.4195.809cca784b9f/bin/switch-to-configuration line 145.
warning: error(s) occurred while switching to the new configuration
```
Outdated?
https://discourse.nixos.org/t/how-to-generate-a-nixos-tarball-lxc-template-with-all-dependencies-not-just-runtime/25444



### Links

https://github.com/NixOS/nixpkgs/blob/master/nixos/release.nix

https://github.com/search?q=proxmoxLXC+language%3ANix&type=code&l=Nix&p=1
https://github.com/lpchaim/homelab/blob/main/terraform-nix/flake.nix
https://github.com/otakulan/infrastructure/blob/e599fed10c62bb219cae4b7041f9669fd5675b3f/otakudc/hardware.nix#L8
https://github.com/gensokyo-zone/infrastructure/blob/a0ae2325d69fe3d37b8fc6738a4b39298a36a4c2/systems/reimu/nixos.nix#L18
https://github.com/abehidek/nix-config/blob/3005bf870ad5730e2253233f548df2e0b1d01226/systems/portainer/default.nix#L9
