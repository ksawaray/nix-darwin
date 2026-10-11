# nix-darwin

## How to update

```bash
$ sudo darwin-rebuild switch --flake ~/.config/nix-darwin#sawara-macbook
```
## How to update homebrew

```bash
$ nix flake update homebrew-cask
$ sudo darwin-rebuild switch --flake ~/.config/nix-darwin#sawara-macbook
```

