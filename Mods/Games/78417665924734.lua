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
local ATTACK_DISTANCE = 3

local function GetPlot()
	local plots = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Plots")
	if not plots then return nil end

	for _, base in pairs(plots:GetChildren()) do
		local owner = base:GetAttribute("Owner")
		if owner and owner == LocalPlayer.Name then
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

	for key, npc in pairs(NpcActives) do
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
				
				local character = LocalPlayer.Character
				if not character or not character:FindFirstChild("HumanoidRootPart") then 
					continue 
				end

				if NpcTarget then
					local humanoid = NpcTarget:FindFirstChild("Humanoid")
					local rootPart = NpcTarget.PrimaryPart
					
					if not NpcTarget.Parent or not humanoid or not rootPart or NpcTarget.Health <= 0 then
						NpcTarget = nil
					end
				end

				if not NpcTarget then
					NpcTarget = FindClosestNpc()
				end

				if NpcTarget then
					local targetHRP = NpcTarget:FindFirstChild("HumanoidRootPart")

					local targetCFrame = targetHRP.CFrame * CFrame.new(0, 0, ATTACK_DISTANCE)
					character:MoveTo(targetCFrame.Position)

					local tool = character:FindFirstChildOfClass("Tool")
					if tool then
						if firesignal then
							firesignal(tool.Activated)
						else
							tool:Activate() 
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
