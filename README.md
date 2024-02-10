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
