local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local ClickPacket, TreePacket, RebirthPacket = nil, nil, nil

local ClickEnabled, UpgradeEnabled = false, false
local RebirthConnection, TreeConnection = nil, nil
local LastTreeTime = 0
local TreeThreshold = 0.05
local MaxDistance = 15
local TreeCache = {}

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function IsFillFull(fill)
	if fill.Size.X.Scale >= 1 then
		return true
	end
	return false
end

local function LoadTrees()
	TreeCache = {}
	
	local TreeAreas = workspace.Map.Lobby.TreeAreas
	
	for _, area in ipairs(TreeAreas:GetChildren()) do
		if area.Name:find("Area") and area:IsA("Folder") then
			for _, tree in ipairs(area:GetChildren()) do
				if tree.Name:find("Tree") and tree:IsA("Folder") then
					local part = tree:FindFirstChildWhichIsA("BasePart")
					if part and not TreeCache[tree.Name] then
						TreeCache[tree.Name] = part
						break
					end
				end
			end
		end
	end
end

local Window = UI:CreateWindow({
	Name = "+1 Wood Per Click",
	Destroying = function()
		ClickEnabled, UpgradeEnabled = false, false
		if TreeConnection then TreeConnection:Disconnect() TreeConnection = nil end
		if RebirthConnection then RebirthConnection:Disconnect() RebirthConnection = nil end
	end
})

Window:AddToggle({
	Text = "Fast Click",
	Value = false,
	Flag = "click_enabled",
	Callback = function(value)
		ClickEnabled = value
		if value then
			task.spawn(function()
				if not ClickPacket then
					ClickPacket = ReplicatedStorage.Packages.Main.DataService.Networker._remotes.AxeService.RemoteEvent
				end
				
				while ClickEnabled do
					ClickPacket:FireServer("requestChop")
					task.wait()
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Fast Chop Tree",
	Value = false,
	Flag = "chop_tree_enabled",
	Callback = function(value)
		if TreeConnection then TreeConnection:Disconnect() TreeConnection = nil end
		if value  then
			if not TreePacket then
				TreePacket = ReplicatedStorage.Packages.Main.DataService.Networker._remotes.TreeService.RemoteEvent
			end
			
			LoadTrees()
			
			TreeConnection = RunService.Heartbeat:Connect(function()
				if os.clock() - LastTreeTime < TreeThreshold  then return end

				local character = LocalPlayer.Character
				if not (character ~= nil and character.Parent ~= nil) then return end

				local rootPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
				if not rootPart then return end

				for name, part in pairs(TreeCache) do
					if part and part.Parent then
						local distance = (rootPart.Position - part.Position).Magnitude
						if distance <= MaxDistance then
							if os.clock() - LastTreeTime < TreeThreshold then break end
							
							TreePacket:FireServer("requestChop", name)

							LastTreeTime = os.clock()
							break
						end
					end
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Flag = "upgrade_enabled",
	Callback = function(value)
		UpgradeEnabled = value
		if value  then
			task.spawn(function()
				local upgradeScroll = PlayerGui.Main.Upgrades.Content.ScrollingFrame
				
				while UpgradeEnabled do
					task.wait(5)
					for _, upgradeFrame in pairs(upgradeScroll:GetChildren()) do
						if not upgradeFrame:IsA("Frame") then continue end
						
						local upgradeButtons = upgradeFrame:FindFirstChild("Buttons")
						if not upgradeButtons then continue end
						
						local upgradeBuyButton = upgradeButtons:FindFirstChild("Buy")
						if not upgradeBuyButton then continue end
						
						task.wait()
						FireButton(upgradeBuyButton)
					end
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		if RebirthConnection then RebirthConnection:Disconnect() RebirthConnection = nil end
		if value then
			if not RebirthPacket then
				RebirthPacket = ReplicatedStorage.Packages.Main.DataService.Networker._remotes.LevelService.RemoteEvent
			end
			
			local rebirthFill = PlayerGui.Main.Rebirth.LevelBar.Move
			-- local rebirthButton = PlayerGui.Main.Rebirth.Buttons.Rebirth
			
			RebirthConnection = rebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
				if IsFillFull(rebirthFill) then
					RebirthPacket:FireServer("requestRebirth")
				end
			end)
			
			if IsFillFull(rebirthFill) then
				RebirthPacket:FireServer("requestRebirth")
			end
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
