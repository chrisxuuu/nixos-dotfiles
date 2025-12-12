{ config, pkgs, ...}:

{
	home.username = "c";
	home.homeDirectory = "/home/c";
	home.stateVersion = "25.11";
	home.packages = with pkgs; [
		neovim
		R
		vscode
	];
	programs.bash = {
		enable = true;
		shellAliases = {
			test = "echo test-alias";
		};
		profileExtra = ''
			if [ -z  "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
				exec Hyprland
			fi
		'';
	};
	programs.firefox = {
		enable = true;
		profiles.default = {
			settings = {
				"ui.systemUsesDarkTheme" = 1;
				"browser.theme.dark-private-windows" = true;
			};
		};
	};
	home.file.".config/hypr".source = ./config/hypr;
	home.file.".config/waybar".source = ./config/waybar;
	home.file.".config/rofi".source = ./config/rofi;
	gtk = {
		enable = true;
		theme = {
			name = "Adwaita-dark";
			package = pkgs.gnome-themes-extra;
		};
		iconTheme = {
			name = "Adwaita";
			package = pkgs.adwaita-icon-theme;
		};
		gtk3.extraConfig = {
			gtk-application-prefer-dark-theme = true;
		};
		gtk4.extraConfig = {
			gtk-application-prefer-dark-theme = true;
		};
	};

	# Qt dark theme
	qt = {
		enable = true;
		platformTheme.name = "adwaita";
		style.name = "adwaita-dark";
	};

	dconf.settings = {
		"org/gnome/desktop/interface" = {
			color-scheme = "prefer-dark";
			gtk-theme = "Adwaita-dark";
		};
	};
}
