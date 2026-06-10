{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.pakky;
in
{
  config = mkIf cfg.programs.zsh.enable {
    programs.zsh = {
      enable = true;

      autocd = true;
      autosuggestion.enable = true;
      enableCompletion = true;

      dotDir = ".config/zsh";
      sessionVariables = { 
        ZDOTDIR = "/home/${cfg.home-manager.username}/.config/zsh"; 
        ${if config.pakky.programs.git.overrideGitSsh then "GIT_SSH" else null} = "/usr/bin/ssh";
        # SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent.socket";
      };

      initContent = ''
autoload -z edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line
      '';
# # SSH Agent should be running, once
# runcount=$(ps -ef | grep "ssh-agent" | grep -v "grep" | wc -l)
# if [ $runcount -eq 0 ]; then
#     echo Starting SSH Agent
#     eval $(ssh-agent -s -a $SSH_AUTH_SOCK)
# fi
#       '';

      shellAliases = {
        acestreamstart = "docker run --name acestream -d --rm -p 6878:6878 docker.io/blaiseio/acelink";
        acestreamstop = "docker stop acestream";
        cat = "bat --pager=never";
        lg = "lazygit";
        nixdev = "nix develop -c $SHELL";
        zz = "z -";
      };

      plugins = [
        {
          name = "fzf-tab";
          src = pkgs.fetchFromGitHub {
            owner = "Aloxaf";
            repo = "fzf-tab";
            rev = "e394092c17277c84cb3d234917c4ac1073102ba6";
            sha256 = "4A7zpaO1rNPvS0rrmmxg56rJGpZHnw/g+x5FJd0EshI=";
          };
        }
      ];
    };

    programs.bat = {
      enable = true;
      config = { theme = "base16"; };
    };

    programs.dircolors = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.direnv = {
      enable = true;
    };

    programs.eza = {
      enable = true;
    };

    programs.fzf = {
      enable = true;
    };

    programs.zoxide = {
      enable = true;
    };

    # users.users.${cfg.home-manager.username}.shell = mkIf cfg.programs.zsh.default pkgs.zsh ;

    # users.users.${cfg.home-manager.username}.shell = pkgs.zsh;

    # if cfg.zsh.default then {
    #   users.users.${cfg.home-manager.username}.shell = pkgs.zsh;
    # };

  };
}
