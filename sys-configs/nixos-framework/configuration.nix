# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, r, ... }:
let
  sources = import ./nix/sources.nix;
  lanzaboote = import sources.lanzaboote;
in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    lanzaboote.nixosModules.lanzaboote
    (r.modules + /base-sys.nix)
    (r.modules + /shell.nix)
  ];

  # Disable power-profiles-daemon to prevent conflcit with tlp.
  services.power-profiles-daemon.enable = false;

  # Enable tlp for battery management.
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_ON_BAT = "balance_power";
      CPU_ENERGY_PERF_ON_AC = "balance_perf";
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;
      START_CHARGE_THRESH_BAT0 = 5;
      STOP_CHARGE_THRESH_BAT0 = 90;
    };
  };

  # Enable biometric login.
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };
  services.fprintd.enable = true;    # Enable below if issues with just enabling fprintd.
    #tod = {
    #  enable = true;
    #  driver = pkgs.libfprint-2-tod1-goodix;
    #};
  # Enable UEFI firmware support for virtualization.
  systemd.tmpfiles.rules = [ "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 2;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "Framework"; # Define your hostname.
  # Enables wireless support via wpa_supplicant.
  # !! Do not enable if networkmanager is enabled!!
  # networking.wireless.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  nix.gc.automatic = true;

  # Enable the X11 windowing system.
  # Let's see if this works...
  # services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  # Enable microcode updates.
  hardware.cpu.intel.updateMicrocode = true;

  # Trusted users.
  nix.settings.trusted-users = [ "root" "awill" ];
  
  # Set build machines for remote building when possible.
  nix.buildMachines = [{
    hostName = "Orion";
    system = "aarch64-linux";
    protocol = "ssh-ng";
    maxJobs = 4;
    speedFactor = 2;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    mandatoryFeatures = [ ];
  }];

  # SSH config for remote building.
  programs.ssh.extraConfig = "
Host vesta
  HostName vesta
  Port 22
  User nixremote
  IdentitiesOnly yes
  IdentityFile /root/.ssh/id_nixremote
  ";

  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  # Enable flakes. "Experimental".
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable bluetooth.
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable sound with pipewire.
  #sound.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable android debug bridge.
  programs.adb.enable = true;
  

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.awill = {
    isNormalUser = true;
    description = "Andrew";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "docker" ];
    packages = with pkgs; [
      vesktop
      mpv
      lua-language-server
      telegram-desktop
      wireshark
      _86Box-with-roms
      wineWowPackages.stable
      mono
      makemkv
      qbittorrent
      pfetch
      handbrake
      #gftp #gftp is broken too now yay
      fastfetch
      kdePackages.kdenlive
      screenfetch
      #vmware-workstation
      hexchat
      hyfetch
      kdePackages.filelight
    ];
  };

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # Enable tailscale.
  services.tailscale.enable = true;
 
  # Enable docker.
  virtualisation.docker.enable = true;

  # Enable VMWare virtualization.
  # virtualisation.vmware.host.enable = true;

  # Enable security things.
  security = {
    doas.enable = false; # doas keeps breaking so im not gonna use it for now
    sudo.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # leave commented until i figure out a fix(pkgs.callPackage ./sd-format-linux.nix { })
    (pkgs.callPackage ./fusee-nano.nix { })
    wget
    sbctl
    qemu
    git
    usbutils
    inetutils
    binutils
    kdePackages.kate
    tmux
    # using firefox esr until they're done with their ai bullshit
    firefox-esr
    nano
    chromium
    gparted
    dosfstools
    ntfs3g
    docker
    docker-compose
    btrfs-progs
    kdePackages.partitionmanager #reiser4 is broken, hold until fixed
    kdePackages.kcalc
    btop
    nixfmt
    cryptsetup
    ddrescue
    diffutils
    dmidecode
    e2fsprogs
    efibootmgr
    exfatprogs
    gpart
    hdparm
    pv
    zstd
    rsync
    screen
    squashfsTools
    pciutils
    aha
    clinfo
    gptfdisk
    parted
  ];

  # Enable KDE Connect
  programs.kdeconnect.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Configure spicetify.
  programs.spicetify =
   let
     spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
   in
   {
     enable = true;
     enabledExtensions = with spicePkgs.extensions; [
       adblock
       hidePodcasts
       shuffle # shuffle+ (special characters are sanitized out of extension names)
     ];
     theme = spicePkgs.themes.catppuccin;
     colorScheme = "mocha";
   };

  # Enable nix-ld.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [ icu ];
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
