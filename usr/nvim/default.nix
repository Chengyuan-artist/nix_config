{pkgs, ...}:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  imports = [
    ./lsp
    ./snacks
    ./mini-nvim.nix
  ];

  programs.neovim.extraPackages = [
    pkgs.tree-sitter
  ];

  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
      type = "lua";
      config = ''
        vim.api.nvim_create_autocmd("FileType", {
          callback = function(args) pcall(vim.treesitter.start, args.buf) end,
        })
      '';
    }
    {
      plugin = pkgs.vimPlugins.zig-vim;
      type = "lua";
      config = ''
        -- don't show parse errors in a separate window
        vim.g.zig_fmt_parse_errors = 0
        -- disable format-on-save from `ziglang/zig.vim`
        vim.g.zig_fmt_autosave = 0
      '';
    }
  ];
}
