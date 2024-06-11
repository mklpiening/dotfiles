{ pkgs, ... }: {
  # here go the darwin preferences and config items
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ bash zsh ];
  environment.loginShell = pkgs.zsh;
  environment.systemPackages = [ pkgs.coreutils ];
  environment.variables = {
    ROS_DOMAIN_ID = "9";
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  services.nix-daemon.enable = true;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  programs.nix-index.enable = true;

  fonts.fontDir.enable = true;
  fonts.fonts = [
    pkgs.nerdfonts
  ];
  
  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder._FXShowPosixPathInTitle = false;

  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 14;
  system.defaults.NSGlobalDomain.KeyRepeat = 1;
  # backwards compat; don't change
  system.stateVersion = 4;

  # make nix handle brews and mac apps
  homebrew = {
    enable = true; 
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    masApps = {
      Magnet = 441258766;       # windows-like window 'snapping'
    }; # mac app store apps
    casks = [ 
      "easy-move-plus-resize"   # move and resize windows with hotkeys + mouse
      "hiddenbar"               # hide items from the menu bar
      "macfuse"                 # FUSE filesystems for macOS
      "prusaslicer"             # prusa slicer
      "freecad"                 # freecad
      "meshlab"                 # meshlab
      "cloudcompare"            # cloudcompare
    ];
    brews = [
      # "ext4fuse"              # ext4 support through FUSE (currenty not supported :/)
      "iproute2mac"             # 'ip' command on mac
      "gz-fortress"             # gazebo
      "spicetify-cli"           # good looking spotify
    ];
    taps = [
      "osrf/simulation"
    ];
  };
  
  users.users.malte.home = "/Users/malte";
}
