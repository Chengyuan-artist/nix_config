{ pkgs, ... }: {
  imports = [
    ./basic.nix
    ./nvim-ext
    ./yazi.nix
    # ./pages-ci.nix
    ./gui
  ];
  home.packages = [
    pkgs.wl-clipboard
    pkgs.wget
    pkgs.curl
    pkgs.typst
    pkgs.drawio
    pkgs.xvfb-run
    pkgs.lazygit
    pkgs.npins
    pkgs.yq-go
  ];

  # https://home-manager.dev/manual/26.05/index.xhtml#sec-usage-gpu-sudo
  # Make nixpkgs programs able to use gpu. This method need sudo.
  # Method without sudo is NixGL, but it may have some issues when nix programs lanching native programs.
  targets.genericLinux.enable = true;

  # 中日韩字体优先级：简体中文 > 繁体中文 > 日文
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Noto Sans CJK SC" "Noto Sans CJK TC" "Noto Sans CJK JP" ];
    serif = [ "Noto Serif CJK SC" "Noto Serif CJK TC" "Noto Serif CJK JP" ];
    monospace = [ "Noto Sans Mono CJK SC" "Noto Sans Mono CJK TC" "Noto Sans Mono CJK JP" ];
  };
}
