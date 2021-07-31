{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";

  outputs = { self, nixpkgs }: {

    nixosConfigurations = let
      modulesCommon = [
        ({ pkgs, ... }: {
          # Let 'nixos-version --json' know about the Git revision of this flake.
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

          nix.package = pkgs.nixUnstable;
          nix.extraOptions = ''
            experimental-features = nix-command flakes
          '';
        })
      ];
    in {
      oldbook = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = modulesCommon ++ [
          ({ pkgs, ... }: {
            boot.isContainer = true;
          })
        ];
      };
    };
  };
}
