{ pkgs, ... }:

{
  home.username = "zcy";
  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/zcy"
    else "/home/zcy";

  home.stateVersion = "26.05"; # Please read the comment before changing.

  news.display = "silent";

  imports = [
    ./nvim
    ./clash
    ./tailscale
    ./zsh
    ./syncthing.nix
    ../modules
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # rg, git and man cli
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--no-ignore-vcs"
    ];
  };
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Chengyuan Zhang";
        email = "1136427613@qq.com";
      };
      core.editor = "nvim";
    };
  };
  programs.gh.enable = true;
  programs.man.enable = true;
  programs.info.enable = true;

  # NIX_PATH check and export
  programs.zsh.initContent = ''
    . ${toString ../scripts/main.sh}
  '';
  
  # zsh.envExtra give ssh "cmd" environment
  programs.zsh.envExtra = /*bash*/ ''
    if [[ -e "$HOME/.config/npins/nixpkgs" && -e "$HOME/.config/npins/home-manager" ]]; then
      export NIX_PATH="nixpkgs=$HOME/.config/npins/nixpkgs:home-manager=$HOME/.config/npins/home-manager"
    fi
  '';
}
