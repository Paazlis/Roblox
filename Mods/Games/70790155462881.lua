local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

local CollectCashPacket, TurretUpgradePacket, TurretPickupPacket, TurretPlacePacket = nil, nil, nil, nil
local Enableds = {}
local UpgradeAccessColor, GridAccessColor = Color3.fromRGB(50, 214, 0), Color3.fromRGB(80, 220, 90)

local TurretData = nil

local function req(module)
	local success, result = pcall(require,module)
	return (success == true and result ~= nil) == true and result or nil
end


local function GetPlot()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return end

	for _, plot in ipairs(plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId ~= nil and ownerId == LocalPlayer.UserId then
			return plot
		end
	end

	return nil
end

local Plot = GetPlot()
local TurretFolder = Plot and Plot:FindFirstChild("Turrets")
local GridFolder = nil

local function EquipBestTurret()
	Plot = (Plot ~= nil and Plot.Parent ~= nil) and Plot or GetPlot()
	if not Plot then return end

	TurretFolder = (TurretFolder ~= nil and TurretFolder.Parent ~= nil) and TurretFolder or Plot:FindFirstChild("Turrets")
	if not TurretFolder then return end

	if not TurretData then
		TurretData = req(ReplicatedStorage.Databases.Turrets:Clone())
	end
	
	if not TurretPickupPacket then
		TurretPickupPacket = ReplicatedStorage.Events.Global.Core.TurretPickup
	end

	if not TurretData then return end

	for _, turret in ipairs(TurretFolder:GetChildren()) do
		local gridCell = turret:GetAttribute("GridCell")
		if not gridCell then continue end

		TurretPickupPacket:FireServer(gridCell)
	end

	if not TurretPlacePacket then
		TurretPlacePacket = ReplicatedStorage.Events.Global.Core.TurretPlace
	end

	if not GridFolder then
		GridFolder = Plot:FindFirstChild("Functional"):FindFirstChild("Grid")
	end

	print("Pickup Turret Complete")

	local turretPlaces = {}

	for _, tool in ipairs(Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			local turretName =  tool:GetAttribute("TurretName") or tool.Name
			local turretLevel = tool:GetAttribute("TurretLevel")
			local turretCount = tool:GetAttribute("Count")

			if TurretData and TurretData.Items then
				local turretData = TurretData.Items[turretName]
				if turretData then
					table.insert(turretPlaces, {Count = turretCount or 1, Name = turretName, Damage = turretData.Damage or 1, Level = turretLevel or 1})
				end
			end
		end
	end

	print("Total Tool:".. tostring(#turretPlaces))

	table.sort(turretPlaces, function(a, b)
		if a.Damage == b.Damage then
			return a.Level > b.Level
		else
			return a.Damage > b.Damage
		end
	end)

	local grids = {}

	for _, gridModel in ipairs(GridFolder:GetChildren()) do
		for _, gridPart in ipairs(gridModel:GetChildren()) do
			if gridPart:IsA("BasePart") and gridPart.Name:lower():find("grid") and gridPart.Transparency == 1 then
				table.insert(grids, gridPart.Name)
			end
		end

	end

	print("Total Grid:".. tostring(#grids))

	for _, gridName in ipairs(grids) do
		if #turretPlaces > 0 then
			local turret = table.remove(turretPlaces, 1)
			TurretPlacePacket:FireServer(turret.Name, turret.Level, gridName)
		end
	end

	print("Equip Turret Complete")

	--[[
	Green Color = 80, 220, 90
	Red Color = 220, 70, 70
	Transparency = 1
	]]
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

for _, key in ipairs({"Upgrade","Turret","TurretLuck","TurretRollSlots","ZombieLuck","ZombieCash","PlotLevel","CollectCash"}) do
	Enableds[key] = false
end

local Window = UI:CreateWindow({
	Name = "Zombie Turret Farm",
	Destroying = function()
		for _, key in ipairs({"Upgrade","Turret","TurretLuck","TurretRollSlots","ZombieLuck","ZombieCash","PlotLevel","CollectCash"}) do
			Enableds[key] = false
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
				if not CollectCashPacket then
					CollectCashPacket = ReplicatedStorage.Events.Global.Core.TurretCollect
				end
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
				if not TurretUpgradePacket then
					TurretUpgradePacket = ReplicatedStorage.Events.Global.Core.TurretUpgrade
				end

				Plot = (Plot ~= nil and Plot.Parent ~= nil) and Plot or GetPlot()
				if not Plot then return end

				TurretFolder = (TurretFolder ~= nil and TurretFolder.Parent ~= nil) and TurretFolder or Plot:FindFirstChild("Turrets")
				if not TurretFolder then return end

				if not TurretData then
					TurretData = req(ReplicatedStorage.Databases.Turrets)
				end

				while Enableds.Upgrade do
					task.wait(1)
					if Enableds.Turret then
						local turretCache = {}

						for _, turret in ipairs(TurretFolder:GetChildren()) do
							if turret:IsA("Model") then
								local turretName = turret:GetAttribute("TurretName")
								local gridCell = turret:GetAttribute("GridCell")
								if not gridCell then continue end

								local newData = {GridCell = gridCell, Damage = 0}

								if TurretData and TurretData.Items then
									local turretData = TurretData.Items[turretName]
									if turretData then
										newData.Damage = turretData.Damage or 0
									end
								end

								table.insert(turretCache, newData)
							end
						end

						table.sort(turretCache, function(a, b)
							return a.Damage < b.Damage
						end)

						for _, turret in ipairs(turretCache) do
							if Enableds.Turret and turret.GridCell then
								task.wait()
								TurretUpgradePacket:FireServer(turret.GridCell)
							end
						end
					end
				end
			end)
		end
	end
})

Window:AddButton({
	Text = "Equip Best Turret",
	Callback = EquipBestTurret
})

Window:AddLabel("YouTube: Crokyreo")
