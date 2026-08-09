{pkgs, ...}:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraConfig = /*vim*/ ''
      set expandtab
      set tabstop=2
      set shiftwidth=2

      xmap <Leader>a <Plug>(EasyAlign)
      nmap <Leader>a <Plug>(EasyAlign)
    '';

    initLua = /*lua*/ ''
      vim.opt.clipboard = "unnamedplus"

      -- SSH 环境使用 OSC 52，将内容复制到客户端剪贴板
      if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
        local osc52 = require("vim.ui.clipboard.osc52")

        vim.g.clipboard = {
          name = "OSC 52",
          copy = {
            ["+"] = osc52.copy("+"),
            ["*"] = osc52.copy("*"),
          },
          paste = {
            ["+"] = osc52.paste("+"),
            ["*"] = osc52.paste("*"),
          },
        }
      end
    '';
  };

  imports = [
    ./lsp
    ./snacks
    ./mini-nvim.nix
    ./blink-cmp.nix
  ];

  programs.neovim.extraPackages = [
    pkgs.tree-sitter
  ];

  programs.neovim.plugins = [
    pkgs.vimPlugins.vim-easy-align
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
