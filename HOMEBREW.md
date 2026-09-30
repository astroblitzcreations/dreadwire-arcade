# Dreadwire Crew / Homebrew

The upgrade adds a separate EmulationStation system whose entries are ordinary
shell launchers. This is the safe place for Void Run, future Python games, and
maintenance tools that should look like menu buttons.

## Included runtime

The installer deliberately uses small Debian packages instead of a copied old
virtual environment: Python 3, venv/pip, pygame, evdev, gpiozero, lgpio, and the
joystick diagnostic utility. A game's extra Python packages should live in that
game's own venv so upgrades cannot break every title at once.

## Add another game or tool

Put an executable `.sh` launcher in `~/RetroPie/roms/homebrew`. EmulationStation
will show it after a restart or game-list refresh. Keep the actual program under
`/opt/dreadwire/<name>` and store save data under the arcade user's home folder.

Do not bind controls to `/dev/input/event5`: that number can change every boot.
Use pygame/SDL controller identity or `/dev/input/by-id`, and provide an on-device
calibration screen for electrically reversed axes.

## Void Run controls to verify on the cabinet

- Joystick: movement (the defaults reproduce the recovered reversed X axis)
- Buttons 0 or 2: fire
- Buttons 1 or 3: afterburner
- Hold buttons 4 and 5: return to EmulationStation

The first cabinet boot remains the authority for axis direction and button index.
If a direction is wrong, change the Godot input map and rebuild; do not rotate or
mirror the game to compensate for wiring.

