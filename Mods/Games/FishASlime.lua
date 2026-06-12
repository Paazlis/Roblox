local Services = setmetatable({},{
	__index=function(_,i) 
		return cloneref and cloneref(game:GetService(i)) or game:GetService(i) 
	end
})

local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")

local AutoEquipEnabled = false

local Window = UI:CreateWindow({
	Name = "Fish a Slime",
	Destroying = function()
		-- Clean up the loop if the UI is closed
		AutoEquipEnabled = false
	end
})

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
	["Blue Blood"] = 3
}

AutoEquipEnabled = false

-- Function to calculate how "good" a tool is

local function getToolScore(tool)
	local level = tool:GetAttribute("Level") or 1
	local mutation = tool:GetAttribute("Mutation")
	local rarity = tool:GetAttribute("Rarity") -- Optional: Expand this if you want to add rarity multipliers later

	local mutationMult = Mutations[mutation] or 1 -- Defaults to 1x if no mutation or unknown mutation

	return level * mutationMult
end

-- Function to find and equip the best tool
local function equipBestTool()
	local bestTool = nil
	local highestScore = -1

	-- 1. Check tools currently in Backpack
	for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
		if item:IsA("Tool") then
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
	if bestTool and bestTool.Parent == LocalPlayer.Backpack then
		local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:UnequipTools() -- Unequips current tool to prevent holding multiple
			humanoid:EquipTool(bestTool)
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
					equipBestTool()
					task.wait(5) -- 5 second period constraint
				end
			end)
		end
	end
})
