# Quality scaling for Heroic roboports (Factorio 2.1)

This note records which quality-scaling behaviours are possible for this mod's roboports and,
importantly, which are **not** — so the impossible ones don't get re-investigated.

## What IS implemented

- **Energy roboport — more simultaneous charging spots with quality.**
  `RoboportPrototype::charging_station_count_affected_by_quality = true`
  (set in [`prototypes/roboport/energy-roboports.lua`](../prototypes/roboport/energy-roboports.lua),
  `EnergyRoboport:_apply_energy`). The per-quality increment comes from the vanilla
  `QualityPrototype::logistic_cell_charging_station_count_bonus` — the same bonus personal
  roboports use — so we only opt in; we don't define the bonus ourselves. More charging spots
  means more robots charging at once and faster fleet recharge, which is the achievable part of
  "more allowed robots" and "more speed" with quality.

## What is NOT possible (and why)

Factorio 2.1's `RoboportPrototype` exposes **exactly one** quality knob:
`charging_station_count_affected_by_quality`. There is no `quality_affects_*` or
`*_quality_scaling` field for any other roboport property, and `LuaEntity` has no runtime setter
for roboport radius / slots / buffer (`logistic_cell` is read-only). So the following requests
cannot be honoured on a roboport prototype:

- **Energy roboport — internal energy buffer scaling with quality.**
  `energy_source.buffer_capacity` (and `energy_usage`) have no quality field on the prototype and
  no runtime setter. Quality cannot change a roboport's internal energy buffer.

- **Logistical roboport — supply / logistics area scaling with quality.**
  `logistics_radius` and `construction_radius` have no quality field. Contrast this with beacons
  (`quality_affects_supply_area_distance`), mining drills (`quality_affects_mining_radius`), and
  containers (`quality_affects_inventory_size`) — roboports were not given an equivalent. There is
  also no runtime setter. Vanilla roboports likewise do not scale area with quality.

- **Logistical roboport — robot / material slot counts scaling with quality.**
  `robot_slots_count` and `material_slots_count` have no quality field either.

## The only workaround (intentionally not done)

The sole way to make area / slots / buffer effectively scale with quality would be a custom
control-stage system that detects a placed roboport's quality and **swaps it for a stronger
prototype variant**. That re-implements quality by hand, adds runtime + save-compat + determinism
surface (see the repo's house rules), and is out of scope. It is recorded here only to explain why
the direct approach is impossible, not as a TODO.
