{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    # Arch（非 NixOS）上 nixpkgs 的 kitty 找不到系统 Mesa/EGL 驱动，
    # EGL/GLX 初始化失败。只管理配置，二进制用系统的 /usr/bin/kitty。
    package = null;

    font = {
      name = "MesloLGS Nerd Font";
      size = 12;
    };

    extraConfig = ''
      italic_font family="JetBrainsMono Nerd Font" style="Italic"
      bold_italic_font family="JetBrainsMono Nerd Font" style="Bold Italic"

      map ctrl+= change_font_size all +2.0
      map ctrl+shift+= change_font_size all +1.0
      map ctrl+- change_font_size all -2.0
      map ctrl+shift+- change_font_size all -1.0
      map ctrl+0 change_font_size all 0

      map --allow-fallback=shifted,ascii kitty_mod+t new_tab_with_cwd
    '';
  };

  home.packages = with pkgs;[ 
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];
}
