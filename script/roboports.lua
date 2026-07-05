require("__heroic-library__.string")
local Entity = require("__heroic-library__.entity")
local EntityRegistry = require("__heroic-library__.entity_registry")
local WorkQueue = require("__heroic-library__.work_queue")
local settings = require("settings")
local Upgrader = require("script.upgrader")

--- Owns the runtime state for tracking and upgrading roboports: the entity registry, the
--- throttled upgrade queue, and the operations the event handlers / commands drive. Kept as a
--- single module so `storage` stays plain data and there is one place responsible for state.
local M = {}

--- Only OUR roboports are tracked; vanilla "roboport" is left alone.
---@param entity LuaEntity
---@return boolean
local function is_mod_roboport(entity)
    local name = entity.name
    return string.starts_with(name, "energy-roboport") or string.starts_with(name, "logistical-roboport")
end
M.is_mod_roboport = is_mod_roboport

M.registry = EntityRegistry.new("roboport_registry", "roboport", { filter = is_mod_roboport })

M.queue = WorkQueue.new("roboport_upgrade_queue", {
    interval = settings.upgrade_timer,
    batch = settings.upgrade_batch_size,
    process = function(unit_number)
        M.process_upgrade(unit_number)
    end,
})

---@return boolean
function M.is_suppressed()
    return (storage.suppress_upgrades_until or 0) > game.tick
end

---Prevent upgrades for `ticks` game ticks (used by the uninstall command).
---@param ticks integer
function M.suppress(ticks)
    storage.suppress_upgrades_until = game.tick + ticks
end

--- Queue callback: upgrade a single tracked roboport and keep the registry in sync.
---@param unit_number number
function M.process_upgrade(unit_number)
    if M.is_suppressed() then
        return
    end
    local entity = M.registry:get(unit_number)
    if not entity then
        return
    end
    local created = Upgrader.upgrade(entity)
    if created then
        M.registry:remove(unit_number)
        M.registry:add(created)
    end
end

--- Create storage tables if missing. Safe to call from on_init/on_configuration_changed.
function M.initialize()
    M.registry:initialize()
    M.queue:initialize()
    storage.suppress_upgrades_until = storage.suppress_upgrades_until or 0
end

--- (Re-)register the nth-tick queue handler. Call from on_init and on_load.
function M.register()
    M.queue:register()
end

--- Re-register the queue when its interval setting changes.
function M.reregister()
    M.queue:reregister()
end

--- Scan every surface and register all existing mod roboports (on_init / reconcile).
function M.scan()
    M.registry:scan_all()
end

--- Track a freshly built roboport and enqueue it (unless suppressed).
---@param entity LuaEntity
function M.track(entity)
    M.registry:add(entity)
    if not M.is_suppressed() then
        M.queue:enqueue(entity.unit_number)
    end
end

--- Stop tracking a removed roboport.
---@param unit_number number|nil
function M.untrack(unit_number)
    M.registry:remove(unit_number)
    M.queue:dequeue(unit_number)
end

--- Enqueue every tracked roboport belonging to `force` (research-driven update).
---@param force LuaForce
function M.enqueue_force(force)
    if M.is_suppressed() then
        return
    end
    M.registry:for_each(function(entity, unit_number)
        if entity.force == force then
            M.queue:enqueue(unit_number)
        end
    end)
end

--- Revert every mod roboport to vanilla and stop tracking, then suppress re-upgrades for 10s.
function M.uninstall()
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(surface.find_entities_filtered({ type = "roboport" })) do
            local e = Entity.new(entity)
            if e and e:is_valid() and is_mod_roboport(entity) then
                e:replace("roboport")
            end
        end
    end
    M.registry:clear()
    storage.roboport_upgrade_queue = {}
    M.suppress(600) -- 10 seconds at 60 UPS
end

--- Revert mod roboports to their base (level 0) variant and re-track them.
function M.reset_entities()
    M.registry:clear()
    storage.roboport_upgrade_queue = {}
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(surface.find_entities_filtered({ type = "roboport" })) do
            local e = Entity.new(entity)
            if e and e:is_valid() and is_mod_roboport(entity) then
                local family = Upgrader.family_for(entity.name)
                local base = family == "energy" and "energy-roboport" or "logistical-roboport"
                local created = e:replace(base)
                if created then
                    M.registry:add(created:unwrap())
                end
            end
        end
    end
end

--- Clear all internal tracking (hr-clean).
function M.clear_tracking()
    M.registry:clear()
    storage.roboport_upgrade_queue = {}
end

return M
