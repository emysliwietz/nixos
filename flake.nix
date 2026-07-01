{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    claude-code.url = "github:sadjow/claude-code-nix";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { nixpkgs, home-manager, claude-code, ... }: {
    nixosConfigurations.astaroth = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit claude-code; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager {
	    }
      ];
    };
  };
}
