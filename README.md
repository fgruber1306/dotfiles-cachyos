# oni-dotfiles

Hyprland rice for the 9800X3D / 9070 XT / 3× WOLED build.
True-black OLED theme · mint `#5fe0c0` · ice `#9db8c4` · oni red `#e5484d` (alerts only).

**Setup is manual and guided — see [SETUP.md](SETUP.md).** No install script;
every command is run by you, so you know exactly where everything lives.

## Layout

Each top-level dir is a GNU Stow "package" mirroring `$HOME`:

```
hypr/.config/hypr/{hyprland,hypridle,hyprlock}.conf
waybar/.config/waybar/{config.jsonc,style.css}
kitty/.config/kitty/{kitty.conf,oni.conf}
mako/.config/mako/config
wofi/.config/wofi/{config,style.css}
mpv/.config/mpv/mpv.conf
swayimg/.config/swayimg/config
zsh/.zshrc
gtk/.config/gtk-{3.0,4.0}/...
bin/.local/bin/oni-wallpaper
firefox/chrome/userChrome.css   ← linked into profile manually (SETUP.md step 5)
system/                         ← root-owned templates (fstab, bluetooth, VPN notes)
```

## Stow cheatsheet

```bash
stow -vt ~ <pkg>     # link package into $HOME
stow -Dt ~ <pkg>     # unlink
stow -Rt ~ <pkg>     # relink (after adding files)
```

## Never in this repo

WireGuard configs (private keys!), SSH keys, tokens.
`system/README-vpn.md` has the NetworkManager import one-liner.

## OLED notes

- Waybar fully transparent, true-black wallpaper base — minimum lit pixels
- hypridle ladder: DDC-dim all 3 monitors @2 min → lock @10 → panels off @15
- Fullscreen apps inhibit idle — movies & games never dim
- `misc:vfr = true`; SUPER+SHIFT+A toggles all animations (streaming mode)
