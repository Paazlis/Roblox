local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character, Humanoid, RootPart = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait(), nil, nil

local Enableds, Connections = {["Prestige"] = false, ["Upgrade"] = false, ["Loot"] = false, ["PowerRoll"] = false}, {}

local PowerRollFrame, PowerRollButton, PowerRollMaxLabel, PowerRollFill = PlayerGui:QueryDescendants("#Main > #Bottom")[1], nil, nil, nil

if PowerRollFrame then
	PowerRollButton = PowerRollFrame:FindFirstChild("PowerRoll")
	if PowerRollButton then
		PowerRollMaxLabel = PowerRollButton:FindFirstChild("IsMax")
		PowerRollFill = PowerRollButton:QueryDescendants("#Arc > #UIGradient")[1]
	end
end

local PrestigeFrame, PrestigeButton, PrestigeFill = PlayerGui:QueryDescendants("#Main > #Center > #Prestige")[1], nil, nil
local FillFullOffset = Vector2.new(0, 0)

if PrestigeFrame then
	PrestigeButton = PrestigeFrame:QueryDescendants("#Prestige")[1]
	PrestigeFill = PrestigeFrame:QueryDescendants("#LevelBar > #ProgressBar > #UIGradient")[1]
end

local UpgradeFrame, UpgradeScroll, UpgradeBackButton = PlayerGui:QueryDescendants("#Main > #Upgrades")[1], nil, nil

if UpgradeFrame then
	UpgradeScroll = UpgradeFrame:QueryDescendants("#Canvas > #Content")[1]
	UpgradeBackButton = UpgradeFrame:QueryDescendants("#Back")[1]
end

local LootFolder = workspace:FindFirstChild("Loot")

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
	if fill.Offset == FillFullOffset or fill.Offset.X >= 0 then
		return true
	end
	return false
end

local function HumanoidMoveTo(humanoid, targetPoint, savePoint)
	local rootPart = nil
	if humanoid.RootPart ~= nil and humanoid.RootPart.Parent ~= nil then
		rootPart = humanoid.RootPart
	else
		local model = humanoid.Parent
		if model and model.Parent and model:IsA("Model") then
			local primaryPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
			if primaryPart then
				rootPart = primaryPart
			end
		end
	end

	local distance = Vector3.zero
	if rootPart then
		distance = (rootPart.Position - targetPoint).Magnitude
	elseif savePoint then
		distance = (savePoint - targetPoint).Magnitude
	end

	local duration = distance / humanoid.WalkSpeed
	local targetReached = false

	local connection = nil
	connection = humanoid.MoveToFinished:Connect(function(reached)
		targetReached = reached
		if reached then
			if connection then
				connection:Disconnect()
				connection = nil
			end
			targetReached = true
		end
	end)

	humanoid:MoveTo(targetPoint)

	local timeoutThread = task.delay(math.max(0.5 , duration), function()
		targetReached = true
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end)

	task.spawn(function()
		while not targetReached do
			if not (humanoid and humanoid.Parent) then
				break
			end
			if humanoid.WalkToPoint ~= targetPoint then
				break
			end
			humanoid:MoveTo(targetPoint)
			task.wait(6)
		end

		if connection then
			connection:Disconnect()
			connection = nil
		end

		if timeoutThread and coroutine.status(timeoutThread) ~= "dead" then
			task.cancel(timeoutThread)
			timeoutThread = nil
		end
	end)

	while not targetReached do
		task.wait()
	end

	if connection then
		connection:Disconnect()
		connection = nil
	end

	if timeoutThread and coroutine.status(timeoutThread) ~= "dead" then
		task.cancel(timeoutThread)
		timeoutThread = nil
	end
end

local function HandlePowerRoll()
	Connections.PowerRoll = PowerRollMaxLabel:GetPropertyChangedSignal("Visible"):Connect(function()
		if not Enableds.PowerRoll then return end

		if PowerRollMaxLabel.Visible then
			FireButton(PowerRollButton)
		end
	end)

	if PowerRollMaxLabel.Visible and Enableds.PowerRoll then
		FireButton(PowerRollButton)
	end

	if Enableds.PowerRoll then
		task.spawn(function()	
			while Enableds.PowerRoll do
				if PowerRollMaxLabel.Visible then
					FireButton(PowerRollButton)
				end
				task.wait(1)
			end
		end)
	end
end

local function HandlePrestige()
	Connections.Prestige = PrestigeFill:GetPropertyChangedSignal("Offset"):Connect(function()
		if not Enableds.Prestige then return end

		if IsFillFull(PrestigeFill) then
			FireButton(PrestigeButton)
		end
	end)

	if Enableds.Prestige then
		task.spawn(function()	
			while Enableds.Prestige do
				if IsFillFull(PrestigeFill) then
					FireButton(PrestigeButton)
				end
				task.wait(1)
			end
		end)
	end
end

local function HandleUpgrade()
	task.spawn(function()
		while Enableds.Upgrade do
			for _, child in ipairs(UpgradeScroll:GetChildren()) do
				if not Enableds.Upgrade then break end

				if child:IsA("GuiObject") then
					local state = child:GetAttribute("UpgradeState")

					if state == "Affordable" then
						FireButton(child)
						task.wait(0.1)
					elseif state == "OpenTab" then
						FireButton(child)
						task.wait(0.2)

						for _, innerChild in ipairs(UpgradeScroll:GetChildren()) do
							if not Enableds.Upgrade then break end
							if innerChild:IsA("GuiObject") and innerChild:GetAttribute("UpgradeState") == "Affordable" then
								FireButton(innerChild)
								task.wait(0.1)
							end
						end

						if not Enableds.Upgrade then break end

						FireButton(UpgradeBackButton)
						task.wait(0.2)
					end
				end
			end

			if not Enableds.Upgrade then break end

			FireButton(UpgradeBackButton)
			task.wait(0.5)
		end
	end)
end

local function HandleLoot()
	task.spawn(function()
		local SavePoint = Character.PrimaryPart.Position * Vector3.new(1, 0, 1)

		while Enableds.Loot do
			for _, lootModel in ipairs(LootFolder:GetChildren()) do
				if not Enableds.Loot then break end

				if lootModel ~= nil and lootModel.Parent ~= nil and lootModel:IsA("Model") then
					local lootPart = lootModel.PrimaryPart or lootModel:FindFirstChildWhichIsA("BasePart")

					if not lootPart then
						for _, desc in ipairs(lootModel:GetDescendants()) do
							if desc:IsA("BillboardGui") and desc.Parent:IsA("BasePart") then
								lootPart = desc.Parent
								break
							end
						end
					end

					if not lootPart then continue end

					Humanoid = (Humanoid ~= nil and Humanoid.Parent ~= nil) and Humanoid or Character:FindFirstChildOfClass("Humanoid")
					RootPart = (RootPart ~= nil and RootPart.Parent ~= nil) and RootPart or (Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart"))

					if not Humanoid or not RootPart then continue end

					local targetPoint = lootPart.Position * Vector3.new(1, 0, 1)

					if lootPart ~= nil and lootPart.Parent ~= nil and Enableds.Loot then
						HumanoidMoveTo(Humanoid, targetPoint, SavePoint)

						task.wait(0.1)

						if not Enableds.Loot then break end

						HumanoidMoveTo(Humanoid, SavePoint, nil)

						task.wait(0.1)
					end
				end
			end

			task.wait(0.2)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "RNG Heroes",
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
	Text = "Auto Upgrade",
	Value = false,
	Callback = function(value)
		Enableds.Upgrade = value
		if value then
			HandleUpgrade()
		end
	end
})

Window:AddToggle({
	Text = "Collect Loot",
	Value = false,
	Callback = function(value)
		Enableds.Loot = value
		if value then
			HandleLoot()
		end
	end
})

Window:AddToggle({
	Text = "Auto Power Roll",
	Value = false,
	Callback = function(value) 
		Enableds.PowerRoll = value
		if Connections.PowerRoll then Connections.PowerRoll:Disconnect() Connections.PowerRoll = nil end
		if value then
			HandlePowerRoll()
		end
	end
})

Window:AddToggle({
	Text = "Auto Prestige",
	Value = false,
	Callback = function(value) 
		Enableds.Prestige = value
		if Connections.Prestige then Connections.Prestige:Disconnect() Connections.Prestige = nil end
		if value then
			HandlePrestige()
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
