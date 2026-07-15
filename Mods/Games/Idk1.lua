local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local CollectCashPacket, TurretUpgradePacket = nil, nil
local Enableds = {}
local UpgradeAccessColor = Color3.new(50, 214, 0)

local function GetPlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return end

    for _, plot in ipairs(plots:GetChildren()) do
        local ownerId = plot:GetAttribute("OwnerUserId")
        if ownerId ~= nil and ownerId == LocalPlayer.UserId then
            return plot
        end
    end

    return nil
end

local Plot = GetPlot()

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function IsFillFull(fill)
	if fill.Size.X.Scale >= 1 then
		return true
	end
	return false
end

local Window = UI:CreateWindow({
	Name = "Idk 1",
	Destroying = function()
        for _, key in ipairs({"Upgrade","Turret","TurretLuck","TurretSlots","ZombieLuck","ZombieYield","CollectCash"}) do
            Enableds[key] = false
        end
	end
})

Window:AddToggle({
	Text = "Collect Cash",
	Value = false,
	Flag = "collect_cash_enabled",
	Callback = function(value)
        Enableds.CollectCash = value
        if value then
            task.spawn(function()
                if not CollectCashPacket then
                   CollectCashPacket = ReplicatedStorage.Events.Global.Core.TurretCollect
                end
			    while Enableds.CollectCash do
					task.wait(1)
                    CollectCashPacket:FireServer()
                end
            end)
        end
    end
})

Window:AddDropdown({
	Text = "Upgrade Type",
    Options = {"Turret Luck","Turret Slots","Zombie Luck","Zombie Yield","Turret"}
	Option = nil,
	Flag = "upgrade_list",
	Callback = function(option)
        Enableds.Turret = table.find(option, "Turret") ~= nil
        Enableds.TurretLuck = table.find(option, "Turret Luck") ~= nil
        Enableds.TurretSlots = table.find(option, "Turret Slots") ~= nil
        Enableds.ZombieLuck = table.find(option, "Zombie Luck") ~= nil
        Enableds.ZombieYield = table.find(option, "Zombie Yield") ~= nil
	end
})

Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Flag = "upgrade_enabled",
	Callback = function(value)
        Enableds.Upgrade = value
		if value then
			task.spawn(function()
                local turretScreen = PlayerGui.PlotScreens.TurretScreen
                        
				while  Enableds.Upgrade do
					task.wait(1)

                    if Enableds.TurretLuck or Enableds.TurretSlots then
                        for _, frame in ipairs(turretScreen:GetChildren()) do
                            if frame and frame.Parent then
                                local buyButton = frame:FindFirstChild("Buy")
                                if buyButton and buyButton.BackgroundColor3 == UpgradeAccessColor  then
                                    task.wait()
                                    local access = false
                                    if frame.Name == "TurretLuck" and Enableds.TurretLuck then
                                        access = true
                                    elseif frame.Name == "TurrentSlots" and Enableds.TurretSlots then
                                        access = true   
                                    end
                                    if access then
                                        FireButton(buyButton)
                                    end
                                end
                            end
                        end
                    end
				end
			end)
            
            task.spawn(function()
                local zombieScreen = PlayerGui.PlotScreens.ZombieScreen
                        
				while Enableds.Upgrade do
					task.wait(1)

                    if Enableds.ZombieLuck or Enableds.ZombieYield then
                        for _, frame in ipairs(zombieScreen:GetChildren()) do
                            if frame and frame.Parent then
                                local buyButton = frame:FindFirstChild("Buy")
                                if buyButton and buyButton.BackgroundColor3 == UpgradeAccessColor  then
                                    local access = false
                                    if frame.Name == "ZombieLuck" and Enableds.ZombieLuck then
                                        access = true
                                    elseif frame.Name == "ZombieYield" and Enableds.ZombieYield then
                                        access = true   
                                    end
                                    if access then
                                        task.wait(1)
                                        FireButton(buyButton)
                                    end
                                end
                            end
                        end
                    end
				end
			end)

            task.spawn(function()
                if not TurretUpgradePacket then
                    TurretUpgradePacket = ReplicatedStorage.Events.Global.Core.TurretUpgrade
                end
                        
                local turrets = Plot:FindFirstChild("Turrets")
                if not turrets then return end
                
				while Enableds.Upgrade do
					task.wait(1)
                    if Enableds.Turret then
                        for _, turret in ipairs(turrets:GetChildren()) do
                            if turret:IsA("Model") then
                                local gridCell = turret:GetAttribute("GridCell")
                                if gridCell ~= nil and Enableds.Turret then
                                    task.wait(1)
                                    TurretUpgradePacket:FireServer(gridCell)
                                end
                            end
                        end
                    end
				end
			end)
		end
	end
})


Window:AddLabel("YouTube: Crokyreo")
