
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

local Enableds, Connections, Packets = {Aim = false, Upgrade = false, Sell = false, Shoot = false}, {}, {}
local AimSettings = {Speed = 0.8}

local DummyFolder = nil

local UpgradeTypes, UpgradeActives, UpgradeInfos, UpgradeOption = {}, {}, {}, {}
UpgradeActives["AllEnabled"] = true
local WeaponCache = {}

local RebirthFrame, RebirthFill, RebirthButton = nil, nil, nil
local UpgradeScroll = PlayerGui:QueryDescendants("#HUD > #Frames > #Upgrades > #ScrollingFrame")[1]
local QuestScroll = nil

if UpgradeScroll then
	local sortUpgrades = {}
	
	for _, layer in ipairs(UpgradeScroll:GetChildren()) do
		local buyButton = layer:FindFirstChild("Plus")
		if not buyButton then continue end

		local title = layer:FindFirstChild("Title")
        if not title then continue end

		local key = title.Text

		if not UpgradeInfos[key] then
			UpgradeInfos[key] = {}
			UpgradeActives[key] = false
			table.insert(sortUpgrades, {
				Name = key,
				Tier = layer.LayoutOrder,
			})
		end

		table.insert(UpgradeInfos[key], {
		   Name = key,
		   UpgradeButton = buyButton
		})
	end

	table.sort(sortUpgrades, function(a, b)
		return a.Tier < b.Tier
	end)

	for _, info in ipairs(sortUpgrades) do
		table.insert(UpgradeTypes, info.Name)
	end
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

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

local function WeaponAdded(weapon)
   if weapon and weapon.Parent and weapon.Name:find("_Orbit_" .. tostring(LocalPlayer.UserId)) ~= nil and WeaponCache[child] == nil  then
         local newName = string.gsub(weapon.Name, "_Orbit_%d+", "")
        
         WeaponCache[weapon] = newName

        local ancestryChanged = nil
        ancestryChanged = weapon.AncestryChanged:Connect(function(_, parent)
            if not parent or not weapon:IsDescendantOf(workspace) then
               WeaponCache[weapon] = nil
               ancestryChanged:Disconnect()
            end
        end)
    end
end

local function HandleShoot()
  if Connections.WeaponAdded then Connections.WeaponAdded:Disconnect() Connections.WeaponAdded = nil end
  if not Enableds.Shoot then return end

  Packets.DummyShoot = Packets.DummyShoot or ReplicatedStorage.Remotes.DummyShoot
  DummyFolder = DummyFolder or workspace:QueryDescendants("#PlayerDummies > #Shared")[1]
  
  Connections.WeaponAdded = workspace.ChildAdded:Connect(function(weapon)
      task.wait(2)
      WeaponAdded(weapon)
  end)
  
  for _, weapon in ipairs(workspace:GetChildren()) do
     WeaponAdded(weapon)
  end
  
	task.spawn(function()
		while Enableds.Shoot do
           for _, dummy in ipairs(DummyFolder:GetChildren()) do
              if not (dummy and dummy.Parent) then continue end
              local humanoid = dummy:FindFirstChildOfClass("Humanoid")
              if not humanoid or humanoid.Health <= 0 or humanoid.MaxHealth <= 0 then continue end
              if not (next(WeaponCache) and Enableds.Shoot) then break end
              repeat 
                 for _, weaponName in pairs(WeaponCache) do
					if not (dummy and dummy.Parent and Enableds.Shoot) then break end
                    Packets.DummyShoot:FireServer(dummy, weaponName)
                    task.wait()
                 end
                 task.wait(0.1)
              until not Enableds.Shoot or not dummy.Parent or not humanoid.Parent or humanoid.Health <= 0 or humanoid.MaxHealth <= 0 or not next(WeaponCache)
              task.wait()
           end
           task.wait(5)
		end
	end)
end

local function HandleUpgrade()
	if not Enableds.Upgrade then return end

	task.spawn(function()
		while Enableds.Upgrade do
			for key, active in pairs(UpgradeActives) do
				if not Enableds.Upgrade then break end
				if UpgradeActives.AllEnabled == true then active = true end
				if key == "AllEnabled" or not active then continue end

				local list = UpgradeInfos[key]
				if not list then continue end

				if #list > 1 then
					for _, info in ipairs(list) do
						if not Enableds.Upgrade then break end

						local button = info.UpgradeButton
						if not button then continue end

						FireButton(button)
						task.wait(0.1)
					end
				else
					local info = list[1]
					if not info then continue end

					local button = info.UpgradeButton
					if not button then continue end

					FireButton(button)
				end
				task.wait(0.1)
			end
			task.wait(1)
		end
	end)
end

local function HandleRebirth()
	if not Enableds.Rebirth then return end

	RebirthFrame = RebirthFrame or PlayerGui:QueryDescendants("#HUD > #Frames > #Rebirths")[1]

	if RebirthFrame then
		RebirthFill = RebirthFill or RebirthFrame:QueryDescendants("#Progress > #CanvasGroup > #Bar")[1]
		RebirthButton = RebirthButton or RebirthFrame:FindFirstChild("RebirthClaim")
	end

	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
		if IsFillFull(RebirthFill) and Enableds.Rebirth then
			FireButton(RebirthButton)
		end
	end)

	task.spawn(function()
		while Enableds.Rebirth do
			if IsFillFull(RebirthFill) then
				FireButton(RebirthButton)
			end
			task.wait(1)
		end
	end)
end

local function HandleQuest()
	if not Enableds.Quest then return end

	QuestScroll = QuestScroll or PlayerGui:QueryDescendants("#HUD > #Frames > #Quests > #ScrollingFrame")[1]
	
	task.spawn(function()
		while Enableds.Quest do
			for _, layer in ipairs(QuestScroll:GetChildren()) do
				if not Enableds.Quest then break end
				local claimButton = layer:FindFirstChild("Complete")
				if not claimButton or not claimButton.Visible then continue end
				FireButton(claimButton)
				task.wait(0.1)
			end
			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Roll to Survive",
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
	Text = "Auto Shoot",
	Value = false,
	Flag = "shoot_enabled",
	Callback = function(value)
		Enableds.Shoot = value
		HandleShoot()
	end
})

Window:AddDropdown({
	Text = "Upgrade Type (Empty = All)",
	Options = #UpgradeTypes > 0 and UpgradeTypes or {"No Upgrade Type"},
	Option = UpgradeOption,
	MultipleOptions = true,
	Flag = "upgrade_options",
	Callback = function(option)
		UpgradeActives["AllEnabled"] = #option <= 0
		for _, mode in ipairs(UpgradeTypes) do
			UpgradeActives[mode] = table.find(option, mode) ~= nil and true or false
		end
	end
})

Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Callback = function(value)
		Enableds.Upgrade = value
		HandleUpgrade()
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

Window:AddToggle({
	Text = "Claim Quest",
	Value = false,
	Callback = function(value)
		Enableds.Quest = value
		HandleQuest()
	end
})


Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-07-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

--[[

-- Rebirth --
game:GetService("Players").LocalPlayer.PlayerGui.HUD.Frames.Rebirths.Progress.CanvasGroup.Bar
game:GetService("Players").LocalPlayer.PlayerGui.HUD.Frames.Rebirths.RebirthClaim

-- Claim Quest --
game:GetService("Players").LocalPlayer.PlayerGui.HUD.Frames.Quests.ScrollingFrame.Slot1.Complete.Visible == true 

-- Upgrade --
game:GetService("Players").LocalPlayer.PlayerGui.HUD.Frames.Upgrades.ScrollingFrame.DamageBoost.Plus
game:GetService("Players").LocalPlayer.PlayerGui.HUD.Frames.Upgrades.ScrollingFrame.DamageBoost.Title

-- Playtime Reward --
game:GetService("Players").LocalPlayer.PlayerGui.HUD.Frames.Gifts.Gift7.Claim.Visible
game:GetService("Players").LocalPlayer.PlayerGui.HUD.Frames.Gifts.GiftsBottom.Gift4.Claim
game:GetService("Players").LocalPlayer.PlayerGui.HUD.Frames.Gifts.GiftsTop.Gift1.Claim


]]
