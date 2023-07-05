# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "null"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  ##the only to lines to add for xfce
  ##if you want gnome
  ##Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;
  # Enable the XFCE Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  ##enabling tor services
  services.tor.enable = true;
  services.tor.client.enable = true;
  services.tor.settings = {
      UseBridges = true;
      ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/obfs4proxy";
      Bridge = "obfs4 IP:ORPort [fingerprint]";
  };


  # Configure keymap in X11
  services.xserver = {
    layout = "fr";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing.enable = false;
  
  # Conguring bluetooth myself
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  # launch blueman-applet after that

  # Switching to pulseaudio
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;    ## If compatibility with 32-bit applications is desired.
  nixpkgs.config.pulseaudio = true;
  # hardware.pulseaudio.extraConfig = "load-module module-combine-sink";  

  
	
  # Enable sound with pipewire.
  #sound.enable = true;
  #security.rtkit.enable = true;
  #services.pipewire = {
  #  enable = true;
  #  alsa.enable = true;
  #  alsa.support32Bit = true;
  #  pulse.enable = true;
  #  # If you want to use JACK applications, uncomment this
  #  #jack.enable = true;

  #  # use the example session manager (no others are packaged yet so this is enabled by default,
  #  # no need to redefine it in your config for now)
  #  #media-session.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.xeylou = {
    isNormalUser = true;
    description = "xeylou";
    extraGroups = [ "networkmanager" "wheel" "kvm" "libvirtd" "audio" ];
    packages = with pkgs; [
      # firefox
      # librewolf
      brave
      gnumake
      # vscode
      vscodium
      gimp
      firefox
      keepassxc
      python311
      discord
      virt-manager
      python311Packages.pip
      wget
      git
      virt-manager
      qemu
      dconf #for virt-manager
      # gnome.gnome-tweaks # usefull for gnome
      openvpn
      qbittorrent
      # maple-mono # my terminal font (doesnt work)
      #maybe add cisco pt but bugging
      # ciscoPacketTracer8 <-- still not working
      #samba
      remmina
      freerdp
      vlc
      solaar
      openssl #fcking ssh keys
      unzip
      unrar
      macchanger
      wireshark
      gnupg
      pinentry
      tor
      tor-browser-bundle-bin
    ];
  };

  # lines i added for firewall
  networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 80 1111 ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ virt-manager pkgs.wireguard-tools
  ## ADDED VIRT-MANAGER & WIREGUARD
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  ##ADDED FOR VIRT-MANAGER

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
  system.stateVersion = "23.05"; # Did you read the comment?

}
