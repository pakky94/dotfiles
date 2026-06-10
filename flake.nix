{
 description = "My Nix config";

 inputs = {
 nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
 # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

 home-manager = {
 url = "github:nix-community/home-manager";
 inputs.nixpkgs.follows = "nixpkgs";
 };

 jovian-nixos = {
 url = "github:Jovian-Experiments/Jovian-NixOS";
 inputs.nixpkgs.follows = "nixpkgs";
 };

 hyprdisplay.url ="github:pakky94/hyprdisplay";

 # zen-browser.url = "github:0xc000022070/zen-browser-flake";
 };

 outputs = { nixpkgs, home-manager, jovian-nixos, ... } @inputs: {
 # NixOS profiles

 nixosConfigurations."steamdeck" = nixpkgs.lib.nixosSystem {
 system = "x86_64-linux";
 specialArgs = {
 inherit inputs;
 };
 modules = [
 ./nix/modules/core.nix
 ./nix/hosts/steamdeck
 home-manager.nixosModules.home-manager
 {
 home-manager.useGlobalPkgs = true;
 home-manager.useUserPackages = true;
 home-manager.users.pakky = import ./nix/hosts/steamdeck/home-manager.nix;
 }
 jovian-nixos.nixosModules.default
 ];
 };

 nixosConfigurations."vmware" = nixpkgs.lib.nixosSystem {
 system = "x86_64-linux";
 specialArgs = {
 inherit inputs;
 };
 modules = [
 ./nix/modules/core.nix
 ./nix/hosts/vmware
 home-manager.nixosModules.home-manager
 {
 home-manager.useGlobalPkgs = true;
 home-manager.useUserPackages = true;
 home-manager.users.pakky = import ./nix/hosts/vmware/home-manager.nix;
 }
 ];
 };

 nixosConfigurations."winmax2" = nixpkgs.lib.nixosSystem {
 system = "x86_64-linux";
 specialArgs = {
 inherit inputs;
 };
 modules = [
 ./nix/modules/core.nix
 ./nix/hosts/winmax2
 home-manager.nixosModules.home-manager
 {
 home-manager.useGlobalPkgs = true;
 home-manager.useUserPackages = true;
 home-manager.users.pakky = import ./nix/hosts/winmax2/home-manager.nix;
 }
 ];
 };

 # Home manager standalone profiles
 homeConfigurations."wsl-personal" = home-manager.lib.homeManagerConfiguration {
 pkgs = nixpkgs.legacyPackages.x86_64-linux;
 modules = [
 ./nix/modules/core.nix
 ./nix/home-manager/profiles/wsl-personal.nix
 ];
 };

 homeConfigurations."steamdeck" = home-manager.lib.homeManagerConfiguration {
 pkgs = nixpkgs.legacyPackages.x86_64-linux;
 modules = [
 ./nix/modules/core.nix
 ./nix/home-manager/profiles/steamdeck.nix
 ];
 };

 homeConfigurations."winmax2hm" = home-manager.lib.homeManagerConfiguration {
 pkgs = nixpkgs.legacyPackages.x86_64-linux;
 modules = [
 ./nix/modules/core.nix
 ./nix/home-manager/profiles/winmax2.nix
 ];
 };

 homeConfigurations."wsl-work" = home-manager.lib.homeManagerConfiguration {
 pkgs = nixpkgs.legacyPackages.x86_64-linux;
 modules = [
 ./nix/modules/core.nix
 ./nix/home-manager/profiles/wsl-work.nix
 ];
 };

 };
}
