-- Targeted revisions to the saved course. Existing scenery, hubs and good sections survive.
local Refinement={}
local Config=require(game.ReplicatedStorage.SkyfallConfig)
local navy=Color3.fromRGB(43,76,97)
local titles={BoulderHop="CLOUD BOULDERS / JUMP BETWEEN THE BALLS",Switchback="SKY SWITCHBACK / FOLLOW THE LIT TURNS",Maze="RUIN LABYRINTH / FOLLOW THE OPEN ARCHES",ArchCrossing="ARCH CROSSING / TIME THE SWEEPER",TerraceClimb="TERRACE CLIMB / FOLLOW THE RISING CURVE",Alternating="SAFE ALCOVES / WATCH THE MOVING GATES",MovingRelay="PLATFORM RELAY / WAIT, LAND, RECENTER",Elevator="LIFT STATION / BOARD LOW, EXIT HIGH",WindSwitchback="WIND WALK / TURN ON THE WIDE LANDINGS",Orbit="ORBIT WALK / TIME THE SWEEPER",Finale="REACTOR ESCAPE / COMBINE WHAT YOU LEARNED"}
local replacements={
 [1]={[5]="BoulderHop",[6]="Switchback"},
 [2]={[2]="Maze",[4]="ArchCrossing",[5]="TerraceClimb",[7]="Alternating"},
 [3]={[1]="MovingRelay",[3]="Elevator",[4]="Alternating",[5]="WindSwitchback",[7]="Elevator",[8]="MovingRelay"},
 [4]={[3]="Orbit",[6]="TerraceClimb",[8]="Finale"},
}
local function part(parent,name,size,pos,color,material)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Color=color or navy;p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true;p.CastShadow=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function visual(parent,name,size,pos,color)
 local p=part(parent,name,size,pos,color,Enum.Material.Neon);p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;return p
end
function Refinement.Apply(world)
 if world:GetAttribute("GameplayVersion")=="Routes_3" then return "Refined routes retained." end
 local report={}
 for level=1,4 do
  local map=world.Levels["Level"..level];local spec=Config.Levels[level];local x=spec.X;local length=spec.Sections*96
  local oldLength=map:GetAttribute("CourseLength")
  -- Trim only redundant route tails; keep the hand-edited environment intact.
  for _,folder in {map.Platforms,map.Hazards,map.RouteGates,map.Orbs} do
   for _,p in folder:GetChildren() do
    if p:IsA("BasePart") and (folder==map.Orbs and (p:GetAttribute("OrbId") or 0)>spec.Sections*3 or folder~=map.Orbs and p.Position.Z< -length-11 and not p:GetAttribute("InvisibleFallCatcher")) then p:Destroy() end
   end
  end
  local delta=Vector3.new(0,0,oldLength-length)
  map.PortalTrigger.CFrame+=delta
  for _,p in map.Decor:GetChildren() do if p:IsA("BasePart") then
   if p.Name=="PortalRing" or p.Name=="FinishLabel" then p.CFrame+=delta
   elseif p.Name=="CheckpointLabel" or p.Name=="SectionLabel" and p.Position.Z< -length then p:Destroy()
   elseif p.Position.Z< -length-12 and (p.Name=="HubEdge" or p.Name=="RockCore" or p.Name=="Crystal" or p.Name=="StepGuide" or p.Name=="CrusherFrame" or p.Name=="BeltArrow" or p.Name=="OpenLane") then p:Destroy() end
  end end
  local identity=map.Decor:FindFirstChild("WorldIdentity")
  if identity then
   for _,obj in identity:GetDescendants() do
    if obj.Parent and obj:IsA("Model") and obj:GetAttribute("SpinVisual") then
     local center=obj:GetAttribute("VisualCenter");if typeof(center)=="Vector3" and center.Z< -length-24 then obj:Destroy() end
    elseif obj.Parent and obj:IsA("BasePart") and obj.Position.Z< -length-24 then obj:Destroy() end
   end
  end
  local endHub=map.Platforms:FindFirstChild("Hub_"..spec.Sections);endHub.Size=Vector3.new(26,3,22)
  map:SetAttribute("Sections",spec.Sections);map:SetAttribute("CourseLength",length);map:SetAttribute("CheckpointCount",spec.Sections/Config.CheckpointEvery-1);map:SetAttribute("TotalOrbs",spec.Sections*3)
  map.Checkpoints:ClearAllChildren()
  for section=Config.CheckpointEvery,spec.Sections-1,Config.CheckpointEvery do
   local stage=section/Config.CheckpointEvery
   local cp=part(map.Checkpoints,"Checkpoint_"..stage,Vector3.new(10,.25,6),Vector3.new(x,20.3,-section*96+3),Color3.fromRGB(100,245,167),Enum.Material.Neon)
   cp:SetAttribute("Stage",stage);cp:SetAttribute("Section",section)
  end
  local oldDetails=map.Decor:FindFirstChild("RefinedRouteDetails");if oldDetails then oldDetails:Destroy() end
  local decor=Instance.new("Folder");decor.Name="RefinedRouteDetails";decor.Parent=map.Decor
  for section,pattern in pairs(replacements[level]) do
   local z=-(section-1)*96
   for _,folder in {map.Platforms,map.Hazards} do for _,p in folder:GetChildren() do
    if p:IsA("BasePart") and (p.Name:match("^Refined_"..section.."_") or p.Name:match("^RefinedSlide_"..section.."_") or not p.Name:match("^Hub_") and not p:GetAttribute("InvisibleFallCatcher") and p.Position.Z<z-10 and p.Position.Z>z-87) then p:Destroy() end
   end end
   for _,p in map.Decor:GetChildren() do if p:IsA("BasePart") and p.Position.Z<z-10 and p.Position.Z>z-87 and (p.Name=="StepGuide" or p.Name=="CrusherFrame" or p.Name=="BeltArrow" or p.Name=="OpenLane") then p:Destroy() end end
   local function pos(a,y,b) return Vector3.new(x+a,y,z+b) end
   local gate=map.RouteGates["Gate_"..section]
   gate:ClearAllChildren()
   local function node(index,point)
    local n=part(gate,"Node_"..index,Vector3.new(12,12,8),point+Vector3.new(0,4,0));n.Transparency=1;n.CanCollide=false;n.CanTouch=false;n.CanQuery=false
   end
   local path={}
   local function mark(point,jump,target)
    table.insert(path,{point.X,point.Y+3,point.Z,Jump=jump==true,Target=target})
   end
   local function deck(name,point,size,kind)
    local p=part(map.Platforms,"Refined_"..section.."_"..name,size or Vector3.new(12,2,12),point-Vector3.new(0,1,0),spec.Color:Lerp(navy,.65));p:SetAttribute("RefinedSection",section)
    if kind=="Moving" then p:SetAttribute("Moving",true);p:SetAttribute("Amplitude",4);p:SetAttribute("Speed",.65);p:SetAttribute("Phase",0) end
    visual(decor,"LandingGuide",Vector3.new(p.Size.X,.06,.18),p.Position+Vector3.new(0,p.Size.Y/2+.04,p.Size.Z/2-.15),spec.Color)
    return p
   end
   local surface=spec.Color:Lerp(navy,.65)
   local function bridge(a,b,width)
    local p=part(map.Platforms,"Refined_"..section.."_Ramp",Vector3.new(width or 8,1,(b-a).Magnitude),(a+b)/2-Vector3.new(0,.5,0),surface);local cf=CFrame.lookAt((a+b)/2+Vector3.new(0,.06,0),b+Vector3.new(0,.06,0));p.CFrame=cf*CFrame.new(0,-.5,0)
    p:SetAttribute("RefinedSection",section);return p
   end
   local function roundJoin(point,width,tangent)
    local p=part(map.Platforms,"Refined_"..section.."_RoundJoin",Vector3.new(1,width,width),point-Vector3.new(0,.5,0),surface)
    p.Shape=Enum.PartType.Cylinder;local center=point+Vector3.new(0,.06,0);p.CFrame=CFrame.lookAt(center,center+tangent)*CFrame.new(0,-.5,0)*CFrame.Angles(0,0,math.pi/2);p:SetAttribute("RefinedSection",section)
   end
   local function route(points,width,mandatory)
    width=width or 8
    local smooth={points[1]}
    for i=2,#points-1 do
     local previous,corner,nextPoint=points[i-1],points[i],points[i+1]
     local radius=math.min(6,(corner-previous).Magnitude*.23,(nextPoint-corner).Magnitude*.23)
     local entry=corner+(previous-corner).Unit*radius
     local exit=corner+(nextPoint-corner).Unit*radius
     table.insert(smooth,entry)
     for j=1,4 do local t=j/4;table.insert(smooth,entry*(1-t)^2+corner*(2*t*(1-t))+exit*t*t) end
    end
    table.insert(smooth,points[#points])
    for i=1,#smooth-1 do bridge(smooth[i],smooth[i+1],width) end
    for i,point in ipairs(smooth) do roundJoin(point,width,smooth[math.min(#smooth,i+1)]-smooth[math.max(1,i-1)]) end
    for i,point in ipairs(points) do mark(point);if mandatory and i>1 and i<#points then node(i-1,point) end end
   end
   if pattern=="BoulderHop" then
    mark(pos(0,20,-9))
    for i=1,6 do
     local top=20+((i==3 or i==4) and 2 or (i==2 or i==5) and 1 or 0)
     local point=pos(i%2==0 and 2 or -2,top,-20-(i-1)*12)
     local p=part(map.Platforms,"Refined_"..section.."_Boulder"..i,Vector3.one*7.5,point-Vector3.new(0,3.75,0),spec.Color:Lerp(navy,.35))
     p.Shape=Enum.PartType.Ball;p:SetAttribute("RefinedSection",section);mark(point,true,p.Name)
     if i==3 then node(1,point) elseif i==5 then node(2,point) end
    end
    mark(pos(0,20,-88),true)
   elseif pattern=="Maze" then
    deck("MazeFloor",pos(0,20,-48),Vector3.new(56,2,76))
    for i=1,3 do local px=i%2==1 and -9 or 9;local dz=-8-i*22
     part(map.Platforms,"Refined_"..section.."_MazeWall"..i,Vector3.new(38,13,2),pos(px,26.5,dz),Color3.fromRGB(103,72,66),Enum.Material.Slate)
     node(i,pos(i%2==1 and 18 or -18,20,dz))
    end
    for _,v in {{0,-12},{18,-23},{18,-37},{-18,-44},{-18,-60},{18,-66},{18,-80},{0,-86}} do mark(pos(v[1],20,v[2])) end
   elseif pattern=="TerraceClimb" then
    -- A monotonic climb and descent: no crossing decks, central cut-through or layered scraps.
    route({pos(0,20,-9),pos(-16,22,-25),pos(-16,25,-42),pos(16,28,-58),pos(16,25,-74),pos(0,20,-88)},8,true)
   elseif pattern=="ArchCrossing" then
    route({pos(0,20,-9),pos(-12,20,-28),pos(0,20,-48),pos(12,20,-68),pos(0,20,-88)},7.5,true)
    local h=visual(map.Hazards,"ArchCrossingSweeper",Vector3.new(14,1,1),pos(0,21.1,-48),Color3.fromRGB(255,88,91));h:SetAttribute("Kind","Spin");h:SetAttribute("Speed",.65)
   elseif pattern=="Elevator" then
    deck("Entry",pos(0,20,-19),Vector3.new(16,2,20));mark(pos(0,20,-24))
    local lift=deck("Lift",pos(0,25,-37),Vector3.new(16,2,22),"Moving");lift:SetAttribute("MotionAxis",Vector3.new(0,1,0));lift:SetAttribute("Amplitude",5);lift:SetAttribute("Phase",-math.pi/2)
    mark(pos(0,20,-31),true,lift.Name);mark(pos(0,25,-42),false,lift.Name)
    deck("UpperLanding",pos(0,30,-59),Vector3.new(18,2,22));mark(pos(0,30,-52),true)
    node(1,pos(0,30,-59));bridge(pos(0,30,-69),pos(0,20,-88),12);mark(pos(0,30,-66));mark(pos(0,20,-88))
   elseif pattern=="MovingRelay" then
    mark(pos(0,20,-9))
    for i=1,3 do local p=deck("Ferry"..i,pos(0,20,-25-(i-1)*23),Vector3.new(14,2,20),"Moving");p:SetAttribute("Speed",level==4 and .85 or .6);p:SetAttribute("Phase",section==1 and 0 or i*.7);mark(p.Position+Vector3.new(0,1,7),true,p.Name);mark(p.Position+Vector3.new(0,1,-7),false,p.Name) end
    mark(pos(0,20,-88),true)
   elseif pattern=="Alternating" then
    deck("Runway",pos(0,20,-48),Vector3.new(22,2,78));mark(pos(0,20,-10))
    for i=1,3 do local dz=-24-(i-1)*23
     local h=visual(map.Hazards,"RefinedSlide_"..section.."_"..i,Vector3.new(2,3.5,9),pos(0,21.75,dz),Color3.fromRGB(255,88,91));h:SetAttribute("Kind","Slide");h:SetAttribute("Amplitude",8);h:SetAttribute("Speed",.8);h:SetAttribute("Phase",i*1.8)
     deck("SafeAlcove"..i,pos(i%2==0 and -13 or 13,20,dz+8),Vector3.new(8,2,10));mark(pos(0,20,dz+7));mark(pos(0,20,dz-8))
    end
   elseif pattern=="Orbit" then
    route({pos(0,20,-9),pos(-16,20,-23),pos(-22,20,-46),pos(-12,20,-71),pos(0,20,-88)},8,true)
    local h=visual(map.Hazards,"OrbitSweeper",Vector3.new(20,1,1),pos(-16,21.1,-46),Color3.fromRGB(255,88,91));h:SetAttribute("Kind","Spin");h:SetAttribute("Speed",.65)
   elseif pattern=="Finale" then
    route({pos(0,20,-9),pos(14,22,-26),pos(14,24,-43),pos(-14,24,-61),pos(0,20,-88)},8,true)
    local h=visual(map.Hazards,"FinalSweeper",Vector3.new(14,1,1),pos(14,25.1,-43),Color3.fromRGB(255,88,91));h:SetAttribute("Kind","Spin");h:SetAttribute("Speed",.6)
   else
    route({pos(0,20,-9),pos(18,20,-28),pos(-18,20,-54),pos(0,20,-88)},pattern=="WindSwitchback" and 7 or 8,true)
   end
   mark(pos(0,20,-96))
   gate:SetAttribute("TraversalPath",game.HttpService:JSONEncode(path))
   for j=1,3 do local orb=map.Orbs:FindFirstChild("Orb_"..((section-1)*3+j));if orb then
    orb:SetAttribute("FollowPlatform",nil);orb:SetAttribute("FollowOffset",nil)
    local index=math.max(1,math.floor((#path-1)*j/4));local q=path[index];orb.Position=Vector3.new(q[1],q[2],q[3])
    if q.Target then local platform=map.Platforms:FindFirstChild(q.Target);if platform and platform:GetAttribute("Moving") then orb:SetAttribute("FollowPlatform",platform.Name);orb:SetAttribute("FollowOffset",orb.Position-platform.Position) end end
   end end
   local label
   for _,p in map.Decor:GetChildren() do if p.Name=="SectionLabel" and math.abs(p.Position.Z-(z-13))<1 then label=p;break end end
   if label then local gui=label:FindFirstChildOfClass("BillboardGui");local text=gui and gui:FindFirstChildOfClass("TextLabel");if text then text.Text=string.format("%02d / %s",section,titles[pattern] or pattern) end end
  end
  -- Forgiving contact areas and timing windows after the movement reduction.
  for _,p in map.Platforms:GetChildren() do
   if p.Name:match("^Step_") then p.Size=Vector3.new(math.max(10,p.Size.X),p.Size.Y,math.max(10,p.Size.Z)) end
   if p:GetAttribute("Crumble") then p:SetAttribute("FallDelay",level==4 and .8 or 1.05) end
   if p:GetAttribute("PhasePlatform") then p:SetAttribute("SolidTime",level==4 and 2.9 or 3.6) end
   if p.Name:match("^Balance_") then p.Size=Vector3.new(level==4 and 4 or 5,p.Size.Y,p.Size.Z) end
   if p.Name:match("^SpringLanding_") then p.Size=Vector3.new(18,2,46);p.Position=Vector3.new(p.Position.X,19,math.floor((p.Position.Z+68)/96)*96-66) end
   if p:GetAttribute("Conveyor") then p.AssemblyLinearVelocity=Vector3.new(7,0,0) end
  end
  for _,h in map.Hazards:GetChildren() do
   if h:GetAttribute("Kind")=="Spin" then h:SetAttribute("Speed",level==1 and .65 or .85) end
  end
  table.insert(report,{Level=level,Sections=spec.Sections,Checkpoints=#map.Checkpoints:GetChildren()})
  task.wait()
 end
 world:SetAttribute("GameplayVersion","Routes_3")
 return report
end
return Refinement
