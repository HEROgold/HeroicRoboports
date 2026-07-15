require("__heroic-library__.number")
local Energy = require("__heroic-library__.energy")
local BaseRoboport = require("prototypes.roboport.base")
local offsets = require("helpers.charging_offset")
local settings = require("settings")
local codec = require("name_codec")
local LevelSet = require("level_set")
local Limits = require("limits")

---@class EnergyRoboport: BaseRoboport
---@field levels LevelSet
local EnergyRoboport = setmetatable({}, { __index = BaseRoboport })
EnergyRoboport.__index = EnergyRoboport

---@param levels table<string, integer>|nil
---@return EnergyRoboport
function EnergyRoboport.new(levels)
    local self = setmetatable(BaseRoboport.new(), EnergyRoboport) --[[@as EnergyRoboport]]
    self._name = "energy-roboport"
    self.minable.result = self._name
    self:apply_icon_overlay("__base__/graphics/icons/signal/signal-lightning.png")

    self.levels = LevelSet.new(levels or { efficiency = 0, productivity = 0, speed = 0 }, Limits.energy)

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

function EnergyRoboport:recipes()
    local super = BaseRoboport.recipes(self)
    for _, recipe in ipairs(super) do
        if not recipe.ingredients then goto continue end
        table.insert(recipe.ingredients, { type = "item", name = "battery", amount = 75 })
        ::continue::
    end
    return super
end


function EnergyRoboport:get_suffix()
    return codec.energy:suffix(self.levels:values())
end

function EnergyRoboport:_apply_energy()
    local efficiency = self.levels:get("efficiency")
    local productivity = self.levels:get("productivity")
    local speed = self.levels:get("speed")

    -- "Base + Base * level * modifier" via Energy:scaled.
    self.recharge_minimum =
        tostring(Energy.new(self.recharge_minimum):scaled(efficiency, settings.recharge_minimum_modifier:get()))
    self.energy_usage =
        tostring(Energy.new(self.energy_usage):scaled(efficiency, settings.energy_usage_modifier:get()))
    self.charging_energy =
        tostring(Energy.new(self.charging_energy):scaled(speed, settings.charging_energy_modifier:get()))

    -- More productivity -> more simultaneous charging spots.
    local count = #self.charging_offsets
    self.charging_offsets = offsets.generate_charging_offsets(count + (count * productivity))

    -- Quality increases the number of simultaneous charging spots on top of the productivity
    -- scaling above, via the vanilla quality prototype's logistic_cell_charging_station_count_bonus.
    -- This is the ONLY roboport property Factorio 2.1 lets scale with quality; area, slot counts,
    -- and the internal energy buffer have no native quality support, so those parts of the request
    -- cannot be honored on a roboport prototype (see docs/quality-scaling.md).
    self.charging_station_count_affected_by_quality = true

    self.energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        input_flow_limit = tostring(
            Energy.new(self.energy_source.input_flow_limit):scaled(efficiency, settings.input_flow_limit_modifier:get())
        ),
        buffer_capacity = tostring(
            Energy.new(self.energy_source.buffer_capacity):scaled(efficiency, settings.buffer_capacity_modifier:get())
        ),
    }
end

local function create_bases()
    local entity = EnergyRoboport.new()
    entity.name = "energy-roboport"
    local recipe = entity:recipes()[1]
    local item = entity:items()[1]
    item.subgroup = "logistic-network"
    item.order = "c[signal]-a[roboport]-b[energy-roboport]"
    entity.localised_name = { "entity-name.energy-roboport" }
    return {
        item,
        recipe,
        entity,
    }
end

local function create_variants()
    local to_add = {}

    for e = 0, Limits.energy.efficiency do
        for p = 0, Limits.energy.productivity do
            for s = 0, Limits.energy.speed do
                local entity = EnergyRoboport.new({
                    efficiency = e,
                    productivity = p,
                    speed = s,
                })
                if settings.show_items:get() then
                    local item = entity:items()[1]
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
