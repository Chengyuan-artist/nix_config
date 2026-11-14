{ ... }:
let
  sources = import ../../npins;

  unstable = import sources.nixpkgs-unstable {
    # 适用于你当前的非 flake、原生系统配置
    system = builtins.currentSystem;
  };

  dms = unstable.dux-shell;
in {
  imports = [
    # 从包对应的源码加载模块，避免另 pin 一份不同版本。
    # 上游 flake 会注入 dmsPkgs；使用 npins 时这里手动提供。
    ({ pkgs, ... }@args:
      import "${dms.src}/distro/nix/home.nix" (args // {
        dmsPkgs = { dms-shell = dms; };
      }))
  ];

  programs.dank-material-shell = {
    enable = true;
    package = dms;
    quickshell.package = unstable.quickshell;

    systemd = {
      enable = true;
      target = "niri.service";
    };
  };

  # 接管主配置的链接，继续使用现有、可编辑的 KDL。
  #xdg.configFile."niri/config.kdl".source =
  #  config.lib.file.mkOutOfStoreSymlink
  #   "${repo}/dotfiles/niri/config.kdl";
}
