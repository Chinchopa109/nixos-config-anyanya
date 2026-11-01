{ config, pkgs, lib, ... }:
{
  home.username = "anyanya";
  home.homeDirectory = "/home/anyanya";
  home.stateVersion = "26.05";

  # --- Out-of-the-Box CLI & Desktop Packages ---
  home.packages = with pkgs; [
    # Desktop apps & utilities
    picom              # Starts via .xinitrc (reads ~/.config/picom/picom.conf)
    dmenu              # Suckless launcher (wrapped by dmenu_wallust)
    fastfetch
    feh                # Sets desktop wallpaper
    nsxiv              # Ultra-fast Suckless image viewer
    deadbeef           # Fast, minimal GTK GUI music player (no MPD required!)
    playerctl          # CLI controller for media keys (controls deadbeef, mpv, browser)
    zed-editor         # Fast Rust code editor (replaces vscodium)
    xclip              # Clipboard manager for screenshots
    python3
    maim               # Screenshot utility
    wiremix
    obsidian
    wineWow64Packages.stable
    telegram-desktop
    libnotify
    udiskie            # Auto-mounts USB drives using udisks2
    pywalfox-native    # Bridge for live Wallust colors in LibreWolf
    hicolor-icon-theme # Base icon fallback for GTK apps
    librsvg            # SVG icon renderer for Abaddon / GTK

    # Yazi & Zsh companion tools (previews, archives, modern CLI)
    file               # Required by Yazi for MIME-type detection
    ouch               # Fast archive manager (zip, 7z, tar.gz)
    unrar              # Fast RAR extractor
    ffmpegthumbnailer  # Video thumbnails in Yazi
    poppler            # PDF previews in Yazi
    jq                 # JSON previews in Yazi
    _7zz               # 7zip archive fallback
    unar               # Archive extraction fallback
    fd                 # Fast file finder for Yazi & FZF
    ripgrep            # Fast text search for Yazi & Neovim
    eza                # Modern 'ls' replacement with icons
    bat                # Modern 'cat' with syntax highlighting

    # Helper script: dmenu_wallust (launches dmenu with current Wallust colors)
    (writeShellScriptBin "dmenu_wallust" ''
      if [ -f "$HOME/.cache/wallust/dmenu_colors" ]; then
        . "$HOME/.cache/wallust/dmenu_colors"
        exec ${pkgs.dmenu}/bin/dmenu_run -nb "$NB" -nf "$NF" -sb "$SB" -sf "$SF" "$@"
      else
        exec ${pkgs.dmenu}/bin/dmenu_run "$@"
      fi
    '')

    # Helper script: setwal (sets wallpaper via feh + updates system colors via wallust)
    (writeShellScriptBin "setwal" ''
      if [ -z "$1" ] || [ ! -f "$1" ]; then
        echo "Usage: setwal /path/to/wallpaper.jpg"
        exit 1
      fi
      IMG="$(realpath "$1")"
      mkdir -p "$HOME/.cache/wallust" "$HOME/.cache/wal" "$HOME/.config/dunst/dunstrc.d" "$HOME/.config/nvim/colors"

      ${pkgs.feh}/bin/feh --bg-fill "$IMG"
      ${pkgs.wallust}/bin/wallust run "$IMG"

      # Load new colors into X11 XRDB (for vxwm)
      [ -f "$HOME/.cache/wallust/Xresources" ] && ${pkgs.xrdb}/bin/xrdb -merge "$HOME/.cache/wallust/Xresources"

      # Live-reload Kitty, Dunst, and LibreWolf (Pywalfox)
      ${pkgs.procps}/bin/pkill -USR1 kitty 2>/dev/null || true
      systemctl --user restart dunst.service 2>/dev/null || true
      ${pkgs.pywalfox-native}/bin/pywalfox update 2>/dev/null || true

      ${pkgs.libnotify}/bin/notify-send -u low "Wallust" "Theme updated! Press Super+F5 to reload vxwm bar."
    '')
  ];


  # --- Wallust (Dynamic Wallpaper Color Generator) ---
  programs.wallust = {
    enable = true;
    settings = {
      backend = "resized";
      color_space = "lab";
      palette = "dark16";
      check_contrast = true;
      templates = {
        Xresources = {
          template = "Xresources.tpl";
          target = "~/.cache/wallust/Xresources";
        };
        kitty = {
          template = "kitty.tpl";
          target = "~/.cache/wallust/kitty-colors.conf";
        };
        dmenu = {
          template = "dmenu.tpl";
          target = "~/.cache/wallust/dmenu_colors";
        };
        dunst = {
          template = "dunst.tpl";
          target = "~/.config/dunst/dunstrc.d/99-wallust.conf";
        };
        zathura = {
          template = "zathura.tpl";
          target = "~/.cache/wallust/zathura-colors";
        };
        pywal = {
          template = "pywal.tpl";
          target = "~/.cache/wal/colors.json";
        };
        nvim = {
          template = "nvim.tpl";
          target = "~/.config/nvim/colors/wallust.vim";
        };
      };
    };
  };

  # Wallust templates
  xdg.configFile = {
    "wallust/templates/Xresources.tpl".text = ''
      *background: {{background}}
      *foreground: {{foreground}}
      *cursorColor: {{cursor}}
      dwm.color0: {{color0}}
      dwm.color6: {{color6}}
      dwm.color8: {{color8}}
      dwm.color14: {{color14}}
    '';

    "wallust/templates/kitty.tpl".text = ''
      background {{background}}
      foreground {{foreground}}
      cursor {{cursor}}
      selection_background {{color6}}
      selection_foreground {{color0}}
      color0 {{color0}}
      color1 {{color1}}
      color2 {{color2}}
      color3 {{color3}}
      color4 {{color4}}
      color5 {{color5}}
      color6 {{color6}}
      color7 {{color7}}
      color8 {{color8}}
      color9 {{color9}}
      color10 {{color10}}
      color11 {{color11}}
      color12 {{color12}}
      color13 {{color13}}
      color14 {{color14}}
      color15 {{color15}}
    '';

    "wallust/templates/dmenu.tpl".text = ''
      NB="{{color0}}"
      NF="{{color6}}"
      SB="{{color6}}"
      SF="{{color0}}"
    '';

    "wallust/templates/dunst.tpl".text = ''
      [global]
      frame_color = "{{color6}}"

      [urgency_low]
      background = "{{background}}"
      foreground = "{{foreground}}"

      [urgency_normal]
      background = "{{background}}"
      foreground = "{{foreground}}"

      [urgency_critical]
      background = "{{color1}}"
      foreground = "{{foreground}}"
      frame_color = "{{color9}}"
    '';

    "wallust/templates/zathura.tpl".text = ''
      set default-bg "{{background}}"
      set default-fg "{{foreground}}"
      set statusbar-bg "{{color0}}"
      set statusbar-fg "{{foreground}}"
      set inputbar-bg "{{color0}}"
      set inputbar-fg "{{foreground}}"
      set recolor-lightcolor "{{background}}"
      set recolor-darkcolor "{{foreground}}"
    '';

    "wallust/templates/pywal.tpl".text = ''
      {
        "wallpaper": "{{wallpaper}}",
        "alpha": "100",
        "special": {
          "background": "{{background}}",
          "foreground": "{{foreground}}",
          "cursor": "{{cursor}}"
        },
        "colors": {
          "color0": "{{color0}}",
          "color1": "{{color1}}",
          "color2": "{{color2}}",
          "color3": "{{color3}}",
          "color4": "{{color4}}",
          "color5": "{{color5}}",
          "color6": "{{color6}}",
          "color7": "{{color7}}",
          "color8": "{{color8}}",
          "color9": "{{color9}}",
          "color10": "{{color10}}",
          "color11": "{{color11}}",
          "color12": "{{color12}}",
          "color13": "{{color13}}",
          "color14": "{{color14}}",
          "color15": "{{color15}}"
        }
      }
    '';

    "wallust/templates/nvim.tpl".text = ''
      highlight clear
      if exists("syntax_on")
        syntax reset
      endif
      set background=dark
      let g:colors_name = "wallust"

      hi Normal       guifg={{foreground}} guibg=NONE ctermbg=NONE
      hi NormalNC     guifg={{foreground}} guibg=NONE ctermbg=NONE
      hi NonText      guifg={{color8}}     guibg=NONE ctermbg=NONE
      hi EndOfBuffer  guifg={{color8}}     guibg=NONE ctermbg=NONE
      hi LineNr       guifg={{color8}}     guibg=NONE
      hi CursorLine   guibg={{color0}}     cterm=NONE
      hi CursorLineNr guifg={{color6}}     guibg={{color0}} gui=bold
      hi Visual       guifg={{background}} guibg={{color6}}
      hi Search       guifg={{background}} guibg={{color3}}
      hi IncSearch    guifg={{background}} guibg={{color1}}
      hi StatusLine   guifg={{foreground}} guibg={{color0}} gui=NONE
      hi StatusLineNC guifg={{color8}}     guibg={{color0}} gui=NONE
      hi VertSplit    guifg={{color8}}     guibg=NONE
      hi WinSeparator guifg={{color8}}     guibg=NONE
      hi Pmenu        guifg={{foreground}} guibg={{color0}}
      hi PmenuSel     guifg={{background}} guibg={{color6}}

      hi Comment      guifg={{color8}}     gui=italic
      hi Constant     guifg={{color3}}
      hi String       guifg={{color2}}
      hi Identifier   guifg={{color1}}
      hi Function     guifg={{color4}}     gui=bold
      hi Statement    guifg={{color5}}     gui=bold
      hi Keyword      guifg={{color5}}
      hi PreProc      guifg={{color6}}
      hi Type         guifg={{color3}}
      hi Special      guifg={{color6}}
      hi Error        guifg={{foreground}} guibg={{color1}}
      hi Todo         guifg={{background}} guibg={{color3}} gui=bold
    '';
  };

  # --- Neovim (Automatically themed by Wallust) ---
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      set number
      set relativenumber
      set termguicolors
      set clipboard=unnamedplus
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set smartindent
      set cursorline

      silent! colorscheme wallust
    '';
  };

  # --- LibreWolf + Pywalfox (Live Wallust Theme Integration) ---
  programs.librewolf = {
    enable = true;
    nativeMessagingHosts = [ pkgs.pywalfox-native ];
    settings = {
      "webextensions.storage.sync.enabled" = true;
    };
    policies = {
      ExtensionSettings = {
        "pywalfox@frewacom.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/pywalfox/latest.xpi";
        };
      };
    };
  };

  home.file.".librewolf/native-messaging-hosts/pywalfox.json".text = builtins.toJSON {
    name = "pywalfox";
    description = "Automatically theme your browser using the colors generated by Pywal";
    path = "${pkgs.pywalfox-native}/bin/pywalfox";
    type = "stdio";
    allowed_extensions = [ "pywalfox@frewacom.org" ];
  };

  home.file.".mozilla/native-messaging-hosts/pywalfox.json".text = builtins.toJSON {
    name = "pywalfox";
    description = "Automatically theme your browser using the colors generated by Pywal";
    path = "${pkgs.pywalfox-native}/bin/pywalfox";
    type = "stdio";
    allowed_extensions = [ "pywalfox@frewacom.org" ];
  };

  # --- Zathura PDF Viewer (Fast + Vim keys + Wallust colors) ---
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      adjust-open = "best-fit";
      pages-per-row = 1;
      scroll-page-aware = true;
      scroll-full-overlap = "0.01";
      scroll-step = 100;
    };
    extraConfig = ''
      include ~/.cache/wallust/zathura-colors
    '';
  };

  # --- Nix-Index + Comma (Find packages & run any command with `, cmd`) ---
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.nix-index-database.comma.enable = true;

  # --- ~/.xinitrc (Executed when you run 'startx') ---
  home.file.".xinitrc" = {
    executable = true;
    text = ''
      #!/bin/sh

      # Ensure cache directories exist for Wallust includes
      mkdir -p "$HOME/.cache/wallust" "$HOME/.cache/wal" "$HOME/.config/nvim/colors"
      touch "$HOME/.cache/wallust/kitty-colors.conf" "$HOME/.cache/wallust/zathura-colors"

      # Import systemd & D-Bus environment variables (fixes picom, dunst, pipewire & portals)
      systemctl --user import-environment DISPLAY XAUTHORITY
      if command -v dbus-update-activation-environment >/dev/null 2>&1; then
        dbus-update-activation-environment --systemd --all
      fi

      # Load Xresources & Wallust Xresources if present
      [ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"
      [ -f "$HOME/.cache/wallust/Xresources" ] && xrdb -merge "$HOME/.cache/wallust/Xresources"

      # Disable screen blanking/DPMS & set snappy keyboard repeat rate (250ms delay, 35Hz rate)
      xset s off -dpms
      xset r rate 250 35

      # Set standard pointer cursor & keyboard layout
      xsetroot -cursor_name left_ptr
      setxkbmap -layout us,ru -option grp:alt_shift_toggle

      # Restore wallpaper if set via feh/setwal
      [ -f "$HOME/.fehbg" ] && "$HOME/.fehbg" &

      # Start Dunst notification service & Picom compositor (reads ~/.config/picom/picom.conf)
      systemctl --user start dunst.service &
      picom -b

      # Lightweight status bar loop for vxwm (RAM, Date/Time)
      (
        while true; do
          MEM=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
          TIME=$(date '+%a %d %b  %H:%M')
          xsetroot -name " $MEM | $TIME "
          sleep 3
        done
      ) &

      # Launch vxwm
      exec vxwm
    '';
  };

  # --- Kitty Terminal (Dynamic Wallust Colors + Zero Input Lag) ---
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
    settings = {
      sync_to_monitor = "no";
      enable_audio_bell = "no";
      confirm_os_window_close = 0;
    };
    extraConfig = ''
      include ~/.cache/wallust/kitty-colors.conf
    '';
  };

  # --- Yazi File Manager + Openers ---
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";

    settings = {
      mgr = {
        ratio = [ 1 4 3 ];
        sort_by = "natural";
        sort_dir_first = true;
        show_hidden = false;
        show_symlink = true;
      };

      preview = {
        max_width = 1000;
        max_height = 1000;
      };

      opener = {
        wine = [
          {
            run = ''cd "$(dirname %s)" && wine %s'';
            orphan = true;
            for = "unix";
            desc = "Run with Wine";
          }
        ];
        nsxiv = [
          {
            run = ''nsxiv -a %s'';
            orphan = true;
            for = "unix";
            desc = "Open image in nsxiv";
          }
        ];
        setwal = [
          {
            run = ''setwal %s'';
            orphan = true;
            for = "unix";
            desc = "Set as Wallpaper (Wallust)";
          }
        ];
        zathura = [
          {
            run = ''zathura %s'';
            orphan = true;
            for = "unix";
            desc = "Open PDF in Zathura";
          }
        ];
        ouch = [
          {
            run = ''ouch decompress -y %s'';
            for = "unix";
            desc = "Extract archive with ouch";
          }
        ];
        unrar = [
          {
            run = ''unrar x -y %s'';
            for = "unix";
            desc = "Extract RAR archive";
          }
        ];
        deadbeef = [
          {
            run = ''deadbeef --queue %s'';
            orphan = true;
            for = "unix";
            desc = "Play / Queue in DeaDBeeF";
          }
        ];
      };

      open = {
        prepend_rules = [
          {
            url = "*.{jpg,jpeg,png,gif,webp,bmp,svg,ico,JPG,JPEG,PNG,GIF,WEBP}";
            use = [ "nsxiv" "setwal" ];
          }
          {
            mime = "image/*";
            use = [ "nsxiv" "setwal" ];
          }
          {
            url = "*.{pdf,PDF,epub,EPUB}";
            use = [ "zathura" ];
          }
          {
            mime = "application/pdf";
            use = [ "zathura" ];
          }
          {
            url = "*.{exe,msi,EXE,MSI}";
            use = [ "wine" ];
          }
          {
            mime = "application/{x-ms-dos-executable,x-msdownload,x-msi,vnd.microsoft.portable-executable}";
            use = [ "wine" ];
          }
          {
            url = "*.{rar,RAR}";
            use = [ "unrar" ];
          }
          {
            mime = "application/{rar,vnd.rar,x-rar*}";
            use = [ "unrar" ];
          }
          {
            url = "*.{zip,7z,tar,gz,xz,zst,bz2,ZIP,7Z,TAR,GZ,XZ,ZST,BZ2}";
            use = [ "ouch" ];
          }
          {
            mime = "application/{*zip,7z*,x-7z*,tar,x-tar,gzip,xz,zstd,bzip*}";
            use = [ "ouch" ];
          }
          {
            url = "*.{mp3,flac,wav,m4a,ogg,opus,MP3,FLAC,WAV,M4A,OGG,OPUS}";
            use = [ "deadbeef" ];
          }
          {
            mime = "audio/*";
            use = [ "deadbeef" ];
          }
        ];
      };

      plugin = {
        prepend_previewers = [
          {
            mime = "application/{*zip,tar,x-tar,bzip2,7z*,x-7z*,rar,vnd.rar,x-rar*,xz,zstd,java-archive}";
            run = "ouch";
          }
        ];
      };
    };

    plugins = {
      full-border = pkgs.yaziPlugins.full-border;
      git = pkgs.yaziPlugins.git;
      chmod = pkgs.yaziPlugins.chmod;
      ouch = pkgs.yaziPlugins.ouch;
    };

    initLua = ''
      require("full-border"):setup()
      require("git"):setup()
    '';

    keymap = {
      mgr.prepend_keymap = [
        {
          on = [ "c" "m" ];
          run = "plugin chmod";
          desc = "Chmod on selected files";
        }
        {
          on = [ "C" ];
          run = "plugin ouch";
          desc = "Compress selected files with ouch";
        }
      ];
    };
  };

  # --- Zsh + Plugins + Prompt ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    history = {
      size = 10000;
      save = 10000;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
    };

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza -lh --icons --group-directories-first --git";
      la = "eza -lah --icons --group-directories-first --git";
      cat = "bat";
      v = "nvim";
      zed = "zeditor";
      update = "nh os switch";
      upgrade = "nix flake update --flake /home/anyanya/nixos-config && nh os switch";
    };

    initContent = ''
      # Bind Up/Down arrow keys to history substring search
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      # Case-insensitive tab completion
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
    '';
  };

  # Fast Rust prompt, fuzzy finder & smart directory jumper for Zsh/Yazi
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # --- MPV (Zero-copy NVDEC for GTX 750 Ti) ---
  programs.mpv = {
    enable = true;
    config = {
      profile = "fast";
      vo = "gpu";
      hwdec = "nvdec";
      keep-open = "yes";
    };
  };

  # --- Btop (Uses Kitty/Wallust terminal colors via TTY theme) ---
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "TTY";
      theme_background = false;
      vim_keys = true;
      shown_boxes = "cpu mem net proc gpu0";
      update_ms = 2000;
    };
  };

  # --- Dunst Notifications ---
  services.dunst = {
    enable = true;
    settings = {
      global = {
        font = "JetBrainsMono Nerd Font 10";
        frame_width = 2;
        corner_radius = 0;
      };
    };
  };

  # --- Abaddon ---
  programs.abaddon = {
    enable = true;
    package = pkgs.abaddon.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [
        (pkgs.fetchpatch {
          name = "abaddon-fix-application-id-null.patch";
          url = "https://github.com/uowuo/abaddon/pull/427.patch";
          hash = "sha256-g/m9RIHfpbmNR0/uVyz0uYAjuTyb2FgcWMrkjcVdCZo=";
        })
      ];
    });
  };

  # --- Git ---
  programs.git = {
    enable = true;
    settings.user.name = "anyanya";
    settings.user.email = "anyanya200@proton.me";
  };

  programs.home-manager.enable = true;
}
