-- Local audio and transient VFX. No gameplay state or server collision is changed.
local Feedback={}
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")
local ContentProvider=game:GetService("ContentProvider")
local Debris=game:GetService("Debris")
local p=Players.LocalPlayer
local Config=require(game.ReplicatedStorage:WaitForChild("SkyfallAudioConfig"))
local GameConfig=require(game.ReplicatedStorage:WaitForChild("SkyfallConfig"))
local initialized=false
local musicGroup,effectsGroup,overlay,fxFolder
local voices={};local voiceIndex=0;local music={};local musicIndex=0;local musicGeneration=0
local activeBursts=0;local lastCue={};local lastCoin=0;local combo=0;local duckGeneration=0
local function color() return GameConfig.Levels[p:GetAttribute("CurrentLevel") or 1].Color end
local function root() return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end
local function low() return p:GetAttribute("LowGraphics")==true or p:GetAttribute("ReducedEffects")==true end
local function tween(obj,seconds,properties) TweenService:Create(obj,TweenInfo.new(seconds,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),properties):Play() end
local function play(id,volume,pitch,duration)
 if not effectsGroup or effectsGroup.Volume==0 then return end
 voiceIndex=voiceIndex%#voices+1
 local s=voices[voiceIndex];s:Stop();s.SoundId=id;s.Volume=volume;s.PlaybackSpeed=pitch or 1;s.TimePosition=0;s:Play()
 -- A generation guard prevents an old voice timer stopping a reused sound.
 local generation=(s:GetAttribute("Generation") or 0)+1;s:SetAttribute("Generation",generation)
 task.delay(duration or .5,function() if s.Parent and s:GetAttribute("Generation")==generation then s:Stop() end end)
end
local function notes(pitches,spacing,volume)
 for i,pitch in ipairs(pitches) do task.delay((i-1)*(spacing or .09),function() play(Config.Tone,volume or .22,pitch,.19) end) end
end
local function duck()
 duckGeneration+=1;local generation=duckGeneration
 tween(musicGroup,.08,{Volume=(p:GetAttribute("MusicVolume") or Config.MusicVolume)*.4})
 task.delay(.8,function() if generation==duckGeneration then tween(musicGroup,.45,{Volume=p:GetAttribute("MusicVolume") or Config.MusicVolume}) end end)
end
local function burst(position,tint,count,radius,confetti)
 if not position or not fxFolder or activeBursts>=(low() and 3 or 10) then return end
 activeBursts+=1
 local carrier=Instance.new("Part");carrier.Name="FeedbackBurst";carrier.Size=Vector3.one*.1;carrier.Position=position;carrier.Transparency=1;carrier.Anchored=true;carrier.CanCollide=false;carrier.CanTouch=false;carrier.CanQuery=false;carrier.CastShadow=false;carrier.Parent=fxFolder
 local emitter=Instance.new("ParticleEmitter");emitter.Enabled=false;emitter.Rate=0
 emitter.Texture=confetti and "rbxasset://textures/particles/SquareParticle.png" or "rbxasset://textures/particles/sparkles_main.dds"
 emitter.Color=confetti and ColorSequence.new(tint,Color3.fromRGB(255,215,90)) or ColorSequence.new(tint)
 emitter.LightEmission=.7;emitter.LightInfluence=0;emitter.Lifetime=NumberRange.new(.3,confetti and 1.25 or .65)
 emitter.Speed=NumberRange.new(confetti and 12 or 3,confetti and 22 or 9);emitter.SpreadAngle=Vector2.new(confetti and 55 or 180,180)
 emitter.Acceleration=Vector3.new(0,confetti and -28 or 3,0);emitter.Drag=2
 emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,confetti and .24 or .32),NumberSequenceKeypoint.new(1,0)})
 emitter.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.1),NumberSequenceKeypoint.new(1,1)})
 emitter.RotSpeed=NumberRange.new(-160,160);emitter.Parent=carrier;emitter:Emit(low() and math.min(4,count) or count)
 Debris:AddItem(carrier,1.6)
 if not low() then
  local ring=Instance.new("Part");ring.Name="PulseRing";ring.Shape=Enum.PartType.Cylinder;ring.Size=Vector3.new(.08,.6,.6);ring.CFrame=CFrame.new(position-Vector3.new(0,.9,0))*CFrame.Angles(0,0,math.pi/2);ring.Material=Enum.Material.Neon;ring.Color=tint;ring.Transparency=.45;ring.Anchored=true;ring.CanCollide=false;ring.CanTouch=false;ring.CanQuery=false;ring.CastShadow=false;ring.Parent=fxFolder
  tween(ring,.45,{Size=Vector3.new(.04,radius or 6,radius or 6),Transparency=1});Debris:AddItem(ring,.5)
 end
 task.delay(1.6,function() activeBursts=math.max(0,activeBursts-1) end)
end
local function banner(words,tint)
 if not overlay then return end
 local label=Instance.new("TextLabel");label.Name="Moment";label.AnchorPoint=Vector2.new(.5,.5);label.Position=UDim2.fromScale(.5,.36);label.Size=UDim2.new(.8,0,0,40);label.BackgroundTransparency=1;label.Font=Enum.Font.GothamBold;label.Text=words;label.TextSize=24;label.TextColor3=tint;label.TextStrokeTransparency=.7;label.Parent=overlay
 local constraint=Instance.new("UITextSizeConstraint");constraint.MaxTextSize=24;constraint.MinTextSize=12;constraint.Parent=label;label.TextScaled=true
 tween(label,.9,{Position=UDim2.fromScale(.5,.31),TextTransparency=1,TextStrokeTransparency=1});Debris:AddItem(label,1)
end
function Feedback.Cue(name,position,data)
 if not initialized then return end
 local t=os.clock();local cooldown=name=="UI" and .045 or name=="Coin" and .035 or .16
 if t-(lastCue[name] or -10)<cooldown then return end;lastCue[name]=t
 local r=root();position=position or r and r.Position
 if name=="UI" then play(Config.Tone,.12,1.75,.09)
 elseif name=="Hover" then play(Config.Tone,.035,2.1,.06)
 elseif name=="Coin" then
  combo=t-lastCoin<1.1 and math.min(combo+1,6) or 1;lastCoin=t
  play(Config.Coin,.45,1+(combo-1)*.07,.4);burst(position,Color3.fromRGB(255,214,85),8,3)
 elseif name=="Jump" then play(Config.Jump,.25,1.06,.35);burst(position and position-Vector3.new(0,2.5,0),color(),4,3)
 elseif name=="Land" then play(Config.Land,.2,.95,.3);burst(position and position-Vector3.new(0,2.5,0),color(),5,4)
 elseif name=="Start" then notes({1,1.26,1.5},.07,.25);burst(position,color(),14,9);banner("GO!",color());duck()
 elseif name=="Ready" then play(Config.Whoosh,.18,1.3,.45)
 elseif name=="Checkpoint" then notes({1,1.26,1.5,2},.09,.26);burst(position,Color3.fromRGB(100,255,176),18,12);banner("CHECKPOINT SAVED",Color3.fromRGB(100,255,176));duck()
 elseif name=="Finish" then
  notes({1,1.26,1.5,2,1.5,2},.11,.3);burst(position,color(),low() and 4 or 36,16,true);banner(data and data.PersonalBest and "NEW PERSONAL BEST!" or "COURSE CLEAR!",Color3.fromRGB(255,216,94));duck()
 elseif name=="Fail" then play(Config.Fail,.3,.92,.4);burst(position,Color3.fromRGB(255,113,130),9,6)
 elseif name=="Respawn" then play(Config.Whoosh,.14,1.4,.35);burst(position,color(),6,4)
 elseif name=="Spring" then play(Config.Whoosh,.35,1.45,.4);notes({1,1.5,2},.055,.16);burst(position,Color3.fromRGB(107,255,171),15,8)
 elseif name=="Skip" then play(Config.Whoosh,.25,.8,.5);notes({1.5,1},.12,.18);burst(position,Color3.fromRGB(205,150,255),12,8);banner("USED SKIP / UNRANKED",Color3.fromRGB(205,150,255))
 elseif name=="Shop" then notes({1.26,1.5,2},.075,.18);burst(position,Color3.fromRGB(255,218,111),8,5)
 elseif name=="Denied" then notes({.8,.65},.11,.14)
 elseif name=="PhaseWarning" then play(Config.Tone,.10,1.15,.1);burst(position,Color3.fromRGB(255,216,96),4,3)
 elseif name=="PhaseSolid" then play(Config.Tone,.07,1.7,.08)
 elseif name=="Crumble" then play(Config.Land,.15,.7,.2);burst(position,Color3.fromRGB(255,183,87),7,3)
 elseif name=="Machinery" then play(Config.Whoosh,.08,.65,.22)
 elseif name=="Ferry" then play(Config.Whoosh,.12,1.1,.3);burst(position,color(),4,3)
 elseif name=="Conveyor" then play(Config.Whoosh,.12,.85,.3) end
end
local function musicForCourse()
 musicGeneration+=1;local generation=musicGeneration
 local level=p:GetAttribute("CurrentLevel") or 1;local track=Config.Tracks[level] or Config.Tracks[1]
 musicIndex=musicIndex%2+1;local incoming=music[musicIndex];local outgoing=music[3-musicIndex]
 incoming:Stop();incoming.SoundId="rbxassetid://"..track.Id;incoming.Volume=0
 p:SetAttribute("NowPlaying",track.Title)
 task.spawn(function()
  local ok=pcall(function() ContentProvider:PreloadAsync({incoming}) end)
  if generation~=musicGeneration then return end
  if not ok or not incoming.IsLoaded then p:SetAttribute("AudioStatus","Music unavailable");return end
  incoming:Play();tween(incoming,1.2,{Volume=1});tween(outgoing,1.2,{Volume=0})
  task.delay(1.3,function() if generation==musicGeneration then outgoing:Stop() end end)
  p:SetAttribute("AudioStatus","Playing")
 end)
end
function Feedback.Init(gui)
 if initialized then return end;initialized=true
 musicGroup=Instance.new("SoundGroup");musicGroup.Name="SkyfallMusic";musicGroup.Volume=Config.MusicVolume;musicGroup.Parent=SoundService
 effectsGroup=Instance.new("SoundGroup");effectsGroup.Name="SkyfallEffects";effectsGroup.Volume=Config.EffectsVolume;effectsGroup.Parent=SoundService
 for i=1,12 do local s=Instance.new("Sound");s.Name="SkyfallVoice"..i;s.SoundGroup=effectsGroup;s.Parent=SoundService;voices[i]=s end
 for i=1,2 do local s=Instance.new("Sound");s.Name="SkyfallMusic"..i;s.SoundGroup=musicGroup;s.Looped=true;s.Parent=SoundService;music[i]=s end
 fxFolder=Instance.new("Folder");fxFolder.Name="SkyfallLocalFeedback";fxFolder.Parent=workspace
 overlay=Instance.new("ScreenGui");overlay.Name="SkyfallMoments";overlay.ResetOnSpawn=false;overlay.DisplayOrder=3;overlay.Parent=p.PlayerGui
 p:SetAttribute("MusicVolume",Config.MusicVolume);p:SetAttribute("EffectsVolume",Config.EffectsVolume);p:SetAttribute("ReducedEffects",false)
 p:GetAttributeChangedSignal("MusicVolume"):Connect(function() duckGeneration+=1;tween(musicGroup,.15,{Volume=p:GetAttribute("MusicVolume") or 0}) end)
 p:GetAttributeChangedSignal("EffectsVolume"):Connect(function() effectsGroup.Volume=p:GetAttribute("EffectsVolume") or 0 end)
 p:GetAttributeChangedSignal("CurrentLevel"):Connect(musicForCourse)
 local boundButtons=setmetatable({},{__mode="k"})
 local function bindButton(b)
  if not b:IsA("GuiButton") or boundButtons[b] then return end;boundButtons[b]=true
  local scale=Instance.new("UIScale");scale.Name="FeedbackScale";scale.Parent=b
  b.MouseEnter:Connect(function() Feedback.Cue("Hover");if not low() then tween(scale,.1,{Scale=1.025}) end end)
  b.MouseLeave:Connect(function() tween(scale,.1,{Scale=1}) end)
  b.Activated:Connect(function() Feedback.Cue("UI");if not low() then scale.Scale=.96;tween(scale,.14,{Scale=1}) end end)
 end
 for _,b in gui:GetDescendants() do bindButton(b) end;gui.DescendantAdded:Connect(bindButton)
 local function bindCharacter(char)
  local h=char:WaitForChild("Humanoid",10);if not h then return end
  local function silenceDefault(s) if s:IsA("Sound") and (s.Name=="Jumping" or s.Name=="Landing" or s.Name=="Died") then s.Volume=0 end end
  for _,s in char:GetDescendants() do silenceDefault(s) end;char.DescendantAdded:Connect(silenceDefault)
  h.StateChanged:Connect(function(_,state)
   if char~=p.Character then return end
   if state==Enum.HumanoidStateType.Jumping then Feedback.Cue("Jump")
   elseif state==Enum.HumanoidStateType.Landed then Feedback.Cue("Land") end
  end)
  task.delay(.25,function() if char==p.Character then Feedback.Cue("Respawn") end end)
 end
 p.CharacterAdded:Connect(bindCharacter);if p.Character then task.spawn(bindCharacter,p.Character) end
 local maps=workspace:WaitForChild("SkyfallSprint"):WaitForChild("Levels")
 local tracked=setmetatable({},{__mode="k"});local machinery=setmetatable({},{__mode="k"})
 local function nearby(part,distance)
  local r=root();return r and part:IsDescendantOf(maps) and (r.Position-part.Position).Magnitude<distance
 end
 local function register(part)
  if not part:IsA("BasePart") or tracked[part] then return end
  if part:GetAttribute("PhasePlatform") or part:GetAttribute("Crumble") then
   local connections={};tracked[part]=connections
   table.insert(connections,part:GetAttributeChangedSignal("PhaseState"):Connect(function()
    if nearby(part,24) then local state=part:GetAttribute("PhaseState");if state=="WARNING" then Feedback.Cue("PhaseWarning",part.Position) elseif state=="SOLID" then Feedback.Cue("PhaseSolid") end end
   end))
   table.insert(connections,part:GetAttributeChangedSignal("CrumbleState"):Connect(function() if nearby(part,22) and part:GetAttribute("CrumbleState")=="Warning" then Feedback.Cue("Crumble",part.Position) end end))
  end
  local kind=part:GetAttribute("Kind");if kind=="Spin" or kind=="Slide" or kind=="Lift" then machinery[part]=true end
 end
 for _,part in maps:GetDescendants() do register(part) end;maps.DescendantAdded:Connect(register)
 maps.DescendantRemoving:Connect(function(part) if tracked[part] then for _,c in tracked[part] do c:Disconnect() end;tracked[part]=nil end;machinery[part]=nil end)
 local tick,lastFloor,lastMachine=0,nil,0
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include
 RunService.Heartbeat:Connect(function(dt)
  tick+=dt;if tick<.2 then return end;tick=0
  if p:GetAttribute("State")~="Racing" then lastFloor=nil;return end
  local r=root();local map=maps:FindFirstChild("Level"..(p:GetAttribute("CurrentLevel") or 1));if not r or not map then return end
  local platforms=map:FindFirstChild("Platforms");if not platforms then return end
  ray.FilterDescendantsInstances={platforms};local hit=workspace:Raycast(r.Position,Vector3.new(0,-5,0),ray);local floor=hit and hit.Instance
  if floor~=lastFloor and floor then if floor:GetAttribute("Moving") then Feedback.Cue("Ferry",floor.Position) elseif floor:GetAttribute("Conveyor") then Feedback.Cue("Conveyor") end end;lastFloor=floor
  if os.clock()-lastMachine>.9 then for part in pairs(machinery) do if nearby(part,10) then Feedback.Cue("Machinery");lastMachine=os.clock();break end end end
 end)
 game.ReplicatedStorage:WaitForChild("SkyfallAction").OnClientEvent:Connect(function(kind,a,b,c)
  if kind=="Feedback" then Feedback.Cue(a,b,c)
  elseif kind=="Collected" then local map=maps:FindFirstChild("Level"..a);local orbs=map and map:FindFirstChild("Orbs");local orb=orbs and orbs:FindFirstChild("Orb_"..b);Feedback.Cue("Coin",orb and orb.Position)
  elseif kind=="Spring" then Feedback.Cue("Spring") end
 end)
 musicForCourse()
end
return Feedback
