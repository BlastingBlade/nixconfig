##
# nixconfig
#
# @file
# @version 0.1

.PHONY: update rebuild homemanager

update:
	nix flake lock --recreate-lock-file --commit-lock-file

rebuild:
	sudo nixos-rebuild switch --flake '.#oldbook'

homemanager:
	nix build '.#homeManagerConfigurations.blasting.activationPackage'
	./result/activate

# end
