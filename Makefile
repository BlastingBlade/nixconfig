##
# nixconfig
#
# @file
# @version 0.1

.PHONY: update gc rebuild homemanager

update:
	nix flake lock --recreate-lock-file --commit-lock-file

gc:
	sudo nix-collect-garbage --delete-older-than 7d

rebuild:
	sudo nixos-rebuild switch --flake '.#'

homemanager:
	nix build '.#homeManagerConfigurations.blasting.activationPackage'
	./result/activate

# end
