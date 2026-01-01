require("vars.strings")
require("__heroic-library__.technology")

function uninstall()
    for _, surface in pairs(game.surfaces) do
        for _, roboport in pairs(surface.find_entities_filtered { type = Roboport }) do
            if not roboport.valid then
                goto continue
            end

            -- TODO: include ghost roboports.

            if (
                    roboport.name == Roboport
                    or not utilities.string_starts_with(roboport.name, RoboportEnergy)
                    and not utilities.string_starts_with(roboport.name, RoboportLogistical)
                ) then
                goto continue
            end

            local old_energy = roboport.energy
            local created_rport = surface.create_entity {
                name = Roboport,
                position = roboport.position,
                force = roboport.force,
                fast_replace = true,
                spill = false,
                create_build_effect_smoke = false,
                raise_built = false
            }
            created_rport.energy = old_energy
            roboport.destroy()
            ::continue::
        end
    end
end

function reset()
    game.print("Resetting mod")
    -- Reset related technologies
    storage.EfficiencyResearchLevel = 0
    storage.ProductivityResearchLevel = 0
    storage.SpeedResearchLevel = 0
    storage.ConstructionAreaResearchLevel = 0
    storage.LogisticAreaResearchLevel = 0
    storage.RobotStorageResearchLevel = 0
    storage.MaterialStorageResearchLevel = 0
    -- Reset all research levels
    for _, force in pairs(game.forces) do
        recursive_unresearch_technology(force.technologies[RoboportEfficiency])
        recursive_unresearch_technology(force.technologies[RoboportProductivity])
        recursive_unresearch_technology(force.technologies[RoboportSpeed])
        recursive_unresearch_technology(force.technologies[RoboportConstructionArea])
        recursive_unresearch_technology(force.technologies[RoboportLogisticArea])
        recursive_unresearch_technology(force.technologies[RoboportRobotStorage])
        recursive_unresearch_technology(force.technologies[RoboportMaterialStorage])
    end
    -- Reset all related roboports
    for _, surface in pairs(game.surfaces) do
        for _, roboport in pairs(surface.find_entities_filtered { type = Roboport }) do
            if not roboport.valid then
                goto continue
            end

            if utilities.string_starts_with(roboport.name, RoboportEnergy) then
                local old_energy = roboport.energy
                local created_rport = surface.create_entity {
                    name = RoboportEnergy,
                    position = roboport.position,
                    force = roboport.force,
                    fast_replace = true,
                    spill = false,
                    create_build_effect_smoke = false,
                    raise_built = false
                }
                created_rport.energy = old_energy
                roboport.destroy()
            elseif utilities.string_starts_with(roboport.name, RoboportLogistical) then
                local old_energy = roboport.energy
                local created_rport = surface.create_entity {
                    name = RoboportLogistical,
                    position = roboport.position,
                    force = roboport.force,
                    fast_replace = true,
                    spill = false,
                    create_build_effect_smoke = false,
                    raise_built = false
                }
                created_rport.energy = old_energy
                roboport.destroy()
            end
            ::continue::
        end
    end
    game.print("Reset complete")
end

commands.add_command(
    "hr-show",
    "Shows the current research levels",
    function(command)
        local force = game.forces[game.players[command.player_index].force.name]
        local energy_levels = get_energy_levels(force)
        local logistical_levels = get_logistical_levels(force)

        game.print("-- Energy --")
        game.print("Efficiency: " .. energy_levels[1] .. "/" .. research_minimum)
        game.print("Productivity: " .. energy_levels[2] .. "/" .. research_minimum)
        game.print("Speed: " .. energy_levels[3] .. "/" .. research_minimum)
        game.print("-- Storage --")
        game.print("Construction Area: " .. logistical_levels[1] .. "/" .. research_minimum)
        game.print("Logistics Area: " .. logistical_levels[2] .. "/" .. research_minimum)
        game.print("Robot Storage: " .. logistical_levels[3] .. "/" .. research_minimum)
        game.print("Material Storage: " .. logistical_levels[4] .. "/" .. research_minimum)
    end
)

commands.add_command(
    "hr-uninstall",
    "Forces roboports to be vanilla, usefull for uninstalling this mod",
    function()
        uninstall()
    end
)
commands.add_command(
    "hr-reset",
    "Resets all roboports to 0, resets all research levels and technologies.",
    function()
        reset()
    end
)

commands.add_command(
    "hr-test",
    "test",
    function()
        for _, force in pairs(game.forces) do
            game.print("Force: " .. force.name)
            for _, tech in pairs(force.technologies) do
                if utilities.string_starts_with(tech.name, Roboport) then
                    game.print("Tech: " .. tech.name)
                end
            end
        end
    end
)

commands.add_command(
    "hr-clean",
    "Resets all internally tracked ports",
    function()
        storage.roboports_to_update = {}
        storage.ghosts_to_update = {}
    end
)
