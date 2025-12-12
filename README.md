Current NixOS + Hyprland Setup

Flake Updates:
```
# Update all flake inputs (nixpkgs, home-manager, etc)
nix flake update

# See what changed
git diff flake.lock

# Rebuild with updates
sudo nixos-rebuild switch --flake .#hyprland

# Commit the updates
git add flake.lock
git commit -m "Update flake inputs - $(date +%Y-%m-%d)"
git push
```
Check what will be updated before applying:
```
cd ~/nixos-dotfiles
nix flake update
sudo nixos-rebuild dry-build --flake .#hyprland
```
