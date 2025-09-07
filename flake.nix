{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";

    vscode-server.url = "github:nix-community/nixos-vscode-server";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
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
    , ...
    }:
    let
      overlays = [
        (final: prev: {
          rbw = prev.rbw.override { };
          nodejs = prev.nodejs_22;
          nodejs-slim = prev.nodejs-slim_22;
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

      # creates a nixos system config
      nixosSystem = system: hostName: username:
        let
          stablePkgs = genPkgs system;
          unstablePkgs = genUnstablePkgs system;
        in
        nixpkgs.lib.nixosSystem
          {
            inherit system;
            modules = [
              # adds unstable to be available in top-level evals (like in common-packages)
              { _module.args = { inherit unstablePkgs stablePkgs; }; }

              ./hosts/common/base.nix
              ./hosts/nixos/${hostName} # ip address, host specific stuff
              vscode-server.nixosModules.default
              home-manager.nixosModules.home-manager
              {
                networking.hostName = hostName;
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${username} = { imports = [ ./home/${username}.nix ]; };
                home-manager.extraSpecialArgs = { inherit unstablePkgs stablePkgs; };
              }
              ./hosts/common/nixos-common.nix
            ] ++ customModules;
          };

      # creates a macos system config
      darwinSystem = system: hostName: username:
        let
          unstablePkgs = genUnstablePkgs system;
          stablePkgs = genDarwinPkgs system;
        in
        nix-darwin.lib.darwinSystem
          {
            inherit system inputs;
            modules = [
              # adds unstable to be available in top-level evals (like in common-packages)
              { _module.args = { inherit unstablePkgs stablePkgs; }; }

              ./hosts/common/base.nix
              ./hosts/darwin/${hostName} # ip address, host specific stuff
              home-manager.darwinModules.home-manager
              {
                networking.hostName = hostName;
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${username} = { imports = [ ./home/${username}.nix ] ++ customModules; };
                home-manager.extraSpecialArgs = { inherit unstablePkgs stablePkgs; };
              }
              ./hosts/common/darwin-common.nix
            ];
          };

      linuxSystem = { system, hostName, username, homeDirectory ? "/home/${username}" }:
        let
          stablePkgs = genPkgs system;
          unstablePkgs = genUnstablePkgs system;
        in

        home-manager.lib.homeManagerConfiguration
          {
            pkgs = stablePkgs;

            modules = [
              { _module.args = { inherit unstablePkgs stablePkgs; }; }
              ./home/${username}.nix
              {
                home = {
                  username = username;
                  homeDirectory = homeDirectory;
                  packages = import ./hosts/common/common-packages.nix { inherit unstablePkgs stablePkgs; };
                };
              }
            ] ++ customModules;
          };
    in
    {
      darwinConfigurations = {
        osprey = darwinSystem "x86_64-darwin" "osprey" "dominik";
        thorax = darwinSystem "aarch64-darwin" "thorax" "dominik";
      };

      nixosConfigurations = {
        testnix = nixosSystem "x86_64-linux" "testnix" "dominik";
      };

      homeManagerConfigurations = {
        lima-ubuntu-lts = linuxSystem { system = "x86_64-linux"; hostName = "lima-ubuntu-lts"; username = "dominik"; homeDirectory = "/home/dominik.linux"; };
        workstation = linuxSystem { system = "x86_64-linux"; hostName = "workstation"; username = "dominik"; };
        dev-vm = linuxSystem { system = "x86_64-linux"; hostName = "dev-vm"; username = "dominik"; };
      };
    };
}
