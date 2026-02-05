local settings = require("settings")

---@param efficiency_level integer
---@param productivity_level integer
---@param speed_level integer
---@return string
function get_energy_suffix(efficiency_level, productivity_level, speed_level)
    efficiency_level = number.within_bounds(efficiency_level, 0, settings.energy_efficiency_limit:get())
    productivity_level = number.within_bounds(productivity_level, 0, settings.energy_productivity_limit:get())
    speed_level = number.within_bounds(speed_level, 0, settings.energy_speed_limit:get())
    return tostring("e" .. efficiency_level .. "p" .. productivity_level .. "s" .. speed_level)
end

---@param construction_area_level integer
---@param logistic_area_level integer
---@param robot_storage_level integer
---@param material_storage_level integer
---@return string
function get_storage_suffix(construction_area_level, logistic_area_level, robot_storage_level, material_storage_level)
    construction_area_level = number.within_bounds(construction_area_level, 0, settings.construction_area_limit:get())
    logistic_area_level = number.within_bounds(logistic_area_level, 0, settings.logistic_area_limit:get())
    robot_storage_level = number.within_bounds(robot_storage_level, 0, settings.robot_storage_limit:get())
    material_storage_level = number.within_bounds(material_storage_level, 0, settings.material_storage_limit:get())
    return tostring(
        "c"
            .. construction_area_level
            .. "l"
            .. logistic_area_level
            .. "r"
            .. robot_storage_level
            .. "m"
            .. material_storage_level
    )
end

return {
    get_energy_suffix = get_energy_suffix,
    get_storage_suffix = get_storage_suffix,
}