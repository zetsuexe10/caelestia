local home   = os.getenv("HOME")
local config = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local state  = (os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")) .. "/caelestia"
local hypr   = config .. "/hypr"
local user   = config .. "/caelestia"
package.path = package.path .. ";" .. user .. "/?.lua"

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

local function report(name, err)
    local message = name .. ": " .. tostring(err)
    pcall(os.execute, 'mkdir -p "' .. state .. '"')
    local log = io.open(state .. "/hypr-errors.log", "a")
    if log then
        log:write(os.date("%Y-%m-%d %H:%M:%S ") .. message .. "\n")
        log:close()
    end
    local safe = (message:gsub("['\"\n]", " "))
    pcall(hl.exec_cmd, "notify-send -u critical -a hyprland 'Config error' '" .. safe .. "'")
end

local function load(name)
    local ok, err = pcall(require, name)
    if not ok then report(name, err) end
    return ok
end

maybe_copy(hypr .. "/scheme/default.lua", hypr .. "/scheme/current.lua")

local ok, overrides = pcall(function()
    if maybe_create(user .. "/hypr-vars.lua", "return {}\n") then
        return require("hypr-vars")
    end
    return {}
end)

if ok and type(overrides) == "table" then
    local vars = require("variables")
    for k, v in pairs(overrides) do
        vars[k] = v
    end
elseif not ok then
    report("hypr-vars", overrides)
end

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

local binds = require("utils.binds")
binds.hook()

load("hyprland.env")
load("hyprland.general")
load("hyprland.input")
load("hyprland.misc")
load("hyprland.animations")
load("hyprland.decoration")
load("hyprland.group")
load("hyprland.keybinds")
load("hyprland.execs")
load("hyprland.rules")
load("hyprland.gestures")

if maybe_create(user .. "/hypr-user.lua") then
    load("hypr-user")
end

pcall(binds.write, state .. "/keybinds.json")
