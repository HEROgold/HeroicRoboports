
-- Cache for generated charging offsets to avoid recalculation
local charging_offsets_cache = {}

function generate_charging_offsets(n)
    if charging_offsets_cache[n] then
        return charging_offsets_cache[n]
    end
    
    local offsets = {}
    local min_offset = 1 -- 0.5
    local max_offset = 2 -- 1.5
    local step = 2 * math.pi / n

    for i = 0, n - 1 do
        local theta = step * i
        local r = (i % 2 == 0) and max_offset or min_offset
        local x = r * math.cos(theta)
        local y = r * math.sin(theta)
        table.insert(offsets, {x, y})
    end

    charging_offsets_cache[n] = offsets
    return offsets
end
