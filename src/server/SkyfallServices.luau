-- ServerScriptService > SkyfallServices (ModuleScript)
local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local HttpService=game:GetService("HttpService")
local Config=require(game.ReplicatedStorage.SkyfallConfig)
local Rules=require(script.Parent.SkyfallRules)
local Services={Profiles={},PendingRecords=0}
local profiles=Services.Profiles
local live=game.GameId>0
local job=game.JobId~="" and game.JobId or HttpService:GenerateGUID(false)
local profileStore=live and DataStoreService:GetDataStore(Config.ProfileStore) or nil
local catalog={}; for _,item in ipairs(Config.Catalog) do catalog[item.Id]=item end
local boards={}; local stores={}; local memory={}; local nameCache={}
local function sanitize(old)
 local data={Coins=Config.StartingCoins,Unlocked=1,Wins=0,Owned={},EquippedTrail="None",EquippedAura="None",Best={},Cleared={},RecordVersion=Config.Version}
 if typeof(old)=="table" then
  data.Coins=math.clamp(math.floor(tonumber(old.Coins) or Config.StartingCoins),0,2147483647)
  data.Unlocked=math.clamp(math.floor(tonumber(old.Unlocked) or 1),1,4)
  data.Wins=math.clamp(math.floor(tonumber(old.Wins) or 0),0,2147483647)
  if typeof(old.Owned)=="table" then for id in pairs(old.Owned) do if catalog[id] then data.Owned[id]=true end end end
  for _,kind in {"Trail","Aura"} do local id=old["Equipped"..kind]; if catalog[id] and catalog[id].Kind==kind and data.Owned[id] then data["Equipped"..kind]=id end end
  if old.RecordVersion==Config.Version and typeof(old.Best)=="table" then for key,v in pairs(old.Best) do if typeof(v)=="number" and v>0 and v<86400000 then data.Best[tostring(key)]=math.floor(v) end end end
  if typeof(old.Cleared)=="table" then for i=1,4 do data.Cleared[tostring(i)]=old.Cleared[tostring(i)]==true end end
 end
 return data
end
function Services.Sync(p)
 local d=profiles[p]; if not d then return end
 p:SetAttribute("Coins",d.Coins); p:SetAttribute("UnlockedLevel",d.Unlocked)
 p:SetAttribute("OwnedItems",HttpService:JSONEncode(d.Owned))
 p:SetAttribute("EquippedTrail",d.EquippedTrail); p:SetAttribute("EquippedAura",d.EquippedAura)
 p:SetAttribute("SavingAvailable",d.CanSave==true)
 if p:FindFirstChild("leaderstats") then p.leaderstats.Coins.Value=d.Coins; p.leaderstats.Wins.Value=d.Wins or 0 end
end
function Services.Load(p)
 local data=sanitize(nil); data.CanSave=false
 local leaseToken=job..":"..HttpService:GenerateGUID(false)
 if live then
  for attempt=1,3 do
   local success,value=pcall(function()
    return profileStore:UpdateAsync(tostring(p.UserId),function(old)
     if typeof(old)=="table" and typeof(old.Session)=="table" and old.Session.Job~=leaseToken and os.time()-(old.Session.At or 0)<180 then return nil end
     local nextData=sanitize(old); nextData.Session={Job=leaseToken,At=os.time()}; return nextData
    end)
   end)
   if success and typeof(value)=="table" then data=sanitize(value); data.CanSave=true; break end
   task.wait(attempt)
  end
 end
 data.LeaseToken=leaseToken
 profiles[p]=data; Services.Sync(p); p:SetAttribute("ProfileLoaded",true)
 p:SetAttribute("DataStatus",data.CanSave and "SAVED WALLET" or (live and "SESSION WALLET / SAVING UNAVAILABLE" or "LOCAL PREVIEW / SESSION WALLET"))
 return data
end
function Services.Save(p,release)
 local d=profiles[p]; if not d then return end
 if not d.CanSave then if release then profiles[p]=nil end; return end
 if d.Busy then d.ReleaseRequested=d.ReleaseRequested or release; return end
 d.Busy=true
 local snapshot=sanitize(d)
 local ok,committed
 for attempt=1,3 do
  ok,committed=pcall(function()
   return profileStore:UpdateAsync(tostring(p.UserId),function(old)
    if typeof(old)~="table" or typeof(old.Session)~="table" or old.Session.Job~=d.LeaseToken then return nil end
    if release then snapshot.Session=nil else snapshot.Session={Job=d.LeaseToken,At=os.time()} end
    return snapshot
   end)
  end)
  if ok then break end
  task.wait(attempt)
 end
 d.Busy=false
 if ok and not committed then d.CanSave=false end
 if not ok or not committed then
  if p.Parent then p:SetAttribute("DataStatus",d.CanSave and "SAVING DELAYED / RETRYING" or "SESSION WALLET / SAVING UNAVAILABLE"); Services.Sync(p) end
 elseif p.Parent then p:SetAttribute("DataStatus","SAVED WALLET") end
 if release then profiles[p]=nil
 elseif d.ReleaseRequested then d.ReleaseRequested=false; Services.Save(p,true) end
end
function Services.Award(p,amount)
 local d=profiles[p]; if not d then return end
 d.Coins=math.clamp(d.Coins+math.max(0,math.floor(amount)),0,2147483647); Services.Sync(p)
end
function Services.ApplyCosmetics(p)
 local d=profiles[p]; local char=p.Character
 if not d or not char then return end
 local root=char:FindFirstChild("HumanoidRootPart"); local head=char:FindFirstChild("Head"); if not root then return end
 for _,obj in char:GetChildren() do if obj.Name=="SkyfallAura" or obj.Name=="SkyfallHalo" then obj:Destroy() end end
 for _,obj in root:GetChildren() do if obj.Name:match("^SkyfallCosmetic") then obj:Destroy() end end
 local item=catalog[d.EquippedTrail]
 if item then
  local a=Instance.new("Attachment"); a.Name="SkyfallCosmeticA"; a.Position=Vector3.new(-.65,.1,.2); a.Parent=root
  local b=Instance.new("Attachment"); b.Name="SkyfallCosmeticB"; b.Position=Vector3.new(.65,.1,.2); b.Parent=root
  local trail=Instance.new("Trail"); trail.Name="SkyfallCosmeticTrail"; trail.Attachment0=a; trail.Attachment1=b; trail.Color=ColorSequence.new(item.Color,Color3.new(1,1,1)); trail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.1),NumberSequenceKeypoint.new(1,1)}); trail.Lifetime=.55; trail.MinLength=.05; trail.LightEmission=.8; trail.FaceCamera=true; trail.Parent=root
 end
 local aura=catalog[d.EquippedAura]
 if aura then
  if aura.Id=="SolarHalo" and head then
   local folder=Instance.new("Folder"); folder.Name="SkyfallHalo"; folder.Parent=char
   for i=1,12 do
    local angle=i*math.pi/6; local part=Instance.new("Part"); part.Name="HaloSegment"; part.Size=Vector3.new(.65,.12,.18); part.Material=Enum.Material.Neon; part.Color=aura.Color; part.CanCollide=false; part.CanTouch=false; part.CanQuery=false; part.Massless=true; part.CFrame=head.CFrame*CFrame.new(math.cos(angle)*1.2,1.1,math.sin(angle)*1.2)*CFrame.Angles(0,-angle,0); part.Parent=folder
    local weld=Instance.new("WeldConstraint"); weld.Part0=head; weld.Part1=part; weld.Parent=part
   end
  else local h=Instance.new("Highlight"); h.Name="SkyfallAura"; h.Adornee=char; h.FillTransparency=.9; h.OutlineTransparency=.15; h.FillColor=aura.Color; h.OutlineColor=aura.Color; h.DepthMode=Enum.HighlightDepthMode.Occluded; h.Parent=char end
 end
end
function Services.Shop(p,request,id)
 local d=profiles[p]; local item=typeof(id)=="string" and catalog[id]
 if not d then return false,"Your wallet is loading." end
 if request=="Unequip" and (id=="Trail" or id=="Aura") then d["Equipped"..id]="None"; Services.Sync(p); Services.ApplyCosmetics(p); return true,"Cosmetic removed." end
 if not item then return false,"Choose a shop item." end
 if request=="BuyItem" and not d.Owned[id] then
  if d.Coins<item.Price then return false,"You need "..(item.Price-d.Coins).." more coins." end
  d.Coins-=item.Price; d.Owned[id]=true
 end
 if not d.Owned[id] then return false,"You do not own this item yet." end
 d["Equipped"..item.Kind]=id; Services.Sync(p); Services.ApplyCosmetics(p)
 return true,item.Name.." equipped!"
end
local function storeFor(key)
 if not live then return nil end
 if not stores[key] then stores[key]=DataStoreService:GetOrderedDataStore(Config.RecordStorePrefix..key) end
 return stores[key]
end
local function remember(key,userId,name,ms)
 memory[key]=memory[key] or {}
 local previous=memory[key][tostring(userId)]
 if not previous or ms<previous.Milliseconds then memory[key][tostring(userId)]={UserId=userId,Username=name,Milliseconds=ms} end
end
function Services.Submit(p,key,run)
 local allowed,reason=Rules.CanRank(run)
 if not allowed then return false,reason end -- A second guard protects the persistence boundary.
 local ms=math.max(1,math.floor(run.elapsed*1000+.5))
 remember(key,p.UserId,p.DisplayName,ms)
 local d=profiles[p]
 if d and (not d.Best[key] or ms<d.Best[key]) then d.Best[key]=ms end
 if live then Services.PendingRecords+=1; task.spawn(function()
  for attempt=1,3 do
   local ok=pcall(function() storeFor(key):UpdateAsync(tostring(p.UserId),function(old) return typeof(old)=="number" and math.min(old,ms) or ms end) end)
   if ok then Services.PendingRecords-=1; return end; task.wait(attempt*2)
  end
  Services.PendingRecords-=1
 end) end
 return true,ms
end
function Services.RefreshBoard(key)
 if not live then return end
 local ok,pages=pcall(function() return storeFor(key):GetSortedAsync(true,10,1) end)
 if not ok then boards[key]={Rows={},Mode="GLOBAL UNAVAILABLE / SESSION RECORDS",At=os.clock()}; return end
 local rows={}
 for _,entry in ipairs(pages:GetCurrentPage()) do
  local id=tonumber(entry.key); local name=nameCache[entry.key] or "Player "..entry.key
  if not nameCache[entry.key] and id and id>0 then local success,n=pcall(function() return Players:GetNameFromUserIdAsync(id) end); if success then name=n; nameCache[entry.key]=n end end
  table.insert(rows,{UserId=id,Username=name,Milliseconds=entry.value})
 end
 boards[key]={Rows=rows,Mode="GLOBAL",At=os.clock()}
end
function Services.GetBoard(key)
 local cached=boards[key]; local mode=not live and "LOCAL PREVIEW / SESSION RECORDS" or cached and cached.Mode or "GLOBAL / LOADING"
 local byUser={}
 for _,row in ipairs(cached and cached.Rows or {}) do byUser[tostring(row.UserId)]=row end
 for id,row in pairs(memory[key] or {}) do if not byUser[id] or row.Milliseconds<byUser[id].Milliseconds then byUser[id]=row end end
 local rows={}; for _,row in pairs(byUser) do table.insert(rows,row) end
 table.sort(rows,function(a,b) if a.Milliseconds==b.Milliseconds then return tostring(a.UserId)<tostring(b.UserId) end; return a.Milliseconds<b.Milliseconds end)
 while #rows>10 do table.remove(rows) end
 return {Rows=rows,Mode=mode,Key=key}
end
function Services.UpdateWorldBoards()
 local levels=workspace.SkyfallSprint.Levels
 for i=1,4 do
  local container=levels["Level"..i].Decor:FindFirstChild("LeaderboardBoard",true)
  local board=container and container:FindFirstChild("LeaderboardSurface",true)
  local heading=board and board:FindFirstChild("Heading",true)
  local rows=board and board:FindFirstChild("Rows",true)
  -- An edited or temporarily streamed board must not stop record refreshes.
  if not heading or not heading:IsA("TextLabel") or not rows or not rows:IsA("TextLabel") then continue end
  local data=Services.GetBoard("Level"..i)
  heading.Text=(data.Mode=="GLOBAL" and "GLOBAL SPEEDRUN" or "LOCAL SPEEDRUN PREVIEW").." / "..i
  local lines={}
  for rank,row in ipairs(data.Rows) do table.insert(lines,string.format("%02d  %s    %s",rank,row.Username,Rules.FormatTime(row.Milliseconds/1000))) end
  rows.TextSize=20
  rows.Text=#lines>0 and table.concat(lines,"\n") or "No clean runs yet.\n\nFinish without a skip to set a record."
 end
end
function Services.Close()
 for p in pairs(profiles) do task.spawn(Services.Save,p,true) end
 local deadline=os.clock()+25
 while (next(profiles) or Services.PendingRecords>0) and os.clock()<deadline do task.wait(.1) end
end
return Services

