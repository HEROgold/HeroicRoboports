require("__heroic-library__.utilities")
require("__heroic-library__.vars.words")
require("__heroic-library__.vars.strings")
require("__heroic-library__.entities")
require("vars.settings")
require("vars.strings")
require("script.commands")
require("helpers.levels")
require("helpers.suffix")

script.on_init(
	function (event)
		InitializeStorage()
	end
)

function InitializeStorage()
	storage.roboports_to_update = {}
	storage.ghosts_to_update = {}
end

---@param roboport LuaEntity
local function validate_roboport(roboport)
	if roboport == nil then return end
	if not roboport.valid then
		storage.roboports_to_update[roboport] = nil
		return
	end

	local roboport_name = roboport.name
	if roboport_name == Roboport then
		-- The entity is from vanilla Factorio
		return true
	elseif utilities.string_starts_with(roboport_name, RoboportEnergyLeveled) then
		local port_levels = energy_levels_from_name(roboport_name)
		---@diagnostic disable-next-line: param-type-mismatch
		local tech_levels = get_energy_levels(roboport.force)
		-- Check for correct levels, to avoid replacing already correct (or higher tier) roboports.
		if (
			port_levels[1] < tech_levels[1]
			or port_levels[2] < tech_levels[2]
			or port_levels[3] < tech_levels[3]
		) then
			return true
		end
	elseif utilities.string_starts_with(roboport_name, RoboportLogisticalLeveled) then 
		local port_levels = storage_levels_from_name(roboport_name)
		---@diagnostic disable-next-line: param-type-mismatch
		local tech_levels = get_logistical_levels(roboport.force)
		if (
			port_levels[1] < tech_levels[1]
			or port_levels[2] < tech_levels[2]
			or port_levels[3] < tech_levels[3]
			or port_levels[4] < tech_levels[4]
		) then
			return true
		end
	elseif utilities.string_starts_with(roboport_name, RoboportEnergy) then
		return true
	elseif utilities.string_starts_with(roboport_name, RoboportLogistical) then
		return true
	else
		return false
	end
end


---@param ghost LuaEntity
---@return boolean
local function validate_ghost(ghost)
	if ghost == nil then
		return false
	end
	if (
		not ghost.valid
		or not utilities.string_starts_with(ghost.ghost_name, RoboportEnergyLeveled)
		and not utilities.string_starts_with(ghost.ghost_name, RoboportLogisticalLeveled)
	) then
		storage.ghosts_to_update[ghost] = nil
		return false
	end
	return true
end

---@param roboport LuaEntity
local function update_energy_roboport_level(roboport)
	local surface = roboport.surface
	local old_energy = roboport.energy
	local force = roboport.force
	local suffix = get_energy_suffix(
		---@diagnostic disable-next-line: param-type-mismatch
		table.unpack(get_energy_levels(force))
	)

	local created_rport = surface.create_entity{
		name = combine{RoboportEnergyLeveled, suffix},
		position = roboport.position,
		force = roboport.force,
		fast_replace = true,
		spill = false,
		create_build_effect_smoke = false,
		raise_built = false,
		quality = roboport.quality
	}

	created_rport.energy = old_energy
	storage.roboports_to_update[roboport] = nil

	roboport.destroy()
end

---@param roboport LuaEntity
local function update_storage_roboport_level(roboport)
	local surface = roboport.surface
	local old_energy = roboport.energy
	local force = roboport.force
	local storage_suffix = get_storage_suffix(
		---@diagnostic disable-next-line: param-type-mismatch
		table.unpack(get_logistical_levels(force))
	)

	local created_rport = surface.create_entity{
		name = combine{RoboportLogisticalLeveled, storage_suffix},
		position = roboport.position,
		force = roboport.force,
		fast_replace = true,
		spill = false,
		create_build_effect_smoke = false,
		raise_built = false,
		quality = roboport.quality,
	}

	created_rport.energy = old_energy
	storage.roboports_to_update[roboport] = nil

	roboport.destroy()
end


---@param roboport LuaEntity
local function update_ghost_level(roboport)
	if not validate_ghost(roboport) then
		return
	end

	local to_create = {}

	if utilities.string_starts_with(roboport.ghost_name, RoboportLogisticalLeveled) then
		to_create = {
			name = EntityGhost,
			type = EntityGhost,
			ghost_name = RoboportLogistical,
			ghost_ype = Roboport,
			ghost_prototype = Roboport,
			position = roboport.position,
			force = roboport.force,
			fast_replace = true,
			spill = false,
			create_build_effect_smoke = false,
			raise_built = false,
			quality = roboport.quality
		}
	elseif utilities.string_starts_with(roboport.ghost_name, RoboportEnergy) then
		to_create = {
			name = EntityGhost,
			type = EntityGhost,
			ghost_name = RoboportEnergy,
			ghost_type = Roboport,
			ghost_prototype = Roboport,
			position = roboport.position,
			force = roboport.force,
			fast_replace = true,
			spill = false,
			create_build_effect_smoke = false,
			raise_built = false,
			quality = roboport.quality
		}
	end

	local surface = roboport.surface
	local created_rport = surface.create_entity(to_create)
	storage.ghosts_to_update[roboport] = nil

	roboport.destroy()
end

---@param roboport LuaEntity
local function update_roboport_level(roboport)
	if not validate_roboport(roboport) then return end

	if utilities.string_starts_with(roboport.name, RoboportLogistical) then
		update_storage_roboport_level(roboport)
	elseif utilities.string_starts_with(roboport.name, RoboportEnergy) then
		update_energy_roboport_level(roboport)
	else
		storage.roboports_to_update[roboport] = nil
	end
end


local function tick_update_roboport_level()
	local roboport, needs_upgrade = next(storage.roboports_to_update)
	if roboport == nil then
		return
	end
	if needs_upgrade then
		update_roboport_level(roboport)
	end
end


local function tick_update_ghost_level()
	local roboport, needs_downgrade = next(storage.ghosts_to_update)
	if roboport == nil then
		return
	end
	if needs_downgrade then
		update_ghost_level(roboport)
	end
end

---@param force LuaForce
local function mark_all_roboports_for_update(force)
	for _, surface in pairs(game.surfaces) do
		for _, roboport in pairs(surface.find_entities_filtered{
			type = Roboport,
			force = force
		}) do
			update_roboport_level(roboport)
			-- TODO: Test if direct upgrade kills performance!
			-- storage.roboports_to_update[roboport] = true
		end
	end
end


script.on_event(defines.events.on_research_finished,
	---@param event EventData.on_research_finished
	function (event)
		mark_all_roboports_for_update(event.research.force)
	end
)


script.on_event(defines.events.on_research_reversed,
	---@param event EventData.on_research_reversed
	function (event)
		mark_all_roboports_for_update(event.research.force)
	end
)


---@param entity LuaEntity
local function on_built(entity)
	if entities.is_ghost(entity) and validate_ghost(entity) then
		update_ghost_level(entity)
	elseif entity.type == Roboport and validate_roboport(entity) then
		update_roboport_level(entity)
	end
end


script.on_event(
	{
		defines.events.on_built_entity,
		defines.events.on_robot_built_entity,
		defines.events.on_post_entity_died,
		defines.events.script_raised_built,
		defines.events.script_raised_revive,
	},
	---@param event EventData.on_built_entity | EventData.on_robot_built_entity | EventData.on_post_entity_died | EventData.script_raised_built | EventData.script_raised_revive
function (event)
	if event.ghost then
		on_built(event.ghost)
		return
	end
	if event.entity then
		on_built(event.entity)
		return
	end
	if event.created_entity then
		on_built(event.created_entity)
		return
	end
end
)

script.on_event(
	{
		defines.events.on_player_mined_entity,
		defines.events.on_robot_mined_entity,
		defines.events.on_entity_died,
		defines.events.script_raised_destroy,
	},
	---@param event EventData.on_player_mined_entity | EventData.on_robot_mined_entity | EventData.on_entity_died | EventData.script_raised_destroy
	function (event)
		if event.entity == nil or not event.entity.valid then
			return
		end
		storage.roboports_to_update[event.entity] = nil
	end
)

script.on_nth_tick(
	upgrade_timer,
	function ()
		tick_update_roboport_level()
		tick_update_ghost_level()
	end
)

script.on_event(defines.events.on_player_selected_area,
	---@param event EventData.on_player_selected_area
function(event)
	if event.item ~= RoboportUpdater then
		return
	end

	for _, entity in pairs(event.entities) do
		if entities.is_ghost(entity) then
			update_ghost_level(entity)
		else
			update_roboport_level(entity)
		end
	end
end
)
