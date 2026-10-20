-- Idempotent scene cleanup. Keep hand-edited trees and every playable surface.
local Polish={}
local palettes={Color3.fromRGB(44,100,113),Color3.fromRGB(117,71,53),Color3.fromRGB(65,78,132),Color3.fromRGB(92,57,116)}
local function part(parent,name,size,cf,color,material)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent;return p
end
function Polish.Apply(world)
 for i=1,4 do
  local map=world.Levels["Level"..i];local x=map.StartPosition.Position.X
  local old=map.Decor:FindFirstChild("CoursePolish");if old then old:Destroy() end
  local decor=Instance.new("Folder");decor.Name="CoursePolish";decor.Parent=map.Decor
  local board=map.Decor:FindFirstChild("LeaderboardBoard")
  if board then
   board.Size=Vector3.new(16,11,.65);board.Color=Color3.fromRGB(19,34,56)
   board.CFrame=CFrame.lookAt(board.Position,Vector3.new(x,board.Position.Y,5))
   part(decor,"BoardCrown",Vector3.new(16,.14,.14),board.CFrame*CFrame.new(0,5.5,-.4),Color3.fromRGB(78,211,245),Enum.Material.Neon)
   local surface=board:FindFirstChild("LeaderboardSurface");if surface then surface.LightInfluence=0;surface.Brightness=1 end
  end
  -- Keep the line as a readable floor cue; the translucent gate is passable.
  local line=map.StartLine;line.Color=Color3.fromRGB(66,211,255);line.CanTouch=false;line.CanQuery=false;line.CastShadow=false
  local gate=map:FindFirstChild("StartGate") or Instance.new("Part")
  gate.Name="StartGate";gate.Size=Vector3.new(25,12,.18);gate.CFrame=CFrame.new(x,26,line.Position.Z)
  gate.Color=line.Color;gate.Material=Enum.Material.SmoothPlastic;gate.Transparency=.87;gate.Anchored=true;gate.CanCollide=false;gate.CanTouch=false;gate.CanQuery=false;gate.CastShadow=false;gate.Parent=map
  for _,side in {-1,1} do
   part(decor,"GateEdge",Vector3.new(.16,12,.18),CFrame.new(x+side*12.5,26,line.Position.Z),line.Color,Enum.Material.Neon)
  end
  part(decor,"GateTop",Vector3.new(25,.16,.18),CFrame.new(x,32,line.Position.Z),line.Color,Enum.Material.Neon)
  local anchor=part(decor,"GateCaption",Vector3.one*.1,CFrame.new(x,33.5,line.Position.Z),line.Color);anchor.Transparency=1
  local gui=Instance.new("BillboardGui");gui.Size=UDim2.fromScale(20,1.2);gui.MaxDistance=70;gui.Parent=anchor
  local text=Instance.new("TextLabel");text.BackgroundTransparency=1;text.Size=UDim2.fromScale(1,1);text.Font=Enum.Font.GothamBold;text.TextScaled=true;text.Text="CROSS TO START / CROSS AGAIN TO RESET";text.TextColor3=Color3.fromRGB(140,233,255);text.Parent=gui
  -- Consistent deck colors; phase, crumble, conveyor and permanent rests keep their cues.
  for _,p in map.Platforms:GetChildren() do
   if p:IsA("BasePart") then
    p.CastShadow=false
    if p.Name:match("^Hub_") or p.Name:match("^Runway_") and not p:GetAttribute("Conveyor") then p.Color=palettes[i];p.Material=Enum.Material.SmoothPlastic end
   end
  end
  local identity=map.Decor:FindFirstChild("WorldIdentity")
  local columnSeams={}
  if identity then
   for _,p in identity:GetDescendants() do
    if p:IsA("BasePart") then
     p.CastShadow=false;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false
     if p.Name=="GardenIsland" and not p:GetAttribute("TerraceAligned") then
      -- Remove the tilted slab sticking through the user's intact grass terrace.
      p.CFrame=CFrame.new(p.Position);p.Size=Vector3.new(23,6,20);p:SetAttribute("TerraceAligned",true)
     elseif p.Name=="MossTerrace" then p.Color=Color3.fromRGB(68,172,112)
     elseif p.Name=="Canopy" then p.Color=Color3.fromRGB(71,197,143)
     elseif p.Name=="EmberSeam" then
      -- Attach each seam to its nearest column instead of leaving it suspended.
      local nearest;local best=math.huge
      for _,column in identity:GetChildren() do if column.Name=="RuinColumn" then local d=(column.Position-p.Position).Magnitude;if d<best then best=d;nearest=column end end end
      if nearest then
       columnSeams[nearest]=(columnSeams[nearest] or 0)+1
       local side=columnSeams[nearest]%2==0 and -.9 or .9
       p.Size=Vector3.new(.18,10,.12);p.CFrame=nearest.CFrame*CFrame.new(side,0,nearest.Size.Z/2+.07)
       p.Color=Color3.fromRGB(255,147,62)
      end
     elseif p.Name=="EmberCore" then
      p.Size=Vector3.new(7,4,7);p.Color=Color3.fromRGB(255,123,48)
      part(decor,"Crucible",Vector3.new(9,2,9),CFrame.new(p.Position-Vector3.new(0,2.5,0)),Color3.fromRGB(87,51,48),Enum.Material.Slate)
     end
    end
   end
  end
  for _,p in map.Decor:GetDescendants() do
   if p:IsA("BasePart") then p.CastShadow=false;p.CanTouch=false;p.CanQuery=false end
   if p:IsA("BillboardGui") then p.AlwaysOnTop=false;p.MaxDistance=math.min(p.MaxDistance>0 and p.MaxDistance or 60,70) end
  end
  for _,anchor in map.Decor:GetChildren() do
   local caption=anchor:FindFirstChildOfClass("BillboardGui")
   if caption and anchor.Name=="SectionLabel" then
    caption.Size=UDim2.fromScale(17,1.2);caption.MaxDistance=42
    local text=caption:FindFirstChildOfClass("TextLabel");if text then text.TextStrokeTransparency=.9 end
   elseif caption and anchor.Name=="GameTitle" then
    anchor.Position=Vector3.new(x,38,0);caption.Size=UDim2.fromScale(23,1.8);caption.MaxDistance=65
   end
  end
  for _,orb in map.Orbs:GetChildren() do orb.CastShadow=false;orb.CanQuery=false end
  for _,hazard in map.Hazards:GetChildren() do if hazard:IsA("BasePart") then hazard.CastShadow=false;hazard.CanTouch=false;hazard.CanQuery=false end end
  task.wait()
 end
 local lighting=game:GetService("Lighting")
 lighting.Brightness=3;lighting.ExposureCompensation=.12
 lighting.Ambient=Color3.fromRGB(105,143,171);lighting.OutdoorAmbient=Color3.fromRGB(140,167,185);lighting.ClockTime=13.3
 local color=lighting:FindFirstChild("SkyfallColor") or Instance.new("ColorCorrectionEffect");color.Name="SkyfallColor";color.Saturation=.22;color.Contrast=.06;color.Brightness=.015;color.TintColor=Color3.fromRGB(255,249,239);color.Parent=lighting
 local bloom=lighting:FindFirstChild("SkyfallBloom") or Instance.new("BloomEffect");bloom.Name="SkyfallBloom";bloom.Intensity=.08;bloom.Threshold=1.7;bloom.Size=12;bloom.Parent=lighting
 local atmosphere=lighting:FindFirstChildOfClass("Atmosphere");if atmosphere then atmosphere.Density=.10;atmosphere.Haze=.15;atmosphere.Color=Color3.fromRGB(187,225,255);atmosphere.Decay=Color3.fromRGB(106,166,218) end
 world:SetAttribute("PolishVersion","Vibrant_1")
 return "Aligned islands, attached ember accents, passable start gates and vibrant lighting installed."
end
return Polish
