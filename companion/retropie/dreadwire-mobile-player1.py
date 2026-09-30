#!/usr/bin/env python3
from pathlib import Path
import re

index = None
for js in Path('/sys/class/input').glob('js*'):
    try: name = (js / 'device/name').read_text().strip()
    except OSError: continue
    if name == 'Dreadwire Mobile Gamepad': index = int(js.name[2:]); break
if index is None: raise SystemExit('Mobile gamepad service is not running')
path = Path('/opt/retropie/configs/all/retroarch.cfg')
text = path.read_text()
key = 'input_player1_joypad_index'; line = f'{key} = "{index}"'
pattern = re.compile(rf'^\s*{key}\s*=.*$', re.MULTILINE)
text = pattern.sub(line, text) if pattern.search(text) else text.rstrip() + '\n' + line + '\n'
temporary = path.with_suffix('.cfg.mobile.tmp'); temporary.write_text(text); temporary.replace(path)
