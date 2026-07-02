require("__heroic-library__.number")

--- Immutable per-axis level values with bounds clamping applied once at construction. Wraps
--- `number.within_bounds` so callers never re-clamp scattered `{eff,prod,speed}` tables.
---@class LevelSet
---@field _values table<string, integer>
local LevelSet = {}
LevelSet.__index = LevelSet

---@param values table<string, integer> Raw per-axis levels.
---@param bounds table<string, integer>|nil Per-axis maxima (missing axis => value kept as-is).
---@return LevelSet
function LevelSet.new(values, bounds)
    local clamped = {}
    for key, value in pairs(values) do
        local max = bounds and bounds[key] or value
        clamped[key] = number.within_bounds(value, 0, max)
    end
    return setmetatable({ _values = clamped }, LevelSet)
end

---@param key string
---@return integer
function LevelSet:get(key)
    return self._values[key] or 0
end

---@return table<string, integer> A copy of the clamped values (safe to pass to a NameCodec).
function LevelSet:values()
    local out = {}
    for key, value in pairs(self._values) do
        out[key] = value
    end
    return out
end

return LevelSet
