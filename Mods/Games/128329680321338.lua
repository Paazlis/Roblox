
Game Name: 
-- auto click --
use Maswa Clicker


-- auto rebirth --
 game:GetService("Players").LocalPlayer.PlayerGui.NewGui.MainFrames.RebirthFrame.RebirthBackground.RebirthButton

game:GetService("Players").LocalPlayer.PlayerGui.NewGui.MainFrames.RebirthFrame.RebirthBackground.Bar.BarCanvas.Progress

-- auto upgrade 

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local UpgradeTypes {"Damage", "Wins", "Luck"}
local Enableds = {["Upgrade"] = false}
local Connections = {}
local Packets = {
 ["BuyBoost"] = ReplicatedStorage:FindFirstChild("BuyBoost")
}

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
	Name = "+1 Fat Per Click",
	Destroying = function()
    for key, value in pairs(Enableds) do
       Enableds[key] = false
    end
   
    for _, connection in pairs(Connections) do
       if connection then
          connection:Disconnect()
       end
    end
	end
})

local LoadAutoClickerButton = nil
LoadAutoClickerButton = Window:AddButton({
	Text = "Load Auto Clicker",
	MethodType = "DoubleClick",
	Callback = function()
		 loadstring(game:HttpGet(""))()
   LoadAutoClickerButton.Visible = false
	end
})

Window:AddToggle({
	Text = "Upgrade All",
	Value = false,
	Flag = "upgrade_enabled",
	Callback = function(value)
		UpgradeEnabled = value
		if value  then
			task.spawn(function()
				local boostsScroll = PlayerGui.NewGui.MainFrames.BoostsFrame.BoostsBackground.BoostsInnerFrame
				
				while UpgradeEnabled do
					task.wait(1)
							
					for _, child in ipairs(boostsScroll:GetChildren()) do
						task.wait()
						local cashButton = child:FindFirstChild("CashButton")
						if cashButton then
							FireButton(cashButton)
						end
					end
				end
			end)
			task.spawn(function()
				local upgradeScroll = PlayerGui.NewGui.MainFrames.UpgradesFrame.UpgradesBackground.ScrollingFrame
					
				while UpgradeEnabled do
                   task.wait(1)

				   for _, child in ipairs(upgradeScroll:GetChildren()) do
						task.wait()
						local cashButton = child:FindFirstChild("CashButton")
						if cashButton and UpgradeEnabled then
							FireButton(cashButton)
						end
					end
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		if RebirthConnection then RebirthConnection:Disconnect() RebirthConnection = nil end
		if value then
			local rebirthFill = PlayerGui.NewGui.MainFrames.RebirthFrame.RebirthBackground.Bar.BarCanvas.Progress
			local rebirthButton = PlayerGui.NewGui.MainFrames.RebirthFrame.RebirthBackground.RebirthButton
			RebirthConnection = rebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
				if IsFillFull(rebirthFill) then
					FireButton(rebirthButton)
				end
			end)
			if IsFillFull(rebirthFill) then
				FireButton(rebirthButton)
			end
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
