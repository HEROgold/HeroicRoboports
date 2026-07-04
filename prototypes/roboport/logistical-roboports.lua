require("__heroic-library__.number")
local Energy = require("__heroic-library__.energy")
local BaseRoboport = require("prototypes.roboport.base")
local offsets = require("helpers.charging_offset")
local settings = require("settings")
local codec = require("name_codec")
local LevelSet = require("level_set")
local Limits = require("limits")

---@class LogisticalRoboport: BaseRoboport
---@field levels LevelSet
local LogisticalRoboport = setmetatable({}, { __index = BaseRoboport })
LogisticalRoboport.__index = LogisticalRoboport

---@param levels table<string, integer>|nil
---@return LogisticalRoboport
function LogisticalRoboport.new(levels)
    local self = setmetatable(BaseRoboport.new(), LogisticalRoboport) --[[@as LogisticalRoboport]]
    self._name = "logistical-roboport"
    self.minable.result = self._name
    self:apply_icon_overlay("__base__/graphics/icons/storage-chest.png")

    self.levels = LevelSet.new(levels or {
        construction_area = 0,
        logistic_area = 0,
        robot_storage = 0,
        material_storage = 0,
    }, Limits.logistical)

    -- Buff roboport storage and radius as benefit.
    self.logistics_radius = settings.logistical_logistics_radius:get()
        + (settings.logistical_logistics_radius_modifier:get() * self.levels:get("logistic_area"))
    self.construction_radius = settings.logistical_construction_radius:get()
        + (settings.logistical_construction_radius_modifier:get() * self.levels:get("construction_area"))
    self.robot_slots_count = settings.logistical_robot_slots:get()
        + (settings.logistical_robot_modifier:get() * self.levels:get("robot_storage"))
    self.material_slots_count = settings.logistical_material_slots:get()
        + (settings.logistical_material_modifier:get() * self.levels:get("material_storage"))

    self:_apply_energy()
    self.name = self:get_name()
    self.localised_name = self:get_localised_name()
    return self
end

function LogisticalRoboport:get_suffix()
    return codec.logistical:suffix(self.levels:values())
end

function LogisticalRoboport:_apply_energy()
    -- Nerf energy usage as tradeoff. Half as effective at charging than the normal roboport.
    self.recharge_minimum = tostring(Energy.new(self.recharge_minimum))
    self.energy_usage = tostring(Energy.new(self.energy_usage))

    -- Lower amount of simultaneously charging robots discourages them from going here.
    -- Increased charge rate to avoid robots taking too long to charge.
    local charging_energy = Energy.new(self.charging_energy)
    self.charging_energy = tostring(charging_energy:with_scale(#self.charging_offsets))
    self.charging_offsets = offsets.generate_charging_offsets(1)
end

local function create_bases()
    local entity = LogisticalRoboport.new()
    entity.name = "logistical-roboport"
    local recipe = entity:recipes()[1]
    local item = entity:items()[1]
    item.subgroup = "logistic-network"
    item.order = "c[signal]-a[roboport]-c[logistical-roboport]"
    entity.localised_name = { "entity-name.logistical-roboport" }
    return {
        item,
        recipe,
        entity,
    }
end

local function create_variants()
    local to_add = {}

    for c = 0, Limits.logistical.construction_area do
        for l = 0, Limits.logistical.logistic_area do
            for r = 0, Limits.logistical.robot_storage do
                for m = 0, Limits.logistical.material_storage do
                    local entity = LogisticalRoboport.new({
                        construction_area = c,
                        logistic_area = l,
                        robot_storage = r,
                        material_storage = m,
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
    end
    return to_add
end

data:extend(create_bases())
data:extend(create_variants())
