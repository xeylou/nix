{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix # hardware scan results
      <nixpkgs/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix>
    ];

  # firemono nerd font, mono regular 13
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  # uefi w/out secure boot & ntfs support
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

  # # activate ipv4 forward
  # kernel/sysctl."net.ipv4.ip_froward" = 1;

  # tpm configuration for w11 virtualization
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
    tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  };

  # ubridge configuration for user gns3 configuration
  security.wrappers.ubridge = {
    source = "/run/current-system/sw/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw=ep";
    owner = "xeylou";
    group = "ubridge";
    permissions = "u+rx,g+x";
  };

  # vaapi (video driver)
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      #vpl-gpu-rt          # for newer GPUs on NixOS >24.05 or unstable
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver

  # network related
  networking = {
    hostName = "null";
    networkmanager.enable = true;
    
    # # to add hosts to /etc/hosts
    # extraHosts = 
    # ''
    #   127.0.0.1 localhost
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
    # nat.enable = false;
    # firewall.enable = false;
    #   nftables = {
    # enable = true;
  # };
  };

  # utc time zone
  time.timeZone = "Europe/Paris";
  
  # locale
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
    xkb.layout = "fr";
    xkb.variant = "";
  };

  # console keymap
  console.keyMap = "fr";

  # printing server (to use a printer)
  services.printing.enable = true; # cups server, exposing port
  services.avahi = {
    enable = true;
    nssmdns4 = true;
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

#  # rtkit is optional but recommended
#  security.rtkit.enable = true;
#  services.pipewire = {
#    enable = true;
#    alsa.enable = true;
#    alsa.support32Bit = true;
#    pulse.enable = true;
#    # If you want to use JACK applications, uncomment this
#    #jack.enable = true;
#  };

  # bluetooth support
  hardware.bluetooth = {
    enable = true;
  };
  services.blueman.enable = true;

  # cron free ram peridocally
  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/10 * * * *      root    sysctl -w vm.drop_caches=3"
    ];
  };

  # user settings
  users.groups.ubridge = {};
  users.users.xeylou = {
    isNormalUser = true;
    description = "xeylou";
    extraGroups = [ "networkmanager" "wheel" "kvm" "libvirtd" "audio" "tss" "ubridge" "wireshark" "libvirt" "scanner" "lp" "docker" "ubridge" ];
    packages = with pkgs; [
      # software
      anydesk
      obs-studio
      joplin-desktop
      sublime
      drawio
      sane-backends # to scan documents
      keepassxc
      firefox
      thunderbird
      vesktop # discord w/ sounded screenshare, krisp...
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
      screen
      # docker
      # docker-compose
      # sqlitebrowser
      # pandoc
      vim
      libva-utils # gpu
      dig
      xorg.xdpyinfo # centering windows
      xdotool # centering windows too
      btop
      ncdu
      # bluedevil ?? bluetooth related (works w/out)
      inetutils
      openssl
      unzip
      zip
      unrar
      rar
      wget
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
      vmware-workstation
      # dev
      libgccjit
      xorg.libX11
      xorg.xorgproto
      libGL
      vscodium
      git
      python3
      python311Packages.pip
      go
      hugo
      zola
    ];
  };

  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # packages installed in system profile
  environment.systemPackages = with pkgs; [
    # put packages here
  ];

  # virtualization related
  virtualisation.vmware.host.enable = true;
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

  # docker related
  #virtualisation.docker.enable = true;

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
