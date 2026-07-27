local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager=Services.VirtualInputManager

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections = {["Wins"] = false, ["Rebirth"] = false}, {}
local ProfileData = {["World"] = 1, ["LastCheckpoint"] = nil}
local WorldValue, LastCheckpointValue = LocalPlayer:QueryDescendants("#Data > #World")[1], LocalPlayer:QueryDescendants("#Data > #LastCheckpoint")[1]

if LastCheckpointValue then
	ProfileData.LastCheckpoint = LastCheckpointValue.Value
	
	Connections.LastCheckpointChanged = LastCheckpointValue:GetPropertyChangedSignal("Value"):Connect(function()
		ProfileData.LastCheckpoint = (LastCheckpointValue ~= nil and LastCheckpointValue.Parent ~= nil) and LastCheckpointValue.Value or nil
	end)
end

local WinsDropdown = nil

local RebirthFrame, RebirthFill, RebirthButton = PlayerGui:QueryDescendants("#Main > #UIs > #Rebirth")[1], nil, nil

if RebirthFrame then
	RebirthFill, RebirthButton = RebirthFrame:QueryDescendants("#Level > #CanvasGroup > #Bar")[1], RebirthFrame:QueryDescendants("#Buttons > #Rebirth")[1]
end

local CheckpointContainerFolder = nil
local MapFolder = workspace:FindFirstChild("Map")
local WorldCache = {}

if MapFolder then
	CheckpointContainerFolder = MapFolder:FindFirstChild("Checkpoints")
	
	for _, worldFolder in ipairs(MapFolder:GetChildren()) do
		if not (worldFolder and worldFolder.Parent) then continue end
		
		local worldName = worldFolder.Name
		
		local worldNum = tonumber(worldName:match("%d+") or "")
		if not worldNum then continue end
		
		local worldKey = "World"..tostring(worldNum)
		if not worldName:match("World") or not worldName:match(worldKey) then continue end
		
		local newWorldStats = {}
		
		local upgradeFolder = worldFolder:FindFirstChild("Upgrades")
		if upgradeFolder then
			newWorldStats.Upgrades = upgradeFolder
		end
		
		local stageFolder = worldFolder:FindFirstChild("Stages")
		if stageFolder then
			newWorldStats.Stages = stageFolder
		end
		
		if CheckpointContainerFolder then
			local checkpointWorldFolder = CheckpointContainerFolder:FindFirstChild(worldKey)
			if checkpointWorldFolder then
				newWorldStats.Checkpoints = checkpointWorldFolder
			end
		end
		WorldCache[worldKey] = newWorldStats
	end
end

if WorldValue then
	ProfileData.World = WorldValue.Value

	Connections.WorldChanged = WorldValue:GetPropertyChangedSignal("Value"):Connect(function()
		ProfileData.World = (WorldValue ~= nil and WorldValue.Parent ~= nil) and WorldValue.Value or 1
		if MapFolder then
			local lastWorld = ProfileData.World
			for _, worldFolder in ipairs(MapFolder:GetChildren()) do
				if not (worldFolder and worldFolder.Parent) then continue end
				
				local worldName = worldFolder.Name
				
				if lastWorld ~= ProfileData.World then break end
				
				local worldNum = tonumber(worldName:match("%d+") or "")
				if not worldNum then continue end

				local worldKey = "World"..tostring(worldNum)
				if not worldName:match("World") or not worldName:match(worldKey) then continue end

				local newWorldStats = {}

				local upgradeFolder = worldFolder:FindFirstChild("Upgrades")
				if upgradeFolder then
					newWorldStats.Upgrades = upgradeFolder
				end

				local stageFolder = worldFolder:FindFirstChild("Stages")
				if stageFolder then
					newWorldStats.Stages = stageFolder
				end
				
				if CheckpointContainerFolder then
					local checkpointWorldFolder = CheckpointContainerFolder:FindFirstChild(worldKey)
					if checkpointWorldFolder then
						newWorldStats.Checkpoints = checkpointWorldFolder
					end
				end
				
				WorldCache[worldKey] = newWorldStats
			end
		end
	end)
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

--[[
-- Auto Win --
game:GetService("Players").LocalPlayer.Data.LastCheckpoint.Value -- SpawnPoint Instance 
game:GetService("Players").LocalPlayer.Data.World.Value -- 1 number


workspace.Map.Checkpoints
workspace.Map.Checkpoints.World1.Checkpoint1.SpawnPoint

workspace.Map.World1.Stages.Stage1.NormalWin.Button
workspace.Map.World2.Stages.Stage1.NormalWin.Button

-- Auto Rebirth --
game:GetService("Players").LocalPlayer.PlayerGui.Main.UIs.Rebirth
game:GetService("Players").LocalPlayer.PlayerGui.Main.UIs.Rebirth.Level.CanvasGroup.Bar
game:GetService("Players").LocalPlayer.PlayerGui.Main.UIs.Rebirth.Buttons.Rebirth

-- Equip Best Rail --
workspace.Map.World1.Upgrades
workspace.Map.World1.Upgrades.Button9 -- Upgrade number attribute or tonumber(child.Name:match("%d+"))
]]

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

local function IsFillFull(fill)
	if fill.Size.X.Scale >= 1 then
		return true
	end
	return false
end

-- Helper function: Teleportasi karakter
local function TeleportTo(cframe)
	Character:PivotTo(cframe)
end

local function HandleWins()
	local worldStats = WorldCache["World"..ProfileData.World]
	if not worldStats then warn("World folder kosong sekali") return end

	local checkpointFolder = worldStats.Checkpoints
	if not checkpointFolder then warn("Checkpoint folder kosong sekali") return end
	
	local stageFolder = worldStats.Stages
	if not stageFolder then warn("Stage folder kosong sekali") return end
	
	local sortStages = {}
	
	for _, checkpointFolder in ipairs(checkpointFolder:GetChildren()) do
		local checkpointName = checkpointFolder.Name
		
		local checkpointNum = tonumber(checkpointName:match("%d+") or "")
		if not checkpointNum then continue end
		
		local spawnPointPart = checkpointFolder:QueryDescendants("BasePart#SpawnPoint")
		if not spawnPointPart then warn("SpawnPoint part tidak ditemukan untuk "..checkpointName) continue end
		
		table.insert(sortStages, {
			Name = checkpointName,
			Tier = checkpointNum,
			SpawnPoint = spawnPointPart,
		})
	end
	
	table.sort(sortStages, function(a, b)
		return a.Tier < b.Tier
	end)
	
	local stageTypes = {}
	
	for _, stageData in ipairs(sortStages) do
		table.insert(stageTypes, stageData.Name)
	end
	
	if #stageTypes > 0 then
		WinsDropdown.Options = stageTypes
		WinsDropdown:Refresh()
	end
	
	
	--task.spawn(function()
	--	while Enableds.Wins do
	--		task.wait(1)


	--	end
	--end)
end

local function HandleEquipBestTail()
	local worldStats = WorldCache["World"..ProfileData.World]
	if not worldStats then warn("World folder kosong sekali") return end
	
	local upgradeFolder = worldStats.Upgrades
	if not upgradeFolder then warn("Upgrade folder kosong sekali") return end
	
	local sortUpgrades = {}

	for _, upgradePad in ipairs(upgradeFolder:GetChildren()) do
		local upgradeNum = tonumber(upgradeFolder:GetAttribute("Upgrade") or "") or tonumber(upgradePad.Name:match("%d+") or "")
		if not upgradeNum then continue end
		
		table.insert(sortUpgrades, {
			Tier = upgradeNum,
			Hitbox = upgradePad:QueryDescendants("BasePart#Button")[1],
		})
	end

	table.sort(sortUpgrades, function(a, b)
		return a.Tier < b.Tier
	end)
	
	if not next(sortUpgrades) or #sortUpgrades <= 0 then
		warn("sortUpgrades table kosong sekali")
	end
	
	for _, upgradePad in ipairs(sortUpgrades) do
		local hitbox = upgradePad.Hitbox
		local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
		if hitbox and rootPart then
			FireTouch(rootPart, hitbox)
		end
	end
end

local function FireRebirth()
	if Enableds.Rebirth and IsFillFull(RebirthFill) then
		FireButton(RebirthButton)
	end
end

local function HandleRebirth()
	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Position"):Connect(FireRebirth)

	task.spawn(function()
		while Enableds.Rebirth do
			FireRebirth()
			task.wait(1)
		end
	end)
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local sortWorldTypes = {}
for Key, data in pairs(WorldCache) do
	table.insert(sortWorldTypes, {
		Name = Key,
		Tier = tonumber(Key:match("%d+") or "") or 1
	})
end
table.sort(sortWorldTypes, function(a, b)
	return a.Tier < b.Tier
end)

local WorldTypes = {}
for _, data in ipairs(sortWorldTypes) do
	table.insert(WorldTypes, data.Name)
end

local Window = UI:CreateWindow({
	Name = "+1 Speed Monkey Escape",
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
	Text = "Wins Farm (Last Area)",
	Value = false,
	Flag = "wins_enabled",
	Callback = function(value)
		Enableds.Wins = value
		if value then
			HandleWins()
		end
	end
})

Window:AddDropdown({
	Text = "World Type (Experiment)",
	Options = WorldTypes,
	Option = nil,
	Flag = "world_options",
	Callback = function(option)
	end
})

WinsDropdown = Window:AddDropdown({
	Text = "Wins Type (Experiment)",
	Options = WorldTypes,
	Option = nil,
	Flag = "wins_options",
	Callback = function(option)
	end
})


Window:AddButton({
	Text = "Equip Best Tail",
	MethodType = "DebounceClick",
	Callback = HandleEquipBestTail
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		Enableds.Rebirth = value
		if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
		if value then
			HandleRebirth()
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
