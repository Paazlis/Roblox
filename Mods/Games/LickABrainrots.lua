local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer

local BuyEnabled, CashEnabled, TrainEnabled, RebirthEnabled, Farming = false, false, false, false, false

-- Train Function --
local function AutoTrain()
    if TrainEnabled then
        task.spawn(function()
            while TrainEnabled do
                task.wait(1)
                local gym = LocalPlayer.Backpack:FindFirstChild("Gym")
                if gym then
                    pcall(function()
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid:EquipTool(gym)
                        end
                    end)
                end
                
               	ReplicatedStorage.Remotes.doubleStrength:FireServer()
            end
        end)
    end
end

-- Farming Function --
local function AutoFarming()
    if Farming then
        task.spawn(function()
            while Farming do
                task.wait(0.5)
                task.spawn(function()
                    pcall(function()
                        ReplicatedStorage.Remotes.OnCast:InvokeServer(1)
                        ReplicatedStorage.Remotes.StartRun:InvokeServer()
                        ReplicatedStorage.Remotes.FinishRun:InvokeServer(true)
                    end)
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
                task.wait(1)
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
            end
        end)
    end
end

-- Main UI --
local Window = UI:CreateWindow({
    Name = "Paper Plane For Brainrots", 
    Destroying = function()
        BuyEnabled, CashEnabled, TrainEnabled, RebirthEnabled, Farming = false, false, false, false, false
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
    Text = "Auto Farming",
    Value = false,
    Callback = function(value)
        Farming = value
        AutoFarming()
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
    Text = "Buy Building",
    Value = false,
    Callback = function(value)
        BuyEnabled = value
        AutoBuy()
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

Window:AddLabel({Text = "YouTube: Crokyreo"})
Window:AddLabel({Text = "YouTube: vaehz"})
