local ShiftLock={}
function ShiftLock.Init(hud)
 local Players=game:GetService("Players");local UIS=game:GetService("UserInputService");local RunService=game:GetService("RunService");local GuiService=game:GetService("GuiService")
 if not UIS.TouchEnabled then return end
 local player=Players.LocalPlayer;local playerGui=player:WaitForChild("PlayerGui")
 local old=playerGui:FindFirstChild("SkyfallMobileCamera");if old then old:Destroy() end
 local gui=Instance.new("ScreenGui");gui.Name="SkyfallMobileCamera";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=90;gui.Parent=playerGui
 local b=Instance.new("TextButton");b.Name="ShiftLock";b.Size=UDim2.fromOffset(56,56);b.AnchorPoint=Vector2.new(.5,.5);b.BackgroundColor3=Color3.fromRGB(16,25,39)
 b.BackgroundTransparency=.1;b.BorderSizePixel=0;b.Text="";b.AutoButtonColor=true;b.Parent=gui
 local round=Instance.new("UICorner");round.CornerRadius=UDim.new(1,0);round.Parent=b
 local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(173,194,216);stroke.Transparency=.4;stroke.Parent=b
 local shackle=Instance.new("Frame");shackle.Size=UDim2.fromOffset(14,13);shackle.Position=UDim2.fromOffset(21,8);shackle.BackgroundTransparency=1;shackle.Parent=b
 local radius=Instance.new("UICorner");radius.CornerRadius=UDim.new(1,0);radius.Parent=shackle
 local shackleStroke=Instance.new("UIStroke");shackleStroke.Thickness=2;shackleStroke.Color=Color3.fromRGB(234,244,255);shackleStroke.Parent=shackle
 local body=Instance.new("Frame");body.Size=UDim2.fromOffset(20,15);body.Position=UDim2.fromOffset(18,17);body.BackgroundColor3=Color3.fromRGB(234,244,255);body.BorderSizePixel=0;body.Parent=b
 local bodyRadius=Instance.new("UICorner");bodyRadius.CornerRadius=UDim.new(0,3);bodyRadius.Parent=body
 local key=Instance.new("Frame");key.Size=UDim2.fromOffset(3,7);key.Position=UDim2.fromOffset(9,4);key.BackgroundColor3=b.BackgroundColor3;key.BorderSizePixel=0;key.Parent=body
 local text=Instance.new("TextLabel");text.Name="Status";text.Size=UDim2.new(1,0,0,16);text.Position=UDim2.fromOffset(0,35);text.BackgroundTransparency=1;text.TextColor3=Color3.fromRGB(234,244,255);text.Font=Enum.Font.GothamBold;text.TextSize=10;text.Text="OFF";text.Parent=b
 local aim=Instance.new("Frame");aim.Name="AimDot";aim.Size=UDim2.fromOffset(5,5);aim.AnchorPoint=Vector2.new(.5,.5);aim.Position=UDim2.fromScale(.5,.5);aim.BackgroundColor3=Color3.fromRGB(235,255,253);aim.BorderSizePixel=0;aim.Visible=false;aim.Parent=gui
 local aimRound=Instance.new("UICorner");aimRound.CornerRadius=UDim.new(1,0);aimRound.Parent=aim
 local aimStroke=Instance.new("UIStroke");aimStroke.Color=Color3.fromRGB(16,25,39);aimStroke.Parent=aim
 local function place()
  local _,bottom=GuiService:GetGuiInset()
  b.Position=UDim2.new(1,-70-bottom.X,1,-190-bottom.Y)
 end
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(place);place()
 local wanted=false;local menuOpen=false;local controlled;local originalOffset;local originalRotate
 local function release()
  if controlled and controlled.Parent then controlled.CameraOffset=originalOffset;controlled.AutoRotate=originalRotate end
  controlled=nil;aim.Visible=false
 end
 b.Activated:Connect(function()
  wanted=not wanted;text.Text=wanted and "ON" or "OFF";b.BackgroundColor3=wanted and Color3.fromRGB(29,111,112) or Color3.fromRGB(16,25,39)
  stroke.Color=wanted and Color3.fromRGB(70,235,220) or Color3.fromRGB(173,194,216)
  if not wanted then release() end
 end)
 GuiService.MenuOpened:Connect(function() menuOpen=true;release() end)
 GuiService.MenuClosed:Connect(function() menuOpen=false end)
 player.CharacterRemoving:Connect(release)
 RunService:BindToRenderStep("SkyfallMobileShiftLock",Enum.RenderPriority.Camera.Value+1,function()
  local state=player:GetAttribute("State");local playing=state=="Armed" or state=="Racing"
  local panel=hud:FindFirstChild("PanelOverlay");local blocked=menuOpen or panel and panel.Visible
  b.Visible=playing and not blocked
  local char=player.Character;local h=char and char:FindFirstChildOfClass("Humanoid");local root=char and char:FindFirstChild("HumanoidRootPart");local camera=workspace.CurrentCamera
  if not wanted or not playing or blocked or not h or h.Health<=0 or not root or not camera or camera.CameraType~=Enum.CameraType.Custom or h.Sit then release();return end
  if controlled~=h then release();controlled=h;originalOffset=h.CameraOffset;originalRotate=h.AutoRotate end
  -- Keep Roblox's touch camera and gestures; only offset the view and face its yaw.
  h.CameraOffset=originalOffset+Vector3.new(1.65,.15,0);h.AutoRotate=false;aim.Visible=true
  local direction=Vector3.new(camera.CFrame.LookVector.X,0,camera.CFrame.LookVector.Z)
  if direction.Magnitude>.01 then root.CFrame=CFrame.lookAt(root.Position,root.Position+direction.Unit) end
 end)
 gui.Destroying:Connect(function() RunService:UnbindFromRenderStep("SkyfallMobileShiftLock");release() end)
end
return ShiftLock
