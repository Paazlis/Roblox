local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections = {CompleteTycoon = false, Register = false, Upgrade = false, Rebirth = false}, {}

local UpgradeScroll = nil
local RebirthButton = nil

local PurchaseEnabled, UpgradeEnabled, RebirthEnabled, RegisterEnabled = false, false, false, false
local PurchaseUpgradeAddedConnection = nil
local PurchaseButtons = {}
local TransparencyConnections = {}

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function GetPlot()
	for _, plot in ipairs(workspace.Plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerId")
		if ownerId ~= nil and ownerId == LocalPlayer.UserId then
			return plot
		end
	end
	return nil
end

local function FireButton(object)
	if firesignal then
		firesignal(object.MouseButton1Click)
	end
end

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

local Plot = GetPlot()

local function PurchaseButtonAdded(model)
	local button = model:FindFirstChild("Purchase")
	if button then
		if button.Transparency == 0 then
			table.insert(PurchaseButtons, button)
		end
		local connection = button:GetPropertyChangedSignal("Transparency"):Connect(function()
			if button.Transparency == 0 then
				table.insert(PurchaseButtons, button)
			end
			if button.Transparency == 1 then
				local index = table.find(PurchaseButtons, button)
				if index then
					table.remove(PurchaseButtons, index)
				end
			end 
		end)
		table.insert(TransparencyConnections, connection)
	end
end

local function PurchaseUpgradeAdded(model)
	local purchaseFolder = model:FindFirstChild("Purchase")
	if purchaseFolder then
		for _, purchase in ipairs(purchaseFolder:GetChildren()) do
			PurchaseButtonAdded(purchase)
		end
	end
end

local function HandleRegister()
	if not Enableds.Register then return end
	task.spawn(function()
		while RegisterEnabled do
			task.wait(1)
			for _, model in ipairs(Plot.Upgrades:GetChildren()) do
				local Builds = model:FindFirstChild("Builds")
				if Builds then
					for i, v in ipairs(Builds:GetChildren()) do
						if string.find(v.Name, "IncomeSource") then
							task.wait()
							ReplicatedStorage.Remotes.ClaimMoney:FireServer(v)
						end
					end
				end
			end
		end
	end)
end

local function HandleCompleteTycoon()
	if not Enableds.CompleteTycoon  then return end
	if Connections.PurchaseUpgradeAdded then Connections.PurchaseUpgradeAdded:Disconnect() Connections.PurchaseUpgradeAdded = nil end
	if Enableds.CompleteTycoon then
		local Upgrades = Plot.Upgrades
		Connections.PurchaseUpgradeAdded = Upgrades.ChildAdded:Connect(PurchaseUpgradeAdded)
		for _, model in ipairs(Upgrades:GetChildren()) do
			PurchaseUpgradeAdded(model)
		end
		task.spawn(function()
			while Enableds.CompleteTycoon do
				if next(PurchaseButtons) then
					for _, button in ipairs(PurchaseButtons) do
						if not Enableds.CompleteTycoon then break end
						if not (button and button.Parent) then continue end
						local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
						if rootPart then
							FireTouch(rootPart, button)
						end
						task.wait(0.1)
					end
				end
				task.wait(1)
			end
		end)
	else
		table.clear(PurchaseButtons)
		for _, connection in ipairs(TransparencyConnections) do
			if connection then
				connection:Disconnect()
			end
		end
		table.clear(TransparencyConnections)
	end
end

local function HandleUpgrade()
	if not Enableds.Upgrade then return end
	task.spawn(function()
		UpgradeScroll = UpgradeScroll or PlayerGui:QueryDescendants("#Frames > #Upgrade > #Holder > #ScrollingFrame")[1]
		while Enableds.Upgrade do
			for _, layer in ipairs(UpgradeScroll:GetChildren()) do
				if not Enableds.Upgrade then break end
				local upgradeButton = layer:FindFirstChild("Upgrade")
				if upgradeButton then
					FireButton(upgradeButton)
				end
				task.wait(0.1)
			end
			task.wait(1)
		end
	end)
end

local function HandleRebirth()
	if not Enableds.Rebirth then return end
	task.spawn(function()
		RebirthButton = RebirthButton or PlayerGui:QueryDescendants("#Frames > #Rebirth > #Holder > #RebirthFrame > #Rebirth")[1]
		while Enableds.Rebirth do
			FireButton(RebirthButton)
			task.wait(5)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "My Parking Lot", 
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end
		for _, connection in ipairs(TransparencyConnections) do
			if connection then
				connection:Disconnect()
			end
		end
		table.clear(TransparencyConnections)
	end
})

Window:AddToggle({
	Text = "Auto Register",
	Value = false,
	Flag = "register_enabled",
	Callback = function(value)
		Enableds.Register = value
		if value then
		
		end
	end
})

Window:AddToggle({
	Text = "Complete Tycoon",
	Value = false,
	Flag = "complete_tycoon_enabled",
	Callback = function(value)
		Enableds.CompleteTycoon = value
		HandleCompleteTycoon()
	end
})

Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Callback = function(value)
		Enableds.Upgrade = value
		HandleUpgrade()
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
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
	Text = "Date: 07-04-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
