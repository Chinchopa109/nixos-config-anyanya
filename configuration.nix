{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # --- Boot & Kernel ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelModules = [ "ntsync" ];

  boot.kernelParams = [
    "nowatchdog"
    "tsc=reliable"
    "clocksource=tsc"
    "transparent_hugepage=madvise"
    "mitigations=off"
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 133;
    "vm.page-cluster" = 0;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_bytes" = 268435456;
    "vm.dirty_background_bytes" = 67108864;

    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_mtu_probing" = 1;
  };

  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 80;
    priority = 100;
  };

  # --- Hardware & CPU ---
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  powerManagement.cpuFreqGovernor = "schedutil";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    powerManagement.enable = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };

  # --- Process & Performance Daemons ---
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  services.fstrim.enable = true;
  services.udisks2.enable = true;
  services.dbus = {
    enable = true;
    implementation = "broker";
  };

  programs.gamemode = {
    enable = true;
    enableRenice = false;
    settings = {
      general = {
        ioprio = 0;
        inhibit_screensaver = 1;
        softrealtime = "auto";
      };
      cpu = {
        park_cores = "no";
        pin_cores = "no";
      
    };
    custom = {
        start = "${pkgs.procps}/bin/pkill picom; ${pkgs.libnotify}/bin/notify-send -u low 'GameMode' 'Optimizations Activated (Picom OFF)'";
        end = "DISPLAY=:0 ${pkgs.picom}/bin/picom -b; ${pkgs.libnotify}/bin/notify-send -u low 'GameMode' 'Optimizations Deactivated (Picom ON)'";
      };
    };
  };

  # --- Networking & Locale ---
  networking.hostName = "anyanya";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  services.resolved.enable = true;

  time.timeZone = "Europe/Samara";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # --- Storage ---
  fileSystems."/mnt/mydrive" = {
    device = "/dev/disk/by-uuid/fb772751-2328-4439-8bee-678e05923a00";
    fsType = "ext4";
    options = [ "nofail" "noatime" "lazytime" "commit=60" ];
  };

  # --- Users & Nix Settings ---
  users.defaultUserShell = pkgs.zsh;
  users.users.anyanya = {
    isNormalUser = true;
    description = "anyanya";
    extraGroups = [ "networkmanager" "wheel" "gamemode" "audio" "video" "input" "storage" ];
    shell = pkgs.zsh;
  };

  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.optimise.automatic = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 5";
    flake = "/home/anyanya/nixos-config";
  };

  # --- X11, Audio & Desktop ---
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    xkb.layout = "us,ru";
    xkb.options = "grp:alt_shift_toggle";
    videoDrivers = [ "nvidia" ];
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # --- Packages & Programs ---
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    mangohud
    xrandr
    xsetroot
    xset
    xrdb
    setxkbmap
    (stdenv.mkDerivation {
      pname = "vxwm";
      version = "unstable";
      src = pkgs.fetchgit {
        url = "https://codeberg.org/wh1tepearl/vxwm.git";
        rev = "refs/heads/main";
        sha256 = "sha256-W7BYpvU1oBfHN3QzZDvDhWVEQ4w/1hKRFdiDzpqfhJ8=";
      };
      prePatch = ''
        cp ${./config.def.h} config.def.h
        # Enable XRDB support in vxwm so Wallust colors apply with Super + F5
        if [ -f modules.def.h ]; then
          sed -i 's/#define XRDB 0/#define XRDB 1/g' modules.def.h
        fi
      '';
      buildInputs = with pkgs; [ libx11 libxft libxinerama fontconfig freetype ];
      NIX_CFLAGS_COMPILE = "-Wno-error -Wno-unused-function";
      makeFlags = [ "PREFIX=$(out)" ];
    })
  ];

  programs.zsh.enable = true;
  programs.amnezia-vpn.enable = true;
  programs.dconf.enable = true;
  programs.localsend.enable = true;
  programs.localsend.openFirewall = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    protontricks.enable = true;
  };

  programs.nix-ld.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: [ pkgs.xcbutilcursor pkgs.zstd pkgs.libxkbfile pkgs.icu ];
    };
  };

  # --- Environment Variables ---
  environment.sessionVariables = {
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    __GL_SHADER_DISK_CACHE_SIZE = "10737418240";
    DXVK_LOG_LEVEL = "none";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  system.stateVersion = "26.05";
}
