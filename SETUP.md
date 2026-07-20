# SETUP.md — the hand-holding walkthrough

No magic script. You run every command yourself and see exactly where everything goes.
Order matters — go top to bottom. Anything with `sudo vim` means: system file, read twice, save once.

---

## Step 1 — Clone the repo

```bash
git clone git@github.com:<you>/oni-dotfiles.git ~/dotfiles
cd ~/dotfiles
```

**Where it lives:** `~/dotfiles`. Every symlink created later points back here — don't move it afterwards (if you ever do: `stow -D` everything, move, re-stow).

---

## Step 2 — Install packages (official repos)

```bash
# The desktop itself
sudo pacman -S --needed hyprland hypridle hyprlock waybar mako swww wofi eww jq

# Terminal + shell
sudo pacman -S --needed kitty zsh zsh-autosuggestions zsh-syntax-highlighting fastfetch

# Files, media
sudo pacman -S --needed nautilus mpv swayimg ffmpegthumbnailer

# Clipboard + screenshots + color picker
sudo pacman -S --needed wl-clipboard cliphist grim slurp hyprpicker

# Wayland plumbing (file pickers, Discord screenshare)
sudo pacman -S --needed xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

# Audio + media keys
sudo pacman -S --needed pipewire wireplumber pavucontrol playerctl

# Bluetooth
sudo pacman -S --needed bluez bluez-utils blueman

# NAS + sync
sudo pacman -S --needed nfs-utils syncthing

# Look & feel
sudo pacman -S --needed ttf-jetbrains-mono-nerd adw-gtk-theme papirus-icon-theme

# OLED dimming via DDC + misc
sudo pacman -S --needed ddcutil polkit-gnome network-manager-applet

# Gaming
sudo pacman -S --needed steam gamemode lib32-gamemode mangohud lib32-mangohud lutris prismlauncher jdk21-openjdk discord

# The symlink manager
sudo pacman -S --needed stow
```

## Step 2b — AUR packages (paru ships with CachyOS)

```bash
paru -S hyprshot          # screenshot wrapper: region/window/monitor, save+copy
paru -S wl-clip-persist   # clipboard survives closing the source app
paru -S firefox-pwa       # real app-mode windows for Claude / Proton Mail / YT Music
paru -S youtube-music-bin # desktop YT Music (feeds playerctl → now-playing widget)
paru -S matugen           # wallpaper → accent color theming (SUPER+SHIFT+W)
```

Why each: `hyprshot` gives proper screenshot ergonomics (bound in hyprland.conf). `wl-clip-persist` fixes Wayland's most annoying quirk — by default the clipboard *empties when you close the app you copied from*. `firefox-pwa` = Firefox's answer to Chromium's `--app` mode.

---

## Step 3 — Understand stow, then link the configs

Stow mirrors a repo folder into `$HOME` **as symlinks**: `hypr/.config/hypr/hyprland.conf` becomes a link at `~/.config/hypr/hyprland.conf` pointing into the repo. Edit either side — same file — every change git-trackable.

If a real file already exists at a target, stow refuses (your safety net): `mv ~/.config/hypr ~/.config/hypr.bak`, then retry.

```bash
cd ~/dotfiles
stow -v -t ~ hypr       # → ~/.config/hypr/{hyprland,hypridle,hyprlock}.conf
stow -v -t ~ waybar     # → ~/.config/waybar/{config.jsonc,style.css}
stow -v -t ~ kitty      # → ~/.config/kitty/{kitty.conf,oni.conf}
stow -v -t ~ mako       # → ~/.config/mako/config
stow -v -t ~ wofi       # → ~/.config/wofi/{config,style.css}
stow -v -t ~ mpv        # → ~/.config/mpv/mpv.conf
stow -v -t ~ swayimg    # → ~/.config/swayimg/config
stow -v -t ~ zsh        # → ~/.zshrc
stow -v -t ~ gtk        # → ~/.config/gtk-3.0/ + gtk-4.0/
stow -v -t ~ bin        # → ~/.local/bin/{oni-wallpaper,oni-keys}
stow -v -t ~ eww        # → ~/.config/eww/ (widgets + poll scripts)
stow -v -t ~ matugen    # → ~/.config/matugen/config.toml
```

Verify: `ls -l ~/.config/hypr/hyprland.conf` → shows `-> ../../dotfiles/...`.
Undo: `stow -Dt ~ <pkg>` · relink after adding files: `stow -Rt ~ <pkg>`.

---

## Step 4 — Make zsh your shell

```bash
chsh -s /usr/bin/zsh
```

Takes effect next login: mint prompt, shared history, case-insensitive completion, autosuggestions + syntax highlighting, aliases (`nas`, `vpn-status`, `update`, `v`).

---

## Step 5 — Firefox

1. Start Firefox once (creates the profile).
2. `ls ~/.mozilla/firefox/ | grep default-release`
3. Link userChrome (replace `XXXX`):
   ```bash
   mkdir -p ~/.mozilla/firefox/XXXX.default-release/chrome
   ln -s ~/dotfiles/firefox/chrome/userChrome.css ~/.mozilla/firefox/XXXX.default-release/chrome/userChrome.css
   ```
4. `about:config`: `toolkit.legacyUserProfileCustomizations.stylesheets` → `true` · `media.ffmpeg.vaapi.enabled` → `true`
5. Settings → Search → default engine **DuckDuckGo**.
6. Restart → slim dark Oni tabs.

### Step 5b — PWAs (Claude, Proton Mail, YT Music as app windows)

With `firefox-pwa` installed: add the **PWAs for Firefox** extension, then install claude.ai / mail.proton.me as PWAs. Each gets its own launcher + window class. Then update the binds in `hyprland.conf`:

```bash
firefoxpwa profile list        # shows the site IDs (ULIDs)
```

Replace the `firefox --new-window ...` exec lines for SUPER+A / SUPER+M with `firefoxpwa site launch <ID>`, and tighten the workspace `windowrulev2` rules using the real class names from `hyprctl clients`. Commit.

---

## Step 6 — Default applications

Writes to `~/.config/mimeapps.list` (the double-click decision file):

```bash
xdg-settings set default-web-browser firefox.desktop
xdg-mime default org.gnome.Nautilus.desktop inode/directory
xdg-mime default swayimg.desktop image/jpeg image/png image/webp image/gif image/bmp
xdg-mime default mpv.desktop video/mp4 video/x-matroska video/webm video/x-msvideo audio/mpeg audio/flac audio/ogg
```

GTK apps dark + mint accent:

```bash
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
```

---

## Step 7 — Clipboard & screenshots — verify they work well

```bash
mkdir -p ~/Pictures/screenshots
```

The pieces already wired in hyprland.conf autostart: `cliphist` watchers (history), `wl-clip-persist` (clipboard survives app closes). `HYPRSHOT_DIR` env points saves at `~/Pictures/screenshots`.

**Test after first Hyprland login:**

| Action | Keys | Expected |
|---|---|---|
| Region screenshot | `PRINT` | select area → saved to ~/Pictures/screenshots **and** in clipboard, mako notification |
| Current monitor | `SHIFT+PRINT` | full shot of active monitor |
| Single window | `SUPER+PRINT` | click a window → shot of just it |
| Region, clipboard only | `SUPER+SHIFT+S` | nothing saved, paste anywhere |
| Clipboard history | `SUPER+V` | wofi list of recent copies incl. images → pick → it's your clipboard |
| Persistence | copy text in kitty, **close kitty**, paste in Firefox | still pastes (that's wl-clip-persist) |
| Color picker | `SUPER+SHIFT+C` | click any pixel → hex in clipboard |

If PRINT does nothing: `hyprctl binds | grep -i print` to confirm the bind loaded, and run `hyprshot -m region` in a terminal to see errors directly.

---

## Step 8 — Services

```bash
sudo systemctl enable --now bluetooth
sudo cp ~/dotfiles/system/bluetooth-main.conf /etc/bluetooth/main.conf   # AutoEnable at boot
systemctl --user enable --now syncthing
```

ddcutil (OLED dimming) needs i2c access:

```bash
sudo groupadd -f i2c
sudo usermod -aG i2c $USER
echo 'i2c-dev' | sudo tee /etc/modules-load.d/i2c-dev.conf
```

Applies after **re-login**. Test: `ddcutil detect` → lists all three GO27Q24Gs.

---

## Step 9 — Games partition + NAS mounts (fstab)

```bash
lsblk -f                                   # find your partitions
sudo mkfs.ext4 -L games /dev/nvme0n1p3     # ONLY if p3 unformatted — double-check device!
mkdir -p ~/Games
sudo mkdir -p /mnt/nas/media /mnt/nas/roms
showmount -e 192.168.188.88                # verify NFS export paths first
sudo vim /etc/fstab                        # append the block from system/fstab.append
sudo systemctl daemon-reload && sudo mount -a
sudo chown fabi:fabi ~/Games
```

Verify: `df -h ~/Games` → ext4 partition · `ls /mnt/nas/media` → triggers automount, lists share. Boot must never hang with NAS off (`x-systemd.automount` guarantees that).

---

## Step 10 — Proton VPN (always-on)

Configs contain **private keys** → never in this repo. account.protonvpn.com → Downloads → WireGuard.

```bash
nmcli connection import type wireguard file ~/Downloads/proton-at.conf
nmcli connection modify proton-at connection.autoconnect yes
nmcli connection up proton-at
curl ifconfig.me          # → Proton IP
ping -c2 192.168.188.88   # → NAS still reachable (LAN bypasses tunnel)
```

---

## Step 11 — Wallpapers

```bash
mkdir -p ~/Pictures/walls    # drop in left.png / yamato.png / right.png (2560×1440)
oni-wallpaper
```

Runs on every Hyprland start via exec-once.

---

## Step 12 — First-boot verification

- [ ] `hyprctl monitors` → names match hyprland.conf (fix + commit if not)
- [ ] Reboot → `vpn-status` = Proton IP · `nas` alias connects
- [ ] Steam → add `~/Games/SteamLibrary` · Lutris → `~/Games/Battlenet` · Prism → `~/Games/Minecraft`
- [ ] BT devices pair and survive reboot
- [ ] Video → mpv · image → swayimg (arrows prev/next, Space slideshow)
- [ ] **Entire Step 7 test table passes** (screenshots + clipboard)
- [ ] Discord screenshare shows the picker
- [ ] Idle: dim @2 min → lock @10 → screens off @15

---

## Keybind cheatsheet

**Apps:** SUPER + `T` kitty · `E` files · `B` firefox · `M` mail · `A` claude · `S` steam · `D` discord · `Y` yt-music · `SPACE` launcher

**Scratchpads:** SUPER+`^` dropdown terminal · SUPER+`X` explorer overlay (works over fullscreen games)

**Screens & workspaces:** SUPER+`1-3` center · `4-5` left · `6-7` right · +SHIFT moves window there · SUPER+CTRL+arrows jump monitors · +SHIFT throws window across

**Tools:** SUPER+`V` clipboard history · `PRINT` region shot · SUPER+SHIFT+`S` shot→clipboard · SUPER+SHIFT+`C` color picker · SUPER+`G` animations toggle · SUPER+`K` this sheet on screen · SUPER+`L` lock · SUPER+`Q` close · SUPER+`F` fullscreen

**Home workspaces:** 2 steam · 4 discord · 5 mail · 6 yt-music · 7 claude

## From now on

Config change → already in repo → `git add -A && git commit && git push`.
New machine → Step 1 and down. Never twice.

---

## Step 13 — Desktop widgets (eww)

Three widgets on the center monitor, top-left: **RetroAchievements**, **~/Games fill**, **Network/VPN**. They autostart with Hyprland; **SUPER+W** toggles them (e.g. for clean screenshots).

**RA needs your API key** (the only widget with a secret — so it lives *outside* the repo):

```bash
mkdir -p ~/.config/oni
vim ~/.config/oni/ra.env
```

Content (key from retroachievements.org → Settings → Keys):

```
RA_USER=YourRAUsername
RA_KEY=xxxxxxxxxxxxxxxx
```

Test each data source directly — they just print JSON:

```bash
~/.config/eww/scripts/ra.sh          # your current game + progress
~/.config/eww/scripts/games-disk.sh  # free space + per-launcher legend
~/.config/eww/scripts/net.sh | head -2  # streams every 2s, Ctrl+C to stop
```

Then `eww open oni-widgets`. Debug rendering with `eww logs`. The window is pinned to `:monitor 1` in `eww.yuck` — if the widgets land on the wrong screen, change that index (eww counts monitors 0,1,2 in `hyprctl monitors` order) and commit.

Notes: the VPN line turns **oni-red with "VPN DOWN"** if no wireguard interface exists — that's your tunnel dead-man switch. The disk legend refreshes hourly (`du` over a terabyte isn't free). RA polls every 2 min.

---

## Step 14 — Wallpaper-driven accent (matugen)

**SUPER+SHIFT+W** opens a wallpaper picker; picking one sets it on all monitors (`swww`) and re-themes the *accent* across Hyprland borders, kitty, waybar and wofi (`matugen`). Hybrid by design: **backgrounds stay #000000** (OLED) and oni-red stays alerts-only — only the accent follows the art. Yamato wall → mint rice · Berserk wall → red rice.

Seed the color cache once so everything renders before your first pick:

```bash
mkdir -p ~/.cache/oni
cp ~/dotfiles/matugen/defaults/* ~/.cache/oni/
```

How it flows: `oni-wallpick` → `matugen image <wall>` → renders the templates in `~/dotfiles/matugen/templates/` to `~/.cache/oni/` → post-hooks reload hyprland/kitty/waybar. Generated files live in `~/.cache` on purpose — the repo never gets dirty from changing wallpapers; if you want a different *mapping* (e.g. dim variant), you edit the templates and commit those.

Test: drop 2+ images in `~/Pictures/walls`, hit SUPER+SHIFT+W, pick — window borders, prompt cursor, waybar and launcher should all flip accent within a second.
