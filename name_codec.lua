--- Single source of truth for encoding roboport upgrade levels into an entity name suffix and
--- decoding them back (e.g. efficiency/productivity/speed <-> "e2p1s3"). Used by both the data
--- stage (variant generation) and the control stage (choosing the target variant), so the
--- encoding can never drift out of sync between the two.
---
--- Axis descriptors also carry the related technology name and (for energy) the module line, so
--- the whole per-axis configuration lives in one place.

--- @class RoboportAxis
--- @field letter string Single-char code used in the name suffix.
--- @field key string Level key used in `levels` tables.
--- @field tech string Related technology base name.
--- @field module string|nil Related module line (energy axes only).

---@type RoboportAxis[]
local ENERGY_AXES = {
    { letter = "e", key = "efficiency", tech = "roboport-efficiency", module = "efficiency" },
    { letter = "p", key = "productivity", tech = "roboport-productivity", module = "productivity" },
    { letter = "s", key = "speed", tech = "roboport-speed", module = "speed" },
}

---@type RoboportAxis[]
local LOGISTICAL_AXES = {
    { letter = "c", key = "construction_area", tech = "roboport-construction-area" },
    { letter = "l", key = "logistic_area", tech = "roboport-logistic-area" },
    { letter = "r", key = "robot_storage", tech = "roboport-robot-storage" },
    { letter = "m", key = "material_storage", tech = "roboport-material-storage" },
}

---@class NameCodec
---@field prefix string Full entity-name prefix, e.g. "energy-roboport-mk-".
---@field axes RoboportAxis[]
local NameCodec = {}
NameCodec.__index = NameCodec

---@param prefix string
---@param axes RoboportAxis[]
---@return NameCodec
function NameCodec.new(prefix, axes)
    return setmetatable({ prefix = prefix, axes = axes }, NameCodec)
end

---Encode a levels table (keyed by axis key) into the "<letter><level>..." suffix.
---@param levels table<string, integer>
---@return string
function NameCodec:suffix(levels)
    local parts = {}
    for i, axis in ipairs(self.axes) do
        parts[i] = axis.letter .. tostring(levels[axis.key] or 0)
    end
    return table.concat(parts)
end

---Encode a levels table into the full entity name.
---@param levels table<string, integer>
---@return string
function NameCodec:name(levels)
    return self.prefix .. self:suffix(levels)
end

---@return string A Lua pattern that captures each axis level in order.
function NameCodec:_pattern()
    local parts = {}
    for i, axis in ipairs(self.axes) do
        parts[i] = axis.letter .. "(%d+)"
    end
    return table.concat(parts)
end

---Decode a name (or bare suffix) back into a levels table. Missing captures default to 0.
---@param name string
---@return table<string, integer>
function NameCodec:levels_from_name(name)
    local matches = { string.match(name, self:_pattern()) }
    local out = {}
    for i, axis in ipairs(self.axes) do
        out[axis.key] = tonumber(matches[i]) or 0
    end
    return out
end

return {
    NameCodec = NameCodec,
    ENERGY_AXES = ENERGY_AXES,
    LOGISTICAL_AXES = LOGISTICAL_AXES,
    energy = NameCodec.new("energy-roboport-mk-", ENERGY_AXES),
    logistical = NameCodec.new("logistical-roboport-mk-", LOGISTICAL_AXES),
}
