{
  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-21.05"; };
    nixos-hardware = { url = "github:nixos/nixos-hardware"; };
    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = { url = "github:nix-community/emacs-overlay"; };
  };

  outputs =
    { self
    , nixpkgs
    , nixos-hardware
    , home-manager
    , emacs-overlay
    , ...
    } @ inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
      };

      lib = nixpkgs.lib;

    in {

      homeManagerConfigurations = {
        blasting = home-manager.lib.homeManagerConfiguration {
          stateVersion = "21.05";
          configuration = ./home/blasting.nix;
          system = system;
          homeDirectory = "/home/blasting";
          username = "blasting";
        };
      };

      nixosConfigurations = let
        modulesCommon = [
          # Enable Flake
          ({ pkgs, ... }: {
            # Let 'nixos-version --json' know about the Git revision of this flake.
            system.configurationRevision = lib.mkIf (self ? rev) self.rev;

            nix.package = pkgs.nixUnstable;
            nix.extraOptions = ''
              experimental-features = nix-command flakes
            '';

            # Set the regestry to use the same revision of nixpkgs as this flake
            nix.registry.nixpkgs.flake = inputs.nixpkgs;
            nix.registry.self.flake = inputs.self;

            nixpkgs.overlays = [ emacs-overlay.overlay ];

            environment.systemPackages = with pkgs; [ gnumake ];
          })
          ./hosts/common.nix
        ];
      in {
        oldbook = lib.nixosSystem {
          system = "x86_64-linux";
          modules = modulesCommon ++ [
            ./hosts/oldbook.nix
            ./bits/desktop.nix
            ./bits/emacs.nix
            ./bits/nonfree.nix
            nixos-hardware.nixosModules.common-gpu-nvidia-disable
            nixos-hardware.nixosModules.dell-latitude-3480
            ({ pkgs, ... }: {
              hardware.opengl = {
                enable = true;
                driSupport = true;
                driSupport32Bit = true;
              };
              hardware.bluetooth.enable = true;
            })
          ];
          specialArgs = { inherit inputs; };
        };
        planeptune = lib.nixosSystem {
          system = "aarch64-linux";
          modules = modulesCommon ++ [
            nixos-hardware.nixosModules.raspberry-pi-4
            ./hosts/planeptune.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.blasting = import ./home/blasting.server.nix;
            }
          ];
        };
      };
    };
}
