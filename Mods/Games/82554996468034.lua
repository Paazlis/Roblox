local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections = {["Win"] = false, ["Rebirth"] = false, ["BuyTrail"] = false}, {}
local RebirthFrame, RebirthFill, RebirthButton = PlayerGui:QueryDescendants("#Game > #Rebirths")[1], nil, nil
local TrailScroll = PlayerGui:QueryDescendants("#Game > #Trails > #Main > #ScrollingFrame")[1]

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

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local Window = UI:CreateWindow({
	Name = "+1 Pickaxe Swing Escape",
	Destroying = function()
		for key, value in pairs(Connections) do
			if value then
				value:Disconnect()
			end
		end

		for key, value in pairs(Enableds) do
			Enableds[key] = false
		end
	end
})

-- Tabel dinamis untuk konfigurasi world dan daftar opsi dropdown
local WorldConfigs = {}
local WorldOptions = {}
local SelectedWorld = ""

-- Fungsi untuk memperbarui WorldConfigs & WorldOptions secara otomatis
local function RefreshWorlds()
	table.clear(WorldConfigs)
	table.clear(WorldOptions)

	local worldsFolder = workspace:FindFirstChild("Worlds")
	if not worldsFolder then return end

	for _, worldObj in ipairs(worldsFolder:GetChildren()) do
		local worldName = worldObj.Name -- Contoh: "World1", "World2"
		local worldNum = worldName:match("%d+") -- Mengambil angka (misal: "1", "2")

		-- Mencari Map yang cocok di workspace (misal: Map1, Map2, atau Map)
		local mapObj = workspace:FindFirstChild("Map" .. (worldNum or ""))
		if not mapObj and worldNum == "1" then
			mapObj = workspace:FindFirstChild("Map")
		end

		-- Format nama yang ditampilkan pada UI Dropdown (contoh: "World 1")
		local displayName = worldNum and ("World " .. worldNum) or worldName

		if mapObj then
			WorldConfigs[displayName] = {
				MapFolder = mapObj,
				WorldFolder = worldObj
			}
			table.insert(WorldOptions, displayName)
		end
	end

	-- Urutkan nama World agar rapi
	table.sort(WorldOptions)

	-- Set opsi default jika tersedia
	if #WorldOptions > 0 and SelectedWorld == "" then
		SelectedWorld = WorldOptions[1]
	end
end

-- Jalankan pencarian awal
RefreshWorlds()

-- Helper function: Cari stage angka tertinggi
local function GetHighestStage(stagesFolder)
	if not stagesFolder then return nil end

	local highestNumber = -1
	local highestStage = nil

	for _, stage in ipairs(stagesFolder:GetChildren()) do
		local stageNum = tonumber(stage.Name:match("%d+$")) or tonumber(stage.Name:match("%d+"))
		if stageNum and stageNum > highestNumber then
			highestNumber = stageNum
			highestStage = stage
		end
	end

	return highestStage
end

-- Helper function: Cari HitBox terdekat
local function GetNearestHitBox(padList, maxDistance)
	local character = LocalPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

	local playerPos = character.HumanoidRootPart.Position
	local nearestHitBox = nil
	local shortestDistance = maxDistance or 150

	for _, pad in ipairs(padList) do
		local hitBox = pad:FindFirstChild("HitBox") or (pad:IsA("BasePart") and pad)
		if hitBox then
			local distance = (hitBox.Position - playerPos).Magnitude
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

-- Setup Dropdown UI menggunakan WorldOptions dinamis
Window:AddDropdown({
	Text = "World",
	Options = #WorldOptions > 0 and WorldOptions or {"No Worlds Found"},
	Option = WorldOptions[1] or nil,
	MultipleOptions = false,
	Flag = "world_options",
	Callback = function(option)
		if type(option) == "table" then
			SelectedWorld = option[1] or ""
		else
			SelectedWorld = option
		end
	end
})

-- Auto Wins Toggle Setup
Window:AddToggle({
	Text = "Auto Wins",
	Value = false,
	Flag = "win_enabled",
	Callback = function(value)
		if true then return end
		Enableds.Win = value

		if value then 
			task.spawn(function()
				while Enableds.Win do
					local config = WorldConfigs[SelectedWorld]

					if config and config.MapFolder and config.WorldFolder then
						local stagesFolder = config.MapFolder:FindFirstChild("Stages")
						local highestStage = GetHighestStage(stagesFolder)

						-- 1. Teleport ke stage tertinggi
						if highestStage then
							local stageCFrame = highestStage:IsA("Model") and highestStage:GetPivot() or highestStage.CFrame
							TeleportTo(stageCFrame)
							task.wait(0.3)
						end

						-- 2. Teleport ke WinPad terdekat
						local winPads = config.WorldFolder:FindFirstChild("DefaultWinPads")
						if winPads then
							local padList = winPads:GetChildren()
							local nearestHitBox = GetNearestHitBox(padList, 150)

							if nearestHitBox then
								TeleportTo(nearestHitBox.CFrame)
							end
						end
					end

					task.wait(0.5)
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Buy Trail",
	Value = false,
	Flag = "buy_trail_enabled",
	Callback = function(value)
		if true then return end
		Enableds.BuyTrail = value
		if value then
		
			task.spawn(function()	
				while Enableds.BuyTrail do
					task.wait(0.5)
					
					for _, trailLayer in ipairs(TrailScroll:GetChildren()) do
						task.wait()
						
						if not Enableds.BuyTrail then break end
						
						local buyButton = trailLayer:FindFirstChild("Buy")
						if not buyButton then continue end
						
						local buyFrame = buyButton:FindFirstChild("Frame")
						if buyFrame and buyFrame.Visible == false then
							continue
						end
						
						if Enableds.BuyTrail then
							FireButton(buyButton)
						end
					end
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		if true then return end
		if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
		if value then
			RebirthButton = RebirthButton or RebirthFrame:FindFirstChild("Rebirth")
			RebirthFill = RebirthFill or RebirthFrame:QueryDescendants("#Bar > #Progress")[1]
			
			Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
				if IsFillFull(RebirthFill) then
					FireButton(RebirthButton)
				end
			end)

			if IsFillFull(RebirthFill) then
				FireButton(RebirthButton)
			end
		end
	end
})

--Window:AddLabel("YouTube: Crokyreo")
