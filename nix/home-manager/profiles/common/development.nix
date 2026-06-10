{ pkgs, ... }:
let
  dotnetPkg =
    (with pkgs.dotnetCorePackages; combinePackages [
     sdk_8_0
     sdk_9_0
     sdk_10_0
    ]);
in
{
  config.home.packages = with pkgs; [
    atac
    #bun
    cargo
    cmake
    # dotenvx
    elixir
    entr
    gcc
    gh
    go

    jaq
    jq
    gnumake
    nodejs
    pi-coding-agent
    ruby
    unzip
    uv

    jetbrains-toolbox
    dotnetPkg
  ];

  config.home.sessionVariables = {
    DOTNET_ROOT = "${dotnetPkg}";
  };

  config.home.sessionPath = [
    "$HOME/.dotnet/tools"
  ];
}
