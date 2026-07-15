local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer :: Player
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

local CollectCashPacket, TurretUpgradePacket, TurretPickupPacket, TurretPlacePacket, TurretSpinPacket, TurretBuyPacket = nil, nil, nil, nil, nil, nil
local Enableds, Connections = {}, {}
local UpgradeAccessColor, GridAccessColor = Color3.fromRGB(50, 214, 0), Color3.fromRGB(80, 220, 90)
local TurretData = nil
local SpinTypes, SpinOptions = {}, {}
local Character = LocalPlayer.Character

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

TurretData = TurretData or req(ReplicatedStorage.Databases.Turrets:Clone())

if TurretData then
	for key, value in pairs(TurretData) do
		if value then
			local rarity = value.Rarity
			if not rarity then continue end
			if table.find(SpinTypes, rarity) ~= nil then continue end
			table.insert(SpinTypes, rarity)
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

for _, key in ipairs({"Upgrade","Turret","TurretLuck","TurretRollSlots","ZombieLuck","ZombieCash","PlotLevel","CollectCash","Spin"}) do
	Enableds[key] = false
end

local Window = UI:CreateWindow({
	Name = "Zombie Turret Farm",
	Destroying = function()
		for _, key in ipairs({"Upgrade","Turret","TurretLuck","TurretRollSlots","ZombieLuck","ZombieCash","PlotLevel","CollectCash","Spin"}) do
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
	Text = "Spin Type",
	Options = SpinTypes,
	MultipleOptions = true,
	Flag = "spin_list",
	Callback = function(option)
		SpinOptions = option
	end
})

Window:AddToggle({
	Text = "Auto Spin",
	Value = false,
	Flag = "spin_enabled",
	Callback = function(value)
		Enableds.Spin = value
		if value then
			task.spawn(function()
				TurretSpinPacket = TurretSpinPacket or ReplicatedStorage.Events.Global.Core.TurretSpin
				Plot = Plot or GetPlot()
				PlotFile.Functional = Plot and Plot:FindFirstChild("Functional")
				PlotFile.Buttons = PlotFile.Functional and PlotFile.Functional:FindFirstChild("SpinButton")
				PlotFile.SpinPrompt = PlotFile.Buttons and PlotFile.Buttons.Button.TurretSpinButton
				TurretBuyPacket = TurretBuyPacket or ReplicatedStorage.Events.Global.Core.TurretBuyReward

                
				local spinData = nil
				local turretCache = {}

			    local applySpin = function()
					--[[
                   for _, child in ipairs(workspace:GetChildren()) do
						if not Enableds.Spin then break end
						if child and child.Parent then
							if child:FindFirstChildOfClass("Humanoid") then continue end
							
							local turretStats = TurretData[child.Name]
							if not turretStats then continue end
							
							local rank, rarity = child:GetAttribute("Rank"), child:GetAttribute("Rarity")
							if rank == nil or rarity == nil then continue end

							table.insert(turretCache, {Name = child.Name, Rank = rank, Rarity = rarity})
						end
					end
					]]
					if spinData then
						for rank, name in ipairs(spinData) do
                           if not Enableds.Spin or #SpinOptions <= 0 then break end

						   local turretStats = TurretData[name]
						   if not turretStats then continue end

						   local rarity = turretStats.Rarity
							
						   if not table.find(SpinOptions, rarity) then continue end
						   TurretBuyPacket:FireServer(rank)
						end
						spinData = nil
					end

					table.clear(turretCache)
				end
						
				while Enableds.Spin do
					task.wait(1)

					if spinData and Enableds.Spin then
                        applySpin()
					end
					
					if Enableds.Spin then
						FirePrompt(PlotFile.SpinPrompt)
					end

					spinData = TurretSpinPacket.OnClientEvent:Wait()
					task.wait(5)

					if #spinData > 0 and Enableds.Spin and #SpinOptions > 0 then
						applySpin()
					end
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Collect Cash",
	Value = false,
	Flag = "collect_cash_enabled",
	Callback = function(value)
		Enableds.CollectCash = value
		if value then
			task.spawn(function()
				CollectCashPacket = CollectCashPacket or ReplicatedStorage.Events.Global.Core.TurretCollect

				while Enableds.CollectCash do
					task.wait(1)
					CollectCashPacket:FireServer()
				end
			end)
		end
	end
})

Window:AddDropdown({
	Text = "Upgrade Type",
	Options = {"Turret","Turret Luck","Turret Roll Slots","Zombie Luck","Zombie Cash Boost","Plot Level"},
	Option = nil,
	MultipleOptions = true,
	Flag = "upgrade_list",
	Callback = function(option)
		Enableds.Turret = table.find(option, "Turret") ~= nil
		Enableds.TurretLuck = table.find(option, "Turret Luck") ~= nil
		Enableds.TurretRollSlots = table.find(option, "Turret Roll Slots") ~= nil
		Enableds.ZombieLuck = table.find(option, "Zombie Luck") ~= nil
		Enableds.ZombieCash = table.find(option, "Zombie Cash Boost") ~= nil
		Enableds.PlotLevel = table.find(option, "Plot Level") ~= nil
	end
})

Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Flag = "upgrade_enabled",
	Callback = function(value)
		Enableds.Upgrade = value
		if value then
			local plotScreens = PlayerGui:FindFirstChild("PlotScreens")
			if plotScreens then
				task.spawn(function()
					local turretScreen = plotScreens:FindFirstChild("TurretScreen")
					if not turretScreen then return end

					local turretScroll = turretScreen:FindFirstChild("Frame")
					if not turretScroll then return end

					while Enableds.Upgrade do
						task.wait(1)

						if Enableds.TurretLuck or Enableds.TurretRollSlots then
							for _, frame in ipairs(turretScroll:GetChildren()) do
								if frame and frame.Parent then
									local titleLabel = frame:FindFirstChild("Title")
									local buyButton = frame:FindFirstChild("Buy")
									if not (titleLabel and buyButton) then continue end

									if buyButton.BackgroundColor3 == UpgradeAccessColor  then
										local lowerText, access = titleLabel.Text:lower(), false
										if lowerText:find("turret luck") and Enableds.TurretLuck then
											access = true
										elseif lowerText:find("turret roll slots") and Enableds.TurretRollSlots then
											access = true
										end
										if access then
											task.wait()
											FireButton(buyButton)
										end
									end
								end
							end
						end
					end
				end)

				task.spawn(function()
					local plotScreen = plotScreens:FindFirstChild("PlotScreen")
					if not plotScreen then return end

					local plotScroll = plotScreen:FindFirstChild("Frame")
					if not plotScroll then return end

					while Enableds.Upgrade do
						task.wait(1)

						if Enableds.PlotLevel then
							for _, frame in ipairs(plotScroll:GetChildren()) do
								if frame and frame.Parent then
									local titleLabel = frame:FindFirstChild("Title")
									local buyButton = frame:FindFirstChild("Buy")
									if not (titleLabel and buyButton) then continue end

									if buyButton.BackgroundColor3 == UpgradeAccessColor and titleLabel.Text:lower():find("plot level") and Enableds.PlotLevel then
										task.wait()
										FireButton(buyButton)
									end
								end
							end
						end
					end
				end)

				task.spawn(function()
					local zombieScreen = plotScreens:FindFirstChild("ZombieScreen")
					if not zombieScreen then return end

					local zombieScroll = zombieScreen:FindFirstChild("Frame")
					if not zombieScroll then return end

					while Enableds.Upgrade do
						task.wait(1)

						if Enableds.ZombieLuck or Enableds.ZombieCash then
							for _, frame in ipairs(zombieScroll:GetChildren()) do
								if frame and frame.Parent then
									local titleLabel = frame:FindFirstChild("Title")
									local buyButton = frame:FindFirstChild("Buy")
									if not (titleLabel and buyButton) then continue end

									if buyButton.BackgroundColor3 == UpgradeAccessColor  then
										local lowerText, access = titleLabel.Text:lower(), false
										if lowerText:find("zombie luck") and Enableds.ZombieLuck then
											access = true
										elseif lowerText:find("zombie cash boost") or lowerText:find("zombie cash") and Enableds.ZombieCash then
											access = true
										end
										if access  then
											task.wait()
											FireButton(buyButton)
										end
									end
								end
							end
						end
					end
				end)
			end

			task.spawn(function()
				TurretUpgradePacket = TurretUpgradePacket or ReplicatedStorage.Events.Global.Core.TurretUpgrade
				Plot = Plot or GetPlot()
				PlotFile.Turrets = PlotFile.Turrets or Plot and Plot:FindFirstChild("Turrets")

				while Enableds.Upgrade do
					task.wait(1)
					if Enableds.Turret then
						local turretCache = {}

						for _, turret in ipairs(PlotFile.Turrets:GetChildren()) do
							if turret:IsA("Model") then
								local turretName = turret:GetAttribute("TurretName") or turret.Name
								local gridCell = turret:GetAttribute("GridCell")
								if not gridCell then continue end

								local turretStats = TurretData[turretName] or {}
								table.insert(turretCache, {GridCell = gridCell, Damage = turretStats.Damage or 0})
							end
						end

						table.sort(turretCache, function(a, b)
							return a.Damage > b.Damage
						end)

						for _, turret in ipairs(turretCache) do
							if Enableds.Turret and turret.GridCell then
								TurretUpgradePacket:FireServer(turret.GridCell)
							end
						end
					end
				end
			end)
		end
	end
})

local function RingAdded(ring)
	if ring and ring.Parent and ring:IsA("BasePart") and ring.Name:find("DroppedItemRing") and Connections.Ring then
		if Character and Character.Parent and Character.PrimaryPart then
			FireTouch(Character.PrimaryPart, ring)
		end
	end
end

Window:AddToggle({
	Text = "Collect Ring",
	Value = false,
	Flag = "collect_ring_enabled",
	Callback = function(value)
		if Connections.Ring then Connections.Ring:Disconnect() Connections.Ring = nil end
		if value then
			Connections.Ring = workspace.ChildAdded:Connect(RingAdded)
			
			for _, ring in ipairs(workspace:GetChildren()) do
				if not Connections.Ring then break end
				RingAdded(ring)
			end
		end
	end
})

Window:AddButton({
	Text = "Equip Best Turret",
	Callback = function()
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

		--[[
		Green Color = 80, 220, 90
		Red Color = 220, 70, 70
		Transparency = 1
		]]
	end
})

Window:AddLabel("YouTube: Crokyreo")
