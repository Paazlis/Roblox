local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local RollEnabled = false
local DesiredChance = 1
local Plot = nil

local Window = UI:CreateWindow({
    Name = "Make Hotsauce",
    Destroying = function()
       RollEnabled = false
    end
})

local function GetPlot()
    local playerLots = workspace:FindFirstChild("PlayerLots")
    if not playerLots then return nil end
    
    for _, base in pairs(playerLots:GetChildren()) do
        if base:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return base
        end
    end
  
    return nil
end

local function StartAutoRoll()
    if not RollEnabled then return end
    task.spawn(function()
        while RollEnabled do
            Plot = (Plot ~= nil and Plot.Parent ~= nil) and Plot or GetPlot()
            if Plot then
                local seedMachine = myLot:FindFirstChild("Important") and myLot.Important:FindFirstChild("SeedMachine")
                
                if seedMachine then
                    local button = seedMachine:FindFirstChild("Button")
                    local rollClickDetector = button and button:FindFirstChildOfClass("ClickDetector")
                    
                    local foundSeed = false
                    local seedToTake = {}
                    
                    for _, child in pairs(seedMachine:GetChildren()) do
                        if child:IsA("Model") and string.find(child.Name, "Seed") then
                            foundSeed = true
                            local chance = child:GetAttribute("SeedChance")
                            if chance and chance >= DesiredChance then
                                seedToTake = child
                            end
                            break
                        end
                    end
                    
                    if seedToTake then
                        -- Ambil Seed jika memenuhi syarat
                        -- Asumsi ada ClickDetector/ProximityPrompt pada Seed untuk mengambilnya
                        local seedClickDetector = seedToTake:FindFirstChildOfClass("ClickDetector", true)
                        local seedPrompt = seedToTake:FindFirstChildOfClass("ProximityPrompt", true)
                        
                        if seedClickDetector then
                            fireclickdetector(seedClickDetector)
                        elseif seedPrompt then
                            fireproximityprompt(seedPrompt)
                        end
                        
                        task.wait(0.5)
                        
                        if rollClickDetector then
                            fireclickdetector(rollClickDetector)
                        end
                    else
                        if rollClickDetector then
                            fireclickdetector(rollClickDetector)
                        end
                    end
                end
            end
            task.wait(0.2) -- Jeda loop agar game tidak lag atau crash
        end
    end)
end

Window:AddSlider({
    Text = "Roll Chance (1 in ...)", 
    Range = {1, math.huge},
    Increment = 1,
    Callback = function(value)
       DesiredChance = value
    end
})

Window:AddToggle({
    Text = "Auto Roll", 
    Value = false,
    Callback = function(value)
       RollEnabled = value
       StartAutoRoll()
    end
})

Window:AddLabel({
    Text = "YouTube: Crokyreo"
})
