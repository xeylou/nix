{ config, pkgs, ... }:

{
  imports =
    [ # results of the hardware scan
      ./hardware-configuration.nix
    ];
  
  # dependency needed when updating
  nixpkgs.config.permittedInsecurePackages = [
    "electron-12.2.3"
  ];

  #font
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    # terminal devicons - firemono nerd font mono regular 13
  ];

  # uefi w/ out secure boot
  boot = {
    supportedFilesystems = [ "ntfs" ];
    # to see ntfs formated drives
    loader = {
      # can be changed for grub
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # enabling tpm for w11 virt
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
    tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  };

  # network configuration
  networking = {
    hostName = "null";
    networkmanager.enable = true;
    extraHosts = 
    ''
      127.0.0.1 xeylou.fr
    '';
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

  # time zone and locale settings
  time.timeZone = "Europe/Paris";
  
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

  # x11 windowing system
  services.xserver.enable = true;

  # xfce
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  # example if you want gnome
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;

  # keymap in x11
  services.xserver = {
    layout = "fr";
    xkbVariant = "";
  };

  # console keymap
  console.keyMap = "fr";

  # cups (to print documents)
  services.printing.enable = false;
  
  # configuring bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # enabling pulseaudio for bluetooth needs
  # could be replaced by pipewire under
  sound.enable = true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  nixpkgs.config.pulseaudio = true;
  # hardware.pulseaudio.extraConfig = "load-module module-combine-sink";  
	
  # pipewire.sound.enable = true;
  # security.rtkit.enable = true;
  # services.pipewire = {
  #  enable = true;
  #  alsa.enable = true;
  #  alsa.support32Bit = true;
  #  pulse.enable = true;
  #  # If you want to use JACK applications, uncomment this
  #  #jack.enable = true;

  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # user settings
  users.users.xeylou = {
    isNormalUser = true;
    description = "xeylou";
    #  tss for tpm
    extraGroups = [ "networkmanager" "wheel" "kvm" "libvirtd" "audio" "tss" ];
    packages = with pkgs; [

      # software
      brave
      mullvad-browser
      keepassxc
      discord
      vlc

      # networking related
      macchanger
      wireguard-tools
      wireshark
      openvpn
      qbittorrent
      remmina
      freerdp

      # utilities
      openssl  # ssh keys
      # unzip  nix-shell -p
      # unrar
      gnumake
      gcc
      gnupg
      pinentry  # gnupg dependency
      # wget  nix-shell -p
      xmousepasteblock # disable middle clic pasting

      # virtualisation
      qemu
      virt-manager
      dconf  # virt-manager dependency
      # swtpm # tpm emulation

      # ide & dev
      tmux
      vim
      neovim
      vscodium
      git
      python3
      go
      hugo

    ];
  };

  # packages installed in system profile
  environment.systemPackages = with pkgs; [
  ];

  virtualisation.libvirtd = {
    enable = true;

    onShutdown = "suspend";
    onBoot = "ignore";

    qemu = {
      package = pkgs.qemu_kvm;
      ovmf.enable = true;
      ovmf.packages = [ pkgs.OVMFFull.fd ];
      swtpm.enable = true;
      runAsRoot = false;
    };
  };

  environment.etc = {
    "ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
    };

    "ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
    };
  };  
  
  # enabling services
  programs.dconf.enable = true;
  # services.openssh.enable = true;

  # # each time you rebuild nix
  # # commands will be executed
  # systemd.services.foo = {
  #   script = ''
  #     systemctl stop bluetooth
  #   '';
  # wantedBy = [ "multi-user.target" ];
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
