local Offsets = require("__heroic-library__.offsets")

-- Charging-pad offsets are a ring layout (radius alternating 1/2). The algorithm now lives in
-- HeroicLibrary as Offsets.ring; this delegate keeps the original signature/output for the two
-- call sites (energy-roboports.lua, logistical-roboports.lua).
local function generate_charging_offsets(n)
    return Offsets.ring(n, 1, 2)
end

return {
    generate_charging_offsets = generate_charging_offsets,
}
