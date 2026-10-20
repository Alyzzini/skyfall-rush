-- Preserve imported/hand-edited geometry; builders are only a fallback for a missing world.
local tools=game.ServerStorage:WaitForChild("SkyfallBuildTools")
if not workspace:FindFirstChild("SkyfallSprint") then
 require(tools.BuildCourse)
 require(tools.ArtDirection)
end
require(tools.CourseEnvironments).Apply(workspace.SkyfallSprint)
require(tools.PhaseRestPlatforms).Apply(workspace.SkyfallSprint)
require(tools.PolishWorld).Apply(workspace.SkyfallSprint)
local ready=game.ReplicatedStorage:FindFirstChild("SkyfallReady") or Instance.new("Folder")
ready.Name="SkyfallReady";ready.Parent=game.ReplicatedStorage
require(script.Parent.SkyfallRuntime)
