local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Utility/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager = Services.VirtualInputManager
local UserInputService = Services.UserInputService

local GameCore, UtilityCore = nil, nil

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer.PlayerGui

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local Enableds, Connections = {Launch = false, Buy = false, Cash = false, Train = false, Rebirth = false, Farm = false}, {}

local LaunchEnabled, BuyEnabled, CashEnabled, TrainEnabled, RebirthEnabled, Farming = false, false, false, false, false, false
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
local function HandleTrain()
	if Enableds.Train then
		task.spawn(function()
			while Enableds.Train do
				ReplicatedStorage.SharedModules.Network.RequestStrength:InvokeServer()
				task.wait(0.5)
			end
		end)
	end

	if Enableds.Train then
		task.spawn(function()
			while Enableds.Train do
				ReplicatedStorage.SharedModules.Network.RequestDoubleStrength:InvokeServer()
				task.wait(0.5)
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

local function HandleLaunch()
    if Connections.Launch then Connections.Launch:Disconnect() Connections.Launch = nil end
	
	if Enableds.Launch then
		local launchFrame = PlayerGui.BottomHud.Window.Container
		local launchButton = launchFrame.Frame.Btns.LaunchBtn.Button
		local progress = PlayerGui.SkillCheck.Window.Container
		local fill = progress.Container.Bar

		Connections.Launch = fill:GetPropertyChangedSignal("Size"):Connect(function()
			if progress.Visible and IsFillPerfect(fill) and Enableds.Launch then
				Mouse1Click(ClickPoint.X,ClickPoint.Y)
			end
		end)

		task.spawn(function()
			while Enableds.Launch do
				if launchFrame.Visible and not progress.Visible and Enableds.Launch then
					FireButton(launchButton)
					task.wait(1)
					if progress.Visible and Enableds.Launch then
						progress:GetPropertyChangedSignal("Visible"):Wait()
					end
					task.wait(1)
				end
				task.wait(0.5)
			end
		end)
	end
end

-- Farm Function --
local function HandleFarm()
	if Enableds.Farm then
	    GameCore = GameCore or require(ReplicatedStorage.GameCore)
		UtilityCore = UtilityCore or require(ReplicatedStorage.UtilityCore)

		local vsp = Vector3.new(-347.2116394043, 89.037544250488, 25.892095565796)
		local GROUND_Y = GameCore.GameConfig.GROUND_Y
		local FORWARD_VECTOR = GameCore.GameConfig.FORWARD_VECTOR
        local limit = 10000000
		
		task.spawn(function()
			while Enableds.Farm do
				ReplicatedStorage.SharedModules.Network.RequestPendingFlight:FireServer()
				task.wait(1)
				local result = ReplicatedStorage.SharedModules.Network.RequestActiveFlight:InvokeServer({
				    plotIndex = LocalPlayer:GetAttribute("PlotIndex"),
					intensity = 1,
					player = LocalPlayer,
					flightUID = UtilityCore.StringUtility.GenerateUID(),
					visualStartPos = vsp,
					startTime = GameCore.GetSycnedTime(),
					startPos = Vector3.new(-347.2116394043, 85.050003051758, 25.892095565796),
					serverStrength = limit,
					serverFloors = limit
				})
				if not result then continue end
				local chosenBrainrot = result.spawnedBrainrots[1]
				task.wait(result.timeInAir + 0.5)
				ReplicatedStorage.SharedModules.Network.ClaimFlight:InvokeServer(chosenBrainrot.uid)
			end
		end)
	end
end

-- Collect Cash Function --
local function HandleCash()
	if Enableds.Cash then
		task.spawn(function()
			while Enableds.Cash do
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
									if Enableds.Cash then
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
	if Enableds.Buy then
		task.spawn(function()
			while Enableds.Buy do
				for index = 1, 3 do
					if Enableds.Buy then
						ReplicatedStorage.SharedModules.Network.BuyBuildFloor:InvokeServer(index)
					end
					task.wait(0.5)
				end
				task.wait(0.5)
			end
		end)
	end
end


-- Rebirth Function --
local function HandleRebirth()
	if Enableds.Rebirth then
		task.spawn(function()
			while Enableds.Rebirth do
				ReplicatedStorage.SharedModules.Network.Rebirth:InvokeServer()
				task.wait(5)
			end
		end)
	end
end

local Window = UI:CreateWindow({
	Name = "Paper Plane For Brainrots", 
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
	Text = "Auto Train",
	Value = false,
	Callback = function(value)
		Enableds.Train = value
		HandleTrain()
	end
})

Window:AddToggle({
	Text = "Auto Launch",
	Value = false,
	Callback = function(value)
		Enableds.Launch = value
		HandleLaunch()
	end
})

Window:AddToggle({
	Text = "Auto Farm",
	Value = false,
	Callback = function(value)
		Enableds.Farm = value
		HandleFarm()
	end
})

Window:AddToggle({
	Text = "Collect Cash",
	Value = false,
	Callback = function(value)
		Enableds.Cash = value
		HandleCash()
	end
})

Window:AddToggle({
	Text = "Buy Building",
	Value = false,
	Flag = "buy_building_enabled",
	Callback = function(value)
		Enableds.Buy = value
		HandleBuy()
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
	Text = "YouTube: vaehz",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
