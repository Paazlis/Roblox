local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local CollectCashPacket, TurretUpgradePacket = nil, nil
local Enableds = {}
local UpgradeAccessColor = Color3.fromRGB(50, 214, 0)
local UpgradeFrames = {}

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

for _, key in ipairs({"Upgrade","Turret","TurretLuck","TurretRollSlots","ZombieLuck","ZombieCash","PlotLevel","CollectCash"}) do
	Enableds[key] = false
end

local Window = UI:CreateWindow({
	Name = "Zombie Turret Farm",
	Destroying = function()
		for _, key in ipairs({"Upgrade","Turret","TurretLuck","TurretRollSlots","ZombieLuck","ZombieCash","PlotLevel","CollectCash"}) do
			Enableds[key] = false
		end
		UpgradeFrames = {}
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
				for _, surfaceGui in ipairs(plotScreens:GetChildren()) do
					if surfaceGui and surfaceGui.Parent and surfaceGui.Name == "TurretScreen" or surfaceGui.Name == "PlotScreen" or surfaceGui.Name == "ZombieScreen" and not UpgradeFrames[surfaceGui.Name] then
						UpgradeFrames[surfaceGui.Name] = surfaceGui:FindFirstChild("Frame")
					end
				end
				
				task.spawn(function()
					while Enableds.Upgrade do
						task.wait()
						for key, frame in pairs(UpgradeFrames) do
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
									elseif lowerText:find("plot level") and Enableds.PlotLevel then
										access = true
									elseif lowerText:find("zombie luck") and Enableds.ZombieLuck then
										access = true
									elseif lowerText:find("zombie cash boost") or lowerText:find("zombie cash") and Enableds.ZombieCash then
										access = true
									end
									if access then
										task.wait()
										FireButton(buyButton)
									end
								end
							else
								UpgradeFrames[key] = nil
							end
						end
					end
				end)
			end

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
									task.wait()
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
