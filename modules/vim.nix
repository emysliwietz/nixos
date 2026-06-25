{ config, lib, pkgs, ... }:

{
  home-manager.users.user =  {
    programs.neovim = {
      enable = true;
      defaultEditor = false;
      viAlias = true;
      vimAlias = true;
      extraLuaConfig = ''
        vim.opt.number = true
          vim.opt.relativenumber = true
          vim.opt.clipboard = "unnamedplus"
      '';
    };
  };
}
