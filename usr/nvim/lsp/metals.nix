{ pkgs, ... }:
{
  programs.neovim = {
    initLua = /*lua*/ ''
      vim.lsp.config("metals", {
        init_options = {
          statusBarProvider = "off",
        },
      })
      vim.lsp.enable("metals")
    '';

    extraPackages = [
      ((pkgs.metals.override {
        jre = pkgs.jre;
      }).overrideAttrs (old: {
        extraJavaOpts = toString [
          old.extraJavaOpts
          # Use mill from the system when available.
          "-Dmetals.millScript=mill"
          "-Dmetals.javaHome=${pkgs.jre}"
          "-Dmetals.defaultBspToBuildTool=true"
        ];
      }))
      (pkgs.coursier.override { jre = pkgs.jre; })
    ];
  };
}
