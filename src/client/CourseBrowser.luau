local Browser={}
function Browser.Init(ui)
 local p,config=ui.Player,ui.Config
 local panel=ui.Panel("MapsPanel","CHOOSE YOUR MAP",720,660)
 local title=ui.Label(panel,"SelectedTitle","",UDim2.new(1,-44,0,26),UDim2.fromOffset(22,60),ui.White,19)
 local view=Instance.new("ViewportFrame");view.Name="ThemePreview";view.Size=UDim2.new(1,-44,.22,0);view.Position=UDim2.fromOffset(22,93)
 view.BackgroundColor3=Color3.fromRGB(15,26,43);view.BorderSizePixel=0;view.Ambient=Color3.fromRGB(180,190,210);view.LightColor=Color3.fromRGB(255,237,209);view.Parent=panel
 local caption=ui.Label(view,"Caption","THEME PREVIEW",UDim2.new(1,-16,0,20),UDim2.fromOffset(8,4),ui.White,10)
 local status=ui.Label(panel,"Access","",UDim2.new(1,-44,0,26),UDim2.new(0,22,.22,99),ui.Gold,12)
 local list=Instance.new("ScrollingFrame");list.Name="Courses";list.BackgroundTransparency=1;list.BorderSizePixel=0;list.ScrollBarThickness=4
 list.Position=UDim2.new(0,22,.22,132);list.Size=UDim2.new(1,-44,.78,-228);list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.Parent=panel
 local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,8);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=list
 local note=ui.Label(panel,"SwitchNote","Choosing a map ends your current run. Its timer waits at the blue start gate.",UDim2.new(1,-44,0,30),UDim2.new(0,22,1,-84),ui.Muted,10)
 local go=ui.Button(panel,"Travel","ENTER MAP",UDim2.new(1,-44,0,38),UDim2.new(0,22,1,-48),ui.Cyan)
 local selected=1;local rows={};local refresh
 local function preview(index)
  local old=view:FindFirstChildOfClass("WorldModel");if old then old:Destroy() end
  local world=Instance.new("WorldModel");world.Parent=view
  local spec=config.Levels[index]
  local function block(size,position,color,shape)
   local part=Instance.new("Part");part.Size=size;part.Position=position;part.Color=color;part.Material=Enum.Material.SmoothPlastic;part.Anchored=true
   if shape then part.Shape=shape end;part.Parent=world;return part
  end
  for i=0,8 do
   local x=i>0 and i<8 and math.sin(i*.85)*6 or 0
   block(Vector3.new((i==0 or i==8) and 12 or 8,1,8),Vector3.new(x,0,-i*8),spec.Color:Lerp(Color3.fromRGB(25,39,59),.5))
   if i%2==1 then local coin=block(Vector3.one*1.1,Vector3.new(x,2,-i*8),ui.Gold,Enum.PartType.Ball);coin.Material=Enum.Material.Neon end
  end
  for _,side in {-1,1} do
   if index==1 then
    block(Vector3.new(1,7,1),Vector3.new(side*17,0,-25),Color3.fromRGB(82,117,95));block(Vector3.one*8,Vector3.new(side*17,6,-25),spec.Color,Enum.PartType.Ball)
   elseif index==2 then
    for j=1,3 do block(Vector3.new(3,5+j*3,4),Vector3.new(side*17,(5+j*3)/2-3,-j*15),Color3.fromRGB(126,91,71)) end
   elseif index==3 then
    block(Vector3.new(2,19,2),Vector3.new(side*17,3,-27),spec.Color:Lerp(Color3.new(0,0,0),.6))
    block(Vector3.new(13,.5,.5),Vector3.new(side*17,10,-27),spec.Color)
   else
    block(Vector3.one*(side==1 and 12 or 6),Vector3.new(side*19,8,-30),spec.Color,Enum.PartType.Ball)
   end
  end
  local camera=view:FindFirstChildOfClass("Camera") or Instance.new("Camera");camera.FieldOfView=42;camera.CFrame=CFrame.lookAt(Vector3.new(42,43,30),Vector3.new(0,0,-28));camera.Parent=view;view.CurrentCamera=camera
  title.Text=string.format("%02d / %s",index,string.upper(spec.Title));title.TextColor3=spec.Color
 end
 for index,spec in ipairs(config.Levels) do
  local row=ui.Frame(list,"Map"..index,UDim2.new(1,-6,0,88),UDim2.new(),Color3.fromRGB(29,45,66));row.LayoutOrder=index
  local name=ui.Label(row,"Name",spec.Title.." / "..spec.Difficulty,UDim2.new(1,-112,0,28),UDim2.fromOffset(12,8),spec.Color,15);name.TextXAlignment=Enum.TextXAlignment.Left
  local detail=ui.Label(row,"Status","",UDim2.new(1,-112,0,34),UDim2.fromOffset(12,40),ui.Muted,11);detail.TextXAlignment=Enum.TextXAlignment.Left
  local b=ui.Button(row,"View","VIEW",UDim2.fromOffset(76,38),UDim2.new(1,-86,.5,-19),spec.Color)
  b.Activated:Connect(function() selected=index;preview(index);refresh() end);rows[index]={Detail=detail,Row=row}
 end
 refresh=function()
  local unlocked=p:GetAttribute("UnlockedLevel") or 1;local complete={};local best={}
  pcall(function() complete=game.HttpService:JSONDecode(p:GetAttribute("CompletedMaps") or "{}") end)
  pcall(function() best=game.HttpService:JSONDecode(p:GetAttribute("MapBestTimes") or "{}") end)
  for index,row in ipairs(rows) do
   local cleared=complete[tostring(index)]==true or index<unlocked
   local time=best["Level"..index]
   row.Detail.Text=(cleared and "COMPLETED / REPLAY AVAILABLE" or index<=unlocked and "UNLOCKED / READY TO RUN" or "LOCKED / FINISH THE PREVIOUS MAP")..(time and "\nBEST / "..ui.FormatTime(time/1000) or "")
   row.Row.BackgroundColor3=index==selected and Color3.fromRGB(41,66,87) or Color3.fromRGB(29,45,66)
  end
  local accessible=selected<=unlocked;local done=complete[tostring(selected)]==true or selected<unlocked
  go.Text=accessible and (done and "REPLAY " or "ENTER ")..string.upper(config.Levels[selected].Title) or "FINISH THE PREVIOUS MAP TO UNLOCK"
  go.Active=accessible;go.AutoButtonColor=accessible;go.BackgroundColor3=accessible and config.Levels[selected].Color or Color3.fromRGB(59,69,85)
  status.Text=config.Levels[selected].Difficulty.." / 8 SECTIONS / "..(accessible and "AVAILABLE" or "PREVIEW ONLY")
 end
 go.Activated:Connect(function()
  if selected>(p:GetAttribute("UnlockedLevel") or 1) then return end
  ui.Action:FireServer("SelectLevel",selected);ui.Close()
 end)
 for _,attr in {"UnlockedLevel","CompletedMaps","MapBestTimes","CurrentLevel"} do p:GetAttributeChangedSignal(attr):Connect(refresh) end
 return function() selected=p:GetAttribute("CurrentLevel") or 1;preview(selected);refresh();ui.Open("MapsPanel") end
end
return Browser
