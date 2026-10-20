-- Mechanics scoped exclusively to the four expansion maps.
local M={}
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local function paint(p,color,alpha,solid)
 p.Color=color;p.Transparency=alpha;p.CanCollide=solid
 local edges=p:FindFirstChild("OutlineDetails")
 if edges then for _,e in edges:GetChildren() do e.Transparency=alpha end end
end
function M.Init()
 local hazards={};local bridges={}
 for level=5,8 do
  local map=workspace.SkyfallSprint.Levels["Level"..level]
  for _,p in map.Hazards:GetDescendants() do if p:IsA("BasePart") and p:GetAttribute("ExpansionMechanic") then table.insert(hazards,{Part=p,Base=p.CFrame,Level=level}) end end
  for _,p in map.Platforms:GetDescendants() do
   if p:IsA("BasePart") and p:GetAttribute("ExpansionBridge") then
    local key=level..":"..p:GetAttribute("Section");bridges[key]={Part=p,Until=0,Color=p.Color};paint(p,p.Color,.8,false)
   elseif p:IsA("BasePart") and p:GetAttribute("ExpansionCollapse") then
    local busy=false;local original=p.Color
    p.Touched:Connect(function(hit)
     local char=hit:FindFirstAncestorOfClass("Model");local player=char and Players:GetPlayerFromCharacter(char)
     if not player or player:GetAttribute("CurrentLevel")~=level or busy then return end
     busy=true;paint(p,Color3.fromRGB(255,205,83),0,true)
     task.delay(p:GetAttribute("FallDelay"),function()
      if not p.Parent then return end;paint(p,original,.85,false)
      task.delay(2,function() if p.Parent then paint(p,original,0,true);busy=false end end)
     end)
    end)
   end
  end
  for _,prompt in map.Platforms:GetDescendants() do if prompt:IsA("ProximityPrompt") and prompt:GetAttribute("ExpansionSwitch") then
   local key=level..":"..prompt:GetAttribute("ExpansionSwitch")
   prompt.Triggered:Connect(function(player)
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if player:GetAttribute("CurrentLevel")~=level or not root or (root.Position-prompt.Parent.Position).Magnitude>12 then return end
    bridges[key].Until=workspace:GetServerTimeNow()+14
   end)
  end end
 end
 local elapsed=0
 RunService.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<1/30 then return end;elapsed=0
  local t=workspace:GetServerTimeNow();local active={}
  for _,p in Players:GetPlayers() do active[p:GetAttribute("CurrentLevel") or 1]=true end
  for _,entry in hazards do if active[entry.Level] then
   local p=entry.Part;local kind=p:GetAttribute("ExpansionMechanic");local period=p:GetAttribute("Period");local phase=(t+(p:GetAttribute("Phase") or 0))%period
   if kind=="Pulse" or kind=="Press" then
    local open=p:GetAttribute("OpenTime");local safe=phase<open;local warning=safe and phase>open-.65
    p:SetAttribute("ExpansionInactive",safe)
    p.Color=warning and Color3.fromRGB(255,198,75) or safe and Color3.fromRGB(89,244,178) or Color3.fromRGB(255,83,105)
    p.Transparency=safe and .88 or .08
    if kind=="Press" then p.CFrame=entry.Base+Vector3.new(0,safe and 11 or 0,0) end
   else
    local angle=phase/period*math.pi*2;local swing=math.sin(angle)*1.1;local distance=kind=="Pendulum" and math.sin(swing)*7 or math.sin(angle)*8
    p.CFrame=entry.Base+(p:GetAttribute("Axis")*distance)+(kind=="Pendulum" and Vector3.new(0,(1-math.cos(swing))*7,0) or Vector3.zero)
    p:SetAttribute("ExpansionInactive",false)
   end
  end end
  for _,entry in bridges do
   local remaining=entry.Until-t;local p=entry.Part
   -- A player occupying the bridge never has it removed under their feet.
   if remaining<=0 then for _,player in Players:GetPlayers() do
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then local q=p.CFrame:PointToObjectSpace(root.Position);if math.abs(q.X)<p.Size.X/2+1 and math.abs(q.Z)<p.Size.Z/2+1 and q.Y>0 and q.Y<7 then entry.Until=t+1;remaining=1 end end
   end end
   paint(p,remaining>0 and remaining<3 and Color3.fromRGB(255,205,83) or entry.Color,remaining>0 and 0 or .8,remaining>0)
  end
 end)
end
return M
