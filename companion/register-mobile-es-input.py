#!/usr/bin/env python3
"""Register the persistent Dreadwire virtual pads with EmulationStation."""
from pathlib import Path
import xml.etree.ElementTree as ET

path=Path("/opt/retropie/configs/all/emulationstation/es_input.cfg")
tree=ET.parse(path); root=tree.getroot()
for old in list(root.findall("inputConfig")):
    if old.get("deviceName","").startswith("Dreadwire Player ") or old.get("deviceName") in ("Dreadwire Menu Pad", "Dreadwire Mobile Gamepad"): root.remove(old)
legacy=ET.SubElement(root,"inputConfig",{"type":"joystick","deviceName":"Dreadwire Mobile Gamepad","vendorId":"17495","productId":"1","deviceGUID":"03000000574400000100000001000000"})
legacy_values={"a":("button","0","1"),"b":("button","1","1"),"x":("button","2","1"),"y":("button","3","1"),"leftshoulder":("button","4","1"),"rightshoulder":("button","5","1"),"lefttrigger":("button","6","1"),"righttrigger":("button","7","1"),"select":("button","8","1"),"start":("button","9","1"),"left":("axis","4","-1"),"right":("axis","4","1"),"up":("axis","5","-1"),"down":("axis","5","1")}
for name,(kind,ident,value) in legacy_values.items(): ET.SubElement(legacy,"input",{"name":name,"type":kind,"id":ident,"value":value})
for player in range(1,5):
    guid=f"0300000057440000{player:02x}00000001000000"
    cfg=ET.SubElement(root,"inputConfig",{"type":"joystick","deviceName":f"Dreadwire Player {player}","vendorId":"17495","productId":str(player),"deviceGUID":guid})
    values={"a":("button","0","1"),"b":("button","1","1"),"x":("button","2","1"),"y":("button","3","1"),"leftshoulder":("button","4","1"),"rightshoulder":("button","5","1"),"lefttrigger":("button","6","1"),"righttrigger":("button","7","1"),"select":("button","8","1"),"start":("button","9","1"),"left":("axis","0","-1"),"right":("axis","0","1"),"up":("axis","1","-1"),"down":("axis","1","1")}
    for name,(kind,ident,value) in values.items(): ET.SubElement(cfg,"input",{"name":name,"type":kind,"id":ident,"value":value})
ET.indent(root,space="\t"); tree.write(path,encoding="utf-8",xml_declaration=True)
