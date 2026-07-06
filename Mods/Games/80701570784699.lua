local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Utility/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local RebirthConnection, SellAddedConnection = nil, nil
local EggOptions, DecorOptions, PackOptions, SellOptions = {}, {}, {}, {}
local EggTypes, DecorTypes, PackTypes, SellTypes = {}, {}, {}, {}
local BuyEggEnabled, BuyDecorEnabled, BuyPackEnabled, SellEnabled, HatchEnabled = false, false, false, false, false
local HatchToggle = false

local Plot = nil

local function GetPlot(child)
	local current = child
	
	while current and current ~= workspace do
		if string.find(current.Name, "Plot_") and current.Parent and current.Parent.Name == "Tycoons" and current:FindFirstChild("PlacedItems") then
			break
		end
		current = current.Parent
	end
	
	return current
end

local function AutoHatch()
	if not HatchEnabled then return end
	if not Plot then HatchEnabled = false HatchToggle:Replace(false) return end
	
	task.spawn(function()
		while HatchEnabled do
			task.wait(1)
			local PlacedItems = Plot:FindFirstChild("PlacedItems")
			if PlacedItems then
				for _, egg in ipairs(PlacedItems:GetChildren()) do
					task.wait()
					local habitatEgg = egg:FindFirstChild("HabitatEgg")
					if habitatEgg then 
						local openPrompt = habitatEgg:FindFirstChild("OpenPrompt")
						if openPrompt then
							ReplicatedStorage.Packages.net["RE/BuildOpenEgg"]:FireServer(egg)
						end
					end
				end
				
			end
		end
	end)
end

local function GetBuyFrame(child)
	if child:IsA("Frame") and child:FindFirstChild("Buy") then
		return child
	end
	return nil
end

local function GetAllEggs()
	for _, child in ipairs(PlayerGui.Main.Shop.Canvas.Holder.Canvas.Scroll:GetChildren()) do
		task.wait()
		local frame = GetBuyFrame(child)
		if not frame then continue end
		if not table.find(EggTypes, frame.Name) then
			table.insert(EggTypes, frame.Name)
		end
		
	end
	
	return EggTypes
end

local function AutoBuyEgg()
	if not BuyEggEnabled then return end

	task.spawn(function()
		while BuyEggEnabled do
			task.wait(1)
			for _, child in ipairs(PlayerGui.Main.Shop.Canvas.Holder.Canvas.Scroll:GetChildren()) do
				task.wait()
				local frame = GetBuyFrame(child)
				if not frame then continue end
				if table.find(EggOptions, frame.Name) or #EggOptions == 0 then
					ReplicatedStorage.Packages.net["RE/PurchaseShop"]:FireServer(frame.Name)
					-- frame.Buy
				end
			end
		end
	end)
end

local function GetAllDecors()
	for _, child in ipairs(PlayerGui.Main.Decor.Canvas.Holder.Canvas.Scroll:GetChildren()) do
		task.wait()
		local frame = GetBuyFrame(child)
		if not frame then continue end
		if not table.find(DecorTypes, frame.Name) then
			table.insert(DecorTypes, frame.Name)
		end
	end

	return DecorTypes
end

local function AutoBuyDecor()
	if not BuyDecorEnabled then return end

	task.spawn(function()
		while BuyDecorEnabled do
			task.wait(1)
			for _, child in ipairs(PlayerGui.Main.Decor.Canvas.Holder.Canvas.Scroll:GetChildren()) do
				task.wait()
				local frame = GetBuyFrame(child)
				if not frame then continue end
				if table.find(DecorOptions, frame.Name) or #DecorOptions == 0 then
					ReplicatedStorage.Packages.net["RE/PurchaseDecor"]:FireServer(frame.Name)
					-- frame.Buy
				end
			end
		end
	end)
end

local function GetAllPacks()
	for _, child in ipairs(PlayerGui.Main.Packs.Canvas.Holder.Canvas.Scroll:GetChildren()) do
		task.wait()
		local frame = GetBuyFrame(child)
		if not frame then continue end
		if not table.find(PackTypes, frame.Name) then
			table.insert(PackTypes, frame.Name)
		end
	end

	return PackTypes
end

local function AutoBuyPack()
	if not BuyPackEnabled then return end

	task.spawn(function()
		while BuyPackEnabled do
			task.wait(1)
			for _, child in ipairs(PlayerGui.Main.Packs.Canvas.Holder.Canvas.Scroll:GetChildren()) do
				task.wait()
				local frame = GetBuyFrame(child)
				if not frame then continue end
				if table.find(DecorOptions, frame.Name) or #DecorOptions == 0 then
					ReplicatedStorage.Packages.net["RE/BuyPack"]:FireServer(frame.Name)
					-- frame.Buy
				end
			end
		end
	end)
end

local function AutoRebirth()
	-- game:GetService("Players").LocalPlayer.PlayerGui.Main.Rebirth.Canvas.Holder.Canvas.Need.Template.CanvasGroup.Ico.ImageColor3 == 255
	-- game:GetService("Players").LocalPlayer.PlayerGui.Main.Rebirth.Canvas.Holder.Canvas.Frame.Bar.Size.X.Scale

	local rebirthButton = PlayerGui.Main.Rebirth.Canvas.Holder.Canvas.Rebirth
	if rebirthButton.Visible == true then
		ReplicatedStorage.Packages.net["RE/Rebirth"]:FireServer()
	end

	RebirthConnection = rebirthButton:GetPropertyChangedSignal("Visible"):Connect(function()
		if rebirthButton.Visible == true then
			ReplicatedStorage.Packages.net["RE/Rebirth"]:FireServer()
		end
	end)
end

local function GetSellFrame(child)
	if child:IsA("Frame") and child:FindFirstChild("Sell") then
		return child
	end
	return nil
end

local SellTypeDropdown = nil

pcall(function()
	local SellCanvasScroll = PlayerGui.Main.Sell.Canvas.Holder.Canvas.Scroll
	
	SellAddedConnection = SellCanvasScroll.ChildAdded:Connect(function(child)
		local frame = GetSellFrame(child)
		if not frame then return end

		if not SellTypeDropdown then
			repeat task.wait() until SellTypeDropdown ~= nil
		end
		
		SellTypeDropdown:Add(frame.Name)
	end)
	
	for _, child in ipairs(SellCanvasScroll:GetChildren()) do
		task.wait()
		local frame = GetSellFrame(child)
		if not frame then continue end

		if not table.find(SellTypes, frame.Name) then
			table.insert(SellTypes, frame.Name)
		end
	end
	
	return nil
end)


local function AutoSell()
	-- game:GetService("Players").LocalPlayer.PlayerGui.Main.Sell.Canvas.Holder.SellAll
	-- game:GetService("Players").LocalPlayer.PlayerGui.Main.Sell.Canvas.Holder.Canvas.Scroll
	if not SellEnabled then return end
	task.spawn(function()
		while SellEnabled do
			task.wait(1)
			local CanSell=false
			for _, child in ipairs(PlayerGui.Main.Sell.Canvas.Holder.Canvas.Scroll:GetChildren()) do
				task.wait()
				local frame = GetSellFrame(child)
				if not frame or not frame.Visible then continue end
				if #SellOptions>0 and table.find(SellOptions, frame.Name) and SellEnabled then
					ReplicatedStorage.Packages.net["RE/Sell"]:FireServer(frame.Name)
					-- frame.Sell
				end
				CanSell = true
			end
			if CanSell and #SellOptions<=0 and SellEnabled then
				ReplicatedStorage.Packages.net["RE/Sell"]:FireServer()
			end
		end
	end)
end

-- Main UI --
local Window = UI:CreateWindow({
	Name = "My Dino Park",
	Destroying = function()
		BuyEggEnabled, BuyDecorEnabled, BuyPackEnabled, SellEnabled, HatchEnabled = false, false, false, false, false
		RebirthConnection = Utility.Cleanup(RebirthConnection)
		SellAddedConnection = Utility.Cleanup(SellAddedConnection)
	end
})

local PlotTargetSelect  
PlotTargetSelect = Window:AddSelect({
	Text = "Plot Target",
	Callback = function(target)
		local newPlot = GetPlot(target)
		if newPlot then
			PlotTargetSelect.Active = false
			PlotTargetSelect.Visible = false
			Plot = newPlot
		end
	end
})

HatchToggle = Window:AddToggle({
	Text = "Auto Hatch", 
	Value = false,
	Callback = function(value)
		HatchEnabled = value
		AutoHatch()
	end
})

Window:AddDropdown({
	Text = "Egg Types",
	Options = #EggTypes == 0 and GetAllEggs() or EggTypes,
	Option = nil,
	MultipleOptions = true,
	Callback = function(option)
		EggOptions = option
	end
})

Window:AddToggle({
	Text = "Buy Egg", 
	Value = false,
	Callback = function(value)
		BuyEggEnabled = value
		AutoBuyEgg()
	end
})

Window:AddDropdown({
	Text = "Decor Types",
	Options = #DecorTypes == 0 and GetAllDecors() or DecorTypes,
	Option = nil,
	MultipleOptions = true,
	Callback = function(option)
		DecorOptions = option
	end
})

Window:AddToggle({
	Text = "Buy Decor", 
	Value = false,
	Callback = function(value)
		BuyDecorEnabled = value
		AutoBuyDecor()
	end
})

Window:AddDropdown({
	Text = "Pack Types",
	Options = #PackTypes == 0 and GetAllPacks() or PackTypes,
	Option = nil,
	MultipleOptions = true,
	Callback = function(option)
		PackOptions = option
	end
})

Window:AddToggle({
	Text = "Buy Pack", 
	Value = false,
	Callback = function(value)
		BuyPackEnabled = value
		AutoBuyPack()
	end
})

SellTypeDropdown = Window:AddDropdown({
	Text = "Sell Types",
	Options = SellTypes,
	Option = nil,
	MultipleOptions = true,
	Callback = function(option)
		SellOptions = option
	end
})

Window:AddToggle({
	Text = "Auto Sell", 
	Value = false,
	Callback = function(value)
		SellEnabled = value
		AutoSell()
	end
})

Window:AddToggle({
	Text = "Auto Rebirth", 
	Value = false,
	Callback = function(value)
		RebirthConnection = Utility.Cleanup(RebirthConnection)
		if value then
			AutoRebirth()
		end
	end
})

-- Window:AddLabel("YouTube: Crokyreo")
