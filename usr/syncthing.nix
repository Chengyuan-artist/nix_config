{ config, ... }: {
  services.syncthing = {
    enable = true;
    overrideFolders = false;
    overrideDevices = false;
  };

  systemd.user.services.syncthing.Service.Environment = [
    "http_proxy=http://127.0.0.1:${toString config.proxyPort}"
    "https_proxy=http://127.0.0.1:${toString config.proxyPort}"
  ];

  launchd.agents.syncthing.config.EnvironmentVariables = {
    http_proxy = "http://127.0.0.1:${toString config.proxyPort}";
    https_proxy = "http://127.0.0.1:${toString config.proxyPort}";
  };
}
