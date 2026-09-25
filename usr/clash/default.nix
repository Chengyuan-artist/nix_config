{ pkgs, ... }: {
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

  my.syncthing.Gist-stignore = [
    "/mihomo/cache.db*"
  ];
}
