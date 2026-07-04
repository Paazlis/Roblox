local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Utility/init.luau"))()
local Instancer = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Instancer/init.luau",true))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer.PlayerGui

local UpgradeEnabled, AttackEnabled = false, false
local NpcAddedConnection, NpcRemovedConnection = nil, nil
local NpcActives = {}
local NpcTarget = nil

local function GetPlot()
	local plots = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Plots")
	if not plots then return nil end

	for _, base in pairs(plots:GetChildren()) do
		local owner = base:GetAttribute("Owner")
		if owner and LocalPlayer.Name then
			return base
		end
	end

	return nil
end

local Plot = GetPlot()

-- Upgrade Function --
local function AutoUpgrade()
	if UpgradeEnabled then
		task.spawn(function()
			while UpgradeEnabled do
				task.wait(5)
				Plot = Plot or GetPlot()
				if Plot then
					local structures = Plot.Main.Plot.Structures
					for _, structure in ipairs(structures:GetChildren()) do
						task.wait()
						if UpgradeEnabled then
							ReplicatedStorage.Remotes.Plot.Building:InvokeServer("UpgradeStructure", structure.Name)
						end
					end
				end
				task.wait(5)
				if UpgradeEnabled then
					ReplicatedStorage.Remotes.Plot.UpgradeKing:InvokeServer()
				end
			end
		end)
	end
end

-- Attack Function --
local function FindClosestNpc()
	local target = nil
	local shortestDistance = math.huge
	local maxDistance = 500

	local character = LocalPlayer.Character

	if not character or not character.PrimaryPart then
		return nil
	end

	local playerPos = character.PrimaryPart.Position

	for _, npc in ipairs(NpcActives) do
		if npc and npc.PrimaryPart and not Instancer.IsDied(npc) then
			local dist = (npc.PrimaryPart.Position - playerPos).Magnitude

			if dist < shortestDistance and dist <= maxDistance then
				target = npc
				shortestDistance = dist
			end
		end
	end

	return target
end

local function AutoAttack()
	NpcAddedConnection = Utility.Cleanup(NpcAddedConnection)
	NpcRemovedConnection = Utility.Cleanup(NpcRemovedConnection)

	if AttackEnabled then
		Plot = Plot or GetPlot()
		if not Plot then return end

		local npcs = Plot.Npcs

		NpcAddedConnection = npcs.ChildAdded:Connect(function(model)
			NpcActives[model] = model
		end)

		NpcRemovedConnection = npcs.ChildRemoved:Connect(function(model)
			NpcActives[model] = nil
		end)

		task.spawn(function() 
			while AttackEnabled do
				task.wait()

				if Instancer.IsDied(NpcTarget) then
					NpcTarget = FindClosestNpc()
				end

				local character = LocalPlayer.Character
				if not Instancer.IsDied(character) and NpcTarget.PrimaryPart and AttackEnabled then
					character:MoveTo(NpcTarget.PrimaryPart.Position)
				end
			end
		end)

		task.spawn(function()
			local tool = nil
			while AttackEnabled do
				task.wait()
				local character = LocalPlayer.Character
				if character then
					if not tool or tool.Parent ~= character then
						for _, object in ipairs(character:GetChildren()) do
							if object:IsA("Tool") and object:FindFirstChild("Handle") then
								tool = object
								break
							end
						end
					end
					if tool and tool.Parent == character then
						if firesignal then
							firesignal(tool.Activated)
						end
					end
				end
			end
		end)
	end
end

-- Main UI --
local Window = UI:CreateWindow({
	Name = "Build a Slime Defense", 
	Destroying = function()
		UpgradeEnabled, AttackEnabled = false, false
		NpcAddedConnection = Utility.Cleanup(NpcAddedConnection)
		NpcRemovedConnection = Utility.Cleanup(NpcRemovedConnection)
	end
})

Window:AddToggle({
	Name = "Auto Attack",
	Value = false,
	Callback = function(value)
		AttackEnabled = value
		AutoAttack()
	end
})

Window:AddToggle({
	Name = "Auto Upgrade",
	Value = false,
	Callback = function(value)
		UpgradeEnabled = value
		AutoUpgrade()
	end
})

Window:AddLabel("YouTube: Crokyreo")
