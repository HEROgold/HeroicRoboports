local tech = require("__heroic-library__.technology")
local levels = require("helpers.levels")
local roboports = require("script.roboports")
local codec = require("name_codec")

commands.add_command("hr-show", "Shows the current research levels", function(command)
    local force = game.players[command.player_index].force
    ---@cast force LuaForce
    local energy_levels = levels.energy(force)
    local logistical_levels = levels.logistical(force)

    game.print("-- Energy --")
    for _, axis in ipairs(codec.ENERGY_AXES) do
        game.print(axis.key .. ": " .. energy_levels[axis.key])
    end
    game.print("-- Storage --")
    for _, axis in ipairs(codec.LOGISTICAL_AXES) do
        game.print(axis.key .. ": " .. logistical_levels[axis.key])
    end
end)

commands.add_command("hr-uninstall", "Forces roboports to be vanilla, useful for uninstalling this mod", function()
    roboports.uninstall()
    game.print("Heroic Roboports reverted to vanilla. Upgrades suppressed for 10 seconds.")
end)

commands.add_command("hr-reset", "Resets all roboports to level 0 and unresearches all mod technologies.", function()
    game.print("Resetting mod")
    for _, force in pairs(game.forces) do
        for _, axis in ipairs(codec.ENERGY_AXES) do
            local root = force.technologies[axis.tech]
            if root then
                tech.recursive_unresearch_technology(root)
            end
        end
        for _, axis in ipairs(codec.LOGISTICAL_AXES) do
            local root = force.technologies[axis.tech]
            if root then
                tech.recursive_unresearch_technology(root)
            end
        end
    end
    roboports.reset_entities()
    game.print("Reset complete")
end)

commands.add_command("hr-test", "Lists all roboport-related technologies per force.", function()
    for _, force in pairs(game.forces) do
        game.print("Force: " .. force.name)
        for _, technology in pairs(force.technologies) do
            if string.starts_with(technology.name, "roboport") then
                game.print("Tech: " .. technology.name)
            end
        end
    end
end)

commands.add_command("hr-clean", "Resets all internally tracked ports", function()
    roboports.clear_tracking()
end)
