local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager = Services.VirtualInputManager
local UserInputService = Services.UserInputService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections, Packets = {["Click"] = false, ["Upgrade"] = false, ["Rebirth"] = false}, {}, {}
local ClickPoint = Vector2.new(500, 500)
local RebirthDebounce = false
local UpgradeTypes, UpgradeActives, UpgradeInfos = {}, {["AllEnabled"] = true}, {}
local UpgradeFailColor3 = Color3.fromRGB(244, 67, 54)

task.delay(2, function()
	ClickPoint = UserInputService:GetMouseLocation()
end)

local LuckyBlockCloseButton = PlayerGui:QueryDescendants("#LuckyBlock > #EndBrainrotFrame > #FinalBrainrotFrame > #Close")[1]
local UpgradeScroll = PlayerGui:QueryDescendants("#Main > #UpgradesBackground > #ScrollingFrame")[1]
local CheckRebirth = nil
local AutoClickButton, AutoClickTimeLabel = nil, nil

if UpgradeScroll then
	local sortUpgrades = {}

	for _, layer in ipairs(UpgradeScroll:GetChildren()) do
		if layer and layer.Parent and layer:IsA("GuiObject") then
			local buyButton = layer:FindFirstChild("BuyButton")
			if not buyButton then continue end

			local lockedFrame = layer:FindFirstChild("LockedFrame")
			if not lockedFrame then continue end

			local key = layer.Name

			if UpgradeActives[key] == nil then
				UpgradeActives[key] = false
				UpgradeInfos[key] = {
					UpgradeButton = buyButton,
					LockedFrame = lockedFrame,
				}
				table.insert(sortUpgrades, {
					Name = key,
					Tier = layer.LayoutOrder,
				})
			end
		end
	end

	table.sort(sortUpgrades, function(a, b)
		return a.Tier < b.Tier
	end)

	for _, info in ipairs(sortUpgrades) do
		table.insert(UpgradeTypes, info.Name)
	end

	table.sort(sortUpgrades, function(a, b)
		return a.Tier > b.Tier
	end)
end

local function SendClick(x,y)
	VirtualInputManager:SendMouseButtonEvent(x,y,0,true,game,0)
	task.wait()
	VirtualInputManager:SendMouseButtonEvent(x,y,0,false,game,0)
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

local function IsFillFull(fill)
	if fill.Size.X.Scale >= 1 then
		return true
	end
	return false
end

-- Click Function --
local function HandleClick(info)
	if Connections.ClickTimeChanged then Connections.ClickTimeChanged:Disconnect() Connections.ClickTimeChanged = nil end
	if not Enableds.Click then return end
	Packets.Click = Packets.Click or ReplicatedStorage:QueryDescendants("#Remotes > #ClickBrainrot")[1]
	AutoClickButton = AutoClickButton or PlayerGui:QueryDescendants("#Main > #AutoClickerButton")[1]
	AutoClickTimeLabel = AutoClickTimeLabel or PlayerGui:QueryDescendants("#Main > #AutoClickerButton > #TimeLabel")[1]
	if AutoClickButton and AutoClickTimeLabel then
		Connections.ClickTimeChanged = AutoClickTimeLabel:GetPropertyChangedSignal("Text"):Connect(function()
			if AutoClickTimeLabel.Text == "Ready" and Enableds.Click then
				FireButton(AutoClickButton)
			end
		end)
		if AutoClickTimeLabel.Text == "Ready" and Enableds.Click then
			FireButton(AutoClickButton)
		end
	end
	task.spawn(function()
		while Enableds.Click do
			Packets.Click:FireServer(1)
			task.wait()
		end
	end)
end

-- Upgrade Function --
local function FireUpgrade(info)
	if not Enableds.Upgrade then return end
	local lockedFrame = info.LockedFrame
	if lockedFrame and lockedFrame.Visible == true then return end
	local button = info.UpgradeButton
	if button then 
		if button.ImageColor3 == UpgradeFailColor3 then return end
		FireButton(button)
	end
end

local function HandleUpgrade()
	if not Enableds.Upgrade then return end
	task.spawn(function()
		while Enableds.Upgrade do
			for key, active in pairs(UpgradeActives) do
				if not Enableds.Upgrade then break end
				if key == "AllEnabled" then continue end
				if UpgradeActives.AllEnabled then active = true end
				if not active then continue end
				local info = UpgradeInfos[key]
				if not info then continue end
				FireUpgrade(info)
				task.wait()
			end
			task.wait()
		end
	end)
end

-- Rebirth Function --
local function FireRebirth()
	if Enableds.Rebirth and CheckRebirth.ImageColor3 ~= UpgradeFailColor3 then
		if RebirthDebounce then return end
		RebirthDebounce = true
		Packets.Rebirth:InvokeServer()
		task.wait(0.5)
		for i = 1, 7 do
			SendClick(ClickPoint.X, ClickPoint.Y)
		end
		task.wait(0.5)
		if LuckyBlockCloseButton then
			FireButton(LuckyBlockCloseButton)
		end
		RebirthDebounce = false
	end
end

local function HandleRebirth()
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end
	CheckRebirth = CheckRebirth or PlayerGui:QueryDescendants("#Main > #RebirthBackground > #RebirthButtons > #UpgradeRebirthButton")[1]
	Packets.Rebirth = Packets.Rebirth or ReplicatedStorage:QueryDescendants("#Remotes > #Rebirth")[1]
	Connections.Rebirth = CheckRebirth:GetPropertyChangedSignal("ImageColor3"):Connect(FireButton)
	task.spawn(function()
		while Enableds.Rebirth do
			FireRebirth()
			task.wait()
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Phonk Clicker",
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
	Callback = function(value)
		Enableds.Click = value
		HandleClick()
	end
})

Window:AddDropdown({
	Text = "Upgrade Type (Empty = All)",
	Options = #UpgradeTypes > 0 and UpgradeTypes or {"No Upgrade Type"},
	Option = nil,
	MultipleOptions = true,
	Flag = "upgrade_options",
	Callback = function(option)
		for _, mode in ipairs(UpgradeTypes) do
			UpgradeActives[mode] = table.find(option, mode) ~= nil and true or false
		end
		UpgradeActives["AllEnabled"] = #option <= 0
	end
})

Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Callback = function(value)
		Enableds.Upgrade = value
		HandleUpgrade()
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Callback = function(value)
		Enableds.Rebirth = value
		HandleRebirth()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

--[[
game:GetService("Players").LocalPlayer.PlayerGui.Main.UpgradesBackground.RebirthButton
game:GetService("Players").LocalPlayer.PlayerGui.Main.UpgradesBackground.RebirthButton.BuyButton.ImageColor3 == 112, 255, 73



game:GetService("Players").LocalPlayer.PlayerGui.Main.RebirthBackground.RebirthButtons.RebirthButton
game:GetService("Players").LocalPlayer.PlayerGui.Main.RebirthBackground.RequirementsFrame.MoneyNeededBG.Bar
]]
