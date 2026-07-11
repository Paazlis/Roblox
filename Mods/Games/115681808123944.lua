local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Instancer = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Instancer/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local CoinName = "Copper Coin"
local CoinShopScroll, UpgradeScroll = nil, nil
local FarmEnabled, UpgradeAllEnabled, BuyCoinEnabled, SellEnabled = false, false, false, false

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
	end
end

local function SetCoinEquipped()
	if not CoinShopScroll then
		CoinShopScroll = PlayerGui.UiFolder.Main.Frames.CoinShop.SFcontainer.SF
	end
	
	if CoinShopScroll then
		for _, child in ipairs(CoinShopScroll:GetChildren()) do
			local main = child:FindFirstChild("Main")
			if main then
				local buttonContainer = main:FindFirstChild("ButtonContainer")
				if buttonContainer then
					local buyButton = buttonContainer:FindFirstChild("BuyButton")
					if buyButton then
						local priceText = buyButton:FindFirstChild("PriceText")
						if priceText and priceText.Text == "Equipped" then
							CoinName = child.Name
							break
						end
					end
				end
			end
		end
	end
	
	--game:GetService("Players").LocalPlayer.PlayerGui.UiFolder.Main.Frames.CoinShop.SFcontainer.SF["Aether Coin"].Main.ButtonContainer.BuyButton
	--game:GetService("Players").LocalPlayer.PlayerGui.UiFolder.Main.Frames.CoinShop.SFcontainer.SF["Basic Coin"].Main.ButtonContainer.BuyButton.PriceText
	--Equip, Equipped
end

local function BuyCoin()
	if CoinShopScroll then
		for _, child in ipairs(CoinShopScroll:GetChildren()) do
			if not (child and child.Parent) then continue end
			
			local main = child:FindFirstChild("Main")
			if not main then continue end
			
			local buttonContainer = main:FindFirstChild("ButtonContainer")
			if not buttonContainer then continue end
			
			local buyButton = buttonContainer:FindFirstChild("BuyButton")
			if not (buyButton and buyButton.Visible) then continue end
			
			local priceText = buyButton:FindFirstChild("PriceText")
			if not priceText then continue end
			
			if priceText.Text == "Equipped" or priceText.Text == "Equip" then continue end
			
			task.wait(2)
			FireButton(buyButton)
			task.wait(1)
			if priceText.Text == "Equipped" then
				CoinName = child.Name
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
				
				local OriginalPosition = Vector3.new(-1162.03125, 0.72600001096725, -176.85087585449)
				
				while FarmEnabled do
					task.wait()
					ReplicatedStorage.Assets.Events.CoinThrow:FireServer(CoinName,OriginalPosition)
					task.wait(0.1)
					ReplicatedStorage.Assets.Events.CoinLanded:FireServer(2,OriginalPosition,CoinName,nil,nil)
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
					for _, child in ipairs(UpgradeScroll:GetChildren()) do
						task.wait()
						ReplicatedStorage.Assets.Events.RequestUpgrade:FireServer(child.Name)
					end
					
					task.wait(2)
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
					SetCoinEquipped()
					task.wait()
					BuyCoin()
					task.wait(2)
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
					ReplicatedStorage.Assets.Events.SellAll:FireServer()
				end
			end)
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
