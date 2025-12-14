{ config, pkgs, lib, ...}:

let
  # Define R packages list (used for both R-with-packages and .Renviron)
  rPackagesList = with pkgs.rPackages; [
    # Core tidyverse and data manipulation
    dplyr tidyr purrr readr tibble stringr forcats lubridate
    
    # Plotting and visualization  
    ggplot2 ggrepel ggridges cowplot patchwork plotly scales
    RColorBrewer viridisLite gridExtra gt
    
    # Data import/export
    haven vroom data_table
    
    # Development tools
    devtools usethis remotes roxygen2 pkgdown testthat lintr styler
    
    # R Markdown and reporting
    rmarkdown knitr markdown r2rtf tinytex
    
    # Shiny and interactive
    shiny htmltools htmlwidgets crosstalk reactable bslib
    
    # Statistical modeling
    lme4 glmnet quantreg sandwich multcomp
    
    # Bioconductor packages
    BiocManager BiocGenerics BiocParallel Biostrings
    GenomeInfoDb GenomicRanges IRanges S4Vectors Rsamtools Rhtslib
    
    # Single-cell analysis
    Seurat SeuratObject Signac sctransform
    
    # Statistical methods
    mice coin broom fitdistrplus
    
    # Language server and IDE support
    languageserver
    httpgd    # HTTP graphics device for neovim/IDE integration (marked broken but works)
    unigd     # Universal graphics device (dependency for httpgd)
    
    # Additional commonly used packages
    cli crayon fs here magrittr rlang digest jsonlite yaml xml2 curl httr httr2
    
    # All other packages
    BH BiocVersion abind askpass backports base64enc bcrm bigD bit bit64
    bitops brew brio cachem callr caTools clipr collections commonmark cpp11
    credentials deldir desc diffobj dotCall64 downlit dqrng dtplyr ellipsis
    evaluate fansi farver fastDummies fastmap fastmatch FNN fontawesome foreach
    formatR futile_logger futile_options future future_apply generics
    GenomeInfoDbData gert gh gitcreds globals glue goftest gplots gsDesign
    gtable gtools highr hms httpuv ica igraph ini insight IRdisplay IRkernel
    irlba ISLR2 isoband iterators jomo jquerylib labeling lambda_r later
    lazyeval leidenbase libcoin lifecycle listenv lmtest MatrixModels
    matrixStats memoise mime miniUI minqa mitml modeltools mstate mvtnorm
    nloptr numDeriv openssl ordinal pan parallelly pbapply pbdZMQ pillar
    pkgbuild pkgconfig pkgload plotrix plyr png polyclip praise prettyunits
    processx profvis progress progressr promises ps pwr PwrGSD R_cache
    R_methodsS3 R_oo R_utils R6 ragg randomizeR RANN rappdirs rbibutils
    rcmdcheck Rcpp RcppAnnoy RcppArmadillo RcppEigen RcppHNSW RcppProgress
    RcppRoll RcppTOML RCurl Rdpack reactR reformulas remotes repr reshape2
    reticulate rex rJava ROCR rprojroot RSpectra rstudioapi Rtsne rversions
    S7 sass scattermore sessioninfo shape sitmo snow sourcetools sp spam
    SparseM spatstat_data spatstat_explore spatstat_geom spatstat_random
    spatstat_sparse spatstat_univar spatstat_utils stringi sys systemfonts
    tensor textshaping TH_data timechange tzdb ucminf UCSC_utils urlchecker
    utf8 uuid uwot V8 vctrs vroom waldo whisker withr xfun xmlparsedata
    xopen xtable XVector zip zoo
  ];

  # Define R with all packages
  R-with-packages = pkgs.rWrapper.override {
    packages = rPackagesList;
  };
in
{
	home.username = "c";
	home.homeDirectory = "/home/c";
	home.stateVersion = "25.11";
	
	home.packages = with pkgs; [
		neovim
		R-with-packages  # R with all packages
		vscode
		python312
		uv
		# Capitaine cursor theme
		capitaine-cursors
		# R console enhancer
		radian
		discord
		slack
	];
	
	programs.bash = {
		enable = true;
		shellAliases = {
			# Existing aliases
			test = "echo test-alias";
			nixbuild = "sudo nixos-rebuild switch --flake ~/nixos-dotfiles#hyprland";
			
			# Editor aliases
			vi = "nvim";
			vim = "nvim";
			v = "nvim";
			
			# R aliases - ensure packages are available
			r = "R";
			R = "R";  # Will use R-with-packages from PATH
			radian = "radian-wrapped";  # Use wrapper that points to R-with-packages
			
			# Git shortcuts
			gs = "git status";
			ga = "git add";
			gc = "git commit";
			gp = "git push";
			gl = "git pull";
			gd = "git diff";
			gco = "git checkout";
			gb = "git branch";
			glog = "git log --oneline --graph --decorate";
			
			# Quick directory navigation
			".." = "cd ..";
			"..." = "cd ../..";
			"...." = "cd ../../..";
			
			# Safety nets
			rm = "rm -i";
			cp = "cp -i";
			mv = "mv -i";
		};
		profileExtra = ''
			if [ -z  "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = "1" ]; then
				exec Hyprland
			fi
		'';
		initExtra = ''
			# PATH configuration
			export PATH="/home/c/.local/bin:$PATH"
			
			# Yazi integration
			function y() {
				local tmp="$(mktemp -t 'yazi-cwd.XXXXXX')" cwd
				yazi "$@" --cwd-file="$tmp"
				IFS= read -r -d "" cwd < "$tmp"
				if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
					builtin cd -- "$cwd"
				fi
				rm -f -- "$tmp"
			}
			
			# Git prompt colors (VSCode inspired)
			GIT_PROMPT_CLEAN=$'\001\033[38;5;114m\002'        # Green when clean
			GIT_PROMPT_AHEAD=$'\001\033[38;5;180m\002'        # Yellow when ahead
			GIT_PROMPT_BEHIND=$'\001\033[38;5;203m\002'       # Red when behind
			GIT_PROMPT_MODIFIED=$'\001\033[38;5;180m\002'     # Yellow when modified
			COLOR_RESET=$'\001\033[0m\002'
			COLOR_BLUE=$'\001\033[38;5;75m\002'               # VSCode blue for path
			COLOR_GREEN=$'\001\033[38;5;114m\002'             # VSCode green for prompt
			
			# Function to get git branch and status
			git_prompt_status() {
				local color=""
				local branch_status=""
				
				# Check if we're in a git repository
				if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
					local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --always 2>/dev/null)
					
					if [[ -n "$branch" ]]; then
						# Default to green (clean)
						color=$GIT_PROMPT_CLEAN
						
						# Check if branch is ahead/behind of remote
						if git rev-list --count --left-right @{upstream}...HEAD &>/dev/null 2>&1; then
							local behind=$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null | awk '{print $1}')
							local ahead=$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null | awk '{print $2}')
							
							if [[ "$behind" -gt 0 ]]; then
								# Red if behind remote (needs pull)
								color=$GIT_PROMPT_BEHIND
							elif [[ "$ahead" -gt 0 ]]; then
								# Yellow if ahead of remote (has commits to push)
								color=$GIT_PROMPT_AHEAD
							fi
						fi
						
						# Check for working tree changes
						if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
							# Yellow for uncommitted changes
							color=$GIT_PROMPT_MODIFIED
						fi
						
						# Set branch status with appropriate color
						branch_status="''${color}(''${branch})''${COLOR_RESET}"
					fi
				fi
				
				echo -n "$branch_status"
			}
			
			# Set prompt with path in blue and git status, then green arrow
			PS1="''${COLOR_BLUE}\w''${COLOR_RESET} \$(git_prompt_status)\n''${COLOR_GREEN}❯''${COLOR_RESET} "
			
			# Grep colors
			export GREP_COLORS='ms=38;5;214:mc=38;5;214:sl=:cx=:fn=38;5;141:ln=38;5;114:bn=38;5;114:se=38;5;243'
			
			# GCC colors
			export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
		'';
		sessionVariables = {
			UV_PYTHON = "${pkgs.python312}/bin/python";
			EDITOR = "code";
			VISUAL = "code";
			GIT_EDITOR = "code";
			# Cursor theme variables for Hyprland
			XCURSOR_THEME = "capitaine-cursors";
			XCURSOR_SIZE = "24";
		};
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
	
	# Wrapper script for radian to use R-with-packages
	# Put R-with-packages/bin at the start of PATH so radian finds it first
	home.file.".local/bin/radian-wrapped".text = ''
		#!/usr/bin/env bash
		# Put R-with-packages/bin at the start of PATH so radian finds it first
		export PATH="${R-with-packages}/bin:$PATH"
		exec ${pkgs.radian}/bin/radian "$@"
	'';
	
	home.file.".local/bin/radian-wrapped".executable = true;
	
	# Auto-generate .Renviron with all R package library paths
	# This makes packages available in radian by capturing what R itself sees
	home.file.".Renviron".text = let
		# Get all library paths by actually running R and querying .libPaths()
		# This ensures we get EVERYTHING including base packages and dependencies
		libPathsScript = pkgs.writeShellScript "get-r-libpaths" ''
			${R-with-packages}/bin/R --slave -e 'cat(paste(.libPaths(), collapse=":"))' 2>/dev/null
		'';
		# Execute the script to get the paths
		allPaths = builtins.readFile (pkgs.runCommand "r-libpaths" {} ''
			${libPathsScript} > $out
		'');
	in ''
		# User-writable library for packages that need compilation (e.g., nvimcom)
		R_LIBS_USER="$HOME/.local/lib/R/library:${allPaths}"
	'';
	
	# Create the user R library directory for packages that need compilation
	# Nvim-R will automatically install nvimcom here when needed
	# Use home.activation to ensure proper permissions
	home.activation.createRLibrary = lib.hm.dag.entryAfter ["writeBoundary"] ''
		$DRY_RUN_CMD mkdir -p $HOME/.local/lib/R/library
		$DRY_RUN_CMD chmod 755 $HOME/.local/lib/R/library
	'';
	
	
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
		cursorTheme = {
			name = "capitaine-cursors";
			package = pkgs.capitaine-cursors;
			size = 24;
		};
		gtk3.extraConfig = {
			gtk-application-prefer-dark-theme = true;
		};
		gtk4.extraConfig = {
			gtk-application-prefer-dark-theme = true;
		};
	};
	
	# Hyprland cursor configuration
	home.pointerCursor = {
		gtk.enable = true;
		x11.enable = true;
		name = "capitaine-cursors";
		package = pkgs.capitaine-cursors;
		size = 24;
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

	# Flatpak
  services.flatpak.packages = [
    "com.usebottles.bottles"
  ];
}
