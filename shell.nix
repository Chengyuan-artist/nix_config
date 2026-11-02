let
  sources = import ./npins;

  pkgs = import sources.nixpkgs {};

  hm = import sources.home-manager {
    inherit pkgs;
  };
in
pkgs.mkShell {
  packages = [
    pkgs.npins
    hm.home-manager
  ];

  NIX_PATH =
    "nixpkgs=${sources.nixpkgs}:home-manager=${sources.home-manager}";
}
