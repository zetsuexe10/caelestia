# Caelestia (custom fork)

A custom fork of Caelestia by **caelestia-dots**. All design, code and credit belong to the original authors:

- [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia) — the Caelestia desktop configuration
- [caelestia-dots/shell](https://github.com/caelestia-dots/shell) — the Caelestia Quickshell shell and C++ plugin

This fork keeps the same shell and desktop, adds a Lua-based Hyprland config and installs everything isolated in `~/.caelestia`.

## Install

```sh
git clone https://github.com/zetsuexe10/caelestia && cd caelestia
./install.sh
```

Options: `--check`, `--yes`, `--build` (force local plugin build), `--repo owner/name`, `--uninstall`.

## Layout

| Path | Purpose |
| --- | --- |
| `hypr/` | Hyprland Lua config |
| `shell/` | Quickshell config and C++ plugin source (from caelestia-dots/shell) |
| `bin/` | session launcher, env, `caelestia` helper |
| `config/` | foot, Thunar, GTK, fontconfig, mime defaults |
| `.github/workflows/build-plugin.yml` | builds the plugin and publishes the `plugin` release |

## Isolation

The session exports `XDG_CONFIG_HOME`, `XDG_STATE_HOME` and `XDG_CACHE_HOME` under `~/.caelestia` and uses the gsettings keyfile backend. Nothing in `~/.config` or dconf is modified.

## Keys

`SUPER+Enter` terminal, `SUPER+W` browser, `SUPER+E` files, `` SUPER+` `` dropdown terminal, `SUPER+F1` shortcut cheatsheet (also in Settings). The list is generated from the active Hyprland config on every reload, including binds added in `~/.caelestia/config/caelestia/hypr-user.lua`.

## Logs

`~/.caelestia/state/caelestia/session.log` for the session, `hypr-errors.log` next to it for Hyprland config errors.

## Start

Pick the Caelestia session in your display manager, or run `~/.caelestia/bin/caelestia-session` from a TTY.

## License

MIT, same as upstream. See [LICENSE](LICENSE).
