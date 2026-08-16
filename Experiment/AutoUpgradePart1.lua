local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
-- https://www.roblox.com/asset-thumbnail/image?assetId=122115114205866&width=768&height=432&format=png
local UpgradeScroll = nil

local Enableds, Connections = {Upgrade = false}, {}
local UpgradeTypes, UpgradeActives, UpgradeInfos = {}, {AllEnabled = true}, {}

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
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

local Window = UI:CreateWindow({
	Name = "Auto Upgrade", 
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

task.spawn(function()
	UpgradeScroll = UpgradeScroll or PlayerGui:QueryDescendants("#Main > #Upgrades > #Main > #ScrollingFrame")[1]
	if UpgradeScroll then
		local sortUpgrades = {}

		for _, layer in ipairs(UpgradeScroll:GetChildren()) do
			if layer and layer.Parent and layer:IsA("GuiObject") then
				local buyButton = layer:FindFirstChild("BuyButton")
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
end)
