# TODO

- [ ] Consider unifying or documenting the item subgroup/order strategy for vanilla and Heroic roboport items.

## Done (2.5.x rewrite / balance pass)
- [x] Uninstall filtering, local `entities`/`roboports`, and the `ghost_ype` typo — fixed by the
  control-stage rewrite (`script/commands.lua`, `script/upgrader.lua`).
- [x] Energy/logistical ghost + entity handling unified via `GhostResolver` and
  `entities.replace`/`replace_ghost`.
- [x] Hard-coded technology effect descriptions moved to locale
  (`[heroic-roboports-effect]` in `locale/en/locale.cfg`).
