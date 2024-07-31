{ pkgs, config, ... }: {
  imports = [
    ./nvim.nix
    ./tmux.nix
  ];

  # Don't change this when you change package input. Leave it alone.
  home.stateVersion = "23.11";
  # specify my home-manager configs
  home.packages = with pkgs; [
    ripgrep   # recursive search for directories
    fd        # alternative to 'find'
    curl      # data transfer
    less      # quick file viewer
    tldr      # 'man' for lazy people
    neofetch  # nice system overview
    ranger    # tui file explorer
    m-cli     # handy mac tools
    comma     # quickly run commands without searching for the correct package name
    ncdu      # more performant "du"

    # lunarvim # nvim distribution

    vcstool   # tool for multi repo use

    lazydocker # useful tui for docker

    python311Full # python
    virtualenv    # python virtualenv
  ];
  home.sessionVariables = {
    PAGER = "less";
    CLICLOLOR = 1;
    EDITOR = "nvim";
  };

  # just write 'fuck' to correct typos on the terminal
  programs.thefuck.enable = true;
  programs.thefuck.enableZshIntegration = true;

  # nicer 'top'
  programs.htop.enable = true;

  # nicer 'htop'
  programs.btop.enable = true;
  programs.btop.settings = {
    color_theme = "TTY";
    theme_background = false;
    update_ms = 200;
  };

  # nicer 'cat'
  programs.bat.enable = true;
  programs.bat.config.theme = "base16-256";

  # powerful fuzzy search
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;

  # modern replacement for 'ls'
  programs.eza.enable = true;

  # modern 'cd' replacement
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  # git
  programs.git = {
    enable = true;
    # diff-so-fancy.enable = true;
    delta.enable = true;
    delta.options = {
      side-by-side = true;
      syntax-theme = "base16";
    };

    lfs.enable = true;
    
    userEmail = "mkl.piening@gmail.com";
    userName = "Malte kleine Piening";

    aliases = {
      l1 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
      l2 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
      l = "!git l1";
      squash = "!f(){ git reset --soft HEAD~\${1} && git commit --edit -m\"\$(git log --format=%B --reverse HEAD..HEAD@{1})\"; };f";
    };

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
  };

  # starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-syntax-highlighting"; }		# syntax highlighting
        { name = "MichaelAquilina/zsh-you-should-use"; }	# recommends aliases when you dont use them
        { name = "wfxr/formarks"; }				                # mark locations and jump to them
        { name = "ChrisPenner/copy-pasta"; } 			        # copy and paste in terminal
        { name = "arzzen/calc.plugin.zsh"; } 			        # calculator
        { name = "fdellwing/zsh-bat"; } 			            # replace cat with bat
        { name = "unixorn/fzf-zsh-plugin"; } 			        # fzf scripts + keybindings (bindings can also be provided by fzf nix itself)
      ];
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ 
      	"git"		  # git ui
      	"colored-man-pages"
      ];
      # theme = "bureau";
    };
    shellAliases = {
      ls = "eza";
      ll = "eza -lbF --git";
      la = "eza -lbhHigmuSa --time-style=long-iso --git --color-scale";
      lx = "eza -lbhHigmuSa@ --time-style=long-iso --git --color-scale";
      llt = "eza -l --git --tree";
      lt = "eza --tree --level=2";
      llm = "eza -lbGF --git --sort=modified";
      lld = "eza -lbhHFGmuSa --group-directories-first";
      docker_rm_dangling = "docker rmi $(docker images --filter 'dangling=true' -q --no-trunc)";
      
      cd = "z"; # replace 'cd' with 'z'
    };
    initExtra = ''
      setopt HIST_EXPIRE_DUPS_FIRST
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_FIND_NO_DUPS
      setopt HIST_SAVE_NO_DUPS

      source /Users/malte/Documents/nr/dev/dev_tooling/setup/host/setup.zsh
    '';
  };

  # EurKEY keyboard layout
  # currently installed manually to reach global Key Layouts
  # home.file."Library/Keyboard Layouts" = {
  #   source = pkgs.fetchFromGitHub {
  #     owner = "jonasdiemer";
  #     repo = "EurKEY-Mac";
  #     rev = "498a7203309d1cfdb3a81960edc812c38fd8acf3";
  #     sha256 = "sha256-/Tmm9dkE1HILryzQ9e6or+Z9geCzS5yZ8GLN3ak22pU=";
  #   };
  #   recursive = true;
  # };

  # hammerspoon config
  home.file.".hammerspoon" = {
    source = ./dotfiles/hammerspoon;
    recursive = true;
  };
}
