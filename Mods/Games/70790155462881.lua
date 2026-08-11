local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

local CollectCashPacket, TurretUpgradePacket, TurretPickupPacket, TurretPlacePacket, TurretSpinPacket, TurretBuyPacket = nil, nil, nil, nil, nil, nil
local Enableds, Connections, Packets = {}, {}, {}
local UpgradeAccessColor, GridAccessColor = Color3.fromRGB(50, 214, 0), Color3.fromRGB(80, 220, 90)
local TurretData = nil
local SpinTypes, SpinActives = {}, {AllEnabled = true}
local Character = LocalPlayer.Character

local UpgradeTypes = {"Turret","Turret Luck","Turret Roll Slots","Zombie Luck","Zombie Cash Boost","Plot Level"}

for _, key in ipairs({"Turret","TurretLuck","TurretRollSlots","ZombieLuck","ZombieCash","PlotLevel","Cash","Roll","Ring"}) do
	Enableds[key] = false
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function req(module)
	local success, result = pcall(require,module)
	return (success == true and result ~= nil) == true and result or nil
end

local function GetPlot()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end

	for _, plot in ipairs(plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId ~= nil and ownerId == LocalPlayer.UserId then
			return plot
		end
	end

	return nil
end

local Plot = GetPlot()

local PlotFile = {}
PlotFile.Turrets = Plot and Plot:FindFirstChild("Turrets")
PlotFile.Functional = Plot and Plot:FindFirstChild("Functional")
PlotFile.Grid = PlotFile.Functional and PlotFile.Functional:FindFirstChild("Grid")
PlotFile.SpinStands = PlotFile.Functional and PlotFile.Functional:FindFirstChild("SpinStands")
PlotFile.Buttons = PlotFile.Functional and PlotFile.Functional:FindFirstChild("SpinButton")
PlotFile.SpinPrompt = PlotFile.Buttons and PlotFile.Buttons.Button.TurretSpinButton

local RingConnection = nil

local TurretDataModule = ReplicatedStorage:QueryDescendants("#Databases > #Turrets")[1]
if TurretDataModule then
	TurretData = TurretData or req(TurretDataModule:Clone())
end

if TurretData then
	for key, value in pairs(TurretData) do
		if value then
			local rarity = value.Rarity
			if not rarity then continue end
			if SpinActives[rarity] == nil then
				SpinActives[rarity] = false
				table.insert(SpinTypes, rarity)
			end
		end
	end
end

local function FirePrompt(prompt)
	if fireproximityprompt then
		fireproximityprompt(prompt, 0)
	end
end

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function HandleRoll()
	if not Enableds.Roll then return end
	task.spawn(function()
		Packets.TurretSpin = Packets.TurretSpin or ReplicatedStorage:QueryDescendants("#Events > #Global > #Core > #TurretSpin")[1]
		Packets.TurretBuyReward = Packets.TurretBuyReward or ReplicatedStorage:QueryDescendants("#Events > #Global > #Core > #TurretBuyReward")[1]
		Plot = Plot or GetPlot()
		PlotFile.Functional = Plot and Plot:FindFirstChild("Functional")
		PlotFile.Buttons = PlotFile.Functional and PlotFile.Functional:FindFirstChild("SpinButton")
		PlotFile.SpinPrompt = PlotFile.Buttons and PlotFile.Buttons.Button.TurretSpinButton
		local spinData = nil
		local applySpin = function()
			if spinData and Enableds.Roll then
				for rank, name in ipairs(spinData) do
					if not Enableds.Roll then break end
					local turretStats = TurretData[name]
					if not turretStats then continue end
					local rarity = turretStats.Rarity
					if SpinActives.AllEnabled ~= true and SpinActives[rarity] then continue end
					Packets.TurretBuyReward:FireServer(rank)
				end
				spinData = nil
			end
		end
		while Enableds.Roll do
			task.wait(1)
			applySpin()
			if Enableds.Roll then
				FirePrompt(PlotFile.SpinPrompt)
			end
			spinData = Packets.TurretSpin.OnClientEvent:Wait()
			task.wait(5)
			applySpin()
		end
	end)
end

local function HandleCash()
	if not Enableds.Cash then return end
	task.spawn(function()
		Packets.TurretCollect = Packets.TurretCollect or ReplicatedStorage:QueryDescendants("#Events > #Global > #Core > #TurretCollect")[1]
		while Enableds.Cash do
			Packets.TurretCollect:FireServer()
			task.wait(1)
		end
	end)
end

local function RingAdded(ring)
	if ring and ring.Parent and ring:IsA("BasePart") and ring.Name:find("DroppedItemRing") then
		if Character and Character.Parent and Character.PrimaryPart then
			FireTouch(Character.PrimaryPart, ring)
		end
	end
end

local function HandleRing()
	if Connections.Ring then Connections.Ring:Disconnect() Connections.Ring = nil end
	if not Enableds.Ring then return end
	Connections.Ring = workspace.ChildAdded:Connect(RingAdded)
	for _, ring in ipairs(workspace:GetChildren()) do
		if not Enableds.Ring then break end
		RingAdded(ring)
	end
end

local function HandleUpgrade()
	if not Enableds.Upgrade then return end
	local plotScreens = PlayerGui:FindFirstChild("PlotScreens")	
	if plotScreens then
		task.spawn(function()
			local turretScreen = plotScreens:FindFirstChild("TurretScreen")
			if not turretScreen then return end
			local turretScroll = turretScreen:FindFirstChild("Frame")
			if not turretScroll then return end
			while Enableds.Upgrade do
				if Enableds.TurretLuck or Enableds.TurretRollSlots then
					for _, layer in ipairs(turretScroll:GetChildren()) do
						if not (Enableds.TurretLuck or Enableds.TurretRollSlots) then break end
						if not (layer and layer.Parent) then continue end
						local title = layer:FindFirstChild("Title")
						local buyButton = layer:FindFirstChild("Buy")
						if not (title and buyButton) then continue end
						if buyButton.BackgroundColor3 == UpgradeAccessColor  then
							local lowerText, access = title.Text:lower(), false
							if lowerText:find("turret luck") and Enableds.TurretLuck then
								access = true
							elseif lowerText:find("turret roll slots") and Enableds.TurretRollSlots then
								access = true
							end
							if access then
								FireButton(buyButton)
							end
						end
						task.wait(0.1)
					end
				end
				task.wait(1)
			end
		end)
		task.spawn(function()
			local plotScreen = plotScreens:FindFirstChild("PlotScreen")
			if not plotScreen then return end
			local plotScroll = plotScreen:FindFirstChild("Frame")
			if not plotScroll then return end
			while Enableds.Upgrade do
				if Enableds.PlotLevel then
					for _, layer in ipairs(plotScroll:GetChildren()) do
						if not Enableds.PlotLevel then break end
						if not (layer and layer.Parent) then continue end
						local title = layer:FindFirstChild("Title")
						local buyButton = layer:FindFirstChild("Buy")
						if not (title and buyButton) then continue end
						if buyButton.BackgroundColor3 == UpgradeAccessColor and title.Text:lower():find("plot level") and Enableds.PlotLevel then
							FireButton(buyButton)
						end
						task.wait(0.1)
					end
				end
				task.wait(1)
			end
		end)
		task.spawn(function()
			local zombieScreen = plotScreens:FindFirstChild("ZombieScreen")
			if not zombieScreen then return end
			local zombieScroll = zombieScreen:FindFirstChild("Frame")
			if not zombieScroll then return end
			while Enableds.Upgrade do
				if Enableds.ZombieLuck or Enableds.ZombieCash then
					for _, layer in ipairs(zombieScroll:GetChildren()) do
						if not (Enableds.ZombieLuck or Enableds.ZombieCash) then break end
						if not (layer and layer.Parent) then continue end
						local title = layer:FindFirstChild("Title")
						local buyButton = layer:FindFirstChild("Buy")
						if not (title and buyButton) then continue end
						if buyButton.BackgroundColor3 == UpgradeAccessColor  then
							local lowerText, access = title.Text:lower(), false
							if lowerText:find("zombie luck") and Enableds.ZombieLuck then
								access = true
							elseif lowerText:find("zombie cash boost") or lowerText:find("zombie cash") and Enableds.ZombieCash then
								access = true
							end
							if access  then
								FireButton(buyButton)
							end
						end
						task.wait(0.1)
					end
				end
				task.wait(1)
			end
		end)
	end
	task.spawn(function()
		Packets.TurretUpgrade = Packets.TurretUpgrade or ReplicatedStorage:QueryDescendants("#Events > #Global > #Core > #TurretUpgrade")[1]
		Plot = Plot or GetPlot()
		PlotFile.Turrets = PlotFile.Turrets or Plot and Plot:FindFirstChild("Turrets")
		while Enableds.Upgrade do
			if Enableds.Turret then
				local sortTurrets = {}
				for _, turret in ipairs(PlotFile.Turrets:GetChildren()) do
					if not Enableds.Turret then break end
					if not (turret and turret.Parent and turret:IsA("Model")) then continue end
					local turretName, gridCell = turret:GetAttribute("TurretName") or turret.Name, turret:GetAttribute("GridCell")
					if not gridCell then continue end
					local turretStats = TurretData[turretName] or {}
					table.insert(sortTurrets, {GridCell = gridCell, Damage = turretStats.Damage or 0})
					task.wait(0.1)
				end
				table.sort(sortTurrets, function(a, b)
					return a.Damage > b.Damage
				end)
				for _, info in ipairs(sortTurrets) do
					if not Enableds.Turret then break end
					if info.GridCell then
						Packets.TurretUpgrade:FireServer(info.GridCell)
					end
					task.wait(0.1)
				end
			end
			task.wait(1)
		end
	end)
end

local function HandleEquipBestTurret()
	TurretPickupPacket = TurretPickupPacket or ReplicatedStorage.Events.Global.Core.TurretPickup
	Plot = Plot or GetPlot()
	PlotFile.Turrets = PlotFile.Turrets or Plot and Plot:FindFirstChild("Turrets")

	for _, turret in ipairs(PlotFile.Turrets:GetChildren()) do
		local gridCell = turret:GetAttribute("GridCell")
		if not gridCell then continue end
		TurretPickupPacket:FireServer(gridCell)
	end

	task.wait(1)

	local turretPlaces = {}

	for _, turret in ipairs(Backpack:GetChildren()) do
		if turret and turret.Parent and turret:IsA("Tool") then
			local level = turret:GetAttribute("TurretLevel")
			if not level then continue end
			local name = turret:GetAttribute("TurretName") or turret.Name
			local turretStats = TurretData[name] or {}
			table.insert(turretPlaces, {Count = turret:GetAttribute("Count") or 1, Name = name, Damage = turretStats.Damage or 1, Level = level})
		end
	end

	table.sort(turretPlaces, function(a, b)
		if a.Damage == b.Damage then
			return a.Level > b.Level
		else
			return a.Damage > b.Damage
		end
	end)

	TurretPlacePacket = TurretPlacePacket or ReplicatedStorage.Events.Global.Core.TurretPlace
	PlotFile.Functional = PlotFile.Functional or Plot and Plot:FindFirstChild("Functional")
	PlotFile.Grid = PlotFile.Functional and PlotFile.Functional:FindFirstChild("Grid")

	local grids = {}

	for _, gridModel in ipairs(PlotFile.Grid:GetChildren()) do
		for _, gridPart in ipairs(gridModel:GetChildren()) do
			if gridPart:IsA("BasePart") and gridPart.Name:lower():find("grid") and gridPart.Transparency == 1 then
				table.insert(grids, gridPart.Name)
			end
		end
	end

	for _, gridName in ipairs(grids) do
		if #turretPlaces > 0 then
			local turret = table.remove(turretPlaces, 1)
			TurretPlacePacket:FireServer(turret.Name, turret.Level, gridName)
		end
	end

	table.clear(turretPlaces)
	table.clear(grids)
end

local Window = UI:CreateWindow({
	Name = "Zombie Turret Farm",
	Destroying = function()
		for _, key in ipairs({"Upgrade","Turret","TurretLuck","TurretRollSlots","ZombieLuck","ZombieCash","PlotLevel","CollectCash","Roll"}) do
			Enableds[key] = false
		end
		local key, connection = next(Connections)
		while connection do
			Connections[key] = nil
			connection:Disconnect()
			key, connection = next(Connections)
		end

	end
})

Window:AddDropdown({
	Text = "Roll Type (Empty = All)",
	Options = SpinTypes,
	MultipleOptions = true,
	Flag = "roll_options",
	Callback = function(option)
		for _, mode in ipairs(SpinTypes) do
			SpinActives[mode] = table.find(option, mode) ~= nil
		end
		SpinActives["AllEnabled"] = #option <= 0
	end
})

Window:AddToggle({
	Text = "Auto Roll",
	Value = false,
	Flag = "roll_enabled",
	Callback = function(value)
		Enableds.Roll = value
		HandleRoll()
	end
})

Window:AddToggle({
	Text = "Collect Cash",
	Value = false,
	Flag = "cash_enabled",
	Callback = function(value)
		Enableds.Cash = value
		HandleCash()
	end
})

Window:AddDropdown({
	Text = "Upgrade Type",
	Options = UpgradeTypes,
	Option = nil,
	MultipleOptions = true,
	Flag = "upgrade_options",
	Callback = function(option)
		for _, mode in ipairs(UpgradeTypes) do
			Enableds[mode] = table.find(option, "Turret") ~= nil
		end
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
	Text = "Collect Ring",
	Value = false,
	Flag = "ring_enabled",
	Callback = function(value)
		Enableds.Ring = value
		HandleRing()
	end
})

Window:AddButton({
	Text = "Equip Best Turret",
	MethodType = "DebounceClick",
	Callback = HandleEquipBestTurret()
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 07-15-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
