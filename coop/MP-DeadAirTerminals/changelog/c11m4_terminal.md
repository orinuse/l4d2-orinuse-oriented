![Add-on's Thumbnail](../resources/xd1.png)
# Dead Air - Terminals Changes

### Glossary:
| Term | Definition |
| ---- | ---------- |
Onslaught | Plow through endless waves of infected to progress. Boss Infected are disallowed when active. |
Gauntlet | Stage-structured version of Onslaught events only found on finales. |
Holdout | Defend till the horde dries out. |

## Metal Detector Event
- From Onslaught to Holdout.
- - Suppressed the saferoom door concept where characters say "HURRY!"
- Couple of weapon spawners as compensation; See Weapons sub-section.

## Weapons
### Before Van
- Added lots of weapon_spawn entities to areas that were devoid of loot 
- - `weapon_pistol_magnum_spawn` to `weapon_item_spawn`  
- - 2x `prop_physics` gas cans to `weapon_item_spawn`  
- - 2x `weapon_spawn` entities with guaranteed T2 spawning to any weapon
### After Van / Before Metal Detector
- Prevented a guaranteed ammo pile from spawning  
- Removed guaranteed spawners foe T2 and ammo pile
### Around Metal Detector
- Healing items and backup T1 weapons as compensation for a Holdout event  

## Van Event
- Replaced the push triggers along the Van's path with a `script_trigger_push` that follows the Van. (`SetParentMaintainOffset`)
- Any `prop_physics` will be flung when ran over by the Gan.
- Van can now run over and kill CI.

## Navigation Meshes
### Before Van
- The rock debris near the escalator are marked as `MOBS_ONLY` to prevent AI Specials getting stuck.
- Laid STAIRS-marked nav areas for the baggage tube at the left of the escalator.
- - STAIRS prevents CI from climbing.
### Around Metal Detector
- Added `NOTHREAT` to around where the Metal Detector's Holdout event takes place.
### Metal Detector Event
- The escalator leading up to the next floor has navigation areas on the railings.
### Van Event
- Nav blockers at the Van's location which unblock after the Van prop moves away.
