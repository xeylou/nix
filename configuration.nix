{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix # results of hardware scan
      <nixpkgs/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix>
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

  # tpm for w11 virtualisation
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
    tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  };

  # networking stuff
  networking = {
    hostName = "null";
    networkmanager.enable = true;
    
    # # to edit /etc/hosts
    # extraHosts = 
    # ''
    #   127.0.0.1 xeylou.fr
    # '';

    # wireless.enable = true;  # wireless support via wpa_supplicant
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    # nftables.enable = true;
    
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

  # keymap in x11
  services.xserver = {
    layout = "fr";
    xkbVariant = "";
  };

  # console keymap
  console.keyMap = "fr";

  # printing for my brother printer
  services.printing.enable = true; # cups server
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
    support32Bit = true;
  };
  nixpkgs.config.pulseaudio = true;

  # user settings
  users.users.xeylou = {
    isNormalUser = true;
    description = "xeylou";
    extraGroups = [ "networkmanager" "wheel" "kvm" "libvirtd" "audio" "tss" "docker" "ubridge" "wireshark" "libvirt" "scanner" "lp" ];
    packages = with pkgs; [
      # software
      sane-backends
      keepassxc
      firefox
      discord
      vlc
      solaar
      # networking
      macchanger
      wireguard-tools
      wireshark
      openvpn
      qbittorrent
      remmina
      freerdp
      gns3-server
      gns3-gui
      ubridge
      dynamips
      vpcs
      # utilities
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
      # virtualisation
      qemu
      virt-manager
      dconf # virt-manager dependency
      # dev
      vscodium
      tmux
      vim
      git
      python3
      go
      hugo
    ];
  };

  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # packages installed in system profile
  environment.systemPackages = with pkgs; [
  ];

  # virtualisation related
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

  # still virtualisation related
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

  system.stateVersion = "23.05";

}
