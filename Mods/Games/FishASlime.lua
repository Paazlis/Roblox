local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

-- Local state control (Replaced _G)
local autoEquipEnabled = false

local Window = UI:CreateWindow({
	Name = "Fish a Slime",
	Destroying = function()
		autoEquipEnabled = false
	end
})

-- Mutation Multipliers
local Mutations = {
	["Frozen"] = 1.2, ["Poison"] = 1.2, ["Electric"] = 1.3, ["Rainbow"] = 1.3,
	["Lightning"] = 1.4, ["Spooky"] = 1.4, ["Magma"] = 1.5, ["Shadow"] = 2,
	["Cosmic"] = 2.5, ["Blood"] = 2.5, ["Burnt"] = 2, ["Planetary"] = 2,
	["Blue Blood"] = 3, ["Normal"] = 1
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Remotes setup
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlaceEvent = Remotes:FindFirstChild("Place")
local PickupEvent = Remotes:FindFirstChild("PickupMob")

-- Calculate tool power score (Works on both Tools and Workspace Models)
local function getToolScore(instance)
	if not instance then return -1 end
	local level = instance:GetAttribute("Level") or 1
	local mutation = instance:GetAttribute("Mutation")
	local mutationMult = Mutations[mutation] or 1
	return level * mutationMult
end

-- Find your plot strictly ordered from 1 upwards
local function getMyPlot()
	local plotIndex = 1
	while true do
		local plot = workspace.Plots:FindFirstChild(tostring(plotIndex))
		if not plot then break end -- Stop when no more sequential plots exist
		
		if plot:GetAttribute("Owner") == LocalPlayer.UserId then
			return plot
		end
		plotIndex = plotIndex + 1
	end
	return nil
end

-- Main automation manager
local function executeAutoEquipment()
	local myPlot = getMyPlot()
	if not myPlot then 
		warn("Auto-Equip: Could not find your owned plot!")
		return 
	end

	local bestTool = nil
	local highestScore = -1
	local bestLocation = "" -- Tracked as: "Backpack", "Character", or "Plot"

	-- 1. Scan Backpack
	for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
		if item:IsA("Tool") then
			local score = getToolScore(item)
			if score > highestScore then
				highestScore = score
				bestTool = item
				bestLocation = "Backpack"
			end
		end
	end

	-- 2. Scan Character (Currently equipped)
	if LocalPlayer.Character then
		for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
			if item:IsA("Tool") then
				local score = getToolScore(item)
				if score > highestScore then
					highestScore = score
					bestTool = item
					bestLocation = "Character"
				end
			end
		end
	end

	-- 3. Scan PlacedHolder on your plot (Check if a better tool is deployed)
	if myPlot:FindFirstChild("PlacedHolder") then
		for _, model in ipairs(myPlot.PlacedHolder:GetChildren()) do
			local score = getToolScore(model)
			if score > highestScore then
				highestScore = score
				bestTool = model
				bestLocation = "Plot"
			end
		end
	end

	-- If no tools are found anywhere, stop here
	if highestScore == -1 or not bestTool then return end

	-- Action Phase: Retrieve the tool if it's on the plot
	if bestLocation == "Plot" then
		if PickupEvent then
			print("Found a superior tool in PlacedHolder. Picking up instance: " .. bestTool.Name)
			
			-- FIXED: Passes the Instance model directly to the server remote
			PickupEvent:InvokeServer(bestTool) 
			task.wait(0.3) -- Brief pause to allow inventory replication
			
			-- Re-verify tool inside backpack after picking it up
			for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
				if item:IsA("Tool") and getToolScore(item) >= highestScore then
					bestTool = item
					bestLocation = "Backpack"
					break
				end
			end
		else
			warn("Auto-Equip: PickupMob remote event is missing!")
			return
		end
	end

	-- Action Phase: Equip the tool to your character
	if (bestLocation == "Backpack" or bestTool.Parent == LocalPlayer.Backpack) and LocalPlayer.Character then
		local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:EquipTool(bestTool)
			print("Successfully equipped the best tool: " .. bestTool.Name .. " (Score: " .. highestScore .. ")")
		end
	end
end

-- UI Toggle Setup
Window:AddToggle({
	Name = "Equip Best",
	Callback = function(value)
		autoEquipEnabled = value
		
		if autoEquipEnabled then
			task.spawn(function()
				while autoEquipEnabled do
					executeAutoEquipment()
					task.wait(5) -- 5-second interval loop
				end
			end)
		end
	end
})
