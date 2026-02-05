local Energy = require("__heroic-library__.energy")
local BaseRoboport = require("prototypes.roboport.base")
local offsets = require("helpers.charging_offset")
local settings = require("settings")

---@class EnergyRoboport: BaseRoboport
---@field levels table<string, integer>
local EnergyRoboport = setmetatable({}, { __index = BaseRoboport })
EnergyRoboport.__index = EnergyRoboport

---@class EnergyLevels
---@field efficiency integer
---@field productivity integer
---@field speed integer

---@return self
---@param levels EnergyLevels | nil
function EnergyRoboport.new(levels)
	local self = setmetatable(BaseRoboport.new(), EnergyRoboport) --[[@as EnergyRoboport]]
	self._name = "energy-roboport"
	self.minable.result = self._name

	self.levels = levels or {
		efficiency = 0,
		productivity = 0,
		speed = 0,
	}

	--- Nerf roboport storage and radius as tradeoff.
	--- Due to the researches being available right after unlocking, it starts out with no benefits.
	self.logistics_radius = settings.energy_logistics_radius:get()
	self.construction_radius = settings.energy_construction_radius:get()
	self.robot_slots_count = settings.energy_robot_slots:get()
	self.material_slots_count = settings.energy_material_slots:get()

	self:_apply_energy()
	self.name = self:get_name()
	self.localised_name = self:get_localised_name()
	return self
end

function EnergyRoboport:_apply_energy()
	-- Helper to calculate "Base + (Base * Multiplier * Modifier)"
	---@param base data.Energy
	---@param mod SettingContainer<number>
	---@param multiplier integer
	local function get_scaled(base, mod, multiplier)
		local base = Energy.new(base)
		-- This assumes your Energy class can handle math or you extract the value
		local scaled_value = base:value() * (1 + (multiplier * mod:get()))
		return Energy.new(scaled_value .. base:suffix())
	end

	-- 1. Update Object State
	self.recharge_minimum =
		tostring(get_scaled(self.recharge_minimum, settings.recharge_minimum_modifier, self.levels.efficiency))
	self.energy_usage = tostring(get_scaled(self.energy_usage, settings.energy_usage_modifier, self.levels.efficiency))
	self.charging_energy =
		tostring(get_scaled(self.charging_energy, settings.charging_energy_modifier, self.levels.speed))

	-- 3. Update Offsets
	local count = #self.charging_offsets
	self.charging_offsets = offsets.generate_charging_offsets(count + (count * self.levels.productivity))

	-- 4. Update energy source
	self.energy_source = {
		type = "electric",
		usage_priority = "secondary-input",
		input_flow_limit = tostring(
			get_scaled(self.energy_source.input_flow_limit, settings.input_flow_limit_modifier, self.levels.efficiency)
		),
		buffer_capacity = tostring(
			get_scaled(self.energy_source.buffer_capacity, settings.buffer_capacity_modifier, self.levels.efficiency)
		),
	}
end

function EnergyRoboport:get_suffix()
	return tostring(
		"e"
			.. number.within_bounds(self.levels.efficiency, 0, settings.energy_efficiency_limit:get())
			.. "p"
			.. number.within_bounds(self.levels.productivity, 0, settings.energy_productivity_limit:get())
			.. "s"
			.. number.within_bounds(self.levels.speed, 0, settings.energy_speed_limit:get())
	)
end

local function create_bases()
	local entity = EnergyRoboport.new()
	entity.name = "energy-roboport"
	local recipe = entity:recipes()[1]
	local item = entity:items()[1]
	entity.localised_name = entity.name
	return {
		item,
		recipe,
		entity,
	}
end

local function create_variants()
	local to_add = {}

	for e = 0, settings.energy_efficiency_limit:get() do
		for p = 0, settings.energy_productivity_limit:get() do
			for s = 0, settings.energy_speed_limit:get() do
				entity = EnergyRoboport.new({
					efficiency = e,
					productivity = p,
					speed = s,
				})
				if settings.show_items:get() then
					item = entity:items()[1]
					item.subgroup = "item-sub-group-roboport"
					table.insert(to_add, item)
				end
				table.insert(to_add, entity)
			end
		end
	end
	return to_add
end

data:extend(create_bases())
data:extend(create_variants())
