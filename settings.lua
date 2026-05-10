require("__heroic-library__.string")
require("__heroic-library__.number")
---@type Settings
local Settings = require("__heroic-library__.settings_manager").new("heroic-roboports")
local startup = Settings:startup()

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
energy_speed_limit = startup:default("energy-speed-limit", 9, {
    minimum = 1,
    maximum = 90,
})
energy_productivity_limit = startup:default("energy-productivity-limit", 9, {
    minimum = 1,
    maximum = 90,
})
energy_efficiency_limit = startup:default("energy-efficiency-limit", 9, {
    minimum = 1,
    maximum = 90,
})

-- Logistical Roboport Settings
construction_area_limit = startup:default("construction-area-limit", 9, {
    minimum = 1,
    maximum = 90,
})
logistic_area_limit = startup:default("logistic-area-limit", 9, {
    minimum = 1,
    maximum = 90,
})
robot_storage_limit = startup:default("robot-storage-limit", 9, {
    minimum = 1,
    maximum = 90,
})
material_storage_limit = startup:default("material-storage-limit", 9, {
    minimum = 1,
    maximum = 90,
})

--- Research Settings

research_minimum = startup:default("research-minimum", 3, {
    minimum = 1,
    maximum = 90,
})
research_maximum = startup:default("research-maximum", 9, {
    minimum = 1,
    maximum = 90,
})
research_upgrade_cost = startup:default("research-upgrade-cost", 500, {
    minimum = 1,
})
research_upgrade_time = startup:default("research-upgrade-time", 60, {
    minimum = 1,
})

-- Mod Settings
upgrade_timer = startup:default("upgrade-timer", 8, {
    minimum = 1,
})

show_items = startup:default("show-items", true)

-- Roboport specific modifiers and slot counts
energy_robot_slots = startup:default("energy-roboport-robot-slots", 0, { minimum = 0, maximum = 100 })
energy_material_slots = startup:default("energy-roboport-material-slots", 0, { minimum = 0, maximum = 100 })
energy_logistics_radius = startup:default("energy-roboport-logistics-radius", 20, { minimum = 0, maximum = 500 })
energy_construction_radius = startup:default("energy-roboport-construction-radius", 45, { minimum = 0, maximum = 500 })

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
    research_upgrade_time = research_upgrade_time,

    upgrade_timer = upgrade_timer,
    show_items = show_items,

    energy_robot_slots = energy_robot_slots,
    energy_material_slots = energy_material_slots,
    energy_logistics_radius = energy_logistics_radius,
    energy_construction_radius = energy_construction_radius,

    logistical_construction_radius = logistical_construction_radius,
    logistical_construction_radius_modifier = logistical_construction_radius_modifier,
    logistical_logistics_radius_modifier = logistical_logistics_radius_modifier,
    logistical_logistics_radius = logistical_logistics_radius,
    logistical_robot_slots = logistical_robot_slots,
    logistical_material_slots = logistical_material_slots,
    logistical_robot_modifier = logistical_robot_modifier,
    logistical_material_modifier = logistical_material_modifier,
}
