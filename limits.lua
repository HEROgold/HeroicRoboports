local settings = require("settings")

local efficiency = 0
local productivity = 0
local speed = 0

for k, v in pairs(data.raw["module"]) do
	local ss = k.sub(k, -2, -1)
	local moduleLevel = tonumber(ss) -- "productivity-module-2" becomes '-2' when converting from string.

	if moduleLevel == nil then -- level one modules don't seem to have a suffix. fix that here
		moduleLevel = 1
	end
	if moduleLevel < 0 then -- invert numbers to positive.
		moduleLevel = -moduleLevel
	end

	local maximum = math.max(moduleLevel, 1)

	if string.starts_with(k, "efficiency-module") then
		efficiency = number.within_bounds(moduleLevel, 0, maximum)
	end
	if string.starts_with(k, "productivity-module") then
		productivity = number.within_bounds(moduleLevel, 0, maximum)
	end
	if string.starts_with(k, "speed-module") then
		speed = number.within_bounds(moduleLevel, 0, maximum)
	end
end

-- the following mods can't be found using data.raw["module"], so we set the limits manually
if mods["Module-Rebalance"] then
	efficiency, productivity, speed = 7, 7, 7
end
if mods["space-exploration"] then
	efficiency, productivity, speed = 9, 9, 9
end

-- Respect the setting a user has provided
efficiency_limit = math.min(settings.energy_efficiency_limit:get(), efficiency)
productivity_limit = math.min(settings.energy_productivity_limit:get(), productivity)
speed_limit = math.min(settings.energy_speed_limit:get(), speed)

Limits = {}
Limits["efficiency"] = efficiency_limit
Limits["productivity"] = productivity_limit
Limits["speed"] = speed_limit

if not ((efficiency_limit == productivity_limit) and (productivity_limit == speed_limit)) then
	error("RoboportUpgrades: The amount of efficiency, productivity and speed modules do not match.")
end

return Limits
