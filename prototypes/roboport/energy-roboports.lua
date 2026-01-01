require("__heroic-library__.vars.words")
local Energy = require("__heroic-library__.energy")
require("vars.settings")
require("vars.strings")
require("helpers.suffix")
require("helpers.charging_offset")

local base_roboport_entity = data.raw[Roboport][Roboport]
local base_roboport_item = data.raw[Item][Roboport]

local efficiency_limit = math.max(Limits[Efficiency], research_minimum)
local productivity_limit = math.max(Limits[Productivity], research_minimum)
local speed_limit = math.max(Limits[Speed], research_minimum)

local energy_roboport_entity = table.deepcopy(base_roboport_entity)
local energy_roboport_item = table.deepcopy(base_roboport_item)

energy_roboport_item.name = RoboportEnergy
energy_roboport_entity.name = RoboportEnergy

energy_roboport_item.place_result = energy_roboport_entity.name
energy_roboport_entity.minable.result = energy_roboport_item.name

-- Nerf roboport storage and radius as tradeoff.
energy_roboport_entity.robot_slots_count = 0
energy_roboport_entity.material_slots_count = 0
energy_roboport_entity.logistics_radius = base_roboport_entity.logistics_radius - 5 -- TODO: Move these values to startup settings
energy_roboport_entity.construction_radius = base_roboport_entity.construction_radius - 10 -- TODO: Move these values to startup settings
-- Due to the researches being available right after unlocking, it starts out with no benefits.

---@type data.RecipePrototype
local energy_roboport_recipe = {
    type = "recipe",
    name = RoboportEnergy,
    enabled = false,
    ---@type data.IngredientPrototype[]
    ingredients = {
        {type = Item, name =Roboport, amount = 1},
        {type = Item, name ="steel-plate", amount = 100},
    },
    ---@type data.ItemProductPrototype[]
    results = {{type = Item, name = energy_roboport_item.name, amount = 1},},
    category = "crafting",
    unlock_results = true,
}


-- Helper function to create a roboport variant
local function create_energy_roboport_variant(base_item, base_entity, e, p, s)
    local roboport_item = table.deepcopy(base_item)
    local roboport_entity = table.deepcopy(base_entity)

    local suffix = get_energy_suffix(e, p, s)
    local name = combine{RoboportEnergyLeveled, suffix}

    roboport_entity.localised_name = {"entity-name." .. RoboportEnergyLeveled, tostring(e), tostring(p), tostring(s)}
    roboport_item.localised_name = {"item-name." .. RoboportEnergyLeveled, tostring(e), tostring(p), tostring(s)}

    roboport_item.name = name
    roboport_entity.name = name
    roboport_item.hidden = true
    roboport_item.place_result = roboport_entity.name
    roboport_entity.fast_replaceable_group = RoboportEnergy

    -- Pre-calculate base values to avoid repeated string parsing
    local energy_source_e = Energy.new(base_entity.energy_source["input_flow_limit"])
    local buffer_capacity_e = Energy.new(base_entity.energy_source["buffer_capacity"])
    local recharge_minimum_e = Energy.new(base_entity.recharge_minimum)
    local energy_usage_e = Energy.new(base_entity.energy_usage)
    local charging_energy_e = Energy.new(base_entity.charging_energy)
    local charging_offset_count = #base_entity.charging_offsets
    local input_flow = energy_source_e:value() + energy_source_e:value()*e*input_flow_limit_modifier
    local input_flow_e = Energy.new(tostring(input_flow) .. energy_source_e:suffix())

    local scaled_buffer_capacity = Energy.new(buffer_capacity_e:value()*e*buffer_capacity_modifier .. buffer_capacity_e:suffix())
    local scaled_recharge_minimum = Energy.new(recharge_minimum_e:value()*e*recharge_minimum_modifier .. recharge_minimum_e:suffix())
    local scaled_energy_usage = Energy.new(energy_usage_e:value()*e*energy_usage_modifier .. energy_usage_e:suffix())
    local scaled_charging_energy = Energy.new(charging_energy_e:value()*s*charging_energy_modifier .. charging_energy_e:suffix())
    local scaled_input_flow = Energy.new(energy_source_e:value()*e*input_flow_limit_modifier .. energy_source_e:suffix())

    buffer_capacity_e:add(scaled_buffer_capacity)
    -- Apply upgrades with pre-calculated values -- Check if Speed levels actually charge faster!!
    roboport_entity.energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        input_flow_limit = tostring(input_flow) .. energy_source_e:suffix(),
        buffer_capacity = tostring(buffer_capacity_e),
    }

    recharge_minimum_e:add(scaled_recharge_minimum)
    energy_usage_e:add(scaled_energy_usage)
    charging_energy_e:add(scaled_charging_energy)

    roboport_entity.recharge_minimum = tostring(recharge_minimum_e)
    roboport_entity.energy_usage = tostring(energy_usage_e)
    roboport_entity.charging_energy = tostring(charging_energy_e)
    roboport_entity.charging_offsets = generate_charging_offsets(charging_offset_count + charging_offset_count * p)
    return roboport_item, roboport_entity
end

local function create_base_roboport()
    return {
        energy_roboport_item,
        energy_roboport_recipe,
        energy_roboport_entity,
    }
end

local function create_roboports()
    local to_add = {}
    local show_items = settings.startup[ShowItems].value

    for e=0, efficiency_limit do
        for p=0, productivity_limit do
            for s=0, speed_limit do
                local roboport_item, roboport_entity = create_energy_roboport_variant(
                    energy_roboport_item, energy_roboport_entity, e, p, s
                )

                if show_items then
                    roboport_item.subgroup = ItemSubGroupRoboport
                    table.insert(to_add, roboport_item)
                end
                table.insert(to_add, roboport_entity)
            end
        end
    end
    return to_add
end

data:extend(create_base_roboport())
data:extend(create_roboports())
