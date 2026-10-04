local Tech = require("__heroic-library__.technology")
local codec = require("name_codec")

--- Reads and writes the upgrade level of each axis of a family. An axis is a chain of
--- technologies; each link covers the levels first..max_level, so a link is either one level
--- (named `Tech.leveled_name(base, first)`) or a multi-level technology (named
--- `codec.multi_level_tech(base, first)`; the logistical axes merge levels that share science
--- packs). Hidden technologies are pre-2.8.0 stubs kept only for migration and end the chain.
local levels = {}

---@class LevelLink
---@field tech LuaTechnology
---@field first integer
---@field last integer

---@param force LuaForce
---@param base string
---@return LevelLink[]
local function chain(force, base)
    local links = {}
    local level = 1
    while true do
        local tech = force.technologies[codec.multi_level_tech(base, level)]
            or force.technologies[Tech.leveled_name(base, level)]
        if not tech or tech.prototype.hidden then
            break
        end
        local last = math.max(tech.prototype.max_level, level)
        links[#links + 1] = { tech = tech, first = level, last = last }
        level = last + 1
    end
    return links
end

--- Highest researched level of one axis.
---@param force LuaForce
---@param base string Axis technology base name, e.g. "roboport-robot-storage".
---@return integer
function levels.researched(force, base)
    local result = 0
    for _, link in ipairs(chain(force, base)) do
        if link.tech.researched then
            result = link.last
        else
            -- A partly researched multi-level technology sits at the level being researched.
            result = math.max(result, link.tech.level - 1)
            break
        end
    end
    return result
end

--- Highest level the axis offers (0 when it has no technologies).
---@param force LuaForce
---@param base string
---@return integer
function levels.maximum(force, base)
    local links = chain(force, base)
    return links[#links] and links[#links].last or 0
end

--- Set one axis to exactly `target` researched levels (0 un-researches the whole axis).
---@param force LuaForce
---@param base string
---@param target integer
function levels.set(force, base, target)
    for _, link in ipairs(chain(force, base)) do
        if target >= link.last then
            link.tech.researched = true
        else
            link.tech.researched = false
            if link.last > link.first then
                link.tech.level = math.max(link.first, target + 1)
            end
        end
    end
end

---@param force LuaForce
---@param axes RoboportAxis[]
---@return table<string, integer>
local function researched_levels(force, axes)
    local out = {}
    for _, axis in ipairs(axes) do
        out[axis.key] = levels.researched(force, axis.tech)
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
