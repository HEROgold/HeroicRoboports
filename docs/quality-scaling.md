# Quality scaling

Factorio 2.1 gives `RoboportPrototype` one quality field:
`charging_station_count_affected_by_quality`. Every roboport this mod defines sets it to `true` in
`BaseRoboport.new` ([`prototypes/roboport/base.lua`](../prototypes/roboport/base.lua)). The extra
pads per quality level come from the vanilla
`QualityPrototype::logistic_cell_charging_station_count_bonus`, so the mod defines no bonus of its
own.

- Energy roboports: quality pads add to the pads from Roboport Productivity research.
- Logistical roboports: the single pad charges at 4x the vanilla rate, and every quality pad does
  too. A logistical roboport above normal quality therefore charges faster than a vanilla one of
  the same quality.

## Properties that cannot scale with quality

The prototype has no quality field for these, and `LuaEntity` has no runtime setter for them
(`logistic_cell` is read-only):

- `logistics_radius` and `construction_radius`. Beacons, mining drills and containers have
  `quality_affects_*` fields. Roboports have none, and vanilla roboports don't scale area either.
- `robot_slots_count` and `material_slots_count`.
- `energy_source.buffer_capacity` and `energy_usage`.

The only way to scale these would be a control-stage system that swaps each placed roboport for a
stronger variant based on its quality. That re-implements quality in script and adds save-compat
and determinism risk, so the mod doesn't do it. Treat requests for it as settled.
