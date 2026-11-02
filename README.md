# Caelestia

Hyprland (Lua config) with the Caelestia Quickshell shell, isolated in `~/.caelestia`.

## Install

```sh
git clone https://github.com/OWNER/caelestia && cd caelestia
./install.sh
```

Options: `--check`, `--yes`, `--build` (force local plugin build), `--repo owner/name`, `--uninstall`.

## Layout

| Path | Purpose |
| --- | --- |
| `hypr/` | Hyprland Lua config |
| `shell/` | Quickshell config and C++ plugin source |
| `bin/` | session launcher, env, `caelestia` helper |
| `config/` | foot, Thunar, GTK, mime defaults |
| `.github/workflows/build-plugin.yml` | builds the plugin and publishes the `plugin` release |

## Isolation

The session exports `XDG_CONFIG_HOME`, `XDG_STATE_HOME` and `XDG_CACHE_HOME` under `~/.caelestia` and uses the gsettings keyfile backend. Nothing in `~/.config` or dconf is modified.

## Start

Pick the Caelestia session in your display manager, or run `~/.caelestia/bin/caelestia-session` from a TTY.
