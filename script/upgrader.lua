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

---Upgrade (or downgrade) a roboport to match its force's research. Returns the newly created
---entity, or nil if nothing changed / creation failed.
---@param entity LuaEntity
---@return LuaEntity|nil
function Upgrader.upgrade(entity)
    local e = Entity.new(entity)
    if not e or not e:is_valid() then
        return nil
    end
    local target = Upgrader.target_name(entity)
    if not target or entity.name == target then
        return nil
    end
    local created = e:replace(target)
    return created and created:unwrap() or nil
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
