-- Re-author every route check against its saved landing hubs and collectible route.
local Registration={}
local function trigger(parent,name,size,position)
 local p=parent:FindFirstChild(name) or Instance.new("Part");p.Name=name;p.Size=size;p.Position=position
 p.Anchored=true;p.Transparency=1;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Locked=true;p.Parent=parent;return p
end
function Registration.Apply(world)
 if world:GetAttribute("RouteRegistrationVersion")==1 then return "Landing-aligned routes retained." end
 local config=require(game.ReplicatedStorage.SkyfallConfig);local report={}
 for level=1,4 do
  local map=world.Levels["Level"..level];local count=0
  for section=1,config.Levels[level].Sections do
   local hub=map.Platforms:FindFirstChild("Hub_"..section,true)
   assert(hub and hub:IsA("BasePart"),"Missing landing hub "..map.Name.." / "..section)
   local top=hub.Position+Vector3.new(0,hub.Size.Y/2,0)
   local gate=trigger(map.RouteGates,"Gate_"..section,Vector3.new(hub.Size.X+2,24,hub.Size.Z+2),top+Vector3.new(0,7,0))
   gate:SetAttribute("Section",section)
   for _,child in gate:GetChildren() do if child.Name:match("^Node_") then child:Destroy() end end
   -- Existing coins have been aligned to real surfaces, including moving decks.
   for index=1,3 do
    local orb=map.Orbs:FindFirstChild("Orb_"..((section-1)*3+index))
    assert(orb and orb:IsA("BasePart"),"Missing route anchor coin")
    local node=trigger(gate,"Node_"..index,Vector3.new(16,24,14),orb.Position+Vector3.new(0,2,0))
    local following=orb:GetAttribute("FollowPlatform")
    if following then
     local platform=map.Platforms:FindFirstChild(following,true)
     if platform then node:SetAttribute("FollowPlatform",following);node:SetAttribute("FollowOffset",node.Position-platform.Position) end
    end
   end
   if section%config.CheckpointEvery==0 and section<config.Levels[level].Sections then
    local stage=section/config.CheckpointEvery
    local cp=map.Checkpoints:FindFirstChild("Checkpoint_"..stage) or Instance.new("Part")
    cp.Name="Checkpoint_"..stage;cp.Size=Vector3.new(12,.2,8);cp.Position=top+Vector3.new(0,.12,0)
    cp.Anchored=true;cp.CanCollide=false;cp.CanTouch=false;cp.CanQuery=false;cp.Locked=false;cp.Transparency=.12
    cp.Material=Enum.Material.Neon;cp.Color=Color3.fromRGB(100,245,167);cp:SetAttribute("Stage",stage);cp:SetAttribute("Section",section);cp.Parent=map.Checkpoints
    trigger(cp,"ArrivalZone",Vector3.new(hub.Size.X+2,24,hub.Size.Z+2),top+Vector3.new(0,7,0));count+=1
   end
  end
  map:SetAttribute("CheckpointCount",count);table.insert(report,{Level=level,Sections=8,Checkpoints=count});task.wait()
 end
 world:SetAttribute("RouteRegistrationVersion",1);return report
end
return Registration
