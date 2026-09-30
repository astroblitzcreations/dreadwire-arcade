# Chain of Command: Speedbike for RetroPie

Standalone Raspberry Pi 4 ARM64 package of the Speedbike mode. It keeps only
the game mode, its tracks, art, audio, and small compatibility autoloads rather
than installing the multi-gigabyte Chain of Command project.

Build with Godot 4.6.1 and its ARM64 export template:

```powershell
Godot_v4.6.1-stable_win64_console.exe --headless --path . --export-release "Raspberry Pi 4 ARM64"
```
