{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix # hardware scan results
      #<nixpkgs/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix>
    ];

  # font, firemono nerd font mono regular 13
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  # uefi w/ secure boot & ntfs support
  boot = {
  supportedFilesystems = [ "ntfs" ];
  loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
  efi.canTouchEfiVariables = true;
    };
  };

  # tpm configuration for w11 virtualization
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
    tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  };

  # networking related stuff
  networking = {
    hostName = "null";
    networkmanager.enable = true;
    
    # # to edit /etc/hosts
    # extraHosts = 
    # ''
    #   127.0.0.1 xeylou.fr
    # '';

    # # additionnal related
    # wireless.enable = true;  # wireless support via wpa_supplicant
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    # nftables.enable = true;
    
    # # configure allowed exposed ports
    # firewall = {
    #    enable = true;
    #   allowedTCPPorts = [ ... ];
    #   allowedUDPPorts = [ ... ];
    # };

  };

  # utc time zone
  time.timeZone = "Europe/Paris";
  
  # locale settings
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  # x11 w/ xfce
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
  };

  # keymap for x11
  services.xserver = {
    layout = "fr";
    xkbVariant = "";
  };

  # console keymap
  console.keyMap = "fr";

  # printing server (to use a printer)
  services.printing.enable = true; # cups server, expose a port
  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  # drivers for brother printers
  services.printing.drivers = [ pkgs.brlaser ];

  # scanning for brother printer
  hardware.sane = {
    enable = true;
    brscan4.enable = true; # drivers
  };
  services.ipp-usb.enable=true; # using usb

  # sound w/ pulseaudio
  sound.enable = true;
    hardware.pulseaudio = {
      enable = true;
    };

  # bluetooth
    hardware.bluetooth = {
      enable = true;
    };
    services.blueman.enable = true;

  # user settings
  users.users.xeylou = {
    isNormalUser = true;
    description = "xeylou";
    extraGroups = [ "networkmanager" "wheel" "kvm" "libvirtd" "audio" "tss" "ubridge" "wireshark" "libvirt" "scanner" "lp" ];
    packages = with pkgs; [
      # software
      typst
      sublime
      drawio
      nextcloud-client
      obs-studio
#      sane-backends  to scan documents
      keepassxc
      firefox
      discord
      vlc
      solaar # logitech stuff
      # networking
      ciscoPacketTracer8
      macchanger
      wireguard-tools
      wireshark
      openvpn
      qbittorrent
      remmina
      freerdp
      # utilities
      speedtest-cli
      dig
      docker
      docker-compose
      screen
      xorg.xdpyinfo # centering windows
      xdotool # centering windows too
      btop
      ncdu
#      bluedevil ?? bluetooth related
      p7zip
      inetutils
      openssl
      unzip
      zip
      unrar
      rar
      wget
      gnumake
      gcc
      gnupg
      pinentry # gnupg dependency
      bluez # also bluetooth related
      # virtualization related
      qemu
      virt-manager
      dconf # virt-manager dependency
      gns3-server
      gns3-gui
      ubridge
      dynamips
      vpcs
      cpulimit # for standard asa
      # dev
      vscodium
      tmux
      git
      python3
#      python311Packages.pip
      go
      hugo
    ];
  };

  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # packages installed in system profile
  environment.systemPackages = with pkgs; [
  ];

  # virtualization related
  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "suspend";
    onBoot = "ignore";
    qemu = {
      package = pkgs.qemu_kvm;
      ovmf.enable = true;
      ovmf.packages = [ pkgs.OVMFFull.fd ];
      swtpm.enable = true;
      runAsRoot = true;
    };
  };

  # still virtualization related
  environment.etc = {
    "ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
    };
    "ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
    };
  };

  # enabling services
  programs.dconf.enable = true;  # virt-manager related

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  system.stateVersion = "23.11";

}
