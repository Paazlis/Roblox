local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local RollEnabled, CollectEnabled, AddEnabled = false, false, false
local DesiredChance = 1
local Plot = nil
local AddAdded = nil

local Window = UI:CreateWindow({
    Name = "Make Hotsauce",
    Destroying = function()
       RollEnabled, CollectEnabled, AddEnabled = false, false, false
            if AddAdded then AddAdded:Disconnect() AddAdded = nil end
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
            task.wait(0.2)
        end
    end)
end

local function StartAutoCollect()
    if not CollectEnabled then return end
    task.spawn(function()
        while CollectEnabled do
            Plot = (Plot ~= nil and Plot.Parent ~= nil) and Plot or GetPlot()
            if Plot then
                local peppers = {}
                for i, v in ipairs(Plot:GetChildren()) do
                   if v.Name == "Crop" and v.ClassName == "Model" then
                      for _, item in ipairs(v:GetChildren()) do
                         if string.find(string.lower(item.Name), "pepper") and item:FindFirstChild("Meat") then
                            table.insert(peppers, item) 
                         end
                      end
                   end
                end
                for _. v in ipairs(peppers) do
                    LocalPlayer.Character:PivotTo(v.Meat.CFrame)
                    task.wait(0.2)
                    fireproximityprompt(v.Meat.PickPepperPrompt)
                end
            end
            task.wait(1)
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

Window:AddToggle({
    Text = "Auto Collect", 
    Value = false,
    Callback = function(value)
       CollectEnabled = value
       StartAutoCollect()
    end
})

local function setAdd(tool)
    if string.find(tool.Name, "Pepper") then
        local Event = ReplicatedStorage.Events.Brewing.AddPepper
        Event:InvokeServer(false,tool.Name)
    end
end

Window:AddToggle({
    Text = "Auto Add", 
    Value = false,
    Callback = function(value)
       if AddAdded then AddAdded:Disconnect() AddAdded = nil end
       if value then
          AddAdded = LocalPlayer.Backpack.ChildAdded:Connect(setAdd)
          
          for i,v in ipairs(LocalPlayer.Backpack:GetChildren()) do
             if AddAdded then
                task.wait(0.1)
                setAdd(v)
             end
          end
       end
    end
})

Window:AddLabel({
    Text = "YouTube: Crokyreo"
})
