{ config, pkgs, lib, ... }: 
let
  runner = "archbook-runner";
  deployDir = "${config.xdg.dataHome}/github-runner/${runner}/deploy";
  port = 8080;
in {
  imports = [ ../modules/github-runner.nix ];
  
  services.github-runner = {
    enable = true;
    url = "https://github.com/Chengyuan-artist/bt-notes";
    name = runner;
    labels = [ "pages-ci" ];
    tokenFile = "${config.xdg.configHome}/github-runner/hm-runner.token";
    extraPackages = with pkgs; [
      drawio
      xvfb-run
      typst
    ];
    extraEnvironment = {
      DEPLOY_DIR = deployDir;
    };
  };

  systemd.user.services.pages-web = {
    Unit.After = [ "network.target" ];
    Service = {
      ExecStart = "${pkgs.caddy}/bin/caddy file-server --root ${
        lib.escapeShellArg deployDir
      } --listen :${toString port}";
      Restart = "always";
      RestartSec = "3";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
