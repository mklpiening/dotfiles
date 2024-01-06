{ pkgs, config, lib, ... }: 
let
  # declare plugins
  catppuccin = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "catppuccin";
    version = "unstable-2022-12-14";
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "tmux";
      rev = "e2561decc2a4e77a0f8b7c05caf8d4f2af9714b3";
      sha256 = "sha256-6UmFGkUDoIe8k+FrzdzsKrDHHMNfkjAk0yyc+HV199M=";
    };
    postInstall = ''
      sed -i -e 's|''${PLUGIN_DIR}/catppuccin-selected-theme.tmuxtheme|''${TMUX_TMPDIR}/catppuccin-selected-theme.tmuxtheme|g' $target/catppuccin.tmux
    '';
  };
in {
  # tmux config
  programs.tmux = {
    enable = true;
    clock24 = true;
    terminal = "screen-256color";
    plugins = [
      catppuccin
    ];
    extraConfig = ''
      set-option -g terminal-overrides ',xterm-256color:RGB'
      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'tmux-plugins/tmux-sensible'
      set -g @plugin 'tmux-plugins/tmux-yank'
      set -g @plugin 'tmux-plugins/tmux-resurrect'
      set -g @plugin 'tmux-plugins/tmux-continuum'
      set -g @plugin 'fcsonline/tmux-thumbs'
      set -g @plugin 'sainnhe/tmux-fzf'
      set -g @plugin 'wfxr/tmux-fzf-url'
      set -g @plugin 'omerxx/catppuccin-tmux' # My fork that holds the meetings script bc I'm lazy af
      set -g @plugin 'omerxx/tmux-sessionx'
    '';
  };
}
