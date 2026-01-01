require("__heroic-library__.vars.words")
local Energy = require("__heroic-library__.energy")
require("vars.settings")
require("vars.strings")
require("helpers.suffix")
require("helpers.charging_offset")

local base_roboport_entity = data.raw[Roboport][Roboport]
local base_roboport_item = data.raw[Item][Roboport]

local robot_storage_limit = math.max(robot_storage_limit, research_minimum)
local material_storage_limit = math.max(material_storage_limit, research_minimum)
local construction_area_limit = math.max(construction_area_limit, research_minimum)
local logistic_area_limit = math.max(logistic_area_limit, research_minimum)
local logistical_roboport_entity = table.deepcopy(base_roboport_entity)
local logistical_roboport_item = table.deepcopy(base_roboport_item)


logistical_roboport_item.name = RoboportLogistical
logistical_roboport_entity.name = RoboportLogistical

logistical_roboport_item.place_result = logistical_roboport_entity.name
-- logistical_roboport_item.hidden = false

logistical_roboport_entity.minable.result = logistical_roboport_item.name

-- Nerf energy usage as tradeoff. Half as effective at charging than the normal roboport.
local recharge_minimum = Energy.new(logistical_roboport_entity.recharge_minimum)
local energy_usage = Energy.new(logistical_roboport_entity.energy_usage)
local charging_energy = Energy.new(logistical_roboport_entity.charging_energy)

logistical_roboport_entity.recharge_minimum = tostring(recharge_minimum:value()) .. recharge_minimum:suffix()
logistical_roboport_entity.energy_usage = tostring(energy_usage:value()) .. energy_usage:suffix()
logistical_roboport_entity.charging_energy = tostring(charging_energy:value() * 5) .. charging_energy:suffix()
logistical_roboport_entity.charging_offsets = generate_charging_offsets(1)
-- Lower amount of simultaneously charging robots discourages them from going here.
-- Increased charge rate to avoid robots taking too long to charge.

-- Buff roboport storage and radius as benefit.
logistical_roboport_entity.logistics_radius = base_roboport_entity.logistics_radius + 5 -- TODO: Move these values to startup settings
logistical_roboport_entity.construction_radius = base_roboport_entity.construction_radius + 10 -- TODO: Move these values to startup settings
logistical_roboport_entity.robot_slots_count = 10 -- TODO: Move these values to startup settings
logistical_roboport_entity.material_slots_count = 10 -- TODO: Move these values to startup settings


---@type data.RecipePrototype
local storage_roboport_recipe = {
    type = "recipe",
    name = RoboportLogistical,
    enabled = false,
    ---@type data.IngredientPrototype[]
    ingredients = {
        {type = Item, name =Roboport, amount = 1},
        {type = Item, name ="steel-plate", amount = 100},
    },
    ---@type data.ItemProductPrototype[]
    results = {{type = Item, name = logistical_roboport_entity.name, amount = 1},},
    category = "crafting",
    unlock_results = true,
}

local function create_base_roboport()
    return {
        logistical_roboport_item,
        storage_roboport_recipe,
        logistical_roboport_entity,
    }
end

-- Helper function to create a logistical roboport variant
local function create_logistical_roboport_variant(base_item, base_entity, c, l, r, m)
    local roboport_item = table.deepcopy(base_item)
    local roboport_entity = table.deepcopy(base_entity)

    local suffix = get_storage_suffix(c, l, r, m)
    local name = combine{RoboportLogisticalLeveled, suffix}

    roboport_entity.localised_name = {"entity-name." .. RoboportLogisticalLeveled, tostring(c), tostring(l), tostring(r), tostring(m)}
    roboport_item.localised_name = {"item-name." .. RoboportLogisticalLeveled, tostring(c), tostring(l), tostring(r), tostring(m)}

    roboport_item.name = name
    roboport_entity.name = name
    roboport_item.place_result = roboport_entity.name
    roboport_entity.fast_replaceable_group = RoboportLogistical
    roboport_item.hidden = true

    -- Pre-calculate base values to avoid repeated access
    local rb = base_entity.robot_slots_count
    local mb = base_entity.material_slots_count
    local cb = base_entity.construction_radius
    local lb = base_entity.logistics_radius
    local ldb = base_entity.logistics_connection_distance or lb

    -- Apply upgrades with pre-calculated values
    roboport_entity.robot_slots_count = (rb * r) + rb
    roboport_entity.material_slots_count = (mb * m) + mb
    roboport_entity.construction_radius = (cb * c) + cb
    roboport_entity.logistics_radius = (lb * l) + lb
    roboport_entity.logistics_connection_distance = (ldb * l) + ldb
    return roboport_item, roboport_entity
end

local function create_roboports()
    local to_add = {}
    local show_items = settings.startup[ShowItems].value

    for c=0, construction_area_limit do 
        for l=0, logistic_area_limit do
            for r=0, robot_storage_limit do
                for m=0, material_storage_limit do
                    local roboport_item, roboport_entity = create_logistical_roboport_variant(
                        logistical_roboport_item, logistical_roboport_entity, c, l, r, m
                    )

                    if show_items then
                        roboport_item.subgroup = ItemSubGroupRoboport
                        table.insert(to_add, roboport_item)
                    end

                    table.insert(to_add, roboport_entity)
                end
            end
        end
    end
    return to_add
end

data:extend(create_base_roboport())
data:extend(create_roboports())
