# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  # Limit number of generations
  boot.loader.systemd-boot.configurationLimit = 3;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "hyprland"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";
  
  services.getty.autologinUser = "c";

  programs.hyprland = {
  	enable = true;
        xwayland.enable = true;
	withUWSM = true;
  };

  users.users.c = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      packages = with pkgs; [
        tree
      ];
  };

  programs.firefox.enable = true;
  programs.steam.enable = true;
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;  # GUI for managing keyring

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    # kitty
    waybar
    git
    hyprpaper
    pciutils
    efibootmgr
    networkmanagerapplet
    blueman
    pavucontrol
    rofi
    gnome-keyring
    libsecret
    wireplumber
    grim          # Screenshot tool
    slurp         # Region selector
    grimblast     # Wrapper for grim + slurp
    wl-clipboard  # For copying to clipboard
    yazi          # Terminal file manager
    kdePackages.dolphin       # KDE file manager (GUI)
    wezterm       # Terminal emulator
    python312     # Python 3.12
    uv            # Fast Python package installer
    unzip
    zip
    gcc           # C compiler (needed for building Lua rocks)
    luajit        # Lua JIT compiler
    luajitPackages.luarocks-nix  # Lua package manager
    cmake         # Build tool (needed by some plugins)
    gnumake       # Make tool
    tree-sitter   # Parser generator (for treesitter plugins)
    fastfetch
    aws-workspaces
    obs-studio
  ];
  hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # GTK dark theme
  programs.dconf.enable = true;

  environment.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
  };

  environment.loginShellInit = ''
  	if [ -z "$DISPLAY" ] && [ "$(tty)" = "dev/tty1" ]; then
		exec Hyprland
	fi

  '';
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
 # services.greetd = {
#	enable = true;
#	settings = {
#		default_session = {
#			command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
#			user = "greeter";
#		};
#	};
  #}; 
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true; 

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

