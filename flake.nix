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
            # 手動インストールが必要なアプリ（nixで管理不可）:
            # - Muse from Meta: https://ai.meta.com/muse/download/
            #   理由: ダウンロードにMetaアカウント認証が必要（signed URL）
            #   App Store ID: 6760173601 だがmacOS版は未提供
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

          # ファイルの関連付け用に duti をインストール
          environment.systemPackages = [ pkgs.duti ];

          # .md のデフォルトアプリを VS Code にする
          # 変更時は macOS の確認ダイアログが出るため、すでに設定済みならスキップする
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
