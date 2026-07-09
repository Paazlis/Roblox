local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local CashEnabled, TrainEnabled, RebirthEnabled, Farming = false, false, false, false, false
local TrainConnection = nil

local function GetPlot()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end

	for _, base in pairs(plots:GetChildren()) do
		local ownerId = base:GetAttribute("Owner")
        if tostring(ownerId) == tostring(LocalPlayer.UserId) then
            return base
        end
	end

	return nil
end

local Plot = GetPlot()

local function FireButton(object)
	if firesignal then
		firesignal(object.MouseButton1Click)
		firesignal(object.Activated)
	end
end

-- Train Function --
local function TrainAdded(child)
   if child.Name:lower() == "doublebutton" and TrainEnabled then
      pcall(FireButton, child)
   end
end

local function AutoTrain()
    if TrainConnection then TrainConnection:Disconnect() TrainConnection = nil end
    if TrainEnabled then
        task.spawn(function()
            while TrainEnabled do
                task.wait(1)
                local gym = LocalPlayer.Backpack:FindFirstChild("Gym")
                if gym then
                    pcall(function()
                        LocalPlayer.Character.Humanoid:EquipTool(gym)
                    end)
                end
               	ReplicatedStorage.Remotes.doubleStrength:FireServer()
            end
        end)

        local frame = PlayerGui.Main
        TrainConnection = frame.ChildAdded:Connect(TrainAdded)
        for _, child in pairs(frame:GetChildren()) do
		   TrainAdded(child)
        end
    end
end

-- Farming Function --
local function AutoFarming()
    if Farming then
        task.spawn(function()
            while Farming do
                task.wait(0.5)
                task.spawn(function()
                    ReplicatedStorage.Remotes.OnCast:InvokeServer(1)
                    ReplicatedStorage.Remotes.StartRun:InvokeServer()
                    ReplicatedStorage.Remotes.FinishRun:InvokeServer(true)
                end)
            end
        end)
    end
end

-- Collect Cash Function --
local function AutoCash()
    if CashEnabled then
        task.spawn(function()
            while CashEnabled do
                task.wait(0.5)
                Plot = (Plot ~= nil and Plot.Parent) and Plot or GetPlot()
                if Plot then
                    local slots = Plot:FindFirstChild("Slots")
                    if slots then
                        for _, slot in pairs(slots:GetChildren()) do
                           ReplicatedStorage.Remotes.Claim:InvokeServer(tonumber(slot.Name) or 1)
                        end
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
                task.wait(5)
                ReplicatedStorage.Remotes.Rebirth:InvokeServer()
            end
        end)
    end
end

-- Main UI --
local Window = UI:CreateWindow({
    Name = "Lick A Brainrots", 
    Destroying = function()
        if TrainConnection then TrainConnection:Disconnect() TrainConnection = nil end
        CashEnabled, TrainEnabled, RebirthEnabled, Farming = false, false, false, false, false
    end
})

Window:AddToggle({
    Text = "Auto Farming",
    Value = false,
    Callback = function(value)
        Farming = value
        AutoFarming()
    end
})

Window:AddToggle({
    Text = "Auto Train",
    Value = false,
    Callback = function(value)
        TrainEnabled = value
        AutoTrain()
    end
})

Window:AddToggle({
    Text = "Collect Cash",
    Value = false,
    Callback = function(value)
        CashEnabled = value
        AutoCash()
    end
})

Window:AddToggle({
    Text = "Auto Rebirth",
    Value = false,
    Callback = function(value)
        RebirthEnabled = value
        AutoRebirth()
    end
})

Window:AddLabel("YouTube: Crokyreo")
Window:AddLabel("YouTube: vaehz")
