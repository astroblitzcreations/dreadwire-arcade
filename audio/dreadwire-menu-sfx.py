#!/usr/bin/env python3
"""Play EmulationStation UI sounds with their own saved volume and mute."""
import json, subprocess, sys
from pathlib import Path
CONFIG=Path("/home/pi/.config/dreadwire-audio.json")
SOUNDS=Path("/etc/emulationstation/themes/dreadwire-neon-3d/assets/sounds")
FILES={"move":"scroll.wav","select":"slide.wav","launch":"launch.wav","return":"return.wav"}
state={"menu_volume":70,"menu_muted":False}
try: state.update(json.loads(CONFIG.read_text()))
except (OSError,ValueError,TypeError): pass
name=FILES.get(sys.argv[1] if len(sys.argv)>1 else "")
if name and not state.get("menu_muted"):
    volume=max(0,min(100,int(state.get("menu_volume",70))))
    subprocess.run(["/usr/bin/paplay",f"--volume={round(volume*65536/100)}",str(SOUNDS/name)],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,check=False)
