-- Server motion and readable deterministic clocks for Levels 9-12 only.
local M={}
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local green=Color3.fromRGB(85,235,178)
local amber=Color3.fromRGB(255,202,79)
local red=Color3.fromRGB(255,85,109)
local function move(p,cf)
 local delta=cf*p.CFrame:Inverse()
 for _,child in p:GetDescendants() do if child:IsA("BasePart") then child.CFrame=delta*child.CFrame end end
 p.CFrame=cf
end
local function phaseVisual(p,solid,warning)
 p.CanCollide=solid;p.Transparency=solid and 0 or .78;p.Color=warning and amber or solid and green or Color3.fromRGB(190,116,232)
 local edges=p:FindFirstChild("OutlineDetails");if edges then for _,e in edges:GetChildren() do e.Transparency=p.Transparency end end
end
function M.Init()
 local motions={};local hazards={};local phases={};local followers={}
 for level=9,12 do
  local map=workspace.SkyfallSprint.Levels["Level"..level]
  for _,p in map.Platforms:GetDescendants() do if p:IsA("BasePart") then
   if p:GetAttribute("AdvancedMotion") then table.insert(motions,{Part=p,Base=p.CFrame,Level=level}) end
   if p:GetAttribute("AdvancedPhase") then table.insert(phases,{Part=p,Level=level}) end
  end end
  for _,p in map.Hazards:GetDescendants() do if p:IsA("BasePart") and p:GetAttribute("AdvancedHazard") then table.insert(hazards,{Part=p,Base=p.CFrame,Level=level}) end end
  for _,p in map:GetDescendants() do if p:IsA("BasePart") and p:GetAttribute("AdvancedFollow") then
   local target=map.Platforms:FindFirstChild(p:GetAttribute("AdvancedFollow"),true)
   assert(target and target:IsA("BasePart"),"Missing advanced platform "..tostring(p:GetAttribute("AdvancedFollow")))
   table.insert(followers,{Part=p,Target=target,Offset=p:GetAttribute("AdvancedOffset"),Level=level})
  end end
 end
 local accumulator=0
 RunService.Heartbeat:Connect(function(dt)
  accumulator+=dt;if accumulator<1/30 then return end;accumulator=0
  local time=workspace:GetServerTimeNow();local occupied={}
  for _,p in Players:GetPlayers() do occupied[p:GetAttribute("CurrentLevel") or 1]=true end
  for _,e in motions do if occupied[e.Level] then
   local p=e.Part;local mode=p:GetAttribute("AdvancedMotion");local angle=((time+(p:GetAttribute("Phase") or 0))%(p:GetAttribute("Period") or 8))/(p:GetAttribute("Period") or 8)*2*math.pi
   if mode=="Gear" then move(p,CFrame.new(e.Base.Position)*CFrame.Angles(0,(time*(p:GetAttribute("AngularSpeed") or .4))%(2*math.pi),0)*e.Base.Rotation)
   elseif mode=="Drum" then move(p,e.Base*CFrame.Angles((time*(p:GetAttribute("AngularSpeed") or .2))%(2*math.pi),0,0))
   elseif mode=="Lift" then move(p,e.Base+Vector3.yAxis*(math.sin(angle)*(p:GetAttribute("Travel") or 8)))
   elseif mode=="Shuttle" then move(p,e.Base+(p:GetAttribute("Axis") or Vector3.xAxis)*math.sin(angle)*(p:GetAttribute("Travel") or 2))
   elseif mode=="Orbit" then
    local r=p:GetAttribute("Radius") or 3;move(p,e.Base+Vector3.new(math.cos(angle)*r,0,math.sin(angle)*r))
   end
  end end
  for _,e in hazards do if occupied[e.Level] then
   local p=e.Part;local mode=p:GetAttribute("AdvancedHazard");local period=p:GetAttribute("Period");local phase=(time+(p:GetAttribute("Phase") or 0))%period
   if mode=="Window" then
    p.CFrame=e.Base+(p:GetAttribute("Axis")*math.sin(phase/period*2*math.pi)*(p:GetAttribute("Travel") or 3));p:SetAttribute("ExpansionInactive",false)
   else
    local safe=phase<p:GetAttribute("OpenTime");local warning=safe and phase>p:GetAttribute("OpenTime")-.85
    p:SetAttribute("ExpansionInactive",safe);p.Color=warning and amber or safe and green or red;p.Transparency=safe and .82 or .08
    if mode=="Press" then p.CFrame=e.Base+Vector3.new(0,safe and 13 or 0,0) end
    local steam=p:FindFirstChild("SteamCue",true)
    if steam then steam.Rate=safe and (warning and 3 or 0) or 7 end
   end
  end end
  for _,e in phases do if occupied[e.Level] then
   local p=e.Part;local q=(time+(p:GetAttribute("Phase") or 0))%p:GetAttribute("Period");local solid=q<p:GetAttribute("OpenTime")
   phaseVisual(p,solid,solid and q>p:GetAttribute("OpenTime")-.85)
  end end
  for _,e in followers do if occupied[e.Level] then e.Part.Position=e.Target.CFrame:PointToWorldSpace(e.Offset) end end
 end)
end
return M
