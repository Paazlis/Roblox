local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections, Packets = {["Advanced"] = false, ["Upgrade"] = false, ["Rebirth"] = false}, {}, {}
local UpgradeTypes, UpgradeActives, UpgradeInfos = {}, {["AllEnabled"] = true}, {}
local RebirthFrame, RebirthFill, RebirthButton = nil, nil, nil
local CarIndexScroll = PlayerGui:QueryDescendants("#Main > #Frames > #CarIndexFrame > #ScrollingFrame")[1]
local RollStands, RollPrompt = nil, nil
local PlacePrompt, PlacePart = nil, nil
local TollCache = {}
local CarIndexCache = {}

local MoneyValue = LocalPlayer:FindFirstChild("Money")

local BuyCache = {}

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

--[[
if CarIndexScroll then
	local function CarIndexAdded(layer)
		if layer and layer.Parent and layer:IsA("GuiObject") then
			local SortPrice = layer:GetAttribute("SortPrice")
			local UnequipButton = layer:FindFirstChild("UnequipButton")
			if not UnequipButton then return end
			if SortPrice == nil then return end

			if CarIndexCache[layer] == nil then
				CarIndexCache[layer] = {
					["UnequipButton"] = UnequipButton,
				}
			end
		end
	end
	
	Connections.CarIndexAdded = CarIndexScroll.ChildAdded:Connect(function(layer)
		task.wait(2)
		CarIndexAdded(layer)
	end)

	Connections.CarIndexRemoved = CarIndexScroll.ChildRemoved:Connect(function(layer)
		if CarIndexCache[layer] then
			CarIndexCache[layer] = nil
		end
	end)

	for _, layer in ipairs(CarIndexScroll:GetChildren()) do
		CarIndexAdded(layer)
	end
end
]]

local UpgradeScroll = PlayerGui:QueryDescendants("#UpgradeBoardGUI > #ScrollingFrame")[1]
if UpgradeScroll then
	for _, layer in ipairs(UpgradeScroll:GetChildren()) do
		if layer and layer.Parent and layer:IsA("GuiObject") then
			local buyButton = layer:FindFirstChild("UpgradeButton")
			if not buyButton then continue end

			local title = layer:FindFirstChild("DisplayName")
			if not title then continue end

			local key = title.Text

			if not UpgradeInfos[key] then
				UpgradeInfos[key] = {}
				UpgradeActives[key] = false
				table.insert(UpgradeTypes, key)
			end

			table.insert(UpgradeInfos[key], {
				Name = key,
				UpgradeButton = buyButton
			})
		end
	end
end

do
	UpgradeInfos["Toll"] = {}
	UpgradeActives["Toll"] = false
	table.insert(UpgradeTypes, "Toll")

	local function GuiAdded(gui)
		if gui and gui.Parent and gui.Name:find("TollUpgradeGUI_Line_") then
			local buyButton = gui:FindFirstChild("UpgradeButton")
			if not buyButton then return end

			local order = gui.Name:match("%d+") or ""

			table.insert(UpgradeInfos["Toll"], {
				Name = "Toll",
				UpgradeButton = buyButton,
				AlertGui = PlayerGui:FindFirstChild("TollAlertUpgradeGUI_Line_"..tostring(order))
			})
		end
	end

	Connections.GuiAdded = PlayerGui.ChildAdded:Connect(function(gui)
		task.wait(2)
		GuiAdded(gui)
	end)

	for _, gui in ipairs(PlayerGui:GetChildren()) do
		GuiAdded(gui)
	end
end

local RollScroll = PlayerGui:QueryDescendants("#Main > #Frames > #RollUpgradesFrame")[1]
if RollScroll then
	for _, layer in ipairs(RollScroll:GetChildren()) do
		if layer and layer.Parent and layer:IsA("GuiObject") then
			local buyButton = layer:FindFirstChild("UpgradeButton")
			if not buyButton then continue end

			local title = layer:FindFirstChild("Title")
			if not title then continue end

			local key = title.Text

			if not UpgradeInfos[key] then
				UpgradeInfos[key] = {}
				UpgradeActives[key] = false
				table.insert(UpgradeTypes, key)
			end

			table.insert(UpgradeInfos[key], {
				Name = key,
				UpgradeButton = buyButton
			})
		end
	end
end

local function GetPlot()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end

	for _, plot in ipairs(plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId ~= nil and ownerId == LocalPlayer.UserId then
			return plot
		end
	end

	return nil

end

local Plot = GetPlot()
if Plot then
	RollStands = Plot:FindFirstChild("RollStands")
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

local function IsFillFull(fill)
	if fill.Size.X.Scale >= 1 then
		return true
	end
	return false
end

--[[
local function HandlePlace()
	if not Enableds.Place then return end
	PlacePart = RollStands:QueryDescendants("#NewCars > #Base")[1]
	if PlacePart then
		PlacePrompt = PlacePart:QueryDescendants("#ProximityPrompt > #ProximityPrompt")[1]
	end
	task.spawn(function()
		local sortPlaces = {}
		local canPlace = false
		
		while Enableds.Place do
			if #BuyCache > 0 then
				local priceTarget = table.remove(BuyCache)
				if priceTarget ~= nil then
					table.clear(sortPlaces)
					canPlace = false
					for _, tool in ipairs(Backpack:GetChildren()) do
						if not Enableds.Place then break end
						local currentPrice = tool:GetAttribute("PurchasePrice") or 0
						if currentPrice ~= nil and currentPrice <= priceTarget then
							canPlace = true
							table.insert(sortPlaces, {
								Price = currentPrice,
								Tool = tool,
							})
							task.wait(0.05)
						end
					end
					
					if canPlace then
						local maxCar = 0
						
						for child, info in pairs(CarIndexCache) do
							if not Enableds.Place then break end
							local unequipButton = info.UnequipButton
							if unequipButton then
								FireButton(unequipButton)
							end
							maxCar += 1
						end
						if not Enableds.Place then break end
						task.wait(0.1)
						
						local humanoid : Humanoid = Character:FindFirstChildOfClass("Humanoid")
						local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
						local offset = PlacePart.Size.Y / 2
						local secondOffset = (rootPart.Size.Y/2) + humanoid.HipHeight
						local orientation = rootPart.Orientation
						Character:PivotTo(CFrame.new(Vector3.new(PlacePart.Position.X, PlacePart.Position.Y + offset + secondOffset, PlacePart.Position.Z)) * CFrame.fromEulerAngles(math.rad(orientation.X), math.rad(orientation.Y), math.rad(orientation.Z), Enum.RotationOrder.YXZ))
						task.wait(0.1)
						for _, info in pairs(sortPlaces) do
							if maxCar <= 0 or not Enableds.Place then break end
							local tool = info.Tool
							humanoid:EquipTool(tool)
							task.wait()
							FirePrompt(PlacePrompt)
							maxCar -= 1
						end
					end
				end
			end
			
			
			task.wait(1)
		end
	end)
end
]]

local function HandleAdvanced()
	if not Enableds.Advanced then return end
	RollPrompt = RollStands:QueryDescendants("#Lever > #ProximityPrompt > #ProximityPrompt")[1]
	task.spawn(function()
		while Enableds.Advanced do
			FirePrompt(RollPrompt)
			task.wait(0.5)

			local newStand = nil

			for _, stand in ipairs(RollStands:GetChildren()) do
				if not Enableds.Advanced then break end
				if stand.Name:find("Stand") then
					newStand = stand
					break
				end
			end

			local rollState = nil

			repeat 
				if newStand ~= nil then
					rollState = newStand:GetAttribute("RollState")
				end
				if rollState ~= nil and rollState == "ReadyToClaim" then
					break
				end
				task.wait() 
			until not Enableds.Advanced

			task.wait(1)

			local sortBuys = {}

			for _, stand in ipairs(RollStands:GetChildren()) do
				if not Enableds.Advanced then break end
				if stand.Name:find("Stand") then
					local previewFolder = stand:FindFirstChild("RollPreview")
					if not previewFolder then continue end

					table.insert(sortBuys, {
						PurchasePrice = previewFolder:GetAttribute("PurchasePrice") or 0,
						BasePrice = previewFolder:GetAttribute("BasePrice") or 0,
						PreviewFolder = previewFolder
					})

					task.wait(0.1)
				end
			end
			if not Enableds.Advanced then break end
			table.sort(sortBuys, function(a, b)
				return a.PurchasePrice > b.PurchasePrice
			end)

			for _, info in ipairs(sortBuys) do
				if not Enableds.Advanced then break end
				local priceTarget = info.PurchasePrice
				local basePrice = info.BasePrice
				
				if MoneyValue.Value >= priceTarget then
					
					
					local previewFolder = info.PreviewFolder

					local newPrompt = nil
					for _, prompt in ipairs(previewFolder:GetDescendants()) do
						if prompt and prompt.Parent and prompt:IsA("ProximityPrompt") and prompt.Enabled then
							newPrompt = prompt
							break
						end
					end

					while Enableds.Advanced and (previewFolder ~= nil and previewFolder.Parent ~= nil) do
						if newPrompt then
							FirePrompt(newPrompt)
						end
						task.wait(1)
					end
					
					task.wait(0.1)
				end
			end


			table.clear(sortBuys)
			--[[
			-- Roll, Buy & Equip Car --
			workspace.Plots.Plot_06 -- OwnerUserId
			workspace.Plots.Plot_06.RollStands.Lever.ProximityPrompt.ProximityPrompt
			workspace.Plots.Plot_06.RollStands.NewCars.Base
			workspace.Plots.Plot_06.RollStands.Stand_01 -- RollState is ReadyToClaim
			workspace.Plots.Plot_06.RollStands.Stand_01.RollPreview["Cozy Rover"] -- PurchasePrice

			game:GetService("Players").LocalPlayer.Money.Value

			game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.CarIndexFrame.ScrollingFrame
			game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.CarIndexFrame.ScrollingFrame["Car_2ad60e9d-e8fa-4dbb-b3de-200b8585ea49"] -- SortPrice
			game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.CarIndexFrame.ScrollingFrame["Car_2ad60e9d-e8fa-4dbb-b3de-200b8585ea49"].UnequipButton

			-- Other
			-- BasePrice
			
			workspace.Plots.Plot_03.RollStands.NewCars.Base.ProximityPrompt.ProximityPrompt -- ini Buy Promot
			game:GetService("Players").LocalPlayer.Backpack:GetChildren()[31] -- PurchasePrice
			]]


			task.wait(1)
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
	RebirthFrame = RebirthFrame or PlayerGui:QueryDescendants("#Main > #Frames > #RebirthFrame")[1]
	if RebirthFrame then
		RebirthFill = RebirthFill or RebirthFrame:QueryDescendants("#CanvasGroup > #Bar")[1]
		RebirthButton = RebirthButton or RebirthFrame:FindFirstChild("RebirthButton")
	end
	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(FireRebirth)
	task.spawn(function()
		while Enableds.Rebirth do
			FireRebirth()
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
				if UpgradeActives.AllEnabled then active = true end
				if not active then continue end

				local list = UpgradeInfos[key]
				if not list then continue end

				if #list > 1 then
					for _, info in ipairs(list) do
						if not Enableds.Upgrade then break end

						local button = info.UpgradeButton
						if not button then continue end

						if key == "Toll" then
							local alertGui = info.AlertGui
							if alertGui and (alertGui:IsA("SurfaceGui") or alertGui:IsA("BillboardGui")) and alertGui.Enabled == false then
								continue
							end
						end

						FireButton(button)
						task.wait(0.05)
					end
				else
					local info = list[1]
					if not info then continue end

					local button = info.UpgradeButton
					if not button then continue end

					if key == "Toll" then
						local alertGui = info.AlertGui
						if alertGui and (alertGui:IsA("SurfaceGui") or alertGui:IsA("BillboardGui")) and alertGui.Enabled == false then
							continue
						end
					end

					FireButton(button)
				end

				task.wait(0.05)
			end
			task.wait(0.5)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "My Toll Farm", 
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
	Text = "Roll & Buy Car",
	Value = false,
	Flag = "advanced_enabled",
	Callback = function(value)
		Enableds.Advanced = value
		HandleAdvanced()
	end
})

--[[
Window:AddButton({
	Text = "Place Best Car",
	MethodType = "DebounceClick",
	Callback = HandlePlace
})
]]

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
	Flag = "upgrade_enabled",
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

-- Do not change
Window:AddLabel({
	Text = "YouTube: Crokyreo",
})

Window:AddLabel({
	Text = "Date: 08-16-2026",
})
