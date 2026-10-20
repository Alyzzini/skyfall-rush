-- Preserve imported/hand-edited geometry; builders are only a fallback for a missing world.
local tools=game.ServerStorage:WaitForChild("SkyfallBuildTools")
local function optionalVisual(name,target)
 local ok,message=pcall(function() return require(tools[name]).Apply(target) end)
 if not ok then warn("Skyfall visual pass "..name.." failed: "..tostring(message)) end
end
if not workspace:FindFirstChild("SkyfallSprint") then
 require(tools.BuildCourse)
 require(tools.ArtDirection)
end
require(tools.CourseEnvironments).Apply(workspace.SkyfallSprint)
optionalVisual("EmberMonuments",workspace.SkyfallSprint.Levels.Level2)
require(tools.CourseRefinement).Apply(workspace.SkyfallSprint)
require(tools.PhaseRestPlatforms).Apply(workspace.SkyfallSprint)
optionalVisual("PolishWorld",workspace.SkyfallSprint)
require(tools.ObstacleModels).Apply(workspace.SkyfallSprint)
require(tools.DifficultyProgression).Apply(workspace.SkyfallSprint)
require(tools.RestoreRouteCoins).Apply(workspace.SkyfallSprint)
require(tools.RouteRegistration).Apply(workspace.SkyfallSprint)
optionalVisual("PlatformOutlines",workspace.SkyfallSprint)
require(script.Parent.SkyfallRuntime)
local ready=game.ReplicatedStorage:FindFirstChild("SkyfallReady") or Instance.new("Folder")
ready.Name="SkyfallReady";ready.Parent=game.ReplicatedStorage
