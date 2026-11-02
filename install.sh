#!/usr/bin/env bash
set -uo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${CAELESTIA_HOME:-$HOME/.caelestia}"
CFG="$ROOT/config"
PREFIX="$ROOT/local"
QSDIR="$CFG/quickshell/caelestia"
SESSION_FILE="/usr/share/wayland-sessions/caelestia.desktop"
REPO="${CAELESTIA_REPO:-}"
ASSUME_YES=0
FORCE_BUILD=0
MODE=install

red()    { printf '\033[31m%s\033[0m\n' "$*"; }
green()  { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
step()   { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
die()    { red "error: $*"; exit 1; }

while [ $# -gt 0 ]; do
    case "$1" in
        --yes|-y) ASSUME_YES=1 ;;
        --check) MODE=check ;;
        --uninstall) MODE=uninstall ;;
        --build) FORCE_BUILD=1 ;;
        --repo) shift; REPO="${1:-}" ;;
        --help|-h)
            echo "usage: install.sh [--check] [--uninstall] [--yes] [--build] [--repo owner/name]"
            exit 0
            ;;
        *) die "unknown option: $1" ;;
    esac
    shift
done

if [ -z "$REPO" ] && command -v git >/dev/null 2>&1 && [ -d "$SRC/.git" ]; then
    REPO="$(git -C "$SRC" remote get-url origin 2>/dev/null | sed -E 's#^(git@github.com:|https://github.com/)##; s#\.git$##')"
fi

confirm() {
    [ "$ASSUME_YES" -eq 1 ] && return 0
    local reply
    read -r -p "$1 [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

RUNTIME_PKGS=(
    hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    quickshell qt6-base qt6-declarative qt6-imageformats qt6-multimedia qt6-svg qt6-wayland
    qt6-m3shapes-git libcava
    libpipewire aubio libqalculate lm_sensors ddcutil brightnessctl
    networkmanager bluez bluez-utils pipewire pipewire-pulse wireplumber pwvucontrol
    power-profiles-daemon upower polkit-gnome gnome-keyring
    foot thunar gvfs btop swappy fuzzel hyprpicker wl-clipboard cliphist jq xdg-utils curl
    python python-pillow grim slurp gpu-screen-recorder libnotify
    ttf-material-symbols-variable ttf-rubik-vf ttf-cascadia-code-nerd ttf-jetbrains-mono-nerd
    noto-fonts noto-fonts-emoji
    adw-gtk-theme papirus-icon-theme adwaita-icon-theme
)
BUILD_PKGS=(base-devel git cmake ninja pkgconf qt6-shadertools)

CMDS=(
    Hyprland quickshell qs foot thunar btop swappy fuzzel hyprpicker grim slurp
    wl-copy wl-paste cliphist jq nmcli bluetoothctl wpctl brightnessctl powerprofilesctl
    upower qalc xdg-open python3 notify-send gpu-screen-recorder curl
)

FONTS=(
    "Material Symbols|Material Symbols"
    "Rubik|Rubik"
    "Cascadia Nerd|CaskaydiaCove\|Cascadia"
    "JetBrains Mono Nerd|JetBrainsMono\|JetBrains Mono"
)

browser_cmd() {
    local c
    for c in brave brave-browser brave-bin; do
        command -v "$c" >/dev/null 2>&1 && { echo "$c"; return 0; }
    done
    return 1
}

browser_desktop() {
    local d dir
    for d in brave-browser.desktop brave.desktop com.brave.Browser.desktop; do
        for dir in /usr/share/applications "$HOME/.local/share/applications"; do
            [ -f "$dir/$d" ] && { echo "$d"; return 0; }
        done
    done
    echo "brave-browser.desktop"
}

qt_full() { pkg-config --modversion Qt6Core 2>/dev/null; }
qt_mm()   { qt_full | cut -d. -f1,2; }

version_ge() {
    [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

has_cava() {
    pkg-config --exists libcava 2>/dev/null || pkg-config --exists cava 2>/dev/null
}

quickshell_version() {
    quickshell --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1
}

run_check() {
    local fail=0 c p f label pattern qv

    step "Commands"
    for c in "${CMDS[@]}"; do
        if command -v "$c" >/dev/null 2>&1; then green "  ok       $c"; else red "  missing  $c"; fail=1; fi
    done
    if browser_cmd >/dev/null; then green "  ok       $(browser_cmd)"; else red "  missing  brave"; fail=1; fi

    step "Packages"
    if command -v pacman >/dev/null 2>&1; then
        for p in "${RUNTIME_PKGS[@]}"; do
            if pacman -T "$p" >/dev/null 2>&1; then green "  ok       $p"; else red "  missing  $p"; fail=1; fi
        done
    else
        red "  pacman not found"
        fail=1
    fi

    step "Libraries and fonts"
    if python3 -c 'import PIL' >/dev/null 2>&1; then green "  ok       python Pillow"; else red "  missing  python Pillow"; fail=1; fi
    for f in "${FONTS[@]}"; do
        label="${f%%|*}"
        pattern="${f#*|}"
        if fc-list 2>/dev/null | grep -qi "$pattern"; then green "  ok       font $label"; else red "  missing  font $label"; fail=1; fi
    done
    if [ -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]; then
        green "  ok       polkit-gnome agent"
    else
        red "  missing  polkit-gnome agent"
        fail=1
    fi

    step "Quickshell"
    if command -v quickshell >/dev/null 2>&1; then
        qv="$(quickshell_version)"
        if [ -n "$qv" ] && version_ge "$qv" "0.3.0"; then
            green "  ok       quickshell $qv"
        else
            yellow "  warning  quickshell ${qv:-unknown}, 0.3.0 or newer recommended"
        fi
    fi

    step "Installation"
    for f in \
        "$CFG/hypr/hyprland.lua" \
        "$QSDIR/shell.qml" \
        "$PREFIX/lib/qt6/qml/Caelestia" \
        "$PREFIX/lib/caelestia/version" \
        "$ROOT/bin/caelestia" \
        "$ROOT/bin/caelestia-session"; do
        if [ -e "$f" ]; then green "  ok       $f"; else red "  missing  $f"; fail=1; fi
    done

    echo
    if [ "$fail" -eq 0 ]; then green "all checks passed"; else red "some checks failed"; fi
    return "$fail"
}

detect_aur_helper() {
    local h
    for h in paru yay; do
        command -v "$h" >/dev/null 2>&1 && { echo "$h"; return 0; }
    done
    return 1
}

bootstrap_aur_helper() {
    confirm "no AUR helper found, build paru-bin from the AUR?" || die "an AUR helper is required"
    command -v git >/dev/null 2>&1 || sudo pacman -S --needed --noconfirm git base-devel || die "cannot install git"
    local tmp
    tmp="$(mktemp -d)"
    git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin" || die "clone of paru-bin failed"
    (cd "$tmp/paru-bin" && makepkg -si --noconfirm) || die "building paru-bin failed"
    rm -rf "$tmp"
}

ensure_packages() {
    local missing=() repo=() aur=() p helper
    for p in "$@"; do
        pacman -T "$p" >/dev/null 2>&1 || missing+=("$p")
    done
    if [ "${#missing[@]}" -eq 0 ]; then
        green "all packages already installed"
        return 0
    fi

    sudo pacman -Sy >/dev/null 2>&1 || true
    for p in "${missing[@]}"; do
        if pacman -Si "$p" >/dev/null 2>&1; then repo+=("$p"); else aur+=("$p"); fi
    done

    [ "${#repo[@]}" -gt 0 ] && echo "repo: ${repo[*]}"
    [ "${#aur[@]}" -gt 0 ] && echo "aur:  ${aur[*]}"
    confirm "install these packages?" || die "aborted"

    if [ "${#repo[@]}" -gt 0 ]; then
        sudo pacman -S --needed --noconfirm "${repo[@]}" || die "pacman failed"
    fi
    if [ "${#aur[@]}" -gt 0 ]; then
        helper="$(detect_aur_helper)" || { bootstrap_aur_helper; helper="$(detect_aur_helper)" || die "no AUR helper"; }
        "$helper" -S --needed --noconfirm "${aur[@]}" || die "$helper failed"
    fi
}

preflight() {
    step "Preflight"
    [ "$(id -u)" -ne 0 ] || die "do not run as root"
    command -v pacman >/dev/null 2>&1 || die "this installer supports Arch based systems only"
    command -v sudo >/dev/null 2>&1 || die "sudo is required"
    [ -d "$SRC/shell" ] && [ -d "$SRC/hypr" ] && [ -d "$SRC/config" ] && [ -d "$SRC/bin" ] || die "run from the caelestia repo folder"
    green "ok"
}

install_runtime_packages() {
    step "Runtime packages"
    local pkgs=("${RUNTIME_PKGS[@]}")
    browser_cmd >/dev/null || pkgs+=(brave-bin)
    ensure_packages "${pkgs[@]}"
}

install_files() {
    step "Installing config into $ROOT"
    mkdir -p "$ROOT/bin" "$CFG" "$ROOT/state" "$ROOT/cache" "$PREFIX"

    install -m 755 "$SRC/bin/caelestia" "$ROOT/bin/caelestia"
    install -m 755 "$SRC/bin/caelestia-session" "$ROOT/bin/caelestia-session"
    install -m 755 "$SRC/bin/caelestia-shell-wrap" "$ROOT/bin/caelestia-shell-wrap"
    install -m 644 "$SRC/bin/caelestia-env" "$ROOT/bin/caelestia-env"

    mkdir -p "$CFG/hypr"
    cp -a "$SRC/hypr/." "$CFG/hypr/"

    local bcmd bdesk
    bcmd="$(browser_cmd || echo brave)"
    bdesk="$(browser_desktop)"

    mkdir -p "$CFG/caelestia" "$CFG/foot" "$CFG/Thunar" "$CFG/gtk-3.0" "$CFG/gtk-4.0" "$CFG/glib-2.0/settings"

    [ -f "$CFG/caelestia/hypr-user.lua" ] || cp "$SRC/config/caelestia/hypr-user.lua" "$CFG/caelestia/hypr-user.lua"
    sed "s|@BROWSER@|$bcmd|g" "$SRC/config/caelestia/hypr-vars.lua" > "$CFG/caelestia/hypr-vars.lua"
    sed "s|@ROOT@|$ROOT|g" "$SRC/config/foot/foot.ini" > "$CFG/foot/foot.ini"
    sed "s|@BROWSER_DESKTOP@|$bdesk|g" "$SRC/config/mimeapps.list" > "$CFG/mimeapps.list"

    cp "$SRC/config/Thunar/uca.xml" "$CFG/Thunar/uca.xml"
    cp "$SRC/config/gtk-3.0/settings.ini" "$CFG/gtk-3.0/settings.ini"
    cp "$SRC/config/gtk-4.0/settings.ini" "$CFG/gtk-4.0/settings.ini"
    cp "$SRC/config/glib-2.0/settings/keyfile" "$CFG/glib-2.0/settings/keyfile"
    cp "$SRC/config/brave-flags.conf" "$CFG/brave-flags.conf"

    if [ -d "$HOME/.config/BraveSoftware" ] && [ ! -e "$CFG/BraveSoftware" ]; then
        ln -s "$HOME/.config/BraveSoftware" "$CFG/BraveSoftware"
        green "linked existing Brave profile"
    fi

    rm -rf "$QSDIR"
    mkdir -p "$QSDIR"
    local d
    for d in assets components daemons modules services utils; do
        cp -a "$SRC/shell/$d" "$QSDIR/$d"
    done
    cp -a "$SRC/shell/shell.qml" "$QSDIR/shell.qml"

    green "ok"
}

fetch_prebuilt() {
    [ "$FORCE_BUILD" -eq 0 ] || return 1
    [ -n "$REPO" ] || { yellow "no GitHub repo known, skipping prebuilt plugin"; return 1; }
    command -v curl >/dev/null 2>&1 || return 1

    local base="https://github.com/$REPO/releases/download/plugin" tmp remote_qt local_qt
    tmp="$(mktemp -d)"
    local_qt="$(qt_mm)"

    remote_qt="$(curl -fsSL "$base/caelestia-plugin.qt" 2>/dev/null | tr -d '[:space:]')"
    if [ -z "$remote_qt" ]; then
        yellow "no prebuilt plugin published for $REPO"
        rm -rf "$tmp"
        return 1
    fi
    if [ "$remote_qt" != "$local_qt" ]; then
        yellow "prebuilt plugin targets Qt $remote_qt, system has Qt $local_qt"
        rm -rf "$tmp"
        return 1
    fi

    curl -fsSL "$base/caelestia-plugin.tar.gz" -o "$tmp/plugin.tar.gz" &&
        curl -fsSL "$base/caelestia-plugin.sha256" -o "$tmp/plugin.sha256" || { rm -rf "$tmp"; return 1; }

    local want got
    want="$(awk '{print $1}' "$tmp/plugin.sha256")"
    got="$(sha256sum "$tmp/plugin.tar.gz" | awk '{print $1}')"
    if [ "$want" != "$got" ]; then
        red "checksum mismatch for prebuilt plugin"
        rm -rf "$tmp"
        return 1
    fi

    rm -rf "$PREFIX/lib"
    mkdir -p "$PREFIX"
    tar -xzf "$tmp/plugin.tar.gz" -C "$PREFIX" || { rm -rf "$tmp"; return 1; }
    rm -rf "$tmp"
    [ -d "$PREFIX/lib/qt6/qml/Caelestia" ] && [ -f "$PREFIX/lib/caelestia/version" ]
}

build_plugin() {
    step "Building plugin locally"
    ensure_packages "${BUILD_PKGS[@]}"
    qt_full | grep -q . || die "Qt6 not found"
    version_ge "$(qt_full)" "6.9" || die "Qt 6.9 or newer is required"
    has_cava || die "libcava not found"

    local build="$ROOT/cache/build" jobs
    jobs="$(nproc)"
    [ "$jobs" -gt 4 ] && jobs=4

    cmake -S "$SRC/shell" -B "$build" -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$PREFIX" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DINSTALL_LIBDIR=lib/caelestia \
        -DINSTALL_QMLDIR=lib/qt6/qml \
        -DINSTALL_QSCONFDIR="$build/qsconf-unused" \
        -DVERSION=1.0.0 \
        -DGIT_REVISION=local \
        -DDISTRIBUTOR=caelestia-private || die "cmake configure failed"

    cmake --build "$build" -j "$jobs" || die "build failed"
    rm -rf "$PREFIX/lib"
    cmake --install "$build" || die "install failed"
}

install_plugin() {
    step "Plugin"
    if fetch_prebuilt; then
        green "installed prebuilt plugin from $REPO"
    else
        build_plugin
        green "built and installed locally"
    fi
}

install_session_entry() {
    step "Login session entry"
    local tmp
    tmp="$(mktemp)"
    cat > "$tmp" <<DESKTOP
[Desktop Entry]
Name=Caelestia
Comment=Hyprland with the Caelestia shell
Exec=$ROOT/bin/caelestia-session
Type=Application
DESKTOP
    if confirm "install $SESSION_FILE so it shows in your display manager (needs sudo)?"; then
        sudo install -Dm644 "$tmp" "$SESSION_FILE" && green "installed" || yellow "could not install session entry"
    else
        yellow "skipped, start from a TTY with: $ROOT/bin/caelestia-session"
    fi
    rm -f "$tmp"
}

do_uninstall() {
    step "Uninstall"
    confirm "remove $ROOT and $SESSION_FILE?" || die "aborted"
    rm -rf "$ROOT"
    [ -f "$SESSION_FILE" ] && sudo rm -f "$SESSION_FILE"
    green "removed"
}

case "$MODE" in
    check) run_check; exit $? ;;
    uninstall) do_uninstall; exit 0 ;;
esac

preflight
install_runtime_packages
install_files
install_plugin
install_session_entry
run_check
status=$?

echo
if [ "$status" -eq 0 ]; then
    green "done. log out and pick the Caelestia session, or run: $ROOT/bin/caelestia-session"
else
    yellow "installed with warnings, fix the items above and run: ./install.sh --check"
fi
exit "$status"
