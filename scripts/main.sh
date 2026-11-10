if [[ ! -d ~/.config/npins || ~/.config/npins-timestamp -ot ~/.config/nixpkgs/npins/sources.json ]]; then
  mkdir -p ~/.config/npins
  nix-store --add-root ~/.config/npins/nixpkgs      \
    --realise $(nix --extra-experimental-features nix-command eval --impure --expr '(import ~/.config/nixpkgs/npins).nixpkgs.outPath' | tr -d '"')
  nix-store --add-root ~/.config/npins/home-manager \
    --realise $(nix --extra-experimental-features nix-command eval --impure --expr '(import ~/.config/nixpkgs/npins).home-manager.outPath' | tr -d '"')
  touch ~/.config/npins-timestamp
fi

NIX_PATH="nixpkgs=$(realpath ~/.config/npins/nixpkgs):home-manager=$(realpath ~/.config/npins/home-manager)"
export NIX_PATH
