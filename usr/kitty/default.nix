{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    # Arch（非 NixOS）上 nixpkgs 的 kitty 找不到系统 Mesa/EGL 驱动，
    # EGL/GLX 初始化失败。只管理配置，二进制用系统的 /usr/bin/kitty。
    package = null;

    font = {
      package = pkgs.nerd-fonts.meslo-lg;
      name = "MesloLGL Nerd Font";
      size = 12;
    };

    extraConfig = ''
      map --allow-fallback=shifted,ascii kitty_mod+t new_tab_with_cwd
    '';
  };
}
