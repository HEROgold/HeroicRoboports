local settings = require("settings")
local tech = require("__heroic-library__.technology")

local levels = {}

---@param force LuaForce
---@return table<number, number, number, number>
function levels.get_logistical_levels(force)
    local out = { 0, 0, 0, 0 }
    local research_minimum = settings.research_minimum:get()

    for i, name in ipairs({
        "roboport-construction-area",
        "roboport-logistic-area",
        "roboport-robot-storage",
        "roboport-material-storage",
    }) do
        for level = 1, research_minimum do
            local tech_level = tech.get_tech_level(force, name, level)
            if out[i] < tech_level then
                out[i] = tech_level
            end
        end
    end

    return out
end

---@param force LuaForce
---@return table<number, number, number>
function levels.get_energy_levels(force)
    local out = { 0, 0, 0 }
    local research_minimum = settings.research_minimum:get()

    for i, name in ipairs({
        "roboport-efficiency",
        "roboport-productivity",
        "roboport-speed",
    }) do
        for level = 1, research_minimum do
            local tech_level = tech.get_tech_level(force, name, level)
            if out[i] < tech_level then
                out[i] = tech_level
            end
        end
    end

    return out
end

---@param to_check string
---@return table<number, number, number>
function levels.energy_levels_from_name(to_check)
    local eff, prod, speed = string.match(to_check, "e(%d+)p(%d+)s(%d+)")
    return { tonumber(eff) or 0, tonumber(prod) or 0, tonumber(speed) or 0 }
end

---@param to_check string
---@return table<number, number, number, number>
function levels.storage_levels_from_name(to_check)
    local c, l, r, m = string.match(to_check, "c(%d+)l(%d+)r(%d+)m(%d+)")
    return { tonumber(c) or 0, tonumber(l) or 0, tonumber(r) or 0, tonumber(m) or 0 }
end

return levels
