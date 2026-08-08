local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local Enableds, Connections, Packets = {Throw = false, Upgrade = false, Sell = false, Buy = false}, {}, {}
local CoinName = "Basic Coin"
local UpgradeTypes, UpgradeActives, UpgradeInfos = {}, {AllEnabled = true}, {}
local UpgradeScroll = nil
local ThrowPosition = Vector3.new(-1162.03125, 0.72600001096725, -176.85087585449)

local CoinShopScroll, UpgradeScroll = nil, nil

local function FireButton(button)
	if firesignal then
		firesignal(button.MouseButton1Click)
	end
end

local function EquipCoin()
	CoinShopScroll = CoinShopScroll or PlayerGui:QueryDescendants("#UiFolder > #Main > #Frames > #CoinShop > #SFcontainer > #SF")[1]
	if not CoinShopScroll then return end

	for _, layer in ipairs(CoinShopScroll:GetChildren()) do
		local buyButton = layer:QueryDescendants("#Main > #ButtonContainer > #BuyButton")[1]
		if not buyButton then continue end
		
		local priceLabel = buyButton:FindFirstChild("PriceText")
		if priceLabel and priceLabel.Text:lower():find("equipped") then
			CoinName = layer.Name
			break
		end
		
		task.wait(0.1)
	end
end

local function HandleBuy()
	if not Enableds.Buy then return end
	CoinShopScroll = CoinShopScroll or PlayerGui:QueryDescendants("#UiFolder > #Main > #Frames > #CoinShop > #SFcontainer > #SF")[1]
	if not CoinShopScroll then return end
	
	task.spawn(function()
		local sortBuys = {}
		
		while Enableds.Buy do
			table.clear(sortBuys)

			for _, layer in ipairs(CoinShopScroll:GetChildren()) do
				if not Enableds.Buy then break end
				
				if layer:IsA("GuiObject") then
					local buyButton = layer:QueryDescendants("#Main > #ButtonContainer > #BuyButton")[1]
					if not buyButton then continue end

					local frame = buyButton.Parent

					table.insert(sortBuys, {
						Name = layer.Name,
						Tier = layer.LayoutOrder,
						BuyButton = buyButton,
						PriceLabel = buyButton:FindFirstChild("PriceText"),
						LockButton = frame:FindFirstChild("LockButton"),
						RobuxButton = frame:FindFirstChild("RobuxPurchase"),
					})
					
					task.wait(0.1)
				end
			end
			
			if not Enableds.Buy then break end
			
			table.sort(sortBuys, function(a, b)
				return a.Tier < b.Tier
			end)

			for _, info in ipairs(sortBuys) do
				if not Enableds.Buy then break end
				
				local priceLabel, buyButton, lockButton, robuxButton = info.PriceLabel, info.BuyButton, info.LockButton, info.RobuxButton

				if priceLabel then 
					if lockButton and lockButton.Visible then continue end
					if robuxButton and not robuxButton.Visible then continue end

					if BuyCoinEnabled then
						FireButton(buyButton)
						task.wait(0.25)
					end
				end

				task.wait(0.1)
			end
			
			task.wait(1)
		end
		
		table.clear(sortBuys)
	end)
end

local function HandleThrow()
	if not Enableds.Throw then return end

	task.spawn(function()
		--[[
		game:GetService("Players").LocalPlayer.PlayerGui.UiFolder.Main.HUD.ThrowBar.CurrentMulti.Size.Y.Scale >= 1
		game:GetService("Players").LocalPlayer.PlayerGui.UiFolder.Main.HUD.Coin.ThrowCoin
		]]
		Packets.CoinThrow = Packets.CoinThrow or ReplicatedStorage:QueryDescendants("#Assets > #Events > #CoinThrow")[1]
		Packets.CoinLanded = Packets.CoinLanded or ReplicatedStorage:QueryDescendants("#Assets > #Events > #CoinLanded")[1]
		while Enableds.Throw do
			task.wait(0.5)
			Packets.CoinThrow:FireServer(CoinName,ThrowPosition)
			task.wait(0.25)
			Packets.CoinLanded:FireServer(2,ThrowPosition,CoinName,nil,nil)
		end
	end)

	task.spawn(function()
		while Enableds.Throw do
			EquipCoin()
			task.wait(5)
		end
	end)
end

local function HandleUpgrade()
	if not Enableds.Upgrade then return end
	task.spawn(function()
		while Enableds.Upgrade do
			for key, active in pairs(UpgradeActives) do
				if not Enableds.Upgrade then break end
				if UpgradeActives.AllEnabled then active = true end
				if key == "AllEnabled" or not active then continue end

				local list = UpgradeInfos[key]
				if not list then continue end

				if #list > 1 then
					for _, info in ipairs(list) do
						if not Enableds.Upgrade then break end

						local button = info.UpgradeButton
						if not button then continue end

						FireButton(button)
						task.wait(0.1)
					end
				else
					local info = list[1]
					if not info then continue end

					local button = info.UpgradeButton
					if not button then continue end

					FireButton(button)
				end
				task.wait(0.1)
			end
			task.wait(1)
		end
	end)
end

local function HandleSell()
	if not Enableds.Sell then return end
	Packets.SellAll = Packets.SellAll or ReplicatedStorage:QueryDescendants("#Assets > #Events > #SellAll")[1]
	task.spawn(function()
		while Enableds.Sell do
			Packets.SellAll:FireServer()
			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Throw a Coin",
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
	Text = "Auto Throw",
	Value = false,
	Flag = "throw_enabled",
	Callback = function(value)
		Enableds.Throw = value
		HandleThrow()
	end
})

local UpgradeDropdown = Window:AddDropdown({
	Text = "Upgrade Type (Empty = All)",
	Options = {"No Upgrade Type"},
	Option = {},
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
	Text = "Auto Buy",
	Value = false,
	Flag = "sell_enabled",
	Callback = function(value)
		Enableds.Buy = value
		HandleBuy()
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

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "YouTube: Tora IsMe",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 07-12-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

task.spawn(function()
	EquipCoin()
	
	UpgradeScroll = UpgradeScroll or PlayerGui:QueryDescendants("#UiFolder > #Main > #Frames > #Upgrades > #SFHolder")[1]

	if UpgradeScroll then
		local sortUpgrades = {}

		for _, layer in ipairs(UpgradeScroll:GetChildren()) do
			local buyButton = layer:QueryDescendants("#Main > #BuyButton")[1]
			if not buyButton then continue end

			local title = layer:QueryDescendants("#Main > #MultiplierName")[1]
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

		table.sort(sortUpgrades, function(a, b)
			return a.Tier < b.Tier
		end)

		for _, info in ipairs(sortUpgrades) do
			table.insert(UpgradeTypes, info.Name)
		end

		UpgradeDropdown.Options = #UpgradeTypes > 0 and UpgradeTypes or {"No Upgrade Type"}
		UpgradeDropdown:Refresh()
	end
end)
