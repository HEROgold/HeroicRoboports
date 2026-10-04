# Follow-up: move build wiring to heroic-library `build_events`

Status: not applied. [`script/control.lua`](../script/control.lua) still registers build and
removal events by hand. The library's `build_events` module (heroic-library 2.1.0, already the
floor in [`info.json`](../info.json)) does the same work: it builds the event list, adds the Space
Age `on_space_platform_built_entity` event when it exists, applies the `type` and `ghost_type`
filters, wires `on_entity_cloned`, and routes ghosts and real entities to separate callbacks.

This is a gated control-stage change. Follow `factoriomods-change-control` and finish with the
in-game test in step 3.

## Steps

1. In `script/control.lua`, delete the `built_filter`, `roboport_filter`, `built_events` and
   `removed_events` locals, the two `for _, ev in ipairs(...)` registration loops, and the
   `on_entity_cloned` registration. Done when no `script.on_event` call for a build or removal
   event remains.

2. Register through the library. The callbacks receive the raw `LuaEntity`, so the ghost check in
   `handle_built` goes away:

   ```lua
   local BuildEvents = require("__heroic-library__.build_events")

   BuildEvents.on_built({
       type = "roboport",
       include_clone = true,
       on_entity = function(entity)
           if roboports.is_mod_roboport(entity) then
               roboports.track(entity)
           end
       end,
       on_ghost = function(ghost)
           GhostResolver.resolve(ghost)
       end,
   })

   BuildEvents.on_removed({
       type = "roboport",
       on_entity = function(entity)
           roboports.untrack(entity.unit_number)
       end,
   })
   ```

   Leave the lifecycle handlers, the research handlers and the runtime-setting handler as they are.

3. Test in-game. Done when each of these still tracks, upgrades or untracks the roboport: a
   manual build, a robot build, a blueprint paste (the ghost resolves to the base roboport), a
   space platform build, mining, and a research level-up. Run one multiplayer session and check
   that it doesn't desync.
