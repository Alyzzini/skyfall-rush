-- Each player sees the lighting for their current course. Backdrops never obstruct the camera.
local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local player=Players.LocalPlayer
local world=workspace:WaitForChild("SkyfallSprint")
local levels=world:WaitForChild("Levels")
player.CameraMaxZoomDistance=512
player.CameraMinZoomDistance=.5
local themes={
 {Clock=13.3,Color=Color3.fromRGB(187,225,255),Decay=Color3.fromRGB(106,166,218),Ambient=Color3.fromRGB(105,143,171),Density=.10,Haze=.15,CloudCover=.16,Tint=Color3.fromRGB(255,249,239)},
 {Clock=15.8,Color=Color3.fromRGB(255,211,173),Decay=Color3.fromRGB(177,119,151),Ambient=Color3.fromRGB(166,133,133),Density=.10,Haze=.25,CloudCover=.08,Tint=Color3.fromRGB(255,239,219)},
 {Clock=13.8,Color=Color3.fromRGB(185,210,255),Decay=Color3.fromRGB(111,137,196),Ambient=Color3.fromRGB(132,149,189),Density=.08,Haze=.25,CloudCover=.38,Tint=Color3.fromRGB(238,243,255)},
 {Clock=0,Color=Color3.fromRGB(185,160,235),Decay=Color3.fromRGB(105,84,158),Ambient=Color3.fromRGB(151,136,183),Density=.015,Haze=0,CloudCover=0,Tint=Color3.fromRGB(255,237,250)},
}
local sky=Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky")
sky.Name="CourseSkybox";sky.StarCount=5000;sky.CelestialBodiesShown=true;sky.Parent=Lighting
local clouds=workspace.Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds")
clouds.Name="CourseClouds";clouds.Parent=workspace.Terrain
-- Course shells provide visual separation. Never mask shared obstacles by level:
-- cached transparency can survive a transition or streamed-instance replacement.
-- Coins have separate per-player visibility owned by SkyfallClient.
local function restoreGeometry(obj)
 if obj:IsA("BasePart") and obj:GetAttribute("OrbId")==nil then
  obj.LocalTransparencyModifier=0
 end
end
local function restoreCourseGeometry()
 for _,obj in levels:GetDescendants() do restoreGeometry(obj) end
end
levels.DescendantAdded:Connect(restoreGeometry)
local function update()
 local theme=themes[player:GetAttribute("CurrentLevel") or 1] or themes[1]
 Lighting.ClockTime=theme.Clock;Lighting.Ambient=theme.Ambient;Lighting.OutdoorAmbient=theme.Ambient:Lerp(Color3.new(1,1,1),.16)
 Lighting.Brightness=3;Lighting.ExposureCompensation=.12
 local color=Lighting:FindFirstChild("SkyfallColor")
 if color then color.Saturation=.22;color.Contrast=.06;color.Brightness=.015;color.TintColor=theme.Tint end
 local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere")
 if atmosphere then atmosphere.Color=theme.Color;atmosphere.Decay=theme.Decay;atmosphere.Density=theme.Density;atmosphere.Haze=theme.Haze end
 local low=player:GetAttribute("LowGraphics")==true
 Lighting.GlobalShadows=not low
 local bloom=Lighting:FindFirstChild("SkyfallBloom");if bloom then bloom.Enabled=not low;bloom.Intensity=.08;bloom.Threshold=1.7;bloom.Size=12 end
 clouds.Cover=low and 0 or theme.CloudCover;clouds.Density=.45;clouds.Color=theme.Color
 restoreCourseGeometry()
end
player:GetAttributeChangedSignal("CurrentLevel"):Connect(update)
player:GetAttributeChangedSignal("LowGraphics"):Connect(update)
game.ReplicatedStorage:WaitForChild("SkyfallAction").OnClientEvent:Connect(function(kind)
 if kind=="Reset" then task.defer(restoreCourseGeometry) end
end)
player.CharacterAdded:Connect(function() task.defer(restoreCourseGeometry) end)
update()

