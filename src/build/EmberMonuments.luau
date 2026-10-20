-- Lightweight, connected ruin silhouettes. No particles, lights or animations.
local Monuments={}
local stone=Color3.fromRGB(97,70,66)
local trim=Color3.fromRGB(172,121,74)
local dark=Color3.fromRGB(62,48,62)
local ember=Color3.fromRGB(255,144,60)
local function piece(parent,name,size,cf,color,material,class)
 local p=Instance.new(class or "Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.Slate
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
function Monuments.Build(parent,cf)
 local model=Instance.new("Model");model.Name="EmberMonument";model:SetAttribute("MonumentVersion",1)
 local function p(name,size,offset,color,material,class)
  return piece(model,name,size,cf*offset,color,material,class)
 end
 p("Foundation",Vector3.new(236,26,112),CFrame.new(0,-13,0),dark)
 p("StoneTerrace",Vector3.new(244,6,120),CFrame.new(0,3,0),stone)
 -- Two fitted slopes give the floating foundation a tapered underside.
 for _,side in {-1,1} do
  p("TaperedStone",Vector3.new(112,52,118),CFrame.new(side*59,-52,0)*CFrame.Angles(0,side*math.pi/2,0),dark,nil,"WedgePart")
  p("ColumnFoot",Vector3.new(30,12,30),CFrame.new(side*88,12,0),trim)
  p("Pillar",Vector3.new(19,176,19),CFrame.new(side*88,106,0),stone)
  p("Capital",Vector3.new(29,14,29),CFrame.new(side*88,201,0),trim)
  -- Flush inlays on the front face; each end stops inside the stone.
  p("PillarInlay",Vector3.new(1.25,140,.2),CFrame.new(side*88,106,-9.61),ember,Enum.Material.Neon)
 end
 p("Lintel",Vector3.new(218,24,30),CFrame.new(0,220,0),trim)
 p("CrownInlay",Vector3.new(186,1.4,.2),CFrame.new(0,220,-15.11),ember,Enum.Material.Neon)
 for x=-72,72,72 do p("FoundationInlay",Vector3.new(38,1.5,.2),CFrame.new(x,-10,-56.11),ember,Enum.Material.Neon) end
 p("BrazierFoot",Vector3.new(25,5,25),CFrame.new(0,8.5,-12),trim)
 local bowl=p("BrazierBowl",Vector3.new(5,23,23),CFrame.new(0,13.5,-12)*CFrame.Angles(0,0,math.pi/2),dark,Enum.Material.Metal);bowl.Shape=Enum.PartType.Cylinder
 local core=p("EmberHeart",Vector3.new(17,6,17),CFrame.new(0,17.5,-12),ember,Enum.Material.Neon);core.Shape=Enum.PartType.Ball
 model.WorldPivot=cf;model.Parent=parent
 return model
end
function Monuments.Apply(map)
 local scenery=map.CourseSky.SurroundingWorld
 local anchors={}
 for _,obj in scenery:GetChildren() do if obj.Name=="AncientArch" and obj:IsA("BasePart") then table.insert(anchors,obj.Position) end end
 if #anchors==0 then return "Existing monuments retained." end
 -- Only replace the old foundry props. Keep the user's chosen monument locations.
 local replace={ObsidianButte=true,EmberFissure=true,AncientPillar=true,AncientArch=true}
 for _,obj in scenery:GetChildren() do if replace[obj.Name] then obj:Destroy() end end
 for _,anchor in anchors do
  local origin=anchor-Vector3.new(0,220,0)
  Monuments.Build(scenery,CFrame.lookAt(origin,Vector3.new(map.StartPosition.Position.X,origin.Y,origin.Z)))
  task.wait()
 end
 return "Rebuilt "..#anchors.." fitted ember monuments."
end
return Monuments
