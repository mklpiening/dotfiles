{ pkgs, config, ... }: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
  home.file."${config.xdg.configHome}/nvim" = {
    source = ./dotfiles/nvim;
    recursive = true;
  };
}
