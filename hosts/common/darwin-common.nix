{ lib, inputs, stablePkgs, unstablePkgs, ... }:
let
  inherit (inputs) nixpkgs nixpkgs-stable;
in
{
  # Nix configuration ------------------------------------------------------------------------------
  users.users.dominik.home = "/Users/dominik";

  system.stateVersion = 5;

  nix = {
    #package = lib.mkDefault pkgs.unstable.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
      max-jobs = "auto";
      extra-nix-path = "nixpkgs=flake:nixpkgs";
    };
  };
  services.nix-daemon.enable = true;

  # pins to stable as unstable updates very often
  # nix.registry.nixpkgs.flake = inputs.nixpkgs;
  # nix.registry = {
  #   n.to = {
  #     type = "path";
  #     path = inputs.nixpkgs;
  #   };
  #   u.to = {
  #     type = "path";
  #     path = inputs.nixpkgs-unstable;
  #   };
  # };

  # nix.buildMachines = [{
  #   systems = [ "x86_64-linux" ];
  #   supportedFeatures = [ "kvm" "big-parallel" ];
  #   sshUser = "ragon";
  #   maxJobs = 12;
  #   hostName = "ds9";
  #   sshKey = "/Users/ragon/.ssh/id_ed25519";
  #   publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUorQkJYdWZYQUpoeVVIVmZocWxrOFk0ekVLSmJLWGdKUXZzZEU0ODJscFYgcm9vdEBpc28K";
  # }

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.overlays = [
    (final: prev: lib.optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
      # Add access to x86 packages system is running Apple Silicon
      pkgs-x86 = import nixpkgs {
        system = "x86_64-darwin";
        config.allowUnfree = true;
      };
    })
  ];

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  environment.systemPackages = with stablePkgs; [
    exiftool
    unstablePkgs.lima
  ] ++ (if system == "aarch64-darwin" then [ unstablePkgs.macmon ] else [ ]);

  homebrew = {
    enable = true;
    onActivation.upgrade = true;
    # updates homebrew packages on activation,
    # can make darwin-rebuild much slower (otherwise i'd forget to do it ever though)
    taps = [
    ];
    brews = [
      # home.nix
      # home.packages
      # "synergy-core"
      # "tailscale"
      "gnu-time"
      "libyaml"
      "mactop"
      {
        name = "neovim";
        link = false; # Dependency of neovide, we want to use neovim from nix
      }
      {
        name = "tree-sitter";
        link = false; # Dependency of neovide, we want to use neovim from nix
      }
    ];
    casks = [
      # #"alfred" # you are on alfred4 not 5
      # "audacity"
      # "balenaetcher"
      # "bartender"
      # #"canon-eos-utility" #old version and v3 not in repo
      # "discord"
      # "displaylink"
      # "docker"
      # "element"
      # "firefox"
      # "google-chrome"
      # "istat-menus"
      # "iterm2"
      # #"lingon-x"
      # "little-snitch"
      # "logitech-options"
      # "macwhisper"
      # "monitorcontrol"
      # "mqtt-explorer"
      # "nextcloud"
      # "notion"
      # "obs"
      # "obsidian"
      # "omnidisksweeper"
      # "onyx"
      # "openttd"
      # "plexamp"
      # "prusaslicer"
      # "rectangle"
      # "signal"
      # "slack"
      # "spotify"
      # "steam"
      # "thunderbird"
      # "viscosity"
      # "visual-studio-code"
      # "vlc"
      # "wireshark"
      # "yubico-yubikey-manager"

      # # rogue amoeba
      # "audio-hijack"
      # "farrago"
      # "loopback"
      # "soundsource"

      "1password"
      "autodesk-fusion360"
      "adobe-creative-cloud"
      "aldente"
      "bambu-studio"
      "bettertouchtool"
      "bitwarden"
      "contexts"
      "dash"
      "deezer"
      "discord"
      "font-hack-nerd-font"
      #"font-sourcecodepro-nerd-font"
      #"font-sourcecodepro-nerd-font-mono"
      "firefox"
      "google-chrome"
      # "google-chrome-canary"
      "keyboardcleantool"
      "iterm2"
      "macwhisper"
      "musicbrainz-picard"
      "nextcloud"
      "neovide"
      "numi"
      "utm"
      # "osxfuse"
      "openscad"
      "orbstack"
      "plex"
      "plexamp"
      "phantomjs"
      "postgres-unofficial"
      # "skype"
      "raycast"
      "slack"
      "sublime-text"
      # "spotify"
      "teamspeak-client"
      "teamviewer"
      "the-unarchiver"
      "thunderbird"
      "vagrant"
      "viscosity"
      "visual-studio-code"
      "vlc"
      "raspberry-pi-imager"
      "zed"
    ];
    masApps = {
      # "Bitwarden" = 1352778147;
      # "Creator's Best Friend" = 1524172135;
      # "Disk Speed Test" = 425264550;
      # "iA Writer" = 775737590;
      # "Microsoft Remote Desktop" = 1295203466;
      # "Reeder" = 1529448980;
      # "Resize Master" = 1025306797;
      # # "Steam Link" = 123;
      # "Tailscale" = 1475387142;
      # "Telegram" = 747648890;
      # "The Unarchiver" = 425424353;
      # "Todoist" = 585829637;
      # "UTM" = 1538878817;
      # "Wireguard" = 1451685025;

      # these apps with uk apple id
      #"Final Cut Pro" = 424389933;
      #"Logic Pro" = 634148309;
      #"MainStage" = 634159523;
      #"Garageband" = 682658836;
      #"ShutterCount" = 720123827;
      #"Teleprompter" = 1533078079;

      "Amphetamine" = 937984704;
      "Mona" = 1659154653;
      "Discovery" = 1381004916;
      "Disk Speed Test" = 425264550;
      "Helium" = 1054607607;
      "Mattermost" = 1614666244;
      "MQTT Explorer" = 1455214828;
      "Telegram" = 747648890;
      "Duplicate File Finder" = 1032755628;
      "Twitter" = 1482454543;
      "WireGuard" = 1451685025;
      "iStat Menus" = 1319778037;
      "ForkLift" = 412448059;
      "DaisyDisk" = 411643860;
      "Infuse" = 1136220934;
      "Better Battery 2" = 1455789676;
      "Microsoft Remote Desktop" = 1295203466;
      "MediaInfo" = 510620098;
      "Tailscale" = 1475387142;
      "Outbank" = 1094255754;
      "TestFlight" = 899247664;

      "Keynote" = 409183694;
      "Numbers" = 409203825;
      "Pages" = 409201541;

    };
  };

  # macOS configuration
  system.activationScripts.postUserActivation.text = ''
    # Following line should allow us to avoid a logout/login cycle
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
  system.defaults = {
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleShowScrollBars = "Always";
    NSGlobalDomain.NSUseAnimatedFocusRing = false;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
    NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
    NSGlobalDomain.PMPrintingExpandedStateForPrint2 = true;
    NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain.InitialKeyRepeat = 20;
    NSGlobalDomain.KeyRepeat = 1;
    NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
    LaunchServices.LSQuarantine = false; # disables "Are you sure?" for new apps
    loginwindow.GuestEnabled = false;
  };
  system.defaults.CustomUserPreferences = {
    "com.apple.finder" = {
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowRemovableMediaOnDesktop = true;
      _FXSortFoldersFirst = true;
      # When performing a search, search the current folder by default
      FXDefaultSearchScope = "SCcf";
      FXPreferredViewStyle = "Nlsv";
      DisableAllAnimations = true;
      NewWindowTarget = "PfDe";
      NewWindowTargetPath = "file://$\{HOME\}/Desktop/";
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      ShowStatusBar = true;
      ShowPathbar = true;
      WarnOnEmptyTrash = false;
    };
    "com.apple.desktopservices" = {
      # Avoid creating .DS_Store files on network or USB volumes
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.dock" = {
      autohide = true;
      autohide-delay = 0;
      autohide-time-modifier = 0;
      launchanim = false;
      static-only = false;
      show-recents = false;
      show-process-indicators = true;
      orientation = "bottom";
      tilesize = 39;
      minimize-to-application = true;
      mineffect = "scale";
    };
    "com.apple.ActivityMonitor" = {
      OpenMainWindow = true;
      IconType = 5;
      SortColumn = "CPUUsage";
      SortDirection = 0;
    };
    "com.apple.Safari" = {
      # Privacy: don’t send search queries to Apple
      UniversalSearchEnabled = false;
      SuppressSearchSuggestions = true;
    };
    "com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
    };
    "com.apple.SoftwareUpdate" = {
      AutomaticCheckEnabled = true;
      # Check for software updates daily, not just once per week
      ScheduleFrequency = 1;
      # Download newly available updates in background
      AutomaticDownload = 1;
      # Install System data files & security updates
      CriticalUpdateInstall = 1;
    };
    "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
    # Prevent Photos from opening automatically when devices are plugged in
    "com.apple.ImageCapture".disableHotPlug = true;
    # Turn on app auto-update
    "com.apple.commerce".AutoUpdate = true;
    "com.googlecode.iterm2".PromptOnQuit = true;
    "com.google.Chrome" = {
      AppleEnableSwipeNavigateWithScrolls = false;
      DisablePrintPreview = true;
      PMPrintingExpandedStateForPrint2 = true;
    };
    "com.adobe.CSXS.11" = {
      PlayerDebugMode = 1;
      LogLevel = 6;
    };
    "com.adobe.CSXS.10" = {
      PlayerDebugMode = 1;
      LogLevel = 6;
    };
    "com.adobe.CSXS.9" = {
      PlayerDebugMode = 1;
      LogLevel = 6;
    };
  };
}
