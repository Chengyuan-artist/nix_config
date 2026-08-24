{pkgs, ...}:
{
  imports = [
    # zig
    {programs.neovim={initLua="vim.lsp.enable('zls')\n";extraPackages=[pkgs.zls];};}
    # nix
    {programs.neovim={initLua="vim.lsp.enable('nixd')\n";extraPackages=[pkgs.nixd];};}
    # emmylua
    {
      programs.neovim = {
        initLua = /*lua*/''
          vim.lsp.config('emmylua_ls', {
            cmd = { 'emmylua_ls', '--log-path', 'none' },
          })
          vim.lsp.enable('emmylua_ls')
        '';
        extraPackages = [ pkgs.emmylua-ls ];
      };
      home.packages = [ pkgs.emmylua-check ];
    }
  ];
  programs.neovim = {
    plugins = [
      {
        plugin = pkgs.vimPlugins.nvim-lspconfig;
        type = "lua";
        config = ''
          vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if client and client.server_capabilities.inlayHintProvider then
                -- Enable inlay hints by default on attach
                vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
              end
              vim.keymap.set('n', 'K', vim.lsp.buf.hover)
              vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename)

              -- make sure lsp/vim native indent(share/nvim/runtime/indent/python.vim)
              -- don't override my setting
              vim.opt.tabstop = 2
              vim.opt.shiftwidth = 2
            end,
          })

          vim.keymap.set('n', '<leader>th', function()
            local current = vim.lsp.inlay_hint.is_enabled()
            vim.lsp.inlay_hint.enable(not current)
          end, { desc = 'Toggle Inlay Hints' })
        '';
      }
    ];
  };
}
