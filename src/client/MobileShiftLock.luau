local ShiftLock={}
function ShiftLock.Init(hud)
 local Players=game:GetService("Players");local UIS=game:GetService("UserInputService");local RunService=game:GetService("RunService");local GuiService=game:GetService("GuiService")
 local player=Players.LocalPlayer;local playerGui=player:WaitForChild("PlayerGui")
 local old=playerGui:FindFirstChild("SkyfallMobileCamera");if old then old:Destroy() end
 local gui=Instance.new("ScreenGui");gui.Name="SkyfallMobileCamera";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=90;gui.Parent=playerGui
 local b=Instance.new("TextButton");b.Name="ShiftLock";b.Size=UDim2.fromOffset(44,44);b.AnchorPoint=Vector2.new(.5,.5);b.BackgroundColor3=Color3.fromRGB(16,25,39)
 b.BackgroundTransparency=.1;b.BorderSizePixel=0;b.Text="";b.AutoButtonColor=true;b.Parent=gui
 local round=Instance.new("UICorner");round.CornerRadius=UDim.new(1,0);round.Parent=b
 local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(173,194,216);stroke.Transparency=.4;stroke.Parent=b
 local shackle=Instance.new("Frame");shackle.Size=UDim2.fromOffset(12,12);shackle.Position=UDim2.fromOffset(16,9);shackle.BackgroundTransparency=1;shackle.Parent=b
 local radius=Instance.new("UICorner");radius.CornerRadius=UDim.new(1,0);radius.Parent=shackle
 local shackleStroke=Instance.new("UIStroke");shackleStroke.Thickness=2;shackleStroke.Color=Color3.fromRGB(234,244,255);shackleStroke.Parent=shackle
 local body=Instance.new("Frame");body.Size=UDim2.fromOffset(18,14);body.Position=UDim2.fromOffset(13,18);body.BackgroundColor3=Color3.fromRGB(234,244,255);body.BorderSizePixel=0;body.Parent=b
 local bodyRadius=Instance.new("UICorner");bodyRadius.CornerRadius=UDim.new(0,3);bodyRadius.Parent=body
 local key=Instance.new("Frame");key.Size=UDim2.fromOffset(3,7);key.Position=UDim2.fromOffset(8,4);key.BackgroundColor3=b.BackgroundColor3;key.BorderSizePixel=0;key.Parent=body
 local aim=Instance.new("Frame");aim.Name="AimDot";aim.Size=UDim2.fromOffset(5,5);aim.AnchorPoint=Vector2.new(.5,.5);aim.Position=UDim2.fromScale(.5,.5);aim.BackgroundColor3=Color3.fromRGB(235,255,253);aim.BorderSizePixel=0;aim.Visible=false;aim.Parent=gui
 local aimRound=Instance.new("UICorner");aimRound.CornerRadius=UDim.new(1,0);aimRound.Parent=aim
 local aimStroke=Instance.new("UIStroke");aimStroke.Color=Color3.fromRGB(16,25,39);aimStroke.Parent=aim
 local hudToggle=playerGui:WaitForChild("SkyfallHUDToggle"):WaitForChild("ToggleHUD")
 local function place()
  local position,size=hudToggle.AbsolutePosition,hudToggle.AbsoluteSize
  b.Position=UDim2.fromOffset(position.X+size.X+8+22,position.Y+size.Y/2)
 end
 hudToggle:GetPropertyChangedSignal("AbsolutePosition"):Connect(place)
 hudToggle:GetPropertyChangedSignal("AbsoluteSize"):Connect(place)
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(place);place();task.defer(place)
 local wanted=false;local menuOpen=false;local controlled;local originalOffset;local originalRotate;local originalMouse
 local function release()
  if controlled and controlled.Parent then controlled.CameraOffset=originalOffset;controlled.AutoRotate=originalRotate end
  if originalMouse then UIS.MouseBehavior=originalMouse;originalMouse=nil end
  controlled=nil;aim.Visible=false
 end
 local function toggle()
  wanted=not wanted;b.BackgroundColor3=wanted and Color3.fromRGB(29,111,112) or Color3.fromRGB(16,25,39)
  stroke.Color=wanted and Color3.fromRGB(70,235,220) or Color3.fromRGB(173,194,216)
  if not wanted then release() end
 end
 b.Activated:Connect(toggle)
 UIS.InputBegan:Connect(function(input,processed)
  if not processed and not UIS:GetFocusedTextBox() and input.KeyCode==Enum.KeyCode.LeftShift then toggle() end
 end)
 GuiService.MenuOpened:Connect(function() menuOpen=true;release() end)
 GuiService.MenuClosed:Connect(function() menuOpen=false end)
 player.CharacterRemoving:Connect(release)
 RunService:BindToRenderStep("SkyfallMobileShiftLock",Enum.RenderPriority.Camera.Value+1,function()
  local state=player:GetAttribute("State");local playing=state=="Armed" or state=="Racing"
  local panel=hud:FindFirstChild("PanelOverlay");local blocked=menuOpen or panel and panel.Visible
  b.Visible=not menuOpen
  local char=player.Character;local h=char and char:FindFirstChildOfClass("Humanoid");local root=char and char:FindFirstChild("HumanoidRootPart");local camera=workspace.CurrentCamera
  if not wanted or not playing or blocked or not h or h.Health<=0 or not root or not camera or camera.CameraType~=Enum.CameraType.Custom or h.Sit then release();return end
  if controlled~=h then release();controlled=h;originalOffset=h.CameraOffset;originalRotate=h.AutoRotate end
  if not UIS.TouchEnabled then
   if not originalMouse then originalMouse=UIS.MouseBehavior end
   UIS.MouseBehavior=Enum.MouseBehavior.LockCenter
  end
  -- Keep Roblox's touch camera and gestures; only offset the view and face its yaw.
  h.CameraOffset=originalOffset+Vector3.new(1.65,.15,0);h.AutoRotate=false;aim.Visible=true
  local direction=Vector3.new(camera.CFrame.LookVector.X,0,camera.CFrame.LookVector.Z)
  if direction.Magnitude>.01 then root.CFrame=CFrame.lookAt(root.Position,root.Position+direction.Unit) end
 end)
 gui.Destroying:Connect(function() RunService:UnbindFromRenderStep("SkyfallMobileShiftLock");release() end)
end
return ShiftLock
