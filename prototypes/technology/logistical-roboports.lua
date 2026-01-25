require("__heroic-library__.utilities")
require("__heroic-library__.table")
local Tech = require("__heroic-library__.technology")
require("settings")


local function get_research_name(upgrade_name, level)
  return upgrade_name .. utilities.get_level_suffix(level)
end

---@return table<TechnologyID>
local function get_SA_prerequisites(upgrade_name, level)
  ---@type table<TechnologyID>
  local prerequisites = {}

  if upgrade_name == "roboport-construction-area" then
    table.insert(prerequisites, "metallurgic-science-pack")
  elseif upgrade_name == "roboport-logistic-area" then
    table.insert(prerequisites, "electromagnetic-science-pack")
  elseif upgrade_name == "roboport-robot-storage" then
    table.insert(prerequisites, "agricultural-science-pack")
  elseif upgrade_name == "roboport-material-storage" then
    table.insert(prerequisites, "agricultural-science-pack")
  end

  if level >= 2 then
    table.insert(prerequisites, "cryogenic-science-pack")
  end

  if level >= 3 then
    table.insert(prerequisites, "promethium-science-pack")
  end
  return prerequisites
end

---@return table<TechnologyID>
local function get_research_prerequisites(upgrade_name, level)
  ---@type table<TechnologyID>
  local prerequisites = {}

  if level == 1 then
    prerequisites = {
      "logistic-robotics"
    }
  else
    prerequisites = {
      get_research_name(upgrade_name, level-1)
    }
  end
  if mods["space-age"] then
    table.extend(prerequisites, get_SA_prerequisites(upgrade_name, level))
  end
  return prerequisites
end

local function get_effect_description(upgrade_name)
  -- TODO: Use proper localization
  return "Upgrade the " .. upgrade_name .. " of a logistical roboport"
end

---@param upgrade_type data.TechnologyPrototype
---@param level number
---@param ingredients data.IngredientPrototype
local function add_SA_ingredients(upgrade_type, level, ingredients)
  if mods["space-age"] then
    if upgrade_type == "roboport-construction-area" then
      table.insert(ingredients, {"metallurgic-science-pack", 1})
    elseif upgrade_type == "roboport-logistic-area" then
      table.insert(ingredients, {"electromagnetic-science-pack", 1})
    elseif upgrade_type == "roboport-robot-storage" then
      table.insert(ingredients, {"agricultural-science-pack", 1})
    elseif upgrade_type == "roboport-material-storage" then
      table.insert(ingredients, {"agricultural-science-pack", 1})
    end

    if level >= 2 then
      table.insert(ingredients, {"cryogenic-science-pack", 1})
    end

    if level >= 3 then
      table.insert(ingredients, {"promethium-science-pack", 1})
    end
  end
end

local function get_research_ingredients(upgrade_type, level)
  local researchPrerequisites = get_research_prerequisites(upgrade_type, level)
  local ingredients = Tech.combined_ingredients(
      researchPrerequisites,
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
      }
  )

  add_SA_ingredients(upgrade_type, level, ingredients)
  return table.unique_kv(ingredients)
end

local function get_research_limit(upgrade_type)
  local limit = 999999
  if upgrade_type == "roboport-robot-storage" then
    limit = robot_storage_limit:get()
  elseif upgrade_type == "roboport-material-storage" then
    limit = material_storage_limit:get()
  elseif upgrade_type == "roboport-construction-area" then
    limit = construction_area_limit:get()
  elseif upgrade_type == "roboport-logistic-area" then
    limit = logistic_area_limit:get()
  end
  return math.max(research_minimum:get(), math.min(limit, research_maximum:get()))
end

local function insert_unlock()
  table.insert(
    data.raw["technology"]["logistic-robotics"].effects,
    {type = "unlock-recipe", recipe = "logistical-roboport"}
  )
end

local function add_researches()
  local upgrade_names = {"roboport-construction-area", "roboport-logistic-area", "roboport-robot-storage", "roboport-material-storage"}

  for _, upgrade_type in pairs(upgrade_names) do
    limit = get_research_limit(upgrade_type)

    for i=1, limit do
      data:extend(
        {
          {
            type = "technology",
            name = get_research_name(upgrade_type, i),
            icon_size = 256,
            icon_mipmaps = 4,
            icons = {
              {
                icon = "__base__/graphics/technology/robotics.png",
                icon_size = 256, icon_mipmaps = 4
              }
            },
            upgrade = true,
            order = "c-k-f-a",
            prerequisites = get_research_prerequisites(upgrade_type, i),
            effects = {
              {
                type = "nothing",
                effect_description = get_effect_description(upgrade_type),
              }
            },
            unit = {
              count_formula = research_upgrade_cost:get() .. "*(L)",
              time = research_upgrade_time:get(),
              ingredients = get_research_ingredients(upgrade_type, i)
            },
          }
        }
      )
    end
  end
end

insert_unlock()
add_researches()
