local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local Enableds, Connections = {["Upgrade"] = false, ["Rebirth"] = false}, {}
local UpgradeTypes, UpgradeActives, UpgradeInfos = {}, {["AllEnabled"] = true}, {}
local RebirthFrame, RebirthFill, RebirthButton = nil, nil, nil

local UpgradeScroll = PlayerGui:QueryDescendants("#HUD > #MugUpgrades")[1]

if UpgradeScroll then
	local sortUpgrades = {}

	for _, layer in ipairs(UpgradeScroll:GetChildren()) do
		if layer and layer.Parent and layer:IsA("GuiObject") then
			local buyButton = layer:QueryDescendants("#BuyMain > #Cash")[1]
			if not buyButton then continue end

			local title = layer:FindFirstChild("Title")
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
	return fill.Size.X.Scale >= 1
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

local function FireRebirth()
	if IsFillFull(RebirthFill) and Enableds.Rebirth then
		FireButton(RebirthButton)
	end
end

local function HandleRebirth()
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end

	RebirthFrame = RebirthFrame or PlayerGui:QueryDescendants("#Frames > #Rebirth")[1]

	if RebirthFrame then
		RebirthFill = RebirthFill or RebirthFrame:QueryDescendants("#BarHolder > #Bar")[1]
		RebirthButton = RebirthButton or RebirthFrame:QueryDescendants("#Main > #Buttons > #Rebirth")[1]
	end

	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(FireRebirth)

	task.spawn(function()
		while Enableds.Rebirth do
			FireRebirth()
			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Idle Ball Bounce", 
	Destroying = function()
		for key, _ in pairs(Enableds) do
			Enableds[key] = false
		end
		for _, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end
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
			UpgradeActives[mode] = table.find(option, mode) ~= nil
		end
		UpgradeActives["AllEnabled"] = #option <= 0
	end
})

Window:AddToggle({
	Style = "2",
	Text = "Auto Upgrade",
	Value = false,
	Flag = "upgrade_enabled",
	Callback = function(value)
		Enableds.Upgrade = value
		HandleUpgrade()
	end
})

Window:AddToggle({
	Style = "2",
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		Enableds.Rebirth = value
		HandleRebirth()
	end
})

Window:AddLabel({ Text = "YouTube: Crokyreo", TextColor3 = Color3.fromRGB(255, 255, 255) })
Window:AddLabel({ Text = "Date: 08-18-2026", TextColor3 = Color3.fromRGB(255, 255, 255) })
