local Sprites = require("__heroic-library__.sprites")
local Energy = require("__heroic-library__.energy")

-- Input flow headroom over the full charging draw, so a roboport with every pad busy still refills.
local INPUT_FLOW_HEADROOM = 1.1

---@class BaseRoboport: data.RoboportPrototype
---@field _name string Internal name for the roboport.
local BaseRoboport = {}
BaseRoboport.__index = BaseRoboport

-- Cached deep copy of the vanilla roboport prototype. Deep-copying it per variant (thousands of
-- times, for the logistical 4-axis cross product) is what hangs the data stage, so we copy the
-- heavy prototype once and shallow-clone it per variant. The shared subtables (graphics, sounds,
-- energy_source, etc.) are only ever read after creation, and `data:extend` serializes each
-- prototype independently, so sharing them by reference is safe.
local template

-- Cache of layered icon tables keyed by overlay path. There are only two overlays (one per
-- variant type) but thousands of variants, so we build each layered table once and share it.
-- Icons are only read after creation and `data:extend` serializes each prototype independently,
-- so sharing them by reference is safe (same rationale as the shared template above).
local icons_cache = {}

---@param overlay data.FileName Small vanilla icon layered onto the roboport base icon.
---@return data.IconData[]
local function build_icons(overlay)
    if not icons_cache[overlay] then
        icons_cache[overlay] = Sprites.add_icon(
            "__base__/graphics/icons/roboport.png",
            overlay,
            { base_size = 64, base_mipmaps = 4, overlay_size = 64, overlay_mipmaps = 4, scale = 0.5, shift = { 8, 8 } }
        )
    end
    return icons_cache[overlay]
end

---@return self
function BaseRoboport.new()
    if not template then
        template = table.deepcopy(data.raw["roboport"]["roboport"])
    end
    local self = {}
    for key, value in pairs(template) do
        self[key] = value
    end
    -- `minable.result` is the only subtable mutated in place by subclasses, so give each variant
    -- its own copy; everything else the subclasses set is a top-level reassignment.
    self.minable = table.deepcopy(template.minable)
    -- Quality adds charging pads via the vanilla QualityPrototype::logistic_cell_charging_station_count_bonus.
    -- This is the only roboport property Factorio 2.1 lets scale with quality (docs/quality-scaling.md).
    self.charging_station_count_affected_by_quality = true
    return setmetatable(self, BaseRoboport)
end

--- Input flow that feeds every pad charging at once plus idle drain, with a little headroom, and
--- never below the vanilla roboport's. Without it a busy roboport drains to 0 and stops charging
--- until it refills to `recharge_minimum`. Call after `charging_energy`, `charging_offsets` and
--- `energy_usage` are final. Quality pads are not covered: input_flow_limit has no quality scaling.
---@return Energy
function BaseRoboport:charging_input_flow()
    local demand = Energy.new(self.charging_energy):with_scale(#self.charging_offsets)
    demand:add(Energy.new(self.energy_usage))
    demand = demand:with_scale(INPUT_FLOW_HEADROOM)
    local vanilla = Energy.new(template.energy_source.input_flow_limit)
    if vanilla:_to_joules() > demand:_to_joules() then
        return vanilla
    end
    return demand
end

---@abstract
---@return string
function BaseRoboport:get_suffix()
    error("get_suffix() not implemented for " .. tostring(self))
end

--- Layer a small distinguishing vanilla icon onto the shared roboport base icon, so the energy
--- and logistical variants can be told apart at a glance. Applied to both the entity (this table)
--- and the item it produces (see `items()`).
---@param overlay data.FileName Small vanilla icon, e.g. "__base__/graphics/icons/storage-chest.png".
function BaseRoboport:apply_icon_overlay(overlay)
    self.icons = build_icons(overlay)
end

function BaseRoboport:items()
    ---@type data.ItemPrototype
    local item = {
        type = "item",
        name = self.name,
        subgroup = self.subgroup,
        order = self.order,
        place_result = self.name,
        stack_size = data.raw["item"]["roboport"].stack_size,
    }
    if self.icons then
        item.icons = self.icons
    else
        item.icon = self.icon
        item.icon_size = self.icon_size
    end
    return { item }
end

--- @return data.RecipePrototype[]
function BaseRoboport:recipes()
    ---@type data.RecipePrototype[]
    return {
        {
            type = "recipe",
            name = self.name,
            enabled = false,
            ingredients = {
                { type = "item", name = "roboport", amount = 1 },
                { type = "item", name = "electronic-circuit", amount = 25 },
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
