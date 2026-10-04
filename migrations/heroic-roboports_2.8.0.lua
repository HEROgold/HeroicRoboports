--- 2.8.0 merged logistical levels that share science packs into multi-level technologies named
--- roboport-robot-storage-levels-N. Before that every level was its own technology
--- (roboport-robot-storage, -2, -3, ...). Those names still exist, either as live single-level
--- technologies or as hidden stubs, so their researched state survived the load; read the old
--- per-level state and set the new chain to match.
local Tech = require("__heroic-library__.technology")
local codec = require("name_codec")
local levels = require("helpers.levels")
local settings = require("settings")

---Level a force had researched under the old one-technology-per-level layout.
---@param force LuaForce
---@param base string
---@return integer
local function old_level(force, base)
    local result = 0
    for level = 1, settings.MAX_RESEARCH_LEVEL do
        local tech = force.technologies[Tech.leveled_name(base, level)]
        if not tech or not tech.researched then
            break
        end
        result = level
    end
    return result
end

for _, force in pairs(game.forces) do
    for _, axis in ipairs(codec.LOGISTICAL_AXES) do
        local target = math.min(old_level(force, axis.tech), levels.maximum(force, axis.tech))
        levels.set(force, axis.tech, target)
    end
end
