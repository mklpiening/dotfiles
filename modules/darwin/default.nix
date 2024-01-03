{ pkgs, ... }: {
  # here go the darwin preferences and config items
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ bash zsh ];
  environment.loginShell = pkgs.zsh;
  environment.systemPackages = [ pkgs.coreutils ];

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  services.nix-daemon.enable = true;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  fonts.fontDir.enable = true;
  fonts.fonts = [
    (pkgs.nerdfonts.override { fonts = [ "Meslo" "Iosevka" ]; })
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
   masApps = {}; # mac app store apps
   casks = [];
   brews = [];
   taps = [];
  };
  
  users.users.malte.home = "/Users/malte";
}