{ lib, ... }: {
  options.my.tailscale.devices = lib.mkOption {
    type = lib.types.attrsOf ( lib.types.submodule { options = {
      user = lib.mkOption {
        type = lib.types.str;
      };
      ip = lib.mkOption {
        type = lib.types.str;
      };
    };});
  };
}
