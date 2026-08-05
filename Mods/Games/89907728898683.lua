local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Packets = {}
local Enableds, Connections = {["Pickup"] = false, ["Upgrade"] = false, ["Quest"] = false}, {}

local QuestScroll = PlayerGui:QueryDescendants("#QuestGui > #ActiveQuestFrame > #ScrollingFrame")[1]

local UpgradeTypes, UpgradeActives = {"Capacity", "Cooldown", "Yield", "Rake Speed", "Rake Area", "Rake Range", "Blower Range", "Blower Radius", "Blower Cooldown", "Lucky Chance", "Sell Multiplier"}, {}
local UpgradeInfos = {
	["Capacity"] = {
		Key = "Capacity",
		Hitbox = nil
	},
	["Cooldown"] = {
		Key = "Cooldown"
	},
	["Yield"] = = {
		Key = "Yield"
	},
	["Rake Speed"] = {
		Key = "RakeSpeed"
	},
	["Rake Area"] = {
	    Key = "RakeArea"
	},
	["Rake Range"] = {
		Key = "RakeRange"
	},
	["Blower Range"] = {
		Key = "BlowerRange"
	},
	["Blower Radius"] = {
	    Key = "BlowerRadius"
	},
	["Blower Cooldown"] = {
		Key = "BlowerCooldown"
	},
	["Lucky Chance"] = {
		Hitbox = nil
	},
	["Sell Multiplier"] = {
		Hitbox = nil
	}
}

UpgradeActives.AllEnabled = false
for index, mode in ipairs(UpgradeTypes) do
	UpgradeActives[mode] = mode == "Capacity" or mode == "Cooldown" or mode == "Yield" or false
end

Packets.SendUpgrade = ReplicatedStorage:QueryDescendants("#Remotes > #UpgradeRequest")[1]
Packets.SendPickup = ReplicatedStorage:QueryDescendants("#Remotes > #LeafPickedUp")[1]

local BasementUpgradeFolder = workspace:FindFirstChild("BasementUpgrades")
local LeafFolder = workspace:FindFirstChild("LeafFolder")
local AreasFolder = workspace:FindFirstChild("Areas")
local SecretStarsFolder = workspace:FindFirstChild("SecretStars")

if BasementUpgradeFolder then
  UpgradeInfos["Capacity"].Hitbox = BasementUpgradeFolder:FindFirstChild("CapacityUpgradeButton")
  UpgradeInfos["Sell Multiplier"].Hitbox = BasementUpgradeFolder:FindFirstChild("CashMultiplierUpgradeButton")
  UpgradeInfos["Lucky Chance"].Hitbox = BasementUpgradeFolder:FindFirstChild("LuckyUpgradeButton")
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local CollectSecretStarButton = nil

local function FireTouch(hitPart, targetPart)
	if firetouchinterest and hitPart and targetPart then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

local function FireButton(button)
	if firesignal and button then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function HandlePickup()
	if not Enableds.Pickup then return end

	-- Patched --
	--[[
	task.spawn(function()
		while Enableds.Pickup do
			for index, child in ipairs(AreasFolder:GetChildren()) do
				if not Enableds.Pickup then break end
				if not (child and child.Parent) then continue end
				local areaName = child.Name
				Packets.SendPickup:FireServer(
					{
						{
							AreaName = areaName,
							IsLucky = false
						},
						{
							AreaName = areaName,
							IsLucky = false
						},
						{
							AreaName = areaName,
							IsLucky = false
						},
						{
							AreaName = areaName,
							IsLucky = false
						},
						{
							AreaName = areaName,
							IsLucky = false
						}
					}
				)
				task.wait(0.1)
			end
			task.wait(0.5)
		end
	end)
	]]
	
	task.spawn(function()
		while Enableds.Pickup do
			for _, part in ipairs(LeafFolder:GetChildren()) do
				if not Enableds.Pickup then break end
				if not (part and part.Parent) then continue end
				
				local areaName = part:GetAttribute("AreaName")
				local leafIndex = part:GetAttribute("LeafIndex")
				local position = part.CFrame.Position
				
				Packets.SendPickup:FireServer(
					{
						{
							IsLucky = false,
							AreaName = areaName,
							LeafIndex = leafIndex,
							Position = position
						}
					}
				)
				task.wait(0.1)
			end
			task.wait(1)
		end
	end)
end

local function HandleUpgrade()
	if not Enableds.Upgrade then return end

	task.spawn(function()
		while Enableds.Upgrade do
			for mode, active in pairs(UpgradeActives) do
				if not Enableds.Upgrade then break end
				if mode == "AllEnabled" then continue end
				if UpgradeActives.AllEnabled then active = true end
				if not active then continue end
				local info = UpgradeInfos[mode]
				if not info then continue end
				if info.Key then
				   Packets.SendUpgrade:FireServer(info.Key)
			       task.wait()
				end
				if info.Hitbox then
					local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
					FireTouch(rootPart, info.Hitbox)
				    task.wait()
				end
			end
			task.wait(1)
		end
	end)
end

local function HandleQuest()
	if not Enableds.Quest then return end

	task.spawn(function()
		while Enableds.Quest do
			if QuestScroll then
				for index, child in ipairs(QuestScroll:GetChildren()) do
					if not Enableds.Quest then break end
					if not (child and child.Parent) then continue end
					if child.Name ~= "QuestCard" then continue end
					local buttonFrame = child:FindFirstChild("ButtonFrame")
					if not buttonFrame then continue end
					local claimButton = buttonFrame:FindFirstChild("ClaimButton")
					if not claimButton then continue end
					local claimGradient = claimButton:FindFirstChild("ClaimGradient")
					if claimGradient and claimGradient.Enabled == false then continue end
					FireButton(claimButton)
					task.wait()
				end
			end
			task.wait(0.5)
		end
	end)
end

local function IsSecretStarDone()
	if SecretStarsFolder then
		local done = true
		for _, star in ipairs(SecretStarsFolder:GetChildren()) do
			if star and star.Parent and star:IsA("BasePart") and star.Transparency <= 0 then
				done = false
			end
		end
		return done
	end
	return nil
end

local function HandleSecretStar()
    if not SecretStarsFolder then return end

	local wasSecretStarDone = IsSecretStarDone()
	
	if wasSecretStarDone then
		if CollectSecretStarButton then
			CollectSecretStarButton.Visible = false
		end
		return
	end

	local rootPart = Character and Character:FindFirstChild("HumanoidRootPart")

	for _, star in ipairs(SecretStarsFolder:GetChildren()) do
		if star and star.Parent and star:IsA("BasePart") and star.Transparency == 0 then
			if rootPart then
				FireTouch(rootPart, star)
			end
		end
	end 

	task.wait(1)

	wasSecretStarDone = IsSecretStarDone()
	
	if wasSecretStarDone  then
		if CollectSecretStarButton then
			CollectSecretStarButton.Visible = false
		end
	end
end

local Window = UI:CreateWindow({
	Name = "Garden Cleaner Evolution",
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
	Text = "Auto Pickup",
	Value = false,
	Flag = "pickup_enabled",
	Callback = function(value)
		Enableds.Pickup = value
		HandlePickup()
	end
})

Window:AddDropdown({
	Text = "Upgrade Type (Empty = All)",
	Options = #UpgradeTypes > 0 and UpgradeTypes or {"No Upgrade Type"},
	Option = {UpgradeTypes[1], UpgradeTypes[2], UpgradeTypes[3]},
	MultipleOptions = true,
	Flag = "upgrade_options",
	Callback = function(option)
		UpgradeActives.AllEnabled = #option <= 0

		for _, mode in ipairs(UpgradeTypes) do
			UpgradeActives[mode] = table.find(option, mode) ~= nil and true or false
		end
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

Window:AddToggle({
	Text = "Claim Quest",
	Value = false,
	Flag = "quest_enabled",
	Callback = function(value)
		Enableds.Quest = value
		HandleQuest()
	end
})

CollectSecretStarButton = Window:AddButton({
	Text = "Collect Secret Star",
	MethodType = "DebounceClick",
	Callback = HandleSecretStar
})

local wasSecretStarDone = IsSecretStarDone()
if wasSecretStarDone ~= nil and wasSecretStarDone then
	CollectSecretStarButton.Visible = false
end

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-2-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
