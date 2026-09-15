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
      plugin = pkgs.vimPlugins.tokyonight-nvim;
      type = "lua";
      config = ''
        vim.cmd[[colorscheme tokyonight-night]]
      '';
    }
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
    {
      plugin = pkgs.vimPlugins.todo-comments-nvim;
      type = "lua";
      config = ''
        require("todo-comments").setup({
          -- 可以在此自定义配置选项
          signs = true, -- 标语栏显示图标
          keywords = {
            FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "ISSUE" } },
            TODO = { icon = " ", color = "info" },
            HACK = { icon = " ", color = "warning" },
            WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
            PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
            NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
          },
          highlight = {
            comments_only = false,
          },
        })
      '';
    }
    {
      plugin = pkgs.vimPlugins.gitsigns-nvim;
      type = "lua";
      config = ''
        require('gitsigns').setup()
      '';
    }
  ];
}
