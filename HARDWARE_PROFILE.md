# Raspberry Pi Arcade Hardware Profile

Captured from the original card before any upgrade.

## Computer and storage

- Board: Raspberry Pi 4 Model B Rev 1.2
- Card: 31.9 GB nominal, MBR partitioned
- Existing OS: Debian 12 Bookworm, 64-bit
- Existing kernel: Raspberry Pi 6.6.31, arm64
- Existing usage: 5.9 GB used, 22 GB available

## Display

- Connection: first micro-HDMI port (`HDMI-A-1`)
- EDID/preferred mode: 1024x768 at 60.004 Hz
- Physical mounting correction: 90 degrees clockwise
- Original Wayfire configuration:

```ini
[output:HDMI-A-1]
mode = 1024x768@60004
position = 1280,0
transform = 90
```

- RetroPie console/KMS equivalent to test on the replacement image:

```text
video=HDMI-A-1:1024x768@60,rotate=90
```

This belongs on the single line in `cmdline.txt`. Preserve a copy of the unmodified
line before changing it. The old desktop also contained generic mappings for DSI
touch controllers, but the active screen in the boot logs was HDMI-A-1.

## Hardware interfaces enabled on the original card

```ini
dtparam=i2c_arm=on
dtparam=spi=on
dtparam=audio=on
dtoverlay=vc4-kms-v3d
max_framebuffers=2
disable_fw_kms_setup=1
arm_64bit=1
disable_overscan=1
arm_boost=1
dtoverlay=w1-gpio
enable_uart=1
```

Keep these only as a compatibility record. The controls appear as a USB input
device, not direct GPIO keys. The one-wire overlay uses GPIO 4 by default and may
have been for another case accessory.

## Arcade controls

The old FritoPie application opened `/dev/input/event5`. Event numbers are not
stable, so the replacement must identify the encoder by device identity/GUID.

Button scan codes recorded by the old application:

| Control | Scan code |
| --- | ---: |
| A | 290 |
| B | 289 |
| X | 291 |
| Y | 292 |
| Select | 293 |
| Start | 295 |

Joystick axes were intentionally reversed:

| Direction | Linux ABS axis | Old value |
| --- | ---: | ---: |
| Left | 0 | 255 |
| Right | 0 | 0 |
| Up | 1 | 0 |
| Down | 1 | 255 |

During EmulationStation's first-run mapping, move the stick according to the
labels shown on screen. This naturally records the cabinet's reversed wiring.
Do not copy the unstable `/dev/input/event5` path into the new setup.

## Existing software and content

- Custom frontend: FritoPie, Python/Tkinter
- Existing RetroArch: 1.14.0 from Debian packages
- Existing ROM root: `/home/steadyforge/fritopie/frontend/roms`
- Existing content folders: `NES`, `genh`, `gg`, `hh`, and `bios`
- ROM and BIOS content occupies about 139 MB total
- Full verified backup is in:
  `../raspberry-pi-arcade-recovery-2026-09-24`

