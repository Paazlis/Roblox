local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Utility/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local LaunchEnabled, BuyEnabled, CashEnabled, TrainEnabled, RebirthEnabled = false, false, false, false, false

local function GetPlot()
	local plots = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Plots")
	if not plots then return nil end

	for _, base in pairs(plots:GetChildren()) do
		local currentPlotIndex = tonumber(string.match(base.Name, "%d+"))
		if currentPlotIndex then
			local plotIndex = LocalPlayer:GetAttribute("PlotIndex")
			if plotIndex and currentPlotIndex == plotIndex then
				return base
			end
		end
	end

	return nil
end

local Plot = GetPlot()

-- Train Function --
local function AutoTrain()
	if TrainEnabled then
		task.spawn(function()
			while TrainEnabled do
				task.wait(1)
				ReplicatedStorage.SharedModules.Network.RequestStrength:InvokeServer()
			end
		end)
	end
	
	if TrainEnabled then
		task.spawn(function()
			while TrainEnabled do
				task.wait(1)
				ReplicatedStorage.SharedModules.Network.RequestDoubleStrength:InvokeServer()
			end
		end)
	end
end

-- Launch Function --

local function AutoLaunch()
	if LaunchEnabled then
		local captureBrainrots = workspace.Live.Debris.CapturBrainrots
		local launchButton = PlayerGui.BottomHud.Window.Container.Frame.Btns.LaunchBtn.Button
	end
end

-- Collect Cash Function --
local function AutoCash()
	if CashEnabled then
		task.spawn(function()
			while CashEnabled do
				task.wait(1)
				Plot = (Plot ~= nil and Plot.Parent ~= nil) and Plot or GetPlot()
				if Plot then
					local slots = Plot:FindFirstChild("BaseTemplate") and Plot.BaseTemplate:FindFirstChild("Resources") and Plot.BaseTemplate.Resources:FindFirstChild("PlotSlots")
					if slots then
						for _, slot in ipairs(slots:GetChildren()) do
							if slot:IsA("Model") then
								local itemUID = slot:GetAttribute("ItemUID")
								if itemUID ~= nil then
									task.wait()
									if CashEnabled then
										ReplicatedStorage.SharedModules.Network.ClaimEarnings:InvokeServer(itemUID)
									end
								end
							end
						end
					end
				end
			end
		end)
	end
end


-- Buy Building Function --
local function AutoBuy()
	if BuyEnabled then
		task.spawn(function()
			while BuyEnabled do
				task.wait(1)
				for index = 1, 3 do
					task.wait(1)
					if BuyEnabled then
						ReplicatedStorage.SharedModules.Network.BuyBuildFloor:InvokeServer(index)
					end
				end
			end
		end)
	end
end


-- Rebirth Function --
local function AutoRebirth()
	if RebirthEnabled then
		task.spawn(function()
			while RebirthEnabled do
				ReplicatedStorage.SharedModules.Network.Rebirth:InvokeServer()
				task.wait(5)
			end
		end)
	end
end


-- Main UI --
local Window = UI:CreateWindow({
	Name = "Paper Plane For Brainrots", 
	Destroying = function()
		LaunchEnabled, BuyEnabled, CashEnabled, TrainEnabled, RebirthEnabled = false, false, false, false, false
	end
})

Window:AddToggle({
	Name = "Auto Train",
	Value = false,
	Callback = function(value)
		TrainEnabled = value
		AutoTrain()
	end
})

Window:AddToggle({
	Name = "Auto Launch",
	Value = false,
	Callback = function(value)
		LaunchEnabled = value
		AutoLaunch()
	end
})

Window:AddToggle({
	Name = "Collect Cash",
	Value = false,
	Callback = function(value)
		CashEnabled = value
		AutoCash()
	end
})

Window:AddToggle({
	Name = "Buy Building",
	Value = false,
	Callback = function(value)
		BuyEnabled = value
		AutoBuy()
	end
})

Window:AddToggle({
	Name = "Auto Rebirth",
	Value = false,
	Callback = function(value)
		RebirthEnabled = value
		AutoRebirth()
	end
})


Window:AddLabel("YouTube: Crokyreo")
