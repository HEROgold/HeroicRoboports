local Tech = require("__heroic-library__.technology")
local codec = require("name_codec")

--- Reads the currently-researched upgrade level for each axis of a family. Uses
--- `Tech.get_highest_researched_level`, which climbs until no further tech exists, so it
--- naturally matches however many tiers were generated (clamped between research_minimum and
--- research_maximum) without hard-coding a cap.
local levels = {}

---@param force LuaForce
---@param axes RoboportAxis[]
---@return table<string, integer>
local function researched_levels(force, axes)
    local out = {}
    for _, axis in ipairs(axes) do
        out[axis.key] = Tech.get_highest_researched_level(force, axis.tech)
    end
    return out
end

---@param force LuaForce
---@return table<string, integer> Levels keyed by energy axis (efficiency/productivity/speed).
function levels.energy(force)
    return researched_levels(force, codec.ENERGY_AXES)
end

---@param force LuaForce
---@return table<string, integer> Levels keyed by logistical axis.
function levels.logistical(force)
    return researched_levels(force, codec.LOGISTICAL_AXES)
end

return levels
