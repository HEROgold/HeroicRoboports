require("__heroic-library__.utilities")
require("__heroic-library__.table")
local Sprites = require("__heroic-library__.sprites")
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
    return Tech.leveled_name(upgrade_name, level)
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

--- Prerequisites of the technology that starts at `level`. `previous` is the technology holding
--- the level before it (nil at level 1, where logistic-robotics is the anchor).
---@param upgrade_name string
---@param level integer
---@param previous string|nil
---@return table<TechnologyID>
local function get_research_prerequisites(upgrade_name, level, previous)
    ---@type table<TechnologyID>
    local prerequisites = { previous or "logistic-robotics" }

    -- A pack can only be a prerequisite if a same-named technology exists to unlock it.
    local techs = data.raw["technology"] or {}
    for _, pack in ipairs(science_ladder(upgrade_name, level)) do
        if techs[pack] then
            prerequisites[#prerequisites + 1] = pack
        end
    end
    return prerequisites
end

---@param upgrade_name string
---@param level integer
---@param previous string|nil
local function get_research_ingredients(upgrade_name, level, previous)
    -- Inherit the base packs from the prerequisite chain (the previous technology, or
    -- logistic-robotics at level 1), falling back to automation/logistic if nothing contributes.
    local prerequisites = get_research_prerequisites(upgrade_name, level, previous)
    local ingredients = Tech.combined_ingredients(prerequisites, {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
    })

    -- On top of the inherited base, require every gating pack this level introduces (known packs
    -- always have a same-named tech; other-mod packs come from the tool pool).
    local techs = data.raw["technology"] or {}
    local tools = data.raw["tool"] or {}
    for _, pack in ipairs(science_ladder(upgrade_name, level)) do
        if techs[pack] or tools[pack] then
            ingredients[#ingredients + 1] = { pack, 1 }
        end
    end
    return table.unique_kv(ingredients)
end

--- Split levels 1..limit into runs that share the same science packs. Each run becomes one
--- technology: a single level, or a multi-level technology (max_level) when the run is longer.
--- The ladder is cumulative, so two levels need the same packs exactly when their counts match.
---@param upgrade_name string
---@param limit integer
---@return { first: integer, last: integer }[]
local function level_runs(upgrade_name, limit)
    local runs = {}
    for level = 1, limit do
        local run = runs[#runs]
        if run and #science_ladder(upgrade_name, level) == #science_ladder(upgrade_name, run.first) then
            run.last = level
        else
            runs[#runs + 1] = { first = level, last = level }
        end
    end
    return runs
end

local function get_research_limit(upgrade_type)
    -- Limits.logistical already applies the research_minimum/maximum clamps per axis.
    return Limits.logistical[tech_to_key[upgrade_type]]
end

-- count = cost * (1 + level * multiplier); multiplier is a startup setting (default 2).
-- In a multi-level technology L is the level being researched, so the curve matches the old
-- one-technology-per-level ladder.
local function get_count_formula()
    return settings.research_upgrade_cost:get() .. "*(1 + L*" .. settings.research_cost_multiplier:get() .. ")"
end

-- A distinct vanilla overlay per logistical upgrade axis, so the four ladders are told apart in the
-- tech tree (mirrors how the energy ladder overlays module icons on the robotics tech sprite).
local axis_overlay = {
    ["roboport-construction-area"] = "__base__/graphics/icons/construction-robot.png",
    ["roboport-logistic-area"] = "__base__/graphics/icons/logistic-robot.png",
    ["roboport-robot-storage"] = "__base__/graphics/icons/signal/signal-stack-size.png",
    ["roboport-material-storage"] = "__base__/graphics/icons/repair-pack.png",
}

Tech.unlock_recipe("logistic-robotics", "logistical-roboport")

for _, axis in ipairs(codec.LOGISTICAL_AXES) do
    local upgrade_name = axis.tech
    local icons = Sprites.add_icon("__base__/graphics/technology/robotics.png", axis_overlay[upgrade_name])
    local used = {}
    local previous = nil
    for _, run in ipairs(level_runs(upgrade_name, get_research_limit(upgrade_name))) do
        local multi_level = run.last > run.first
        local name = multi_level and codec.multi_level_tech(upgrade_name, run.first)
            or get_research_name(upgrade_name, run.first)
        data:extend({
            {
                type = "technology",
                name = name,
                localised_name = { "technology-name." .. upgrade_name },
                localised_description = { "technology-description." .. upgrade_name },
                icon_size = 256,
                icon_mipmaps = 4,
                icons = icons,
                upgrade = true,
                order = "c-k-f-a",
                max_level = multi_level and run.last or nil,
                prerequisites = get_research_prerequisites(upgrade_name, run.first, previous),
                effects = {
                    {
                        type = "nothing",
                        effect_description = { "heroic-roboports-effect.logistical", upgrade_name },
                    },
                },
                unit = {
                    count_formula = get_count_formula(),
                    time = settings.research_upgrade_time:get(),
                    ingredients = get_research_ingredients(upgrade_name, run.first, previous),
                },
            },
        })
        used[name] = true
        previous = name
    end

    -- Before 2.8.0 every level was its own technology. Keep the per-level names no longer in use
    -- as hidden, disabled stubs so Factorio keeps their researched state in old saves; the 2.8.0
    -- migration reads them to restore each force's level. helpers/levels.lua skips hidden
    -- technologies. Multi-level technologies use a separate base name (codec.multi_level_tech),
    -- so these stubs never overlap their level range.
    for level = 2, settings.MAX_RESEARCH_LEVEL do
        local name = get_research_name(upgrade_name, level)
        if not used[name] then
            data:extend({
                {
                    type = "technology",
                    name = name,
                    icon_size = 256,
                    icon_mipmaps = 4,
                    icons = icons,
                    hidden = true,
                    enabled = false,
                    visible_when_disabled = false,
                    effects = {},
                    unit = {
                        count = 1,
                        time = 1,
                        ingredients = { { "automation-science-pack", 1 } },
                    },
                },
            })
        end
    end
end
