# Claude Code from sadjow/claude-code-nix + its binary cache
{ pkgs, claude-code, ... }:
{
  environment.systemPackages = [
    claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  nix.settings = {
    extra-substituters = [ "https://claude-code.cachix.org" ];
    extra-trusted-public-keys = [
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
    ];
  };
}
