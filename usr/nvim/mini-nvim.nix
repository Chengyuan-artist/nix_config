{ pkgs, ... }:
let
  my-mini-nvim = {
    plugin = pkgs.vimPlugins.mini-nvim;
    type = "lua";
    config = ''
      require('mini.indentscope').setup{
        options = {
          try_as_border = true,
        },
      }

      -- mini.animate looks promising, and can totally replace vim-smoothie
      -- However, bugs seem exist:
      -- * touchpad scroll become slow
      -- * background color blinks when create window
      -- * background color broken after q::q
      -- require('mini.animate').setup()

      require('mini.icons').setup()
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-mini-nvim
    ];
  };
}