{pkgs, ...}:
{
  imports = [
    # zig
    {programs.neovim={initLua="vim.lsp.enable('zls')\n";extraPackages=[pkgs.zls];};}
  ];
  programs.neovim = {
    plugins = [
      {
        plugin = pkgs.vimPlugins.nvim-lspconfig;
      }
    ];
  };
}