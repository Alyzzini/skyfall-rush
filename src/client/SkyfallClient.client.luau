local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local HttpService=game:GetService("HttpService")
local UIS=game:GetService("UserInputService")
local p=Players.LocalPlayer
local Config=require(game.ReplicatedStorage:WaitForChild("SkyfallConfig"))
game.ReplicatedStorage:WaitForChild("SkyfallReady")
local maps=workspace:WaitForChild("SkyfallSprint"):WaitForChild("Levels")
local action=game.ReplicatedStorage:WaitForChild("SkyfallAction")
local query=game.ReplicatedStorage:WaitForChild("SkyfallQuery")
local gui=Instance.new("ScreenGui"); gui.Name="SkyfallHUD"; gui.ResetOnSpawn=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=p:WaitForChild("PlayerGui")
local Feedback=require(script.Parent:WaitForChild("SkyfallFeedback"))
Feedback.Init(gui)
local navy=Color3.fromRGB(10,17,30); local white=Color3.fromRGB(240,247,255); local muted=Color3.fromRGB(162,181,202); local cyan=Color3.fromRGB(70,235,220); local gold=Color3.fromRGB(255,214,90); local red=Color3.fromRGB(255,108,127)
local function corner(obj,n) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,n); c.Parent=obj end
local function frame(parent,name,size,pos,color,alpha)
 local f=Instance.new("Frame"); f.Name=name; f.Size=size; f.Position=pos; f.BackgroundColor3=color or navy; f.BackgroundTransparency=alpha or 0; f.BorderSizePixel=0; f.Parent=parent; return f
end
local function label(parent,name,words,size,pos,color,fontSize)
 local t=Instance.new("TextLabel"); t.Name=name; t.BackgroundTransparency=1; t.Size=size; t.Position=pos; t.Font=Enum.Font.GothamBold; t.Text=words; t.TextColor3=color or white; t.TextSize=fontSize or 16; t.TextWrapped=true; t.Parent=parent; return t
end
local function fitText(t,maxSize,minSize) t.TextScaled=true; local c=Instance.new("UITextSizeConstraint"); c.MaxTextSize=maxSize; c.MinTextSize=minSize or 8; c.Parent=t end
local function button(parent,name,words,size,pos,color)
 local b=Instance.new("TextButton"); b.Name=name; b.Size=size; b.Position=pos; b.BackgroundColor3=color or cyan; b.TextColor3=navy; b.Font=Enum.Font.GothamBold; b.Text=words; b.TextSize=14; b.AutoButtonColor=true; b.BorderSizePixel=0; b.Parent=parent; corner(b,8); fitText(b,14,10)
 b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(.12),{BackgroundTransparency=.12}):Play() end)
 b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(.12),{BackgroundTransparency=0}):Play() end)
 return b
end
local function stroke(f,color,alpha) local s=Instance.new("UIStroke"); s.Color=color; s.Transparency=alpha or .5; s.Parent=f end
local function limit(f,w,h) local c=Instance.new("UISizeConstraint"); c.MaxSize=Vector2.new(w,h); c.Parent=f end
local function timeString(seconds)
 local ms=math.max(0,math.floor((seconds or 0)*1000+.5)); return string.format("%02d:%02d.%03d",math.floor(ms/60000),math.floor(ms/1000)%60,ms%1000)
end
local refresh
local compact=false
local controls; local movementEnabled
local function updateMovement(enabled)
 if controls and movementEnabled~=enabled then
  movementEnabled=enabled
  if enabled then controls:Enable() else controls:Disable() end
 end
 local touch=p.PlayerGui:FindFirstChild("TouchGui")
 if touch then touch.Enabled=enabled end
end
p.PlayerGui.ChildAdded:Connect(function(child)
 if child.Name=="TouchGui" then task.defer(function() updateMovement((p:GetAttribute("State")=="Racing" or p:GetAttribute("State")=="Armed") and not (gui:FindFirstChild("PanelOverlay") and gui.PanelOverlay.Visible)) end) end
end)
task.spawn(function()
 local module=p:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule",10)
 if module then local ok,result=pcall(function() return require(module):GetControls() end); if ok then controls=result; movementEnabled=nil; if refresh then refresh() end end end
end)
-- One width-constrained container keeps every race control aligned on ultrawide screens.
local hud=frame(gui,"RaceHUD",UDim2.new(.94,0,0,190),UDim2.new(.5,0,0,12),navy,1);hud.AnchorPoint=Vector2.new(.5,0);limit(hud,1100,220)
local statusRow=frame(hud,"StatusRow",UDim2.new(1,0,0,32),UDim2.fromOffset(0,84),navy,1)
local top=frame(hud,"Header",UDim2.new(1,0,0,76),UDim2.new(),navy,.08);corner(top,16);stroke(top,cyan,.65)
local brand=label(top,"Brand","SKYFALL RUSH",UDim2.new(.37,-22,0,28),UDim2.fromOffset(18,12),white,22); brand.TextXAlignment=Enum.TextXAlignment.Left; fitText(brand,22,10)
local levelText=label(top,"Level","LEVEL 1 / THE ASCENT",UDim2.new(.37,-22,0,20),UDim2.fromOffset(18,45),muted,12); levelText.TextXAlignment=Enum.TextXAlignment.Left; fitText(levelText,12,8)
local timer=label(top,"Timer","00:00.000",UDim2.new(.35,0,0,35),UDim2.new(.36,0,0,8),white,30); timer.Font=Enum.Font.Code; fitText(timer,30,12)
local rankStatus=label(top,"RankStatus","RANKED SPEEDRUN",UDim2.new(.35,0,0,20),UDim2.new(.36,0,0,44),cyan,11); fitText(rankStatus,11,8)
local wallet=label(top,"Wallet","125 COINS",UDim2.new(.27,-12,0,32),UDim2.new(.73,0,0,10),gold,23); fitText(wallet,23,10)
local pickupText=label(top,"Pickups","COINS ARE OPTIONAL",UDim2.new(.27,-12,0,20),UDim2.new(.73,0,0,44),muted,10); fitText(pickupText,10,7)
local track=frame(top,"ProgressTrack",UDim2.new(1,-36,0,3),UDim2.new(0,18,1,-11),Color3.fromRGB(42,60,82)); corner(track,2)
local fill=frame(track,"ProgressFill",UDim2.fromScale(0,1),UDim2.new(),cyan); corner(fill,2)
local toolbar=frame(gui,"Toolbar",UDim2.new(.94,0,0,36),UDim2.new(.5,0,0,111),navy,1); toolbar.AnchorPoint=Vector2.new(.5,0); limit(toolbar,900,36)
local shopButton=button(toolbar,"ShopButton","SHOP",UDim2.new(.25,-6,1,0),UDim2.fromScale(0,0),gold)
local boardButton=button(toolbar,"BoardButton","RANKINGS",UDim2.new(.25,-6,1,0),UDim2.fromScale(.25,0),Color3.fromRGB(174,190,226))
local restartButton=button(toolbar,"RestartButton","RESTART",UDim2.new(.25,-6,1,0),UDim2.fromScale(.5,0),Color3.fromRGB(160,184,202))
local skipButton=button(toolbar,"SkipButton","SKIP →",UDim2.new(.25,-6,1,0),UDim2.fromScale(.75,0),Color3.fromRGB(200,150,255))
local audioButton=button(toolbar,"AudioButton","AUDIO / FX",UDim2.new(.2,-6,1,0),UDim2.fromScale(.8,0),Color3.fromRGB(140,210,235))
for i,b in ipairs({shopButton,boardButton,restartButton,skipButton,audioButton}) do b.Size=UDim2.new(.2,-6,1,0);b.Position=UDim2.fromScale((i-1)*.2,0) end
local raceMenuOpen=false
local raceMenu=button(statusRow,"RaceMenu","MENU",UDim2.fromOffset(78,30),UDim2.new(.97,0,0,83),navy); raceMenu.AnchorPoint=Vector2.new(1,0); raceMenu.TextColor3=white; raceMenu.Visible=false
local graphics=button(statusRow,"Graphics","VISUALS: AUTO",UDim2.fromOffset(132,28),UDim2.new(.97,0,0,154),navy);graphics.AnchorPoint=Vector2.new(1,0);graphics.TextColor3=muted;stroke(graphics,cyan,.75)
local graphicsMode="Auto";local autoLow=false
local function applyGraphics()
 p:SetAttribute("LowGraphics",graphicsMode=="Low" or graphicsMode=="Auto" and autoLow)
 graphics.Text="VISUALS: "..string.upper(graphicsMode)..(graphicsMode=="Auto" and autoLow and " / LOW" or "")
end
graphics.Activated:Connect(function() graphicsMode=graphicsMode=="Auto" and "Low" or graphicsMode=="Low" and "High" or "Auto";applyGraphics() end)
applyGraphics()
-- Ignore startup/menu spikes. Auto reduces cosmetic work after sustained slow frames.
local sampleTime,sampleFrames,slowWindows=0,0,0
RunService.Heartbeat:Connect(function(dt)
 if graphicsMode~="Auto" or autoLow or p:GetAttribute("State")~="Racing" or dt>.25 then sampleTime=0;sampleFrames=0;slowWindows=0;return end
 sampleTime+=dt;sampleFrames+=1
 if sampleTime>=5 then
  slowWindows=sampleTime/sampleFrames>1/38 and slowWindows+1 or 0;sampleTime=0;sampleFrames=0
  if slowWindows>=3 then autoLow=true;applyGraphics() end
 end
end)
raceMenu.Activated:Connect(function() raceMenuOpen=not raceMenuOpen; if refresh then refresh() end end)
local objective=frame(statusRow,"Objective",UDim2.new(.9,0,0,40),UDim2.new(.5,0,1,-15),navy,.15); objective.AnchorPoint=Vector2.new(.5,1); corner(objective,12); limit(objective,950,40)
local objectiveText=label(objective,"Text","56 obstacle sections / 4 courses / cosmetics with coins",UDim2.new(1,-24,1,-6),UDim2.fromOffset(12,3),white,13); fitText(objectiveText,13,8)
local toast=frame(gui,"Toast",UDim2.new(.9,0,0,43),UDim2.new(.5,0,1,-66),navy,.04); toast.AnchorPoint=Vector2.new(.5,1); corner(toast,12); stroke(toast,cyan,.6); limit(toast,900,43); toast.Visible=false
local toastText=label(toast,"Text","",UDim2.new(1,-24,1,-8),UDim2.fromOffset(12,4),cyan,15); fitText(toastText,15,8)
local toastId=0
local function showToast(words)
 toastId+=1; local id=toastId; toastText.Text=words; toast.Visible=true
 task.delay(4.5,function() if id==toastId then toast.Visible=false end end)
end
local modal=frame(gui,"RunCard",UDim2.new(.94,0,0,440),UDim2.new(.5,0,.5,45),navy,.02); modal.AnchorPoint=Vector2.new(.5,.5); corner(modal,20); stroke(modal,cyan,.5); limit(modal,760,440)
local modalScale=Instance.new("UIScale"); modalScale.Parent=modal
local kicker=label(modal,"Kicker","FOUR COURSES / SPEEDRUN",UDim2.new(1,-44,0,22),UDim2.fromOffset(22,18),cyan,12)
local heading=label(modal,"Heading","THE ASCENT",UDim2.new(1,-44,0,42),UDim2.fromOffset(22,49),white,31); fitText(heading,31,14)
local body=label(modal,"Body","Loading course...",UDim2.new(1,-52,0,82),UDim2.fromOffset(26,96),muted,15); fitText(body,15,11)
local rulesText=label(modal,"Rules","CYAN SOLID / PINK GHOST / RED DANGER",UDim2.new(1,-44,0,26),UDim2.fromOffset(22,183),white,11)
local bestText=label(modal,"Best","Finish clean to set a personal best.",UDim2.new(1,-44,0,20),UDim2.fromOffset(22,214),gold,12)
local levelRow=frame(modal,"LevelSelection",UDim2.new(1,-44,0,30),UDim2.fromOffset(22,240),navy,1)
local levelButtons={}
for index=1,4 do
 local b=button(levelRow,"LevelButton"..index,"LEVEL "..index,UDim2.new(.25,-6,1,0),UDim2.new((index-1)*.25,3,0,0),Color3.fromRGB(44,61,84)); b.TextColor3=white; levelButtons[index]=b
 b.Activated:Connect(function() if index<=(p:GetAttribute("UnlockedLevel") or 1) then action:FireServer("SelectLevel",index) else showToast("Finish the previous course to unlock this level.") end end)
end
local startButton=button(modal,"StartButton","START SPEEDRUN",UDim2.new(1,-44,0,49),UDim2.fromOffset(22,285),cyan)
local footer=label(modal,"Footer","Free skip prototype / skips remove ranked time",UDim2.new(1,-44,0,20),UDim2.fromOffset(22,348),muted,10)
local overlay=frame(gui,"PanelOverlay",UDim2.fromScale(1,1),UDim2.new(),Color3.new(0,0,0),.2); overlay.Visible=false; overlay.Active=true; overlay.ZIndex=10
local panels={}
local function closePanels()
 for _,panel in pairs(panels) do panel.Visible=false end
 overlay.Visible=false; if refresh then refresh() end
end
local function panel(name,title,w,h)
 local f=frame(overlay,name,UDim2.new(.93,0,.9,0),UDim2.fromScale(.5,.5),navy,.01); f.AnchorPoint=Vector2.new(.5,.5); f.Visible=false; corner(f,18); stroke(f,cyan,.5); limit(f,w,h); panels[name]=f
 label(f,"Title",title,UDim2.new(1,-90,0,36),UDim2.fromOffset(22,15),white,24).TextXAlignment=Enum.TextXAlignment.Left
 local close=button(f,"CloseButton","X",UDim2.fromOffset(38,32),UDim2.new(1,-55,0,16),Color3.fromRGB(72,87,109)); close.TextColor3=white; close.Activated:Connect(closePanels)
 local scale=Instance.new("UIScale"); scale.Parent=f
 local function resize() scale.Scale=1 end
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize); resize()
 return f
end
local function openPanel(name)
 for key,f in pairs(panels) do f.Visible=key==name end
 overlay.Visible=true; modal.Visible=false
 if refresh then refresh() end
end
local shop=panel("ShopPanel","TRAILS & AURAS",650,510)
local shopStatus=label(shop,"Status","125 COINS",UDim2.new(1,-44,0,26),UDim2.fromOffset(22,58),gold,14); shopStatus.TextXAlignment=Enum.TextXAlignment.Left; fitText(shopStatus,14,8)
local scroll=Instance.new("ScrollingFrame"); scroll.Name="Items"; scroll.Position=UDim2.fromOffset(22,97); scroll.Size=UDim2.new(1,-44,1,-180); scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0; scroll.ScrollBarThickness=4; scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.CanvasSize=UDim2.new(); scroll.Parent=shop
local layout=Instance.new("UIListLayout"); layout.Padding=UDim.new(0,7); layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Parent=scroll
local shopRows={}
for itemIndex,item in ipairs(Config.Catalog) do
 local row=frame(scroll,item.Id,UDim2.new(1,-6,0,70),UDim2.new(),Color3.fromRGB(29,45,66)); row.LayoutOrder=itemIndex; corner(row,10)
 local swatch=frame(row,"Swatch",UDim2.fromOffset(6,44),UDim2.fromOffset(10,13),item.Color); corner(swatch,3)
 label(row,"Name",item.Name.." / "..string.upper(item.Kind),UDim2.new(1,-160,0,24),UDim2.fromOffset(26,9),white,15).TextXAlignment=Enum.TextXAlignment.Left
 label(row,"Description",item.Description,UDim2.new(1,-160,0,22),UDim2.fromOffset(26,34),muted,11).TextXAlignment=Enum.TextXAlignment.Left
 local buy=button(row,"Buy_"..item.Id,item.Price.." COINS",UDim2.fromOffset(116,42),UDim2.new(1,-128,.5,-21),item.Color); shopRows[item.Id]=buy
 buy.Activated:Connect(function()
  local owned={}; pcall(function() owned=HttpService:JSONDecode(p:GetAttribute("OwnedItems") or "{}") end)
  action:FireServer(owned[item.Id] and "EquipItem" or "BuyItem",item.Id)
 end)
end
local unequipTrail=button(shop,"UnequipTrail","NO TRAIL",UDim2.new(.5,-26,0,32),UDim2.new(0,22,1,-75),Color3.fromRGB(81,101,128)); unequipTrail.TextColor3=white; unequipTrail.Activated:Connect(function() action:FireServer("Unequip","Trail") end)
local unequipAura=button(shop,"UnequipAura","NO AURA",UDim2.new(.5,-26,0,32),UDim2.new(.5,4,1,-75),Color3.fromRGB(81,101,128)); unequipAura.TextColor3=white; unequipAura.Activated:Connect(function() action:FireServer("Unequip","Aura") end)
label(shop,"ShopRules","Cosmetics only / movement stays fair / race timer keeps running",UDim2.new(1,-44,0,20),UDim2.new(0,22,1,-30),muted,10)
local function refreshShop()
 shopStatus.Text=(p:GetAttribute("Coins") or 0).." COINS / "..(p:GetAttribute("DataStatus") or "WALLET LOADING")
 local owned={}; pcall(function() owned=HttpService:JSONDecode(p:GetAttribute("OwnedItems") or "{}") end)
 for _,item in ipairs(Config.Catalog) do
  local equipped=p:GetAttribute("Equipped"..item.Kind)==item.Id
  shopRows[item.Id].Text=equipped and "EQUIPPED" or owned[item.Id] and "EQUIP" or item.Price.." COINS"
  local affordable=owned[item.Id] or (p:GetAttribute("Coins") or 0)>=item.Price
  shopRows[item.Id].BackgroundColor3=affordable and item.Color or Color3.fromRGB(45,59,78)
  shopRows[item.Id].TextColor3=affordable and navy or red
 end
end
local board=panel("BoardPanel","SPEEDRUN RANKINGS",690,540)
local boardMode=label(board,"Mode","Loading rankings...",UDim2.new(1,-44,0,24),UDim2.fromOffset(22,58),gold,12); boardMode.TextXAlignment=Enum.TextXAlignment.Left
local tabs=frame(board,"Tabs",UDim2.new(1,-44,0,31),UDim2.fromOffset(22,92),navy,1)
local boardKey="Level1"; local boardVersion=0
local boardEntries=Instance.new("ScrollingFrame"); boardEntries.Name="Entries"; boardEntries.Size=UDim2.new(1,-52,1,-234); boardEntries.Position=UDim2.fromOffset(26,139); boardEntries.BackgroundTransparency=1; boardEntries.BorderSizePixel=0; boardEntries.ScrollBarThickness=4; boardEntries.AutomaticCanvasSize=Enum.AutomaticSize.Y; boardEntries.CanvasSize=UDim2.new(); boardEntries.Parent=board
local rows=label(boardEntries,"Rows","Finish a clean run to set a record.",UDim2.new(1,-6,0,0),UDim2.new(),white,17); rows.AutomaticSize=Enum.AutomaticSize.Y; rows.TextXAlignment=Enum.TextXAlignment.Left; rows.TextYAlignment=Enum.TextYAlignment.Top; rows.Font=Enum.Font.Code
local boardLayout=Instance.new("UIListLayout"); boardLayout.Padding=UDim.new(0,7); boardLayout.SortOrder=Enum.SortOrder.LayoutOrder; boardLayout.Parent=boardEntries
local function renderRecords(records)
 for _,child in boardEntries:GetChildren() do if child.Name=="Record" then child:Destroy() end end
 rows.Visible=#records==0; rows.Text="THE PODIUM IS OPEN\n\nFinish a clean run to claim your place."; rows.TextSize=14
 for rank,record in ipairs(records) do
  local row=frame(boardEntries,"Record",UDim2.new(1,-6,0,51),UDim2.new(),Color3.fromRGB(29,45,66)); row.LayoutOrder=rank; corner(row,8)
  local medal=rank==1 and gold or rank==2 and Color3.fromRGB(196,213,228) or rank==3 and Color3.fromRGB(213,161,111) or muted
  label(row,"Rank",string.format("%02d",rank),UDim2.fromOffset(38,51),UDim2.fromOffset(6,0),medal,18)
  local name=label(row,"Runner",record.Username,UDim2.new(1,-166,1,0),UDim2.fromOffset(50,0),white,14); name.TextXAlignment=Enum.TextXAlignment.Left; name.TextTruncate=Enum.TextTruncate.AtEnd; name.TextWrapped=false
  local clock=label(row,"Time",timeString(record.Milliseconds/1000),UDim2.fromOffset(112,51),UDim2.new(1,-118,0,0),cyan,16); clock.Font=Enum.Font.Code
 end
end
local boardNote=label(board,"Note","Clean, server-timed runs only. Skipped runs never submit.",UDim2.new(1,-44,0,36),UDim2.new(0,22,1,-89),muted,11)
local refreshBoardButton=button(board,"RefreshButton","REFRESH",UDim2.new(1,-44,0,31),UDim2.new(0,22,1,-45),Color3.fromRGB(151,179,224))
local function loadBoard(key)
 boardKey=key; boardVersion+=1; local version=boardVersion
 for _,b in tabs:GetChildren() do if b:IsA("TextButton") then b.BackgroundColor3=b.Name=="Tab"..key and cyan or Color3.fromRGB(45,63,87); b.TextColor3=b.Name=="Tab"..key and navy or white end end
 boardMode.Text="LOADING / "..(key=="Campaign" and "ALL FOUR LEVELS" or key)
 task.spawn(function()
  local ok,data=pcall(function() return query:InvokeServer(key) end)
  if version~=boardVersion then return end
  if not ok then renderRecords({}); boardMode.Text="RANKINGS UNAVAILABLE"; rows.Text="Try refreshing in a moment."; return end
  boardMode.Text=data.Mode.." / "..(key=="Campaign" and "FULL CAMPAIGN" or key)
  renderRecords(data.Rows or {})
  boardNote.Text=data.Mode=="GLOBAL" and "Fastest clean times across all servers / refreshes about once a minute." or "Global records activate after publication and data access. Current session shown."
 end)
end
for i=1,5 do
 local key=i==5 and "Campaign" or "Level"..i
 local b=button(tabs,"Tab"..key,i==5 and "CAMPAIGN" or "LEVEL "..i,UDim2.new(.2,-5,1,0),UDim2.new((i-1)*.2,2,0,0),Color3.fromRGB(72,97,132)); b.TextColor3=white; b.Activated:Connect(function() loadBoard(key) end)
end
refreshBoardButton.Activated:Connect(function() loadBoard(boardKey) end)
local skip=panel("SkipPanel","SKIP TO CHECKPOINT?",490,295)
local skipWords=label(skip,"Warning","Your current time will be removed. This level run and its full campaign will not count on leaderboards.",UDim2.new(1,-48,0,85),UDim2.fromOffset(24,71),white,17)
local skipNotice=label(skip,"PriceNote","FREE PROTOTYPE / NO ROBUX CHARGED",UDim2.new(1,-44,0,30),UDim2.fromOffset(22,164),gold,12)
local confirmSkip=button(skip,"ConfirmSkip","SKIP & REMOVE TIME",UDim2.new(1,-44,0,43),UDim2.fromOffset(22,210),Color3.fromRGB(205,160,255))
skipWords.Position=UDim2.fromOffset(24,60); skipWords.Size=UDim2.new(1,-48,.30,0); fitText(skipWords,17,12)
skipNotice.Position=UDim2.new(0,22,1,-118)
confirmSkip.Position=UDim2.new(0,22,1,-72)
confirmSkip.Activated:Connect(function() action:FireServer("Skip"); closePanels() end)
label(skip,"SkipFooter","Restarting starts a fresh run eligible for a new time.",UDim2.new(1,-44,0,22),UDim2.fromOffset(22,263),muted,10)
skip.SkipFooter.Position=UDim2.new(0,22,1,-27)
shopButton.Activated:Connect(function() refreshShop(); openPanel("ShopPanel") end)
boardButton.Activated:Connect(function() openPanel("BoardPanel"); loadBoard("Level"..(p:GetAttribute("CurrentLevel") or 1)) end)
restartButton.Activated:Connect(function() closePanels(); action:FireServer("Start") end)
skipButton.Activated:Connect(function()
 if p:GetAttribute("State")~="Racing" then showToast("Start a run before using a skip."); return end
 local stage=p:GetAttribute("Stage") or 0; local count=p:GetAttribute("LevelCheckpointCount") or 1
 skipWords.Text="Skip to "..(stage<count and ("checkpoint "..(stage+1)) or "the finish").."? Your time will be removed. This run and its campaign will not enter leaderboards."
 skipNotice.Text=Config.PrototypeSkipEnabled and "FREE PROTOTYPE / NO ROBUX CHARGED" or "PURCHASES HAVE NOT BEEN CONFIGURED"
 openPanel("SkipPanel")
end)
startButton.Activated:Connect(function()
 if p:GetAttribute("State")=="Finished" then action:FireServer((p:GetAttribute("CurrentLevel") or 1)<4 and "Next" or "Campaign") else action:FireServer("Start") end
end)
local audioPanel=panel("AudioPanel","SOUND & EFFECTS",540,390)
local audioContent=Instance.new("ScrollingFrame");audioContent.Name="AudioControls";audioContent.BackgroundTransparency=1;audioContent.BorderSizePixel=0;audioContent.Position=UDim2.fromOffset(12,64);audioContent.Size=UDim2.new(1,-24,1,-78);audioContent.CanvasSize=UDim2.fromOffset(0,280);audioContent.ScrollBarThickness=4;audioContent.Parent=audioPanel
local nowPlaying=label(audioContent,"NowPlaying","ARCADE SOUNDTRACK",UDim2.new(1,-24,0,35),UDim2.fromOffset(12,0),cyan,12)
local function updateTrack() nowPlaying.Text="NOW PLAYING / "..(p:GetAttribute("NowPlaying") or "Loading soundtrack") end
p:GetAttributeChangedSignal("NowPlaying"):Connect(updateTrack);updateTrack()
local function volumeRow(attribute,title,y)
 label(audioContent,attribute.."Label",title,UDim2.new(.45,-22,0,34),UDim2.fromOffset(12,y),white,14).TextXAlignment=Enum.TextXAlignment.Left
 local minus=button(audioContent,attribute.."Down","−",UDim2.new(.12,0,0,34),UDim2.new(.47,0,0,y),Color3.fromRGB(64,88,115))
 local value=button(audioContent,attribute.."Mute","",UDim2.new(.22,-12,0,34),UDim2.new(.60,0,0,y),Color3.fromRGB(101,179,190))
 local plus=button(audioContent,attribute.."Up","+",UDim2.new(.12,0,0,34),UDim2.new(.83,0,0,y),Color3.fromRGB(64,88,115))
 local previous=p:GetAttribute(attribute) or .3
 local function refreshVolume() local v=p:GetAttribute(attribute) or 0;value.Text=v==0 and "MUTED" or string.format("%d%%",math.floor(v*100+.5)) end
 minus.Activated:Connect(function() p:SetAttribute(attribute,math.max(0,math.floor(((p:GetAttribute(attribute) or 0)-.1)*100+.5)/100)) end)
 plus.Activated:Connect(function() p:SetAttribute(attribute,math.min(1,math.floor(((p:GetAttribute(attribute) or 0)+.1)*100+.5)/100)) end)
 value.Activated:Connect(function() local v=p:GetAttribute(attribute) or 0;if v>0 then previous=v;p:SetAttribute(attribute,0) else p:SetAttribute(attribute,previous) end end)
 p:GetAttributeChangedSignal(attribute):Connect(refreshVolume);refreshVolume()
end
volumeRow("MusicVolume","MUSIC",50)
volumeRow("EffectsVolume","SOUND EFFECTS",100)
local reduced=button(audioContent,"ReducedEffects","",UDim2.new(1,-24,0,38),UDim2.fromOffset(12,161),Color3.fromRGB(153,188,220))
local function refreshReduced() reduced.Text=p:GetAttribute("ReducedEffects") and "VISUAL EFFECTS: REDUCED" or "VISUAL EFFECTS: FULL" end
reduced.Activated:Connect(function() p:SetAttribute("ReducedEffects",not p:GetAttribute("ReducedEffects")) end);refreshReduced()
label(audioContent,"AudioNote","Tap a percentage to mute. Preferences apply to this session.\nLow graphics also reduces particles. Race timing is unchanged.",UDim2.new(1,-24,0,56),UDim2.fromOffset(12,212),muted,11)
audioButton.Activated:Connect(function() openPanel("AudioPanel") end)
-- Expedition design system: quiet surfaces, one bright action, illustrated course identity.
local function gradient(obj,a,b,rotation)
 obj.BackgroundColor3=Color3.new(1,1,1)
 local g=Instance.new("UIGradient"); g.Color=ColorSequence.new(a,b); g.Rotation=rotation or 90; g.Parent=obj; return g
end
gradient(modal,Color3.fromRGB(23,38,57),navy,115)
for _,panelFrame in pairs(panels) do gradient(panelFrame,Color3.fromRGB(23,37,55),navy,110) end
local veil=frame(gui,"MenuVeil",UDim2.fromScale(1,1),UDim2.new(),navy,.76); veil.ZIndex=0
for _,obj in {top,toolbar,objective,toast,modal} do obj.ZIndex=2 end
local hero=frame(modal,"CourseIllustration",UDim2.new(.32,-12,0,230),UDim2.fromOffset(20,22),Color3.fromRGB(22,58,67)); corner(hero,14); hero.ClipsDescendants=true
local heroGradient=gradient(hero,Color3.fromRGB(29,100,105),Color3.fromRGB(13,30,48),135)
local halo=frame(hero,"Sun",UDim2.fromOffset(96,96),UDim2.new(.5,-48,0,26),cyan,.88); corner(halo,100); stroke(halo,cyan,.7)
local heroNumber=label(hero,"CourseNumber","01",UDim2.new(1,0,0,68),UDim2.fromOffset(0,35),white,50)
local islandPieces={}
for i=1,6 do
 local x=.2+(i%2)*.25; local y=.46+i*.055
 local shadow=frame(hero,"IslandCore",UDim2.new(.40,0,0,15),UDim2.fromScale(x,y),Color3.fromRGB(20,31,49)); shadow.Rotation=-12; corner(shadow,3)
 local tile=frame(hero,"IslandTop",UDim2.new(.40,0,0,5),UDim2.fromScale(x,y),cyan); tile.Rotation=-12; corner(tile,2); table.insert(islandPieces,tile)
end
local heroCaption=label(hero,"Caption","SKY GARDENS",UDim2.new(1,-16,0,25),UDim2.new(0,8,1,-38),white,12)
local statPill=label(modal,"CourseStats","8 SECTIONS    /    768 STUDS",UDim2.new(.60,-18,0,24),UDim2.new(.36,0,0,184),cyan,12); statPill.TextXAlignment=Enum.TextXAlignment.Left
local routeTitle=label(modal,"RouteTitle","CHOOSE YOUR COURSE",UDim2.new(1,-44,0,20),UDim2.fromOffset(22,262),muted,10); routeTitle.TextXAlignment=Enum.TextXAlignment.Left
local courseNames={"ASCENT","EMBER","STORM","SOLAR"}
local courseThemes={"SKY GARDENS","FORGOTTEN FOUNDRY","TEMPEST STATION","ORBITAL REACTOR"}
local courseSubtitles={"Find your rhythm above the clouds.","Race through a forgotten sky foundry.","Ride the machines that harvest storms.","Escape a fractured orbital reactor."}
local courseCaptions={}
for i,b in ipairs(levelButtons) do
 b.Text=""; b.ClipsDescendants=true
 local stripe=frame(b,"Accent",UDim2.new(1,0,0,3),UDim2.new(),Config.Levels[i].Color)
 local title=label(b,"CourseName",string.format("%02d  %s",i,courseNames[i]),UDim2.new(1,-12,0,22),UDim2.fromOffset(6,8),white,12); fitText(title,12,9)
 local subtitle=label(b,"CourseAccess","EASY",UDim2.new(1,-12,0,18),UDim2.fromOffset(6,31),muted,10); courseCaptions[i]={title,subtitle}
end
-- Trail previews are drawn from the actual catalog colors; no external image assets.
for _,item in ipairs(Config.Catalog) do
 local row=scroll:FindFirstChild(item.Id); row.Size=UDim2.new(1,-6,0,88)
 row.Swatch:Destroy()
 local preview=frame(row,"Preview",UDim2.fromOffset(50,58),UDim2.fromOffset(9,15),Color3.fromRGB(16,28,43)); corner(preview,8)
 if item.Kind=="Trail" then
  for j=1,4 do local ribbon=frame(preview,"Ribbon",UDim2.fromOffset(31-j*3,4),UDim2.fromOffset(7+j*2,10+j*7),item.Color,(j-1)*.18); ribbon.Rotation=-25; corner(ribbon,3) end
 else
  local ring=frame(preview,"Aura",UDim2.fromOffset(29,29),UDim2.fromOffset(10,14),item.Color,.9); corner(ring,100); stroke(ring,item.Color,.1)
  local core=frame(preview,"Core",UDim2.fromOffset(9,18),UDim2.fromOffset(20,20),item.Color,.25); corner(core,5)
 end
 row.Name=""..item.Id
 row:FindFirstChild("Name").Position=UDim2.fromOffset(70,18); row:FindFirstChild("Name").Size=UDim2.new(1,-203,0,25)
 row.Description.Position=UDim2.fromOffset(70,43); row.Description.Size=UDim2.new(1,-203,0,24)
 row.Description.TextSize=11; row:FindFirstChild("Name").TextSize=14
 row:FindFirstChild("Name").Text=item.Name; fitText(row:FindFirstChild("Name"),14,11)
end
local function layoutRaceHUD(playing)
 local narrow=gui.AbsoluteSize.X<600
 local headerHeight=compact and 64 or 76
 local rowY=playing and headerHeight+8 or 0
 local rowHeight=playing and narrow and 68 or 32
 statusRow.Position=UDim2.fromOffset(0,rowY);statusRow.Size=UDim2.new(1,0,0,rowHeight)
 objective.AnchorPoint=Vector2.zero;objective.Position=UDim2.new()
 objective.Size=UDim2.new(1,playing and narrow and 0 or -226,0,32)
 raceMenu.Size=UDim2.fromOffset(78,32);graphics.Size=UDim2.fromOffset(132,32)
 local controlsY=playing and narrow and 36 or 0
 raceMenu.Position=UDim2.new(1,-140,0,controlsY)
 graphics.Position=UDim2.new(1,0,0,controlsY)
 if playing then
  toolbar.Parent=hud;toolbar.Size=UDim2.new(1,0,0,32)
  toolbar.Position=UDim2.new(.5,0,0,rowY+rowHeight+8)
 else
  toolbar.Parent=gui;toolbar.Size=UDim2.new(.88,0,0,32)
  toolbar.Position=UDim2.new(.5,0,1,-45)
 end
end
local function fitCard()
 local v=gui.AbsoluteSize; compact=v.Y<500
 local narrow=v.X<600
 modal.Size=UDim2.new(.94,0,0,440)
 modalScale.Scale=math.min(1,math.max(.45,(v.Y-(compact and 60 or 180))/440))
 modal.Position=compact and UDim2.new(.5,0,.5,-20) or UDim2.new(.5,0,.5,22)
 hero.Visible=not narrow
 kicker.Position=UDim2.new(narrow and 0 or .36,narrow and 22 or 0,0,26); kicker.Size=UDim2.new(narrow and 1 or .60,-44,0,22); kicker.TextXAlignment=Enum.TextXAlignment.Left
 heading.Position=UDim2.new(narrow and 0 or .36,narrow and 22 or 0,0,58); heading.Size=UDim2.new(narrow and 1 or .61,-40,0,48); heading.TextXAlignment=Enum.TextXAlignment.Left
 body.Position=UDim2.new(narrow and 0 or .36,narrow and 22 or 0,0,115); body.Size=UDim2.new(narrow and 1 or .61,-44,0,56); body.TextXAlignment=Enum.TextXAlignment.Left
 statPill.Position=UDim2.new(narrow and 0 or .36,narrow and 22 or 0,0,184); statPill.Size=UDim2.new(narrow and 1 or .61,-44,0,24)
 bestText.Position=UDim2.new(narrow and 0 or .36,narrow and 22 or 0,0,217); bestText.Size=UDim2.new(narrow and 1 or .61,-44,0,24); bestText.TextXAlignment=Enum.TextXAlignment.Left
 rulesText.Position=UDim2.fromOffset(22,409); rulesText.Size=UDim2.new(1,-44,0,19); rulesText.TextSize=9
 levelRow.Position=UDim2.fromOffset(22,289); levelRow.Size=UDim2.new(1,-44,0,59)
 startButton.Position=UDim2.fromOffset(22,362); startButton.Size=UDim2.new(1,-44,0,43)
 footer.Visible=false
 top.Size=UDim2.new(1,0,0,compact and 64 or 76)
 brand.Position=UDim2.fromOffset(15,compact and 5 or 7); brand.TextSize=16
 levelText.Position=UDim2.fromOffset(15,compact and 32 or 38)
 timer.Position=UDim2.new(.36,0,0,compact and 0 or 2)
 rankStatus.Position=UDim2.new(.36,0,0,compact and 32 or 39)
 wallet.Position=UDim2.new(.73,0,0,compact and 0 or 4)
 pickupText.Position=UDim2.new(.73,0,0,compact and 32 or 39)
 toolbar.Size=UDim2.new(.88,0,0,32)
 toolbar:FindFirstChildOfClass("UISizeConstraint").MaxSize=Vector2.new(550,32)
 if refresh then refresh() end
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitCard); fitCard()
refresh=function()
 local level=p:GetAttribute("CurrentLevel") or 1; local spec=Config.Levels[level]; local state=p:GetAttribute("State") or "Loading"; local accent=spec.Color
 local playing=state=="Racing" or state=="Armed"
 levelText.Text="LEVEL "..level.." / "..string.upper(spec.Title)
 rankStatus.Text=state=="Armed" and "CROSS BLUE GATE TO START" or p:GetAttribute("RankStatus") or "RANKED SPEEDRUN"; rankStatus.TextColor3=p:GetAttribute("RankEligible") and accent or red
 wallet.Text=(p:GetAttribute("Coins") or 0).." COINS"
 pickupText.Text=(p:GetAttribute("Orbs") or 0).." / "..(spec.Sections*3).." PICKUPS"
 fill.Size=UDim2.fromScale(p:GetAttribute("Progress") or 0,1); fill.BackgroundColor3=accent
 modal.Visible=not playing and not overlay.Visible
 updateMovement(playing and not overlay.Visible)
 top.Visible=playing
 raceMenu.Visible=playing; raceMenu.Text=raceMenuOpen and "CLOSE" or "MENU"
 toolbar.Visible=not playing or raceMenuOpen
 objective.Visible=playing;graphics.Visible=not overlay.Visible
 layoutRaceHUD(playing)
 kicker.TextColor3=accent; startButton.BackgroundColor3=accent
 veil.Visible=not playing and not overlay.Visible
 heroNumber.Text=string.format("%02d",level); heroCaption.Text=courseThemes[level]; halo.BackgroundColor3=accent
 heroGradient.Color=ColorSequence.new(accent:Lerp(navy,.65),navy)
 for _,tile in ipairs(islandPieces) do tile.BackgroundColor3=accent end
 statPill.Text=spec.Sections.." SECTIONS    /    "..(spec.Sections*96).." STUDS"; statPill.TextColor3=accent
 for i,labels in ipairs(courseCaptions) do labels[1].TextColor3=i==level and navy or white; labels[2].TextColor3=i==level and navy or muted; labels[2].Text=i<=(p:GetAttribute("UnlockedLevel") or 1) and Config.Levels[i].Difficulty or "LOCKED" end
 for i,b in ipairs(levelButtons) do local unlocked=i<=(p:GetAttribute("UnlockedLevel") or 1); b.Text=""; b.BackgroundColor3=i==level and accent or Color3.fromRGB(44,61,84); b.TextColor3=i==level and navy or unlocked and white or muted end
 if state=="Loading" then heading.Text="LOADING..."; body.Text="Preparing your course and wallet."; startButton.Text="LOADING..."
 elseif state=="Finished" then
  local skipped=p:GetAttribute("UsedSkip"); local ranked=p:GetAttribute("RankEligible")
  kicker.Text=level==4 and "FOUR COURSES COMPLETE" or "LEVEL "..(level+1).." UNLOCKED"
  heading.Text=skipped and "ASSISTED CLEAR" or "COURSE COMPLETE!"
  body.Text=skipped and "USED SKIP / No time recorded.\nYou can keep exploring or restart for a ranked run." or (timeString(p:GetAttribute("FinishTime") or 0)..(ranked and " / CLEAN RUN" or " / UNRANKED").."\n"..spec.Title)
  startButton.Text=level<4 and "NEXT LEVEL  →" or "RESTART FULL CAMPAIGN  →"
 else
  kicker.Text="SKYFALL RUSH / "..spec.Difficulty
  heading.Text=string.upper(spec.Title)
  body.Text=courseSubtitles[level].."\n"..spec.Summary
  startButton.Text="ENTER COURSE  →"
 end
 local best=p:GetAttribute("BestTime") or 0
 bestText.Text=best>0 and "PERSONAL BEST / "..timeString(best) or "Finish clean to set a personal best."
 rulesText.Text=UIS.TouchEnabled and "STICK + JUMP   •   CYAN SOLID / PINK GHOST / RED DANGER" or "WASD + SPACE   •   CYAN SOLID / PINK GHOST / RED DANGER"
 if state=="Armed" then objectiveText.Text="TIMER READY / Walk through the blue gate to begin"
 elseif playing then
  local section=p:GetAttribute("Section") or 1; local pattern=spec.Patterns[section]
  objectiveText.Text=string.format("%s / Section %d of %d / Checkpoint %d of %d",string.upper(pattern or "FINISH"),section,spec.Sections,p:GetAttribute("Stage") or 0,spec.Sections/4-1)
 elseif state=="Finished" then objectiveText.Text=p:GetAttribute("UsedSkip") and "USED SKIP / UNRANKED / Your previous records are unchanged." or "Course complete. Continue the campaign or replay an unlocked level."
 else objectiveText.Text="Gold coins buy cosmetics / Red is dangerous / Skips remove the current ranked time" end
end
for _,attr in {"State","Coins","CurrentLevel","UnlockedLevel","Orbs","Stage","Section","Progress","RankStatus","RankEligible","UsedSkip","BestTime","FinishTime","OwnedItems","EquippedTrail","EquippedAura","DataStatus"} do p:GetAttributeChangedSignal(attr):Connect(refresh) end
for _,attr in {"Coins","OwnedItems","EquippedTrail","EquippedAura","DataStatus"} do p:GetAttributeChangedSignal(attr):Connect(refreshShop) end
refreshShop()
p:GetAttributeChangedSignal("MessageId"):Connect(function() showToast(p:GetAttribute("Message") or "") end)
local initial=setmetatable({},{__mode="k"}); local collectedCoins={}
local function registerCoin(obj)
 if not obj:IsA("BasePart") or not obj.Parent or obj.Parent.Name~="Orbs" then return end
 local map=obj.Parent.Parent
 if not map then return end
 initial[obj]=obj.Position
 local key=map.Name..":"..tostring(obj:GetAttribute("OrbId"))
 obj.LocalTransparencyModifier=collectedCoins[key] and 1 or 0
end
maps.DescendantAdded:Connect(function(obj)
 registerCoin(obj)
end)
for _,map in maps:GetChildren() do
 for _,orb in map.Orbs:GetChildren() do registerCoin(orb) end
end
action.OnClientEvent:Connect(function(kind,level,id)
 if kind=="Reset" then
  table.clear(collectedCoins)
  for _,map in maps:GetChildren() do for _,orb in map.Orbs:GetChildren() do orb.LocalTransparencyModifier=0 end end
 elseif kind=="Collected" then
  collectedCoins["Level"..level..":"..id]=true
  local map=maps:FindFirstChild("Level"..level); local orb=map and map.Orbs:FindFirstChild("Orb_"..id); if orb then orb.LocalTransparencyModifier=1 end
 elseif kind=="OpenShop" then refreshShop(); openPanel("ShopPanel")
 elseif kind=="OpenBoard" then openPanel("BoardPanel"); loadBoard("Level"..level)
 elseif kind=="Spring" then
  local char=p.Character; local root=char and char:FindFirstChild("HumanoidRootPart"); local h=char and char:FindFirstChildOfClass("Humanoid")
  if root and h and typeof(level)=="Vector3" then h:ChangeState(Enum.HumanoidStateType.Jumping); root.AssemblyLinearVelocity=level end
  showToast("SPRING LAUNCH / HOLD FORWARD")
 end
end)
local rayParams=RaycastParams.new(); rayParams.FilterType=Enum.RaycastFilterType.Include
local previousFloor; local previousFloorPosition
RunService.RenderStepped:Connect(function()
 local char=p.Character; local root=char and char:FindFirstChild("HumanoidRootPart"); local h=char and char:FindFirstChildOfClass("Humanoid"); local map=maps:FindFirstChild("Level"..(p:GetAttribute("CurrentLevel") or 1))
 if not root or not h or not map then previousFloor=nil; previousFloorPosition=nil; return end
 if previousFloor and previousFloor.Parent and previousFloorPosition and h.FloorMaterial~=Enum.Material.Air then
  local delta=previousFloor.Position-previousFloorPosition
  if delta.Magnitude<4 then root.CFrame+=delta end
 end
 rayParams.FilterDescendantsInstances={map.Platforms}
 local hit=workspace:Raycast(root.Position,Vector3.new(0,-5,0),rayParams)
 local floor=hit and hit.Instance
 previousFloor=floor and floor:GetAttribute("Moving") and floor or nil
 previousFloorPosition=previousFloor and previousFloor.Position or nil
end)
local coinTick=0
RunService.RenderStepped:Connect(function(dt)
 local state=p:GetAttribute("State")
 if p:GetAttribute("UsedSkip") then timer.Text="USED SKIP"; timer.TextColor3=red
 else
  local seconds=p:GetAttribute("RunTime") or 0; local started=p:GetAttribute("RunStartedAt") or 0
  if state=="Racing" and started>0 then seconds=workspace:GetServerTimeNow()-started+(p:GetAttribute("PenaltySeconds") or 0) end
  timer.Text=state=="Armed" and "READY" or timeString(seconds); timer.TextColor3=state=="Armed" and cyan or white
 end
 local map=maps:FindFirstChild("Level"..(p:GetAttribute("CurrentLevel") or 1)); if not map then return end
 coinTick+=dt;local low=p:GetAttribute("LowGraphics")==true
 if coinTick<(low and 1/15 or 1/30) then return end;coinTick=0
 local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart");if not root then return end
 local t=workspace:GetServerTimeNow()
 for _,orb in map.Orbs:GetChildren() do
  if orb.LocalTransparencyModifier==1 or (orb.Position-root.Position).Magnitude>160 then continue end
  local base=initial[orb]; local following=orb:GetAttribute("FollowPlatform")
  if following then local platform=map.Platforms:FindFirstChild(following); if platform then base=platform.Position+orb:GetAttribute("FollowOffset") end end
  if base then orb.Position=base+Vector3.new(0,math.sin(t*2+orb:GetAttribute("OrbId"))*.16,0) end
 end
end)
refresh()

-- Checkpoint split coaching stays local; only server records enter the rankings.
local splitBest={}; local lastStage=0
p:GetAttributeChangedSignal("State"):Connect(function()
 if p:GetAttribute("State")=="Ready" or p:GetAttribute("State")=="Racing" then lastStage=0 end
end)
p:GetAttributeChangedSignal("Stage"):Connect(function()
 local stage=p:GetAttribute("Stage") or 0
 if stage<=lastStage then lastStage=stage; return end
 lastStage=stage
 if p:GetAttribute("State")~="Racing" or p:GetAttribute("UsedSkip") then return end
 local level=p:GetAttribute("CurrentLevel") or 1
 local t=workspace:GetServerTimeNow()-(p:GetAttribute("RunStartedAt") or 0)+(p:GetAttribute("PenaltySeconds") or 0)
 local key=level..":"..stage; local previous=splitBest[key]; splitBest[key]=math.min(previous or t,t)
 showToast("CHECKPOINT "..stage.."  /  "..timeString(t)..(previous and string.format("  /  %+.2fs vs session best",t-previous) or "  /  SPLIT SAVED"))
end)

local visualRotors={}; local registeredRotors=setmetatable({},{__mode="k"})
local function registerRotor(model)
 if not model:IsA("Model") or not model:GetAttribute("SpinVisual") or registeredRotors[model] then return end
 local map=model
 while map and map.Parent~=maps do map=map.Parent end
 if not map then return end
 registeredRotors[model]=true
 table.insert(visualRotors,{model=model,base=model:GetPivot(),level=map.Name,angle=0})
end
for _,model in maps:GetDescendants() do registerRotor(model) end
maps.DescendantAdded:Connect(function(obj)
 if obj:IsA("Model") then task.defer(function() if obj.Parent then registerRotor(obj) end end) end
end)
maps.DescendantRemoving:Connect(function(obj)
 initial[obj]=nil
 if registeredRotors[obj] then
  registeredRotors[obj]=nil
  for i=#visualRotors,1,-1 do if visualRotors[i].model==obj then table.remove(visualRotors,i) end end
 end
end)
local rotorTick=0
RunService.Heartbeat:Connect(function(dt)
 rotorTick+=dt; if rotorTick<1/20 then return end
 local step=rotorTick; rotorTick=0
 if p:GetAttribute("LowGraphics") then rotorTick=0;return end
 local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart");if not root then return end
 local current="Level"..(p:GetAttribute("CurrentLevel") or 1)
 for _,rotor in ipairs(visualRotors) do
  if rotor.model.Parent and rotor.level==current and (rotor.base.Position-root.Position).Magnitude<220 then rotor.angle+=step*.25; rotor.model:PivotTo(rotor.base*CFrame.Angles(0,0,rotor.angle)) end
 end
end)

for _,b in {shopButton,boardButton,restartButton,skipButton,audioButton} do b.BackgroundColor3=Color3.fromRGB(23,37,55); b.TextColor3=white; stroke(b,muted,.82) end
shopButton.TextColor3=gold; skipButton.TextColor3=Color3.fromRGB(205,160,255)
-- Menu camera establishes the selected world; gameplay immediately restores avatar control.
local menuCamera=false
RunService.RenderStepped:Connect(function()
 local camera=workspace.CurrentCamera; if not camera then return end
 local state=p:GetAttribute("State")
 if state=="Ready" or state=="Loading" then
  local spec=Config.Levels[p:GetAttribute("CurrentLevel") or 1]
  menuCamera=true; camera.CameraType=Enum.CameraType.Scriptable
  camera.CFrame=CFrame.lookAt(Vector3.new(spec.X+51,58,32),Vector3.new(spec.X,22,-90))
 elseif menuCamera then
  menuCamera=false; camera.CameraType=Enum.CameraType.Custom
  local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid"); if h then camera.CameraSubject=h end
 end
end)


