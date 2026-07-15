require("__heroic-library__.utilities")
require("__heroic-library__.table")
local Sprites = require("__heroic-library__.sprites")
local Tech = require("__heroic-library__.technology")
local settings = require("settings")
local Limits = require("limits")

local module_names = {
    "efficiency",
    "productivity",
    "speed",
}

local function get_research_name(module_type, level)
    return Tech.leveled_name("roboport-" .. module_type, level)
end

-- the module technology is the 1st prerequisite
--- Get the prerequisites for a module research, including the module technology itself.
---@return table<TechnologyID>
local function get_research_prerequisites(module_type, level)
    local prerequisites = nil
    local module = module_type .. "-module" .. utilities.get_level_suffix(level)

    if level == 1 then
        prerequisites = {
            module,
            "construction-robotics",
        }
    else
        prerequisites = {
            module,
            get_research_name(module_type, level - 1),
        }
    end
    return prerequisites
end

local get_tech_sprite = function(module_type, level)
    return Sprites.add_icon(
        "__base__/graphics/technology/robotics.png",
        "__base__/graphics/icons/" .. module_type .. "-module-3.png"
    )
end

--- Returns a table of all the ingredients required to research a technology, including all prerequisites.
--- If the technology has no prerequisites, it will return the default ingredients.
---@param module_type string
---@param level number
local function get_module_research_ingredients(module_type, level)
    local researchPrerequisites = get_research_prerequisites(module_type, level)
    return Tech.combined_ingredients(researchPrerequisites, {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
        { "utility-science-pack", 1 },
    })
end

Tech.unlock_recipe("construction-robotics", "energy-roboport")

Tech.add_upgrade_ladder({
    axes = module_names,
    -- Limits.energy already applies the research_minimum/maximum + per-axis clamps.
    get_limit = function(module_type) return Limits.energy[module_type] end,
    get_name = get_research_name,
    get_icons = get_tech_sprite,
    get_prerequisites = get_research_prerequisites,
    get_effects = function(module_type)
        return {
            {
                type = "nothing",
                effect_description = { "heroic-roboports-effect.energy", module_type },
            },
        }
    end,
    get_count_formula = function() return settings.research_upgrade_cost:get() .. "*(L)" end,
    get_time = function() return settings.research_upgrade_time:get() end,
    get_ingredients = get_module_research_ingredients,
})
