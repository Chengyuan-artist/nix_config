{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    # 退出 yazi 后让 shell 自动 cd 到上次浏览的目录。
    enableZshIntegration = true;
  };
}
