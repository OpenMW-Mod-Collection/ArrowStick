# Arrow Stick (OpenMW)

## 1.6

- Added Impact Effects SFX
  - Requires Impact Effects 1.08 or newer to work
  - Older versions of Impact Effects still work, but they don't make SFX
- Added arow scatter setting
- Changed "ArrowStick_ArrowPlaced" event behavior and data

## 1.5

- Changed distance delay to affect not just impact effects, but arrow spawning too
- Added new event on successful arrow stick
- Renamed event for an attempt to place an arrow ("placeArrow" -> "ArrowStick_PlaceNewArrow")
- Removed some legacy code

## 1.4.2

- Fixed water detection for the second time

## 1.4.1

- Fixed arrows crashing the mod if not shot at water (uh oh)

## 1.4

- Moved Impact Effects Integration settings into their own settings group
- Added water splashes (Impact Effects integration)
- Added a non-sticking material list (Impact Effects integration)
- Added script removing to despawning arrows. It may or may not positively impact your performance
- Fixed random and AOE enchant cheks not working correctly

## 1.3

- Added vanilla parity settings
- Added option to enable sticking for projectiles with AOE enchantments
- Added option to enable underwater sticking

## 1.2.1

- Fixed mod breaking on initialization

## 1.2

- Added settings page
- Added chance for arrow not to stick
- Added option for arrows to despawn on being unloaded
- Added optional Impact Effects integration

## 1.1

- Arrows no longer spawn inside the player

## 1.0

Initial release