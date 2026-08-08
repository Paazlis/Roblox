local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local CoinName = "Basic Coin"
local CoinShopScroll, UpgradeScroll = nil, nil
local FarmEnabled, UpgradeAllEnabled, BuyCoinEnabled, SellEnabled = false, false, false, false

local Enableds, Connections, Packets = {Throw = false, Upgrade = false, Sell = false}, {}, {}

local UpgradeTypes, UpgradeActives, UpgradeInfos = {}, {AllEnabled = true}, {}
local UpgradeScroll = nil
local ThrowPosition = Vector3.new(-1162.03125, 0.72600001096725, -176.85087585449)

local function FireButton(button)
	if firesignal then
		firesignal(button.MouseButton1Click)
	end
end

local function SetCoinEquipped()
	CoinShopScroll = CoinShopScroll or PlayerGui.UiFolder.Main.Frames.CoinShop.SFcontainer.SF
	
	for _, child in ipairs(CoinShopScroll:GetChildren()) do
		if child and child.Parent and child:IsA("Frame") then
		    local current = child
			for _, str in ipairs(string.split("Main.ButtonContainer.BuyButton",".")) do
               local value = current:FindFirstChild(str)
			   if value then
				  current = value
			   end
			end
			
			if current and current.Name == "BuyButton" then
               local priceLabel = current:FindFirstChild("PriceText")
			   if priceLabel and priceLabel.Text:lower():find("equipped") then
				   CoinName = child.Name
				   break
				end
			end
		end
	end

	--game:GetService("Players").LocalPlayer.PlayerGui.UiFolder.Main.Frames.CoinShop.SFcontainer.SF["Aether Coin"].Main.ButtonContainer.BuyButton
	--game:GetService("Players").LocalPlayer.PlayerGui.UiFolder.Main.Frames.CoinShop.SFcontainer.SF["Basic Coin"].Main.ButtonContainer.BuyButton.PriceText
	--Equip, Equipped
end

local function BuyCoin()
	CoinShopScroll = CoinShopScroll or PlayerGui.UiFolder.Main.Frames.CoinShop.SFcontainer.SF

	for _, child in ipairs(CoinShopScroll:GetChildren()) do
		if child and child.Parent and child:IsA("Frame") then
			local current = child
			for _, str in ipairs(string.split("Main.ButtonContainer.BuyButton",".")) do
               local value = current:FindFirstChild(str)
			   if value then
				  current = value
			   end
			end
			
			if current and current.Name == "BuyButton" then
				local robuxPurchase current.Parent:FindFirstChild("RobuxPurchase")
				local lockButton = current.Parent:FindFirstChild("LockButton")
				local priceLabel = current:FindFirstChild("PriceText")
				if priceLabel then 
				    if lockButton and lockButton.Visible then continue end
					if robuxPurchase and not robuxPurchase.Visible then continue end
					
					if BuyCoinEnabled then
						FireButton(current)
					end
				end
			end
		end
	end
end

local function HandleThrow()
	if not Enableds.Throw then return end

	task.spawn(function()
		--[[
		game:GetService("Players").LocalPlayer.PlayerGui.UiFolder.Main.HUD.ThrowBar.CurrentMulti.Size.Y.Scale >= 1
		game:GetService("Players").LocalPlayer.PlayerGui.UiFolder.Main.HUD.Coin.ThrowCoin
		]]
		Packets.CoinThrow = Packets.CoinThrow or ReplicatedStorage.Assets.Events.CoinThrow
	    Packets.CoinLanded = Packets.CoinLanded or ReplicatedStorage.Assets.Events.CoinLanded
		while Enableds.Throw do
			task.wait(0.5)
			Packets.CoinThrow:FireServer(CoinName,ThrowPosition)
			task.wait(0.25)
			Packets.CoinLanded:FireServer(2,originalPosition,CoinName,nil,nil)
		end
	end)

	task.spawn(function()
        while Enableds.Throw do
            task.wait(1)
			SetCoinEquipped()
		end
   end)
end

local function HandleUpgrade()
	if not Enableds.Upgrade then return end

	task.spawn(function()
		while Enableds.Upgrade do
			for key, active in pairs(UpgradeActives) do
				if not Enableds.Upgrade then break end
				if UpgradeActives.AllEnabled == true then active = true end
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
	Packets.SellAll = Packets.SellAll or ReplicatedStorage.Assets.Events.SellAll
	task.spawn(function()
		while Enableds.Sell do
			Packets.SellAll:FireServer()
			task.wait(1)
		end
	end)
end

SetCoinEquipped()

local Window = UI:CreateWindow({
	Name = "Throw a Coin",
	Destroying = function()
		FarmEnabled, UpgradeAllEnabled, BuyCoinEnabled, SellEnabled = false, false, false, false
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
	Text = "Date: 00-00-0000",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

task.spawn(function()
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
