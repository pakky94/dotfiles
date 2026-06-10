{ lib, pkgs, config, ... }:
with lib;
{
  imports = [
    ../../../modules/core.nix
    ./personal.nix
    ./work.nix
  ];

  config = mkIf (config.pakky.programs.git.enable) {
    programs = {
      git = {
        enable = true;
        package = pkgs.gitFull;

        ignores = [
          "tags"
          "*.swp"

          # Nix builds
          "result"

          # Core latex/pdflatex auxiliary files
          "*.aux"
          "*.lof"
          "*.log"
          "*.lot"
          "*.fls"
          "*.out"
          "*.toc"
          "*.fmt"
          "*.fot"
          "*.cb"
          "*.cb2"
          ".*.lb"

          # Python
          "__pycache__/"
          "*.py[cod]"
          "*$py.class"
          ".Python"
          "build/"
          "develop-eggs/"
          "dist/"

          # local env files
          ".envrc"
          ".direnv"
        ];

        settings = {
          commit.verbose = "true";
          merge.conflictStyle = "diff3";
          pull.ff = "only";
          push.autoSetupRemote = "true";
          rerere = {
            autoupdate = "true";
            enabled = "true";
          };
          tag.sort = "version:refname";
          url = {
            "git@github.com:".insteadOf = "gh:";
          };
        };

        lfs.enable = true;
      };

      lazygit = {
        enable = true;
      };
    };

    home.packages = with pkgs; mkIf config.pakky.programs.git.enable [
      pkgs.pre-commit

      (writeShellScriptBin "git-bare-clone" ''
set -e

git clone --bare $1 ./.bare
echo "gitdir: ./.bare" > .git
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
        '')

      (writeShellScriptBin "git-bare-init" ''
set -e

git init --bare ./.bare
echo "gitdir: ./.bare" > .git
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
        '')
    ];
  };

}
