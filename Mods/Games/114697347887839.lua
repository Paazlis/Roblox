local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

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

local CheckpointIndex = 5
local WinsDropdown, StagesDropdown = nil, nil

local RebirthFrame, RebirthFill, RebirthButton = PlayerGui:QueryDescendants("#Main > #UIs > #Rebirth")[1], nil, nil

if RebirthFrame then
	RebirthFill, RebirthButton = RebirthFrame:QueryDescendants("#Level > #CanvasGroup > #Bar")[1], RebirthFrame:QueryDescendants("#Buttons > #Rebirth")[1]
end

local CheckpointContainerFolder = nil
local SunkenShardFolder = workspace:FindFirstChild("SunkenShards")
local MapFolder = workspace:FindFirstChild("Map")
local WorldData = {}

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
		WorldData[worldKey] = newWorldStats
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
				if not (Connections.WorldChanged and Connections.WorldChanged.Connected) then break end
	
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

				WorldData[worldKey] = newWorldStats
			end
		end
	end)
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

-- Helper function: Menekan BasePart tombol
local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

-- Helper function: Menekan UI tombol
local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

-- Helper function: Cek apakah fill penuh
local function IsFillFull(fill)
	if fill.Size.X.Scale >= 1 then
		return true
	end
	return false
end

-- Helper function: Cari terdekat
local function GetNearest(selector, list, maxDistance)
	local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return nil end

	local playerPosition = rootPart.Position
	local nearestHitBox = nil
	local shortestDistance = maxDistance or 150

	for _, pad in ipairs(list) do
		local hitBox = pad:QueryDescendants(selector)[1]
		if hitBox then
			local distance = (hitBox.Position - playerPosition).Magnitude
			if distance < shortestDistance then
				shortestDistance = distance
				nearestHitBox = hitBox
			end
		end
	end

	return nearestHitBox
end

-- Helper function: Teleportasi karakter
local function TeleportTo(cframe)
	Character:PivotTo(cframe)
end

-- Helper function: Untuk menghindari GameplayPaused
local function PlayerRequestStreamAroundAsync(position, timeOut)
	-- Minta Roblox memuat area lokasi teleport agar mengurangi durasi GameplayPaused
	pcall(function()
		LocalPlayer:RequestStreamAroundAsync(position, timeOut)
	end)
end

local function HandleWins()
	local worldStats = WorldData["World"..ProfileData.World]
	if not worldStats then return end

	local checkpointFolder = worldStats.Checkpoints
	if not checkpointFolder then return end

	local stageFolder = worldStats.Stages
	if not stageFolder then return end

	local waitForUnpaused = function()
		while Enableds.Wins and LocalPlayer.GameplayPaused do
			task.wait(0.1)
		end
	end

	task.spawn(function()
		while Enableds.Wins do
			task.wait(0.5)

			local sortCheckpoints = {}

			for _, checkpoint in ipairs(checkpointFolder:GetChildren()) do
				if not Enableds.Wins then break end

				local checkpointName = checkpoint.Name
				local checkpointNum = tonumber(checkpointName:match("%d+") or "")
				if not checkpointNum then continue end

				local spawnPointPart = checkpoint:QueryDescendants("BasePart#SpawnPoint")[1]
				if not spawnPointPart then continue end

				table.insert(sortCheckpoints, {
					Name = checkpointName,
					Tier = checkpointNum,
					SpawnPoint = spawnPointPart,
					Hitbox = checkpoint:FindFirstChild("Hitbox") -- Ditambahkan agar v.Hitbox tidak nil
				})
			end

			if not Enableds.Wins then table.clear(sortCheckpoints) break end		

			table.sort(sortCheckpoints, function(a, b)
				return a.Tier < b.Tier
			end)

			for i, v in ipairs(sortCheckpoints) do
				-- Pastikan game tidak dalam kondisi paused sebelum melangkah
				waitForUnpaused()
				if not Enableds.Wins then break end

				local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
				local spawnPoint = v.SpawnPoint
				local hitbox = v.Hitbox

				if spawnPoint and rootPart and Enableds.Wins then
					PlayerRequestStreamAroundAsync(spawnPoint.Position, 5)
					TeleportTo(spawnPoint.CFrame)

					-- Tunggu jika game terkena GameplayPaused setelah teleportasi
					waitForUnpaused()

					if hitbox and rootPart then
						FireTouch(rootPart, hitbox)
					end

					local attempt = 50

					-- PERBAIKAN: Gunakan AND bukan OR agar loop langsung berhenti saat checkpoint ter-update
					while Enableds.Wins and (ProfileData.LastCheckpoint ~= spawnPoint) and attempt > 0 do
						attempt -= 1
						waitForUnpaused()
						task.wait(0.05)
					end

					-- PERBAIKAN: Penanganan logika gagal dengan kurung yang benar
					if (ProfileData.LastCheckpoint ~= nil and ProfileData.LastCheckpoint ~= spawnPoint) and attempt <= 0 then
						-- Jika gagal mengambil checkpoint setelah attempt habis, lewati/ulang
						break
					end
				end

				if i == CheckpointIndex then break end
			end

			if not Enableds.Wins then table.clear(sortCheckpoints) break end	

			waitForUnpaused()

			local stagePart = GetNearest("#NormalWin > BasePart#Button", stageFolder:GetChildren(), 150)
			if stagePart and Enableds.Wins then
				PlayerRequestStreamAroundAsync(stagePart.Position, 5)
				TeleportTo(stagePart.CFrame)
			end

			task.wait(0.2)
			table.clear(sortCheckpoints)
		end
	end)
end

local function HandleEquipBestTail()
	local worldStats = WorldData["World"..ProfileData.World]
	if not worldStats then return end

	local upgradeFolder = worldStats.Upgrades
	if not upgradeFolder then return end

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

local function HandleSukenShard()
	if SunkenShardFolder then
		for _, sukenShard in ipairs(SunkenShardFolder:GetChildren()) do
			local hitbox = sukenShard:FindFirstChild("Hitbox")
			local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
			if hitbox and rootPart then
				FireTouch(rootPart, hitbox)
			end
		end
	end
end

local function HandleFinishRace()
	local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end -- Batalkan jika karakter tidak ada

	-- Setup Raycast: Titik awal di pemain, arah ke bawah sepanjang 100 stud
	local rayOrigin = rootPart.Position
	local rayDirection = Vector3.new(0, -100, 0)

	-- Abaikan karakter pemain agar raycast tidak mengenai diri sendiri
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	-- Lakukan Raycast
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	if raycastResult then
		local hit = raycastResult.Instance
		if not hit then return end

		local target = hit

		while target ~= workspace do
			task.wait()

			for _, child in ipairs(target:GetChildren()) do
				if child:IsA("Model") and child.Name:find("Finish") then
					target = child
					break
				end
			end

			if target and target:IsA("Model") and target.Name:find("Finish") then
				break
			end

			target = target.Parent
		end

		if not (target and target:IsA("Model") and target.Name:find("Finish")) then
			return
		end
		
		while LocalPlayer.GameplayPaused do
			task.wait(0.1)
		end
		
		-- Jika model Finish ditemukan, teleportasi karakter
		if target then
			local newCFrame = target:GetPivot()
			PlayerRequestStreamAroundAsync(newCFrame.Position, 5)
			TeleportTo(newCFrame)
		end
	end
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

Window:AddSlider({
	Text = "Checkpoint",
	Range = {1, 1000},
	Value = 5,
	Increment= 1,
	Flag = "checkpoint_index",
	Callback = function(value)
		CheckpointIndex = value
	end
})

Window:AddToggle({
	Text = "Wins Farm",
	Value = false,
	Flag = "wins_enabled",
	Callback = function(value)
		Enableds.Wins = value
		if value then
			HandleWins()
		end
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

Window:AddButton({
	Text = "Collect Suken Shard",
	MethodType = "DebounceClick",
	Callback = HandleSukenShard
})

Window:AddButton({
	Text = "Finish Race",
	MethodType = "DebounceClick",
	Callback = HandleFinishRace
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 07-27-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
