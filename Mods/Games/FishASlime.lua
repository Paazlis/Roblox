local Services = setmetatable({},{
	__index=function(_,i) 
		return cloneref and cloneref(game:GetService(i)) or game:GetService(i) 
	end
})

local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local PlaceEvent = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Place")
local PickupEvent = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("PickupMob")

local AutoEquipEnabled = false

local Window = UI:CreateWindow({
	Name = "Fish a Slime",
	Destroying = function()
		-- Clean up the loop if the UI is closed
		AutoEquipEnabled = false
	end
})

local MyPlot = nil

-- Mutation Multiplier Dictionary
local Mutations = {
	["Frozen"] = 1.2,
	["Poison"] = 1.2,
	["Electric"] = 1.3,
	["Rainbow"] = 1.3,
	["Lightning"] = 1.4,
	["Spooky"] = 1.4,
	["Magma"] = 1.5,
	["Shadow"] = 2,
	["Cosmic"] = 2.5,
	["Blood"] = 2.5,
	["Burnt"] = 2,
	["Planetary"] = 2,
	["Blue Blood"] = 3,
	["Normal"] = 1
}

AutoEquipEnabled = false

local function getMyPlot()
	for _, plot in ipairs(script:GetChildren()) do
		local ownerId = plot:GetAttribute("Owner")
		if ownerId and ownerId == LocalPlayer.UserId then
			return plot
		end
	end
	
	return nil
end

-- Function to calculate how "good" a tool is

local function getToolScore(tool)
	local level = tool:GetAttribute("Level") or 1
	local mutation = tool:GetAttribute("Mutation")
	local rarity = tool:GetAttribute("Rarity") -- Optional: Expand this if you want to add rarity multipliers later

	local mutationMult = Mutations[mutation] or 1 -- Defaults to 1x if no mutation or unknown mutation

	return level * mutationMult
end

local function getPlacedHolders(plot)
	local list={}
	-- Read existing slots from PlacedHolder
	local placedHolder=plot:FindFirstChild("PlacedHolder")
	if placedHolder then
		for _, model in ipairs(placedHolder:GetChildren()) do
			if model:IsA("Model") then
				table.insert(list,model)
			end
		end
	end
	return list
end

-- Find the first available open slot number on your plot
local function getOpenSlot(plot)
	if not plot then return nil end

	local occupiedSlots = {}

	local placedHolders=getPlacedHolders(plot)
	for _,model in ipairs(placedHolders) do
		local slotValueObj = model:FindFirstChild("slotValue")
		if slotValueObj and slotValueObj:IsA("ValueBase") then
			occupiedSlots[slotValueObj.Value] = model
		end
	end
	
	local slotsLength = 10
	
	local slots = plot:FindFirstChild("Slots")
	if slots then
		slotsLength = 0
		
		for _,slot in ipairs(slots:GetChildren()) do
			local position = tonumber(slot.Name)
			if position then
				slotsLength += 1
			end
		end
	end
	
	for i = 1, slotsLength do
		if not occupiedSlots[i] then
			return i
		end
	end

	return nil -- Plot is full
end

-- Function to find and equip the best tool
local function equipBest()
	if MyPlot == nil then
		MyPlot = getMyPlot()
	end

	if not MyPlot then return end
	
	local placedHolders=getPlacedHolders(MyPlot)
	for _, model in ipairs(placedHolders) do
		local slotValueObj = model:FindFirstChild("slotValue")
		if slotValueObj and slotValueObj:IsA("ValueBase") then
			if PickupEvent then
				PickupEvent:InvokeServer(model)
			end
		end
	end
	
	local bestTool = nil
	local highestScore = -1

	-- 1. Check tools currently in Backpack
	for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
		if item:IsA("Tool") and item.Name~="Gym" then
			local score = getToolScore(item)
			if score > highestScore then
				highestScore = score
				bestTool = item
			end
		end
	end

	-- 2. Check tools already in Character (currently equipped)
	if LocalPlayer.Character then
		for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
			if item:IsA("Tool") then
				local score = getToolScore(item)
				if score > highestScore then
					highestScore = score
					bestTool = item
				end
			end
		end
	end

	-- 3. Equip the best tool using the Humanoid (safer than re-parenting manually)
	if bestTool and bestTool.Parent == LocalPlayer.Backpack and LocalPlayer.Character then
		local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:UnequipTools() -- Unequips current tool to prevent holding multiple
			humanoid:EquipTool(bestTool)
			task.wait(0.1) -- Small delay to ensure engine replication
		end
		
		if LocalPlayer.Character and bestTool.Parent == LocalPlayer.Character then
			
			local targetSlot = getOpenSlot(MyPlot)
			if not targetSlot then
				return
			end

			-- Fire the Cobalt placement remote
			if PlaceEvent and targetSlot then
				PlaceEvent:InvokeServer(targetSlot)
				print("Successfully placed " .. bestTool.Name .. " into Plot: " .. MyPlot.Name .. " | Slot: " .. tostring(targetSlot))
			end
		end
	end
end

-- UI Toggle Setup
Window:AddToggle({
	Name = "Equip Best",
	Callback = function(value)
		AutoEquipEnabled = value

		if AutoEquipEnabled then
			task.spawn(function()
				while AutoEquipEnabled do
					equipBest()
					task.wait(5) -- 5 second period constraint
				end
			end)
		end
	end
})
