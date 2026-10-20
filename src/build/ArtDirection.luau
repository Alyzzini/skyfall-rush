-- Edit-time visual pass. Every new prop is noncolliding and cannot alter ranked routes.
local Config=require(game.ReplicatedStorage.SkyfallConfig)
local world=workspace.SkyfallSprint
local function piece(parent,name,size,cf,color,material)
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf; p.Color=color; p.Material=material or Enum.Material.SmoothPlastic
 p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.CastShadow=false; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=parent; return p
end
local function ring(parent,name,center,radius,color,axis)
 local f=Instance.new("Model"); f.Name=name; f.Parent=parent
 for i=1,20 do
  local a=i*math.pi/10; local cf=CFrame.new(center)* (axis or CFrame.new()) * CFrame.Angles(0,0,a) * CFrame.new(0,radius,0)
  piece(f,"Segment",Vector3.new(radius*.32,.65,.65),cf,color,Enum.Material.Neon)
 end
 return f
end
for level,spec in ipairs(Config.Levels) do
 local map=world.Levels:FindFirstChild("Level"..level)
 local old=map.Decor:FindFirstChild("WorldIdentity"); if old then old:Destroy() end
 local decor=Instance.new("Folder"); decor.Name="WorldIdentity"; decor.Parent=map.Decor
 local board=map.Decor:FindFirstChild("LeaderboardBoard"); if board then board.Position=Vector3.new(spec.X-25,27,11) end
 local title=map.Decor:FindFirstChild("GameTitle"); if title then title.Position=Vector3.new(spec.X,36,0); local b=title:FindFirstChildOfClass("BillboardGui"); if b then b.MaxDistance=55; b.Size=UDim2.fromScale(24,2) end end
 local rules=map.Decor:FindFirstChild("StartRules"); if rules then local b=rules:FindFirstChildOfClass("BillboardGui"); if b then b.Enabled=false end end
 local accent=spec.Color
 local baseColors={Color3.fromRGB(37,65,67),Color3.fromRGB(72,44,34),Color3.fromRGB(43,44,75),Color3.fromRGB(50,33,53)}
 for _,p in map.Platforms:GetChildren() do
  if p:IsA("BasePart") and (p.Name:match("Hub_") or p.Name:match("Runway_") and not p:GetAttribute("Conveyor")) then p.Color=baseColors[level] end
 end
 for _,item in map.Decor:GetChildren() do
  if item.Name=="SectionLabel" then
   local b=item:FindFirstChildOfClass("BillboardGui"); if b then b.MaxDistance=48; b.Size=UDim2.fromScale(21,1.1) end
  end
 end
 -- Open checkpoint portals frame the route without masking the landing surface.
 for stage=0,spec.Sections,4 do
  local z=-stage*96
  for _,side in {-1,1} do
   piece(decor,"GatePillar",Vector3.new(1.2,14,1.2),CFrame.new(spec.X+side*15,26,z),baseColors[level],Enum.Material.Metal)
   piece(decor,"Beacon",Vector3.new(.25,12,.25),CFrame.new(spec.X+side*14.3,26,z+.7),accent,Enum.Material.Neon)
  end
  piece(decor,"GateCrown",Vector3.new(31,1,1.2),CFrame.new(spec.X,33,z),baseColors[level],Enum.Material.Metal)
  for j=-2,2 do piece(decor,"GateLight",Vector3.new(3,.25,.3),CFrame.new(spec.X+j*5,32.4,z+.7),accent,Enum.Material.Neon) end
 end
 for section=0,spec.Sections-1,2 do
  local z=-section*96-45; local side=section%4==0 and -1 or 1; local x=spec.X+side*42
  if level==1 then
   -- Hanging botanical islands: stone terraces, glowing tree trunks, broad canopies.
   piece(decor,"GardenIsland",Vector3.new(25,6,22),CFrame.new(x,9,z)*CFrame.Angles(0,.25,.08),Color3.fromRGB(56,79,77),Enum.Material.Slate)
   piece(decor,"MossTerrace",Vector3.new(23,1,20),CFrame.new(x,12,z),Color3.fromRGB(62,126,103),Enum.Material.Grass)
   piece(decor,"Tree",Vector3.new(2,13,2),CFrame.new(x,19,z)*CFrame.Angles(0,0,.16),Color3.fromRGB(75,100,91),Enum.Material.Wood)
   for j=1,3 do local leaf=piece(decor,"Canopy",Vector3.new(17-j*3,3,14-j*2),CFrame.new(x+j-2,24+j*2,z),Color3.fromRGB(62+j*8,137+j*13,117+j*6)); leaf.Shape=Enum.PartType.Ball end
   ring(decor,"GardenHalo",Vector3.new(x,20,z),14,accent,CFrame.Angles(math.rad(75),0,0))
  elseif level==2 then
   -- Broken foundry arches, suspended crucibles and ember seams.
   for _,offset in {-8,8} do piece(decor,"RuinColumn",Vector3.new(5,21,5),CFrame.new(x+offset,14,z)*CFrame.Angles(0,.1,offset*.01),Color3.fromRGB(93,66,46),Enum.Material.Slate) end
   piece(decor,"BrokenLintel",Vector3.new(23,4,6),CFrame.new(x,25,z)*CFrame.Angles(0,0,.12),Color3.fromRGB(119,81,48),Enum.Material.Slate)
   local bowl=piece(decor,"EmberCore",Vector3.new(11,5,11),CFrame.new(x,8,z),Color3.fromRGB(255,122,46),Enum.Material.Neon); bowl.Shape=Enum.PartType.Ball
   for j=1,4 do piece(decor,"EmberSeam",Vector3.new(.3,9,1),CFrame.new(x-8+j*4,15,z+3.1)*CFrame.Angles(0,0,.25),accent,Enum.Material.Neon) end
  elseif level==3 then
   -- Storm harvesting turbines and conductive spires.
   piece(decor,"TurbineMast",Vector3.new(3,31,3),CFrame.new(x,10,z),baseColors[level],Enum.Material.Metal)
   local turbine=ring(decor,"Turbine",Vector3.new(x,28,z),13,accent)
   turbine:SetAttribute("SpinVisual",true); turbine:SetAttribute("VisualCenter",Vector3.new(x,28,z))
   for j=1,3 do
    local a=j*math.pi*2/3
    piece(turbine,"Blade",Vector3.new(3,11,.7),CFrame.new(x,28,z)*CFrame.Angles(0,0,a)*CFrame.new(0,6,0),Color3.fromRGB(120,135,171),Enum.Material.Metal)
   end
   piece(decor,"Collector",Vector3.new(2,24,2),CFrame.new(x+side*18,14,z-20),Color3.fromRGB(68,77,112),Enum.Material.Metal)
   ring(decor,"CollectorHalo",Vector3.new(x+side*18,26,z-20),5,accent,CFrame.Angles(math.pi/2,0,0))
  else
   -- Orbital reactor fragments: concentric rings surrounding a fractured energy core.
   local orb=piece(decor,"ReactorCore",Vector3.one*9,CFrame.new(x,23,z),accent,Enum.Material.Neon); orb.Shape=Enum.PartType.Ball
   ring(decor,"Containment",orb.Position,14,Color3.fromRGB(255,193,101),CFrame.Angles(.5,.3,0))
   local outer=ring(decor,"Orbit",orb.Position,18,accent,CFrame.Angles(1,.4,0)); outer:SetAttribute("SpinVisual",true); outer:SetAttribute("VisualCenter",orb.Position)
   for j=1,3 do piece(decor,"ReactorFragment",Vector3.new(8,4,6),CFrame.new(x+j*8-16,6-j*2,z+12)*CFrame.Angles(.2,j,.3),baseColors[level],Enum.Material.Metal) end
  end
 end
 task.wait()
end
world:SetAttribute("VisualVersion","Expedition_1")
local atmosphere=game.Lighting:FindFirstChildOfClass("Atmosphere"); if atmosphere then atmosphere.Density=.20; atmosphere.Haze=.6 end
return "Four world identities installed; route geometry unchanged."
