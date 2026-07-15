# Migration: adopt `heroic-library` `build_events`

HeroicLibrary 2.1.0 adds a `build_events` module that encapsulates the build/removal event wiring
this mod currently hand-rolls in [`script/control.lua`](../script/control.lua) (the `built_events` /
`removed_events` lists, the per-event filtered `script.on_event` loops, and the separate
`on_entity_cloned` registration). Moving onto it removes ~40 lines of boilerplate and gives us the
Space-Age feature-detection and ghost/real routing for free.

**This is a documented follow-up, not yet applied.** It is a `heroic-library` behavior swap gated by
`factoriomods-change-control`: bump the floor and retest the full roboport upgrade flow in-game
before shipping.

## Steps

1. **Raise the library floor.** In [`info.json`](../info.json) change
   `"heroic-library >= 2.0.0"` → `"heroic-library >= 2.1.0"`.

2. **Replace the wiring in `script/control.lua`.** Delete the `built_filter` / `roboport_filter` /
   `built_events` / `removed_events` locals and the three registration loops
   (`for _, ev in ipairs(built_events) ...`, the `on_entity_cloned` call, and
   `for _, ev in ipairs(removed_events) ...`). Keep `handle_built` and `handle_removed`, but have
   them take the raw entity that `build_events` passes:

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

   `build_events` already: assembles the build list incl. the Space-Age-guarded
   `on_space_platform_built_entity`; applies the `type` + `ghost_type` filter per event; wires
   `on_entity_cloned` (via `include_clone`); and routes ghosts vs real entities to the two callbacks
   using `Entity.from_event` + `:is_ghost()`. So the manual ghost check in the old `handle_built` is
   no longer needed.

3. **Leave the rest of `control.lua` unchanged** — the lifecycle (`on_init`/`on_load`/
   `on_configuration_changed`), the research handlers (`on_research_finished`/`_reversed`), and the
   `on_runtime_mod_setting_changed` re-register are unrelated to build wiring.

4. **Retest in-game** (per change-control): manual build, robot build, blueprint paste (ghost →
   resolve), space-platform build, mining/removal, and a research level-up still upgrade/track/untrack
   roboports correctly, with no desync in multiplayer.

## Note

`Entity:replace` in 2.1.0 also now preserves `direction`. Roboports are directionless, so this is a
no-op for this mod — but confirm nothing regresses during the retest above.
