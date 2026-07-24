local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Enableds, Connections = {["Click"] = false, ["Upgrade"] = false}, {}

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
	Name = "+1 Hack Per Click",
	Destroying = function()
	   for key, enabled in pairs(Enableds) do
		   Enableds[key] = false
	   end

       for key, connection in pairs(Connections) do
          if connection then
			  connection:Disconnect()
		  end
	   end
	end
})

Window:AddToggle({
	Text = "Auto Click",
	Value = false,
	Flag = "click_enabled",
	Callback = function(value)
		Enableds.Click = value
		if value then
			task.spawn(function()
				while Enableds.Click do
					ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.KickService.RF.AddKick:InvokeServer(nil)
					task.wait()
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Upgrade All",
	Value = false,
	Flag = "upgrade_enabled",
	Callback = function(value)
		Enableds.Upgrade = value
		if value  then
			task.spawn(function()
				local boostsScroll = PlayerGui.NewGui.MainFrames.BoostsFrame.BoostsBackground.BoostsInnerFrame
				
				while Enableds.Upgrade do
					task.wait(1)
							
					for _, child in ipairs(boostsScroll:GetChildren()) do
						task.wait()
						local cashButton = child:FindFirstChild("CashButton")
						if cashButton and Enableds.Upgrade then
							FireButton(cashButton)
						end
					end
				end
			end)
			task.spawn(function()
				local upgradeScroll = PlayerGui.NewGui.MainFrames.UpgradesFrame.UpgradesBackground.ScrollingFrame
					
				while Enableds.Upgrade do
                   task.wait(1)

				   for _, child in ipairs(upgradeScroll:GetChildren()) do
						task.wait()
						local cashButton = child:FindFirstChild("CashButton")
						if cashButton and Enableds.Upgrade then
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
		if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
		if value then
			local rebirthFill = PlayerGui.NewGui.MainFrames.RebirthFrame.RebirthBackground.Bar.BarCanvas.Progress
			local rebirthButton = PlayerGui.NewGui.MainFrames.RebirthFrame.RebirthBackground.RebirthButton
			Connections.Rebirth = rebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
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
