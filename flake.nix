{
  description = "Sawara's Darwin System Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask }: {
    darwinConfigurations."sawara-macbook" = nix-darwin.lib.darwinSystem {
      modules = [ 
        nix-homebrew.darwinModules.nix-homebrew
        ({ pkgs, config, ... }: {
          # Disable Nix self-management
          nix.enable = false;

          # Set username
          system.primaryUser = "sawara";

          # Set hostname
          networking.hostName = "sawara-macbook";
          networking.computerName = "sawara-macbook";
          networking.localHostName = "sawara-macbook";

          # Specify architecture
          nixpkgs.hostPlatform = "aarch64-darwin"; # For Apple Silicon

          # Basic settings
          #nix.settings.experimental-features = "nix-command flakes";
          system.stateVersion = 6;

          # System settings
          #system.defaults.dock.autohide = true; # Hide the Dock

          # Manage Homebrew itself
          nix-homebrew = {
            enable = true;
            user = "sawara";
            enableRosetta = false;
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };
            mutableTaps = false;
            autoMigrate = true;
          };

          # Install packages via brew
          homebrew = {
            enable = true;
            taps = builtins.attrNames config.nix-homebrew.taps;
            brews = [
            ];
            # Apps that require manual installation (not manageable via nix):
            # - Muse from Meta: https://ai.meta.com/muse/download/
            #   Reason: Download requires Meta account authentication (signed URL)
            #   App Store ID: 6760173601 but no macOS version is available
            casks = [
              "google-chrome"
              "karabiner-elements"
              "visual-studio-code"
              "iterm2"
              "claude"
              "slack"
              "windows-app"
              "displaylink"
              "tunnelblick"
              "discord"
            ];
            onActivation = {
              autoUpdate = false;
              upgrade = false;
              cleanup = "none";
            };
          };

          # Install duti for file association
          environment.systemPackages = [ pkgs.duti ];

          # Set VS Code as the default app for .md files
          # Skip if already configured, as macOS shows a confirmation dialog on change
          system.activationScripts.postActivation.text = ''
            if [ "$(sudo -u ${config.system.primaryUser} ${pkgs.duti}/bin/duti -d net.daringfireball.markdown 2>/dev/null)" != "com.microsoft.VSCode" ]; then
              echo "Setting default app for Markdown..."
              sudo -u ${config.system.primaryUser} ${pkgs.duti}/bin/duti -s com.microsoft.VSCode net.daringfireball.markdown all
            fi
          '';
        })
      ];
    };
  };
}
