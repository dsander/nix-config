#!/bin/bash

set -e
set -o pipefail
# set -x

OS=$(uname -s)
TARGET_OS="linux"
if [ "$OS" = "Darwin" ]; then
    TARGET_OS="macos"
elif [ "$OS" = "Linux" ] && [ -f "/etc/NIXOS" ]; then
    TARGET_OS="nixos"
fi

HOSTNAME=$(hostname | cut -d "." -f 1)
FLAKE_REF="path:."

resolve_target_type() {
  local target=$1

  if nix eval --raw "${FLAKE_REF}#darwinConfigurations.${target}.system.drvPath" >/dev/null 2>&1; then
    echo "darwin"
  elif nix eval --raw "${FLAKE_REF}#nixosConfigurations.${target}.config.system.build.toplevel.drvPath" >/dev/null 2>&1; then
    echo "nixos"
  elif nix eval --raw "${FLAKE_REF}#homeManagerConfigurations.${target}.activationPackage.drvPath" >/dev/null 2>&1; then
    echo "linux-home"
  else
    echo "Unknown target: ${target}" >&2
    return 1
  fi
}

target_drv_path() {
  local type=$1
  local target=$2

  case "$type" in
    "darwin")
      echo "${FLAKE_REF}#darwinConfigurations.${target}.system.drvPath"
      ;;
    "nixos")
      echo "${FLAKE_REF}#nixosConfigurations.${target}.config.system.build.toplevel.drvPath"
      ;;
    "linux-home")
      echo "${FLAKE_REF}#homeManagerConfigurations.${target}.activationPackage.drvPath"
      ;;
    *)
      echo "Unsupported target type: ${type}" >&2
      return 1
      ;;
  esac
}

target_build_attr() {
  local type=$1
  local target=$2

  case "$type" in
    "darwin")
      echo "${FLAKE_REF}#darwinConfigurations.${target}.system"
      ;;
    "nixos")
      echo "${FLAKE_REF}#nixosConfigurations.${target}.config.system.build.toplevel"
      ;;
    "linux-home")
      echo "${FLAKE_REF}#homeManagerConfigurations.${target}.activationPackage"
      ;;
    *)
      echo "Unsupported target type: ${type}" >&2
      return 1
      ;;
  esac
}

build_target() {
  local target=$1
  local trace=$2
  local type
  local build_attr

  type=$(resolve_target_type "$target")
  build_attr=$(target_build_attr "$type" "$target")

  case "$type" in
    "darwin")
      echo "Building darwin target ${target} ..."
      ;;
    "nixos")
      echo "Building NixOS target ${target} ..."
      ;;
    "linux-home")
      echo "Building standalone Home Manager target ${target} ..."
      ;;
  esac

  nix build "$build_attr" ${trace:+"$trace"}
}

check_target() {
  local target=$1
  local trace=$2
  local type
  local drv_attr
  local build_attr

  type=$(resolve_target_type "$target")
  drv_attr=$(target_drv_path "$type" "$target")
  build_attr=$(target_build_attr "$type" "$target")

  echo "Evaluating ${target} (${type}) ..."
  nix eval --raw "$drv_attr" ${trace:+"$trace"} >/dev/null

  echo "Dry-run building ${target} (${type}) ..."
  nix build "$build_attr" --dry-run ${trace:+"$trace"}
}

all_targets() {
  nix flake show --json "$FLAKE_REF" \
    | jq -r '(.darwinConfigurations // {} | keys[]), (.nixosConfigurations // {} | keys[]), (.homeManagerConfigurations // {} | keys[])'
}

build() {
  local trace=$1
  if [ -n "${TARGET:-}" ]; then
    build_target "$TARGET" "$trace"
    return
  fi

  case "$TARGET_OS" in
    "macos")
      echo "Building nix-darwin config ..."
      nix --extra-experimental-features 'nix-command flakes' build "${FLAKE_REF}#darwinConfigurations.${HOSTNAME}.system" ${trace:+"$trace"}
      ;;
    "nixos")
      echo "Building NixOS config ..."
      nixos-rebuild build --flake "${FLAKE_REF}#${HOSTNAME}" ${trace:+"$trace"}
      ;;
    "linux")
      echo "Building home-manager config..."
      nix build "${FLAKE_REF}#homeManagerConfigurations.${HOSTNAME}.activationPackage" ${trace:+"$trace"}
      ;;
  esac
}

trace() {
  build "--show-trace"
}

check() {
  local trace=$1
  local target=${TARGET:-$HOSTNAME}

  check_target "$target" "$trace"
}

check_all() {
  local trace=$1
  local target

  while IFS= read -r target; do
    [ -n "$target" ] || continue
    check_target "$target" "$trace"
  done < <(all_targets)
}

switch() {
  if [ -n "${TARGET:-}" ] && [ "${TARGET}" != "${HOSTNAME}" ]; then
    echo "switch only supports the current machine. Use 'make build TARGET=${TARGET}' or 'make check TARGET=${TARGET}' for other targets." >&2
    exit 1
  fi

  build
  case "$TARGET_OS" in
    "macos")
      echo "Switching nix-darwin config ..."
      sudo ./result/sw/bin/darwin-rebuild switch --flake "${FLAKE_REF}#${HOSTNAME}"
      ;;
    "nixos")
      echo "Switching NixOS config ..."
      sudo nixos-rebuild switch --flake "${FLAKE_REF}#${HOSTNAME}"
      ;;
    "linux")
      echo "Applying home-manager config..."
      export HOME_MANAGER_BACKUP_EXT="nix-hm-backup"
      ./result/activate
      ;;
  esac
}

update() {
    echo "Updating flake inputs..."
    nix flake update
}

gc() {
    echo "Garbage collecting..."
    nix-env --delete-generations 5d
    nix-store --gc
}

clean() {
    if [ -L "result" ] || [ -e "result" ]; then
        echo "Removing local build result link..."
        rm -f result
    else
        echo "No local result link to remove."
    fi
}

ansible() {
  pushd ansible
  ansible-playbook -i inventory.ini playbook.yml --ask-become-pass
  popd
}

ansible_reqs() {
  pushd ansible
  ansible-galaxy install -r requirements.yml --roles-path vendor_roles
  ansible-galaxy collection install -r requirements.yml
  popd
}

case "$1" in
    "build") build;;
    "trace") trace;;
    "check") check;;
    "check_all") check_all;;
    "check-trace") check "--show-trace";;
    "switch") switch;;
    "apply") switch;;
    "update") update;;
    "gc") gc;;
    "clean") clean;;
    "ansible") ansible;;
    "ansible_reqs") ansible_reqs;;
    *) switch;;
esac
