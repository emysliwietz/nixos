{ config, lib, pkgs, ... }:

{
  home-manager.users.user = {
    programs.git = {
      enable = true;
      settings.user = {
        name = "Egidius";
        email = "git@sermak.xyz";
      };
      settings = {
        credential.helper = "store";
        # caches in ~/.git-credentials
      };
    };
  };

  environment.etc."gitconfig".text = ''
    [user]
      name = "Egidius"
      email = "git@sermak.xyz"
    [credential]
      helper = store
  '';

}
