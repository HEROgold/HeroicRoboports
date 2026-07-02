require("__heroic-library__.utilities")
require("__heroic-library__.table")
local Tech = require("__heroic-library__.technology")
local settings = require("settings")
local codec = require("name_codec")
local Limits = require("limits")
local prng = require("helpers.prng")

-- Map each logistical technology name to its Limits.logistical axis key.
local tech_to_key = {}
for _, axis in ipairs(codec.LOGISTICAL_AXES) do
    tech_to_key[axis.tech] = axis.key
end

-- Space Age planet pack anchored to each logistical axis (tier 1 gate under Space Age).
local axis_science_pack = {
    ["roboport-construction-area"] = "metallurgic-science-pack",
    ["roboport-logistic-area"] = "electromagnetic-science-pack",
    ["roboport-robot-storage"] = "agricultural-science-pack",
    ["roboport-material-storage"] = "agricultural-science-pack",
}

-- Base/SA science packs the ladder places explicitly; everything else counts as "other-mod".
local KNOWN_PACKS = {
    ["automation-science-pack"] = true,
    ["logistic-science-pack"] = true,
    ["military-science-pack"] = true,
    ["chemical-science-pack"] = true,
    ["production-science-pack"] = true,
    ["utility-science-pack"] = true,
    ["space-science-pack"] = true,
    ["metallurgic-science-pack"] = true,
    ["electromagnetic-science-pack"] = true,
    ["agricultural-science-pack"] = true,
    ["cryogenic-science-pack"] = true,
    ["promethium-science-pack"] = true,
}

-- Science packs added by other mods, in canonical (sorted) order so the shuffle is deterministic.
local function other_mod_science_packs()
    local pool = {}
    for name, tool in pairs(data.raw["tool"] or {}) do
        if not KNOWN_PACKS[name] and (tool.subgroup == "science-pack" or string.find(name, "%-science%-pack$")) then
            pool[#pool + 1] = name
        end
    end
    table.sort(pool)
    return pool
end

-- Precompute, per axis, a deterministic shuffle of the other-mod pool seeded by a startup
-- setting, so every multiplayer client generates the same tech tree. Taking the first N of a
-- fixed shuffle gives a stable, cumulative selection as tiers climb.
local axis_extra_packs = {}
do
    local pool = other_mod_science_packs()
    local seed = settings.research_tier_seed:get()
    for i, axis in ipairs(codec.LOGISTICAL_AXES) do
        axis_extra_packs[axis.tech] = prng.shuffled(pool, seed * 1000003 + i)
    end
end

local function get_research_name(upgrade_name, level)
    return upgrade_name .. utilities.get_level_suffix(level)
end

--- The science packs a tier requires beyond the always-present automation/logistic packs,
--- cumulative. Logistical upgrades are a deliberately late-game progression:
---   With Space Age:    T1 planet pack, T2 +cryogenic, T3+ +promethium, T4+ +other-mod packs.
---   Without Space Age: T1 utility,     T2 +space,     T3+ +other-mod packs.
---@param upgrade_name string
---@param level integer
---@return string[]
local function science_ladder(upgrade_name, level)
    local packs = {}
    local extra_start
    if mods["space-age"] then
        if level >= 1 then
            packs[#packs + 1] = axis_science_pack[upgrade_name]
        end
        if level >= 2 then
            packs[#packs + 1] = "cryogenic-science-pack"
        end
        if level >= 3 then
            packs[#packs + 1] = "promethium-science-pack"
        end
        extra_start = 4
    else
        if level >= 1 then
            packs[#packs + 1] = "utility-science-pack"
        end
        if level >= 2 then
            packs[#packs + 1] = "space-science-pack"
        end
        extra_start = 3
    end

    -- Tiers past the last named milestone additionally pull other-mod packs (one more per tier).
    if level >= extra_start then
        local shuffled = axis_extra_packs[upgrade_name] or {}
        local count = level - extra_start + 1
        for i = 1, math.min(count, #shuffled) do
            packs[#packs + 1] = shuffled[i]
        end
    end

    return packs
end

---@return table<TechnologyID>
local function get_research_prerequisites(upgrade_name, level)
    ---@type table<TechnologyID>
    local prerequisites = {}
    if level == 1 then
        prerequisites[#prerequisites + 1] = "logistic-robotics"
    else
        prerequisites[#prerequisites + 1] = get_research_name(upgrade_name, level - 1)
    end

    -- A pack can only be a prerequisite if a same-named technology exists to unlock it.
    local techs = data.raw["technology"] or {}
    for _, pack in ipairs(science_ladder(upgrade_name, level)) do
        if techs[pack] then
            prerequisites[#prerequisites + 1] = pack
        end
    end
    return prerequisites
end

local function get_research_ingredients(upgrade_type, level)
    local ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
    }
    -- Require every gating pack that exists (known packs always have a same-named tech;
    -- other-mod packs come from the tool pool). This keeps ingredients in sync with the gates.
    local techs = data.raw["technology"] or {}
    local tools = data.raw["tool"] or {}
    for _, pack in ipairs(science_ladder(upgrade_type, level)) do
        if techs[pack] or tools[pack] then
            ingredients[#ingredients + 1] = { pack, 1 }
        end
    end
    return table.unique_kv(ingredients)
end

local function get_research_limit(upgrade_type)
    -- Limits.logistical already applies the research_minimum/maximum clamps per axis.
    return Limits.logistical[tech_to_key[upgrade_type]]
end

-- count = cost * (1 + level * multiplier); multiplier is a startup setting (default 2).
local function get_count_formula()
    return settings.research_upgrade_cost:get() .. "*(1 + L*" .. settings.research_cost_multiplier:get() .. ")"
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
                    prerequisites = get_research_prerequisites(upgrade_type, i),
                    effects = {
                        {
                            type = "nothing",
                            effect_description = { "heroic-roboports-effect.logistical", upgrade_type },
                        },
                    },
                    unit = {
                        count_formula = get_count_formula(),
                        time = settings.research_upgrade_time:get(),
                        ingredients = get_research_ingredients(upgrade_type, i),
                    },
                },
            })
        end
    end
end

insert_unlock()
add_researches()
