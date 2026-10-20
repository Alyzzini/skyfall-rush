-- Editable obstacle assemblies. Coins and gameplay triggers keep their own containers.
local Assemblies={}
local function model(parent,name,primary)
 local m=Instance.new("Model");m.Name=name;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;m.Parent=parent
 if primary then primary.Parent=m;m.PrimaryPart=primary end
 m:SetAttribute("ObstacleAssembly",true);return m
end
local function piece(parent,name,size,cf,color,collide)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=collide and Enum.Material.SmoothPlastic or Enum.Material.Neon
 p.Anchored=true;p.CanCollide=collide;p.CanTouch=collide;p.CanQuery=collide;p.CastShadow=false;p.Locked=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function smoothBalance(map,accent)
 local chains={}
 for _,p in map.Platforms:GetChildren() do local section=p.Name:match("^Balance_(%d+)_");if section then chains[section]=chains[section] or {};table.insert(chains[section],p) end end
 for section,beams in pairs(chains) do
  table.sort(beams,function(a,b)return a.Position.Z>b.Position.Z end)
  local points={};local width=beams[1].Size.X;local color=beams[1].Color
  for i,p in ipairs(beams) do
   local a=p.CFrame:PointToWorldSpace(Vector3.new(0,.5,-p.Size.Z/2));local b=p.CFrame:PointToWorldSpace(Vector3.new(0,.5,p.Size.Z/2))
   if a.Z<b.Z then a,b=b,a end
   if i==1 then table.insert(points,a) end;table.insert(points,b)
  end
  local lo,hi=points[#points].Z-8,points[1].Z+8
  for _,p in map.Decor:GetChildren() do if p.Name=="BalanceGuide" and p.Position.Z>lo and p.Position.Z<hi then p:Destroy() end end
  -- Remove the thin manual patch slivers on the damaged Ascent beam only.
  for _,p in map.Platforms:GetChildren() do if p:IsA("BasePart") and p.Name=="Part" and p.Position.Z>lo and p.Position.Z<hi and math.min(p.Size.X,p.Size.Y,p.Size.Z)<.1 then p:Destroy() end end
  local m=model(map.Platforms,"Balance_"..section.."_Rounded")
  local curve={points[1]}
  for i=2,#points-1 do
   local c=points[i];local radius=math.min(5,(points[i-1]-c).Magnitude*.22,(points[i+1]-c).Magnitude*.22)
   local a=c+(points[i-1]-c).Unit*radius;local b=c+(points[i+1]-c).Unit*radius
   table.insert(curve,a);for j=1,8 do local t=j/8;table.insert(curve,a*(1-t)^2+c*(2*t*(1-t))+b*t*t) end
  end
  table.insert(curve,points[#points])
  for i=1,#curve-1 do
   local a,b=curve[i],curve[i+1];local cf=CFrame.lookAt((a+b)/2+Vector3.new(0,.03,0),b+Vector3.new(0,.03,0))
   piece(m,string.format("Deck_%02d",i),Vector3.new(width,1,(b-a).Magnitude),cf*CFrame.new(0,-.5,0),color,true)
   piece(m,string.format("Guide_%02d",i),Vector3.new(.12,.04,(b-a).Magnitude+.04),cf*CFrame.new(0,.025,0),accent,false)
  end
  for i,p in ipairs(curve) do
   local join=piece(m,string.format("Turn_%02d",i),Vector3.new(1,width,width),CFrame.new(p+Vector3.new(0,-.47,0))*CFrame.Angles(0,0,math.pi/2),color,true);join.Shape=Enum.PartType.Cylinder
   local dot=piece(m,string.format("GuideJoin_%02d",i),Vector3.new(.04,.12,.12),CFrame.new(p+Vector3.new(0,.055,0))*CFrame.Angles(0,0,math.pi/2),accent,false);dot.Shape=Enum.PartType.Cylinder
  end
  m.PrimaryPart=m:FindFirstChild("Deck_01")
  for _,p in beams do p:Destroy() end
 end
end
function Assemblies.Apply(world)
 if world:GetAttribute("AssemblyVersion")~=1 then
  local config=require(game.ReplicatedStorage.SkyfallConfig)
  for level=1,4 do
   local map=world.Levels["Level"..level];local accent=config.Levels[level].Color
   smoothBalance(map,accent)
   for _,p in map.Decor:GetChildren() do if p.Name=="StepGuide" then p:Destroy() end end
   -- One pad = exactly five parts: original deck and four noncolliding trim walls.
   for _,p in map.Platforms:GetChildren() do
    if p:IsA("BasePart") and p.Name:match("^Step_%d+_%d+$") then
     local m=model(map.Platforms,p.Name.."_Pad",p)
     for _,side in {-1,1} do
      local rail=piece(m,side<0 and "OutlineLeft" or "OutlineRight",Vector3.new(.12,.18,p.Size.Z),p.CFrame*CFrame.new(side*(p.Size.X/2-.06),p.Size.Y/2+.025,0),accent,false);rail:SetAttribute("PadTrim",true)
      rail=piece(m,side<0 and "OutlineFront" or "OutlineBack",Vector3.new(p.Size.X-.24,.18,.12),p.CFrame*CFrame.new(0,p.Size.Y/2+.025,side*(p.Size.Z/2-.06)),accent,false);rail:SetAttribute("PadTrim",true)
     end
    end
   end
   -- Group the other surfaces per physical obstacle, with larger routes per section.
   local groups={}
   for _,p in map.Platforms:GetChildren() do if p:IsA("BasePart") then
    local section=p.Name:match("^Refined_(%d+)_")
    local key=section and ("Section_"..section.."_Obstacle") or (p.Name.."_Assembly")
    if not groups[key] then groups[key]=model(map.Platforms,key) end
    p.Parent=groups[key];if not groups[key].PrimaryPart then groups[key].PrimaryPart=p end
   end end
   -- Collapse the repeated gate clutter into one editable assembly at each position.
   local identity=map.Decor:FindFirstChild("WorldIdentity")
   if identity then local gates={};for _,p in identity:GetChildren() do
    if p:IsA("BasePart") and ({GatePillar=true,GateCrown=true,GateLight=true,Beacon=true})[p.Name] then
     local z=math.floor(p.Position.Z/96+.5)*96;local key="CheckpointArch_"..math.abs(z/96)
     gates[key]=gates[key] or model(identity,key);p.Parent=gates[key]
    end
   end end
   local loose={}
   for _,p in map.Decor:GetChildren() do if p:IsA("BasePart") and not p:FindFirstChildOfClass("ProximityPrompt") and not p:FindFirstChildOfClass("SurfaceGui") then
    local index=math.clamp(math.floor((-p.Position.Z+48)/96),0,8);local key="Section_"..index.."_Details"
    loose[key]=loose[key] or model(map.Decor,key);p.Parent=loose[key]
   end end
   task.wait()
  end
  world:SetAttribute("AssemblyVersion",1)
 end
 if world:GetAttribute("HazardAssemblyVersion")~=1 then
  for _,map in world.Levels:GetChildren() do
   local groups={}
   for _,p in map.Hazards:GetChildren() do if p:IsA("BasePart") and not p:GetAttribute("InvisibleFallCatcher") and p.Name~="FallCatcher" and p.Name~="Hurdle_Bottem" then
    local index=math.clamp(math.floor(-p.Position.Z/96)+1,1,8);local key="Section_"..index.."_Hazards"
    groups[key]=groups[key] or model(map.Hazards,key);p.Parent=groups[key]
   end end
  end
  world:SetAttribute("HazardAssemblyVersion",1)
 end
 -- Background and hidden infrastructure are protected; playable pieces stay editable.
 for _,map in world.Levels:GetChildren() do
  for _,p in map:GetDescendants() do if p:IsA("BasePart") then
   local background=p:IsDescendantOf(map.CourseSky) or (map.Decor:FindFirstChild("WorldIdentity") and p:IsDescendantOf(map.Decor.WorldIdentity))
   local hidden=p:GetAttribute("InvisibleFallCatcher") or p:IsDescendantOf(map.RouteGates) or p==map.StartPosition or p==map.PortalTrigger
   p.Locked=background or hidden or false
  end end
 end
 return "Obstacle Models organized; rounded balance decks; background protected."
end
return Assemblies
