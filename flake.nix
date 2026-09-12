{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    vscode-server.url = "github:nix-community/nixos-vscode-server";

    hunk.url = "github:modem-dev/hunk/v0.20.1";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixpkgs-unstable
    , nixpkgs-darwin
    , home-manager
    , nix-darwin
    , vscode-server
    , hunk
    , ...
    }:
    let
      inherit (inputs.nixpkgs) lib;
      overlays = [
        (final: prev: {
          rbw = prev.rbw.override { };
        })
       (import ./packages/overlays/herdr.nix)
        (final: prev: {
          hunk = hunk.packages.${final.system}.default;
        })
      ];

      inputs = { inherit nix-darwin home-manager nixpkgs nixpkgs-unstable; };
      # creates correct package sets for specified arch
      genPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = overlays;
      };
      genUnstablePkgs = system: import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        overlays = overlays;
      };
      genDarwinPkgs = system: import nixpkgs-darwin {
        inherit system;
        config.allowUnfree = true;
        overlays = overlays;
      };

      customModules = [
        ./modules/services/syncthing.nix
      ];

      hostSpecs = {
        osprey = {
          kind = "darwin";
          system = "x86_64-darwin";
          username = "dominik";
        };
        thorax = {
          kind = "darwin";
          system = "aarch64-darwin";
          username = "dominik";
        };
        testnix = {
          kind = "nixos";
          system = "x86_64-linux";
          username = "dominik";
        };
        lima-ubuntu-lts = {
          kind = "linux-home";
          system = "x86_64-linux";
          username = "dominik";
          homeDirectory = "/home/dominik.linux";
        };
        workstation = {
          kind = "linux-home";
          platform = "wsl";
          system = "x86_64-linux";
          username = "dominik";
        };
        dev-vm = {
          kind = "linux-home";
          system = "x86_64-linux";
          username = "dominik";
        };
        cachyos-x8664 = {
          kind = "linux-home";
          system = "x86_64-linux";
          username = "dominik";
          desktop = true;
        };
      };

      selectHostSpecs = kind: lib.filterAttrs (_: spec: spec.kind == kind) hostSpecs;

      hostImports = {
        cli = [ ./home/profiles/cli.nix ];
        guiBase = [ ./home/profiles/gui-base.nix ];
      };

      homeImportsFor = { desktop ? false, platform ? "linux" }:
        hostImports.cli
        ++ lib.optionals desktop hostImports.guiBase
        ++ lib.optionals (platform == "wsl") [ ./home/platforms/wsl.nix ]
        ++ customModules;

      mkPkgsFor = { kind, system }:
        let
          stablePkgs = if kind == "darwin" then genDarwinPkgs system else genPkgs system;
        in
        {
          inherit stablePkgs;
          unstablePkgs = genUnstablePkgs system;
        };

      mkHomeManagerModule =
        { username
        , stablePkgs
        , unstablePkgs
        , homeImports ? hostImports.cli ++ customModules
        }:
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = { imports = homeImports; };
          home-manager.extraSpecialArgs = { inherit unstablePkgs stablePkgs; };
        };

      mkManagedSystem = { kind, system, hostName, username }:
        let
          inherit (mkPkgsFor { inherit kind system; }) stablePkgs unstablePkgs;
          systemBuilder = if kind == "darwin" then nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
          homeManagerModule =
            if kind == "darwin" then home-manager.darwinModules.home-manager else home-manager.nixosModules.home-manager;
          hostModule = if kind == "darwin" then ./hosts/darwin/${hostName} else ./hosts/nixos/${hostName};
          commonModule =
            if kind == "darwin" then ./hosts/common/darwin-common.nix else ./hosts/common/nixos-common.nix;
        in
        systemBuilder (
          {
            inherit system;
            modules = [
              { _module.args = { inherit unstablePkgs stablePkgs; }; }
              ./hosts/common/base.nix
              hostModule
            ]
            ++ lib.optionals (kind == "nixos") [ vscode-server.nixosModules.default ]
            ++ [
              homeManagerModule
              ({ networking.hostName = hostName; } // mkHomeManagerModule {
                inherit username stablePkgs unstablePkgs;
              })
              commonModule
            ];
          }
          // lib.optionalAttrs (kind == "darwin") { inherit inputs; }
        );

      mkLinuxHome =
        { kind
        , system
        , hostName
        , username
        , homeDirectory ? "/home/${username}"
        , desktop ? false
        , platform ? "linux"
        }:
        let
          inherit (mkPkgsFor { inherit kind system; }) stablePkgs unstablePkgs;
        in
        home-manager.lib.homeManagerConfiguration
          {
            pkgs = stablePkgs;
            modules = [
              { _module.args = { inherit unstablePkgs stablePkgs; }; }
            ]
            ++ homeImportsFor { inherit desktop platform; }
            ++ [
              ({ config, lib, pkgs, ... }:
                let
                  packageGroups = import ./packages { inherit stablePkgs unstablePkgs lib; };
                in
                {
                  home = {
                    username = username;
                    homeDirectory = homeDirectory;
                    packages = packageGroups.development;
                  };

                  home.activation.make-zsh-default-shell = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                    PATH="/usr/bin:/bin:$PATH"
                    ZSH_PATH="/home/${username}/.nix-profile/bin/zsh"
                    if [[ $(getent passwd ${username}) != *"$ZSH_PATH" ]]; then
                      echo "Setting zsh as default shell (using chsh). Password might be necessary."
                      if ! grep -q $ZSH_PATH /etc/shells; then
                        echo "Adding zsh to /etc/shells"
                        $DRY_RUN_CMD echo "$ZSH_PATH" | sudo tee -a /etc/shells
                      fi
                      echo "Running chsh to make zsh the default shell"
                      $DRY_RUN_CMD chsh -s $ZSH_PATH ${username}
                      echo "zsh is now set as default shell !"
                    fi
                  '';
                })
            ];
          };
    in
    {
      darwinConfigurations = lib.mapAttrs
        (
          hostName: spec: mkManagedSystem ({ inherit hostName; } // spec)
        )
        (selectHostSpecs "darwin");

      nixosConfigurations = lib.mapAttrs
        (
          hostName: spec: mkManagedSystem ({ inherit hostName; } // spec)
        )
        (selectHostSpecs "nixos");

      homeManagerConfigurations = lib.mapAttrs
        (
          hostName: spec: mkLinuxHome ({ inherit hostName; } // spec)
        )
        (selectHostSpecs "linux-home");
    };
}
