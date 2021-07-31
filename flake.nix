{
  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-21.05"; };
    nixos-hardware = { url = "github:nixos/nixos-hardware"; };
  };

  outputs =
    { self
    , nixpkgs
    , nixos-hardware
    , ...
    } @ inputs: {

    nixosConfigurations = let
      modulesCommon = [
        # Enable Flake
        ({ pkgs, ... }: {
          # Let 'nixos-version --json' know about the Git revision of this flake.
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

          nix.package = pkgs.nixUnstable;
          nix.extraOptions = ''
            experimental-features = nix-command flakes
          '';
        })
        ./hosts/common.nix
      ];
    in {
      oldbook = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = modulesCommon ++ [
          ./hosts/desktop.nix
          ./hosts/oldbook.nix
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
