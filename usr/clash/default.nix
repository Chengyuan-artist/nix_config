{ config, pkgs, lib, ... }:

{  
  imports = [
    ./tui
  ];

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

  programs.zsh.envExtra = lib.mkBefore ''
    # proxy
    ## default
    HTTP_PROXY="http://127.0.0.1:${toString config.proxyPort}"
    export HTTPS_PROXY="$HTTP_PROXY"
    export HTTP_PROXY="$HTTP_PROXY"
    export FTP_PROXY="$HTTP_PROXY"
    export http_proxy="$HTTP_PROXY"
    export https_proxy="$HTTP_PROXY"
    export ftp_proxy="$HTTP_PROXY"
  '';

  programs.zsh.initContent = lib.mkBefore ''
    unset_proxy() {
      unset HTTPS_PROXY
      unset HTTP_PROXY
      unset FTP_PROXY
      unset https_proxy
      unset http_proxy
      unset ftp_proxy
      unset HTTPS_PORT
      unset HTTP_PORT
      unset FTP_PORT
      unset https_port
      unset http_port
      unset ftp_port
      unset ALL_PROXY
      unset all_proxy
      unset NO_PROXY
      unset no_proxy
      unset RSYNC_PROXY
      unset rsync_proxy
    }
  '';

}
