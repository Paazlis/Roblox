local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local RebirthFrame, RebirthFill, RebirthButton = nil, nil, nil
local Packets = {}
local UpgradeTypes, UpgradeActives, UpgradeInfos = {}, {}, {}
UpgradeActives.AllEnabled = true

local UpgradeScroll = PlayerGui:QueryDescendants("#Main > #Upgrades > #Main > #ScrollingFrame")[1]
Packets.DataAction =  ReplicatedStorage:QueryDescendants("#Remotes > #DataAction")[1]

local WinsCFrame = CFrame.new(14.684351, 1.35249388, -2488.14941, 1, 0, 0, 0, 1, 0, 0, 0, 1)
local Enableds, Connections = {["Click"] = false, ["Wins"] = false, ["Upgrade"] = false, ["Rebirth"] = false}, {}

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

if UpgradeScroll then
	local sortUpgrades = {}

	for _, layer in ipairs(UpgradeScroll:GetChildren()) do
		if layer and layer.Parent and layer:IsA("GuiObject") then
			local buyButton = layer:FindFirstChild("Buy")
			if not buyButton then continue end

			local title = layer:QueryDescendants("#Improve > #Title")[1]
			if not title then continue end

			local key = title.Text
			
			if not UpgradeInfos[key] then
				UpgradeInfos[key] = {}
				UpgradeActives[key] = false
				table.insert(sortUpgrades, {
					Name = key,
					Tier = layer.LayoutOrder,
				})
			end

			table.insert(UpgradeInfos[key], {
				Name = key,
				UpgradeButton = buyButton
			})
		end
	end

	table.sort(sortUpgrades, function(a, b)
		return a.Tier < b.Tier
	end)

	for _, info in ipairs(sortUpgrades) do
		table.insert(UpgradeTypes, info.Name)
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

local function PlayerRequestStreamAroundAsync(position, timeOut)
	pcall(function()
		LocalPlayer:RequestStreamAroundAsync(position, timeOut)
	end)
end

local function HandleClick()
	if not Enableds.Click then return end

	task.spawn(function()
		while Enableds.Click do
			Packets.DataAction:FireServer("ClickReward", 660.81494140625, 74.296371459961)
			task.wait(0.5)
		end
	end)
end

local function HandleWins()
	if not Enableds.Wins then return end

	task.spawn(function()
		while Enableds.Wins do
			PlayerRequestStreamAroundAsync(WinsCFrame.Position, 5)
			Character:PivotTo(WinsCFrame)
			task.wait(0.5)
		end
	end)
end

local function HandleUpgrade()
	if not Enableds.Upgrade then return end

	task.spawn(function()
		while Enableds.Upgrade do
			for key, active in pairs(UpgradeActives) do
				if not Enableds.Upgrade then break end

				if key == "AllEnabled" then continue end
				if UpgradeActives.AllEnabled == true then active = true end
				if not active then continue end
				if not UpgradeActives[key] then continue end

				local list = UpgradeInfos[key]
				if not list then continue end

				if #list > 1 then
					for _, info in ipairs(list) do
						if not Enableds.Upgrade then break end

						local button = info.UpgradeButton
						if not button then continue end

						FireButton(button)
						task.wait(0.05)
					end
				else
					local info = list[1]
					if not info then continue end

					local button = info.UpgradeButton
					if not button then continue end

					FireButton(button)
				end

				task.wait(0.05)
			end
			task.wait(0.5)
		end
	end)
end

local function HandleRebirth()
	if not Enableds.Rebirth then return end

	RebirthFrame = PlayerGui:QueryDescendants("#Main > #Rebirth > #Main")[1]

	if RebirthFrame then
		RebirthFill = RebirthFill or RebirthFrame:QueryDescendants("#Bar > #Bar > #Bar")[1]
		RebirthButton = RebirthButton or RebirthFrame:QueryDescendants("#Buttons > #Rebirth")[1]
	end

	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
		if IsFillFull(RebirthFill) and Enableds.Rebirth then
			FireButton(RebirthButton)
		end
	end)

	task.spawn(function()
		while Enableds.Rebirth do
			if IsFillFull(RebirthFill) then
				FireButton(RebirthButton)
			end
			task.wait(0.5)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "+1 Kaiju Power Per Click",
	Destroying = function()
		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end

		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
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

Window:AddToggle({
	Text = "Wins Farm (Last Area)",
	Value = false,
	Flag = "wins_enabled",
	Callback = function(value)
		Enableds.Wins = value
		HandleWins()
	end
})

Window:AddDropdown({
	Text = "Upgrade Type (Empty = All)",
	Options = #UpgradeTypes > 0 and UpgradeTypes or {"No Upgrade Type"},
	Option = nil,
	MultipleOptions = true,
	Flag = "upgrade_options",
	Callback = function(option)
		UpgradeActives["AllEnabled"] = #option <= 0
		for _, mode in ipairs(UpgradeTypes) do
			UpgradeActives[mode] = table.find(option, mode) ~= nil and true or false
		end
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
