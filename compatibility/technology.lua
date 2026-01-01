
-- the following mods can't be found using highest_module_number_by_name()
-- we set the limits manually
function apply_mod_compatibility(efficiency, productivity, speed)
    if mods["Module-Rebalance"] then
        efficiency, productivity, speed = 7, 7, 7
    end
    if mods["space-exploration"] then
        efficiency, productivity, speed = 9, 9, 9
    end
    -- if mods["secretas"] then
    --     efficiency, productivity, speed = 4, 4, 4
    -- end
    return efficiency, productivity, speed
end
