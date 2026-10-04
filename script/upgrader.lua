require("__heroic-library__.string")
local Entity = require("__heroic-library__.entity")
local codec = require("name_codec")
local levels = require("helpers.levels")

--- Pure upgrade logic (no storage/registry bookkeeping — the caller handles that).
--- Resolves the correct variant name for a roboport given its force's researched levels and
--- performs the swap via the library's nil-guarded `Entity:replace`.
local Upgrader = {}

---@param name string
---@return "energy"|"logistical"|nil
function Upgrader.family_for(name)
    if string.starts_with(name, "energy-roboport") then
        return "energy"
    elseif string.starts_with(name, "logistical-roboport") then
        return "logistical"
    end
    return nil
end

---Compute the variant name this roboport should have for its force's current research.
---@param entity LuaEntity
---@return string|nil
function Upgrader.target_name(entity)
    local family = Upgrader.family_for(entity.name)
    if not family then
        return nil
    end
    local force_levels = levels[family](entity.force)
    return codec[family]:name(force_levels)
end

local ROBOPORT_INVENTORIES = { defines.inventory.roboport_robot, defines.inventory.roboport_material }

---Move every stack out of `entity`'s roboport inventories into temporary script inventories.
---Stacks are transferred (not copied), so robot health and repair-pack durability survive.
---@param entity LuaEntity
---@return table<defines.inventory, LuaInventory>
local function stash_contents(entity)
    local stashes = {}
    for _, id in ipairs(ROBOPORT_INVENTORIES) do
        local inventory = entity.get_inventory(id)
        if inventory and not inventory.is_empty() then
            local stash = game.create_inventory(#inventory)
            for i = 1, #inventory do
                local stack = inventory[i]
                if stack.valid_for_read then
                    stash[i].transfer_stack(stack)
                end
            end
            stashes[id] = stash
        end
    end
    return stashes
end

---Insert stashed stacks into `entity`. Anything that no longer fits (the new prototype has fewer
---slots) is spilled on the ground and marked for deconstruction, so robots haul it to storage.
---@param entity LuaEntity
---@param stashes table<defines.inventory, LuaInventory>
local function restore_contents(entity, stashes)
    for _, id in ipairs(ROBOPORT_INVENTORIES) do
        local stash = stashes[id]
        if stash then
            local inventory = entity.get_inventory(id)
            for i = 1, #stash do
                local stack = stash[i]
                if stack.valid_for_read and inventory then
                    local inserted = inventory.insert(stack)
                    if inserted >= stack.count then
                        stack.clear()
                    elseif inserted > 0 then
                        stack.count = stack.count - inserted
                    end
                end
                if stack.valid_for_read then
                    entity.surface.spill_item_stack({
                        position = entity.position,
                        stack = stack,
                        enable_looted = true,
                        force = entity.force,
                        allow_belts = false,
                    })
                end
            end
            stash.destroy()
        end
    end
end

---Swap a roboport for `new_name` without losing the robots and materials inside it.
---Fast-replace alone deletes whatever doesn't fit the new prototype's slot counts (e.g. a
---12-slot logistical roboport reverting to the 7-slot vanilla one), so contents are moved out
---first and put back afterwards. On failure the original entity keeps its contents.
---@param entity LuaEntity
---@param new_name string
---@return LuaEntity|nil
function Upgrader.replace(entity, new_name)
    local e = Entity.new(entity)
    if not e or not e:is_valid() then
        return nil
    end
    local stashes = stash_contents(entity)
    local created = e:replace(new_name)
    local raw = created and created:unwrap() or nil
    restore_contents(raw or entity, stashes)
    return raw
end

---Upgrade (or downgrade) a roboport to match its force's research. Returns the newly created
---entity, or nil if nothing changed / creation failed.
---@param entity LuaEntity
---@return LuaEntity|nil
function Upgrader.upgrade(entity)
    if not entity.valid then
        return nil
    end
    local target = Upgrader.target_name(entity)
    if not target or entity.name == target then
        return nil
    end
    return Upgrader.replace(entity, target)
end

--- Resolves ghosts of an upgraded variant back to the base family ghost, so blueprinted
--- roboports rebuild as the base entity (which is then upgraded once placed).
local GhostResolver = {}

---@param ghost LuaEntity
---@return LuaEntity|nil
function GhostResolver.resolve(ghost)
    local g = Entity.new(ghost)
    if not g or not g:is_valid() or not g:is_ghost() then
        return nil
    end
    local family = Upgrader.family_for(ghost.ghost_name)
    if not family then
        return nil
    end
    local base_name = family == "energy" and "energy-roboport" or "logistical-roboport"
    if ghost.ghost_name == base_name then
        return nil
    end
    local created = g:replace_ghost(base_name)
    return created and created:unwrap() or nil
end

Upgrader.GhostResolver = GhostResolver

return Upgrader
