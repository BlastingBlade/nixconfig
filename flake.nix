{
  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-21.05"; };
    nixos-hardware = { url = "github:nixos/nixos-hardware"; };
    emacs-overlay = { url = "github:nix-community/emacs-overlay"; };
  };

  outputs =
    { self
    , nixpkgs
    , nixos-hardware
    , emacs-overlay
    , ...
    } @ inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ emacs-overlay.overlay ];
      };

      lib = nixpkgs.lib;

    in {

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
          })
          ./hosts/common.nix
        ];
      in {
        oldbook = lib.nixosSystem {
          system = "x86_64-linux";
          modules = modulesCommon ++ [
            ./hosts/desktop.nix
            ./hosts/oldbook.nix
            ./bits/emacs.nix
            nixos-hardware.nixosModules.common-gpu-nvidia-disable
            nixos-hardware.nixosModules.dell-latitude-3480
            ({ pkgs, ... }: {
              hardware.opengl.enable = true;
              hardware.bluetooth.enable = true;
            })
          ];
          specialArgs = { inherit inputs; };
        };
      };
    };
}
