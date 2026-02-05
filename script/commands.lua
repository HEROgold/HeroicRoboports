
local tech = require("__heroic-library__.technology")
local levels = require("helpers.levels")

function uninstall()
    for _, surface in pairs(game.surfaces) do
        entities = surface.find_entities_filtered { type = "roboport" }
        roboports = table.filtered(entities, function(v)
            return (
                string.starts_with(roboport.name, "energy-roboport")
                or string.starts_with(roboport.name, "logistical-roboport")
                -- TODO: Also include ghosts properly.
            )
        end)
        for roboport in roboports do
            if not roboport.valid then
                goto continue
            end

            local old_energy = roboport.energy
            local created_rport = surface.create_entity {
                name = "roboport",
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
        tech.recursive_unresearch_technology(force.technologies["roboport-efficiency"])
        tech.recursive_unresearch_technology(force.technologies["roboport-productivity"])
        tech.recursive_unresearch_technology(force.technologies["roboport-speed"])
        tech.recursive_unresearch_technology(force.technologies["roboport-construction-area"])
        tech.recursive_unresearch_technology(force.technologies["roboport-logistic-area"])
        tech.recursive_unresearch_technology(force.technologies["roboport-robot-storage"])
        tech.recursive_unresearch_technology(force.technologies["roboport-material-storage"])
    end
    -- Reset all related roboports
    for _, surface in pairs(game.surfaces) do
        for _, roboport in pairs(surface.find_entities_filtered { type = "roboport" }) do
            if not roboport.valid then
                goto continue
            end

            if string.starts_with(roboport.name, "energy-roboport") then
                local old_energy = roboport.energy
                local created_rport = surface.create_entity {
                    name = "energy-roboport",
                    position = roboport.position,
                    force = roboport.force,
                    fast_replace = true,
                    spill = false,
                    create_build_effect_smoke = false,
                    raise_built = false
                }
                created_rport.energy = old_energy
                roboport.destroy()
            elseif string.starts_with(roboport.name, "logistical-roboport") then
                local old_energy = roboport.energy
                local created_rport = surface.create_entity {
                    name = "logistical-roboport",
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
        local energy_levels = levels.get_energy_levels(force)
        local logistical_levels = levels.get_logistical_levels(force)

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
    "Forces roboports to be vanilla, useful for uninstalling this mod",
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
                if string.starts_with(tech.name, "roboport") then
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
