
---@param force LuaForce
---@return table<number, number, number, number>
function get_logistical_levels(force)
    levels = {0, 0, 0, 0}
    for i, name in ipairs{
        RoboportConstructionArea,
        RoboportLogisticArea,
        RoboportRobotStorage,
        RoboportMaterialStorage
    } do
        for level = 1, research_minimum, 1 do
            local tech_level = get_tech_level(force, name, level)
            if levels[i] < tech_level then
                levels[i] = tech_level
            end
        end
    end
    return levels
end

---@param force LuaForce
---@return table<number, number, number>
function get_energy_levels(force)
    local levels = {0, 0, 0}
    for i, name in ipairs{
        RoboportEfficiency,
        RoboportProductivity,
        RoboportSpeed
    } do
        for level = 1, research_minimum, 1 do
            local tech_level = get_tech_level(force, name, level)
            if levels[i] < tech_level then
                levels[i] = tech_level
            end
        end
    end
    return levels
end

---@param to_check string
---@return table<number, number, number>
function energy_levels_from_name(to_check)
    local eff = string.sub(to_check, -5, -5)
    local prod = string.sub(to_check, -3, -3)
    local speed = string.sub(to_check, -1, -1)
    return {tonumber(eff), tonumber(prod), tonumber(speed)}
end

---@param to_check string
---@return table<number, number, number, number>
function storage_levels_from_name(to_check)
    local c = string.sub(to_check, -7, -7)
    local l = string.sub(to_check, -5, -5)
    local r = string.sub(to_check, -3, -3)
    local m = string.sub(to_check, -1, -1)
    return {tonumber(c), tonumber(l), tonumber(r), tonumber(m)}
end
