# Dreadwire Crew: Void Run for RetroPie

This is the standalone version of the Gradius-style Void Run minigame recovered
from the Dreadwire Crew Godot project. It contains only the game, its sprites,
shaders, three music tracks, complete sound bank, and two custom MP3 effects.

The default joystick axes reproduce the old cabinet mapping:

- raw X positive = left
- raw X negative = right
- raw Y negative = up
- raw Y positive = down

Buttons 0 or 2 fire. Buttons 1 or 3 engage the afterburner. Holding joystick
buttons 4 and 5 together exits to EmulationStation. These defaults must be tested
on the cabinet after the first boot because Linux event codes and Godot/SDL button
indices are different namespaces.

The screen is not rotated inside the game. Rotation is deliberately applied once
at the Raspberry Pi KMS layer so the game, RetroPie, and all emulators agree.

Build with Godot 4.6.x and the official ARM64 export template:

```text
godot --headless --path . --export-release "Raspberry Pi 4 ARM64"
```

Verified build (2026-09-24):

- `build/void-run.arm64`: 103,458,544 bytes
- ELF 64-bit ARM aarch64, dynamically linked for GNU/Linux 5.15+
- SHA-256: `e6c31871076e9f16d6c2f2b48a4c369a2f28ed641b3077af4c3aab90cdaed4ad`
