local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local ClickEnabled, BuyBoostsEnabled = false, false
local RebirthConnection = nil

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function IsFillFull(fill)
	if fill.Size.X.Scale >= 1 and fill.Size.X.Scale <= 0.98 then
		return true
	end
	return false
end

local Window = UI:CreateWindow({
	Name = "+1 Hack Per Click",
	Destroying = function()
		ClickEnabled, BuyBoostsEnabled = false, false
		if RebirthConnection then RebirthConnection:Disconnect() RebirthConnection = nil end
	end
})

Window:AddToggle({
	Text = "Auto Click",
	Value = false,
	Flag = "click_enabled",
	Callback = function(value)
		ClickEnabled = value
		if value then
			task.spawn(function()
				while ClickEnabled do
					ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.KickService.RF.AddKick:InvokeServer(nil)
					task.wait(0.1)
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Buy Boosts",
	Value = false,
	Flag = "buy_boosts_enabled",
	Callback = function(value)
		BuyBoostsEnabled = value
		if value  then
			task.spawn(function()
				local boostsScroll = PlayerGui.NewGui.MainFrames.BoostsFrame.BoostsBackground.BoostsInnerFrame
				while BuyBoostsEnabled do
					task.wait(5)
					for _, boosts in ipairs(boostsScroll:GetChildren()) do
						task.wait()
						local cashButton = boosts:FindFirstChild("CashButton")
						if cashButton then
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
