-- Per-player breakaway balconies: one player cannot remove another player's floor.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local p=Players.LocalPlayer
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include
local started={}
local function appearance(part,alpha,color)
 part.Transparency=alpha;part.CanCollide=alpha<.5;part.Color=color
 local edges=part:FindFirstChild("OutlineDetails");if edges then for _,edge in edges:GetChildren() do edge.Transparency=alpha end end
end
RunService.RenderStepped:Connect(function()
 local t=os.clock()
 for part,state in pairs(started) do
  if not part.Parent then started[part]=nil
  elseif t-state.At>state.Delay+2.5 then appearance(part,0,state.Color);started[part]=nil
  elseif t-state.At>state.Delay then appearance(part,.85,state.Color)
  else appearance(part,0,Color3.fromRGB(255,202,79)) end
 end
 local level=p:GetAttribute("CurrentLevel") or 1;if level<9 then return end
 local maps=workspace:FindFirstChild("SkyfallSprint");local map=maps and maps.Levels:FindFirstChild("Level"..level)
 local char=p.Character;local root=char and char:FindFirstChild("HumanoidRootPart");local h=char and char:FindFirstChildOfClass("Humanoid")
 if not map or not root or not h or h.FloorMaterial==Enum.Material.Air then return end
 params.FilterDescendantsInstances={map.Platforms}
 local hit=workspace:Raycast(root.Position,Vector3.new(0,-5,0),params)
 local floor=hit and hit.Instance
 if floor and floor:GetAttribute("AdvancedBreakaway") and not started[floor] then started[floor]={At=t,Delay=floor:GetAttribute("FallDelay") or 1.25,Color=floor.Color} end
end)
