local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Utility/init.luau"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

local RollEnabled, PickupEnabled, AddEnabled = false, false, false

local AddConnection = nil
local PickupConnections = {}

local function GetPlot()
    local playerLots = workspace:FindFirstChild("PlayerLots")
    if not playerLots then return nil end
    
    for _, base in pairs(playerLots:GetChildren()) do
        if base.Name == LocalPlayer.Name then
            return base
        end
    end
  
    return nil
end

local Plot = GetPlot()

-- Roll Seed Function --
local function AutoRollSeed()
    if not RollEnabled then return end
    task.spawn(function()
        while RollEnabled do
            task.wait(1)

            Plot = (Plot ~= nil and Plot.Parent ~= nil) and Plot or GetPlot()
            if Plot then
                local seedMachine = Plot:FindFirstChild("Important") and Plot.Important:FindFirstChild("SeedMachine")
                
                if seedMachine then
                    local rollDetector = seedMachine:FindFirstChild("Button") and seedMachine.Button:FindFirstChildOfClass("ClickDetector")
                    local foundSeed = false

                    for _, seed in pairs(seedMachine:GetChildren()) do
                        if seed:IsA("Model") and seed.Name:lower():find("seed") then
                            foundSeed = true
                            break
                        end
                    end
                    
                    if foundSeed then
                        --[[
                        local seedClickDetector = seedToTake:FindFirstChildOfClass("ClickDetector", true)
                        local seedPrompt = seedToTake:FindFirstChildOfClass("ProximityPrompt", true)
                        
                        if seedClickDetector then
                            fireclickdetector(seedClickDetector)
                        elseif seedPrompt then
                            fireproximityprompt(seedPrompt)
                        end
                        ]]

                        task.wait(0.5)
                        
                        if rollDetector then
                            fireclickdetector(rollDetector)
                        end
                    else
                        if rollDetector then
                            fireclickdetector(rollDetector)
                        end
                    end
                end
            end
          
        end
    end)
end

-- Pickup Pepper Function --
local function PickupPepperAdded(pepper)
    if pepper.Name:lower():find("pepper") then
        ReplicatedStorage.Events.Pepper.PickupPepper:InvokeServer(pepper)
    end
end

local function PickupCropAdded(crop)
    if crop:IsA("Model") and crop.Name == "Crop" then
      for _, pepper in ipairs(crop:GetChildren()) do
         PickupPepperAdded(pepper)
      end
      local connection = crop.ChildAdded:Connect(PickupPepperAdded)
      table.insert(PickupConnections, connection)
   end
end

local function AutoPickupPepper()
    for _, connection in ipairs(PickupConnections) do Utility.Cleanup(connection) end
    table.clear(PickupConnections)
    if PickupEnabled then
        Plot = (Plot ~= nil and Plot.Parent ~= nil) and Plot or GetPlot()
        if Plot then
            for _, crop in ipairs(Plot:GetChildren()) do
               PickupCropAdded(crop)
            end
            local connection = Plot.ChildAdded:Connect(PickupCropAdded)
            table.insert(PickupConnections, connection)
        end
    end
end

-- Add Pepper Function --
local function AddPepperAdded(tool)
    if tool.Name:lower():find("pepper") then
        ReplicatedStorage.Events.Brewing.AddPepper:InvokeServer(false, tool.Name)
    end
end

local function AutoAddPepper()
    AddConnection = Utility.Cleanup(AddConnection)
    if AddEnabled then
      for _, tool in ipairs(Backpack:GetChildren()) do
         AddPepperAdded(tool)
      end
      AddConnection = Backpack.ChildAdded:Connect(AddPepperAdded)
    end
end

-- Main UI --
local Window = UI:CreateWindow({
    Name = "Make Hotsauce",
    Destroying = function()
        RollEnabled, PickupEnabled, AddEnabled = false, false, false
        AddConnection = Utility.Cleanup(AddConnection)
        for _, connection in ipairs(PickupConnections) do Utility.Cleanup(connection) end
        table.clear(PickupConnections)
    end
})

Window:AddToggle({
    Text = "Auto Roll", 
    Value = false,
    Callback = function(value)
       RollEnabled = value
       AutoRollSeed()
    end
})

Window:AddToggle({
    Text = "Auto Pickup", 
    Value = false,
    Callback = function(value)
       PickupEnabled = value
       AutoPickupPepper()
    end
})

Window:AddToggle({
    Text = "Auto Add", 
    Value = false,
    Callback = function(value)
        AddEnabled = value
        AutoAddPepper()
    end
})

Window:AddLabel({
    Text = "YouTube: Crokyreo"
})
