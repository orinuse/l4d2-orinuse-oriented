![Add-on's Thumbnail](xd1.png)
# Dead Air - Terminals Changes
First will be what I had in mind first; Bottom will be vice versa.
## Metal Detector Event
- Previously an Onslaught, now a Holdout.
- - Suppressed the saferoom door concept where characters say "HURRY!"
- - Term definitions:
- - - Onslaught: Infinite horde of Infected that constantly respawns
- - - Gauntlet: which provides breaks dependant on your flow progression.
- Couple of weapon spawners as compensation; See Weapons sub-section.

## Weapons
### Before Van
- Added lots of new weapon_spawn entities among two areas that were lacking in loot  
- Conversions:
- - weapon_pistol_magnum_spawn to weapon_item_spawn  
- - 2x prop_physics gas cans to weapon_item_spawn  
- - 2x weapon_spawn entities that guaranteed T2 spawning to probably spawning T2 / T1  
### After Van / Before Metal Detector
- Prevented a guaranteed ammo pile from spawning  
- Removed a guaranteed T2 Spawner  
### Around Metal Detector
- Healing items and backup T1 weapons as compensation for a Holdout event  

## Van Event
- Removed the magical push triggers along the pathway of the Van.
- - `SetParentMaintainOffset` is instead used on the Van with a manually spawned in `script_trigger_push`.
- Van will now push away not only survivors and AI SI, but also CI and prop_physics.
- Van can now kill CI if they're in front of it.

## Navigation Meshes
### Before Van
- The rock debris spot to the left of the escalator, when looking its front from below, are all now marked as MOBS_ONLY, since AI Specials can spawn in there and get stuck due to lack of infected ladders.
- Survivors and Infected acknowledge the alternate path to get down the escalator (to the left of the escalator).
- - The area has been marked with the proper navigation mesh attribute too, especially STAIRS to prevent CI climbing the structure while running up.
### Around Metal Detector
- Added NOTHREAT to the big area where the Metal Detector's Holdout event takes place.
