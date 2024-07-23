{ pkgs, config, lib, ... }: 
let
  # my slightly customized version of catppuccin
  catppuccin = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "catppuccin";
    version = "2023-11-01";
    src = pkgs.fetchFromGitHub {
      owner = "mklpiening";
      repo = "catppuccin_tmux";
      rev = "4bbfe07f974f85b2844742eb55bc9abf8099a1bd";
      sha256 = "sha256-ZdE3dHUTWQYczg0kROJRk4Y9+sOzBTPqVm9k2fz3WNs=";
    };
    postInstall = ''
      sed -i -e 's|''${PLUGIN_DIR}/catppuccin-selected-theme.tmuxtheme|''${TMUX_TMPDIR}/catppuccin-selected-theme.tmuxtheme|g' $target/catppuccin.tmux
    '';
  };
in {
  # tmux config
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    terminal = "screen-256color";
    historyLimit = 100000;
    plugins = [
      {                             # pastel colore theme
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_window_left_separator ""
          set -g @catppuccin_window_right_separator " "
          set -g @catppuccin_window_middle_separator " █"
          set -g @catppuccin_window_number_position "right"
          set -g @catppuccin_window_default_fill "number"
          set -g @catppuccin_window_default_text "#W"
          set -g @catppuccin_window_current_fill "number"
          set -g @catppuccin_window_current_text "#W#{?window_zoomed_flag,(),}"

          set -g @catppuccin_status_modules_right "directory date_time"
          set -g @catppuccin_status_modules_left "session"
          set -g @catppuccin_status_left_separator  " "
          set -g @catppuccin_status_right_separator " "
          set -g @catppuccin_status_right_separator_inverse "no"
          set -g @catppuccin_status_fill "icon"
          set -g @catppuccin_status_connect_separator "no"

          set -g @catppuccin_directory_text "#{b:pane_current_path}"
          set -g @catppuccin_date_time_text "%H:%M"

          # navigation
          bind-key -n 'C-h' select-pane -L
          bind-key -n 'C-j' select-pane -D
          bind-key -n 'C-k' select-pane -U
          bind-key -n 'C-l' select-pane -R
          bind-key -n 'C-\' select-pane -l
          
          # switch between light and dark
          bind-key o set -g @catppuccin_flavour 'latte' \; source-file ~/.config/tmux/tmux.conf
          bind-key O set -g @catppuccin_flavour 'mocha' \; source-file ~/.config/tmux/tmux.conf
        '';
      }
      pkgs.tmuxPlugins.sensible     # some common settings
      pkgs.tmuxPlugins.yank         # copy to system clipboard
      {                             # save and restore tmux
        plugin = pkgs.tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      # pkgs.tmuxPlugins.continuum    # automatic tmux save and restore
      pkgs.tmuxPlugins.tmux-thumbs  # search current tmux view and use the selection for autofill
      pkgs.tmuxPlugins.tmux-fzf     # fzf to manage tmux sessions, windows and panes
    ];
    extraConfig = ''
      set-option -g terminal-overrides ',xterm-256color:RGB'

      set -g renumber-windows on       # renumber all windows when any window is closed
      set -g set-clipboard on          # use system clipboard
      set -g status-position top       # macOS / darwin style
    '';
  };
}
