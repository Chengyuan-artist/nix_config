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
    {
      plugin = pkgs.vimPlugins.render-markdown-nvim;
      type = "lua";
      config = /*lua*/ ''
        require('render-markdown').setup({
          completions = { lsp = { enabled = true } },
            -- 保留标题背景高亮，但不替换 #。
          heading = {
            sign = false,
          },

          -- 只保留代码背景，不隐藏围栏或增加语言标题。
          code = {
            conceal_delimiters = false,
            language = false,
            border = "none",
          },

          -- 这些组件会用不同宽度的字符替换原始标记。
          --dash = {
          --  enabled = false,
          --},
          --bullet = {
          --  enabled = false,
          --},
          --checkbox = {
          --  enabled = false,
          --},
          --quote = {
          --  enabled = false,
          --},

          -- 保留表格字符替换，但不填充列宽、不添加上下边框。
          pipe_table = {
            cell = "raw",
            border_enabled = false,
          },

          -- 不在链接前增加图标。
          link = {
            enabled = false,
          },

          -- LaTeX 转换后的字符宽度可能与源码不同。
          --latex = {
          --  enabled = false,
          --},

          -- 不隐藏 HTML 注释。
          html = {
            comment = {
              conceal = false,
            },
          },

          -- normal/insert 模式始终显示原始 Markdown 标记。
          win_options = {
            conceallevel = {
              default = 0,
              rendered = 0,
            },
          },
        })
      '';
    }
  ];
}
