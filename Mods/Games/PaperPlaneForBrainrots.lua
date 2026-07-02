local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Utility/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager = Services.VirtualInputManager
local UserInputService = Services.UserInputService

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer.PlayerGui

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local LaunchEnabled, BuyEnabled, CashEnabled, TrainEnabled, RebirthEnabled = false, false, false, false, false
local LaunchConnection = nil

local ClickPoint=UserInputService:GetMouseLocation()

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

local function Mouse1Click(x,y)
	VirtualInputManager:SendMouseButtonEvent(x,y,0,true,game,0)
	task.wait()
	VirtualInputManager:SendMouseButtonEvent(x,y,0,false,game,0)
end

local function FireButton(object)
	if firesignal then
		firesignal(object.MouseButton1Click)
		firesignal(object.Activated)
	end
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
local function IsFillPerfect(fill)
	local currentY = fill.Size.Y.Scale
	if currentY >= 0.98 and currentY <= 1 then
		return true
	end
	return false
end

local function AutoLaunch()
	LaunchConnection = Utility.Cleanup(LaunchConnection)

	if LaunchEnabled then
		local launchFrame = PlayerGui.BottomHud.Window.Container
		local launchButton = launchFrame.Frame.Btns.LaunchBtn.Button
		local progress = PlayerGui.SkillCheck.Window.Container
		local fill = progress.Container.Bar

		LaunchConnection = fill:GetPropertyChangedSignal("Size"):Connect(function()
			if progress.Visible and IsFillPerfect(fill) then
				Mouse1Click(ClickPoint.X,ClickPoint.Y)
			end
		end)


		task.spawn(function()
			while LaunchEnabled do
				task.wait(1)
				if launchFrame.Visible and not progress.Visible then
					FireButton(launchButton)
					task.wait(1)
					if progress.Visible then
						progress:GetPropertyChangedSignal("Visible"):Wait()
					end
					task.wait(1)
				end

			end
		end)
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
		LaunchConnection = Utility.Cleanup(LaunchConnection)
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
