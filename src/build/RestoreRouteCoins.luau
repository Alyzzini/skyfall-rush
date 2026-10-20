-- Restore missing collectibles and center them over real, reachable route surfaces.
local Coins={}
local function top(p)
 if p:IsA("Part") and p.Shape==Enum.PartType.Cylinder then
  return p.Position+Vector3.new(0,math.abs(p.CFrame.RightVector.Y)*p.Size.X/2,0)
 end
 return p.Position+p.CFrame.UpVector*p.Size.Y/2
end
function Coins.Apply(world)
 if world:GetAttribute("CoinLayoutVersion")==1 then return "Coin layout retained." end
 local config=require(game.ReplicatedStorage.SkyfallConfig);local report={}
 for level=1,4 do
  local map=world.Levels["Level"..level];local count=0
  -- Clear invalid, duplicate, and obsolete IDs before reconstructing the complete set.
  local byId={}
  for _,p in map.Orbs:GetChildren() do
   local id=p:IsA("BasePart") and p:GetAttribute("OrbId")
   if type(id)=="number" and id>=1 and id<=24 and id%1==0 and not byId[id] then byId[id]=p else p:Destroy() end
  end
  local platforms={};local hazards={}
  for _,p in map.Platforms:GetDescendants() do if p:IsA("BasePart") and p.CanCollide and not p:GetAttribute("PermanentRest") and not p.Name:match("^Hub_") and not p.Name:find("MazeWall") and not p.Name:find("SlalomWall") then table.insert(platforms,p) end end
  for _,p in map.Hazards:GetDescendants() do if p:IsA("BasePart") and not p:GetAttribute("InvisibleFallCatcher") then table.insert(hazards,p) end end
  for section=1,8 do
   local z=-(section-1)*96;local steps={};local moving={};local candidates={}
   for _,p in platforms do
    if p.Name:match("^Step_"..(section-1).."_") or p.Name:match("^Refined_"..section.."_Boulder") then table.insert(steps,p)
    elseif p.Position.Z<z-10 and p.Position.Z>z-87 then
     if p:GetAttribute("Moving") then table.insert(moving,p) end
     table.insert(candidates,p)
    end
   end
   table.sort(steps,function(a,b)return a.Position.Z>b.Position.Z end)
   table.sort(moving,function(a,b)return a.Position.Z>b.Position.Z end)
   local used={}
   local gate=map.RouteGates:FindFirstChild("Gate_"..section)
   local encoded=gate and gate:GetAttribute("TraversalPath")
   local route=encoded and game.HttpService:JSONDecode(encoded)
   for j=1,3 do
    local source;local point
    if #steps>=6 then source=steps[j*2];point=top(source)
    elseif #moving>=3 then source=moving[j];point=top(source)
    else
     local targetZ=z-20-j*17;local best=math.huge
     local targetX=config.Levels[level].X
     if route then for i=1,#route-1 do
      local a,b=route[i],route[i+1]
      if targetZ<=a[3] and targetZ>=b[3] and math.abs(b[3]-a[3])>.01 then
       targetX=a[1]+(b[1]-a[1])*((targetZ-a[3])/(b[3]-a[3]));break
      end
     end end
     -- Evaluate points on the actual deck, not the straight line between its hubs.
     for _,p in candidates do
      for _,offset in {0,-.28,.28,99} do
       local goal=p.CFrame:PointToObjectSpace(Vector3.new(targetX,p.Position.Y,targetZ))
       local localPoint=offset==99 and Vector3.new(math.clamp(goal.X,-p.Size.X/2+.4,p.Size.X/2-.4),p.Size.Y/2,math.clamp(goal.Z,-p.Size.Z/2+.4,p.Size.Z/2-.4)) or Vector3.new(0,p.Size.Y/2,offset*p.Size.Z)
       local q=p.CFrame:PointToWorldSpace(localPoint)
       if p:IsA("Part") and (p.Shape==Enum.PartType.Cylinder or p.Shape==Enum.PartType.Ball) then q=top(p) end
       if q.Z>z-12 or q.Z<z-86 then continue end
       local score=math.abs(q.Z-targetZ)+math.abs(q.X-targetX)*.6
       for _,previous in used do if (q-previous).Magnitude<12 then score+=100 end end
       for _,h in hazards do
        local delta=Vector3.new(q.X-h.Position.X,0,q.Z-h.Position.Z)
        if h:GetAttribute("Kind")=="Spin" and delta.Magnitude<5 then score+=50
        elseif h:GetAttribute("Kind")=="Static" and math.abs(delta.Z)<3 and math.abs(delta.X)<h.Size.X/2+1 then score+=40 end
       end
       if score<best then best=score;source=p;point=q end
      end
     end
    end
    assert(source and point,"No coin landing found: "..map.Name.." section "..section)
    table.insert(used,point)
    local id=(section-1)*3+j;local p=byId[id] or Instance.new("Part");p.Name="Orb_"..id
    p.Shape=Enum.PartType.Ball;p.Size=Vector3.one*1.2;p.Position=point+Vector3.new(0,2.6,0);p.Color=Color3.fromRGB(255,221,72);p.Material=Enum.Material.Neon
    p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Locked=false;p.Transparency=0
    p:SetAttribute("OrbId",id);p:SetAttribute("Section",section);p:SetAttribute("FollowPlatform",nil);p:SetAttribute("FollowOffset",nil)
    if source:GetAttribute("Moving") then p:SetAttribute("FollowPlatform",source.Name);p:SetAttribute("FollowOffset",p.Position-source.Position) end
    p.Parent=map.Orbs;count+=1
   end
  end
  map:SetAttribute("TotalOrbs",count);table.insert(report,{Level=level,Coins=count});task.wait()
 end
 world:SetAttribute("CoinLayoutVersion",1);return report
end
return Coins
