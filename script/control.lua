require("__heroic-library__.utilities")
require("__heroic-library__.string")
require("__heroic-library__.number")

local Entity = require("__heroic-library__.entity")
local roboports = require("script.roboports")
local Upgrader = require("script.upgrader")
local GhostResolver = Upgrader.GhostResolver
require("script.commands")

-- Filter matching real roboports (type) OR roboport ghosts (ghost_type).
local built_filter = {
    { filter = "type", type = "roboport" },
    { filter = "ghost_type", type = "roboport", mode = "or" },
}
-- Filter matching real roboports only (ghosts are resolved on build, not tracked).
local roboport_filter = { { filter = "type", type = "roboport" } }

-- Build events. Space platform event only exists with Space Age. (on_entity_cloned has a
-- different filter type, so it is registered separately below.)
local built_events = {
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.script_raised_built,
    defines.events.script_raised_revive,
}
if defines.events.on_space_platform_built_entity then
    built_events[#built_events + 1] = defines.events.on_space_platform_built_entity
end

local removed_events = {
    defines.events.on_player_mined_entity,
    defines.events.on_robot_mined_entity,
    defines.events.on_entity_died,
    defines.events.script_raised_destroy,
}

-- Lifecycle -----------------------------------------------------------------------------------

script.on_init(function()
    roboports.initialize()
    -- on_init also fires when the mod is added to an existing save: seed the registry from a
    -- full surface scan, then enqueue everything so it upgrades to the current research level.
    roboports.scan()
    roboports.register()
    roboports.registry:for_each(function(_, unit_number)
        roboports.queue:enqueue(unit_number)
    end)
end)

script.on_load(function()
    roboports.register()
end)

script.on_configuration_changed(function()
    roboports.initialize()
    roboports.scan() -- reconcile the registry with the world after any mod change
    roboports.register()
    roboports.registry:for_each(function(_, unit_number)
        roboports.queue:enqueue(unit_number)
    end)
end)

-- Build / removal -----------------------------------------------------------------------------

---@param entity LuaEntity|nil
local function handle_built(entity)
    local e = Entity.new(entity)
    if not e or not e:is_valid() then
        return
    end
    if e:is_ghost() then
        GhostResolver.resolve(entity)
        return
    end
    if entity.type == "roboport" and roboports.is_mod_roboport(entity) then
        roboports.track(entity)
    end
end

---@param event EventData.on_player_mined_entity|EventData.on_robot_mined_entity|EventData.on_entity_died|EventData.script_raised_destroy
local function handle_removed(event)
    local entity = event.entity
    local e = Entity.new(entity)
    if not e or not e:is_valid() then
        return
    end
    roboports.untrack(entity.unit_number)
end

-- Filters can only be applied when registering a single event id, so register per event.
for _, ev in ipairs(built_events) do
    script.on_event(ev, function(event)
        handle_built(event.entity)
    end, built_filter)
end

-- Cloning is rare (editor / super-force); filter by roboport type only.
script.on_event(defines.events.on_entity_cloned, function(event)
    handle_built(event.destination)
end, roboport_filter)

for _, ev in ipairs(removed_events) do
    script.on_event(ev, handle_removed, roboport_filter)
end

-- Research ------------------------------------------------------------------------------------

---@param event EventData.on_research_finished|EventData.on_research_reversed
local function on_research(event)
    local research = event.research
    if not research or not string.starts_with(research.name, "roboport-") then
        return
    end
    roboports.enqueue_force(research.force)
end

script.on_event(defines.events.on_research_finished, on_research)
script.on_event(defines.events.on_research_reversed, on_research)

-- Runtime setting changes ---------------------------------------------------------------------

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting == "heroic-roboports-upgrade-timer" then
        roboports.reregister()
    end
end)
