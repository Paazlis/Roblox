---- Win HitBox --
--workspace.Generated.Progression.WinBoxes.WinBoxNormal_Stage03.Hitbox
--workspace.Generated.Progression.WinBoxes


---- Checkpoint --
--workspace.Generated.Zones
--workspace.Generated.Zones.Zone_04.ZoneHitbox_04 -- Different as Wins


local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Executier = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Executier/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds = {["LevelUp"] = false, ["Wins"] = false, ["Rebirth"] = false}
local Connections = {}
local Packets = {
	["LongEarningIntent"] = ReplicatedStorage:QueryDescendants("#RuntimeRemoteEvents > #LongEarningIntentEvent")[1]
}

local Values = {
	["Checkpoint"] = 5
}
local Interfaces = {
	["RebirthButton"] = PlayerGui:QueryDescendants("#MainUI > #Frames > #Rebirth > #Main > #Holder > #Frame > #Rebirth")[1],
	["RebirthFill"] = PlayerGui:QueryDescendants("#MainUI > #Frames > #Rebirth > #Main > #Holder > #RequirementsFrame > #ProgressCanvas > #Main > #Progress")[1]
}

Values.CheckpointFolder = workspace:QueryDescendants("#Generated > #Zones")[1]
Values.ProgressionFolder = workspace:QueryDescendants("#Generated > #Progression")[1]

if Values.ProgressionFolder then
	Values.StretchPadsFolder = Values.ProgressionFolder:QueryDescendants("#HomeBase > #StretchPads")[1]
	Values.WinsFolder = Values.ProgressionFolder:FindFirstChild("WinBoxes")
end


local ProfileData = LocalPlayer:GetAttributes()

if ProfileData.EquippedStretchPad ~= nil then
	Connections.EquippedStretchPadChanged = LocalPlayer:GetAttributeChangedSignal("EquippedStretchPad"):Connect(function()
		ProfileData.EquippedStretchPad = LocalPlayer:GetAttribute("EquippedStretchPad")
	end)
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local Window = UI:CreateWindow({
	Name = "+1 Long Arm Toy Escape",
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

Interfaces.LevelUpToggle = Window:AddToggle({
	Text = "Level Up",
	Value = false,
	Callback = function(value)
		Enableds.LevelUp = value

		if not Packets.LongEarningIntent then
			Enableds.LevelUp = false
			Interfaces.LevelUpToggle:Replace(false)
			return
		end
		
		Packets.LongEarningIntent:FireServer(Enableds.LevelUp)
	end
})

Window:AddSlider({
	Text = "Checkpoint",
	Range = {1, 25},
	Value = Values.Checkpoint,
	Increment = 1,
	Callback = function(value)
		Values.Checkpoint = value
	end
})

Interfaces.RebirthToggle = Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Callback = function(value)
		Enableds.Rebirth = value
		
		if not Enableds.Rebirth then return end

		if not (Interfaces.RebirthFill and Interfaces.RebirthButton) then
			Enableds.Rebirth = false
			Interfaces.RebirthToggle:Replace(false)
			return
		end

		task.spawn(function()
			while Enableds.Rebirth do
				if Interfaces.RebirthFill.Size.X.Scale >= 1 then
					Executier.FireButton(Interfaces.RebirthButton)
				end
				task.wait(0.5)
			end
		end)
	end
})

Window:AddButton({
	Text = "Equip Best",
	MethodType = "DebounceClick",
	Callback = function()
		if not Values.StretchPadsFolder then return end
		
		local sortStretchPads = {}
		
		for _, v in ipairs(Values.StretchPadsFolder:GetChildren()) do
			if v and v.Parent then
				if not v.Name:find("Stretch") then continue end
				local tier = tonumber(v.Name:match("%d+") or "")
				if not tier then continue end
				local hitbox = v:FindFirstChild("Hitbox")
				if not hitbox then continue end
				table.insert(sortStretchPads, {
					["Tier"] = tier,
					["Hitbox"] = hitbox
				})
				task.wait()
			end
		end
		
		table.sort(sortStretchPads, function(a, b)
			return a.Tier < b.Tier
		end)
		
		local currentTier = ProfileData.EquippedStretchPad == nil and 0 or ProfileData.EquippedStretchPad
		
		for _, v in ipairs(sortStretchPads) do
			if v.Tier <= currentTier then
				Executier.FireTouch(Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart"), v.Hitbox)
				task.wait()
			end
		end
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
