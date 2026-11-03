{ config, pkgs, ... }: let
  mihomo-tui = pkgs.callPackage ./package.nix {};
  
  clashBase = builtins.fromJSON (
    builtins.readFile
      "${config.home.homeDirectory}/Gist/mihomo/base.json"
  );

  yaml = pkgs.formats.yaml {};
in {
  home.packages = [
    pkgs.mihomo
    mihomo-tui
    (pkgs.makeDesktopItem {
      name = "mihomo-tui";
      desktopName = "Mihomo TUI";
      keywords = ["mihomo" "clash" "tui"];
      exec = "kitty mihomo-tui";
      icon = pkgs.mihomo.src + /Meta.png;
    })
  ];
 
  home.file.".config/mihomo-tui/config.yaml".source =
    yaml.generate "mihomo-tui-config.yaml" {
      mihomo-api = "http://${clashBase.external-controller}";
      mihomo-secret = clashBase.secret;
      log-file = "/tmp/mihomo-tui.log";
    };
}
