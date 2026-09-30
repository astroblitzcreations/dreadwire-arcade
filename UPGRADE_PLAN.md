# Raspberry Pi Arcade Upgrade Plan

## Target

Use the official weekly RetroPie 4.8.12 Bookworm 64-bit image for Raspberry Pi 4,
released 2026-08-25.

- Compressed download: 881,803,764 bytes
- Expanded image: 4,120,903,680 bytes
- Expanded image SHA-256:
  `eb879017a40846003a1db80e5db4c97907703c09659333526f34ab2a8f584aa0`

The 32 GB card is ample. The base image plus the recovered games should use well
under 8 GB, leaving roughly 20 GB for artwork, metadata, saves, and additional
legally obtained games.

## Safety gate

Do not erase the card until all three recovery archives pass `gzip -t` and the
recovered FritoPie tree contains 4,584 source files. These checks already passed
on 2026-09-24.

## Staged upgrade

1. Download and verify the official Pi 4 64-bit image.
2. Flash the 32 GB card only after confirming the Windows disk identity again.
3. Before first boot, preserve the image's original `config.txt` and `cmdline.txt`.
4. Add the KMS display mode/rotation to `cmdline.txt`:
   `video=HDMI-A-1:1024x768@60,rotate=270`
5. Preserve required hardware-interface settings from `HARDWARE_PROFILE.md`.
6. First boot with the cabinet screen and USB arcade encoder connected.
7. Map controls interactively in EmulationStation. Follow the on-screen direction
   names even when the raw axis is electrically reversed.
8. Set Select as Hotkey Enable and Start as Start; Select+Start then exits games.
9. Install a lightweight 4:3-capable modern theme. Recommended starting point:
   Art Book Next using its 4:3 option and metadata-off layout, because the screen
   is small and portrait-rotated.
10. Copy ROMs and BIOS files using `ROM_MIGRATION.md`.
11. Boot-test NES, Genesis, Game Gear, and one BIOS-dependent system.
12. Confirm screen orientation during boot, EmulationStation, RetroArch menus,
    and gameplay before adding more packages or artwork.

## Space policy

- Keep only one installed theme initially.
- Scrape box art and metadata first; avoid gameplay videos until free space is
  rechecked.
- Do not restore either old Python virtual environment.
- Keep recovery archives on the PC, not on the SD card.
- Do not blindly install every optional emulator. Install systems represented by
  the recovered ROM library, then add others intentionally.

## Rollback

The old card contents are recoverable from the three archives in the recovery
folder. The key hardware settings are also recorded separately here, so restoring
the screen and controls does not depend on the old OS booting.
