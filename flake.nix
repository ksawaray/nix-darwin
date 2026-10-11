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
          # Nix 本体の管理をオフにする
          nix.enable = false;

          # ユーザ名の設定
          system.primaryUser = "sawara";

          # ホスト名の設定
          networking.hostName = "sawara-macbook";
          networking.computerName = "sawara-macbook";
          networking.localHostName = "sawara-macbook";

          # アーキテクチャの指定
          nixpkgs.hostPlatform = "aarch64-darwin"; # Apple Siliconの場合

          # 基本設定
          #nix.settings.experimental-features = "nix-command flakes";
          system.stateVersion = 6;

          # システムの設定
          #system.defaults.dock.autohide = true; # Dock を隠す

          # Homebrew 本体の管理
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

          # brew でのパッケージインストール
          homebrew = {
            enable = true;
            taps = builtins.attrNames config.nix-homebrew.taps;
            brews = [
            ];
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
        })
      ];
    };
  };
}
