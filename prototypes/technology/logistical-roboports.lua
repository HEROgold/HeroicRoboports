require("__heroic-library__.utilities")
require("__heroic-library__.table")
local Tech = require("__heroic-library__.technology")
local settings = require("settings")
local codec = require("name_codec")
local Limits = require("limits")

-- Map each logistical technology name to its Limits.logistical axis key.
local tech_to_key = {}
for _, axis in ipairs(codec.LOGISTICAL_AXES) do
    tech_to_key[axis.tech] = axis.key
end

-- Space Age planet pack anchored to each logistical axis.
local axis_science_pack = {
    ["roboport-construction-area"] = "metallurgic-science-pack",
    ["roboport-logistic-area"] = "electromagnetic-science-pack",
    ["roboport-robot-storage"] = "agricultural-science-pack",
    ["roboport-material-storage"] = "agricultural-science-pack",
}

local function get_research_name(upgrade_name, level)
    return upgrade_name .. utilities.get_level_suffix(level)
end

--- Science-anchored ladder: returns the science packs a given tier requires beyond the base
--- automation/logistic packs. Thresholds are relative to the axis' tier limit, so the ladder
--- spreads across however many tiers exist and top tiers become an endgame investment. Each
--- pack name doubles as both the unlocking technology (prerequisite) and the tool (ingredient).
---@param upgrade_name string
---@param level integer
---@param limit integer
---@return string[]
local function science_ladder(upgrade_name, level, limit)
    local packs = {}
    -- Reaches `threshold` fraction of the limit (never before tier 2).
    local function at(threshold)
        return level >= math.max(2, math.ceil(threshold * limit))
    end

    -- Base-game ladder.
    if at(0.25) then
        packs[#packs + 1] = "chemical-science-pack"
    end
    if at(0.45) then
        packs[#packs + 1] = "production-science-pack"
    end
    if at(0.65) then
        packs[#packs + 1] = "utility-science-pack"
    end

    -- Space Age ladder.
    if mods["space-age"] then
        if at(0.50) and axis_science_pack[upgrade_name] then
            packs[#packs + 1] = axis_science_pack[upgrade_name]
        end
        if at(0.75) then
            packs[#packs + 1] = "space-science-pack"
        end
        if at(0.90) then
            packs[#packs + 1] = "cryogenic-science-pack"
        end
        if level >= limit then
            packs[#packs + 1] = "promethium-science-pack"
        end
    end

    return packs
end

---@return table<TechnologyID>
local function get_research_prerequisites(upgrade_name, level, limit)
    ---@type table<TechnologyID>
    local prerequisites = {}
    if level == 1 then
        prerequisites[#prerequisites + 1] = "logistic-robotics"
    else
        prerequisites[#prerequisites + 1] = get_research_name(upgrade_name, level - 1)
    end

    -- Anchor higher tiers behind the science-pack technologies (when they exist).
    local techs = data.raw["technology"] or {}
    for _, pack in ipairs(science_ladder(upgrade_name, level, limit)) do
        if techs[pack] then
            prerequisites[#prerequisites + 1] = pack
        end
    end
    return prerequisites
end

local function get_research_ingredients(upgrade_type, level, limit)
    -- Base ingredients: cheap early tiers only need the starter packs.
    local ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
    }
    -- Progressively require later packs as the tier climbs (if the science pack exists).
    local tools = data.raw["tool"] or {}
    for _, pack in ipairs(science_ladder(upgrade_type, level, limit)) do
        if tools[pack] then
            ingredients[#ingredients + 1] = { pack, 1 }
        end
    end
    return table.unique_kv(ingredients)
end

local function get_research_limit(upgrade_type)
    -- Limits.logistical already applies the research_minimum/maximum clamps per axis.
    return Limits.logistical[tech_to_key[upgrade_type]]
end

-- count = cost * (L ^ exponent); exponent is a startup setting (default 1.5).
local function get_count_formula()
    return settings.research_upgrade_cost:get() .. "*(L^" .. settings.research_cost_exponent:get() .. ")"
end

local function insert_unlock()
    table.insert(
        data.raw["technology"]["logistic-robotics"].effects,
        { type = "unlock-recipe", recipe = "logistical-roboport" }
    )
end

local function add_researches()
    local upgrade_names = {
        "roboport-construction-area",
        "roboport-logistic-area",
        "roboport-robot-storage",
        "roboport-material-storage",
    }

    for _, upgrade_type in pairs(upgrade_names) do
        local limit = get_research_limit(upgrade_type)

        for i = 1, limit do
            data:extend({
                {
                    type = "technology",
                    name = get_research_name(upgrade_type, i),
                    icon_size = 256,
                    icon_mipmaps = 4,
                    icons = {
                        {
                            icon = "__base__/graphics/technology/robotics.png",
                            icon_size = 256,
                            icon_mipmaps = 4,
                        },
                    },
                    upgrade = true,
                    order = "c-k-f-a",
                    prerequisites = get_research_prerequisites(upgrade_type, i, limit),
                    effects = {
                        {
                            type = "nothing",
                            effect_description = { "heroic-roboports-effect.logistical", upgrade_type },
                        },
                    },
                    unit = {
                        count_formula = get_count_formula(),
                        time = settings.research_upgrade_time:get(),
                        ingredients = get_research_ingredients(upgrade_type, i, limit),
                    },
                },
            })
        end
    end
end

insert_unlock()
add_researches()
