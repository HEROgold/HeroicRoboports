require("__heroic-library__.utilities")
require("__heroic-library__.table")
require("__heroic-library__.sprites")
local Tech = require("__heroic-library__.technology")
local settings = require("settings")
local Limits = require("limits")

local module_names = {
    "efficiency",
    "productivity",
    "speed",
}

local function get_research_name(module_type, level)
    return "roboport-" .. module_type .. utilities.get_level_suffix(level)
end

local get_effect_description = function(module_type)
    return "Upgrade the " .. module_type .. " of a energy roboport"
end

-- the module technology is the 1st prerequisite
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
    return sprite_add_icon(
        "__base__/graphics/technology/robotics.png",
        "__base__/graphics/icons/" .. module_type .. "-module-3.png"
    )
end

local function get_module_research_ingredients(module_type, level)
    local researchPrerequisites = get_research_prerequisites(module_type, level)
    return Tech.combined_ingredients(researchPrerequisites, {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
        { "utility-science-pack", 1 },
    })
end

local function insert_unlock()
    table.insert(
        data.raw["technology"]["construction-robotics"].effects,
        { type = "unlock-recipe", recipe = "energy-roboport" }
    )
end

local function add_module_upgrade_research()
    for _, module_type in pairs(module_names) do
        local limit = math.max(Limits[module_type], settings.research_minimum:get())

        for i = 1, limit do
            data:extend({
                {
                    type = "technology",
                    name = get_research_name(module_type, i),
                    icon_size = 256,
                    icon_mipmaps = 4,
                    icons = get_tech_sprite(module_type, i),
                    upgrade = true,
                    order = "c-k-f-a",
                    prerequisites = get_research_prerequisites(module_type, i),
                    effects = {
                        {
                            type = "nothing",
                            effect_description = get_effect_description(module_type),
                        },
                    },
                    unit = {
                        count_formula = settings.research_upgrade_cost:get() .. "*(L)",
                        time = settings.research_upgrade_time:get(),
                        ingredients = get_module_research_ingredients(module_type, i),
                    },
                },
            })
        end
    end
end

insert_unlock()
add_module_upgrade_research()
