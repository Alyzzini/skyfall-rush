-- Additive chapter: never author, search inside, or rebuild Levels 1-8.
local A={}
local V=Vector3.new
local navy=Color3.fromRGB(22,32,49)
local danger=Color3.fromRGB(255,85,109)
local gold=Color3.fromRGB(255,215,95)
local patterns={
 [9]={"GearTransfer","PistonDecks","PressureLine","RollingDrum","WallLift","SteamUnderpass","MachineInterior","DriveShaft"},
 [10]={"ExteriorClimb","OrbitLanding","WallSteps","LiftShaft","InteriorStairs","BreakawayBalconies","SkyBridge","CrownAscent"},
 [11]={"TravelingWindow","SignalFloor","BeatBridge","CrossingWindows","SafeZoneCircuit","EchoStairs","PhaseOrbit","PatternFinale"},
 [12]={"GearWindow","PressureEscape","LiftWindows","BreakawayRise","CoreNavigation","SignalOrbit","UnderCore","SummitCircuit"},
}
local instructions={
 GearTransfer="ENGAGE / rotating gear decks carry you",PistonDecks="TRANSFER / board at the ends of each stroke",PressureLine="PRESSURE LINE / use the blue side bays",RollingDrum="DRIVE ROLLER / cross the rotating barrel",WallLift="LIFT HOUSING / ride up past the wall opening",SteamUnderpass="STEAM TUNNEL / white vents warn before firing",MachineInterior="INNER MACHINE / pass through the moving windows",DriveShaft="OUTPUT SHAFT / gear transfer and steam exhaust",
 ExteriorClimb="OUTSIDE THE TOWER / climb the marked balconies",OrbitLanding="ORBIT DOCK / ride around the tower corner",WallSteps="WALL CASSETTES / blue ledges remain solid",LiftShaft="INTERIOR LIFT / watch the upper opening",InteriorStairs="SERVICE ROOM / climb inside, then step outside",BreakawayBalconies="BREAKAWAY / blue balconies are permanent rests",SkyBridge="SKY CROSSING / choose the lower walkway or gold relay",CrownAscent="THE CROWN / orbit, climb and reach the lookout",
 TravelingWindow="MOVING WINDOW / follow the opening across the wall",SignalFloor="SIGNAL FLOOR / green is open, amber warns, red burns",BeatBridge="BEAT BRIDGE / blue islands never disappear",CrossingWindows="DOUBLE WINDOW / stop in the central bay",SafeZoneCircuit="SAFE ZONE / follow behind the red floor wave",EchoStairs="ECHO STEPS / climb after the pulse passes",PhaseOrbit="ORBITAL RHYTHM / ride to the green exit",PatternFinale="SIGNAL LOCK / read the floor and wall together",
 GearWindow="TRANSFER CHAMBER / gear deck and moving exit",PressureEscape="PRESSURE ESCAPE / belt, press and safe bays",LiftWindows="CORE LIFT / moving exit, permanent top dock",BreakawayRise="ASCENT / disappearing wall steps and steam",CoreNavigation="INNER CORE / navigate between moving windows",SignalOrbit="ORBITAL CORE / moving deck and signal floor",UnderCore="UNDER THE CORE / descend below the machine",SummitCircuit="SKYFALL CIRCUIT / three systems, two safe bays",
}
local function attr(p,t) for k,v in pairs(t) do p:SetAttribute(k,v) end;return p end
local function part(parent,name,size,cf,color,solid)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=solid~=false;p.CanTouch=solid~=false;p.Color=color or navy;p.Material=Enum.Material.SmoothPlastic;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function invisible(parent,name,size,cf)
 local p=part(parent,name,size,cf,nil,false);p.Transparency=1;p.CanQuery=false;p.Locked=true;return p
end
local function sign(parent,text,cf,color)
 local p=invisible(parent,"Wayfinding",Vector3.one*.1,cf);local g=Instance.new("BillboardGui",p);g.Size=UDim2.fromOffset(370,48);g.MaxDistance=70;g.StudsOffsetWorldSpace=V(0,3,0)
 local t=Instance.new("TextLabel",g);t.Size=UDim2.fromScale(1,1);t.BackgroundColor3=navy;t.BackgroundTransparency=.12;t.Text=text;t.TextColor3=color;t.Font=Enum.Font.GothamBold;t.TextSize=14;t.TextWrapped=true;Instance.new("UICorner",t)
end
function A.Build(index)
 assert(index>=9 and index<=12,"Only new advanced courses can be authored")
 local levels=workspace.SkyfallSprint.Levels
 if levels:FindFirstChild("Level"..index) then return end
 local spec=require(game.ReplicatedStorage.SkyfallConfig).Levels[index];local accent=spec.Color
 local map=Instance.new("Folder");map.Name="Level"..index
 for _,n in {"Platforms","Hazards","Orbs","Checkpoints","RouteGates","Decor"} do Instance.new("Folder",map).Name=n end
 attr(map,{Number=index,Title=spec.Title,Sections=8,CheckpointCount=3,TotalOrbs=24,CourseLength=512,CourseCenterX=spec.X,AdvancedVersion=1})
 local layouts={
  [9]={{0,0,32},{0,-64,32},{64,-64,32},{64,-128,32},{128,-128,32},{128,-192,48},{64,-192,48},{0,-192,48},{0,-256,48}},
  [10]={{0,0,32},{0,-64,48},{64,-64,64},{64,0,80},{0,0,96},{0,-64,112},{64,-64,128},{64,0,144},{0,0,160}},
  [11]={{0,0,32},{0,-64,32},{64,-64,32},{64,-128,32},{0,-128,32},{0,-192,32},{64,-192,48},{128,-192,48},{128,-256,48}},
  [12]={{0,0,40},{0,-64,40},{-64,-64,40},{-64,-128,56},{0,-128,72},{0,-192,72},{64,-192,72},{64,-256,56},{0,-256,72}},
 }
 local hubs={};for _,c in layouts[index] do table.insert(hubs,V(spec.X+c[1],c[3],c[2])) end
 local serial=0
 local function deck(parent,name,size,cf,color)
  serial+=1;name=name.."_"..serial
  local model=Instance.new("Model");model.Name=name.."Assembly";model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;model.Parent=parent
  local p=part(model,name,size,cf,color or accent:Lerp(navy,.72));model.PrimaryPart=p
  local edges=Instance.new("Folder",p);edges.Name="OutlineDetails"
  for _,s in {-1,1} do
   local e=part(edges,"Rim",V(.12,.08,size.Z),cf*CFrame.new(s*(size.X/2-.06),size.Y/2+.04,0),accent,false);e.Material=Enum.Material.Neon;e.CanQuery=false
   local f=part(edges,"Rim",V(size.X,.08,.12),cf*CFrame.new(0,size.Y/2+.04,s*(size.Z/2-.06)),accent,false);f.Material=Enum.Material.Neon;f.CanQuery=false
  end
  return p
 end
 for j,pos in hubs do
  deck(map.Platforms,"Milestone"..(j-1),V(18,2,18),CFrame.new(pos-V(0,1,0)))
  if j>1 then
   local g=invisible(map.RouteGates,"Gate_"..(j-1),V(18,14,18),CFrame.new(pos+V(0,6,0)));g:SetAttribute("Section",j-1)
   if j<9 and (j-1)%2==0 then
    local stage=(j-1)/2;local cp=part(map.Checkpoints,"Checkpoint_"..stage,V(12,.15,10),CFrame.new(pos+V(0,.12,0)),Color3.fromRGB(90,245,180),false);cp.Material=Enum.Material.Neon;attr(cp,{Section=j-1,Stage=stage})
    invisible(cp,"ArrivalZone",V(18,14,18),CFrame.new(pos+V(0,6,0)));sign(map.Decor,"CHECKPOINT / "..stage,CFrame.new(pos+V(0,7,0)),accent)
   end
  end
 end
 invisible(map,"StartPosition",Vector3.one,CFrame.new(hubs[1]+V(0,3.5,4)))
 local start=part(map,"StartGate",V(17,10,.2),CFrame.new(hubs[1]+V(0,5,-6)),Color3.fromRGB(70,235,255),false);start.Transparency=.8;start.Material=Enum.Material.Neon
 part(map,"StartLine",V(17,.1,.3),CFrame.new(hubs[1]+V(0,.1,-6)),accent,false)
 invisible(map,"PortalTrigger",V(10,12,2),CFrame.new(hubs[9]+V(0,5,0)))
 sign(map.Decor,string.upper(spec.Title).." / FINISH",CFrame.new(hubs[9]+V(0,8,0)),accent)
 for section,kind in patterns[index] do
  local a,b=hubs[section],hubs[section+1];local rise=b.Y-a.Y;local basis=CFrame.lookAt(a,V(b.X,a.Y,b.Z));local group=Instance.new("Model");group.Name=string.format("%02d_%s",section,kind);group.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;group.Parent=map.Platforms
  local function cf(x,y,t) return basis*CFrame.new(x,y,-t) end
  local function floor(name,x,y,t,w,d) return deck(group,name,V(w,1,d),cf(x,y-.5,t)) end
  local function wall(x,y,t,w,h,d) return part(group,"MachineHousing",V(w,h,d),cf(x,y+h/2,t),accent:Lerp(navy,.8)) end
  local checks={}
  local function mark(x,y,t,follow)
   table.insert(checks,{Position=cf(x,y+3,t).Position,Frame=cf(x,y+3,t),Follow=follow})
  end
  local function hazard(name,size,frame,mode,phase,period,open)
   local h=part(map.Hazards,name.."_"..section.."_"..#map.Hazards:GetChildren(),size,frame,danger,false);h.Material=Enum.Material.Neon
   attr(h,{AdvancedHazard=mode,AdvancedFloor=mode=="Signal",Period=period or (index==12 and 5 or 5.8),Phase=phase or 0,OpenTime=open or 3.2,Section=section,Axis=basis.RightVector})
   return h
  end
  local function walkway(width)
   local p=floor("Walkway",0,0,32,width or 16,46)
   for _,s in {-1,1} do wall(s*((width or 16)/2+.3),0,32,.6,12,46) end
   return p
  end
  local function window(t,y,phase,width,centerX)
   centerX=centerX or 0;width=width or 20;local gap=9;local panel=(width-gap)/2
   for _,side in {-1,1} do
    local h=hazard("TravelingWindow",V(panel,10,.7),cf(centerX+side*(gap/2+panel/2),y+5,t),"Window",phase,7,4)
    attr(h,{Travel=3,PairSide=side})
   end
   for _,side in {-1,1} do wall(centerX+side*(width/2+.3),y,t,.6,13,9) end
  end
  local function vent(t,x,y,phase)
   local h=hazard("SteamVent",V(7,7,3),cf(x,y+3.5,t),"Steam",phase,5.6,3.7)
   local grate=part(map.Decor,"VentGrate",V(7,.1,3),cf(x,y+.06,t),Color3.fromRGB(147,171,180),false);grate.Material=Enum.Material.DiamondPlate;grate.CanQuery=false
   local at=Instance.new("Attachment",h);local e=Instance.new("ParticleEmitter",at);e.Name="SteamCue";e.Texture="rbxasset://textures/particles/smoke_main.dds";e.Rate=0;e.Lifetime=NumberRange.new(.35,.6);e.Speed=NumberRange.new(7,10);e.Size=NumberSequence.new(1.2);e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.5),NumberSequenceKeypoint.new(1,1)});e.SpreadAngle=Vector2.new(12,12)
  end
  local function gear(t,y,speed)
   local p=floor("GearDeck",0,y,t,24,24);p.Shape=Enum.PartType.Cylinder;p.Size=V(1.5,24,24);p.CFrame=cf(0,y-.75,t)*CFrame.Angles(0,0,math.pi/2)
   p.OutlineDetails:Destroy();attr(p,{AdvancedMotion="Gear",AngularSpeed=speed or .42,AdvancedCarry=true,RestFrame=p.CFrame})
   for k=1,16 do local theta=k*math.pi/8;local teeth=part(p,"GearTooth",V(2.8,1.5,2.8),cf(math.cos(theta)*11.5,y-.75,t-math.sin(theta)*11.5),accent,false);teeth.CanQuery=false
   end
   local axle=part(map.Decor,"Axle",V(2,9,2),cf(0,y-6,t),accent:Lerp(navy,.4),false);axle.CanQuery=false
   return p
  end
  local function stairs(phase,breakaway,sideways)
   for j=1,8 do
    local t=10+(j-1)*6;local y=rise*j/8;local x=sideways and (j<=3 and -3 or j>=6 and 3 or 0) or 0
    local p=floor("WallBalcony",x,y,t,10,6)
    if breakaway and j~=4 then attr(p,{AdvancedBreakaway=true,FallDelay=1.25}) end
    if phase and j~=4 and j%2==0 then vent(t,x,y,j*.8) end
    if j==2 or j==4 or j==7 then mark(x,y,t) end
   end
  end
  local function lift(withWindow)
   floor("LowerDock",0,0,16,14,14);floor("UpperDock",0,rise,48,14,14)
   local p=floor("ShaftLift",0,rise/2,32,14,18);attr(p,{AdvancedMotion="Lift",Travel=rise/2,Period=8,AdvancedCarry=true})
   for _,side in {-1,1} do wall(side*8,0,32,1,rise+14,20) end
   if withWindow then window(44,rise,0,14) end
   mark(0,0,17);mark(0,rise/2,32,p);mark(0,rise,49)
  end
  local function signalFloor(y,rows,offset)
   local width=20;floor("SignalBed",0,y,32,width,46)
   for row=1,rows do
    local t=12+(row-1)*40/(rows-1)
    for column=1,3 do
     local x=(column-2)*6.5;hazard("SignalTile",V(6.2,.18,4.5),cf(x,y+.12,t),"Signal",(offset or 0)+row*.55+column*1.7,6.4,4.5)
    end
   end
   for _,s in {-1,1} do wall(s*10.5,y,32,.6,12,46) end
   for j=1,3 do mark((j%2==0 and 1 or -1)*6.5,y,14+j*10) end
  end
  local function optionalRoute(y)
   -- Both branches pass the same wide route volumes; the gold relay is a legal shortcut.
   for _,side in {-1,1} do floor("SafeSideRoute",side*13,y,32,8,46).Color=Color3.fromRGB(65,165,211);floor("BranchEntry",side*7,y,11,20,6);floor("BranchExit",side*7,y,53,20,6) end
   for j=1,3 do local p=floor("GoldRelay",0,y,17+j*8,8,6);p.Color=gold;attr(p,{AdvancedMotion="Shuttle",Travel=2,Period=5,Phase=j,Axis=basis.RightVector,AdvancedCarry=true}) end
   sign(map.Decor,"BLUE / SAFE WALK     GOLD / OPTIONAL RELAY",cf(0,y+6,8),gold)
   for j=1,3 do mark(0,y,14+j*11) end
  end
  sign(map.Decor,string.format("%02d / %s",section,instructions[kind]),cf(0,8,5),accent)
  if kind=="GearTransfer" or kind=="DriveShaft" or kind=="GearWindow" then
   gear(18,0,.42);gear(46,0,-.46)
   if kind=="DriveShaft" then vent(19,0,0,0);vent(45,0,0,2.4) end
   if kind=="GearWindow" then floor("ExitCollar",0,0,54,18,10);window(53,0,0,18) end
   mark(0,0,18);mark(0,0,32);mark(0,0,46)
  elseif kind=="PistonDecks" then
   for j=1,3 do local t=16+(j-1)*16;local p=floor("PistonCarrier",0,0,t,14,12);attr(p,{AdvancedMotion="Shuttle",Travel=1.8,Period=6,Phase=j*1.4,Axis=basis.LookVector,AdvancedCarry=true});mark(0,0,t,p);wall(12,-7,t,5,8,8) end
  elseif kind=="PressureLine" or kind=="PressureEscape" then
   local belt=floor("PressureBelt",0,0,32,18,46);belt:SetAttribute("ExpansionBelt",basis.LookVector*5)
   for _,side in {-1,1} do local ranges=side==-1 and {{9,10},{22,55}} or {{9,31},{43,55}};for _,span in ranges do wall(side*9.3,0,(span[1]+span[2])/2,.6,12,span[2]-span[1]) end end
   for j=1,2 do local t=22+(j-1)*21;hazard("MachinePress",V(18,10,5),cf(0,5,t),"Press",j*2.5,6,3.6);floor("Refuge",j==1 and -12 or 12,0,t-6,8,9).Color=Color3.fromRGB(65,165,211) end
   mark(0,0,16);mark(0,0,33);mark(0,0,51)
  elseif kind=="RollingDrum" then
   local p=floor("DriveDrum",0,-5,32,12,46);p.Shape=Enum.PartType.Cylinder;p.Size=V(46,12,12);p.CFrame=cf(0,-6,32)*CFrame.Angles(0,math.pi/2,0);p.OutlineDetails:Destroy();attr(p,{AdvancedMotion="Drum",AngularSpeed=.22,AdvancedCarry=true})
   for j=1,12 do local stripe=part(p,"DrumStripe",V(42,.15,.4),p.CFrame*CFrame.new(0,math.cos(j*math.pi/6)*6,math.sin(j*math.pi/6)*6),accent,false);stripe.CanQuery=false end
   for j=1,3 do mark(0,0,14+j*11) end
  elseif kind=="WallLift" or kind=="LiftShaft" or kind=="LiftWindows" then lift(true)
  elseif kind=="SteamUnderpass" or kind=="UnderCore" then
   if rise~=0 then stairs(true,false,false) else walkway(16);vent(23,-3,0,0);vent(43,3,0,2.8);for j=1,3 do mark(0,0,14+j*11) end end
   part(map.Decor,"OverheadMachine",V(24,6,43),cf(0,15,32),accent:Lerp(navy,.7),false)
  elseif kind=="MachineInterior" or kind=="TravelingWindow" or kind=="CrossingWindows" then
   if kind=="MachineInterior" then optionalRoute(0) else walkway(20) end;window(23,0,0);window(45,0,kind=="CrossingWindows" and 2 or 0)
   for j=1,3 do mark(0,0,12+j*12) end
   if kind=="MachineInterior" then part(map.Decor,"EngineRoof",V(22,1,46),cf(0,14,32),navy,false) end
  elseif kind=="ExteriorClimb" or kind=="InteriorStairs" or kind=="WallSteps" or kind=="BreakawayBalconies" or kind=="BreakawayRise" or kind=="EchoStairs" then
   stairs(kind=="BreakawayRise" or kind=="EchoStairs",kind=="BreakawayBalconies" or kind=="BreakawayRise",true)
   if kind=="WallSteps" then for _,p in group:GetDescendants() do if p:IsA("BasePart") and p.Name:match("^WallBalcony") then attr(p,{AdvancedMotion="Shuttle",Travel=1.4,Period=6,Phase=p.Position.Y*.3,Axis=basis.RightVector,AdvancedCarry=true}) end end end
   if kind=="InteriorStairs" then for _,s in {-1,1} do wall(s*7,0,32,1,rise+12,46) end end
  elseif kind=="OrbitLanding" or kind=="CrownAscent" or kind=="PhaseOrbit" or kind=="SignalOrbit" then
   -- Split height gain between accessible balconies and a low-speed orbital transfer.
   for j=1,4 do local y=rise*j/4;floor("AccessLanding",-4,y,9+j*6,12,7) end
   local p=floor("OrbitCarrier",0,rise,40,12,12);attr(p,{AdvancedMotion="Orbit",Radius=3,Period=9,AdvancedCarry=true})
   floor("ExitLanding",0,rise,52,14,9)
   if kind=="PhaseOrbit" or kind=="SignalOrbit" then hazard("ExitSignal",V(14,.18,6),cf(0,rise+.1,52),"Signal",0,6,4.2) end
   mark(-4,rise/2,21);mark(0,rise,40,p);mark(0,rise,52)
  elseif kind=="SkyBridge" then
   -- Ascend to the upper-level branch; the reward is time, never required progression.
   for j=1,8 do floor("BranchClimb",-13,rise*j/8,10+j*5.5,8,6) end
   for j=1,4 do local p=floor("GoldLift",5,rise*j/4,12+j*10,9,7);p.Color=gold end
   floor("BranchJoin",0,rise,54,34,8)
   sign(map.Decor,"BLUE / BALCONY CLIMB     GOLD / FEWER LANDINGS",cf(0,6,8),gold)
   mark(0,rise/4,22);mark(0,rise/2,34);mark(0,rise*.8,46)
  elseif kind=="SignalFloor" or kind=="SafeZoneCircuit" then signalFloor(0,kind=="SafeZoneCircuit" and 8 or 5,0)
  elseif kind=="BeatBridge" then
   for j=1,7 do local p=floor("BeatTile",0,0,11+j*6,12,5)
    if j==3 or j==6 then p.Color=Color3.fromRGB(65,165,211) else attr(p,{AdvancedPhase=true,Period=6,OpenTime=4.7,Phase=j*.3}) end
   end
   mark(0,0,23);mark(0,0,35);mark(0,0,47)
  elseif kind=="PatternFinale" then signalFloor(0,5,0);window(43,0,1.4)
  elseif kind=="CoreNavigation" then
   floor("CoreRoom",0,0,32,30,46)
   for j=1,3 do local t=15+j*10;local side=j%2==0 and -1 or 1;wall(-side*5,0,t,20,14,1);window(t,0,j,10,side*10) end
   mark(10,0,22);mark(-10,0,32);mark(10,0,44)
  elseif kind=="SummitCircuit" then
   stairs(false,false,false)
   for j=1,2 do vent(17+j*15,0,rise*(17+j*15)/58,j*2) end
   window(52,rise,0,14);floor("FinalRefuge",0,rise,54,16,8)
  end
  -- Signals are read from safe hub landings; checkpoints follow pairs of rooms.
  if #checks==0 then for j=1,3 do mark(0,rise*j/3,12+j*12) end end
  local gate=map.RouteGates["Gate_"..section]
  for j=1,3 do
   local c=checks[math.clamp(math.ceil(#checks*j/3),1,#checks)];local node=invisible(gate,"Node_"..j,V(kind=="SkyBridge" and 38 or 32,16,10),c.Frame)
   local orb=part(map.Orbs,"Orb_"..((section-1)*3+j),Vector3.one*1.2,CFrame.new(c.Position-V(0,.4,0)),gold,false);orb.Shape=Enum.PartType.Ball;orb.Material=Enum.Material.Neon;orb.CanQuery=false;orb:SetAttribute("OrbId",(section-1)*3+j)
   if c.Follow then
    for _,o in {node,orb} do o:SetAttribute("AdvancedFollow",c.Follow.Name);o:SetAttribute("AdvancedOffset",c.Follow.CFrame:PointToObjectSpace(o.Position)) end
   end
  end
  task.wait()
 end
 local room=Instance.new("Model",map);room.Name="CourseSky";room.ModelStreamingMode=Enum.ModelStreamingMode.PersistentPerPlayer
 if index==10 then
  local core=part(room,"TowerCore",V(28,142,28),CFrame.new(spec.X+32,89,-32),accent:Lerp(navy,.78),false);core.Locked=true
  for n=0,8 do local y=32+n*16;for _,side in {-1,1} do local p=part(room,"TowerRib",V(1,1,58),CFrame.new(spec.X+32+side*27,y,-32),accent,false);p.Material=Enum.Material.Neon;p.Locked=true end end
 else
  for n=1,8 do local p=part(room,"DistantStructure",V(12,35+(n%3)*20,12),CFrame.new(spec.X+(n%2==0 and -70 or 170),25,-n*35),accent:Lerp(navy,.82),false);p.Locked=true end
 end
 map.Parent=levels
end
function A.Apply() for i=9,12 do A.Build(i) end end
return A
