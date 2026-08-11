local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local Enableds, Connections, Packets = {["Click"] = false, ["Upgrade"] = false, ["Rebirth"] = false}, {}, {}
local BoostsScroll = nil
local UpgradeScroll = nil
local RebirthFrame, RebirthFill, RebirthButton = nil, nil, nil

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

local function HandleClick()
	if not Enableds.Click then return end
	Packets.AddKick = Packets.AddKick or ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.KickService.RF.AddKick
	task.spawn(function()
		while Enableds.Click do
			Packets.AddKick:InvokeServer(nil)
			task.wait()
		end
	end)
end

local function HandleUpgrade()
	if not Enableds.Upgrade then return end
	task.spawn(function()
		BoostsScroll = BoostsScroll or PlayerGui:QueryDescendants("#NewGui > #MainFrames > #BoostsFrame > #BoostsBackground > #BoostsInnerFrame")[1]
		while Enableds.Upgrade do
			for _, layer in ipairs(BoostsScroll:GetChildren()) do
				if not Enableds.Upgrade then break end
				local buyButton = layer:FindFirstChild("CashButton")
				if not buyButton then continue end
				FireButton(buyButton)
				task.wait(0.1)
			end
			
		end
	end)
	task.spawn(function()
		UpgradeScroll = UpgradeScroll or PlayerGui:QueryDescendants("#NewGui > #MainFrames > #UpgradesFrame > #UpgradesBackground > #ScrollingFrame")[1] 
		while Enableds.Upgrade do
			for _, layer in ipairs(UpgradeScroll:GetChildren()) do
				if not Enableds.Upgrade then break end
				local buyButton = layer:FindFirstChild("CashButton")
				if not buyButton then continue end
				FireButton(buyButton)
				task.wait(0.1)
			end
			task.wait(1)
		end
	end)
end

local function HandleRebirth()
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end
	RebirthFrame = RebirthFrame or PlayerGui:QueryDescendants("#NewGui > #MainFrames > #RebirthFrame > #RebirthBackground")[1]
	if RebirthFrame then
		RebirthFill = RebirthFill or RebirthFrame:QueryDescendants("#Bar > #BarCanvas > #Progress")[1]
		RebirthButton = RebirthButton or RebirthFrame:FindFirstChild("RebirthButton")
	end
	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
		if IsFillFull(RebirthFill) then
			FireButton(RebirthButton)
		end
	end)
	task.spawn(function()
		while Enableds.Rebirth do
			if IsFillFull(RebirthFill) then
				FireButton(RebirthButton)
			end
			task.wait(1)
		end
	end)
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
		HandleClick()
	end
})

Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Flag = "upgrade_enabled",
	Callback = function(value)
		Enableds.Upgrade = value
		HandleUpgrade()
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		Enableds.Rebirth = value
		HandleRebirth()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255),
})

Window:AddLabel({
	Text = "Date: 07-10-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255),
})
