# github-runner.nix
#
# A home-manager module that manages a GitHub Actions self-hosted runner as a
# systemd --user service on a non-NixOS host (e.g. Ubuntu/macOS-with-nix).
#
# Design constraints (per current requirements):
#   * Authentication: PAT only (no registration token, no GitHub App).
#   * No automatic re-registration: the runner is configured exactly once.
#     Changing url/name/labels after the first start has NO effect unless you
#     remove the state dir yourself (see "State" below).
#   * No ephemeral mode.
#
# State layout:
#   $XDG_DATA_HOME/github-runner/<name>/       <- RUNNER_ROOT (.runner/.credentials)
#   $XDG_DATA_HOME/github-runner/<name>/work  <- job work dir
#
# The nixpkgs `github-runner` package is wrapped so that RUNNER_ROOT controls
# where the runner keeps its config; we point it at the persistent state dir.
#
# Usage:
#   imports = [ ./github-runner.nix ];
#   services.github-runner = {
#     enable = true;
#     url = "https://github.com/my-org";   # org URL, or a repo URL
#     name = "hm-runner";
#     tokenFile = "${config.xdg.configHome}/github-runner/hm-runner.token";
#   };
#
# The token file must contain exactly one line (no trailing newline):
#   printf '%s' 'github_pat_xxx' > ~/.config/github-runner/hm-runner.token
#
# SECURITY: pass tokenFile as a STRING ("..." or agenix/sops `.path`), never as
# a path literal (./token). A path literal is a Nix path value and would be
# copied verbatim into /nix/store, leaking the token.
#
{ config, lib, pkgs, ... }:

let
  cfg = config.services.github-runner;

  # Persistent runner state; holds .runner / .credentials.
  stateDir = "${config.xdg.dataHome}/github-runner/${cfg.name}";
  workDir = "${stateDir}/work";

  runtimePath = lib.makeBinPath (
    with pkgs;
    [
      bashInteractive
      coreutils
      git
      nix
      gnutar
      gzip
      gnumake
    ]
    ++ cfg.extraPackages
  );

  # One-shot, idempotent registration. Runs before every start but only does
  # work the first time (when $RUNNER_ROOT/.runner is absent).
  configure = pkgs.writeShellApplication {
    name = "hm-github-runner-configure";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      set -euo pipefail
      root="$1"; work="$2"; tokenFile="$3"

      mkdir -p "$root" "$work"

      # No re-registration: already configured -> leave it untouched.
      if [[ -f "$root/.runner" ]]; then
        echo "[hm-github-runner] already registered, skipping configure"
        exit 0
      fi

      if [[ ! -r "$tokenFile" ]]; then
        echo "[hm-github-runner] token file not readable: $tokenFile" >&2
        exit 1
      fi

      token="$(< "$tokenFile")"

      echo "[hm-github-runner] registering runner '${cfg.name}'"
      RUNNER_ROOT="$root" ${cfg.package}/bin/Runner.Listener configure \
        --unattended \
        --disableupdate \
        --work "$work" \
        --url ${lib.escapeShellArg cfg.url} \
        --name ${lib.escapeShellArg cfg.name} \
        --labels ${lib.escapeShellArg (lib.concatStringsSep "," cfg.labels)} \
        ${lib.optionalString (cfg.runnerGroup != null)
          "--runnergroup ${lib.escapeShellArg cfg.runnerGroup}"} \
        ${lib.optionalString cfg.replace "--replace"} \
        --pat "$token"
    '';
  };
in
{
  options.services.github-runner = {
    enable = lib.mkEnableOption "GitHub Actions self-hosted runner (home-manager user service)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.github-runner;
      defaultText = lib.literalExpression "pkgs.github-runner";
      description = "The github-runner package to use.";
    };

    url = lib.mkOption {
      type = lib.types.str;
      example = "https://github.com/my-org";
      description = ''
        Repository or organization URL to register the runner with.

        Use an organization URL (e.g. https://github.com/my-org) when the PAT
        is organization-wide; a repository URL otherwise. The token scope must
        match this URL, otherwise registration fails with a 404.
      '';
    };

    name = lib.mkOption {
      type = lib.types.str;
      default = "hm-runner";
      description = "Name to register the runner under (must be unique in the scope).";
    };

    labels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "nixos" "home" ];
      description = "Extra labels to attach to the runner.";
    };

    runnerGroup = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Runner group to join (organization-level only).";
    };

    tokenFile = lib.mkOption {
      type = lib.types.str;
      description = ''
        Absolute path (as a STRING) to a file containing a single-line PAT
        (no trailing newline).

        IMPORTANT: pass a string such as "/run/secrets/gh.token" or an
        agenix/sops-nix `.path`, NOT a path literal like ./token. A path literal
        is a Nix path value and would be copied verbatim into /nix/store,
        leaking the token. The `types.str` type here rejects path literals so
        this cannot happen by accident.
      '';
    };

    replace = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Pass --replace when registering, allowing an existing same-named runner to be replaced.";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra packages added to PATH for the runner service (available to workflows).";
    };

    extraEnvironment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = { NIX_CONFIG = "experimental-features = nix-command flakes"; };
      description = "Extra environment variables for the runner service.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create the persistent directories.
    home.activation.githubRunnerDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p ${lib.escapeShellArg stateDir} ${lib.escapeShellArg workDir}
      $DRY_RUN_CMD chmod 700 ${lib.escapeShellArg stateDir}
    '';

    systemd.user.services.github-runner = {
      Unit = {
        Description = "GitHub Actions runner (${cfg.name})";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "simple";
        WorkingDirectory = workDir;

        Environment = [
          "RUNNER_ROOT=${stateDir}"
          "PATH=${runtimePath}"
        ] ++ lib.mapAttrsToList (k: v: "${k}=${v}") cfg.extraEnvironment;

        ExecStartPre = "${configure}/bin/hm-github-runner-configure ${stateDir} ${workDir} ${lib.escapeShellArg cfg.tokenFile}";
        ExecStart = "${cfg.package}/bin/Runner.Listener run --startuptype service";

        Restart = "always";
        RestartSec = 5;
        # Runner return code 2 == retryable error.
        RestartForceExitStatus = 2;
        KillSignal = "SIGINT";
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
