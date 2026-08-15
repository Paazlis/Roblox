local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Packets, Connections = {Money = false, Roll = false, Rebirth = false}, {}, {}

local RebirthFrame, RebirthCheck, RebirthButton = PlayerGui:QueryDescendants("#RebirthGui > #Frame")[1], nil, nil

if RebirthFrame then
	RebirthCheck, RebirthButton = RebirthFrame:FindFirstChild("RebirthLockedFrame"), RebirthFrame:QueryDescendants("#RebirthFrame > #RebirthButton")[1]
end

local LootCache = {}

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

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function FirePrompt(prompt)
	if fireproximityprompt then
		fireproximityprompt(prompt, 0)
	end
end

local function GetPlot()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end

	for _, plot in pairs(plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId ~= nil and ownerId == LocalPlayer.UserId then
			return plot
		end
	end

	return nil
end

local Plot = GetPlot()
local LootFolder = nil
local WeaponBox, WeaponPrompt = nil, nil
local GroupHitbox = nil

if Plot then
	GroupHitbox = Plot:QueryDescendants("#GroupReward > #CollectButton > #Button")[1]
	LootFolder = Plot:FindFirstChild("LootSpawned")
	WeaponBox = Plot:FindFirstChild("WeaponBox")
	if WeaponBox then
		WeaponPrompt = WeaponBox:QueryDescendants("#ProxPromptPart > #WeaponBoxPrompt")[1]
	end
end

local function HandleMoney()
	if Connections.LootAdded then Connections.LootAdded:Disconnect() Connections.LootAdded = nil end
	if Connections.LootRemoved then Connections.LootRemoved:Disconnect() Connections.LootRemoved = nil end
	if not Enableds.Money then return end
	Packets.CurrencyPickup = Packets.CurrencyPickup or ReplicatedStorage:QueryDescendants("#RemoteEvents > #CurrencyPickup")[1]
	Connections.LootAdded = LootFolder.ChildAdded:Connect(function(part)
		task.wait(1)
		if not Enableds.Money then return end
		if not (part and part.Parent and part:IsA("BasePart")) then return end
		if LootCache[part] ~= nil then return end
		LootCache[part] = true
		Packets.CurrencyPickup:FireServer({part.Name})
	end)
	Connections.LootRemoved = LootFolder.ChildRemoved:Connect(function(part)
		if LootCache[part] ~= nil then
			LootCache[part] = nil
		end
	end)
	task.spawn(function()
		local list = {}
		while Enableds.Money do
			table.clear(list)
			for _, part in ipairs(LootFolder:GetChildren()) do
				if not Enableds.Money then break end
				if not (part and part.Parent and part:IsA("BasePart")) then
					if LootCache[part] ~= nil then
						LootCache[part] = nil
					end
					continue
				end
				local key = part.Name
				if LootCache[part] == nil then
					LootCache[part] = true
					table.insert(list,key)
				end
				task.wait()
			end
			if #list > 0 and Enableds.Money then
				Packets.CurrencyPickup:FireServer(list)
			end
			task.wait(1)
		end
	end)
end

local function FireRebirth()
	if Enableds.Rebirth and RebirthCheck.Visible == false then
		FireButton(RebirthButton)
	end
end

local function HandleRebirth()
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end
	Connections.Rebirth = RebirthCheck:GetPropertyChangedSignal("Visible"):Connect(FireRebirth)
	task.spawn(function()
		while Enableds.Rebirth do
			FireRebirth()
			task.wait(0.5)
		end
	end)
end

local function HandleRoll()
	if not Enableds.Roll then return end
	task.spawn(function()
		while Enableds.Roll do
			if WeaponPrompt.Enabled and WeaponPrompt.ActionText == "Open" then
				FirePrompt(WeaponPrompt)
				repeat task.wait() until not Enableds.Roll or (WeaponPrompt.Enabled and WeaponPrompt.ActionText == "Buy")
				if Enableds.Roll then
					FirePrompt(WeaponPrompt)
				end
			end
			task.wait(0.5)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Build a Gun Army", 
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
	Text = "Open & Buy Weapon",
	Value = false,
	Callback = function(value)
		Enableds.Roll = value
		HandleRoll()
	end
})

Window:AddToggle({
	Text = "Collect Money",
	Value = false,
	Callback = function(value)
		Enableds.Money = value
		HandleMoney()
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Callback = function(value)
		Enableds.Rebirth = value
		HandleRebirth()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-10-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Services.GuiService:SetGameplayPausedNotificationEnabled(false)
