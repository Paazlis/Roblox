local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau", true))()
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local PurchaseEnabled, UpgradeEnabled = false, false
local PurchaseUpgradeAddedConnection = nil
local PurchaseButtons = {}
local TransparencyConnections = {}

local function GetPlot()
    for _, plot in ipairs(workspace.Plots:GetChildren()) do
        local ownerId = plot:GetAttribute("OwnerId")
        if ownerId ~= nil and ownerId == LocalPlayer.UserId then
            return plot
        end
    end
    return nil
end

local function FireTouch(hitPart, targetPart)
    if firetouchinterest then
        firetouchinterest(hitPart, targetPart, 1)
        task.wait()
        firetouchinterest(hitPart, targetPart, 0)
    end
end

local Plot = GetPlot()

local Window = UI:CreateWindow({Name = "My Parking Lot", Destroying = function()
    if PurchaseUpgradeAddedConnection then 
        PurchaseUpgradeAddedConnection:Disconnect() 
        PurchaseUpgradeAddedConnection = nil 
    end
    PurchaseEnabled, UpgradeEnabled = false, false
    table.clear(PurchaseButtons)
    for _, connection in ipairs(TransparencyConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    table.clear(TransparencyConnections)
end})

local function PurchaseButtonAdded(model)
    local button = model:FindFirstChild("Purchase")
    if button then
        if button.Transparency == 0 then
            table.insert(PurchaseButtons, button)
        end
        local connection = button:GetPropertyChangedSignal("Transparency"):Connect(function()
            if button.Transparency == 0 then
                table.insert(PurchaseButtons, button)
            end
            if button.Transparency == 1 then
                local index = table.find(PurchaseButtons, button)
                if index then
                    table.remove(PurchaseButtons, index)
                end
            end 
        end)

        table.insert(TransparencyConnections, connection)
    end
end

local function PurchaseUpgradeAdded(model)
    local purchaseFolder = model:FindFirstChild("Purchase")
    if purchaseFolder then
        for _, purchase in ipairs(purchaseFolder:GetChildren()) do
            PurchaseButtonAdded(purchase)
        end
    end
end

Window:AddToggle({
    Text = "Purchase All",
    Value = false,
    Callback = function(value)
        PurchaseEnabled = value
        
        if PurchaseUpgradeAddedConnection then 
            PurchaseUpgradeAddedConnection:Disconnect() 
            PurchaseUpgradeAddedConnection = nil 
        end
        
        if value then
            local Upgrades = Plot.Upgrades

            PurchaseUpgradeAddedConnection = Upgrades.ChildAdded:Connect(PurchaseUpgradeAdded)
            
            for _, model in ipairs(Upgrades:GetChildren()) do
                PurchaseUpgradeAdded(model)
            end

            task.spawn(function()
                while PurchaseEnabled do
                    task.wait(1)
                    if next(PurchaseButtons) then
                        for _, button in ipairs(PurchaseButtons) do
                            -- Tambahkan pengecekan PrimaryPart agar tidak error saat karakter respawn
                            if button and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                                FireTouch(LocalPlayer.Character.PrimaryPart, button)
                            end
                        end
                    end
                end
            end)
        else
            table.clear(PurchaseButtons)
            for _, connection in ipairs(TransparencyConnections) do
                if connection then
                    connection:Disconnect()
                end
            end
            table.clear(TransparencyConnections)
        end
    end
})



Window:AddToggle({
    Text = "Auto Upgrade",
    Value = false,
    Callback = function(value)
       UpgradeEnabled = value
       if value then
          task.spawn(function()
              while UpgradeEnabled do
                 task.wait(1)
                 for _, frame in ipairs(PlayerGui.Frames.Upgrade.Holder.ScrollingFrame:GetChildren()) do
                    if frame.ClassName == "Frame" then
                       local button = nil
                       for i,v in ipairs(frame:GetChildren()) do
                          if v.Name == "Upgrade" and v.ClassName == "TextButton" or v.ClassName == "ImageButton" then
                             button = v
                             break
                          end
                       end
                       if button then
                          firesignal(button.Activated)
                       end
                    end
                 end
              end
          end)
       end
    end
})

Window:AddLabel({
    Text = "YouTube: Crokyreo"
})
