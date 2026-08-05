local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Packets = {}
local Enableds, Connections = {NAME = false}, {}

local RebirthFrame, RebirthFill, RebirthButton = nil, nil, nil
local UpgradeScroll = PlayerGui:QueryDescendants("#UpgradesGUI > #Upgrades > #Background > #ScrollingFrame")[1]
local UpgradeTypes, UpgradeActives, UpgradeInfos = {}, {}, {}
UpgradeActives["AllEnabled"] = true

if UpgradeScroll then
	local sortUpgrades = {}

	for _, layer in ipairs(UpgradeScroll:GetChildren()) do
		if layer and layer.Parent and layer:IsA("GuiObject") then
			local contentFrame = layer:FindFirstChild("Content")
			if not contentFrame then continue end
			
			local buyButton = contentFrame:FindFirstChild("BuyButton")
			if not buyButton then continue end

			local title = contentFrame:FindFirstChild("Name")
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

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function IsFillMoveFull(fill)
	if fill.Position.X.Scale >= 1 then
		return true
	end
	return false
end

local function HandleClick()
	if not Enableds.Click then return end

	Packets.Click = Packets.Click or ReplicatedStorage.Packages._Index["acecateer_knit@1.7.2"].knit.Services.StrengthService.RE.ClickRequested

	task.spawn(function()
		while Enableds.Click do
			Packets.Click:FireServer()
			task.wait(1)
		end
	end)
end

local function HandleSell()
	if not Enableds.Sell then return end

	Packets.Sell = Packets.Sell or ReplicatedStorage.Packages._Index["acecateer_knit@1.7.2"].knit.Services.DataService.RF.SellAllBackpackLoot
	
	task.spawn(function()
		while Enableds.Sell do
			Packets.Sell:InvokeServer()
			task.wait(1)
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
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end

	RebirthFrame = RebirthFrame or PlayerGui:QueryDescendants("#RebirthGUI > #Rebirth > #Background")[1]

	if RebirthFrame then
		RebirthFill = RebirthFill or RebirthFrame:QueryDescendants("#Midleground > #Bar > #BarFill")[1]
		RebirthButton = RebirthButton or RebirthFrame:FindFirstChild("RebirthButton")
	end

	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
		if IsFillMoveFull(RebirthFill) and Enableds.Rebirth then
			FireButton(RebirthButton)
		end
	end)

	task.spawn(function()
		while Enableds.Rebirth do
			if IsFillMoveFull(RebirthFill) then
				FireButton(RebirthButton)
			end
			task.wait(0.5)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "+1 Cut Grass Adventure",
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
	Text = "Auto Sell",
	Value = false,
	Flag = "sell_enabled",
	Callback = function(value)
		Enableds.Sell = value
		HandleSell()
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
	Text = "Date: 08-06-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
