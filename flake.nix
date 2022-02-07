{
  description = "Some nonsense that I'm using on my computers";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-unstable"; };

    flake-utils = { url = "github:numtide/flake-utils"; };
    flake-utils-plus = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
      inputs.flake-utils.follows = "flake-utils";
    };

    nixos-hardware = { url = "github:nixos/nixos-hardware"; };

    impermanence = { url = "github:nix-community/impermanence"; };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-overlay = { url = "github:nix-community/emacs-overlay"; };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils-plus
    , ...
    } @ inputs:
    flake-utils-plus.lib.mkFlake
      {
        inherit self inputs;

        lib = import ./lib { inherit (nixpkgs) lib; };

        modules = flake-utils-plus.lib.exportModules [
          ./nixosModules/common.nix
          ./nixosModules/flakes.nix
          ./nixosModules/blasting.nix
          ./nixosModules/desktops
        ];

        hostModules = flake-utils-plus.lib.exportModules [
          ./hosts/oldbook.nix
          ./hosts/planeptune.nix
          ./hosts/histoire.nix
        ];

        channels.nixpkgs.overlaysBuilder = channels: [
          self.overlay
          inputs.flake-utils-plus.overlay
          inputs.emacs-overlay.overlay
        ];

        hostDefaults = {
          channelName = "nixpkgs";
          system = "x86_64-linux";
          modules = [
            self.modules.common
            self.modules.flakes
            self.modules.blasting

            inputs.home-manager.nixosModule
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit (inputs) self;
                };
              };
            }
          ];
          specialArgs = {
            inherit (inputs)
              self
              nixos-hardware
              impermanence;
          };
        };

        hosts = {
          # Personal laptop, Dell Inspiron 3543 A10
          oldbook.modules = [
            self.modules.desktops.river
            self.hostModules.oldbook
          ];

          # Online VPS, Linode
          histoire.modules = [
            self.hostModules.histoire
          ];
        };

        overlay = import ./pkgs { inherit inputs; };
        overlays = flake-utils-plus.lib.exportOverlays { inherit (self) inputs pkgs; };
      };
}
