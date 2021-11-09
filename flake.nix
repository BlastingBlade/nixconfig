{
  description = "Some nonsense that I'm using on my computers";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-21.05"; };

    utils = { url = "github:gytis-ivaskevicius/flake-utils-plus"; };

    nixos-hardware = { url = "github:nixos/nixos-hardware"; };

    impermanence = { url = "github:nix-community/impermanence"; };

    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-overlay = { url = "github:nix-community/emacs-overlay"; };

    nix-doom-emacs = {
      url = "github:vlaci/nix-doom-emacs/develop";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.emacs-overlay.follows = "emacs-overlay";
      inputs.straight = {
        url = "github:raxod502/straight.el";
        flake = false;
       };
    };
  };

  outputs =
    { self
    , nixpkgs
    , utils
    , ...
    } @ inputs:
    utils.lib.mkFlake
      {
        inherit self inputs;

        nixosModules = utils.lib.exportModules [
          ./nixosModules/common.nix
          ./nixosModules/flakes.nix
          ./nixosModules/blasting.nix
          ./nixosModules/desktop.nix
        ];

        hostModules = utils.lib.exportModules [
          ./hosts/oldbook.nix
          ./hosts/planeptune.nix
          ./hosts/histoire.nix
        ];

        hmModules = utils.lib.exportModules [
          ./hmModules/common.nix
          ./hmModules/desktop
          ./hmModules/server.nix
        ];

        # Channels are generated from nixpkgs style inputs (ie those with .legacyPackages)

        channels.nixpkgs.overlayBuilder = channels: [
          inputs.utils.overlay
          inputs.emacs-overlay.overlay
          (final: prev: {
            emacs = prev.emacsPgtkGcc;
          })
        ];

        hostDefaults = {
          channelName = "nixpkgs";
          system = "x86_64-linux";
          modules = [
            self.nixosModules.common
            self.nixosModules.flakes
            self.nixosModules.blasting

            inputs.home-manager.nixosModule
            {
              home-manager = {
                useGlobalPkgs = true;
                #useUserPackages = true;
                extraSpecialArgs = {
                  inherit (inputs) self nix-doom-emacs;
                };
              };
            }
          ];
          specialArgs = { inherit (inputs) self nixos-hardware impermanence home-manager; };
        };

        hosts = let
          droidcam = { ... }: { programs.droidcam.enable = true; };
        in {
          # Personal laptop, Dell Inspiron 3543 A10
          oldbook.modules = [
            self.nixosModules.desktop
            self.hostModules.oldbook
            droidcam
            { home-manager.users.blasting.imports = [ self.hmModules.desktop ]; }
          ];
          # Local server, Raspberry Pi 4B 1GiB
          planeptune.system = "aarch64-linux";
          planeptune.modules = [
            self.hostModules.planeptune
            { home-manager.users.blasting.imports = [ self.hmModules.server ]; }
          ];

          # Online VPS, Linode
          histoire.modules = [
            self.hostModules.histoire
            { home-manager.users.blasting.imports = [ self.hmModules.server ]; }
          ];
        };
      };
}
