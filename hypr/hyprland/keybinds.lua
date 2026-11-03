local vars  = require("variables")
local fn    = require("utils.functions")
local binds = require("utils.binds")

local locked           = { locked = true }
local mouse            = { mouse = true }
local release          = { release = true }
local repeating        = { repeating = true }
local locked_repeating = { locked = true, repeating = true }

local function normalise_keybind(key)
    return key:gsub("%s+", ""):lower()
end

local function valid_keybind(key)
    return type(key) == "string" and key:match("%S") ~= nil
end

local function repeating_unless_mouse(key)
    return not normalise_keybind(key):find("mouse", 1, true) and repeating or nil
end

local function flatten_keybinds(keybinds, keys)
    keys = keys or {}

    if type(keybinds) == "table" then
        for _, keybind in pairs(keybinds) do
            flatten_keybinds(keybind, keys)
        end
    elseif valid_keybind(keybinds) then
        keys[#keys + 1] = keybinds
    end

    return keys
end

local function create_bind(keybinds, action, flags, desc)
    local get_flags = type(flags) == "function" and flags or function()
        return flags
    end

    local keys = flatten_keybinds(keybinds)
    for _, key in ipairs(keys) do
        binds.bind(key, action, get_flags(key))
    end

    if desc then
        binds.add(keys, desc)
    end
end

local function extend_keybind(base, suffix)
    return valid_keybind(base) and base .. " + " .. suffix or nil
end

local function open_command(cmd)
    return hl.dsp.exec_cmd(cmd)
end

binds.section("Apps")
create_bind(vars.kbTerminal, open_command(vars.terminal), nil, "Terminal")
create_bind(vars.kbBrowser, open_command(vars.browser), nil, "Browser")
create_bind(vars.kbFileExplorer, open_command(vars.fileExplorer), nil, "File manager")
create_bind(vars.kbScratchTerminal, fn.toggle("scratch"), nil, "Dropdown terminal")
create_bind(vars.kbAudioSettings, open_command(vars.audioSettings), nil, "Audio mixer")
create_bind(vars.kbSystemMonitorWs, fn.toggle("sysmon"), nil, "System monitor")

binds.section("Shell")
local launcher_default = normalise_keybind("SUPER + SUPER_L")
create_bind(
    vars.kbLauncher,
    hl.dsp.global("caelestia:launcher"),
    function(key)
        return normalise_keybind(key) == launcher_default and release or nil
    end,
    "App launcher"
)
create_bind("SUPER + mouse_up", hl.dsp.global("caelestia:launcherInterrupt"))
create_bind("SUPER + mouse_down", hl.dsp.global("caelestia:launcherInterrupt"))

create_bind(vars.kbCheatsheet, hl.dsp.global("caelestia:cheatsheet"), nil, "Keyboard shortcuts")
create_bind(vars.kbSettings, hl.dsp.global("caelestia:nexus"), nil, "Settings")
create_bind(vars.kbDashboard, hl.dsp.global("caelestia:dashboard"), nil, "Dashboard")
create_bind(vars.kbSession, hl.dsp.global("caelestia:session"), nil, "Session menu")
create_bind(vars.kbShowSidebar, hl.dsp.global("caelestia:sidebar"), nil, "Notifications sidebar")
create_bind(vars.kbClearNotifs, hl.dsp.global("caelestia:clearNotifs"), locked, "Clear notifications")
create_bind(vars.kbShowPanels, hl.dsp.global("caelestia:showall"), nil, "Toggle all panels")
create_bind(vars.kbLock, hl.dsp.global("caelestia:lock"), nil, "Lock screen")

create_bind(vars.kbRestoreLock, function()
    hl.dispatch(hl.dsp.exec_cmd("caelestia shell -d"))
    hl.dispatch(hl.dsp.global("caelestia:lock"))
end, locked, "Restart shell and lock")

create_bind("CTRL + SUPER + SHIFT + R", hl.dsp.exec_cmd("caelestia shell -k"), release, "Stop shell")
create_bind("CTRL + SUPER + ALT + R", hl.dsp.exec_cmd("caelestia shell -r -d"), release, "Restart shell")
create_bind(vars.kbSleep, hl.dsp.exec_cmd(vars.sleepCmd), locked, "Suspend")

binds.section("Workspaces")
for i = 1, 10 do
    local key = i % 10
    create_bind(extend_keybind(vars.kbGoToWs, key), fn.wsaction("focus", "", i))
    create_bind(extend_keybind(vars.kbMoveWinToWs, key), fn.wsaction("move", "", i))
    create_bind(extend_keybind(vars.kbGoToWsGroup, key), fn.wsaction("focus", "group", i))
    create_bind(extend_keybind(vars.kbMoveWinToWsGroup, key), fn.wsaction("move", "group", i))
    create_bind(extend_keybind(vars.kbMoveWinToWsSilent, key), fn.wsaction("move_silent", "", i))
end
binds.add(vars.kbGoToWs .. " + 1-0", "Go to workspace")
binds.add(vars.kbMoveWinToWs .. " + 1-0", "Move window to workspace")
binds.add(vars.kbMoveWinToWsSilent .. " + 1-0", "Move window to workspace silently")
binds.add(vars.kbGoToWsGroup .. " + 1-0", "Go to workspace group")

create_bind(vars.kbPrevWs, hl.dsp.focus({ workspace = "-1" }), repeating_unless_mouse, "Previous workspace")
create_bind(vars.kbNextWs, hl.dsp.focus({ workspace = "+1" }), repeating_unless_mouse, "Next workspace")
create_bind(vars.kbPrevWsGroup, hl.dsp.focus({ workspace = "-10" }), repeating_unless_mouse, "Previous workspace group")
create_bind(vars.kbNextWsGroup, hl.dsp.focus({ workspace = "+10" }), repeating_unless_mouse, "Next workspace group")
create_bind(vars.kbMoveWinToWsNext, hl.dsp.window.move({ workspace = "+1" }), repeating_unless_mouse, "Move window to next workspace")
create_bind(vars.kbMoveWinToWsPrev, hl.dsp.window.move({ workspace = "-1" }), repeating_unless_mouse, "Move window to previous workspace")
create_bind(vars.kbMoveWinToWsSpecial, hl.dsp.window.move({ workspace = "special:special" }), nil, "Send window to special workspace")
create_bind(vars.kbMoveWinFromWsSpecial, hl.dsp.window.move({ workspace = "e+0" }), nil, "Bring window out of special workspace")
create_bind(vars.kbSpecialWs, fn.toggle("specialws"), nil, "Toggle special workspace")

binds.section("Windows")
create_bind(vars.kbCloseWindow, hl.dsp.window.close(), nil, "Close window")
create_bind(vars.kbWindowFullscreen, hl.dsp.window.fullscreen({ mode = "fullscreen" }), nil, "Fullscreen")
create_bind(vars.kbWindowBorderedFullscreen, hl.dsp.window.fullscreen({ mode = "maximized" }), nil, "Maximize")
create_bind(vars.kbToggleWindowFloating, hl.dsp.window.float(), nil, "Toggle floating")
create_bind(vars.kbPinWindow, hl.dsp.window.pin(), nil, "Pin window")
create_bind(vars.kbCenterWindow, hl.dsp.window.center(), nil, "Center window")
create_bind(vars.kbNormalizeWindow, function()
    hl.dispatch(hl.dsp.window.resize(fn.resize_by_screen(55, 70)))
    hl.dispatch(hl.dsp.window.center())
end, nil, "Reset floating window size")
create_bind(vars.kbWindowPip, function()
    local a = hl.get_active_window()
    if a then
        local pip = fn.move_actions(a) or {}
        if not a.floating then table.insert(pip, 1, hl.dsp.window.float()) end
        table.insert(pip, hl.dsp.window.pin({ action = "on", window = "address:" .. a.address }))

        for _, x in ipairs(pip) do
            hl.dispatch(x)
        end
    end
end, nil, "Picture in picture")

create_bind(vars.kbWindowCycleNext, hl.dsp.window.cycle_next(), repeating, "Cycle windows")
create_bind(vars.kbWindowCyclePrev, hl.dsp.window.cycle_next({ next = false }), repeating, "Cycle windows backwards")
create_bind(vars.kbWindowGroupCycleNext, hl.dsp.group.next(), repeating, "Next tab in group")
create_bind(vars.kbWindowGroupCyclePrev, hl.dsp.group.prev(), repeating, "Previous tab in group")
create_bind(vars.kbToggleGroup, hl.dsp.group.toggle(), nil, "Toggle window group")
create_bind(vars.kbUngroup, hl.dsp.window.move({ out_of_group = true }), nil, "Remove window from group")
create_bind(vars.kbGroupLockActive, hl.dsp.group.lock(), nil, "Lock group")

for _, dir in ipairs({ "left", "right", "up", "down" }) do
    create_bind("SUPER + " .. dir, hl.dsp.focus({ direction = dir }))
    create_bind("SUPER + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
end
binds.add("SUPER + Arrows", "Focus window")
binds.add("SUPER + SHIFT + Arrows", "Move window")

create_bind(vars.kbWindowDecreaseWidth, fn.resize_active_window(-10, 0), repeating, "Shrink window width")
create_bind(vars.kbWindowIncreaseWidth, fn.resize_active_window(10, 0), repeating, "Grow window width")
create_bind(vars.kbWindowDecreaseHeight, fn.resize_active_window(0, -10), repeating, "Shrink window height")
create_bind(vars.kbWindowIncreaseHeight, fn.resize_active_window(0, 10), repeating, "Grow window height")
create_bind({ vars.kbMoveWindow, "SUPER + mouse:272" }, hl.dsp.window.drag(), mouse, "Drag window")
create_bind({ vars.kbResizeWindow, "SUPER + mouse:273" }, hl.dsp.window.resize(), mouse, "Resize window")

binds.section("Capture")
create_bind(vars.kbScreenshot, hl.dsp.exec_cmd("caelestia screenshot"), locked, "Screenshot to clipboard")
create_bind(vars.kbScreenshotFreeze, hl.dsp.global("caelestia:screenshotFreeze"), nil, "Region screenshot (frozen)")
create_bind(vars.kbScreenshotRegion, hl.dsp.global("caelestia:screenshot"), nil, "Region screenshot")
create_bind(vars.kbRecord, hl.dsp.exec_cmd("caelestia record"), nil, "Record screen")
create_bind(vars.kbRecordSound, hl.dsp.exec_cmd("caelestia record -s"), nil, "Record screen with audio")
create_bind(vars.kbRecordRegion, hl.dsp.exec_cmd("caelestia record -r"), nil, "Record region")
create_bind(vars.kbColorPicker, hl.dsp.exec_cmd("hyprpicker -a"), nil, "Colour picker")

binds.section("Clipboard")
create_bind(vars.kbClipboard, hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard"), nil, "Clipboard history")
create_bind(vars.kbClipboardDel, hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard -d"), nil, "Delete clipboard entry")
create_bind(vars.kbEmoji, hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"), nil, "Emoji picker")

binds.section("Media")
create_bind("XF86MonBrightnessUp", hl.dsp.global("caelestia:brightnessUp"), locked, "Brightness up")
create_bind("XF86MonBrightnessDown", hl.dsp.global("caelestia:brightnessDown"), locked, "Brightness down")
create_bind({ vars.kbMediaToggle, "XF86AudioPlay", "XF86AudioPause" }, hl.dsp.global("caelestia:mediaToggle"), locked, "Play / pause")
create_bind({ vars.kbMediaNext, "XF86AudioNext" }, hl.dsp.global("caelestia:mediaNext"), locked, "Next track")
create_bind({ vars.kbMediaPrev, "XF86AudioPrev" }, hl.dsp.global("caelestia:mediaPrev"), locked, "Previous track")
create_bind({ vars.kbMediaStop, "XF86AudioStop" }, hl.dsp.global("caelestia:mediaStop"), locked, "Stop playback")
create_bind({ vars.kbVolumeMute, "XF86AudioMute" }, hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), locked, "Mute")
create_bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), locked, "Mute microphone")
create_bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l " ..
        (vars.volumeMax / 100) .. " @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%+"
    ),
    locked_repeating,
    "Volume up"
)
create_bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%-"
    ),
    locked_repeating,
    "Volume down"
)
