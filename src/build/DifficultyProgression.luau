-- One-time authored progression. Preserve later manual edits until this version changes.
local Progression={}
local function outlinePad(p,color)
 local m=p.Parent
 for _,side in {-1,1} do
  for _,axis in {"X","Z"} do
   local name=axis=="X" and (side<0 and "OutlineLeft" or "OutlineRight") or (side<0 and "OutlineFront" or "OutlineBack")
   local edge=m:FindFirstChild(name)
   if edge then
    edge.Size=axis=="X" and Vector3.new(.12,.18,p.Size.Z) or Vector3.new(p.Size.X-.24,.18,.12)
    edge.CFrame=p.CFrame*CFrame.new(axis=="X" and side*(p.Size.X/2-.06) or 0,p.Size.Y/2+.025,axis=="Z" and side*(p.Size.Z/2-.06) or 0)
    edge.Color=color
   end
  end
 end
end
function Progression.Apply(world)
 if world:GetAttribute("DifficultyVersion")==1 then return "Difficulty progression retained." end
 local config=require(game.ReplicatedStorage.SkyfallConfig);local report={}
 for level=1,4 do
  local map=world.Levels["Level"..level];local size=12-level*2;local color=config.Levels[level].Color;local pads=0;local spinners=0
  for _,p in map.Platforms:GetDescendants() do if p:IsA("BasePart") then
   if p.Name:match("^Step_%d+_%d+$") then
    -- Keep twelve-stud center spacing: the gaps grow naturally from 2 to 8 studs.
    p.Size=Vector3.new(size,2,size);outlinePad(p,color);pads+=1
    if p:GetAttribute("Crumble") then p:SetAttribute("FallDelay",1.25-level*.15) end
    if p:GetAttribute("PhasePlatform") then p:SetAttribute("SolidTime",3.9-level*.35) end
   elseif p:GetAttribute("Moving") or p.Name:match("^Ferry_") then
    -- Narrow machinery landings across the route while retaining boarding length.
    p.Size=Vector3.new(size,p.Size.Y,p.Size.Z)
   elseif p.Name:match("^Refined_%d+_Ramp$") then p.Size=Vector3.new(size,p.Size.Y,p.Size.Z)
   elseif p.Name:match("^Refined_%d+_RoundJoin$") then p.Size=Vector3.new(p.Size.X,size,size)
   elseif p.Name:match("^Deck_%d+$") then p.Size=Vector3.new(size*.5,p.Size.Y,p.Size.Z)
   elseif p.Name:match("^Turn_%d+$") then p.Size=Vector3.new(p.Size.X,size*.5,size*.5) end
  end end
  -- Bends are based on the route control points, not every tiny smoothing segment.
  if level>=2 then
   local folder=map.Hazards:FindFirstChild("BendSweepers") or Instance.new("Model");folder.Name="BendSweepers";folder.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;folder.Parent=map.Hazards
   local routes={ArchCrossing=true,TerraceClimb=true,WindSwitchback=true,Orbit=true,Finale=true,Switchback=true,Balance=true}
   for section,pattern in ipairs(config.Levels[level].Patterns) do if routes[pattern] then
    local gate=map.RouteGates:FindFirstChild("Gate_"..section);local encoded=gate and gate:GetAttribute("TraversalPath");local points
    if encoded then points=game.HttpService:JSONDecode(encoded) end
    if pattern=="Balance" then
     local z=-(section-1)*96;local x=config.Levels[level].X
     points={{x,23,z-8},{x+6,23,z-30},{x-6,23,z-56},{x,23,z-88}}
    end
    if points then
     local placed={}
     for i=2,#points-1 do
      local a,b,c=Vector3.new(unpack(points[i-1],1,3)),Vector3.new(unpack(points[i],1,3)),Vector3.new(unpack(points[i+1],1,3))
      local before=Vector3.new(b.X-a.X,0,b.Z-a.Z);local after=Vector3.new(c.X-b.X,0,c.Z-b.Z)
      if before.Magnitude<1 or after.Magnitude<1 or before.Unit:Dot(after.Unit)>.98 then continue end
      local center=b-Vector3.new(0,3,0);local nearest;local distance=math.huge
      for _,p in map.Platforms:GetDescendants() do if p:IsA("BasePart") and (p.Name:match("^Refined_"..section.."_RoundJoin$") or pattern=="Balance" and p.Name:match("^Turn_%d+$")) then
       local d=(Vector3.new(p.Position.X,0,p.Position.Z)-Vector3.new(center.X,0,center.Z)).Magnitude
       if d<distance then distance=d;nearest=p end
      end end
      if nearest then
       local normal=nearest.CFrame.RightVector;if normal.Y<0 then normal=-normal end
       center=nearest.Position+normal*nearest.Size.X/2
      end
      local tooClose=false;for _,v in placed do if (v-center).Magnitude<12 then tooClose=true end end;if tooClose then continue end
      table.insert(placed,center)
      local p=Instance.new("Part");p.Name=string.format("BendSweeper_%02d_%02d",section,#placed)
      p.Size=Vector3.new((pattern=="Balance" and size*.5 or size)+4,.8,.8);p.CFrame=CFrame.new(center+Vector3.new(0,1,0))*CFrame.Angles(0,#placed*.65,0)
      p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Color=Color3.fromRGB(255,88,91);p.Material=Enum.Material.Neon
      p:SetAttribute("Kind","Spin");p:SetAttribute("Speed",(.65+(level-2)*.25)*(#placed%2==0 and -1 or 1));p:SetAttribute("Phase",#placed*.8);p:SetAttribute("AlwaysAnimate",true);p.Parent=folder;spinners+=1
     end
    end
   end end
  end
  table.insert(report,{Level=level,PadSize=size,JumpPads=pads,BendSweepers=spinners});task.wait()
 end
 -- Rebuild exposed edges after resizing; existing five-part pad trim was resized above.
 world:SetAttribute("OutlineVersion",nil);world:SetAttribute("DifficultyVersion",1)
 return report
end
return Progression
