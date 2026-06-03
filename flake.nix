{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    nixosConfigurations.astaroth = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
	./packages/iriunwebcam/iriunwebcam-module.nix
	./packages/starship-prompt/starship-module.nix
        home-manager.nixosModules.home-manager {
	}
      ];
    };
  };
}
