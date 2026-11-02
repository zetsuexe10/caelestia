local home       = os.getenv("HOME")
local config     = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local hypr       = config .. "/hypr"
local user       = config .. "/caelestia"
package.path     = package.path .. ";" .. user .. "/?.lua"

local function exists(file)
    local f = io.open(file)
    if f then
        f:close()
        return true
    end
    return false
end

local function maybe_create(file, content)
    if exists(file) then return true end
    local f = io.open(file, "w")
    if not f then return false end
    if content then f:write(content) end
    f:close()
    return true
end

local function maybe_copy(src, dst)
    if exists(dst) then return end
    local input = io.open(src, "r")
    if not input then return end
    local out = io.open(dst, "w")
    if out then
        out:write(input:read("*a"))
        out:close()
    end
    input:close()
end

maybe_copy(hypr .. "/scheme/default.lua", hypr .. "/scheme/current.lua")

local overrides = maybe_create(user .. "/hypr-vars.lua", "return {}\n") and require("hypr-vars") or {}

if type(overrides) == "table" then
    local vars = require("variables")
    for k, v in pairs(overrides) do
        vars[k] = v
    end
end

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

require("hyprland.env")
require("hyprland.general")
require("hyprland.input")
require("hyprland.misc")
require("hyprland.animations")
require("hyprland.decoration")
require("hyprland.group")
require("hyprland.execs")
require("hyprland.rules")
require("hyprland.gestures")
require("hyprland.keybinds")

if maybe_create(user .. "/hypr-user.lua") then
    require("hypr-user")
end
