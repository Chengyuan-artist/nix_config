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
