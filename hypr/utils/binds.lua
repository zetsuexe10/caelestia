local json = require("utils.json")

local M = {}

local groups  = {}
local order   = {}
local current = "General"
local busy    = false

local aliases = {
    ["mouse:272"] = "Left click",
    ["mouse:273"] = "Right click",
    mouse_up      = "Scroll up",
    mouse_down    = "Scroll down",
    Return        = "Enter",
    Minus         = "-",
    Equal         = "=",
    Comma         = ",",
    Period        = ".",
    Slash         = "/",
    Backslash     = "\\",
    grave         = "`",
    Page_Up       = "Page Up",
    Page_Down     = "Page Down",
}

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function pretty(keys)
    if keys:gsub("%s+", ""):lower() == "super+super_l" then
        return "SUPER (tap)"
    end

    local parts = {}
    for part in keys:gmatch("[^+]+") do
        part = trim(part)
        parts[#parts + 1] = aliases[part] or part
    end
    return table.concat(parts, " + ")
end

function M.section(name)
    current = name
end

function M.add(keys, desc, group)
    local list = type(keys) == "table" and keys or { keys }
    local shown = {}

    for _, key in ipairs(list) do
        if type(key) == "string" and key:match("%S") then
            shown[#shown + 1] = pretty(key)
        end
    end
    if #shown == 0 then return end

    group = group or current
    if not groups[group] then
        groups[group] = {}
        order[#order + 1] = group
    end
    table.insert(groups[group], { keys = shown, desc = desc })
end

function M.bind(keys, action, flags)
    busy = true
    local ok, err = pcall(hl.bind, keys, action, flags)
    busy = false
    if not ok then error(err, 0) end
end

function M.hook()
    return pcall(function()
        local original = hl.bind
        hl.bind = function(keys, action, opts)
            if not busy then
                M.add(keys, "Custom binding", "Custom")
            end
            return original(keys, action, opts)
        end
    end)
end

function M.write(path)
    local dir = path:match("^(.*)/[^/]+$")
    if dir then pcall(os.execute, 'mkdir -p "' .. dir .. '"') end

    local out = {}
    for _, name in ipairs(order) do
        out[#out + 1] = { name = name, binds = groups[name] }
    end

    local f = io.open(path, "w")
    if not f then return false end
    f:write(json.encode({ groups = out }))
    f:close()
    return true
end

return M
