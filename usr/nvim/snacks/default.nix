{ pkgs, ... }: {
  imports = [
    ./picker/config.nix
    ./image/config.nix
  ];
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.snacks-nvim;
      type = "lua";
      config = /*lua*/ ''
        require("snacks").setup({
          ${import ./scroll/lua.nix}
          ${import ./picker/lua.nix}
          ${import ./image/lua.nix}
        })
      '';
    }];
  };
}
