-- Spacious, noncolliding sky rooms. Apply after importing or generating a world.
-- Moving entire courses preserves all hand-edited trees and obstacle relationships.
local Environments={}
local themes={
 {Top=Color3.fromRGB(43,137,224),Horizon=Color3.fromRGB(167,222,246),Clouds=true},
 {Top=Color3.fromRGB(100,74,142),Horizon=Color3.fromRGB(255,187,143),Clouds=true},
 {Top=Color3.fromRGB(36,48,88),Horizon=Color3.fromRGB(133,158,199)},
 {Top=Color3.fromRGB(19,20,56),Horizon=Color3.fromRGB(128,77,152),Stars=true},
}
local function part(parent,name,size,pos,color)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Color=color;p.Material=Enum.Material.SmoothPlastic;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function solidSky(p,face,color)
 local s=Instance.new("SurfaceGui");s.Name="SkyIllusion";s.Face=face;s.CanvasSize=Vector2.new(8,8);s.LightInfluence=0;s.MaxDistance=10000;s.Parent=p
 local f=Instance.new("Frame");f.Size=UDim2.fromScale(1,1);f.BorderSizePixel=0;f.BackgroundColor3=color;f.Parent=s
end
local function paint(p,face,theme,seed)
 local surface=Instance.new("SurfaceGui");surface.Name="SkyIllusion";surface.Face=face;surface.CanvasSize=Vector2.new(1024,1024);surface.LightInfluence=0;surface.MaxDistance=10000;surface.Parent=p
 local background=Instance.new("Frame");background.Size=UDim2.fromScale(1,1);background.BorderSizePixel=0;background.BackgroundColor3=Color3.new(1,1,1);background.Parent=surface
 local gradient=Instance.new("UIGradient");gradient.Rotation=90;gradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,theme.Top),ColorSequenceKeypoint.new(.57,theme.Horizon),ColorSequenceKeypoint.new(1,theme.Horizon)});gradient.Parent=background
 local random=Random.new(seed)
 if theme.Stars then
  for i=1,18 do local star=Instance.new("Frame");star.BorderSizePixel=0;star.BackgroundColor3=Color3.fromRGB(225,234,255);star.BackgroundTransparency=random:NextNumber(.1,.65);local size=random:NextInteger(1,3);star.Size=UDim2.fromOffset(size,size);star.Position=UDim2.fromScale(random:NextNumber(.03,.97),random:NextNumber(.02,.44));star.Parent=background end
 elseif theme.Clouds then
  for row=1,2 do
   local x=random:NextNumber(.1,.5);local y=.44+row*.06
   for i=1,5 do local cloud=Instance.new("Frame");cloud.BorderSizePixel=0;cloud.BackgroundColor3=Color3.fromRGB(241,244,255);cloud.BackgroundTransparency=.76+math.abs(i-3)*.04;cloud.Size=UDim2.fromScale(.20,.014+((i%2)*.009));cloud.Position=UDim2.fromScale(x+(i-1)*.048,y);cloud.Parent=background;local c=Instance.new("UICorner");c.CornerRadius=UDim.new(1,0);c.Parent=cloud end
  end
 end
end
function Environments.Apply(world)
 world=world or workspace:WaitForChild("SkyfallSprint")
 local result={}
 for index=1,4 do
  local map=world.Levels:FindFirstChild("Level"..index)
  if map then
   local oldRoom=map:FindFirstChild("CourseSky");if oldRoom then oldRoom:Destroy() end
   local targetX=(index-1)*4096;local offset=Vector3.new(targetX-map.StartPosition.Position.X,0,0)
   if offset.Magnitude>.01 then
    local n=0
    for _,obj in map:GetDescendants() do
     if obj:IsA("BasePart") then obj.CFrame+=offset;n+=1;if n%500==0 then task.wait() end end
     if obj:IsA("Model") and obj:GetAttribute("SpinVisual") then obj.ModelStreamingMode=Enum.ModelStreamingMode.Atomic end
     local center=obj:GetAttribute("VisualCenter");if typeof(center)=="Vector3" then obj:SetAttribute("VisualCenter",center+offset) end
    end
   end
   local length=map:GetAttribute("CourseLength") or (map:GetAttribute("Sections") or index*4+4)*96
   -- Preserve the user's floor, including its trigger settings, and make it invisible.
   local catcher=map.Hazards:FindFirstChild("Hurdle_Bottem") or map.Hazards:FindFirstChild("FallCatcher")
   if not catcher then catcher=part(map.Hazards,"FallCatcher",Vector3.new(400,1.3,math.min(2048,length+100)),Vector3.new(targetX,-10.35,-length/2),Color3.fromRGB(255,88,91));catcher:SetAttribute("Kind","Static") end
   catcher.Transparency=1;catcher.CastShadow=false;catcher:SetAttribute("InvisibleFallCatcher",true)
   local room=Instance.new("Model");room.Name="CourseSky";room.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;room:SetAttribute("VisualOnly",true);room:SetAttribute("Theme",({"Blue sky gardens","Amber sunset","Storm horizon","Starlit orbit"})[index]);room.Parent=map
   local theme=themes[index];local half=1100;local front=900;local back=-length-900;local bottom=-700;local top=900
   local zCount=math.ceil((front-back)/1024);local zSize=(front-back)/zCount;local xCount=3;local xSize=half*2/xCount
   for z=1,zCount do
    local centerZ=back+(z-.5)*zSize
    for _,side in {-1,1} do local wall=part(room,"SkyHorizon",Vector3.new(4,top-bottom,zSize),Vector3.new(targetX+side*half,(top+bottom)/2,centerZ),theme.Horizon);paint(wall,side==-1 and Enum.NormalId.Right or Enum.NormalId.Left,theme,index*1000+z*10+side) end
    for x=1,xCount do
     local centerX=targetX-half+(x-.5)*xSize
     solidSky(part(room,"UpperSky",Vector3.new(xSize,4,zSize),Vector3.new(centerX,top,centerZ),theme.Top),Enum.NormalId.Bottom,theme.Top)
     solidSky(part(room,"LowerSky",Vector3.new(xSize,4,zSize),Vector3.new(centerX,bottom,centerZ),theme.Horizon),Enum.NormalId.Top,theme.Horizon)
    end
   end
   for x=1,xCount do
    local centerX=targetX-half+(x-.5)*xSize
    for _,endSide in {-1,1} do local wall=part(room,"DistantSky",Vector3.new(xSize,top-bottom,4),Vector3.new(centerX,(top+bottom)/2,endSide==-1 and back or front),theme.Horizon);paint(wall,endSide==-1 and Enum.NormalId.Back or Enum.NormalId.Front,theme,index*100+x*3+endSide) end
   end
   map:SetAttribute("CourseCenterX",targetX);map:SetAttribute("SkyRoomVersion",1)
   table.insert(result,{Level=index,X=targetX,RoomWidth=half*2,RoomHeight=top-bottom,RoomLength=front-back})
   task.wait()
  end
 end
 game.StarterPlayer.CameraMaxZoomDistance=512
 world:SetAttribute("EnvironmentVersion","SkyRooms_1")
 return result
end
return Environments
