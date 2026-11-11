{ pkgs, ... }: {
  imports = [
    ./basic.nix
    ./nvim-ext
    ./kitty
    ./yazi.nix
    ./pages-ci.nix
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
  ];

  # 中日韩字体优先级：简体中文 > 繁体中文 > 日文
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Noto Sans CJK SC" "Noto Sans CJK TC" "Noto Sans CJK JP" ];
    serif = [ "Noto Serif CJK SC" "Noto Serif CJK TC" "Noto Serif CJK JP" ];
    monospace = [ "Noto Sans Mono CJK SC" "Noto Sans Mono CJK TC" "Noto Sans Mono CJK JP" ];
  };
}
