local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local UpgradeTypes, UpgradeActives = {"Damage", "Wins", "Luck"}, {}
local Enableds = {["Upgrade"] = false}
local Connections = {}
local Packets = {
	["BuyBoost"] = nil
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

Window:AddDropdown({
	Text = "Upgrade Type",
	Options = UpgradeTypes,
	Option = nil,
	MultipleOptions = true,
	Flag = "upgrade_options",
	Callback = function(option)
		for _, mode in ipairs(UpgradeTypes) do
			UpgradeActives[mode] = table.find(option, mode) ~= nil and true or false
		end
	end
})

Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Flag = "upgrade_enabled",
	Callback = function(value)
		Enableds.Upgrade = value
		if value then
			Packets.BuyBoost = Packets.BuyBoost or ReplicatedStorage:FindFirstChild("BuyBoost")
			
			task.spawn(function()	
				while Enableds.Upgrade do
					task.wait(0.5)
					for mode, active in pairs(UpgradeActives) do
						if not Enableds.Upgrade then break end
						if active then
							Packets.BuyBoost:InvokeServer(mode)
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
		
		game:GetService("Players").LocalPlayer.PlayerGui.NewGui.MainFrames.RebirthFrame.RebirthBackground.RebirthButton

game:GetService("Players").LocalPlayer.PlayerGui.NewGui.MainFrames.RebirthFrame.RebirthBackground.Bar.BarCanvas.Progress

			
		if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
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
