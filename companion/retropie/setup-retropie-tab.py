#!/usr/bin/env python3
from pathlib import Path
import shutil
import xml.etree.ElementTree as ET

SYSTEMS = Path('/home/pi/.emulationstation/es_systems.cfg')
ROMS = Path('/home/pi/RetroPie/roms/companion')
SOURCE = Path('/tmp/dreadwire-companion/retropie')
ROMS.mkdir(parents=True, exist_ok=True); (ROMS/'media').mkdir(exist_ok=True)
for script in ('01-scan-qr.sh','02-connection-info.sh','03-restart-remote.sh','04-mobile-player1.sh','05-battery-help.sh'):
    shutil.copy2(SOURCE/script, ROMS/script); (ROMS/script).chmod(0o755)

tree=ET.parse(SYSTEMS); root=tree.getroot()
for node in list(root.findall('system')):
    if node.findtext('name') == 'companion': root.remove(node)
node=ET.SubElement(root,'system')
for tag,value in [('name','companion'),('fullname','Arcade Remote'),('path',str(ROMS)),('extension','.sh .SH'),('command','bash %ROM%'),('platform','pc'),('theme','companion')]:
    ET.SubElement(node,tag).text=value
backup=SYSTEMS.with_suffix('.cfg.before-companion')
if not backup.exists(): shutil.copy2(SYSTEMS,backup)
ET.indent(tree,space='  '); tree.write(SYSTEMS,encoding='utf-8',xml_declaration=True)

entries=[
 ('./01-scan-qr.sh','SCAN QR — CONNECT PHONE','Display a full-screen QR code that opens Dreadwire Arcade Remote.'),
 ('./02-connection-info.sh','CONNECTION & LOGIN','Show the current phone address, account name, and service status.'),
 ('./03-restart-remote.sh','RESTART REMOTE SERVICE','Restart the phone companion without rebooting the cabinet.'),
 ('./04-mobile-player1.sh','MAKE PHONE PLAYER 1','Assign the mobile virtual gamepad as RetroArch Player 1.'),
 ('./05-battery-help.sh','BATTERY CALIBRATION HELP','Learn how manual INIU readings produce a runtime estimate.'),
]
game_root=ET.Element('gameList')
for path,name,desc in entries:
    game=ET.SubElement(game_root,'game'); ET.SubElement(game,'path').text=path; ET.SubElement(game,'name').text=name; ET.SubElement(game,'desc').text=desc; ET.SubElement(game,'image').text=str(ROMS/'media/arcade-remote-qr.png'); ET.SubElement(game,'developer').text='Dreadwire Crew'; ET.SubElement(game,'genre').text='System Tool'
game_tree=ET.ElementTree(game_root); ET.indent(game_tree,space='  '); game_tree.write(ROMS/'gamelist.xml',encoding='utf-8',xml_declaration=True)
for path in ROMS.rglob('*'):
    try: shutil.chown(path,user='pi',group='pi')
    except PermissionError: pass
