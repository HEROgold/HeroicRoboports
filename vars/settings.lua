require("vars.strings")

---@diagnostic disable: assign-type-mismatch
---@type number
upgrade_timer = settings.startup[UpgradeTimer].value
---@type number
construction_area_limit = settings.startup[ConstructionAreaLimit].value
---@type number
logistic_area_limit = settings.startup[LogisticAreaLimit].value
---@type number
robot_storage_limit = settings.startup[RobotStorageLimit].value
---@type number
material_storage_limit = settings.startup[MaterialStorageLimit].value
---@type number
energy_speed_limit = settings.startup[EnergySpeedLimit].value
---@type number
energy_productivity_limit = settings.startup[EnergyProductivityLimit].value
---@type number
energy_efficiency_limit = settings.startup[EnergyEfficiencyLimit].value
---@type number
research_minimum = settings.startup[ResearchMinimum].value
---@type number
research_maximum = settings.startup[ResearchMaximum].value
---@type number
input_flow_limit_modifier = settings.startup[InputFlowLimitModifier].value
---@type number
buffer_capacity_modifier = settings.startup[BufferCapacityModifier].value
---@type number
recharge_minimum_modifier = settings.startup[RechargeMinimumModifier].value
---@type number
energy_usage_modifier = settings.startup[EnergyUsageModifier].value
---@type number
charging_energy_modifier = settings.startup[ChargingEnergyModifier].value
---@type number
research_upgrade_cost = settings.startup[RoboportResearchUpgradeCost].value
---@type number
research_upgrade_time = settings.startup[RoboportResearchUpgradeTime].value
