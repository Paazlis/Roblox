local UI=loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer

local Bases=workspace:FindFirstChild("Bases")

local CollectNuke=false

local Window=UI:CreateWindow({Name="Merge a Nuke",Destroying=function()
	 CollectNuke=false
end})

Window:AddToggle({Name="Collect Nuke",Callback=function(value)
	CollectNuke=value
end})

local function getMyBase()
	local allBases=Bases:GetChildren()
	for _, base in ipairs(allBases) do
		local ownerId=base:GetAttribute("OwnerUserId")
		if ownerId==LocalPlayer.UserId then
			return base
		end
	end
	return nil
end

local function getNukes(base)
	local nukes={}
	local nukeFolder=base:FindFirstChild("Nukes")
	
	if nukeFolder then
		for _,nuke in ipairs(nukeFolder:GetChildren()) do
			local tier=tonumber(nuke:GetAttribute("Tier"))
			if tier~=nil then
				local pickNuke=workspace.CurrentCamera:FindFirstChild("HeldNukeVisual")
				if pickNuke then
					local pickTier=tonumber(pickNuke:GetAttribute("Tier"))
					if pickTier~=nil and tier~=pickTier then
						continue
					end
				end
				table.insert(nukes,nuke)
			end
		end

		table.sort(nukes,function(a, b)
			return tonumber(a:GetAttribute("Tier"))<tonumber(b:GetAttribute("Tier"))
		end)
	end
	
	return nukes
end

local LocalCamera=workspace.CurrentCamera
local PickNuke=nil
local LocalCameraAdded,LocalCameraRemoved=nil,nil

local function dropNuke()
	if PickNuke then
	   firesignal(LocalPlayer.PlayerGui.ScreenGui.HoldingFrame.Frame.Drop.TextButton.Activated)
	end
end

local setupNuke=function()
	LocalCamera=workspace.CurrentCamera
	
	if LocalCameraAdded then LocalCameraAdded:Disconnect() end
	LocalCameraAdded=LocalCamera.ChildAdded:Connect(function(child)
		if child.Name=="HeldNukeVisual" then
			local pickTier=tonumber(child:GetAttribute("Tier"))
			if pickTier~=nil then
				PickNuke=child
			end
		end
	end)
	if LocalCameraRemoved then LocalCameraRemoved:Disconnect() end
	LocalCameraRemoved=LocalCamera.ChildRemoved:Connect(function(child)
		if PickNuke==child then PickNuke=nil end
	end)
end

setupNuke()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(setupNuke)

task.spawn(function()
	while true do
		task.wait(0.5)
		if not CollectNuke then continue end

		local base=getMyBase()
		if not base then continue end
		
		local nukes=getNukes(base)
		if #nukes<=0 then continue end
		
		local character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local humanoid=character and character:FindFirstChildOfClass("Humanoid")
		local hrp=character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
		
		if not humanoid or not hrp then continue end

		local selectNuke=nil
		
		for _,nuke in ipairs(nukes) do
			if not CollectNuke then break end
			if not (nuke and nuke.Parent) then continue end

			local tier=tonumber(nuke:GetAttribute("Tier"))
			
			if PickNuke and PickNuke.Parent and tier~=nil then
				local PickTier=tonumber(PickNuke:GetAttribute("Tier"))
				if PickTier~=nil and tier~=PickTier then
					continue
				end
			end

			local targetPosition=nil
				
			if nuke:IsA("BasePart") then
				targetPosition=nuke.Position
			elseif nuke:IsA("Model") and nuke.PrimaryPart then
				targetPosition=nuke.PrimaryPart.Position
			end

			if targetPosition and nuke.Parent then
				humanoid:MoveTo(targetPosition)
				
				selectNuke=nuke
				
				while (hrp.Position-targetPosition).Magnitude>4 and nuke.Parent and CollectNuke do
					task.wait(0.1)
					
					if PickNuke and PickNuke.Parent and tier~=nil then
						local PickTier=tonumber(PickNuke:GetAttribute("Tier"))
						if PickTier~=nil and tier~=PickTier then
							break
						end
					end
					
					humanoid:MoveTo(targetPosition)
				end
			end
		end
		if not selectNuke then dropNuke() end
	end
end)
