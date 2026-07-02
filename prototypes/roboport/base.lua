---@class BaseRoboport: data.RoboportPrototype
---@field _name string Internal name for the roboport.
local BaseRoboport = {}
BaseRoboport.__index = BaseRoboport

---@return self
function BaseRoboport.new()
    return setmetatable(table.deepcopy(data.raw["roboport"]["roboport"]), BaseRoboport)
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
            categories = { "crafting" },
            unlock_results = true,
        },
    }
end

function BaseRoboport:get_name()
    return self._name .. "-mk-" .. self:get_suffix()
end

---@return string[]
function BaseRoboport:get_suffix_segments()
    local suffix = self:get_suffix()
    local segments = {}
    for segment in string.gmatch(suffix, "[a-z]%d+") do
        segments[#segments + 1] = segment
    end
    if #segments == 0 then
        segments[1] = suffix
    end
    return segments
end

function BaseRoboport:get_localised_name()
    local segments = self:get_suffix_segments()
    return { "entity-name." .. self._name .. "-mk", table.unpack(segments) }
end

return BaseRoboport
