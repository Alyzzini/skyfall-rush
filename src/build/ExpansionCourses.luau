-- Additive authoring only. This module never accesses the contents of Levels 1-4.
local Expansion={}
local V=Vector3.new
local dark=Color3.fromRGB(24,35,53)
local red=Color3.fromRGB(255,83,105)
local gold=Color3.fromRGB(255,218,107)
local definitions={
 [5]={"Relay","Pistons","Lift","Press","Belt","Swing","Stairs","DockRun"},
 [6]={"Gallery","Switch","Ledges","Shutters","GalleryReverse","Descent","SwitchBelt","ArchiveExit"},
 [7]={"Pulse","Wave","LiftLaser","Collapse","Crossfire","SwingSteps","PulseBelt","ClockExit"},
 [8]={"RelayLaser","SwitchPulse","LiftPress","LedgesPulse","CollapseBelt","CrossfireSteps","DescentPulse","FinalRun"},
}
local tips={Relay="RELAY DOCK / ride the moving decks",Pistons="PISTON WALK / wait in the side bays",Lift="FREIGHT LIFT / ride to the upper dock",Press="PRESS ROOM / amber warns, green opens",Belt="SORTING BELT / steer against the arrows",Swing="PENDULUM BAY / cross behind each hammer",Stairs="SERVICE TOWER / climb the outside ledges",DockRun="SHIFT CHANGE / belts and presses together",Gallery="PRISM GALLERY / follow the diamond windows",Switch="POWER BRIDGE / hold the switch, then cross",Ledges="ARCHIVE EXTERIOR / wrap around the stacks",Shutters="READING ROOM / doors open in sequence",GalleryReverse="MIRROR GALLERY / read the route before entering",Descent="LOWER VAULT / descend the marked balconies",SwitchBelt="DELIVERY ROUTE / power the bridge against the belt",ArchiveExit="EXIT GALLERY / shutters guard the last turn",Pulse="PULSE SCHOOL / green is safe, amber warns",Wave="WAVE WALK / follow behind the red pulse",LiftLaser="LASER LIFT / leave when the upper gate opens",Collapse="AFTERIMAGE / amber tiles recover after you pass",Crossfire="CROSSFIRE / use the safe bays between beams",SwingSteps="PENDULUM STAIRS / time each landing",PulseBelt="CURRENT RUN / move against the belt between pulses",ClockExit="CLOCK EXIT / read both gates from the safe bay",RelayLaser="TRANSFER ARRAY / moving decks meet timed gates",SwitchPulse="POWER CIRCUIT / bridge and laser sequence",LiftPress="REACTOR LIFT / wait for the upper press",LedgesPulse="REACTOR EXTERIOR / timing on the balconies",CollapseBelt="EVACUATION / keep moving, rest at the blue island",CrossfireSteps="SIGNAL STAIRS / climb between laser pulses",DescentPulse="CORE DESCENT / look before each drop",FinalRun="CONVERGENCE / belt, hammer and final pulse"}
local function part(parent,name,size,cf,color,solid)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or dark;p.Anchored=true;p.Material=Enum.Material.SmoothPlastic;p.CanCollide=solid~=false;p.CanTouch=true;p.CastShadow=solid~=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function attributes(obj,t) for k,v in pairs(t) do obj:SetAttribute(k,v) end return obj end
local function hidden(parent,name,size,cf) local p=part(parent,name,size,cf,nil,false);p.Transparency=1;p.CanQuery=false;p.Locked=true;return p end
local function sign(parent,words,position,color)
 local p=hidden(parent,"Instruction",V(.1,.1,.1),CFrame.new(position));local gui=Instance.new("BillboardGui");gui.Size=UDim2.fromOffset(400,54);gui.MaxDistance=65;gui.StudsOffsetWorldSpace=V(0,3,0);gui.Parent=p
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundColor3=dark;t.BackgroundTransparency=.15;t.TextColor3=color;t.Text=words;t.TextWrapped=true;t.TextSize=16;t.Font=Enum.Font.GothamBold;t.Parent=gui;Instance.new("UICorner",t)
end
function Expansion.Build(index)
 assert(index>=5 and index<=8,"Only expansion levels may be authored")
 local world=workspace.SkyfallSprint;local levels=world.Levels
 if levels:FindFirstChild("Level"..index) then return levels["Level"..index] end
 local spec=require(game.ReplicatedStorage.SkyfallConfig).Levels[index];local accent=spec.Color
 local map=Instance.new("Folder");map.Name="Level"..index
 for _,name in {"Platforms","Hazards","Orbs","Checkpoints","RouteGates","Decor","TestRoute"} do Instance.new("Folder",map).Name=name end
 attributes(map,{Number=index,Title=spec.Title,Sections=8,CheckpointCount=7,TotalOrbs=24,CourseLength=448,ExpansionVersion=1,CourseCenterX=spec.X})
 local elevations=index==5 and {24,24,24,36,36,36,36,48,48} or index==6 and {24,24,24,36,36,36,24,24,24} or index==7 and {24,24,24,36,36,36,48,48,48} or {24,24,24,36,48,48,60,48,48}
 local layouts={
 [5]={{0,0},{0,-56},{56,-56},{112,-56},{112,-112},{56,-112},{0,-112},{0,-168},{56,-168}},
 [6]={{0,0},{0,-56},{56,-56},{56,-112},{112,-112},{112,-168},{56,-168},{0,-168},{0,-224}},
 [7]={{0,0},{0,-56},{56,-56},{56,0},{112,0},{112,-56},{112,-112},{56,-112},{0,-112}},
 [8]={{0,0},{0,-56},{-56,-56},{-56,-112},{0,-112},{0,-168},{56,-168},{56,-224},{0,-224}},
 };local coords=layouts[index]
 local hubs={};for n,c in ipairs(coords) do hubs[n]=V(spec.X+c[1],elevations[n],c[2]) end
 local function deck(parent,name,size,cf,color)
  local model=Instance.new("Model");model.Name=name.."Assembly";model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;model.Parent=parent
  local p=part(model,name,size,cf,color or accent:Lerp(dark,.65));model.PrimaryPart=p
  local edges=Instance.new("Folder",p);edges.Name="OutlineDetails"
  for _,s in {-1,1} do
   local a=part(edges,"Side",V(.12,.08,size.Z),cf*CFrame.new(s*(size.X/2-.06),size.Y/2+.04,0),accent,false);a.Material=Enum.Material.Neon;a.CanQuery=false
   local b=part(edges,"End",V(size.X,.08,.12),cf*CFrame.new(0,size.Y/2+.04,s*(size.Z/2-.06)),accent,false);b.Material=Enum.Material.Neon;b.CanQuery=false
  end
  return p
 end
 for n,pos in ipairs(hubs) do
  deck(map.Platforms,"Hub_"..(n-1),V(16,2,16),CFrame.new(pos-V(0,1,0)))
  if n>1 then
   local g=hidden(map.RouteGates,"Gate_"..(n-1),V(16,14,16),CFrame.new(pos+V(0,6,0)));g:SetAttribute("Section",n-1)
   if n<9 then
    local cp=part(map.Checkpoints,"Checkpoint_"..(n-1),V(10,.15,8),CFrame.new(pos+V(0,.1,0)),Color3.fromRGB(85,245,176),false);cp.Material=Enum.Material.Neon;attributes(cp,{Section=n-1,Stage=n-1})
    hidden(cp,"ArrivalZone",V(16,14,16),CFrame.new(pos+V(0,6,0)))
   end
  end
 end
 hidden(map,"StartPosition",Vector3.one,CFrame.new(hubs[1]+V(0,3.5,4)))
 local start=part(map,"StartGate",V(15,10,.2),CFrame.new(hubs[1]+V(0,5,-6)),Color3.fromRGB(60,240,255),false);start.Transparency=.8;start.Material=Enum.Material.Neon
 part(map,"StartLine",V(15,.1,.3),CFrame.new(hubs[1]+V(0,.1,-6)),accent,false)
 hidden(map,"PortalTrigger",V(10,12,2),CFrame.new(hubs[9]+V(0,5,0)))
 sign(map.Decor,string.upper(spec.Title).." / FINISH",hubs[9]+V(0,6,0),accent)
 sign(map.Decor,string.upper(spec.Title).." / CROSS BLUE TO START",hubs[1]+V(0,8,0),accent)
 local routeIndex=0
 for section,kind in ipairs(definitions[index]) do
  local a,b=hubs[section],hubs[section+1];local flat=V(b.X,a.Y,b.Z);local cf=CFrame.lookAt(a,flat);local rise=b.Y-a.Y
  local assembly=Instance.new("Model");assembly.Name=string.format("%02d_%s",section,kind);assembly.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;assembly.Parent=map.Platforms
  local function point(x,y,t) return cf:PointToWorldSpace(V(x,y,-t)) end
  local function localcf(x,y,t) return cf*CFrame.new(x,y,-t) end
  local function floor(name,x,t,width,length,y)
   return deck(assembly,name.."_"..section,V(width,1,length),localcf(x,(y or 0)-.5,t))
  end
  local function nav(x,y,t,mode,follow)
   routeIndex+=1;local n=hidden(map.TestRoute,string.format("%03d",routeIndex),Vector3.one,CFrame.new(point(x,y+3,t)));attributes(n,{Section=section,Mode=mode or "Walk"});if follow then n:SetAttribute("Follow",follow.Name) end;return n
  end
  local function danger(name,x,y,t,size,mechanic,offset)
   local h=part(map.Hazards,name.."_"..section,size,localcf(x,y,t),red,false);h.Material=Enum.Material.Neon;attributes(h,{ExpansionMechanic=mechanic,Period=index==8 and 3.8 or index==7 and 4.4 or 5,OpenTime=index>=7 and 2.2 or 2.8,Phase=offset or 0,Axis=cf.RightVector,Section=section})
   if mechanic=="Pendulum" then
    h.Shape=Enum.PartType.Ball;h.Size=V(4,4,4)
    local pivot=part(map.Decor,"HammerPivot",V(1,1,1),localcf(x,y+7,t),accent,false);local a0=Instance.new("Attachment",pivot);local a1=Instance.new("Attachment",h);local rope=Instance.new("Beam",pivot);rope.Attachment0=a0;rope.Attachment1=a1;rope.Width0=.25;rope.Width1=.25;rope.Color=ColorSequence.new(accent);rope.FaceCamera=true
   end
   return h
  end
  local function pulse(t,offset,y) return danger("PulseGate",0,(y or 0)+4,t,V(12,8,.5),"Pulse",offset) end
  local function path(y) return floor("Walkway",0,28,12,40,y or 0) end
  local function rails(y)
   for _,side in {-1,1} do local wall=part(assembly,"GuardWall",V(.6,10,40),localcf(side*6.5,(y or 0)+5,28),accent:Lerp(dark,.8));wall.Transparency=.25 end
  end
  sign(map.Decor,string.format("%02d / %s",section,tips[kind]),point(0,7,6),accent)
  local points={}
  if kind=="Relay" or kind=="RelayLaser" then
   for j=1,4 do local t=12+(j-1)*10;local p=floor("Transfer"..j,0,t,10,8,0);attributes(p,{Moving=true,Speed=.85,Phase=j*1.4,Amplitude=1.4,MotionAxis=cf.RightVector});nav(0,0,t,"Jump",p);table.insert(points,point(0,0,t)) end
   if kind=="RelayLaser" then pulse(27,0) end
  elseif kind=="Lift" or kind=="LiftLaser" or kind=="LiftPress" then
   floor("LowerDock",0,15,12,14,0);floor("UpperDock",0,42,12,14,rise)
   local p=floor("FreightLift",0,28,12,14,rise/2);attributes(p,{Moving=true,Speed=.65,Phase=-math.pi/2,Amplitude=rise/2,MotionAxis=Vector3.yAxis});nav(0,0,18);nav(0,0,27,"Lift",p);nav(0,rise,38,"Jump");nav(0,rise,46)
   for _,s in {-1,1} do part(map.Decor,"LiftRail",V(.5,rise+7,.5),localcf(s*7,rise/2+2,28),accent) end
   if kind~="Lift" then for _,side in {-1,1} do part(assembly,"UpperGuard",V(.5,10,16),localcf(side*6.25,rise+5,42),dark) end end
   if kind=="LiftLaser" then pulse(42,0,rise) elseif kind=="LiftPress" then danger("UpperPress",0,rise+5,43,V(12,9,5),"Press",0) end
  elseif kind=="Stairs" or kind=="Ledges" or kind=="SwingSteps" or kind=="LedgesPulse" or kind=="CrossfireSteps" or kind=="Descent" or kind=="DescentPulse" then
   for j=1,6 do local t=9+j*6;local y=rise*j/6;local x=(j<3 and -3 or j>4 and 3 or 0)
    floor("Balcony"..j,x,t,10,6,y);nav(x,y,t,"Jump");table.insert(points,point(x,y,t))
    if (kind=="LedgesPulse" or kind=="CrossfireSteps" or kind=="DescentPulse") and j%2==0 then pulse(t,j*.65,y) end
   end
   if kind=="SwingSteps" then danger("Hammer",0,rise/2+2,29,V(3,4,3),"Pendulum",0) end
   for _,side in {-1,1} do part(map.Decor,"TowerSpine",V(3,24,3),localcf(side*12,6,28),accent:Lerp(dark,.6)) end
  elseif kind=="Gallery" or kind=="GalleryReverse" or kind=="ArchiveExit" then
   floor("GalleryFloor",0,28,24,40,0)
   for _,s in {-1,1} do part(assembly,"ArchiveWall",V(1,15,40),localcf(s*12,7.5,28),accent:Lerp(dark,.75)) end
   for j=1,3 do local t=14+j*8;local side=(j%2==0 and -1 or 1)*(kind=="GalleryReverse" and -1 or 1)
    part(assembly,"BookStack"..j,V(16,14,1),localcf(-side*4,7,t),accent:Lerp(dark,.55));local p=point(side*8,0,t);table.insert(points,p)
    nav(side*8,0,t-3);nav(side*8,0,t+3)
    local jewel=part(map.Decor,"RouteDiamond",V(.8,.8,.8),localcf(side*8,6,t)*CFrame.Angles(0,0,math.pi/4),accent,false);jewel.Material=Enum.Material.Neon
    if kind=="ArchiveExit" then danger("ArchiveShutter",side*8,4,t,V(8,8,.5),"Pulse",j*.8) end
   end
   nav(0,0,46)
  elseif kind=="Switch" or kind=="SwitchBelt" or kind=="SwitchPulse" then
   floor("SwitchDock",0,12,12,8,0);floor("ExitDock",0,44,12,8,0)
   local bridge=floor("PowerBridge",0,28,10,24,0);attributes(bridge,{ExpansionBridge=true,Section=section});bridge.CanCollide=false;bridge.Transparency=.8
   local button=part(assembly,"PowerSwitch",V(3,.5,3),localcf(0,.3,12),gold);local prompt=Instance.new("ProximityPrompt");prompt.ActionText="Power bridge (14s)";prompt.ObjectText="POWER SWITCH";prompt.HoldDuration=.3;prompt.MaxActivationDistance=9;prompt.RequiresLineOfSight=false;prompt.Parent=button;prompt:SetAttribute("ExpansionSwitch",section)
   nav(0,0,12,"Switch");nav(0,0,22);nav(0,0,34);nav(0,0,44)
   if kind=="SwitchBelt" then bridge:SetAttribute("ExpansionBelt",cf.LookVector*-5) end
   if kind=="SwitchPulse" then pulse(32,0) end
  elseif kind=="Collapse" or kind=="CollapseBelt" then
   for j=1,6 do local t=10+j*6;local p=floor("Afterimage"..j,0,t,10,5,0)
    if j~=3 then attributes(p,{ExpansionCollapse=true,FallDelay=index==8 and .9 or 1.2}) else p.Color=Color3.fromRGB(56,156,196) end
    if kind=="CollapseBelt" then p:SetAttribute("ExpansionBelt",cf.LookVector*3) end
    nav(0,0,t,"Jump");table.insert(points,point(0,0,t))
   end
  else
   local p=path();rails()
   if kind=="Belt" or kind=="DockRun" or kind=="PulseBelt" or kind=="FinalRun" then p:SetAttribute("ExpansionBelt",cf.LookVector*-6) end
   for j=1,3 do local t=14+j*8
    if kind=="Pistons" then danger("Piston",0,3,t,V(8,6,2),"Piston",j*1.5)
    elseif kind=="Press" or kind=="DockRun" then danger("Press",0,5,t,V(12,9,3),"Press",j*.9)
    elseif kind=="Swing" then danger("Pendulum",0,2,t,V(3,4,3),"Pendulum",j*1.2)
    elseif kind=="Belt" then local s=j%2==0 and -1 or 1;part(assembly,"Sorter",V(7,7,1),localcf(s*2.5,3.5,t),dark);nav(-s*4.5,0,t-3);nav(-s*4.5,0,t+3)
    elseif kind=="Crossfire" then danger("CrossLaser",0,2,t,V(2,4,2),"Piston",j*1.5)
    elseif kind=="FinalRun" and j==2 then danger("FinalHammer",0,2,t,V(3,4,3),"Pendulum",0)
    else pulse(t,kind=="Wave" and j*.7 or j*1.1) end
    if kind~="Belt" then nav(0,0,t-4,"Wait");nav(0,0,t+3) end
    table.insert(points,point(0,0,t-4))
   end
  end
  nav(0,rise,56)
  -- Ordered route volumes follow the actual turns. They are independent of coin collection.
  local candidates={};for _,n in map.TestRoute:GetChildren() do if n:GetAttribute("Section")==section and n.Position~=b+V(0,3,0) then table.insert(candidates,n) end end
  table.sort(candidates,function(x,y)return x.Name<y.Name end)
  for j=1,3 do
   local source=candidates[math.clamp(math.ceil(#candidates*j/3),1,#candidates)];local p=source.Position
   local node=hidden(map.RouteGates["Gate_"..section],"Node_"..j,V(12,16,8),CFrame.new(p)*cf.Rotation)
   local orb=part(map.Orbs,"Orb_"..((section-1)*3+j),Vector3.one*1.2,CFrame.new(p-V(0,.4,0)),gold,false);orb.Shape=Enum.PartType.Ball;orb.Material=Enum.Material.Neon;orb:SetAttribute("OrbId",(section-1)*3+j);orb.CanQuery=false
   local follow=source:GetAttribute("Follow");local moving=follow and map.Platforms:FindFirstChild(follow,true)
   if moving then
    node.Position=moving.Position+V(0,3.5,0);attributes(node,{FollowPlatform=follow,FollowOffset=V(0,3.5,0)})
    orb.Position=moving.Position+V(0,3.1,0);attributes(orb,{FollowPlatform=follow,FollowOffset=V(0,3.1,0)})
   end
  end
  task.wait()
 end
 -- Simple silhouettes keep the background coherent without thousands of decorative parts.
 local room=Instance.new("Model");room.Name="CourseSky";room.ModelStreamingMode=Enum.ModelStreamingMode.PersistentPerPlayer;room.Parent=map
 for n=1,12 do
  local angle=n*math.pi/6;local center=V(spec.X+56,30,-84);local pos=center+V(math.cos(angle)*190,0,math.sin(angle)*190)
  local p=part(room,"DistantSpire",V(14,35+(n%4)*15,14),CFrame.new(pos),accent:Lerp(dark,.8),false);p.Locked=true
 end
 map.Parent=levels;return map
end
function Expansion.Apply() for i=5,8 do Expansion.Build(i) end end
return Expansion

