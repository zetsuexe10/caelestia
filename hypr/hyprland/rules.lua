local vars = require("variables")

local function tagged_rule(tag, matches, field)
    for _, entry in ipairs(matches) do
        local match = entry
        if field then
            match = { [field] = entry }
        end
        hl.window_rule({ match = match, tag = "+" .. tag })
    end
end

local function create_tag(tag, rules)
    local rule = { match = { tag = tag } }
    for k, v in pairs(rules) do
        rule[k] = v
    end
    hl.window_rule(rule)
end

local opaque_tag = "opaque"
local float_tag = "float"
local float_60_70_tag = "float_60_70"
local game_tag = "game"
local xwl_popup_tag = "xwl_popup"
local system_monitor_tag = "system_monitor"
local scratch_term_tag = "scratch_term"

hl.window_rule({ match = { fullscreen = false }, opacity = vars.windowOpacity .. " override" })

hl.window_rule({ match = { float = true, xwayland = false }, center = true })

hl.window_rule({
    match             = { title = "Picture(-| )in(-| )[Pp]icture" },
    move              = "(monitor_w*0.98-window_w) (monitor_h*0.97-window_h)",
    pin               = true,
    float             = true,
    keep_aspect_ratio = true,
})

tagged_rule(opaque_tag, {
    "foot",
    "org.quickshell",
    "feh|imv|swappy",
    "mpv|vlc",
}, "class")

tagged_rule(float_tag, {
    "yad|zenity",
    "org.gnome.FileRoller|file-roller",
    "blueman-manager",
    "feh|imv|swappy",
    "org.quickshell",
}, "class")
tagged_rule(float_tag, {
    "File (Operation|Upload)( Progress)?",
    ".* Properties",
    'Rename ".*"',
}, "title")

tagged_rule(float_60_70_tag, {
    "(Select|Open)( a)? (File|Folder)(s)?",
    "Save As",
    "Library",
}, "title")
tagged_rule(float_60_70_tag, {
    "org.pulseaudio.pavucontrol|com.saivert.pwvucontrol",
}, "class")

tagged_rule(game_tag, {
    "steam_app_[0-9]+",
    "steam_app_default",
    "gamescope",
}, "class")

tagged_rule(xwl_popup_tag, {
    { xwayland = true, title = "win[0-9]+" },
    { xwayland = true, title = "", class = "", initial_title = "", initial_class = "" }
})

tagged_rule(system_monitor_tag, { "btop" }, "class")
tagged_rule(scratch_term_tag, { "scratchterm" }, "class")

create_tag(opaque_tag, { opaque = true })
create_tag(float_tag, { float = true })
create_tag(float_60_70_tag, { float = true, size = "(monitor_w*0.6) (monitor_h*0.7)", center = true })
create_tag(game_tag, { opaque = true, immediate = true, idle_inhibit = "always" })
create_tag(xwl_popup_tag, {
    no_dim = true,
    no_shadow = true,
    no_blur = true,
    opaque = true,
    rounding = math.min(10, vars.windowRounding),
})
create_tag(system_monitor_tag, { workspace = "special:sysmon" })
create_tag(scratch_term_tag, {
    workspace = "special:scratch",
    float = true,
    size = "(monitor_w*0.7) (monitor_h*0.6)",
    center = true,
})

hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = vars.singleWindowGapsOut })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = vars.singleWindowGapsOut })

hl.layer_rule({ match = { namespace = "hyprpicker" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "selection" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "wayfreeze" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "launcher" }, animation = "popin 80%", blur = true })

hl.layer_rule({ match = { namespace = "caelestia-(border-exclusion|area-picker)" }, no_anim = true })
hl.layer_rule({ match = { namespace = "caelestia-(drawers|background)" }, animation = "fade" })
