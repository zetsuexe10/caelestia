# Caelestia (custom fork)

A custom fork of Caelestia by **caelestia-dots**. All design, code and credit belong to the original authors:

- [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia): the desktop configuration
- [caelestia-dots/shell](https://github.com/caelestia-dots/shell): the Quickshell shell and C++ plugin

This fork combines both into one repository, uses the Lua Hyprland config, and installs everything in a private folder (`~/.caelestia`) so your system settings stay untouched.

## What is different

- Everything lives in `~/.caelestia`. No changes to `~/.config`, dconf or system theme settings.
- `caelestia-cli` is replaced by a small built-in helper (`bin/caelestia`).
- Default apps: Foot (terminal), Brave (browser), Thunar (files).
- Keyboard cheatsheet that is generated from the live Hyprland config.
- Compact UI: thinner bar and screen frame, smaller launcher and panels. The dashboard size is adjustable in Settings → Panels → Dashboard → Size (60% to 140%).
- Removed: battery icon in the bar, battery card in the dashboard, placeholder settings pages, zen, micro, fastfetch, starship, uwsm and other unused extras.
- The plugin is built by GitHub Actions and downloaded by the installer, so no local compile is needed in most cases.

## Requirements

- Arch Linux or an Arch based distribution (`pacman`, `sudo`)
- Hyprland 0.55 or newer (Lua config)
- Qt 6.9 or newer, Quickshell 0.3.0 or newer recommended

Packages are installed for you. Repo packages use `pacman`, AUR packages use `paru` or `yay` (the installer offers to build `paru-bin` if neither exists).

## Install

```sh
git clone https://github.com/zenosce10/caelestia
cd caelestia
./install.sh
```

Then log out and choose the **Caelestia** session, or start it from a TTY:

```sh
~/.caelestia/bin/caelestia-session
```

### Installer options

| Option | Effect |
| --- | --- |
| `--check` | Verify commands, packages, fonts, libraries and installed files |
| `--yes`, `-y` | Do not ask for confirmation |
| `--build` | Build the plugin locally instead of downloading it |
| `--reset-ui` | Restore the default compact UI files |
| `--repo owner/name` | Use another GitHub repository for the prebuilt plugin |
| `--uninstall` | Remove `~/.caelestia` and the session entry |

### The plugin

The shell needs a C++ QML plugin. The workflow in `.github/workflows/build-plugin.yml` builds it on Arch and publishes it as the rolling release `plugin`. The installer downloads it, verifies the checksum and checks that the Qt version matches your system. If anything does not match, or no release exists yet, it builds the plugin locally.

## Keys

| Key | Action |
| --- | --- |
| `SUPER+Enter` or `SUPER+T` | Terminal |
| `SUPER+W` | Browser |
| `SUPER+E` | File manager |
| `` SUPER+` `` | Dropdown terminal |
| `SUPER+F1` or `SUPER+/` | Keyboard cheatsheet |
| `SUPER+I` | Settings |
| `SUPER+D` | Dashboard |
| `SUPER+SHIFT+U` | Quick settings |
| `SUPER+SHIFT+N` | Do not disturb |
| `SUPER` (tap) | App launcher |
| `SUPER+L` | Lock screen |
| `SUPER+Q` | Close window |
| `SUPER+1..0` | Go to workspace |
| `CTRL+SUPER+S` | Region screenshot to clipboard |
| `Print` | Screenshot to clipboard and file |

The cheatsheet lists every binding, searchable, and is also available in Settings under Keyboard shortcuts. It is generated on each Hyprland reload, so changed variables and your own binds appear automatically. Duplicate bindings are reported in the cheatsheet and in `hypr-errors.log`.

## Configuration

Everything is under `~/.caelestia/config`.

| Path | Purpose |
| --- | --- |
| `hypr/` | Hyprland Lua config |
| `quickshell/caelestia/` | Shell QML |
| `caelestia/hypr-vars.lua` | Override variables such as apps and keybindings |
| `caelestia/hypr-user.lua` | Your own Hyprland Lua code, loaded last |
| `caelestia/shell.json` | Shell settings and UI scale |
| `caelestia/shell-tokens.json` | Panel and bar sizes |
| `foot/`, `Thunar/` | Terminal and file manager |
| `gtk-3.0/`, `gtk-4.0/`, `fontconfig/` | Theme settings and font aliases, session only |
| `mimeapps.list`, `brave-flags.conf` | Default applications and Brave flags |

Example, change the terminal and a keybinding in `hypr-vars.lua`:

```lua
return {
    terminal = "foot",
    kbBrowser = "SUPER + B",
}
```

To change sizes, edit `shell-tokens.json` (bar width, dashboard, launcher, sidebar), the `appearance` scales and the `border` (frame) thickness in `shell.json`. The dashboard size slider needs the plugin built from this repo, so run the installer again after the CI build finishes.

## Isolation

The session sets `XDG_CONFIG_HOME`, `XDG_STATE_HOME` and `XDG_CACHE_HOME` to folders in `~/.caelestia` and uses the gsettings keyfile backend. `XDG_DATA_HOME` is not changed, so your keyring, trash and desktop entries keep working. If `~/.config/BraveSoftware` exists it is linked in so Brave keeps your profile.

## The `caelestia` helper

`bin/caelestia` provides the commands the shell and keybindings use:

| Command | Purpose |
| --- | --- |
| `shell` | Start, stop, restart or message the shell |
| `scheme` | List, get and set colour schemes (presets or from the wallpaper) |
| `wallpaper` | Set a wallpaper (`-f file`, `-r` random, `-p file` preview) |
| `screenshot`, `record` | Screenshots and screen recording |
| `clipboard`, `emoji` | Clipboard history and emoji picker |

It needs `python`, `python-pillow`, `grim`, `slurp`, `gpu-screen-recorder` and `libnotify`.

## Troubleshooting

- Run `./install.sh --check` to see missing packages, fonts or files.
- Session log: `~/.caelestia/state/caelestia/session.log`
- Hyprland config errors: `~/.caelestia/state/caelestia/hypr-errors.log` (also shown as a notification)
- Reset sizes: `./install.sh --reset-ui`

## Known limits

- The bar is fixed on the left. The shell has no setting for other sides.
- Arch based systems only.

## License

GPL-3.0, same as upstream. See [LICENSE](LICENSE).
