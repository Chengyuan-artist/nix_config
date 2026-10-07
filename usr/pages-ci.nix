{ config, pkgs, ... }: 
let
  runner = "archbook-runner";
  deployDir = "${config.xdg.dataHome}/github-runner/${runner}/deploy";
  port = 8080;

  # 内网 basic_auth 保护静态页面。
  # 重新生成哈希: nix-shell -p caddy --run "caddy hash-password --plaintext '密码'"
  caddyfile = pkgs.writeText "pages-Caddyfile" ''
    http://:${toString port} {
      basic_auth {
        guanchuan $2a$14$2s.YzWAtbW9HNoutxyLWyOs3bfYQ.0b0.qrQZhlxMcDEBafHF0qwK
      }
      root * ${deployDir}
      file_server
    }
  '';
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
      ExecStart = "${pkgs.caddy}/bin/caddy run --config ${caddyfile} --adapter caddyfile";
      Restart = "always";
      RestartSec = "3";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
