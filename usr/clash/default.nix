{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.mihomo
  ];

  systemd.user.services.clash = {
    Unit = {
      Description = "Auto start clash";
      After = ["network.target"];
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      ExecStart = "${pkgs.mihomo}/bin/mihomo -d %h/Gist/mihomo";
    };
  };

  launchd.agents.clash = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.mihomo}/bin/mihomo"
        "-d"
        "${config.home.homeDirectory}/Gist/mihomo"
      ];
      RunAtLoad = true;
      KeepAlive = {
        Crashed = true;
        SuccessfulExit = false;
      };
      ProcessType = "Background";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/mihomo.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/mihomo.err.log";
    };
  };

  my.syncthing.Gist-stignore = [
    "/mihomo/cache.db*"
  ];
}
