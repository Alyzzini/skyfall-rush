-- Each player sees the lighting for their current course. Backdrops never obstruct the camera.
local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local player=Players.LocalPlayer
local world=workspace:WaitForChild("SkyfallSprint")
local levels=world:WaitForChild("Levels")
player.CameraMaxZoomDistance=512
player.CameraMinZoomDistance=.5
local themes={
 {Clock=14,Color=Color3.fromRGB(190,225,255),Decay=Color3.fromRGB(113,158,211),Ambient=Color3.fromRGB(107,127,161),Density=.18,Haze=.4,CloudCover=.24},
 {Clock=17.7,Color=Color3.fromRGB(255,211,179),Decay=Color3.fromRGB(149,108,147),Ambient=Color3.fromRGB(139,115,129),Density=.20,Haze=.8,CloudCover=.16},
 {Clock=16,Color=Color3.fromRGB(168,186,220),Decay=Color3.fromRGB(73,86,130),Ambient=Color3.fromRGB(106,117,151),Density=.16,Haze=.8,CloudCover=.82},
 {Clock=0,Color=Color3.fromRGB(158,140,207),Decay=Color3.fromRGB(64,53,117),Ambient=Color3.fromRGB(108,105,151),Density=.02,Haze=.05,CloudCover=.02},
}
local sky=Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky")
sky.Name="CourseSkybox";sky.StarCount=5000;sky.CelestialBodiesShown=true;sky.Parent=Lighting
local clouds=workspace.Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds")
clouds.Name="CourseClouds";clouds.Parent=workspace.Terrain
local original=setmetatable({},{__mode="k"})
local function visibility(obj)
 local cursor=obj;local room=false;local map
 while cursor and cursor~=levels do
  if cursor.Name=="CourseSky" then room=true end
  if cursor.Parent==levels then map=cursor;break end
  cursor=cursor.Parent
 end
 if not map then return end
 local hidden=map.Name~="Level"..(player:GetAttribute("CurrentLevel") or 1)
 if obj:IsA("BasePart") then
  if hidden then
   if original[obj]==nil then original[obj]=obj.LocalTransparencyModifier end
   obj.LocalTransparencyModifier=1
  elseif original[obj]~=nil then obj.LocalTransparencyModifier=original[obj];original[obj]=nil end
 elseif obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") or obj:IsA("ProximityPrompt") or obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
  if hidden then if original[obj]==nil then original[obj]=obj.Enabled end;obj.Enabled=false
  elseif original[obj]~=nil then obj.Enabled=original[obj];original[obj]=nil end
 end
end
local function updateVisibility()
 for _,obj in levels:GetDescendants() do visibility(obj) end
end
levels.DescendantAdded:Connect(visibility)
local function update()
 local theme=themes[player:GetAttribute("CurrentLevel") or 1] or themes[1]
 Lighting.ClockTime=theme.Clock;Lighting.Ambient=theme.Ambient;Lighting.OutdoorAmbient=theme.Ambient:Lerp(Color3.new(1,1,1),.16)
 local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere")
 if atmosphere then atmosphere.Color=theme.Color;atmosphere.Decay=theme.Decay;atmosphere.Density=theme.Density;atmosphere.Haze=theme.Haze end
 clouds.Cover=theme.CloudCover;clouds.Density=.6;clouds.Color=theme.Color
 updateVisibility()
end
player:GetAttributeChangedSignal("CurrentLevel"):Connect(update)
game.ReplicatedStorage:WaitForChild("SkyfallAction").OnClientEvent:Connect(function(kind)
 if kind=="Reset" then task.defer(updateVisibility) end
end)
update()

