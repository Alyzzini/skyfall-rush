local Config=require(game.ReplicatedStorage.SkyfallConfig)
local SS=game.ServerStorage
local old=workspace:FindFirstChild("SkyfallSprint")
if old then old.Name="SkyfallBeforeRush"; old.Parent=SS end
local world=Instance.new("Folder"); world.Name="SkyfallSprint"; world.Parent=workspace
local levels=Instance.new("Folder"); levels.Name="Levels"; levels.Parent=world
local navy=Color3.fromRGB(20,33,54)
local red=Color3.fromRGB(255,88,91)
local gold=Color3.fromRGB(255,214,90)
local cyan=Color3.fromRGB(65,239,215)
local function part(parent,name,size,pos,color,material)
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Position=pos; p.Anchored=true; p.Color=color or navy; p.Material=material or Enum.Material.SmoothPlastic; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=parent; return p
end
local function sign(parent,name,words,pos,width,height,color)
 local p=part(parent,name,Vector3.one*.1,pos,color); p.Transparency=1; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false
 local b=Instance.new("BillboardGui"); b.Size=UDim2.fromScale(width,height); b.MaxDistance=85; b.Parent=p
 local t=Instance.new("TextLabel"); t.Size=UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.Text=words; t.Font=Enum.Font.GothamBold; t.TextScaled=true; t.TextColor3=color or Color3.new(1,1,1); t.TextStrokeTransparency=.7; t.Parent=b
end
local function beam(parent,name,a,b,width,color)
 local p=part(parent,name,Vector3.new(width,1,(a-b).Magnitude),(a+b)/2,color,Enum.Material.Metal); p.CFrame=CFrame.lookAt((a+b)/2,b); return p
end
local descriptions={Jumps="MOMENTUM JUMPS / KEEP YOUR RHYTHM",Hurdles="HURDLE RUN / JUMP THE RED BARS",Slalom="SLALOM WALLS / FOLLOW THE OPEN SIDE",Phase="PHASE STEPS / CYAN SOLID - PINK GHOST",Crumble="CRUMBLE CHAIN / AMBER STEPS FALL AWAY",Ferry="SKY FERRIES / LAND ON THE MOVING DECKS",Balance="RAZOR RIDGE / STAY ON THE LIT BEAM",Spinners="SWEEPER ALLEY / JUMP THE RED ARMS",Conveyor="CROSSWIND BELT / STEER AGAINST THE ARROWS",Slide="SLIDING GATES / FIND YOUR OPENING",Crusher="CRUSHER CORRIDOR / MOVE WHEN THEY RISE",Spring="SPRING GAP / HOLD FORWARD ON GREEN"}
local summary={}
for level,spec in ipairs(Config.Levels) do
 local map=Instance.new("Folder"); map.Name="Level"..level; map.Parent=levels
 for _,name in {"Platforms","Orbs","Hazards","Checkpoints","RouteGates","Decor"} do local f=Instance.new("Folder"); f.Name=name; f.Parent=map end
 for k,v in {Number=level,Title=spec.Title,Difficulty=spec.Difficulty,Summary=spec.Summary,Sections=spec.Sections,CourseLength=spec.Sections*96,CheckpointCount=spec.Sections/4-1,TotalOrbs=spec.Sections*3,RequiredOrbs=0,TimeLimit=0} do map:SetAttribute(k,v) end
 local function pos(x,y,z) return Vector3.new(spec.X+x,y,z) end
 local start=part(map,"StartPosition",Vector3.one,pos(0,24,5)); start.Transparency=1; start.CanCollide=false; start.CanTouch=false
 local spawn=level==1 and Instance.new("SpawnLocation") or nil
 if spawn then spawn.Name="SkyfallSpawn"; spawn.Size=Vector3.new(6,.2,6); spawn.Position=pos(0,20.25,5); spawn.Anchored=true; spawn.Neutral=true; spawn.Duration=0; spawn.Transparency=1; spawn.Parent=map end
 local startLine=part(map,"StartLine",Vector3.new(24,.15,1),pos(0,20.3,-8),spec.Color,Enum.Material.Neon); startLine.CanCollide=false
 local function hazard(name,size,p,kind)
  local h=part(map.Hazards,name,size,p,red,Enum.Material.Neon); h.CanCollide=false; h:SetAttribute("Kind",kind or "Static"); return h
 end
 local function pad(section,j,x,z,width,kind)
  local p=part(map.Platforms,"Step_"..section.."_"..j,Vector3.new(width,2,8),pos(x,19,z),kind=="Crumble" and Color3.fromRGB(172,111,55) or navy,kind=="Crumble" and Enum.Material.CrackedLava or Enum.Material.SmoothPlastic)
  if kind=="Crumble" then p:SetAttribute("Crumble",true); p:SetAttribute("FallDelay",level==4 and .55 or .85)
  elseif kind=="Phase" then p:SetAttribute("PhasePlatform",true); p:SetAttribute("Period",level==4 and 3.6 or 4.4); p:SetAttribute("SolidTime",level==4 and 2.5 or 3.4); p:SetAttribute("Phase",j*.32); p.Color=cyan; p.Material=Enum.Material.Neon
  else local edge=part(map.Decor,"StepGuide",Vector3.new(width,.1,.2),pos(x,20.08,z+3.8),spec.Color,Enum.Material.Neon); edge.CanCollide=false; edge.CanTouch=false end
  return p
 end
 local function coin(id,p,follow)
  local c=part(map.Orbs,"Orb_"..id,Vector3.new(1.7,1.7,1.7),p,gold,Enum.Material.Neon); c.Shape=Enum.PartType.Ball; c.CanCollide=false; c.CanTouch=false; c:SetAttribute("OrbId",id)
  if follow then c:SetAttribute("FollowPlatform",follow.Name); c:SetAttribute("FollowOffset",p-follow.Position) end
 end
 local checkpointIndex=0
 for hub=0,spec.Sections do
  local z=-hub*96; local depth=(hub==0 or hub==spec.Sections or hub%4==0) and 22 or 18
  part(map.Platforms,"Hub_"..hub,Vector3.new(26,3,depth),pos(0,18.5,z),navy)
  for _,side in {-1,1} do local edge=part(map.Decor,"HubEdge",Vector3.new(.25,.15,depth),pos(12.8*side,20.1,z),spec.Color,Enum.Material.Neon); edge.CanCollide=false end
  local core=part(map.Decor,"RockCore",Vector3.new(19,10,15),pos(0,12,z),Color3.fromRGB(39,45,66),Enum.Material.Slate); core.CFrame*=CFrame.Angles(0,.22,.08); core.CanCollide=false
  for _,side in {-1,1} do local crystal=part(map.Decor,"Crystal",Vector3.new(1.3,4,1.3),pos(11*side,21.8,z-5),spec.Color,Enum.Material.Neon); crystal.CFrame*=CFrame.Angles(.15,.4,side*.22); crystal.CanCollide=false end
  if hub>0 then
   local gate=part(map.RouteGates,"Gate_"..hub,Vector3.new(25,12,5),pos(0,24,z+6)); gate.Transparency=1; gate.CanCollide=false; gate.CanTouch=false; gate:SetAttribute("Section",hub)
   if hub%4==0 and hub<spec.Sections then
    checkpointIndex+=1
    local cp=part(map.Checkpoints,"Checkpoint_"..checkpointIndex,Vector3.new(10,.25,6),pos(0,20.3,z+3),Color3.fromRGB(90,245,165),Enum.Material.Neon); cp:SetAttribute("Stage",checkpointIndex); cp:SetAttribute("Section",hub)
    sign(map.Decor,"CheckpointLabel","CHECKPOINT "..checkpointIndex.." / +20 COINS",pos(0,26,z+3),15,1.5,Color3.fromRGB(130,255,185))
   end
  end
  if hub<spec.Sections then
   local pattern=spec.Patterns[hub+1]
   sign(map.Decor,"SectionLabel",string.format("%02d / %s",hub+1,descriptions[pattern]),pos(0,27,z-13),26,1.5,spec.Color)
   local pickups={}
   if pattern=="Jumps" or pattern=="Crumble" or pattern=="Phase" then
    for j=1,6 do local dz=z-20-(j-1)*12; local x=(j%2==0 and 1 or -1)*(level>=3 and 3.5 or 2.5); pad(hub,j,x,dz,math.max(6.5,10-level*.7),pattern); if j%2==0 then table.insert(pickups,{p=pos(x,23,dz)}) end end
   elseif pattern=="Ferry" then
    for j=1,3 do
     local dz=z-26-(j-1)*22; local ferry=part(map.Platforms,"Ferry_"..hub.."_"..j,Vector3.new(12-level*.5,2,16),pos(0,19,dz),spec.Color,Enum.Material.Metal); ferry:SetAttribute("Moving",true); ferry:SetAttribute("Amplitude",level==4 and 6 or 4); ferry:SetAttribute("Speed",level==4 and 1.4 or .85); ferry:SetAttribute("Phase",j*1.7)
     table.insert(pickups,{p=ferry.Position+Vector3.new(0,4,0),follow=ferry})
    end
   elseif pattern=="Balance" then
    local points={pos(0,19.5,z-8),pos(6,19.5,z-30),pos(-6,19.5,z-56),pos(0,19.5,z-88)}
    for j=1,3 do beam(map.Platforms,"Balance_"..hub.."_"..j,points[j],points[j+1],level==4 and 2.7 or 3.8,navy); local guide=beam(map.Decor,"BalanceGuide",points[j]+Vector3.new(0,.55,0),points[j+1]+Vector3.new(0,.55,0),.16,spec.Color); guide.CanCollide=false; guide.Material=Enum.Material.Neon; table.insert(pickups,{p=points[j]:Lerp(points[j+1],.6)+Vector3.new(0,3.5,0)}) end
   elseif pattern=="Spring" then
    part(map.Platforms,"SpringApproach_"..hub,Vector3.new(14,2,18),pos(0,19,z-18),navy)
    local spring=part(map.Platforms,"Spring_"..hub,Vector3.new(10,.35,7),pos(0,20.2,z-24),Color3.fromRGB(83,255,146),Enum.Material.Neon); spring:SetAttribute("Spring",true)
    part(map.Platforms,"SpringLanding_"..hub,Vector3.new(18,2,40),pos(0,19,z-68),navy)
    for j=1,3 do table.insert(pickups,{p=pos(0,j==1 and 24 or 23,z-(j==1 and 24 or j==2 and 58 or 77))}) end
   else
    local floor=part(map.Platforms,"Runway_"..hub,Vector3.new(pattern=="Slalom" and 18 or 13,2,78),pos(0,19,z-48),navy,Enum.Material.Metal)
    if pattern=="Conveyor" then
     floor.Material=Enum.Material.DiamondPlate; floor:SetAttribute("Conveyor",true); floor.AssemblyLinearVelocity=Vector3.new(level>=3 and 13 or 9,0,0)
     for j=1,7 do local arrow=part(map.Decor,"BeltArrow",Vector3.new(4,.08,.35),pos(0,20.1,z-12-j*9),spec.Color,Enum.Material.Neon); arrow.CFrame*=CFrame.Angles(0,.5,0); arrow.CanCollide=false end
    end
    for j=1,3 do
     local dz=z-25-(j-1)*22; local pickupX=0
     if pattern=="Hurdles" or pattern=="Conveyor" then hazard("Hurdle_"..hub.."_"..j,Vector3.new(13,1.3,.7),pos(0,20.65,dz))
     elseif pattern=="Slalom" then
      local side=j%2==0 and 1 or -1; part(map.Platforms,"SlalomWall_"..hub.."_"..j,Vector3.new(11,8,1.5),pos(3.5*side,24,dz),Color3.fromRGB(59,79,106),Enum.Material.Metal); pickupX=-6.5*side
      local marker=part(map.Decor,"OpenLane",Vector3.new(4,.1,3),pos(pickupX,20.1,dz+2),cyan,Enum.Material.Neon); marker.CanCollide=false
     elseif pattern=="Spinners" then
      for arm=1,(level==4 and 2 or 1) do local h=hazard("Spin_"..hub.."_"..j.."_"..arm,Vector3.new(13,1,1),pos(0,21.2,dz),"Spin"); h:SetAttribute("Speed",.7+level*.25); h:SetAttribute("Phase",(arm-1)*math.pi/2) end
     elseif pattern=="Slide" then
      local h=hazard("Slide_"..hub.."_"..j,Vector3.new(1,3.6,8),pos(0,21.8,dz),"Slide"); h:SetAttribute("Amplitude",7); h:SetAttribute("Speed",.8+level*.15); h:SetAttribute("Phase",j*1.5)
     elseif pattern=="Crusher" then
      local h=hazard("Crusher_"..hub.."_"..j,Vector3.new(13,6,3),pos(0,24,dz),"Lift"); h:SetAttribute("Amplitude",8); h:SetAttribute("Speed",.8+level*.13); h:SetAttribute("Phase",j*1.5)
      for _,side in {-1,1} do local post=part(map.Decor,"CrusherFrame",Vector3.new(.7,15,.7),pos(7.7*side,27,dz),spec.Color,Enum.Material.Metal); post.CanCollide=false end
     end
     table.insert(pickups,{p=pos(pickupX,23,dz+6)})
    end
   end
   for j,pickup in ipairs(pickups) do coin(hub*3+j,pickup.p,pickup.follow) end
  end
  task.wait()
 end
 sign(map.Decor,"GameTitle",string.format("%02d / %s",level,string.upper(spec.Title)),pos(0,32,-7),27,3,Color3.new(1,1,1))
 sign(map.Decor,"StartRules","SPEEDRUN / COINS OPTIONAL / FOUR OBSTACLES PER CHECKPOINT",pos(0,28,-7),28,1.2,spec.Color)
 local finishZ=-spec.Sections*96-4
 local portal=part(map,"PortalTrigger",Vector3.new(9,10,2),pos(0,25,finishZ),spec.Color,Enum.Material.Neon); portal.Transparency=.65; portal.CanCollide=false; portal.CanTouch=false
 for j=0,11 do local a=j*math.pi/6; local p=part(map.Decor,"PortalRing",Vector3.new(2.4,2,1.5),pos(math.sin(a)*6.5,25+math.cos(a)*6.5,finishZ),spec.Color,Enum.Material.Neon); p.CFrame*=CFrame.Angles(0,0,-a); p.CanCollide=false end
 sign(map.Decor,"FinishLabel",level==4 and "CAMPAIGN FINISH" or "FINISH / NEXT LEVEL",pos(0,36,finishZ),20,2,Color3.new(1,1,1))
 local kiosk=part(map.Decor,"ShopKiosk",Vector3.new(4,4,3),pos(-10,22,4),Color3.fromRGB(43,67,90)); local prompt=Instance.new("ProximityPrompt"); prompt.ActionText="Open Shop"; prompt.ObjectText="Trails & Auras"; prompt.HoldDuration=0; prompt.RequiresLineOfSight=false; prompt.MaxActivationDistance=12; prompt.Parent=kiosk; kiosk.CanCollide=false
 sign(map.Decor,"ShopLabel","COIN SHOP",pos(-10,26,4),8,1.2,gold)
 local board=part(map.Decor,"LeaderboardBoard",Vector3.new(20,13,1),pos(23,27,11),navy); board.CanCollide=false
 local surface=Instance.new("SurfaceGui"); surface.Name="LeaderboardSurface"; surface.Face=Enum.NormalId.Front; surface.CanvasSize=Vector2.new(700,455); surface.Parent=board
 local heading=Instance.new("TextLabel"); heading.Name="Heading"; heading.Size=UDim2.new(1,0,0,60); heading.BackgroundTransparency=1; heading.Text="GLOBAL SPEEDRUN / LEVEL "..level; heading.TextColor3=gold; heading.Font=Enum.Font.GothamBold; heading.TextSize=27; heading.Parent=surface
 local rows=Instance.new("TextLabel"); rows.Name="Rows"; rows.Position=UDim2.fromOffset(25,80); rows.Size=UDim2.new(1,-50,1,-100); rows.BackgroundTransparency=1; rows.Text="Loading rankings..."; rows.TextColor3=Color3.new(1,1,1); rows.Font=Enum.Font.Gotham; rows.TextSize=24; rows.TextYAlignment=Enum.TextYAlignment.Top; rows.TextXAlignment=Enum.TextXAlignment.Left; rows.Parent=surface
 local prompt2=Instance.new("ProximityPrompt"); prompt2.ActionText="View Rankings"; prompt2.ObjectText="Speedrun Records"; prompt2.HoldDuration=0; prompt2.RequiresLineOfSight=false; prompt2.MaxActivationDistance=25; prompt2.Parent=board
 table.insert(summary,{level=level,sections=spec.Sections,length=spec.Sections*96,checkpoints=checkpointIndex,coins=#map.Orbs:GetChildren(),parts=#map:GetDescendants()})
end
if workspace.CurrentCamera then workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(65,70,45),Vector3.new(0,20,-100)) end
if not game:GetService("RunService"):IsRunning() then game:GetService("ChangeHistoryService"):SetWaypoint("Skyfall Rush: longer modular courses") end
return summary
