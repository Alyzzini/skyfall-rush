-- ServerScriptService > SkyfallRuntime (ModuleScript). All timing, skips, money and records are server owned.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local PhysicsService=game:GetService("PhysicsService")
local Config=require(game.ReplicatedStorage.SkyfallConfig)
local Rules=require(script.Parent.SkyfallRules)
local Services=require(script.Parent.SkyfallServices)
local Runtime={Runs={}}
local runs=Runtime.Runs
local maps=workspace.SkyfallSprint.Levels
local action=game.ReplicatedStorage.SkyfallAction
local query=game.ReplicatedStorage.SkyfallQuery
local hazards={}; local phasePads={}; local ferries={}; local following={}
local now=function() return workspace:GetServerTimeNow() end
local function rootOf(p) return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end
local function mapOf(r) return maps["Level"..r.level] end
local function tell(p,message) p:SetAttribute("Message",message); p:SetAttribute("MessageId",(p:GetAttribute("MessageId") or 0)+1) end
local function setState(p,r,state) r.state=state; p:SetAttribute("State",state) end
local function elapsed(r) return r.usedSkip and 0 or math.max(0,now()-(r.startedAt or now())+(r.penalty or 0)) end
local function syncRank(p,r)
 p:SetAttribute("UsedSkip",r.usedSkip==true); p:SetAttribute("RankEligible",r.eligible==true and not r.usedSkip)
 p:SetAttribute("RankStatus",r.usedSkip and "USED SKIP / UNRANKED" or r.eligible and "RANKED SPEEDRUN" or (r.invalidReason or "UNRANKED"))
 p:SetAttribute("CampaignEligible",r.campaignBaseEligible==true and r.eligible==true and not r.usedSkip)
end
local function checkpointPosition(r)
 local cp=mapOf(r).Checkpoints:FindFirstChild("Checkpoint_"..r.cpStage)
 return cp and cp.Position+Vector3.new(0,3.2,0) or mapOf(r).StartPosition.Position
end
local function teleport(p,position)
 local r=runs[p]; local root=rootOf(p)
 if r then r.authorizedUntil=now()+.6; r.lastPosition=position; r.lastObserved=now(); r.lastReturn=now() end
 if root then root.CFrame=CFrame.new(position); root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero end
end
function Runtime.Start(p,crossedGate)
 local r=runs[p]; if not r or not Services.Profiles[p] then return false end
 if r.level==1 then r.campaignBaseTime=0; r.campaignBaseEligible=true end
 r.usedSkip=false; r.eligible=true; r.invalidReason=nil; r.startedAt=crossedGate and now() or nil; r.penalty=0; r.elapsed=0; r.cpStage=0; r.completedSections=0; r.totalSections=Config.Levels[r.level].Sections; r.lastSplit=now(); r.collected={}; r.orbs=0; r.lastSpring=0
 r.portalDebounce=0
 p:SetAttribute("Stage",0); p:SetAttribute("Section",1); p:SetAttribute("Orbs",0); p:SetAttribute("Progress",0); p:SetAttribute("RunTime",0); p:SetAttribute("FinishTime",0); p:SetAttribute("RunStartedAt",r.startedAt or 0); p:SetAttribute("PenaltySeconds",0)
 syncRank(p,r); setState(p,r,crossedGate and "Racing" or "Armed")
 if not crossedGate then teleport(p,checkpointPosition(r));r.gatePrevious=nil end
 action:FireClient(p,"Reset",r.level)
 tell(p,crossedGate and "GO! Timer started at the blue gate." or "Walk through the blue gate to start. Your timer is waiting.")
 return true
end
function Runtime.ChooseLevel(p,index,fromNext,autoStart)
 local r=runs[p]; local profile=Services.Profiles[p]
 if not r or not profile or typeof(index)~="number" or index%1~=0 or index<1 or index>profile.Unlocked or index>4 then return false end
 if fromNext then r.campaignBaseTime=r.campaignTotal or 0; r.campaignBaseEligible=r.campaignFinishedEligible==true
 else r.campaignBaseTime=0; r.campaignBaseEligible=index==1 end
 r.level=index; r.cpStage=0; r.completedSections=0; r.orbs=0; r.collected={}; r.usedSkip=false; r.eligible=true; r.totalSections=Config.Levels[index].Sections
 r.gatePrevious=nil;r.startedAt=nil
 -- Keep only this player's selected sky environment persistent. Never hide platforms.
 local selectedRoom=mapOf(r):FindFirstChild("CourseSky")
 if selectedRoom~=r.room then
  if r.room then r.room:RemovePersistentPlayer(p) end
  r.room=selectedRoom;if selectedRoom then selectedRoom:AddPersistentPlayer(p) end
 end
 local spec=Config.Levels[index]
 p:SetAttribute("CurrentLevel",index); p:SetAttribute("LevelTitle",spec.Title); p:SetAttribute("LevelDifficulty",spec.Difficulty); p:SetAttribute("LevelSummary",spec.Summary); p:SetAttribute("LevelSections",spec.Sections); p:SetAttribute("LevelCheckpointCount",spec.Sections/4-1); p:SetAttribute("LevelTotalOrbs",spec.Sections*3)
 p:SetAttribute("Stage",0); p:SetAttribute("Section",1); p:SetAttribute("Orbs",0); p:SetAttribute("Progress",0); p:SetAttribute("RunTime",0); p:SetAttribute("RunStartedAt",0); p:SetAttribute("FinishTime",0); p:SetAttribute("PenaltySeconds",0); p:SetAttribute("BestTime",(profile.Best["Level"..index] or 0)/1000)
 syncRank(p,r); setState(p,r,"Ready"); teleport(p,checkpointPosition(r)); action:FireClient(p,"Reset",index)
 if autoStart then Runtime.Start(p) end
 return true
end
function Runtime.Skip(p)
 local r=runs[p]; if not r or r.state~="Racing" then return false,"Start a run first." end
 r.usedSkip=true; r.eligible=false; r.invalidReason="USED SKIP"; r.elapsed=0
 p:SetAttribute("RunTime",0); p:SetAttribute("FinishTime",0); p:SetAttribute("RunStartedAt",0); p:SetAttribute("PenaltySeconds",0); syncRank(p,r)
 local map=mapOf(r); local nextCheckpoint=map.Checkpoints:FindFirstChild("Checkpoint_"..(r.cpStage+1))
 if nextCheckpoint then
  r.cpStage+=1; r.completedSections=nextCheckpoint:GetAttribute("Section"); r.lastSplit=now()
  p:SetAttribute("Stage",r.cpStage); teleport(p,checkpointPosition(r))
 else r.completedSections=r.totalSections; teleport(p,map.PortalTrigger.Position) end
 p:SetAttribute("Section",math.min(r.totalSections,r.completedSections+1)); p:SetAttribute("Progress",r.completedSections/r.totalSections)
 tell(p,"USED SKIP: time removed. This run and campaign cannot enter leaderboards.")
 return true
end
local function fallReturn(p,reason)
 local r=runs[p]; if not r or now()-(r.lastReturn or 0)<.8 then return end
 if r.state=="Racing" then
  if not r.usedSkip then r.penalty+=Config.FallPenalty; p:SetAttribute("PenaltySeconds",r.penalty) end
  tell(p,reason..(r.usedSkip and " / unranked run" or " / +3 seconds"))
 end
 if r.state=="Finished" then teleport(p,mapOf(r).PortalTrigger.Position+Vector3.new(0,1,5)) else teleport(p,checkpointPosition(r)) end
end
local function collect(p,r,orb)
 local id=orb:GetAttribute("OrbId")
 if r.collected[id] then return end
 local root=rootOf(p); if not root or (root.Position-orb.Position).Magnitude>4 then return end
 r.collected[id]=true; r.orbs+=1; p:SetAttribute("Orbs",r.orbs); Services.Award(p,Config.CoinValue); action:FireClient(p,"Collected",r.level,id)
end
function Runtime.Finish(p)
 local r=runs[p]; if not r or r.state~="Racing" or r.completedSections~=r.totalSections then return false end
 r.elapsed=elapsed(r)
 local ranked,reason=Rules.CanRank(r)
 if ranked then
  Services.Submit(p,"Level"..r.level,r)
  local d=Services.Profiles[p]
  local reward=r.level*40+25
  if not d.Cleared[tostring(r.level)] then reward+=100; d.Cleared[tostring(r.level)]=true end
  Services.Award(p,reward)
  p:SetAttribute("BestTime",(d.Best["Level"..r.level] or 0)/1000)
  tell(p,"LEVEL CLEAR! +"..reward.." coins. Clean time: "..Rules.FormatTime(r.elapsed))
 else tell(p,r.usedSkip and "LEVEL CLEAR / USED SKIP / NO LEADERBOARD TIME" or "LEVEL CLEAR / "..reason) end
 local d=Services.Profiles[p]; d.Unlocked=math.max(d.Unlocked,math.min(4,r.level+1)); Services.Sync(p)
 r.campaignTotal=(r.campaignBaseTime or 0)+(ranked and r.elapsed or 0)
 r.campaignFinishedEligible=r.campaignBaseEligible==true and ranked
 if r.level==4 and r.campaignFinishedEligible then
  local full={usedSkip=false,eligible=true,completedSections=4,totalSections=4,elapsed=r.campaignTotal}
  Services.Submit(p,"Campaign",full); d.Wins=(d.Wins or 0)+1; Services.Sync(p)
 end
 p:SetAttribute("FinishTime",r.usedSkip and 0 or r.elapsed); p:SetAttribute("RunTime",r.usedSkip and 0 or r.elapsed); p:SetAttribute("Progress",1); p:SetAttribute("CampaignTime",r.campaignFinishedEligible and r.campaignTotal or 0)
 setState(p,r,"Finished"); task.defer(Services.UpdateWorldBoards)
 if d.CanSave then task.spawn(Services.Save,p,false) end
 return true
end
local function touchedPlayer(hit) local model=hit:FindFirstAncestorOfClass("Model"); return model and Players:GetPlayerFromCharacter(model) end
local function armCrumble(p,pad,level)
 local r=runs[p]; if not r or r.level~=level or r.state~="Racing" or pad:GetAttribute("CrumbleState")~="Solid" then return end
 local original=pad:GetAttribute("OriginalColor")
 pad:SetAttribute("CrumbleState","Warning"); pad.Color=Color3.fromRGB(255,219,90)
 task.delay(pad:GetAttribute("FallDelay"),function()
  if not pad.Parent then return end
  pad.CanCollide=false; pad.Transparency=.92; pad:SetAttribute("CrumbleState","Gone")
  task.delay(2.4,function() if pad.Parent then pad.Color=original; pad.Transparency=0; pad.CanCollide=true; pad:SetAttribute("CrumbleState","Solid") end end)
 end)
end
local function spring(p,pad,level)
 local r=runs[p]; local root=rootOf(p); local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
 if not r or r.level~=level or r.state~="Racing" or not root or not h or now()-(r.lastSpring or 0)<1.2 then return end
 r.lastSpring=now(); r.boostUntil=now()+1.15; h.WalkSpeed=34; h:ChangeState(Enum.HumanoidStateType.Jumping); root.AssemblyLinearVelocity=Vector3.new(0,90,-34); action:FireClient(p,"Spring",Vector3.new(0,90,-34))
end
pcall(function() PhysicsService:RegisterCollisionGroup("SkyfallPlayers") end)
PhysicsService:CollisionGroupSetCollidable("SkyfallPlayers","SkyfallPlayers",false)
local function init(p)
 if runs[p] then return end
 local r={level=1,state="Loading",cpStage=0,completedSections=0,orbs=0,collected={},actions={},campaignBaseTime=0,campaignBaseEligible=true}; runs[p]=r
 p:SetAttribute("State","Loading")
 local stats=Instance.new("Folder"); stats.Name="leaderstats"; stats.Parent=p
 for _,name in {"Coins","Wins"} do local v=Instance.new("IntValue"); v.Name=name; v.Parent=stats end
 local function characterAdded(char)
  local function collision(obj) if obj:IsA("BasePart") then obj.CollisionGroup="SkyfallPlayers" end end
  char.DescendantAdded:Connect(collision); for _,obj in char:GetDescendants() do collision(obj) end
  local h=char:WaitForChild("Humanoid",10); local root=char:WaitForChild("HumanoidRootPart",10)
  if h then h.WalkSpeed=Config.WalkSpeed; h.UseJumpPower=true; h.JumpPower=Config.JumpPower end
  if root and runs[p] then teleport(p,checkpointPosition(r)); Services.ApplyCosmetics(p) end
 end
 p.CharacterAdded:Connect(characterAdded)
 if p.Character then task.spawn(characterAdded,p.Character) end
 Services.Load(p)
 if not p.Parent then Services.Save(p,true); runs[p]=nil; return end
 Runtime.ChooseLevel(p,1,false,false); Services.ApplyCosmetics(p)
end
Players.PlayerAdded:Connect(init)
Players.PlayerRemoving:Connect(function(p) local r=runs[p];if r and r.room then r.room:RemovePersistentPlayer(p) end;Services.Save(p,true); runs[p]=nil end)
for _,p in Players:GetPlayers() do task.spawn(init,p) end
local cooldown={Start=1,Next=.6,SelectLevel=.4,Campaign=.8,Skip=1,BuyItem=.35,EquipItem=.35,Unequip=.35}
action.OnServerEvent:Connect(function(p,request,arg)
 local r=runs[p]; if not r or typeof(request)~="string" or not cooldown[request] then return end
 if now()-(r.actions[request] or 0)<cooldown[request] then return end; r.actions[request]=now()
 if not p:GetAttribute("ProfileLoaded") then tell(p,"Your profile is loading."); return end
 if request=="Start" then Runtime.Start(p)
 elseif request=="Next" and r.state=="Finished" and r.level<4 then Runtime.ChooseLevel(p,r.level+1,true,true)
 elseif request=="Campaign" and r.state=="Finished" then Runtime.ChooseLevel(p,1,false,true)
 elseif request=="SelectLevel" then Runtime.ChooseLevel(p,arg,false,false)
 elseif request=="Skip" then
  if Config.PrototypeSkipEnabled then local ok,message=Runtime.Skip(p); if not ok then tell(p,message) end
  else tell(p,"Skip purchases have not been enabled yet.") end
 elseif request=="BuyItem" or request=="EquipItem" or request=="Unequip" then local _,message=Services.Shop(p,request,arg); tell(p,message)
 end
end)
local lastQuery={}
query.OnServerInvoke=function(p,key)
 if key~="Campaign" and (typeof(key)~="string" or not key:match("^Level[1-4]$")) then return {Rows={},Mode="Choose a leaderboard"} end
 if now()-(lastQuery[p] or 0)<.8 then return Services.GetBoard(key) end
 lastQuery[p]=now(); return Services.GetBoard(key)
end
Players.PlayerRemoving:Connect(function(p) lastQuery[p]=nil end)
local grant=Instance.new("BindableFunction"); grant.Name="SkyfallGrantSkip"; grant.Parent=script.Parent; grant.OnInvoke=Runtime.Skip
for level=1,4 do
 local map=maps["Level"..level]
 for _,h in map.Hazards:GetChildren() do table.insert(hazards,{Part=h,Base=h.CFrame,Kind=h:GetAttribute("Kind"),Level=level}) end
 for _,p in map.Platforms:GetChildren() do
  if p:GetAttribute("PhasePlatform") then p:SetAttribute("CourseLevel",level);table.insert(phasePads,p) end
  if p:GetAttribute("Moving") then table.insert(ferries,{Part=p,Base=p.CFrame,Level=level}) end
  if p:GetAttribute("Crumble") then
   p:SetAttribute("CrumbleState","Solid"); p:SetAttribute("OriginalColor",p.Color)
   p.Touched:Connect(function(hit) local player=touchedPlayer(hit); if player then armCrumble(player,p,level) end end)
  end
  if p:GetAttribute("Spring") then p.Touched:Connect(function(hit) local player=touchedPlayer(hit); if player then spring(player,p,level) end end) end
 end
 for _,orb in map.Orbs:GetChildren() do if orb:GetAttribute("FollowPlatform") then table.insert(following,{Orb=orb,Platform=map.Platforms[orb:GetAttribute("FollowPlatform")],Offset=orb:GetAttribute("FollowOffset"),Level=level}) end end
 for _,obj in map.Decor:GetDescendants() do
  if obj:IsA("ProximityPrompt") then obj.Triggered:Connect(function(p) action:FireClient(p,obj.Parent.Name=="ShopKiosk" and "OpenShop" or "OpenBoard",level) end) end
 end
end
local accumulator=0;local motionAccumulator=0
RunService.Heartbeat:Connect(function(dt)
 local t=now(); accumulator+=dt;motionAccumulator+=dt
 local active={};for p,r in pairs(runs) do if p.Parent then active[r.level]=true end end
 if motionAccumulator>=1/30 then
 motionAccumulator=0
 for _,entry in ipairs(hazards) do
  if not active[entry.Level] then continue end
  local h=entry.Part; local phase=t*(h:GetAttribute("Speed") or 1)+(h:GetAttribute("Phase") or 0)
  if entry.Kind=="Spin" then h.CFrame=entry.Base*CFrame.Angles(0,phase,0)
  elseif entry.Kind=="Slide" then h.CFrame=entry.Base+Vector3.new(math.sin(phase)*(h:GetAttribute("Amplitude") or 7),0,0)
  elseif entry.Kind=="Lift" then h.CFrame=entry.Base+Vector3.new(0,(math.sin(phase)+1)*.5*(h:GetAttribute("Amplitude") or 8),0) end
 end
 for _,entry in ipairs(ferries) do if active[entry.Level] then local p=entry.Part; p.CFrame=entry.Base+Vector3.new(math.sin(t*p:GetAttribute("Speed")+p:GetAttribute("Phase"))*p:GetAttribute("Amplitude"),0,0) end end
 for _,entry in ipairs(following) do if active[entry.Level] then entry.Orb.Position=entry.Platform.Position+entry.Offset end end
 end
 if accumulator<.1 then return end; accumulator=0
 for _,pad in ipairs(phasePads) do
  if not active[pad:GetAttribute("CourseLevel")] then continue end
  local phase=(t+pad:GetAttribute("Phase"))%pad:GetAttribute("Period"); local remaining=pad:GetAttribute("SolidTime")-phase; local solid=remaining>0
  local phaseState=not solid and "GHOST" or remaining<.45 and "WARNING" or "SOLID"
  if pad:GetAttribute("PhaseState")~=phaseState then
   pad.CanCollide=solid;pad.Transparency=solid and .1 or .78;pad.Color=not solid and Color3.fromRGB(223,95,235) or remaining<.45 and Color3.fromRGB(255,217,90) or Color3.fromRGB(65,239,215)
   pad:SetAttribute("PhaseState",phaseState)
  end
 end
 for p,r in pairs(runs) do
  local root=rootOf(p)
  if root then
   if root.Position.Y<0 then fallReturn(p,"Fell from the course") end
   -- Server-observed forward crossing, swept between samples, with per-player cooldown.
   local gate=mapOf(r):FindFirstChild("StartGate")
   if gate and (r.state=="Armed" or r.state=="Racing") then
    local q=gate.CFrame:PointToObjectSpace(root.Position);local previous=r.gatePrevious;r.gatePrevious=q
    if previous and previous.Z>0 and q.Z<=0 and (q-previous).Magnitude<14 and t-(r.lastGate or 0)>1.5 then
     local fraction=previous.Z/(previous.Z-q.Z);local crossing=previous:Lerp(q,fraction)
     if math.abs(crossing.X)<gate.Size.X/2 and math.abs(crossing.Y)<gate.Size.Y/2 then r.lastGate=t;Runtime.Start(p,true) end
    end
   end
   if r.state=="Racing" then
    local map=mapOf(r); local h=p.Character:FindFirstChildOfClass("Humanoid")
    if h and (r.boostUntil or 0)<t and h.WalkSpeed~=Config.WalkSpeed then h.WalkSpeed=Config.WalkSpeed end
    if r.lastPosition and t>(r.authorizedUntil or 0) and (root.Position-r.lastPosition).Magnitude>math.max(28,70*(t-(r.lastObserved or t))) then
     r.eligible=false; r.invalidReason="UNRANKED / ROUTE CHECK"; syncRank(p,r)
    end
    r.lastPosition=root.Position; r.lastObserved=t
    local nextGate=map.RouteGates:FindFirstChild("Gate_"..(r.completedSections+1))
    if nextGate then
     local q=nextGate.CFrame:PointToObjectSpace(root.Position)
     if math.abs(q.X)<13 and math.abs(q.Y)<7 and math.abs(q.Z)<4 then
      if t-(r.lastSplit or r.startedAt)<1.25 then r.eligible=false; r.invalidReason="UNRANKED / ROUTE CHECK"; syncRank(p,r) end
      r.completedSections+=1; r.lastSplit=t; p:SetAttribute("Section",math.min(r.totalSections,r.completedSections+1))
     end
    end
    local cp=map.Checkpoints:FindFirstChild("Checkpoint_"..(r.cpStage+1))
    if cp and r.completedSections>=cp:GetAttribute("Section") and (root.Position-(cp.Position+Vector3.new(0,2.5,0))).Magnitude<6 then
     r.cpStage+=1; p:SetAttribute("Stage",r.cpStage); Services.Award(p,20); tell(p,"Checkpoint "..r.cpStage.." saved / +20 coins")
    end
    for _,orb in map.Orbs:GetChildren() do collect(p,r,orb) end
    local progress=math.clamp(-root.Position.Z/map:GetAttribute("CourseLength"),0,1)
    if math.abs((p:GetAttribute("Progress") or 0)-progress)>.003 then p:SetAttribute("Progress",progress) end
    p:SetAttribute("RunTime",elapsed(r))
    for _,entry in ipairs(hazards) do if entry.Level==r.level then
     local hpart=entry.Part; local q=hpart.CFrame:PointToObjectSpace(root.Position-Vector3.new(0,.65,0))
     if math.abs(q.X)<hpart.Size.X/2+.65 and math.abs(q.Y)<hpart.Size.Y/2+2.2 and math.abs(q.Z)<hpart.Size.Z/2+.65 then fallReturn(p,"Caught by a red hazard"); break end
    end end
    local portal=map.PortalTrigger; local q=portal.CFrame:PointToObjectSpace(root.Position)
    if math.abs(q.X)<5.5 and math.abs(q.Y)<6 and math.abs(q.Z)<2 then
     if r.completedSections==r.totalSections then Runtime.Finish(p)
     elseif t-(r.portalDebounce or 0)>2 then r.portalDebounce=t; tell(p,"Follow all route markers first. Skips can bypass the route, but remove your time.") end
    end
   end
  end
 end
end)
task.spawn(function()
 while true do
  for _,key in {"Level1","Level2","Level3","Level4","Campaign"} do Services.RefreshBoard(key); task.wait(.1) end
  Services.UpdateWorldBoards(); task.wait(60)
 end
end)
task.spawn(function() while true do task.wait(45); for p in pairs(Services.Profiles) do task.spawn(Services.Save,p,false) end end end)
game:BindToClose(Services.Close)
print("Skyfall Rush ready: 56 obstacle sections, ranked timers, skips, coins, shop and global records.")
return Runtime

