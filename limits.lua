require("__heroic-library__.number")
local settings = require("settings")
local modules = require("__heroic-library__.modules")
local codec = require("name_codec")

--- Computes the per-axis level limits for both roboport families. These drive BOTH how many
--- research technologies are generated and how many entity variants are pre-generated, so the
--- two always match.
---
--- research_minimum / research_maximum act as clamps on the number of levels per axis:
---   levels = clamp(detected_module_tiers, research_minimum, cap)
--- where `cap = min(research_maximum, per-axis setting limit)`.
--- - Remove all modules  -> detected 0 -> clamps up to research_minimum.
--- - A mod adds 9 tiers  -> up to research_maximum (or the per-axis setting cap).

local research_minimum = settings.research_minimum:get()
local research_maximum = settings.research_maximum:get()

-- Energy axes follow module tiers (per line), independently per axis.
local detected = modules.max_tiers({ "efficiency", "productivity", "speed" })
local energy_caps = {
    efficiency = settings.energy_efficiency_limit:get(),
    productivity = settings.energy_productivity_limit:get(),
    speed = settings.energy_speed_limit:get(),
}

local energy = {}
for _, axis in ipairs(codec.ENERGY_AXES) do
    local cap = math.min(research_maximum, energy_caps[axis.key])
    local minimum = math.min(research_minimum, cap)
    energy[axis.key] = number.within_bounds(detected[axis.module] or 0, minimum, cap)
end

-- Logistical axes have no natural module anchor: driven by their setting limits, clamped.
local logistical_caps = {
    construction_area = settings.construction_area_limit:get(),
    logistic_area = settings.logistic_area_limit:get(),
    robot_storage = settings.robot_storage_limit:get(),
    material_storage = settings.material_storage_limit:get(),
}

local logistical = {}
for _, axis in ipairs(codec.LOGISTICAL_AXES) do
    logistical[axis.key] = math.max(research_minimum, math.min(logistical_caps[axis.key], research_maximum))
end

---@class RoboportLimits
---@field energy table<string, integer>
---@field logistical table<string, integer>
Limits = {
    energy = energy,
    logistical = logistical,
}

return Limits
