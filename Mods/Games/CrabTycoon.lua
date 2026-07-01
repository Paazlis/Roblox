local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Workspace = Services.Workspace
local Players = Services.Players

local LocalPlayer = Players.LocalPlayer
local DepositEnabled, BuyEnabled, MergeEnabled, CashEnabled, PickupEnabled = false, false, false, false, false

local PickupConnection = nil

local function GetPlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    
    for _, base in pairs(plots:GetChildren()) do
        local ownerId = base:GetAttribute("OwnerUserId")
        if ownerId and ownerId == LocalPlayer.UserId then
            return base
        elseif base.Name:find(LocalPlayer.Name) then
            return base
        end
    end
  
    return nil
end

local Plot = GetPlot()

local function FireTouch(hitPart, targetPart)
   if firetouchinterest and hitPart and targetPart then
      firetouchinterest(hitPart, targetPart, 1)
      task.wait()
      firetouchinterest(hitPart, targetPart, 0)
   end
end

-- Pickup Function --
local function PickupAdded(child)
    if child.Parent and child.Name:lower():find("RollSphere") and child:IsA("BasePart") and child:GetAttribute("Tier") ~= nil then
        if LocalPlayer.Character then
            FireTouch(LocalPlayer.Character.PrimaryPart, child)  
        end 
    end
end

local function AutoPickup()
    if PickupConnection then PickupConnection:Disconnect() PickupConnection = nil end
    if PickupEnabled then
        PickupConnection = Workspace.ChildAdded:Connect(function(child)
            task.wait(1)
            PickupAdded(child)
        end)
        for _, child in ipairs(Workspace:GetChildren()) do
            PickupAdded(child)
        end
    end
end

-- Deposit Function --
local function AutoDeposit()
    if DepositEnabled then
        task.spawn(function()
            while DepositEnabled do
               task.wait(1)
               if Plot then
                  local targetPart = Plot.DepositShells.Press
                  if targetPart and LocalPlayer.Character then
                     FireTouch(LocalPlayer.Character.PrimaryPart, targetPart)
                  end
			   end
            end
        end)
     end
end

local Window = UI:CreateWindow({Name = "Crab Tycoon", Destroying = function()
     if PickupConnection then PickupConnection:Disconnect() PickupConnection = nil end
     DepositEnabled, BuyEnabled, MergeEnabled, CashEnabled, PickupEnabled = false, false, false, false, false
end})

Window:AddToggle({
	Name = "Collect Shell",
    Value = false,
	Callback = function(value)
        PickupEnabled = value
        AutoPickup()
    end
})

Window:AddToggle({
	Name = "Auto Deposit",
    Value = false,
	Callback = function(value)
        DepositEnabled = value
        AutoDeposit()
    end
})

Window:AddToggle({
	Name = "Collect Cash",
    Value = false,
	Callback = function(value)
    CashEnabled = value
        if value then
            task.spawn(function()
                while CashEnabled do
                    task.wait(1)
                    local button = Plot and Plot:FindFirstChild("CollectCash") and Plot.CollectCash:FindFirstChild("Press")
                    FireTouch(LocalPlayer.Character and LocalPlayer.Character.PrimaryPart, button)
                end
            end)
        end
    end
})


Window:AddToggle({
	Name = "Auto Merge",
    Value = false,
	Callback = function(value)
        MergeEnabled = value
        if value then
            task.spawn(function()
                while MergeEnabled do
                    task.wait(1)
                    local button = Plot and Plot:FindFirstChild("Merge") and Plot.Merge:FindFirstChild("Press")
                    FireTouch(LocalPlayer.Character and LocalPlayer.Character.PrimaryPart, button)
                end
            end)
        end
    end
})

Window:AddToggle({
	Name = "Auto Buy",
    Value = false,
	Callback = function(value)
        BuyEnabled = value
        if value then
            task.spawn(function()
                while BuyEnabled do
                    task.wait(1)
                    if Plot then
                        for _, model in ipairs(Plot:GetChildren()) do
                             task.wait()
                            if model.Name:find("Buy") and model:FindFirstChild("Press") then
                                FireTouch(LocalPlayer.Character and LocalPlayer.Character.PrimaryPart, model.Press)
                            end
                        end
                    end
                end
            end)
        end
    end
})

Window:AddLabel("YouTube: Crokyreo")
