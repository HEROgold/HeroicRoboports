---@class BaseRoboport: data.RoboportPrototype
local BaseRoboport = {}
BaseRoboport.__index = BaseRoboport

---@return self
function BaseRoboport.new()
    self = setmetatable(table.deepcopy(data.raw["roboport"]["roboport"]), BaseRoboport)
    self.minable.result = self.name
    return self
end

---@abstract
---@return string
function BaseRoboport:get_suffix()
    error("get_suffix() not implemented for " .. tostring(self))
end

function BaseRoboport:items()
    ---@type data.ItemPrototype[]
    return {
        {
            type = "item",
            name = self.name,
            icon = self.icon,
            icon_size = self.icon_size,
            subgroup = self.subgroup,
            order = self.order,
            place_result = self.name,
            stack_size = data.raw["item"]["roboport"].stack_size,
        },
    }
end

function BaseRoboport:recipes()
    ---@type data.RecipePrototype[]
    return {
        {
            type = "recipe",
            name = self.name,
            enabled = false,
            ingredients = {
                { type = "item", name = "roboport", amount = 1 },
                { type = "item", name = "steel-plate", amount = 100 },
            },
            results = { { type = "item", name = self.name, amount = 1 } },
            category = "crafting",
            unlock_results = true,
        },
    }
end

function BaseRoboport:get_localised_name()
    return { self.name .. "-mk-", self:get_suffix() }
end

return BaseRoboport
