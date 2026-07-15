local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local CollectCashPacket, TurretUpgradePacket = nil, nil
local Enableds = {}
local UpgradeAccessColor = Color3.new(50, 214, 0)

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

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

for _, key in ipairs({"Upgrade","Turret","TurretLuck","TurretRollSlots","ZombieLuck","ZombieCash","CollectCash"}) do
	Enableds[key] = false
end

local Window = UI:CreateWindow({
	Name = "Zombie Turret Farm",
	Destroying = function()
		for _, key in ipairs({"Upgrade","Turret","TurretLuck","TurretRollSlots","ZombieLuck","ZombieCash","CollectCash"}) do
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
	Options = {"Turret","Turret Luck","Turret Roll Slots","Zombie Luck","Zombie Cash Boost"},
	Option = nil,
	MultipleOptions = true,
	Flag = "upgrade_list",
	Callback = function(option)
		Enableds.Turret = table.find(option, "Turret") ~= nil
		Enableds.TurretLuck = table.find(option, "Turret Luck") ~= nil
		Enableds.TurretRollSlots = table.find(option, "Turret Roll Slots") ~= nil
		Enableds.ZombieLuck = table.find(option, "Zombie Luck") ~= nil
		Enableds.ZombieCash = table.find(option, "Zombie Cash Boost") ~= nil
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
			
			task.spawn(function()
				local turretScreen = plotScreens:FindFirstChild("TurretScreen")
				if not turretScreen then return end
				
				local turretScroll = turretScreen:FindFirstChild("Frame")
				if not turretScroll then return end
				
				while  Enableds.Upgrade do
					task.wait(1)

					if Enableds.TurretLuck or Enableds.TurretRollSlots then
						for _, frame in ipairs(turretScroll:GetChildren()) do
							if frame and frame.Parent then
								local buyButton = frame:FindFirstChild("Buy")
								if buyButton and buyButton.BackgroundColor3 == UpgradeAccessColor  then
									local lowerName, access = frame.Name:lower(), false
									if lowerName:find("turretluck") and Enableds.TurretLuck then
										access = true
									elseif lowerName:find("turrentslots") or lowerName:find("turretrollslots") and Enableds.TurretRollSlots then
										access = true
									end
									if access  then
										task.wait(1)
										FireButton(buyButton)
									end
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
								local buyButton = frame:FindFirstChild("Buy")
								if buyButton and buyButton.BackgroundColor3 == UpgradeAccessColor  then
									local lowerName, access = frame.Name:lower(), false
									if lowerName:find("zombieluck") and Enableds.ZombieLuck then
										access = true
									elseif lowerName:find("zombieyield") or frame.Name:find("zombiecash") and Enableds.ZombieCash then
										access = true   
									end
									if access then
										task.wait(1)
										FireButton(buyButton)
									end
								end
							end
						end
					end
				end
			end)

			task.spawn(function()
				if not TurretUpgradePacket then
					TurretUpgradePacket = ReplicatedStorage.Events.Global.Core.TurretUpgrade
				end

				local turrets = Plot:FindFirstChild("Turrets")
				if not turrets then return end

				while Enableds.Upgrade do
					task.wait(1)
					if Enableds.Turret then
						for _, turret in ipairs(turrets:GetChildren()) do
							if turret:IsA("Model") then
								local gridCell = turret:GetAttribute("GridCell")
								if gridCell ~= nil and Enableds.Turret then
									task.wait(1)
									TurretUpgradePacket:FireServer(gridCell)
								end
							end
						end
					end
				end
			end)
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
