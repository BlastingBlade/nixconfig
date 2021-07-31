{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";

  outputs = { self, nixpkgs }: {

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
        # Base Packages
        ({ pkgs, ... }: {
          time.timeZone = "America/New_York";
          environment.systemPackages = with pkgs; [
            vim
            git
            nix-index
          ];
          environment.variables = {
            EDITOR = "vim";
            VISUAL = "vim";
          };
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
        specialArgs = { inherit inputs; };
      };
    };
  };
}
