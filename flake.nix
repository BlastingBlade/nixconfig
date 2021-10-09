{
  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-21.05"; };
    nixos-hardware = { url = "github:nixos/nixos-hardware"; };
    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
    };
    nix-doom-emacs = {
      url = "github:vlaci/nix-doom-emacs/develop";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.emacs-overlay.follows = "emacs-overlay";
      inputs.straight = {
        url = "github:raxod502/straight.el";
        flake = false;
       };
    };

    impermanence = { url = "github:nix-community/impermanence"; };
  };

  outputs =
    { self
    , nixpkgs
    , nixos-hardware
    , home-manager
    , emacs-overlay
    , nix-doom-emacs
    , impermanence
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

      nixosModules = import ./nixosModules;

      hmModules = import ./hmModules { inherit pkgs inputs; };

      homeManagerConfigurations = {
        blasting = home-manager.lib.homeManagerConfiguration {
          stateVersion = "21.05";
          configuration = self.hmModules.desktop;
          system = system;
          homeDirectory = "/home/blasting";
          username = "blasting";
        };
      };

      nixosConfigurations = let
        hosts = import ./hosts;
        commonModule = ({ ... }:
          {
            imports = [ inputs.self.nixosModules.common ];

            time.timeZone = "America/New_York";
            blasting.common = {
              user = {
                username = "blasting";
                realname = "Henry Fiantaca";
                sshAuthorizedKeys = [
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmKlAu/Fgvt5TYZgBV3aZdoTQ+SfI/x+0zUEsyK9ET1 hfiantaca@gmail.com"
                ];
                passwordHash =
                  "$6$jTnBoykh2C$c3xA1b0jHixv6WeFIQCmQ0Vc1l.N.l5Uc0t7/d.WPbkd8vERnWjZv8ZgGPNshPr3cME.RXGiOe5oi5hm2ym/q1";
              };
            };

            nix.package = pkgs.nixUnstable;
            nix.extraOptions = ''
              experimental-features = nix-command flakes
            '';
            system.configurationRevision = lib.mkIf (self ? rev) self.rev;
            nix.registry.nixpkgs.flake = inputs.nixpkgs;
            nix.registry.self.flake = inputs.self;
            environment.systemPackages = with pkgs; [ git gnumake ];
          });
      in {
        oldbook = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            commonModule
            self.nixosModules.desktop
            hosts.oldbook
          ];
          specialArgs = { inherit inputs; };
        };
        planeptune = lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            commonModule
            hosts.planeptune
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.blasting = self.hmModules.server;
            }
          ];
          specialArgs = { inherit inputs; };
        };
        histoire = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            commonModule
            hosts.histoire
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.blasting = self.hmModules.server;
            }
          ];
          specialArgs = { inherit inputs; };
        };
      };
    };
}
