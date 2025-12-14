{
  description = "Hyprland";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };
  outputs = { nixpkgs, home-manager, nix-flatpak, ... }: {
    nixosConfigurations.hyprland = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.c = import ./home.nix;
            backupFileExtension = "backup";
            
            # Add nix-flatpak module to home-manager
            sharedModules = [
              nix-flatpak.homeManagerModules.nix-flatpak
            ];
          };
        }
      ];
    };
  };
}