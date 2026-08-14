local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections, Packets = {Upgrade = false, Attack = false, Gold = false}, {}, {}

local NpcTarget = nil
local AttackDistance = 3
local WaveFrame, StartWaveButton = nil, nil

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

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
local StructuresFolder = nil
if Plot then
	StructuresFolder = Plot:QueryDescendants("#Main > Plot > #Structures")[1]
end

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function FireTool(tool)
	if tool and tool:FindFirstChild("Handle") then
		if firesignal then
			firesignal(tool.Activated)
		end
	end
end

local function HandleUpgrade()
	if not Enableds.Upgrade then return end
	Packets.Building = Packets.Building or ReplicatedStorage:QueryDescendants("#Remotes > #Plot > #Building")[1]
	Packets.UpgradeKing = Packets.UpgradeKing or ReplicatedStorage:QueryDescendants("#Remotes > #Plot > #UpgradeKing")[1]
	task.spawn(function()
		while Enableds.Upgrade do
			for _, structure in ipairs(StructuresFolder:GetChildren()) do
				if not Enableds.Upgrade then break end
				Packets.Building:InvokeServer("UpgradeStructure", structure.Name)
				task.wait(0.1)
			end
			task.wait(1)
		end
	end)
	task.spawn(function()
		while Enableds.Upgrade do
			if Enableds.Upgrade then
				Packets.UpgradeKing:InvokeServer()
			end
			task.wait(5)
		end
	end)
end

local function HandleGold()
	if not Enableds.Gold then return end
	Packets.ClaimGoldMine = Packets.ClaimGoldMine or ReplicatedStorage:QueryDescendants("#Remotes > #ClaimGoldMine")[1]
	task.spawn(function()
		while Enableds.Gold do
			for _, structure in ipairs(StructuresFolder:GetChildren()) do
				if not Enableds.Gold then break end
				local part = structure:FindFirstChild("Part")
				if part then
					Packets.ClaimGoldMine:FireServer(structure.Name)
					task.wait(0.1)
				end
			end
			task.wait(1)
		end
	end)
end

local function GetAliveNpc()
	local target = nil
	local distance = math.huge
	local maxDistance = 500

	Plot = Plot or GetPlot()
	if not Plot then return nil end

	local npcs = Plot:FindFirstChild("Npcs")

	for key, npc in pairs(npcs:GetChildren()) do
		if not npc or not npc.Parent then
			continue
		end

		local humanoid = npc:FindFirstChild("Humanoid")
		local rootPart = npc.PrimaryPart
		if not humanoid or not rootPart or humanoid.Health <= 0  then
			continue
		end

		if not Character or not Character.Parent or not Character.PrimaryPart then
			return nil
		end

		local dist = (rootPart.Position - Character.PrimaryPart.Position).Magnitude

		if dist < distance and dist <= maxDistance then
			distance = dist
			target = npc
		end
	end

	return target
end

local function HandleAttack()
	if Connections.NpcAdded then Connections.NpcAdded:Disconnect() Connections.NpcAdded = nil end
	if Connections.NpcRemoved then Connections.NpcRemoved:Disconnect() Connections.NpcRemoved = nil end
	if not Enableds.Attack then return end
	
	WaveFrame = WaveFrame or PlayerGui:QueryDescendants("#MainUI > #Top > #Wave")[1]
	StartWaveButton = StartWaveButton or PlayerGui:QueryDescendants("#MainUI > #Top2 > #StartWave")[1]
	
	task.spawn(function() 
		while Enableds.Attack do
			if not WaveFrame.Visible then
				FireButton(StartWaveButton)
			end
			task.wait(0.5)
		end
	end)
	
	task.spawn(function() 
		while Enableds.Attack do
			task.wait()

			if not Character or not Character.Parent then 
				continue 
			end

			if NpcTarget and NpcTarget.Parent then
				local humanoid = NpcTarget:FindFirstChildOfClass("Humanoid")
				local rootPart = NpcTarget.PrimaryPart

				if not NpcTarget.Parent or not humanoid or not rootPart or humanoid.Health <= 0 then
					NpcTarget = nil
				end
			end

			if not (NpcTarget and NpcTarget.Parent) then
				NpcTarget = GetAliveNpc()
			end
			
			if NpcTarget and Character and NpcTarget.Parent and Character.Parent then
				local targetHRP = NpcTarget.PrimaryPart or NpcTarget:GetPivot()
				local myHRP = Character.PrimaryPart or Character:GetPivot()

				if not targetHRP or not myHRP then continue end

				local targetCFrame = targetHRP.CFrame * CFrame.new(0, 0, -AttackDistance)

				local lookCFrame = CFrame.lookAt(
					Vector3.new(targetCFrame.Position.X, myHRP.Position.Y, targetCFrame.Position.Z), 
					Vector3.new(targetHRP.Position.X, myHRP.Position.Y, targetHRP.Position.Z)
				)

				Character:PivotTo(lookCFrame)
			end
		end
	end)

	task.spawn(function()
		while Enableds.Attack do
			if Character and Character.Parent then
				local tool = Character:FindFirstChildOfClass("Tool")
				FireTool(tool)
			end
			task.wait(0.25)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Build a Slime Defense", 
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
	Text = "Auto Attack",
	Value = false,
	Callback = function(value)
		Enableds.Attack = value
		HandleAttack()
	end
})

Window:AddToggle({
	Text = "Collect Gold",
	Value = false,
	Flag = "gold_enabled",
	Callback = function(value)
		Enableds.Gold = value
		HandleGold()
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

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 07-04-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
