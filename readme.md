# Roboport Upgrades

Mod page can be found [Here](https://mods.factorio.com/mod/heroic-roboport-upgrades)!

## Content

Ths mod adds upgrades to roboports, similar to the module's found in the game.

Has support for Space-Exploration and Module-T4 mods.

For how quality interacts with these roboports (and which quality-scaling requests are not
possible in Factorio 2.1), see [docs/quality-scaling.md](docs/quality-scaling.md).

### Research levels

Each upgrade axis defaults to 6 levels, and the hard limit is 12. Every level is a set of
pre-generated roboport variants. Logistical variants grow as (levels + 1)^4, so each level above 6
makes the game load slower.

### Power statistics

Every upgrade combination is its own entity, so the electric network statistics list roboport
power usage per variant (for example "Energy Roboport Mk. e1p2s0") instead of one combined entry.
Factorio has no way to group prototypes in those statistics.

## Commands

### /hr-uninstall

Removes any of this mod's roboports, and reverts them to vanilla.
