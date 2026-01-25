local Energy = require("__heroic-library__.energy")
local BaseRoboport = require("prototypes.roboport.base")
local offsets = require("helpers.charging_offset")
local settings = require("settings")


---@class LogisticalRoboport: BaseRoboport
---@field levels table<string, integer>
local LogisticalRoboport = setmetatable({}, { __index = BaseRoboport })
LogisticalRoboport.__index = LogisticalRoboport

---@class LogisticalLevels
---@field construction_area integer
---@field logistic_area integer
---@field robot_storage integer
---@field material_storage integer

---@return self
---@param levels LogisticalLevels | nil
function LogisticalRoboport.new(levels)
    local self = setmetatable(BaseRoboport.new(), LogisticalRoboport) --[[@as LogisticalRoboport]]
    self.name = "logistical-roboport"
    self.levels = levels or {
        construction_area = 0,
        logistic_area = 0,
        robot_storage = 0,
        material_storage = 0,
    }

    -- Buff roboport storage and radius as benefit.
    self.logistics_radius =
        settings.logistical_logistics_radius:get()
        + (settings.logistical_logistics_radius_modifier:get()
            * self.levels.logistic_area)
    self.construction_radius =
        settings.logistical_construction_radius:get()
        + (settings.logistical_construction_radius_modifier:get()
            * self.levels.construction_area)
    self.robot_slots_count =
        settings.logistical_robot_slots:get()
        + (settings.logistical_robot_modifier:get()
            * self.levels.robot_storage)
    self.material_slots_count =
        settings.logistical_material_slots:get()
        + (settings.logistical_material_modifier:get()
            * self.levels.material_storage)

    self:_apply_energy()
    self.localised_name = self:get_localised_name()
    return self
end

function LogisticalRoboport:_apply_energy()
    -- Nerf energy usage as tradeoff. Half as effective at charging than the normal roboport.
    local recharge_minimum = Energy.new(self.recharge_minimum)
    local energy_usage = Energy.new(self.energy_usage)
    self.recharge_minimum = tostring(recharge_minimum:value()) .. recharge_minimum:suffix()
    self.energy_usage = tostring(energy_usage:value()) .. energy_usage:suffix()

    -- Lower amount of simultaneously charging robots discourages them from going here.
    -- Increased charge rate to avoid robots taking too long to charge.
    local charging_energy = Energy.new(self.charging_energy)
    self.charging_energy = tostring(
        charging_energy:with_scale(#self.charging_offsets or self.charging_station_count))
    self.charging_offsets = offsets.generate_charging_offsets(1)
end

function LogisticalRoboport:get_suffix()
    return tostring(
        "c"
        .. number.within_bounds(
            self.levels.construction_area,
            0,
            settings.construction_area_limit:get())
        .. "l"
        .. number.within_bounds(
            self.levels.logistic_area,
            0,
            settings.logistic_area_limit:get())
        .. "r"
        .. number.within_bounds(
            self.levels.robot_storage,
            0,
            settings.robot_storage_limit:get())
        .. "m"
        .. number.within_bounds(
            self.levels.material_storage,
            0,
            settings.material_storage_limit:get()))
end

local function create_bases()
    local entity = LogisticalRoboport.new()
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

    for c = 0, settings.construction_area_limit:get() do
        for l = 0, settings.logistic_area_limit:get() do
            for r = 0, settings.robot_storage_limit:get() do
                for m = 0, settings.material_storage_limit:get() do
                    entity = LogisticalRoboport.new({
                        construction_area = c,
                        logistic_area = l,
                        robot_storage = r,
                        material_storage = m,
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
    end
    return to_add
end

data:extend(create_bases())
data:extend(create_variants())
