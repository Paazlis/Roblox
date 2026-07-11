local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Instancer = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Instancer/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local CoinName = "Basic Coin"
local CoinShopScroll, UpgradeScroll = nil, nil
local FarmEnabled, UpgradeAllEnabled, BuyCoinEnabled, SellEnabled = false, false, false, false

local function FireButton(button)
	if firesignal then
		firesignal(button.MouseButton1Click)
	end
end

local function SetCoinEquipped()
	CoinShopScroll = CoinShopScroll or PlayerGui.UiFolder.Main.Frames.CoinShop.SFcontainer.SF

	firesignal(game:GetService("Players").LocalPlayer.PlayerGui.UiFolder.Main.Frames.CoinShop.SFcontainer.SF["Fire Coin"].Main.ButtonContainer.BuyButton.MouseButton1Click)
	
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
				local lockButton = current.Parent:FindFirstChild("LockButton")
				local priceLabel = current:FindFirstChild("PriceText")
				if priceLabel then 
				    if lockButton and lockButton.Visible then continue end
					
					local priceText = string.lower(priceLabel.Text)

					local canBuy = false

					if not string.find(priceText, "equipped") and not string.find(priceText, "equip") then
						canBuy = true
					end

					if canBuy and BuyCoinEnabled then
						FireButton(current)

					    priceLabel:GetPropertyChangedSignal("Text"):Wait()

						if priceLabel.Text == "Equipped" then
							CoinName = child.Name
						end
					end
				end
			end
		end
	end
end

SetCoinEquipped()

local Window = UI:CreateWindow({
	Name = "Throw a Coin",
	Destroying = function()
		FarmEnabled, UpgradeAllEnabled, BuyCoinEnabled, SellEnabled = false, false, false, false
	end
})

Window:AddToggle({
	Text = "Auto Farm",
	Value = false,
	Flag = "farm_enabled",
	Callback = function(value)
		FarmEnabled = value
		if value then
			task.spawn(function()
				--game:GetService("Players").LocalPlayer.PlayerGui.UiFolder.Main.HUD.ThrowBar.CurrentMulti.Size.Y.Scale >= 1
				--game:GetService("Players").LocalPlayer.PlayerGui.UiFolder.Main.HUD.Coin.ThrowCoin

				local originalPosition = Vector3.new(-1162.03125, 0.72600001096725, -176.85087585449)

				while FarmEnabled do
					task.wait(2)
					ReplicatedStorage.Assets.Events.CoinThrow:FireServer(CoinName,originalPosition)
					task.wait(0.25)
					ReplicatedStorage.Assets.Events.CoinLanded:FireServer(2,originalPosition,CoinName,nil,nil)
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Upgrade All",
	Value = false,
	Flag = "upgrade_all_enabled",
	Callback = function(value)
		UpgradeAllEnabled = value
		if value then
			task.spawn(function()
				if not UpgradeScroll then
					UpgradeScroll = PlayerGui.UiFolder.Main.Frames.Upgrades.SFHolder
				end

				while UpgradeAllEnabled do
					task.wait(1)

					for _, child in ipairs(UpgradeScroll:GetChildren()) do
						task.wait()
						if child:IsA("Frame") then
							ReplicatedStorage.Assets.Events.RequestUpgrade:FireServer(child.Name)
						end
					end
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Buy Coin",
	Value = false,
	Flag = "buy_coin_enabled",
	Callback = function(value)
		BuyCoinEnabled = value
		if value then
			task.spawn(function()
				while BuyCoinEnabled do
					task.wait(2)
					SetCoinEquipped()
					BuyCoin()
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Auto Sell",
	Value = false,
	Flag = "sell_enabled",
	Callback = function(value)
		SellEnabled = value
		if value then
			task.spawn(function()
				while SellEnabled do
					task.wait(2)
					if SellEnabled then
						ReplicatedStorage.Assets.Events.SellAll:FireServer()
					end
				end
			end)
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
