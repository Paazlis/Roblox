local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections, Packets = {["Restock"] = false, ["Harvest"] = false, ["Plant"] = false}, {}, {}
local SeedCache = {}

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function GetPlot()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end

	for _, plot in ipairs(plots:GetChildren()) do
		if plot.Name == LocalPlayer.Name then
			return plot
		end
	end

	return nil
end

local Plot = GetPlot()
local ObjectsFolder = nil
if Plot then
	ObjectsFolder = Plot:FindFirstChild("Objects")
end

local function GetIndexByChildren(parent, name)
	local list = {}
	for _, child in ipairs(parent:GetChildren()) do
		if string.match(child.Name, "^"..name.."%d+$") then
			table.insert(list, {
				["Instance"] = child,
				["Tier"] = child.Name:match("%d+") or 0
			})
		end
	end
	return list
end

local function HandleRestock()
	if not Enableds.Restock then return end
	task.spawn(function()
		Packets.StockFlower = Packets.StockFlower or ReplicatedStorage:QueryDescendants("#Packages > #_Index >> #knit > #Services > #FlowerDisplayService > #RF > #StockFlower")[1]
		while Enableds.Restock do
			for _, display in ipairs(ObjectsFolder:GetChildren()) do
				if not Enableds.Restock then break end
				if display.Name == "Flower Display" then
					Packets.StockFlower:InvokeServer(display)
				end
				task.wait(0.1)
			end
			task.wait(1)
		end
	end)
end

local function HandleHarvest()
	if not Enableds.Harvest then return end
	task.spawn(function()
		Packets.Harvest = Packets.Harvest or ReplicatedStorage:QueryDescendants("#Packages > #_Index >> #knit > #Services > #GrowingService > #RF > #Harvest")[1]
		while Enableds.Harvest do
			for _, bed in ObjectsFolder:GetChildren() do
				if not Enableds.Harvest then break end
				if bed.Name == "Flower Bed" then
					local slots = GetIndexByChildren(bed, "Plot")
					for _, slot in ipairs(slots) do
						if not Enableds.Harvest then break end
						local tier = tostring(slot.Tier)
						if tier ~= "0" then
							local prompt = slot.Instance:QueryDescendants("#SlotPromptAtt_"..tier.." > #SlotPrompt_"..tier)[1]
							if prompt and prompt.ActionText == "Harvest" then
								Packets.Harvest:InvokeServer(bed,tier)
							end
						end
						task.wait(0.1)
					end
					table.clear(slots)
				end
				task.wait(0.1)
			end
			task.wait(1)
		end
	end)
end

local function HandlePlant()
	if not Enableds.Plant then return end
	task.spawn(function()
		Packets.PlantSeed = Packets.PlantSeed or ReplicatedStorage:QueryDescendants("#Packages > #_Index >> #knit > #Services > #GrowingService > #RF > #PlantSeed")[1]
		while Enableds.Plant do
			for _, bed in ObjectsFolder:GetChildren() do
				if not Enableds.Plant then break end
				if bed.Name == "Flower Bed" then
					local slots = GetIndexByChildren(bed, "Plot")
					for _, slot in ipairs(slots) do
						if not Enableds.Plant then break end
						local tier = tostring(slot.Tier)
						if tier ~= "0" then
							local prompt = slot.Instance:QueryDescendants("#SlotPromptAtt_"..tier.." > #SlotPrompt_"..tier)[1]
							if prompt and prompt.ActionText == "Empty" then
								local tool, seedName = nil, nil
								for _, newTool in ipairs(Backpack:GetChildren()) do
									if not Enableds.Plant then break end
									if SeedCache[newTool.Name] then
										tool = newTool
										seedName = newTool.Name
										break
									end
								end
								if not (tool and seedName) then continue end
								local humanoid = Character:FindFirstChildOfClass("Humanoid")
								if humanoid then
									humanoid:EquipTool(tool)
									task.wait(0.2)
								end
								Packets.PlantSeed:InvokeServer(bed,seedName,tonumber(tier))
							end
						end
						task.wait(0.1)
					end
					table.clear(slots)
				end
				task.wait(0.1)
			end
			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "My Flower Shoop",
	Destroying = function()
		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end

		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
	end
})

Window:AddToggle({
	Text = "Auto Restock",
	Value = false,
	Flag = "restock_enabled",
	Callback = function(value)
		Enableds.Restock = value
		HandleRestock()
	end
})

Window:AddToggle({
	Text = "Auto Harvest",
	Value = false,
	Flag = "harvest_enabled",
	Callback = function(value)
		Enableds.Harvest = value
		HandleHarvest()
	end
})

Window:AddToggle({
	Text = "Auto Plant",
	Value = false,
	Flag = "plant_enabled",
	Callback = function(value)
		Enableds.Plant = value
		HandlePlant()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-11-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Services.GuiService:SetGameplayPausedNotificationEnabled(false)

task.spawn(function()
	local SeedScroll = PlayerGui:QueryDescendants("#ScreenGui > #MainMenu > #Main > #SeedsContent > #ScrollingFrame")[1]
	if SeedScroll then
		for _, layer in ipairs(SeedScroll:GetChildren()) do
			local title = layer:FindFirstChild("SeedName")
			if not title then
				continue
			end
			local key = title.Text
			if SeedCache[key] ~= nil then continue end
			SeedCache[key] = {}
		end
	end
end)
