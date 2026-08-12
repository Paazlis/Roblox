local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Packets, Enableds, Connections = {}, {Click = false, Upgrade = false, ChopTree = false, Rebirth = false}, {}
local LastTreeTime, TreeThreshold, MaxDistance = 0, 0.05, 15
local TreeCache = {}
local TreeAreasFolder = workspace:QueryDescendants("#Map > #Lobby > #TreeAreas")[1]
local UpgradeScroll = PlayerGui:QueryDescendants("#Main > #Upgrades > #Content > #ScrollingFrame")[1]
local RebirthFrame, RebirthFill, RebirthButton = nil, nil, nil

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

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
	
	if TreeAreasFolder then
		for _, area in ipairs(TreeAreasFolder:GetChildren()) do
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
end

-- Click Function --
local function HandleClick()
	if not Enableds.Click then return end
	
	task.spawn(function()
		Packets.Click = Packets.Click or ReplicatedStorage.Packages.Main.DataService.Networker._remotes.AxeService.RemoteEvent

		while Enableds.Click do
			Packets.Click:FireServer("requestChop")
			task.wait()
		end
	end)
end

-- Chop Tree Function --
local function HandleChopTree()
	if Connections.ChopTreeLooped then Connections.ChopTreeLooped:Disconnect() Connections.ChopTreeLooped = nil end
	if not Enableds.ChopTree then return end
	
	Packets.Tree = Packets.Tree or ReplicatedStorage.Packages.Main.DataService.Networker._remotes.TreeService.RemoteEvent
	LoadTrees()
	Connections.ChopTreeLooped = RunService.Heartbeat:Connect(function()
		if not Enableds.ChopTree then
			if Connections.ChopTreeLooped then
				Connections.ChopTreeLooped:Disconnect()
				Connections.ChopTreeLooped = nil
			end
			return 
		end

		if os.clock() - LastTreeTime < TreeThreshold  then return end

		if not (Character ~= nil and Character.Parent ~= nil) then return end

		local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		for name, part in pairs(TreeCache) do
			if part and part.Parent and rootPart and rootPart.Parent then
				local distance = (rootPart.Position - part.Position).Magnitude
				if distance <= MaxDistance then
					if os.clock() - LastTreeTime < TreeThreshold then break end

					Packets.Tree:FireServer("requestChop", name)

					LastTreeTime = os.clock()
					break
				end
			end
		end
	end)
end

-- Upgrade Function --
local function HandleUpgrade()
	if not Enableds.Upgrade then return end
	
	task.spawn(function()
		while Enableds.Upgrade do
			for _, upgradeFrame in pairs(UpgradeScroll:GetChildren()) do
				task.wait()

				if not Enableds.Upgrade then break end
				
				if not upgradeFrame:IsA("Frame") then continue end

				local upgradeButtons = upgradeFrame:FindFirstChild("Buttons")
				if not upgradeButtons then continue end

				local upgradeBuyButton = upgradeButtons:FindFirstChild("Buy")
				if not upgradeBuyButton then continue end

				
				FireButton(upgradeBuyButton)
			end

			task.wait(5)
		end
	end)
end

-- Rebirth Function --
local function HandleRebirth()
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end
	
	Packets.SendRebirth = Packets.SendRebirth or ReplicatedStorage.Packages.Main.DataService.Networker._remotes.LevelService.RemoteEvent

	RebirthFrame = RebirthFrame or PlayerGui:QueryDescendants("#Main > #Rebirth")[1]
	RebirthFill = RebirthFill or RebirthFrame:QueryDescendants("#LevelBar > #Move")[1]
	RebirthButton = RebirthButton or RebirthFrame:QueryDescendants("#Buttons > #Rebirth")[1]

	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
		if IsFillFull(RebirthFill) and Enableds.Rebirth then
			Packets.SendRebirth:FireServer("requestRebirth")
		end
	end)

	task.spawn(function()
		while Enableds.Rebirth do
			if IsFillFull(RebirthFill) then
				Packets.SendRebirth:FireServer("requestRebirth")
			end
			task.wait(0.5)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "+1 Wood Per Click",
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end

		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end
	end
})

Window:AddToggle({
	Text = "Fast Click",
	Value = false,
	Flag = "click_enabled",
	Callback = function(value)
		Enableds.Click = value
		HandleClick()
	end
})

Window:AddToggle({
	Text = "Fast Chop Tree",
	Value = false,
	Flag = "chop_tree_enabled",
	Callback = function(value)
		Enableds.ChopTree = value
		HandleChopTree()
	end
})

Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Flag = "upgrade_enabled",
	Callback = function(value)
		Enableds.Upgrade = value
		HandleUpgrade()
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		Enableds.Rebirth = value
		HandleRebirth()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 07-14-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
