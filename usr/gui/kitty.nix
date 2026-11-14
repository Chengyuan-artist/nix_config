{ pkgs, ... }: {
  programs.kitty = {
    enable = true;

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

      globinclude dank-*.conf
    '';
  };

  home.packages = with pkgs;[ 
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    noto-fonts-color-emoji
  ];
}
