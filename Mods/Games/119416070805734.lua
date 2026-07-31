local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local TweenService = Services.TweenService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RebirthNotify = PlayerGui:QueryDescendants("#MainUI > #LeftButtons > #Holder > #Rebirth > #Notify > #TextLabel")[1]
local WinsFolder = workspace:QueryDescendants("#StageWinPaths > #Normal")[1]
local SpeedsFolder = workspace:QueryDescendants("#Map > #SpeedTools")[1]

-- Pastikan variabel 'Character' sudah didefinisikan di script Anda
local function TeleportTo(targetCFrame, mode)
	if mode and mode == 1 then
		task.wait(0.1)
	end
	
	if not mode or mode == 0 or mode == 1 then
		Character:PivotTo(targetCFrame)
	end

	if true then return end
	local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- Konfigurasi Animasi
	local durasi = 0.25 -- Durasi animasi (detik)
	local tinggi = 15 -- Seberapa tinggi karakter naik/turun
	local tweenInfo = TweenInfo.new(durasi, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

	-- 1. Bekukan karakter agar tidak jatuh karena gravitasi saat animasi
	--rootPart.Anchored = false

	-- 2. Animasi melayang ke atas di lokasi saat ini
	local upCFrame = rootPart.CFrame * CFrame.new(0, tinggi, 0)
	local tweenUp = TweenService:Create(rootPart, tweenInfo, {CFrame = upCFrame})
	tweenUp:Play()
	tweenUp.Completed:Wait() -- Tunggu animasi naik selesai

	-- 3. Teleportasi ke atas lokasi target secara instan
	local targetUpCFrame = targetCFrame * CFrame.new(0, tinggi, 0)
	Character:PivotTo(targetUpCFrame)

	-- 4. Animasi turun perlahan ke posisi target akhir
	local tweenDown = TweenService:Create(rootPart, tweenInfo, {["CFrame"] = targetCFrame})
	tweenDown:Play()
	tweenDown.Completed:Wait() -- Tunggu animasi turun selesai

	-- 5. Lepaskan kembali karakter agar bisa berjalan normal
	--rootPart.Anchored = false
end


local Packets = {
	["SendRebirth"] = ReplicatedStorage:QueryDescendants("#Remotes > #RebirthButtonEvent")[1]
}
local Enableds, Connections = {["Win"] = false, ["Rebirth"] = false}, {}

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

local function IsPercentFull(label)
	if label.Text:find("100") then
		return true
	end
	return false
end

--[[
local function TeleportTo(cframe)
	Character:PivotTo(cframe)
end
]]

-- Wins Function (Working) --
local function HandleWins()
	if not Enableds.Win then return end
	local sortWins = {}

	if WinsFolder then
		for _, pad in ipairs(WinsFolder:GetChildren()) do
			if not Enableds.Win then return end
			
			local padTier = tonumber(pad.Name:match("%d+") or "")
			if not padTier then continue end
			
			local padModel = nil
			if pad:IsA("Model") then
				padModel = pad
			end
			
			table.insert(sortWins, {
				Tier = padTier,
				Hitbox = pad:QueryDescendants("BasePart#Hitbox")[1],
				Model = padModel
			})
		end
	end
	
	if not Enableds.Win then return end
	
	table.sort(sortWins, function(a, b)
		return a.Tier > b.Tier
	end)
	
	if not Enableds.Win then return end
	
	task.spawn(function()
		while Enableds.Win do
			task.wait()

			local winStats = sortWins[1]
			if not winStats then continue end
			
			local model, hitbox, targetCFrame = winStats.Model, winStats.Hitbox, nil

			if hitbox ~= nil then
				targetCFrame = hitbox.CFrame
			elseif model ~= nil then
				targetCFrame = model:GetPivot()
			end
			
			if targetCFrame and Enableds.Win then
				Character:PivotTo(targetCFrame, 1)
			end
		end
	end)
end

-- Rebirth Function (Working) --
local function FireRebirth()
	if Enableds.Rebirth then
		if RebirthNotify ~= nil and not IsPercentFull(RebirthNotify) then
			return
		end
		Packets.SendRebirth:FireServer()
	end
end

local function HandleRebirth()
	if not Enableds.Rebirth then return end
	
	if RebirthNotify then
		Connections.Rebirth = RebirthNotify:GetPropertyChangedSignal("Text"):Connect(FireRebirth)
	end
	
	task.spawn(function()
		while Enableds.Rebirth do
			FireRebirth()
			task.wait(1)
		end
	end)
end

-- Equip Best Speed Function (WIP) --
local function HandleEquipBestSpeed()
	local saveCFrame = Character:GetPivot()
	
	local sortSpeeds = {}
	
	if SpeedsFolder then
		for _, pad in ipairs(SpeedsFolder:GetChildren()) do
			local padName = pad.Name
			local padTier = tonumber(padName:match("%d+") or "")
			if not padTier then continue end
			
			table.insert(sortSpeeds, {
				Tier = padTier,
				Hitbox = pad:QueryDescendants("BasePart#Hitbox")[1]
			})
		end

		table.sort(sortSpeeds, function(a, b)
			return a.Tier < b.Tier
		end)
	end
	
	local teleporting = false
	
	for _, speedStats in ipairs(sortSpeeds) do
		local hitbox = speedStats.Hitbox
		if hitbox ~= nil then
			teleporting = true
			TeleportTo(hitbox.CFrame, 0)
		end
	end
	
	if teleporting then
		TeleportTo(saveCFrame)
	end
end

local Window = UI:CreateWindow({
	Name = "+1 Speed Phonk Escape",
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
	Text = "Wins Farm",
	Value = false,
	Flag = "wins_enabled",
	Callback = function(value)
		Enableds.Win = value
		HandleWins()
	end
})

Window:AddButton({
	Text = "Equip Best Phonk",
	MethodType = "DebounceClick",
	Callback = HandleEquipBestSpeed
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		Enableds.Rebirth = value
		if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
		HandleRebirth()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255),
})
