local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()
local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds = {["Upgrade"] = false, ["Cash"] = false, ["Stage"] = false, ["Sell"] = false, ["Rebirth"] = false, ["Place"] = false}

local Connections = {}

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(char)
	Character = char
end)

local Packets = {
	["RedeemCode"] = ReplicatedStorage:QueryDescendants("#Library > #Knit >> #Services > #CodeService > #RF > #TryRedeem")[1],
	["Sell"] = ReplicatedStorage:QueryDescendants("#Library > #Knit >> #Services > #ItemService > #RF > #TrySell")[1],
	["Rebirth"] = ReplicatedStorage:QueryDescendants("#Library > #Knit >> #Services > #RebirthService > #RF > #TryRebirth")[1],
	["UpgradeAnimal"] = ReplicatedStorage:QueryDescendants("#Library > #Knit >> #Services > #SlotService > #RF > #TryUpgradeItem")[1],
	["Upgrade"] = ReplicatedStorage:QueryDescendants("#Library > #Knit >> #Services > #UpgradeService > #RF > #TryUpgrade")[1],
	["PurchaseBoost"] = ReplicatedStorage:QueryDescendants("#Library > #Knit >> #Services > #BoostService > #RF > #TryPurchase")[1],
	["PlaceBest"] = ReplicatedStorage:QueryDescendants("#Library > #Knit >> #Services > #SlotService > #RF > #TryPlaceBest")[1],
	["CollectCash"] = ReplicatedStorage:QueryDescendants("#Library > #Knit >> #Services > #SlotService > #RF > #TryCollectCurrency")[1],
	["PurchasePickaxe"] = ReplicatedStorage:QueryDescendants("#Library > #Knit >> #Services > #PickaxeService > #RF > #TryPurchase")[1]
	-- Library.Knit.Knit.Services
}

local Interfaces = {
	["PickaxeScroll"] = PlayerGui:QueryDescendants("#PickaxeShop > #Frame > #Container")[1],
	["FoodScroll"] = PlayerGui:QueryDescendants("#BoostShop > #Frame > #Container")[1],
	["AnimalScroll"] = PlayerGui:QueryDescendants("#StoredItems > #Frame > #Container")[1],
	["UpgradeScroll"] = PlayerGui:QueryDescendants("#Upgrades > #Frame > #Upgrades")[1]
}

local TypesData = {
	["Code"] = {"DISCO"},
	["Upgrade"] = {"Upgrade", "Animal", "Buy Pickaxe", "Buy Food"},
	["Names"] = {},
	["Raritys"] = {}
}

local ActivesData = {
	["Names"] = {},
	["Raritys"] = {}
}

local InfosData = {
	["Pickaxe"] = {},
	["Food"] = {},
	["Upgrade"] = {}
}

local UpgradeActives = {["Upgrade"] = false, ["Animal"] = false, ["Buy Pickaxe"] = false, ["Buy Food"] = false}

if Interfaces.PickaxeScroll then
	local sortPickaxes = {}

	for _, layer in ipairs(Interfaces.PickaxeScroll:GetChildren()) do
		if layer and layer.Parent and layer:IsA("GuiObject") and layer.Visible then
			local actionButton = layer:QueryDescendants("#Buttons > #Action")[1]
			local cashButton = layer:QueryDescendants("#Buttons > #Currency")[1]
			local rebirthFrame = layer:FindFirstChild("Rebirth")
			if cashButton and actionButton and rebirthFrame then
				table.insert(sortPickaxes, {
					Name = layer.Name,
					Tier = layer.LayoutOrder,
					Button = cashButton,
					ActionFrame = actionButton,
					RebirthFrame = rebirthFrame
				})
			end
		end
	end

	table.sort(sortPickaxes, function(a, b)
		return a.Tier < b.Tier
	end)

	for _, info in ipairs(sortPickaxes) do
		table.insert(InfosData.Pickaxe, info)
	end
end

if Interfaces.FoodScroll then
	local sortFoods = {}

	for _, layer in ipairs(Interfaces.FoodScroll:GetChildren()) do
		if layer and layer.Parent and layer:IsA("GuiObject") and layer.Visible then
			local button = layer:QueryDescendants("#Buttons > #Currency")[1]
			local stock = layer:FindFirstChild("Stock")
			local title = layer:QueryDescendants("#DisplayName > #DisplayLabel")[1]
			if button and stock then
				table.insert(sortFoods, {
					Name = layer.Name,
					Tier = layer.LayoutOrder,
					Stock = stock,
					Button = button
				})
			end
		end
	end

	table.sort(sortFoods, function(a, b)
		return a.Tier < b.Tier
	end)

	for _, info in ipairs(sortFoods) do
		table.insert(InfosData.Food, info)
	end
end

local function FirePrompt(prompt)
	if fireproximityprompt then
		fireproximityprompt(prompt, 0)
	end
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

local AnimalFolder = nil
local Modules = {}

pcall(function()
	local animalDataModule = ReplicatedStorage.__DIRECTORY.Items
	Modules.AnimalData = require(cloneref and cloneref(animalDataModule) or animalDataModule:Clone())
end)

if Modules.AnimalData then
	for name, data in next, Modules.AnimalData do
		if ActivesData.Names[name] == nil then
			ActivesData.Names[name] = false
			table.insert(TypesData.Names, data)
		end
		if data.Rarity and ActivesData.Raritys[data.Rarity] == nil then
			ActivesData.Raritys[data.Rarity] = false
			table.insert(TypesData.Raritys, data.Rarity)
		end
	end
end

-- High To Low
-- Low To High
-- Selected Name

local Window = UI:CreateWindow({
	Name = "Rescue Animals", 
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
		Connections.CharacterAdded:Disconnect()
	end
})

local LastAnimalDrodown = nil

Interfaces.AnimalNameDropdown = Window:AddDropdown({
	Text = "Animal Name",
	Options = TypesData.Names > 0 and TypesData.Names or {"No Animal Name"},
	Option = nil,
	Multi = true,
	Callback = function(option)
		for _, mode in ipairs(TypesData.Upgrade) do
			ActivesData.Names[mode] = table.find(option, mode) ~= nil
		end
	end
})

Interfaces.AnimalNameDropdown = Window:AddDropdown({
	Text = "Animal Rarity",
	Options = TypesData.Raritys > 0 and TypesData.Raritys or {"No Animal Rarity"},
	Option = nil,
	Multi = true,
	Visible = false,
	Callback = function(option)
		for _, mode in ipairs(TypesData.Raritys) do
			ActivesData.Raritys[mode] = table.find(option, mode) ~= nil
		end
	end
})

Window:AddSelector({
	Text = "Animal Mode",
	Options = {"Animal Name", "Animal Rarity", "WIP 😂"},
	NoCap = true,
	Callback = function(value)
		if value == "Animal Rarity" then
			Interfaces.AnimalDropdown = Interfaces.AnimalRarityDropdown
		else
			Interfaces.AnimalDropdown = Interfaces.AnimalNameDropdown
		end
		if Interfaces.LastAnimalDropdown then
			Interfaces.LastAnimalDropdown.Visible = false
			Interfaces.LastAnimalDropdown = nil
		end
		if Interfaces.AnimalDropdown then
			Interfaces.LastAnimalDropdown = Interfaces.AnimalDropdown
			Interfaces.AnimalDropdown.Visible = true
		end
	end
})

Window:AddToggle({
	Text = "Auto Rescue",
	Value = false,
	Callback = function(value)
		Enableds.Rescue = value
		if not Enableds.Rescue then return end
		AnimalFolder = AnimalFolder or workspace.CASCHES.CLIENT_ITEMS
		task.spawn(function()
			while Enableds.Rescue do
				for _, animal in ipairs(AnimalFolder:GetChildren()) do
				if not Enableds.Rescue then break end
				if animal and animal.Parent then 
					local overheadGui = PlayerGui:QueryDescendants("#OverheadAttachment > #ItemInfo")[1]
					if not overheadGui then continue end

					local rarityLabel = overheadGui:FindFirstChild("Rarity")
					local nameLabel = overheadGui:FindFirstChild("ItemName")
					local mutationFrame = overheadGui:FindFirstChild("Mutations")

					local iceCube = animal:FindFirstChild("IceCube")
					if not iceCube then continue end

					if ActivesData.Raritys[rarityLabel.Text] or ActivesData.Names[nameLabel.Text] then
						local pickupPrompt = nil
						
						for _, prompt in ipairs(animal:GetDescendants()) do
							if prompt:IsA("ProximityPrompt") then
								pickupPrompt = prompt
								break
							end
						end
						
						repeat 
							Character:PivotTo(CFrame.new(Vector3.new(iceCube.PrimaryPart.Position.X, Character.PrimaryPart.Position.Y, iceCube.PrimaryPart.Position.Z)))
							task.wait(1)
							if pickupPrompt and pickupPrompt.Visible then
								FirePrompt(pickupPrompt)
								task.wait(0.2)
							end
						until not (Enableds.Rescue and iceCube.Parent)
					end
						
					task.wait(0.1)
				end
				
			end
			task.wait(1)
		end
	end)
end
})

Interfaces.CashToggle = Window:AddToggle({
	Text = "Collect Cash",
	Value = false,
	Callback = function(value)
		Enableds.Cash = value
		if not Enableds.Cash then return end
		if not Packets.CollectCash then
			Enableds.Cash = false
			Interfaces.CashToggle:Replace(false)
			return
		end
		task.spawn(function()
			while Enableds.Cash do
				Packets.CollectCash:InvokeServer()
				task.wait(1)
			end
		end)
	end
})

Interfaces.PlaceToggle = Window:AddToggle({
	Text = "Place Best Animal",
	Value = false,
	Callback = function(value)
		Enableds.Place = value
		if not Enableds.Place then return end
		if not Packets.PlaceBest then
			Enableds.Place = false
			Interfaces.PlaceToggle:Replace(false)
			return
		end
		task.spawn(function()
			while Enableds.Place do
				Packets.PlaceBest:InvokeServer()
				task.wait(3)
			end
		end)
	end
})

Interfaces.RebirthToggle = Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Callback = function(value)
		Enableds.Rebirth = value
		if not Enableds.Rebirth then return end
		Interfaces.RebirthFill = Interfaces.RebirthFill or PlayerGui:QueryDescendants("#Rebirth > #Frame > #Container > #Bar > #Fill")[1]
		Interfaces.RebirthButton = Interfaces.RebirthButton or PlayerGui:QueryDescendants("#Rebirth > #Frame > #Container > #RebirthBtn")[1]
		local success = false
		if Packets.Rebirth then
			success = true
		elseif Interfaces.RebirthButton then
			success = true
		end
		if not (Interfaces.RebirthFill and success) then
			Enableds.Rebirth = false
			Interfaces.RebirthToggle:Replace(false)
			return
		end
		task.spawn(function()
			while Enableds.Rebirth do
				if Interfaces.RebirthFill.Size.X.Scale >= 1 then
					if Packets.Rebirth then
						Packets.Rebirth:InvokeServer()
					else
						FireButton(Interfaces.RebirthButton)
					end
				end
				task.wait()
			end
		end)
	end
})

Window:AddDropdown({
	Text = "Upgrade Type",
	Options = #TypesData.Upgrade > 0 and TypesData.Upgrade or {"No Upgrade Type"},
	Option = nil,
	Multi = true,
	Callback = function(option)
		for _, mode in ipairs(TypesData.Upgrade) do
			UpgradeActives[mode] = table.find(option, mode) ~= nil
		end
		UpgradeActives.AllEnabled = #option <= 0
	end
})

Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Callback = function(value)
		Enableds.Upgrade = value
		if not Enableds.Upgrade then return end

		task.spawn(function()
			while Enableds.Upgrade do
				if Interfaces.UpgradeScroll and Packets.Upgrade and (UpgradeActives["Upgrade"] or UpgradeActives.AllEnabled) then
					for _, layer in ipairs(Interfaces.UpgradeScroll:GetChildren()) do
						if not Enableds.Upgrade then break end
						if layer and layer.Parent and layer:IsA("GuiObject") and layer.Visible and (UpgradeActives["Upgrade"] or UpgradeActives.AllEnabled) then
							local key = layer.Name 
							local info = InfosData.Upgrade[key]
							if info == nil then
								info = {
									DisplayLabel = layer:QueryDescendants("#Information > #DisplayLabel")[1],
									Button = layer:QueryDescendants("#Buttons > #Currency")[1]
								}
								InfosData.Upgrade[key] = info
							end
						end
						task.wait()

					end
				end
				task.wait(0.5)
			end
		end)

		task.spawn(function()
			while Enableds.Upgrade do
				if UpgradeActives["Buy Pickaxe"] or UpgradeActives.AllEnabled then
					for _, info in ipairs(InfosData.Pickaxe) do
						if not Enableds.Upgrade then break end
						if UpgradeActives["Buy Pickaxe"] or UpgradeActives.AllEnabled then
							local rebirthFrame, actionFrame = info.RebirthFrame, info.ActionFrame
							local button = info.Button
							if button.Visible == true then
								if rebirthFrame.Visible == true then continue end
								if actionFrame.Visible == true then continue end
								if Packets.PurchasePickaxe then
									Packets.PurchasePickaxe:InvokeServer(info.Name)
								else
									FireButton(button)
								end
							end
						end
						task.wait()
					end
				end
				task.wait(0.5)
			end
		end)

		task.spawn(function()
			while Enableds.Upgrade do
				if UpgradeActives["Buy Food"] or UpgradeActives.AllEnabled then
					for _, info in ipairs(InfosData.Food) do
						if not Enableds.Upgrade then break end
						if UpgradeActives["Buy Food"] or UpgradeActives.AllEnabled then
							local text = string.gsub(info.Stock.Text:lower(), "stock:%s*", "")
							if not text or text:sub(1,1) == "0" then continue end
							FireButton(info.Button)
						end
						task.wait()
					end
				end
				task.wait(0.5)
			end
		end)

		task.spawn(function()
			while Enableds.Upgrade do
				if UpgradeActives["Animal"] or UpgradeActives.AllEnabled then
					if Interfaces.AnimalScroll and Packets.UpgradeAnimal then
						for _, layer in ipairs(Interfaces.AnimalScroll:GetChildren()) do
							if not (Enableds.Upgrade) then break end
							if layer and layer.Parent and layer:IsA("GuiObject") and layer.Visible and (UpgradeActives["Animal"] or UpgradeActives.AllEnabled) then
								local key = layer.Name
								local button = layer:QueryDescendants("#Buttons > #Upgrade")[1]
								if button ~= nil then
									if Packets.UpgradeAnimal then
										Packets.UpgradeAnimal:InvokeServer(key)
									else
										FireButton(button)
									end
								end
							end
							task.wait()
						end
					end
				end
				task.wait(0.5)
			end
		end)
	end
})

Interfaces.SellToggle = Window:AddToggle({
	Text = "Auto Sell",
	Value = false,
	Callback = function(value)
		Enableds.Sell = value
		if not Enableds.Sell then return end
		if not Packets.Sell then
			Enableds.Sell = false
			Interfaces.SellToggle:Replace(false)
			return
		end
		task.spawn(function()
			while Enableds.Sell do
				Packets.Sell:InvokeServer()
				task.wait(1)
			end
		end)
	end
})

Interfaces.CodeDropdown = Window:AddDropdown({
	Text = "Code List",
	Options = #TypesData.Code > 0 and TypesData.Code or {"No Code"},
	Option = nil,
	Multi = true,
	Callback = function(option) end
})

Window:AddButton({
	Text = "Redeem Code",
	MethodType = "DebounceClick",
	Callback = function(value)
		if Packets.RedeemCode then
			for _, code in ipairs(TypesData.Code) do
				Packets.RedeemCode:InvokeServer(code)
				task.wait(0.1)
			end
		end
	end
})

Window:AddLabel({ Text = "YouTube: Crokyreo", TextColor3 = Color3.fromRGB(255, 255, 255) })
Window:AddLabel({ Text = "YouTube: Tora IsMe", TextColor3 = Color3.fromRGB(255, 255, 255) })
Services.GuiService:SetGameplayPausedNotificationEnabled(false)
