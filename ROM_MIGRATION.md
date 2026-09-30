# ROM and BIOS Migration Map

Source root:

```text
raspberry-pi-arcade-recovery-2026-09-24/browsable/home/fritopie/frontend/roms
```

Copy into the new RetroPie user's `RetroPie/roms` tree as follows:

| Recovered folder | RetroPie destination | Notes |
| --- | --- | --- |
| `NES` | `RetroPie/roms/nes` | Preserve `.nes` and supported `.zip` files |
| `genh` | `RetroPie/roms/megadrive` | Genesis/Mega Drive ROM hacks; inspect extensions before launch |
| `gg` | `RetroPie/roms/gamegear` | Sega Game Gear |
| `hh` | Hold for manual review | Mixed DOS/PC-style content, not a single console system |
| `bios` | `RetroPie/BIOS` | Copy recursively; do not rename BIOS files casually |

The `hh` folder contains mixed PC/DOS material and should not be dumped into a
single EmulationStation system. Review it and migrate compatible titles to the
appropriate DOSBox or ports folder after the core systems pass testing.

Do not copy the recovered `venv`, `fritopie-env`, cache directories, or fixed
`/dev/input/event5` references to the new installation.

