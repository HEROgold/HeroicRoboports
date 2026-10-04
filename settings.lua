require("__heroic-library__.string")
require("__heroic-library__.number")
---@type Settings
local Settings = require("__heroic-library__.settings_manager").new("heroic-roboports")
local startup = Settings:startup()
local runtime = Settings:global()

-- Hard ceiling on levels per axis. Logistical variants grow as (levels + 1)^4 and every variant is
-- an entity (plus an item with show-items), so 12 levels is 28,561 logistical entities, well under
-- Factorio's 65,535 per-category prototype limit. 15 levels would hit it exactly.
local MAX_RESEARCH_LEVEL = 12
-- Default levels per axis. Higher values work, but every level adds roboport variants and load time.
local DEFAULT_RESEARCH_LEVEL = 6

-- Energy Roboport Settings
input_flow_limit_modifier = startup:default("input-flow-limit-modifier", 1.0, {
    minimum = 0.1,
})
buffer_capacity_modifier = startup:default("buffer-capacity-modifier", 1.0, {
    minimum = 0.1,
})
recharge_minimum_modifier = startup:default("recharge-minimum-modifier", 1.0, {
    minimum = 0.1,
})
energy_usage_modifier = startup:default("energy-usage-modifier", 1.0, {
    minimum = 0.1,
})
charging_energy_modifier = startup:default("charging-energy-modifier", 1.0, {
    minimum = 0.1,
})
energy_speed_limit = startup:default("energy-speed-limit", DEFAULT_RESEARCH_LEVEL, {
    minimum = 1,
    maximum = MAX_RESEARCH_LEVEL,
})
energy_productivity_limit = startup:default("energy-productivity-limit", DEFAULT_RESEARCH_LEVEL, {
    minimum = 1,
    maximum = MAX_RESEARCH_LEVEL,
})
energy_efficiency_limit = startup:default("energy-efficiency-limit", DEFAULT_RESEARCH_LEVEL, {
    minimum = 1,
    maximum = MAX_RESEARCH_LEVEL,
})

-- Logistical Roboport Settings
construction_area_limit = startup:default("construction-area-limit", DEFAULT_RESEARCH_LEVEL, {
    minimum = 1,
    maximum = MAX_RESEARCH_LEVEL,
})
logistic_area_limit = startup:default("logistic-area-limit", DEFAULT_RESEARCH_LEVEL, {
    minimum = 1,
    maximum = MAX_RESEARCH_LEVEL,
})
robot_storage_limit = startup:default("robot-storage-limit", DEFAULT_RESEARCH_LEVEL, {
    minimum = 1,
    maximum = MAX_RESEARCH_LEVEL,
})
material_storage_limit = startup:default("material-storage-limit", DEFAULT_RESEARCH_LEVEL, {
    minimum = 1,
    maximum = MAX_RESEARCH_LEVEL,
})

--- Research Settings

research_minimum = startup:default("research-minimum", 3, {
    minimum = 1,
    maximum = MAX_RESEARCH_LEVEL,
})
research_maximum = startup:default("research-maximum", DEFAULT_RESEARCH_LEVEL, {
    minimum = 1,
    maximum = MAX_RESEARCH_LEVEL,
})
research_upgrade_cost = startup:default("research-upgrade-cost", 500, {
    minimum = 1,
})
-- Multiplier for the logistical research cost curve: count = cost * (1 + level * multiplier).
research_cost_multiplier = startup:default("research-cost-multiplier", 2, {
    minimum = 0,
})
-- Multiplier for the energy research cost curve: count = cost * L * multiplier.
energy_research_cost_multiplier = startup:default("energy-research-cost-multiplier", 1, {
    minimum = 1,
})
-- Seed for deterministically assigning extra (other-mod) science packs to higher logistical
-- tiers. Shared across multiplayer clients so every client generates the same tech tree.
research_tier_seed = startup:default("research-tier-seed", 0, {})
research_upgrade_time = startup:default("research-upgrade-time", 60, {
    minimum = 1,
})

-- Mod Settings (runtime-global so the upgrade queue cadence can be tuned without a restart)
upgrade_timer = runtime:default("upgrade-timer", 8, {
    minimum = 1,
})
upgrade_batch_size = runtime:default("upgrade-batch-size", 20, {
    minimum = 1,
})

show_items = startup:default("show-items", true)

-- Roboport specific modifiers and slot counts
energy_robot_slots = startup:default("energy-roboport-robot-slots", 4, { minimum = 0, maximum = 100 })
energy_material_slots = startup:default("energy-roboport-material-slots", 0, { minimum = 0, maximum = 100 })
energy_logistics_radius = startup:default("energy-roboport-logistics-radius", 20, { minimum = 0, maximum = 500 })
energy_construction_radius = startup:default("energy-roboport-construction-radius", 45, { minimum = 0, maximum = 500 })
-- Charging pads added per productivity level, on top of the vanilla roboport's pads.
energy_pads_per_productivity =
    startup:default("energy-roboport-pads-per-productivity", 4, { minimum = 0, maximum = 100 })

logistical_logistics_radius =
    startup:default("logistical-roboport-logistics-radius", 30, { minimum = 0, maximum = 500 })
logistical_construction_radius =
    startup:default("logistical-roboport-construction-radius", 60, { minimum = 0, maximum = 500 })
logistical_robot_slots = startup:default("logistical-roboport-robot-slots", 10, { minimum = 0, maximum = 100 })
logistical_material_slots = startup:default("logistical-roboport-material-slots", 10, { minimum = 0, maximum = 100 })
logistical_logistics_radius_modifier =
    startup:default("logistical-roboport-logistics-radius-modifier", 5, { minimum = -100, maximum = 100 })
logistical_construction_radius_modifier =
    startup:default("logistical-roboport-construction-radius-modifier", 10, { minimum = -100, maximum = 100 })
logistical_robot_modifier = startup:default("logistical-roboport-robot-modifier", 1, { minimum = 0, maximum = 100 })
logistical_material_modifier =
    startup:default("logistical-roboport-material-modifier", 1, { minimum = 0, maximum = 100 })

return {
    MAX_RESEARCH_LEVEL = MAX_RESEARCH_LEVEL,

    input_flow_limit_modifier = input_flow_limit_modifier,
    buffer_capacity_modifier = buffer_capacity_modifier,
    recharge_minimum_modifier = recharge_minimum_modifier,
    energy_usage_modifier = energy_usage_modifier,
    charging_energy_modifier = charging_energy_modifier,
    energy_speed_limit = energy_speed_limit,
    energy_productivity_limit = energy_productivity_limit,
    energy_efficiency_limit = energy_efficiency_limit,

    construction_area_limit = construction_area_limit,
    logistic_area_limit = logistic_area_limit,
    robot_storage_limit = robot_storage_limit,
    material_storage_limit = material_storage_limit,

    research_minimum = research_minimum,
    research_maximum = research_maximum,
    research_upgrade_cost = research_upgrade_cost,
    research_cost_multiplier = research_cost_multiplier,
    energy_research_cost_multiplier = energy_research_cost_multiplier,
    research_tier_seed = research_tier_seed,
    research_upgrade_time = research_upgrade_time,

    upgrade_timer = upgrade_timer,
    upgrade_batch_size = upgrade_batch_size,
    show_items = show_items,

    energy_robot_slots = energy_robot_slots,
    energy_material_slots = energy_material_slots,
    energy_logistics_radius = energy_logistics_radius,
    energy_construction_radius = energy_construction_radius,
    energy_pads_per_productivity = energy_pads_per_productivity,

    logistical_construction_radius = logistical_construction_radius,
    logistical_construction_radius_modifier = logistical_construction_radius_modifier,
    logistical_logistics_radius_modifier = logistical_logistics_radius_modifier,
    logistical_logistics_radius = logistical_logistics_radius,
    logistical_robot_slots = logistical_robot_slots,
    logistical_material_slots = logistical_material_slots,
    logistical_robot_modifier = logistical_robot_modifier,
    logistical_material_modifier = logistical_material_modifier,
}
