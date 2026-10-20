-- A permanent centered landing in every phase-platform chain.
local PhaseRests={}
function PhaseRests.Apply(world)
 world=world or workspace:WaitForChild("SkyfallSprint")
 local changes={}
 for _,map in world.Levels:GetChildren() do
  local groups={}
  for _,p in map.Platforms:GetChildren() do
   if p:IsA("BasePart") and p:GetAttribute("PhasePlatform")==true then
    local section=p.Name:match("^Step_(%d+)_")
    if section then groups[section]=groups[section] or {};table.insert(groups[section],p) end
   end
  end
  for section,pads in pairs(groups) do
   table.sort(pads,function(a,b) return a.Position.Z>b.Position.Z end)
   local left=pads[math.max(1,math.floor(#pads/2))]
   local right=pads[math.min(#pads,math.floor(#pads/2)+1)]
   local middle=(left.Position+right.Position)/2
   local name="PhaseRest_"..section
   local rest=map.Platforms:FindFirstChild(name) or Instance.new("Part")
   rest.Name=name;rest.Size=Vector3.new(14,2,16);rest.CFrame=CFrame.new(middle+Vector3.new(0,.25,0))
   rest.Anchored=true;rest.CanCollide=true;rest.CanTouch=true;rest.CanQuery=true;rest.Transparency=0
   rest.Color=Color3.fromRGB(42,83,93);rest.Material=Enum.Material.DiamondPlate
   rest.TopSurface=Enum.SurfaceType.Smooth;rest.BottomSurface=Enum.SurfaceType.Smooth
   rest:SetAttribute("PhasePlatform",nil);rest:SetAttribute("Crumble",nil);rest:SetAttribute("Moving",nil)
   rest:SetAttribute("PermanentRest",true);rest:SetAttribute("PhaseSection",tonumber(section));rest.Parent=map.Platforms
   local old=rest:FindFirstChild("RestDetails");if old then old:Destroy() end
   local details=Instance.new("Folder");details.Name="RestDetails";details.Parent=rest
   for _,side in {-1,1} do
    local light=Instance.new("Part");light.Name="AlwaysSolidGuide";light.Anchored=true;light.CanCollide=false;light.CanTouch=false;light.CanQuery=false;light.Size=Vector3.new(.22,.12,15.5);light.CFrame=rest.CFrame*CFrame.new(side*6.7,1.07,0);light.Color=Color3.fromRGB(128,255,180);light.Material=Enum.Material.Neon;light.Parent=details
   end
   local sign=Instance.new("BillboardGui");sign.Name="RestSign";sign.Size=UDim2.fromOffset(160,25);sign.StudsOffset=Vector3.new(0,3.5,0);sign.MaxDistance=55;sign.Parent=details;sign.Adornee=rest
   local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Text="REST / ALWAYS SOLID";text.TextSize=12;text.Font=Enum.Font.GothamBold;text.TextColor3=Color3.fromRGB(157,255,193);text.TextStrokeTransparency=.5;text.Parent=sign
   table.insert(changes,{Level=map.Name,Section=tonumber(section)+1,Position=tostring(rest.Position)})
  end
 end
 world:SetAttribute("PhaseRestVersion",1)
 return changes
end
return PhaseRests
