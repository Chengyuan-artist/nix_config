{ lib, ... }: {
  options = {
    proxyPort = lib.mkOption {
      type = lib.types.number;
      default = 7890;
      description = ''
        代理端口号
      '';
    };
  };
}
