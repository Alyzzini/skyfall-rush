-- A fresh Rojo build creates the complete procedural world at the start of Play.
-- Existing Studio worlds are preserved; the editor builders are also available manually.
local tools=game:GetService("ServerStorage"):WaitForChild("SkyfallBuildTools")
if not workspace:FindFirstChild("SkyfallSprint") then
    require(tools.BuildCourse)
    require(tools.ArtDirection)
end
local ready=game.ReplicatedStorage:FindFirstChild("SkyfallReady") or Instance.new("Folder")
ready.Name="SkyfallReady"
ready.Parent=game.ReplicatedStorage
require(script.Parent.SkyfallRuntime)
