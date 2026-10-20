local Controls={}
function Controls.Init(hud,closePanels,restart)
 local Players=game:GetService("Players");local UIS=game:GetService("UserInputService");local GuiService=game:GetService("GuiService")
 local playerGui=Players.LocalPlayer:WaitForChild("PlayerGui")
 local old=playerGui:FindFirstChild("SkyfallHUDToggle");if old then old:Destroy() end
 -- Separate from the game HUD so showing the UI is always possible.
 local gui=Instance.new("ScreenGui");gui.Name="SkyfallHUDToggle";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=100;gui.Parent=playerGui
 local b=Instance.new("TextButton");b.Name="ToggleHUD";b.Size=UDim2.fromOffset(106,36);b.BackgroundColor3=Color3.fromRGB(12,18,29);b.BackgroundTransparency=.08
 b.BorderSizePixel=0;b.Text="";b.AutoButtonColor=true;b.Parent=gui
 local rounding=Instance.new("UICorner");rounding.CornerRadius=UDim.new(1,0);rounding.Parent=b
 local icon=Instance.new("Frame");icon.Name="Icon";icon.Size=UDim2.fromOffset(16,16);icon.Position=UDim2.fromOffset(13,10);icon.Rotation=15;icon.BackgroundColor3=Color3.fromRGB(240,247,255);icon.BorderSizePixel=0;icon.Parent=b
 local hole=Instance.new("Frame");hole.Size=UDim2.fromOffset(6,6);hole.Position=UDim2.fromOffset(5,5);hole.BackgroundColor3=b.BackgroundColor3;hole.BorderSizePixel=0;hole.Parent=icon
 local text=Instance.new("TextLabel");text.Name="Label";text.BackgroundTransparency=1;text.Size=UDim2.new(1,-38,1,0);text.Position=UDim2.fromOffset(33,0)
 text.Font=Enum.Font.GothamBold;text.TextSize=11;text.TextColor3=Color3.fromRGB(240,247,255);text.Text="HIDE UI";text.Parent=b
 local function place()
  local inset=GuiService.TopbarInset;local available=inset.Max.X-inset.Min.X;local height=inset.Max.Y-inset.Min.Y
  if available>=174 and height>=44 then b.Position=UDim2.fromOffset(inset.Min.X+8,inset.Min.Y+(height-36)/2)
  else local topLeft=GuiService:GetGuiInset();b.Position=UDim2.fromOffset(12,topLeft.Y+8) end
 end
 GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(place);place()
 local hidden=false
 b.Activated:Connect(function()
  closePanels();hidden=not hidden;hud.Enabled=not hidden;text.Text=hidden and "SHOW UI" or "HIDE UI"
 end)
 GuiService.MenuOpened:Connect(function() b.Visible=false end)
 GuiService.MenuClosed:Connect(function() b.Visible=true;place() end)
 local lastReset=0
 UIS.InputBegan:Connect(function(input,processed)
  if processed or UIS:GetFocusedTextBox() or input.KeyCode~=Enum.KeyCode.R or os.clock()-lastReset<1 then return end
  if Players.LocalPlayer:GetAttribute("State")=="Loading" then return end
  lastReset=os.clock();closePanels();restart()
 end)
end
return Controls
