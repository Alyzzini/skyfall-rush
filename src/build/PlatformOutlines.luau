-- Draw only exposed deck edges, including curves and their full approaches.
local Outlines={}
local width=.14
local function rail(parent,a,b,color)
 if (b-a).Magnitude<.025 then return end
 local p=Instance.new("Part");p.Name="PerimeterOutline";p.Size=Vector3.new(width,.07,(b-a).Magnitude+.06)
 p.CFrame=CFrame.lookAt((a+b)/2,b);p.Color=color;p.Material=Enum.Material.Neon;p.Anchored=true
 p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Locked=false;p.Parent=parent
end
local function contains(p,point)
 local v=p.CFrame:PointToObjectSpace(point);local half=p.Size/2
 if p:IsA("Part") and p.Shape==Enum.PartType.Cylinder then
  return math.abs(v.X)<half.X+.18 and (v.Y/half.Y)^2+(v.Z/half.Z)^2<1.001
 end
 return math.abs(v.X)<half.X+.015 and math.abs(v.Z)<half.Z+.015 and math.abs(v.Y-half.Y)<.35
end
function Outlines.Apply(world)
 if world:GetAttribute("OutlineVersion")==1 then return "Complete outlines retained." end
 local config=require(game.ReplicatedStorage.SkyfallConfig);local total=0
 for level=1,4 do
  local map=world.Levels["Level"..level];local color=config.Levels[level].Color;local surfaces={}
  for _,p in map.Platforms:GetDescendants() do
   if p:IsA("BasePart") and p.CanCollide and not p:GetAttribute("InvisibleFallCatcher") then table.insert(surfaces,p) end
  end
  for _,p in map.Decor:GetDescendants() do if p:IsA("BasePart") and (p.Name=="HubEdge" or p.Name=="LandingGuide") then p:Destroy() end end
  for index,p in ipairs(surfaces) do
   -- Existing five-part pad Models already have all four borders.
   if p.Name:match("^Step_%d+_%d+$") then continue end
   local old=p:FindFirstChild("OutlineDetails");if old then old:Destroy() end
   local details=Instance.new("Folder");details.Name="OutlineDetails";details.Parent=p
   if p:IsA("Part") and p.Shape==Enum.PartType.Ball then
    local h=Instance.new("Highlight");h.Name="BallOutline";h.Adornee=p;h.FillTransparency=1;h.OutlineColor=color;h.OutlineTransparency=.12;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=details
   else
    local neighbors={}
    for _,other in surfaces do if other~=p and (other.Position-p.Position).Magnitude<(other.Size.Magnitude+p.Size.Magnitude)/2+2 then table.insert(neighbors,other) end end
    local function edge(a,b,outward)
     local count=math.max(1,math.ceil((b-a).Magnitude/.7));local start
     for j=1,count do
      local mid=a:Lerp(b,(j-.5)/count)+outward*.13;local hidden=false
      for _,other in neighbors do if contains(other,mid) then hidden=true;break end end
      if not hidden and not start then start=a:Lerp(b,(j-1)/count) end
      if start and (hidden or j==count) then
       local finish=a:Lerp(b,hidden and (j-1)/count or 1)
       rail(details,start,finish,color);total+=1;start=nil
      end
     end
    end
    if p:IsA("Part") and p.Shape==Enum.PartType.Cylinder then
     -- Cylinder joins lie with local X along the deck's surface normal.
     local normal=p.CFrame.RightVector;local side=normal.Y>=0 and 1 or -1
     local last
     for j=0,32 do
      local angle=j*math.pi/16;local point=p.CFrame:PointToWorldSpace(Vector3.new(side*(p.Size.X/2+.045),math.cos(angle)*p.Size.Y/2,math.sin(angle)*p.Size.Z/2))
      if last then local center=p.Position+normal*side*p.Size.X/2;edge(last,point,((last+point)/2-center).Unit) end;last=point
     end
    else
     local x,z=p.Size.X/2,p.Size.Z/2;local y=p.Size.Y/2+.045
     local corners={Vector3.new(-x,y,-z),Vector3.new(x,y,-z),Vector3.new(x,y,z),Vector3.new(-x,y,z)}
     local dirs={-p.CFrame.LookVector,p.CFrame.RightVector,p.CFrame.LookVector,-p.CFrame.RightVector}
     -- Local -Z is LookVector; choose the outward direction for each edge.
     dirs={p.CFrame.LookVector,p.CFrame.RightVector,-p.CFrame.LookVector,-p.CFrame.RightVector}
     for j=1,4 do edge(p.CFrame:PointToWorldSpace(corners[j]),p.CFrame:PointToWorldSpace(corners[j%4+1]),dirs[j]) end
    end
   end
   if index%35==0 then task.wait() end
  end
  task.wait()
 end
 world:SetAttribute("OutlineVersion",1)
 return "Completed exposed platform borders: "..total.." outline segments."
end
return Outlines
