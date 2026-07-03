local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

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
                        LocalPlayer.Character.Humanoid:EquipTool(gym)
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
                    ReplicatedStorage.Remotes.OnCast:InvokeServer(1)
                    ReplicatedStorage.Remotes.StartRun:InvokeServer()
                    ReplicatedStorage.Remotes.FinishRun:InvokeServer(true)
                end)
            end
        end)
    end
end

-- Main UI --
local Window = UI:CreateWindow({
    Name = "Lick A Brainrots", 
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

Window:AddLabel("YouTube: Crokyreo")
Window:AddLabel("YouTube: vaehz")
