{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = false;
    syntaxHighlighting.enable = true;
    
    historySubstringSearch.enable = true;

    plugins = [
      { name = "fzf-tab"; src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";}
      { name = "vi-mode"; src = pkgs.zsh-vi-mode; file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";}
    ];

    history = {
      size = 10000;
      ignoreAllDups = true;
      extended = true;
    };

    localVariables = {
      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = true;
    };

    initContent = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # fzf-tab: 用 Tab 选中（覆盖默认的 tab:down / enter 接受）
      zstyle ':fzf-tab:*' fzf-bindings 'tab:accept' 'enter:ignore'
      
      bindkey -M viins  "^W" vi-backward-kill-word

      # https://unix.stackexchange.com/questions/58870/ctrl-left-right-arrow-keys-issue
      bindkey -M viins  "^[[1;5C" forward-word
      bindkey -M viins  "^[[1;5D" backward-word
      bindkey -M visual "^[[1;5C" forward-word
      bindkey -M visual "^[[1;5D" backward-word
      bindkey -M vicmd  "^[[1;5C" forward-word
      bindkey -M vicmd  "^[[1;5D" backward-word
      bindkey -M viopp  "^[[1;5C" forward-word
      bindkey -M viopp  "^[[1;5D" backward-word

      # Match Neovim's default 'iskeyword' word model for ctrl+left/right:
      # letters, digits, and `_` are words; punctuation such as `/`, `.`, and
      # `-` are boundaries. This makes URL/path movement in zsh line up with
      # Neovim's small-word motions (`w`/`b`/`e`).
      WORDCHARS=_
    '';

    shellAliases = {
      gst = "git status";
      ssh="kitten ssh";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true; # 自动定义 ls / ll / la / lt / lla
    icons = "auto";
    colors = "auto";
    git = true;
    theme = {
      filekinds.directory = {
        foreground = "Blue";
        is_bold = true;
      };
    };
  };

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    zsh-completions
    nerd-fonts.fira-code
  ];
    
  home.file.".p10k.zsh".source = ./p10k.zsh;
}
