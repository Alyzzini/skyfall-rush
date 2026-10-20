-- An enclosing capsule-shaped sky shell with real 3D scenery inside it.
-- The shell has rounded end caps, so a player never looks into a square corner.
local Environments={}
local colors={Color3.fromRGB(108,185,231),Color3.fromRGB(104,69,112),Color3.fromRGB(48,65,92),Color3.fromRGB(8,9,26)}
local function part(parent,name,size,cf,color,material)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function ball(parent,name,size,pos,color,material,alpha)
 local p=part(parent,name,size,CFrame.new(pos),color,material);p.Shape=Enum.PartType.Ball;p.Transparency=alpha or 0;return p
end
local function beam(parent,name,a,b,width,color,material)
 return part(parent,name,Vector3.new(width,width,(b-a).Magnitude+1),CFrame.lookAt((a+b)/2,b),color,material)
end
local function ring(parent,name,cf,radius,color,width)
 for i=1,32 do
  local a=(i-1)*math.pi/16;local b=i*math.pi/16
  beam(parent,name,cf:PointToWorldSpace(Vector3.new(math.cos(a)*radius,0,math.sin(a)*radius)),cf:PointToWorldSpace(Vector3.new(math.cos(b)*radius,0,math.sin(b)*radius)),width or 5,color,Enum.Material.Neon)
 end
end
local function shellPanel(parent,a,b,width,normalHint,color)
 local along=(b-a).Unit
 local theta=math.atan2(normalHint.Y/1000,normalHint.X/1250)
 local right=Vector3.new(-1250*math.sin(theta),1000*math.cos(theta),0).Unit
 local normal=along:Cross(right).Unit
 if normal:Dot(normalHint)<0 then normal=-normal end
 local up=normal:Cross(right).Unit
 -- Neon is unlit on every face; overlapping panels cannot reveal shaded seams.
 part(parent,"CurvedSky",Vector3.new(width+14,(b-a).Magnitude+14,6),CFrame.fromMatrix((a+b)/2,right,up,normal),color:Lerp(Color3.new(0,0,0),.55),Enum.Material.Neon)
end
local function buildShell(parent,x,length,color)
 local rx,ry,rz,cy=1250,1000,1250,100
 local segments=24
 local front,back=300,-length-300
 local function point(theta,factor,z) return Vector3.new(x+rx*math.cos(theta)*factor,cy+ry*math.sin(theta)*factor,z) end
 local bodyCount=math.ceil((front-back)/1000)
 for i=1,segments do
  local a=(i-1)*math.pi*2/segments;local b=i*math.pi*2/segments;local theta=(a+b)/2
  local hint=Vector3.new(rx*math.cos(theta),ry*math.sin(theta),0)
  local width=(point(a,1,0)-point(b,1,0)).Magnitude
  for section=1,bodyCount do
   local z1=back+(front-back)*(section-1)/bodyCount;local z2=back+(front-back)*section/bodyCount
   local mid1=(point(a,1,z1)+point(b,1,z1))/2;local mid2=(point(a,1,z2)+point(b,1,z2))/2
   shellPanel(parent,mid1,mid2,width,hint,color)
  end
  for _,endSign in {-1,1} do
   local z0=endSign==1 and front or back
   for band=1,5 do
    local phi1=(band-1)*math.pi/10;local phi2=band*math.pi/10
    local k1,k2=math.cos(phi1),math.cos(phi2)
    local z1=z0+endSign*rz*math.sin(phi1);local z2=z0+endSign*rz*math.sin(phi2)
    local mid1=(point(a,k1,z1)+point(b,k1,z1))/2;local mid2=(point(a,k2,z2)+point(b,k2,z2))/2
    shellPanel(parent,mid1,mid2,width*k1,Vector3.new(hint.X,hint.Y,endSign*rz*math.sin((phi1+phi2)/2)),color)
   end
  end
 end
end
local function cloud(parent,center,size,color,seed)
 local r=Random.new(seed)
 for i=1,5 do
  local offset=Vector3.new((i-3)*size*.36,r:NextNumber(-.1,.1)*size,r:NextNumber(-.2,.2)*size)
  ball(parent,"CloudVolume",Vector3.new(size,size*.42,size*.85),center+offset,color,Enum.Material.SmoothPlastic,.13)
 end
end
local function garden(parent,center,seed)
 local random=Random.new(seed)
 part(parent,"DistantIsland",Vector3.new(220,80,200),CFrame.new(center)*CFrame.Angles(.1,random:NextNumber(0,3),.05),Color3.fromRGB(65,91,96),Enum.Material.Slate)
 part(parent,"DistantMeadow",Vector3.new(224,10,204),CFrame.new(center+Vector3.new(0,44,0)),Color3.fromRGB(74,151,119),Enum.Material.Grass)
 for i=1,3 do
  local p=center+Vector3.new((i-2)*60,78,random:NextNumber(-55,55))
  part(parent,"DistantTree",Vector3.new(10,70,10),CFrame.new(p),Color3.fromRGB(73,104,91),Enum.Material.Wood)
  ball(parent,"DistantCanopy",Vector3.new(75,43,65),p+Vector3.new(0,42,0),Color3.fromRGB(99,187,148))
 end
end
local function foundry(parent,center,seed)
 local random=Random.new(seed)
 for i=1,5 do
  local h=random:NextNumber(100,260);local p=center+Vector3.new((i-3)*35,h/2-80,random:NextNumber(-50,50))
  part(parent,"ObsidianButte",Vector3.new(65,h,85),CFrame.new(p)*CFrame.Angles(.1,random:NextNumber(0,3),.15),Color3.fromRGB(73,48,61),Enum.Material.Slate)
  beam(parent,"EmberFissure",p-Vector3.new(0,h*.4,0),p+Vector3.new(0,h*.4,0),3,Color3.fromRGB(255,133,71),Enum.Material.Neon)
 end
 for _,side in {-1,1} do part(parent,"AncientPillar",Vector3.new(18,210,18),CFrame.new(center+Vector3.new(side*90,80,0)),Color3.fromRGB(125,81,66),Enum.Material.Slate) end
 part(parent,"AncientArch",Vector3.new(210,22,24),CFrame.new(center+Vector3.new(0,185,0))*CFrame.Angles(0,0,.08),Color3.fromRGB(155,100,70),Enum.Material.Slate)
end
local function storm(parent,center,seed)
 cloud(parent,center+Vector3.new(0,340,0),190,Color3.fromRGB(102,120,152),seed)
 local points={center+Vector3.new(0,360,0),center+Vector3.new(30,285,0),center+Vector3.new(-12,210,8),center+Vector3.new(35,150,0),center+Vector3.new(5,75,0)}
 for i=1,4 do beam(parent,"DistantLightning",points[i],points[i+1],5,Color3.fromRGB(187,191,255),Enum.Material.Neon) end
 part(parent,"StormSpire",Vector3.new(24,260,24),CFrame.new(center+Vector3.new(0,-100,0)),Color3.fromRGB(53,65,91),Enum.Material.Metal)
 ring(parent,"CollectorRing",CFrame.new(center+Vector3.new(0,10,0)),100,Color3.fromRGB(135,133,231),4)
end
local function planet(parent,center,radius,color,hasRings)
 ball(parent,"Planet",Vector3.one*radius*2,center,color)
 for band=-2,2 do
  local y=band*radius*.24;local ringRadius=math.sqrt(radius*radius-y*y)+1
  local p=part(parent,"PlanetCloudBand",Vector3.new(6,ringRadius*2,ringRadius*2),CFrame.new(center+Vector3.new(0,y,0))*CFrame.Angles(0,0,math.pi/2),color:Lerp(Color3.fromRGB(255,218,172),band%2==0 and .45 or .16))
  p.Shape=Enum.PartType.Cylinder
 end
 if hasRings then
  local cf=CFrame.new(center)*CFrame.Angles(.34,0,.30)
  ring(parent,"PlanetRing",cf,radius*1.50,Color3.fromRGB(208,166,229),7)
  ring(parent,"PlanetRing",cf,radius*1.68,Color3.fromRGB(126,139,207),4)
 end
end
local function buildScenery(room,index,x,length)
 local parent=Instance.new("Folder");parent.Name="SurroundingWorld";parent.Parent=room
 local count=math.max(3,math.ceil(length/400))
 for i=1,count do
  local z=100-(i-1)*(length+200)/(count-1)
  for _,side in {-1,1} do
   local center=Vector3.new(x+side*860,-15,z)
   if index==1 then
    garden(parent,center,index*100+i*7+side)
    cloud(parent,center+Vector3.new(0,400,80),150,Color3.fromRGB(231,244,250),i*9+side)
   elseif index==2 then foundry(parent,center,index*100+i*7+side)
   elseif index==3 then storm(parent,center,index*100+i*7+side)
   else
    local r=Random.new(i*47+side)
    for j=1,5 do
     local pos=center+Vector3.new(r:NextNumber(-40,40),r:NextNumber(-160,270),r:NextNumber(-100,100))
     local rock=ball(parent,"Asteroid",Vector3.new(r:NextNumber(24,65),r:NextNumber(22,60),r:NextNumber(24,70)),pos,Color3.fromRGB(93,83,116),Enum.Material.Slate)
     rock.CFrame*=CFrame.Angles(r:NextNumber(0,3),r:NextNumber(0,3),r:NextNumber(0,3))
    end
   end
  end
  if index==1 then cloud(parent,Vector3.new(x,-700,z),240,Color3.fromRGB(205,230,243),i*3) end
 end
 if index==2 then
  ball(parent,"SettingSun",Vector3.one*280,Vector3.new(x-500,660,-length-700),Color3.fromRGB(255,161,102),Enum.Material.Neon)
 elseif index==4 then
  planet(parent,Vector3.new(x-600,650,-900),175,Color3.fromRGB(152,125,188),true)
  planet(parent,Vector3.new(x+890,260,-length*.55),100,Color3.fromRGB(106,151,192),false)
  ball(parent,"DistantStar",Vector3.one*240,Vector3.new(x,340,-length-1000),Color3.fromRGB(255,184,143),Enum.Material.Neon)
  local r=Random.new(2401)
  for i=1,180 do
   local a=r:NextNumber(0,math.pi*2);local z=r:NextNumber(-length-180,180)
   local p=Vector3.new(x+math.cos(a)*1130,100+math.sin(a)*880,z)
   local size=r:NextNumber(1.6,5)
   ball(parent,"Star",Vector3.one*size,p,Color3.fromRGB(208+r:NextInteger(0,47),213+r:NextInteger(0,42),255),Enum.Material.Neon)
  end
 end
end
function Environments.Apply(world)
 world=world or workspace:WaitForChild("SkyfallSprint")
 local result={}
 for index=1,4 do
  local map=world.Levels:FindFirstChild("Level"..index)
  if map then
   local old=map:FindFirstChild("CourseSky");if old then old:Destroy() end
   local x=(index-1)*4096;local offset=Vector3.new(x-map.StartPosition.Position.X,0,0)
   if offset.Magnitude>.01 then
    local n=0
    for _,obj in map:GetDescendants() do
     if obj:IsA("BasePart") then obj.CFrame+=offset;n+=1;if n%500==0 then task.wait() end end
     local center=obj:GetAttribute("VisualCenter");if typeof(center)=="Vector3" then obj:SetAttribute("VisualCenter",center+offset) end
    end
   end
   local length=map:GetAttribute("CourseLength") or map:GetAttribute("Sections")*96
   local catcher=map.Hazards:FindFirstChild("Hurdle_Bottem") or map.Hazards:FindFirstChild("FallCatcher")
   if not catcher then catcher=part(map.Hazards,"FallCatcher",Vector3.new(400,1.3,math.min(2048,length+100)),CFrame.new(x,-10.35,-length/2),Color3.fromRGB(255,88,91));catcher:SetAttribute("Kind","Static") end
   catcher.Transparency=1;catcher.CastShadow=false;catcher:SetAttribute("InvisibleFallCatcher",true)
   local room=Instance.new("Model");room.Name="CourseSky";room.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;room:SetAttribute("VisualOnly",true);room:SetAttribute("Theme",({"Cloud Garden Realm","Ember Canyon","Tempest Citadel","Orbital Expanse"})[index]);room.Parent=map
   local shell=Instance.new("Folder");shell.Name="EnclosingSky";shell.Parent=room
   buildShell(shell,x,length,colors[index]);task.wait()
   buildScenery(room,index,x,length);task.wait()
   map:SetAttribute("CourseCenterX",x);map:SetAttribute("SkyRoomVersion",2)
   table.insert(result,{Level=index,Theme=room:GetAttribute("Theme"),Instances=#room:GetDescendants()})
  end
 end
 game.StarterPlayer.CameraMaxZoomDistance=512
 world:SetAttribute("EnvironmentVersion","ImmersiveWorlds_2")
 return result
end
return Environments
