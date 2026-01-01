require("__heroic-library__.utilities")
require("__heroic-library__.table")
require("__heroic-library__.technology")
require("__heroic-library__.string")
require("__heroic-library__.number")
require("vars.settings")
require("compatibility.technology")

local modules = data.raw["module"]

local module_names = {
  "efficiency",
  "productivity",
  "speed"
}


local function get_research_name(module_type, level)
  return "roboport-" .. module_type .. utilities.get_level_suffix(level)
end

local get_effect_description = function(module_type)
  return "Upgrade the " .. module_type .. " of a energy roboport"
end

---@return number, number, number 
local function highest_module_number_by_name()
  local efficiency = 0
  local productivity = 0
  local speed = 0

    for k, v in pairs(modules) do
      local ss = k.sub(k, -2, -1) 
      local moduleLevel = tonumber(ss) -- "productivity-module-2" becomes '-2' when converting from string.

      if moduleLevel == nil then -- level one modules don't seem to have a suffix. fix that here
        moduleLevel = 1
      end
      if moduleLevel < 0 then -- invert numbers to positive.
        moduleLevel = -moduleLevel
      end

      local maximum = math.max(moduleLevel, 1)

      if string.starts_with(k, "efficiency-module") then
        efficiency = number.within_bounds(moduleLevel, 0, maximum)
      end
      if string.starts_with(k, "productivity-module") then
        productivity = number.within_bounds(moduleLevel, 0, maximum)
      end
      if string.starts_with(k, "speed-module") then
        speed = number.within_bounds(moduleLevel, 0, maximum)
      end
    end
    return efficiency, productivity, speed
end

local function get_highest_module_number()
  local efficiency, productivity, speed = highest_module_number_by_name()
  efficiency, productivity, speed = apply_mod_compatibility(efficiency, productivity, speed)  
  return efficiency, productivity, speed
end



local efficiency, productivity, speed = get_highest_module_number()

-- Respect the setting a user has provided
local efficiency_limit = math.min(energy_efficiency_limit, efficiency)
local productivity_limit = math.min(energy_productivity_limit, productivity)
local speed_limit = math.min(energy_speed_limit, speed)

Limits = {}
Limits["efficiency"] = efficiency_limit
Limits["productivity"] = productivity_limit
Limits["speed"] = speed_limit

valid = (efficiency_limit == productivity_limit) and (productivity_limit == speed_limit)

if (not valid) then
  error("RoboportUpgrades: The amount of efficiency, productivity and speed modules do not match.")
end

local total_modules = efficiency -- modules usually are paired, so should be fine like this.

-- the module technology is the 1st prerequisite
---@return table<TechnologyID>
local function get_research_prerequisites(module_type, level)
  local prerequisites = nil
  local module = module_type .. "-module" .. utilities.get_level_suffix(level)

  if level == 1 then
    prerequisites = {
      module,
      "construction-robotics"
    }
  else
    prerequisites = {
      module,
      get_research_name(module_type, level-1)
    }
  end
  return prerequisites
end

local get_tech_sprite = function (module_type, level)
    return utilities.sprite_add_icon(
      "__base__/graphics/technology/robotics.png",
      "__base__/graphics/icons/"..module_type.."-module-3.png"
    )
end

local function get_module_research_ingredients(module_type, level)
  local researchPrerequisites = get_research_prerequisites(module_type, level)
  return combined_ingredients(
    researchPrerequisites,
    {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"utility-science-pack", 1},
  })
end

local function insert_unlock()
  table.insert(
    data.raw["technology"]["construction-robotics"].effects,
    {type = "unlock-recipe", recipe = RoboportEnergy}
  )
end

local function add_module_upgrade_research()
  for _, module_type in pairs(module_names) do
    local limit = math.max(Limits[module_type], research_minimum)

    for i=1, limit do
      data:extend(
        {
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
              }
            },
            unit = {
              count_formula = research_upgrade_cost .. "*(L)",
              time = research_upgrade_time,
              ingredients = get_module_research_ingredients(module_type, i)
            },
          }
        }
      )
    end
  end
end

insert_unlock()
add_module_upgrade_research()