I would like to refactor this nix configuration to be more modular, at first it seemed like a good idea to share everything but now I am considering adding an actual NixOS desktop, potentially nixos LXC or VMs on proxmox and so one. Depending on the
  system type will not need my full home dir setup with all the packages. I think the programs and packages should be moved to group (or even one module per program), then grouped together so that i can easily choose what to install on which host. I
  looked at some other nix configurations and these stand out

  https://github.com/EmergentMind/nix-config very powerful but maybe overkill? I also don't like that the hosts are all defined in the main flake.nix
  https://github.com/mitchellh/nixos-config maybe a bit too simple? no real modules for different packages and their configuration i think he has the same installed on every host
  https://github.com/ryan4yin/nix-config very nice but i am not sure if i like the modularization style, i think i want group based on the type of the systems to not install everything everywhere.

  Please summarize the different approaches in the repos (analyze the content) and give me a plan. I am not tied to make, we can switch to just but it should still be simple to run one command to update/apply one system. Ideally I would also like to test the build for other systems, i.e. if i am on my mac i would like to test the NixOS and or homemanager for a x86 linux will still work.

## Analysis Summary

### Current repo shape

- `flake.nix` currently contains most of the composition logic directly and manually enumerates hosts.
- `hosts/common/common-packages.nix` is used as one shared package bundle across darwin, nixos, and standalone home-manager systems.
- `home/dominik.nix` contains most user configuration in one large module, with only a small amount split into submodules.
- Darwin hosts currently reuse the same shared package list as other systems.
- The current `make.sh` flow is simple for "apply on this machine" but is not ideal for explicitly building other targets from a different host.

### Reference repo takeaways

- `EmergentMind/nix-config`
  - Strong separation between `core` and `optional` modules.
  - Good example of filesystem-driven structure and host discovery.
  - Powerful, but likely more framework than needed here right now.
- `mitchellh/nixos-config`
  - Small and easy to follow.
  - Good example of a minimal `mkSystem` abstraction.
  - Too coarse for the package/profile composition wanted here.
- `ryan4yin/nix-config`
  - Rich modular structure with explicit per-system outputs and `just` commands.
  - Good reference for multi-system output organization and host targeting.
  - More complex than needed as a direct template.

### Chosen direction

- Keep the overall structure closer to `mitchellh/nixos-config` in complexity.
- Borrow `core` vs `optional` discipline from `EmergentMind/nix-config`.
- Borrow explicit target/build ergonomics from `ryan4yin/nix-config`.
- Avoid over-modularizing into one module per program unless there is a clear reuse need.

## Proposed Refactor Plan

### 1. Layer package groups by machine type

Use a small number of layered package bundles instead of many tiny categories:

- `core`
  - Minimal toolbox for every machine, including service VMs.
  - Expected examples: `htop`, `btop`, `jq`, `tree`, `wget`, `curl`, `ripgrep`, `fd`, `drill`, `iperf3`, `smartmontools`.
- `development`
  - `core` plus the full shared developer CLI/tooling baseline.
  - This should include what is currently needed on all dev machines.
- `desktop-base`
  - `development` plus packages common to any graphical Linux workstation.
- `desktop-plasma`
  - `desktop-base` plus Plasma-specific packages and related config modules.
- `desktop-niri`
  - `desktop-base` plus Niri-specific packages and related config modules.
- `darwin-base`
  - Small darwin-specific Nix-managed package bundle.
  - Keep this small because most macOS-specific app management already lives in nix-darwin/homebrew config rather than Nix packages.

This gives a simple inheritance model:

- service VM = `core`
- dev VM = `development`
- Linux desktop = `desktop-base + desktop-plasma` or `desktop-base + desktop-niri`
- Darwin workstation = `development + darwin-base`

### 2. Separate package groups from host profiles

Use two levels of composition:

- `packages/groups/*`
  - Reusable package bundles only.
- `profiles/*`
  - Host-role modules that import package groups and system/service config.

Suggested shape:

- `packages/groups/core.nix`
- `packages/groups/development.nix`
- `packages/groups/desktop-base.nix`
- `packages/groups/desktop-plasma.nix`
- `packages/groups/desktop-niri.nix`
- `packages/groups/darwin-base.nix`

- `profiles/nixos/server.nix`
- `profiles/nixos/dev-vm.nix`
- `profiles/nixos/desktop-plasma.nix`
- `profiles/nixos/desktop-niri.nix`
- `profiles/darwin/default.nix`

Hosts should become mostly hardware, networking, secrets, and profile imports.

### 3. Keep Home Manager mostly unified

Do not split Home Manager aggressively yet. The current user setup is expected to be shared across development systems and future GUI hosts, so start with minimal grouping:

- `home/profiles/cli.nix`
  - Shared shell/editor/git/tmux/dev-user config for all development systems.
- `home/profiles/gui-base.nix`
  - Optional GUI-only additions shared by graphical Linux systems.
- `home/profiles/gui/plasma.nix`
  - Only if Plasma-specific HM config actually appears.
- `home/profiles/gui/niri.nix`
  - Only if Niri-specific HM config actually appears.

If GUI-specific HM needs stay small, `cli` plus `gui-base` may be enough for a long time.

### 4. Move Darwin-specific Home Manager logic into its own module

This makes sense and should be part of the plan.

Preferred minimal split:

- keep the main shared user config in `home/profiles/cli.nix`
- move darwin-only HM behavior into `home/platforms/darwin.nix`

Darwin-only HM items that belong there:

- darwin-specific `home.sessionPath` entries
- `targets.darwin.*`
- darwin-only `programs.ssh.extraConfig`
- services or options that behave differently only on macOS
- any `mkIf stdenv.isDarwin` branches that are platform behavior rather than user profile behavior

If Linux-specific HM behavior grows later, add `home/platforms/linux.nix`, but that is not necessary up front.

### 5. Reduce flake-level host boilerplate

The current flake manually declares all hosts. Refactor toward:

- a small explicit host metadata attrset in `flake.nix`

Preferred first step:

- keep an explicit metadata attrset for clarity
- move heavy composition logic out of the large inline blocks
- avoid jumping directly to a large framework

This keeps the flake understandable while avoiding repeated host boilerplate.

### 6. Improve command ergonomics

Current `make.sh` is convenient for "apply here", but the refactor should support explicit target operations such as:

- build one target from another machine
- check multiple targets
- keep one simple command for local apply

Either `make` or `just` is acceptable, but the interface should support commands like:

- `apply`
- `build <target>`
- `check`
- `check-all`
- `build-home <target>`

It is fine to keep `make` as a compatibility wrapper even if `just` becomes the main task runner.

### 7. Add cross-system evaluation/build checks

The refactor should make it easy to validate non-local targets from a different machine, for example from macOS:

- evaluate Linux home-manager outputs
- evaluate NixOS outputs
- dry-run or build target derivations where supported

At minimum, the structure should support:

- `nix flake check`
- `nix eval`
- explicit `nix build` targets for home-manager and nixos outputs

Actual foreign-architecture builds may later benefit from remote builders, but that does not need to be solved in the first refactor.

## Initial implementation order

Most importantly the outcome for all currently configured systems should stay the same!

1. Introduce layered package groups:
   `core`, `development`, `desktop-base`, `desktop-plasma`, `desktop-niri`, `darwin-base`
2. Migrate the current shared package list into those groups.
3. Split Home Manager minimally into `cli`, `gui-base`, and `platforms/darwin`.
4. Introduce host profiles for `server`, `dev-vm`, `desktop-plasma`, `desktop-niri`, and `darwin/workstation`.
5. Refactor host definitions to import profiles instead of duplicating package setup.
6. Simplify `flake.nix` around host metadata and system builders.
7. Add explicit build/check/apply commands for local and cross-target workflows.
