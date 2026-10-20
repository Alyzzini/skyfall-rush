"""Preserve the hand-edited Studio world as the project's Rojo model source.

Save SkyfallRush.rbxlx in Studio before running this script.
Requires Python 3 and the pinned Rojo CLI installed by Setup-Rojo.ps1.
"""
from pathlib import Path
import json
import subprocess
import xml.etree.ElementTree as ET

root=Path(__file__).resolve().parents[1]
place=root/'SkyfallRush.rbxlx'
document=ET.parse(place)
def name(item):
    return item.findtext("Properties/string[@name='Name']")
workspace=next(item for item in document.getroot().findall('Item') if item.get('class')=='Workspace')
world=next(item for item in workspace.findall('Item') if name(item)=='SkyfallSprint')
# Studio's derived model render cache uses a newer serialization type than Rojo.
# All actual editable parts are retained; Roblox regenerates this cache on load.
for properties in world.iter('Properties'):
    for prop in list(properties):
        if prop.get('name') in {'ModelMeshData','SlimHash'}:
            properties.remove(prop)
snapshot=ET.Element('roblox',{'version':'4'})
snapshot.append(world)
shared=document.getroot().find('SharedStrings')
if shared is not None:
    snapshot.append(shared)
tools=root/'.tools';tools.mkdir(exist_ok=True)
ET.ElementTree(snapshot).write(tools/'edited-world.rbxmx',encoding='utf-8',xml_declaration=True)
(root/'src/world').mkdir(exist_ok=True)
project={'name':'Skyfall edited world','tree':{'$path':'edited-world.rbxmx'}}
(tools/'world.project.json').write_text(json.dumps(project,indent=2)+'\n',encoding='utf-8')
rojo=tools/'rojo.exe'
subprocess.run([str(rojo) if rojo.exists() else 'rojo','build',str(tools/'world.project.json'),'--output',str(root/'src/world/SkyfallSprint.rbxm')],check=True)
print('Exported',sum(1 for _ in world.iter('Item')),'world instances into src/world/SkyfallSprint.rbxm')
