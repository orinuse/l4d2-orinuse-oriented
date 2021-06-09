![Add-on's Thumbnail](../resources/xd1.png)
# Dead Air - Terminals Changes
First will be what I had in mind first; Bottom will be vice versa.

### Glossary:
Term | Definition | Notes
---- | ---------- | ----
Onslaught | An event that summons endless Infected hordes, which constantly respawns at a fast pace. Boss Infected are disallowed when active. | Appears usually only on a few occasions as mid-campaign events.
Gauntlet | Similar to Onslaught events, however are more structured. Infecteds will pause spawning if survivors are not progressing fast enough. Tanks are allowed to spawn. | Only in finales. A consistent tank wave appear mid-way through the Gauntlet, which when active, will pause Infected spawning.
Holdout | Events compromising of a large Infected horde, and players are forced to defend themselves until the horde dries out. | Sometimes refer to players "holding out", rather than a "Holdout" event. For example, players holding out at the counter amidst a natural Mob's attack.

## Metal Detector Event
- Previously an Onslaught, now a Holdout.
- - Suppressed the saferoom door concept where characters say "HURRY!"
- Couple of weapon spawners as compensation; See Weapons sub-section.

## Weapons
### Before Van
- Added lots of new weapon_spawn entities among two areas that were lacking in loot  
- Conversions:
- - `weapon_pistol_magnum_spawn` to `weapon_item_spawn`  
- - 2x `prop_physics` gas cans to `weapon_item_spawn`  
- - 2x `weapon_spawn` entities that guaranteed T2 spawning to probably spawning T2 / T1  
### After Van / Before Metal Detector
- Prevented a guaranteed ammo pile from spawning  
- Removed a guaranteed T2 Spawner  
### Around Metal Detector
- Healing items and backup T1 weapons as compensation for a Holdout event  

## Van Event
- Removed the magical push triggers along the pathway of the Van.
- - `SetParentMaintainOffset` is instead used on the Van with a manually spawned in `script_trigger_push`.
- Van will now push away not only survivors and AI SI, but also CI and `prop_physics`.
- Van can now kill CI if they're in front of it.

## Navigation Meshes
### Before Van
- The rock debris spot to the left of the escalator, when looking its front from below, are all now marked as `MOBS_ONLY`, since AI Specials can spawn in there and get stuck due to lack of infected ladders.
- Survivors and Infected acknowledge the alternate path to get down the escalator (to the left of the escalator).
- - The area has been marked with the proper navigation mesh attribute too, especially STAIRS to prevent CI climbing the structure while running up.
### Around Metal Detector
- Added `NOTHREAT` to the big area where the Metal Detector's Holdout event takes place.
### Metal Detector Event
- The escalator leading up to the next floor now has navigation meshes on the railings.
### Van Event
- Van prop itself now has active nav blockers at where it rests. Nav blockers unblock the nav shortly after the Van prop drives away.
