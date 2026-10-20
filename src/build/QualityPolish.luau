-- Additive dressing and navigation. Original decks, hazards and route geometry stay in place.
local Q={}
local V=Vector3.new
local dark=Color3.fromRGB(20,30,46)
local function part(parent,name,size,cf,color,neon)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Locked=true;p.Color=color;p.Material=neon and Enum.Material.Neon or Enum.Material.SmoothPlastic;p.Parent=parent;return p
end
local function frame(parent,gate,color)
 local cf=gate.CFrame;local width=gate.Size.X+3;local height=12
 for _,s in {-1,1} do
  part(parent,"PortalPillar",V(.7,height,.7),cf*CFrame.new(s*width/2,1,0),dark)
  part(parent,"PortalLight",V(.1,height-.8,.12),cf*CFrame.new(s*width/2,1,-.39),color,true)
 end
 part(parent,"PortalCrown",V(width+.7,.7,.7),cf*CFrame.new(0,7,0),dark)
 part(parent,"PortalCrownLight",V(width,.1,.12),cf*CFrame.new(0,7,-.39),color,true)
end
function Q.Apply()
 local config=require(game.ReplicatedStorage.SkyfallConfig)
 local report={}
 for index=1,#config.Levels do
  local map=workspace.SkyfallSprint.Levels["Level"..index]
  if map:GetAttribute("QualityPolishVersion")==1 then continue end
  local accent=config.Levels[index].Color
  local root=Instance.new("Model");root.Name="QualityDetails";root.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;root.Parent=map.Decor
  local hubs={};local surfaces={}
  for _,p in map.Platforms:GetDescendants() do if p:IsA("BasePart") then
   local n=p.Name:match("^Hub_(%d+)$") or p.Name:match("^Milestone(%d+)_")
   if n then hubs[tonumber(n)]=p end
   if p.CanCollide then table.insert(surfaces,p) end
   -- Wall panels receive matching cap seams without changing their shape or collision.
   if p.Name:match("Wall") or p.Name=="MachineHousing" or p.Name=="UpperGuard" or p.Name:match("BookStack") or p.Name=="Sorter" then
    if p.Size.Y>=5 and math.min(p.Size.X,p.Size.Z)<2.1 then
     for _,side in {-1,1} do
      local size,offset
      if p.Size.X<p.Size.Z then size=V(.07,.1,math.max(.2,p.Size.Z-.3));offset=V(side*(p.Size.X/2+.04),p.Size.Y*.3,0)
      else size=V(math.max(.2,p.Size.X-.3),.1,.07);offset=V(0,p.Size.Y*.3,side*(p.Size.Z/2+.04)) end
      part(root,"PanelSeam",size,p.CFrame*CFrame.new(offset),accent:Lerp(dark,.25),true)
     end
    end
   end
   -- Personal crumble behavior retains each obstacle's original delay.
   if p:GetAttribute("Crumble") or p:GetAttribute("ExpansionCollapse") then p:SetAttribute("PersonalCrumble",true) end
  end end
  -- A consistent small chevron on safe hubs indicates the next turn, never the shortcut.
  for n=0,7 do
   local p,nextHub=hubs[n],hubs[n+1]
   if p and nextHub then
    local a=p.Position+Vector3.yAxis*(p.Size.Y/2+.1);local target=V(nextHub.Position.X,a.Y,nextHub.Position.Z)
    if (target-a).Magnitude>.1 then local cf=CFrame.lookAt(a,target)*CFrame.new(0,0,-3)
     for _,side in {-1,1} do part(root,"RouteChevron",V(.1,.045,1.5),cf*CFrame.new(side*.4,0,.35)*CFrame.Angles(0,side*.6,0),accent,true) end
    end
   end
  end
  if index>=5 then frame(root,map.StartGate,Color3.fromRGB(65,216,255));frame(root,map.PortalTrigger,accent) end
  -- Finish the distant silhouettes with anchored caps rather than scattering more objects.
  local room=map:FindFirstChild("CourseSky")
  if room then for _,p in room:GetDescendants() do if p:IsA("BasePart") and (p.Name=="DistantSpire" or p.Name=="DistantStructure") then
   local crown=part(room,"SpireCrown",V(p.Size.X+1,.8,p.Size.Z+1),p.CFrame*CFrame.new(0,p.Size.Y/2+.4,0),dark)
   if index==6 then crown.CFrame*=CFrame.Angles(0,math.pi/4,0);crown.Color=accent:Lerp(dark,.55)
   elseif index==8 or index==12 then crown.Shape=Enum.PartType.Cylinder;crown.Size=V(.8,p.Size.X+2,p.Size.X+2);crown.CFrame*=CFrame.Angles(0,0,math.pi/2)
   elseif index==7 or index==11 then for k=1,3 do part(room,"SpireSignal",V(1,2,.15),p.CFrame*CFrame.new((k-2)*2,p.Size.Y*.35,-p.Size.Z/2-.1),k==1 and Color3.fromRGB(85,235,178) or k==2 and Color3.fromRGB(255,202,79) or Color3.fromRGB(255,85,109),true) end end
   part(room,"SpireBand",V(p.Size.X+.05,.15,p.Size.Z+.05),p.CFrame*CFrame.new(0,p.Size.Y*.24,0),accent,true)
  end end end
  -- Machinery, archive, clockwork and reactor details use different silhouettes.
  for n=2,6,2 do local hub=hubs[n]
   if hub and index>=5 then
    local pos=hub.Position+V(hub.Size.X/2+5,-2,0)
    -- Attach to an existing milestone; keep all dressing below the playable deck.
    if index==5 or index==9 then
     part(root,"BearingHousing",V(4,3,5),CFrame.new(pos),dark)
     local p=part(root,"BearingFace",V(.3,2.4,2.4),CFrame.new(pos+V(2.2,0,0)),accent);p.Shape=Enum.PartType.Cylinder
    elseif index==6 then
     for k=1,3 do part(root,"ArchiveVolume",V(.8,2+k*.3,3),CFrame.new(pos+V(k-2,0,0)),accent:Lerp(dark,k*.18)) end
    elseif index==7 or index==11 then
     local cf=CFrame.new(pos);part(root,"ClockHousing",V(4,3,.6),cf,dark)
     for k=1,3 do part(root,"ClockSignal",V(.55,1,.1),cf*CFrame.new(k-2,0,-.36),k==1 and Color3.fromRGB(85,235,178) or k==2 and Color3.fromRGB(255,202,79) or Color3.fromRGB(255,85,109),true) end
    elseif index==8 or index==12 then
     part(root,"ReactorHousing",V(4,3,4),CFrame.new(pos),dark)
     part(root,"ReactorSlit",V(.14,2.2,2.7),CFrame.new(pos+V(2.05,0,0)),accent,true)
    end
   end
  end
  -- All explanatory signs fade before neighboring rooms become a wall of text.
  for _,gui in map.Decor:GetDescendants() do if gui:IsA("BillboardGui") then
   gui.AlwaysOnTop=false
   if gui.Parent.Name=="Instruction" or gui.Parent.Name=="Wayfinding" or gui.Parent.Name=="SectionLabel" then gui.MaxDistance=42 end
  end end
  -- Repair coins authored between the two optional branches in Cloudspire.
  if index==10 then for id=19,21 do
   local orb=map.Orbs:FindFirstChild("Orb_"..id);local best;local distance=math.huge
   for _,p in surfaces do if p.Name:match("BranchClimb") then local d=(p.Position-orb.Position).Magnitude;if d<distance then best=p;distance=d end end end
   if best then orb.Position=best.Position+V(0,best.Size.Y/2+2.6,0) end
  end end
  map:SetAttribute("QualityPolishVersion",1)
  table.insert(report,{Level=index,DecorParts=#root:GetDescendants()})
  task.wait()
 end
 return report
end
return Q
