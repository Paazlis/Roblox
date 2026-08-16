local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Packets = {
	["Click"] = ReplicatedStorage:QueryDescendants("#Remotes > #Events > #ClickRemote")[1]
}
local Enableds, Connections = {["Click"] = false, ["Upgrade"] = false, ["Rebirth"] = false}, {}
local UpgradeTypes, UpgradeActives, UpgradeInfos = {}, {["AllEnabled"] = true}, {}

local RebirthFrame, RebirthFill, RebirthButton = PlayerGui:QueryDescendants("#MainGui > #RebirthMenu")[1], nil, nil
if RebirthFrame then
	RebirthFill = RebirthFrame:QueryDescendants("#ProgressBar > #BarFill")[1]
	RebirthButton = RebirthFrame:QueryDescendants("TextButton#RebirthButton, ImageButton#RebirthButton")[1]
end

local UpgradeScroll = PlayerGui:QueryDescendants("#MainGui > #UpgradesMenu > #UpgradeScrollFrame")[1]
if UpgradeScroll then
	local sortUpgrades = {}
	
	for _, upgradeLayer in ipairs(UpgradeScroll:GetChildren()) do
		if upgradeLayer:IsA("GuiObject") then
			local upgradeTitle = upgradeLayer:FindFirstChild("UpgradeName")
			if not upgradeTitle then continue end
			table.insert(sortUpgrades, {
				Name = upgradeTitle.Text,
				Tier = upgradeLayer.LayoutOrder,
				UpgradeButton = upgradeLayer:FindFirstChild("BuyWinButton")
			})
		end
	end
	
	table.sort(sortUpgrades, function(a, b)
		return a.Tier < b.Tier
	end)
	
	for _, upgradeStats in ipairs(sortUpgrades) do
		table.insert(UpgradeTypes, upgradeStats.Name)
		UpgradeInfos[upgradeStats.Name] = upgradeStats
		UpgradeActives[upgradeStats.Name] = false
	end
end

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
	task.spawn(function()
		while Enableds.Click do
			Packets.Click:FireServer()
			task.wait()
		end
	end)
end

local function HandleUpgrade()
	if not Enableds.Upgrade then return end
	task.spawn(function()
		while Enableds.Upgrade do
			for mode, active in pairs(UpgradeActives) do
				task.wait(0.1)
				if not Enableds.Upgrade then break end
				if mode == "AllEnabled" then continue end
				if UpgradeActives.AllEnabled then active = true end
				if not active then continue end
				local upgradeStats = UpgradeInfos[mode]
				if not upgradeStats then continue end
				local upgradeButton = upgradeStats.UpgradeButton
				if not upgradeButton then continue end
				FireButton(upgradeButton)
			end
			task.wait(0.5)
		end
	end)
end

local function FireRebirth()
    if Enableds.Rebirth and IsFillFull(RebirthFill) then
		FireButton(RebirthButton)
	end
end

local function HandleRebirth()
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
    if not Enableds.Rebirth then return end
	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(FireRebirth)
	if Enableds.Rebirth then
		task.spawn(function()
			while Enableds.Rebirth do
				FireRebirth()
				task.wait(0.5)
			end
		end)
	end
end

local Window = UI:CreateWindow({
	Name = "+1 Follower Per Click",
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
	Text = "Fast Click",
	Value = false,
	Flag = "click_enabled",
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
		UpgradeActives.AllEnabled = #option <= 0
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
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 07-29-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
