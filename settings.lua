
---@type table<LuaSettings>
local energy_roboport_settings = {
	{
		type = "double-setting",
		name = "input-flow-limit-modifier",
		setting_type = "startup",
		minimum_value = 0.1,
		default_value = 1,
	},
	{
		type = "double-setting",
		name = "buffer-capacity-modifier",
		setting_type = "startup",
		minimum_value = 0.1,
		default_value = 1,
	},
	{
		type = "double-setting",
		name = "recharge-minimum-modifier",
		setting_type = "startup",
		minimum_value = 0.1,
		default_value = 1,
	},
	{
		type = "double-setting",
		name = "energy-usage-modifier",
		setting_type = "startup",
		minimum_value = 0.1,
		default_value = 1,
	},
	{
		type = "double-setting",
		name = "charging-energy-modifier",
		setting_type = "startup",
		minimum_value = 0.1,
		default_value = 1,
	},
	{
		type = "int-setting",
		name = "energy-speed-limit",
		setting_type = "startup",
		default_value = 9,
		maximum_value = 90
	},{
		type = "int-setting",
		name = "energy-productivity-limit",
		setting_type = "startup",
		default_value = 9,
		maximum_value = 90
	},{
		type = "int-setting",
		name = "energy-efficiency-limit",
		setting_type = "startup",
		default_value = 9,
		maximum_value = 90
	},
}
---@type table<LuaSettings>
local logistical_roboport_settings = {
	{
		type = "int-setting",
		name = "construction-area-limit",
		setting_type = "startup",
		default_value = 3,
		minimum_value = 1,
		maximum_value = 90
	},
	{
		type = "int-setting",
		name = "logistic-area-limit",
		setting_type = "startup",
		default_value = 3,
		minimum_value = 1,
		maximum_value = 90
	},
	{
		type = "int-setting",
		name = "robot-storage-limit",
		setting_type = "startup",
		default_value = 3,
		minimum_value = 1,
		maximum_value = 90
	},
	{
		type = "int-setting",
		name = "material-storage-limit",
		setting_type = "startup",
		default_value = 3,
		minimum_value = 1,
		maximum_value = 90
	},
}
---@type table<LuaSettings>
local research_settings = {
	{
		type = "int-setting",
		name = "research-minimum",
		setting_type = "startup",
		default_value = 3,
		maximum_value = 90
		-- Minimum amount of researches required
	},
	{
		type = "int-setting",
		name = "research-maximum",
		setting_type = "startup",
		default_value = 9,
		maximum_value = 90
		-- Maximum amount of all researches required. The specific limits have to be <= to this setting..
	},
	{
		type = "int-setting",
		name = "roboport-research-upgrade-cost",
		setting_type = "startup",
		default_value = 500,
		minimum_value = 1,
	},
	{
		type = "int-setting",
		name = "roboport-research-upgrade-time",
		setting_type = "startup",
		default_value = 60,
		minimum_value = 1,
	},
}
---@type table<LuaSettings>
local mod_settings = {
	{
		type = "int-setting",
		name = "upgrade-timer",
		setting_type = "startup",
		minimum_value = 1,
		default_value = 8
	},
	{
		type = "bool-setting",
		name = "show-items",
		setting_type = "startup",
		default_value = true
	},
}

data:extend(energy_roboport_settings)
data:extend(logistical_roboport_settings)
data:extend(research_settings)
data:extend(mod_settings)
