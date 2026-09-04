local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds = {["LevelUp"] = false, ["Wins"] = false, ["Rebirth"] = false, ["Value"] = false}
local Connections = {}
local Packets = {
	["LongEarningIntent"] = ReplicatedStorage:QueryDescendants("#RuntimeRemoteEvents > #LongEarningIntentEvent")[1]
}

local Values = {
	["Checkpoint"] = 5,
	["WinCache"] = {}
}
local Interfaces = {
	["RebirthButton"] = PlayerGui:QueryDescendants("#MainUI > #Frames > #Rebirth > #Main > #Holder > #Frame > #Rebirth")[1],
	["RebirthFill"] = PlayerGui:QueryDescendants("#MainUI > #Frames > #Rebirth > #Main > #Holder > #RequirementsFrame > #Main > #Main > #Progress")[1]
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

local function FireTouch(part1,part2)
	if firetouchinterest then
		if not (part1 and part1.Parent and part2 and part2.Parent) then return end
		firetouchinterest(part1,part2,1)
		task.wait()
		if not (part1 and part1.Parent and part2 and part2.Parent) then return end
		firetouchinterest(part1,part2,0)
	end
end

local function FireButton(button)
	if firesignal then
		if not (button and button.Parent) then return end
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function KeepRotationPivotTo(model, rootPart, position) 
	local orientation = rootPart.Orientation
	local rotation = CFrame.fromEulerAngles(math.rad(orientation.X), math.rad(orientation.Y), math.rad(orientation.Z), Enum.RotationOrder.YXZ)
	model:PivotTo(CFrame.new(position) * rotation)
end

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
	Text = "Auto Train",
	Value = false,
	Callback = function(value)
		Enableds.LevelUp = value

		if not Packets.LongEarningIntent then
			Enableds.LevelUp = false
			Interfaces.LevelUpToggle:Replace(false)
			return
		end

		Packets.LongEarningIntent:FireServer(Enableds.LevelUp)

		task.spawn(function()
			while Enableds.LevelUp do
				Packets.LongEarningIntent:FireServer(true)
				task.wait(1)
			end
		end)
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

Interfaces.WinsToggle = Window:AddToggle({
	Text = "Auto Wins (Last Area)",
	Value = false,
	Callback = function(value)
		Enableds.Wins = value

		if not Enableds.Wins then return end

		if not (Values.WinsFolder and Values.CheckpointFolder) then
			Enableds.Wins = false
			Interfaces.WinsToggle:Replace(false)
			return
		end

		task.spawn(function()
			while Enableds.Wins do
				task.wait()
				
				ProfileData.Stage = 0
				
				local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
				local humanoid = Character:FindFirstChildOfClass("Humanoid")

				local totalZones = #Values.WinsFolder:GetChildren()

				for stage = 1, totalZones do
					local stageStr = string.format("%02d", stage + 1)

					local zoneModel = Values.CheckpointFolder:FindFirstChild("Zone_" .. stageStr)
					if zoneModel then
						local zoneHitbox = zoneModel:FindFirstChild("ZoneHitbox_" .. stageStr) or zoneModel:FindFirstChildWhichIsA("BasePart")
						if zoneHitbox then
							KeepRotationPivotTo(Character, rootPart, zoneHitbox.Position)
							ProfileData.Stage += 1
							task.wait(0.3)
						end
					end
					task.wait()
				end
				
				if ProfileData.Stage == ProfileData.Checkpoint then
					local stageStr = string.format("%02d", ProfileData.Stage)
					
					local winBox = Values.WinsFolder:WaitForChild("WinBoxNormal_Stage" .. stageStr)
					if winBox then
						local winHitbox = winBox:FindFirstChild("Hitbox") or winBox:FindFirstChildWhichIsA("BasePart")
						if winHitbox then
							KeepRotationPivotTo(Character, rootPart, winHitbox.Position)
							ProfileData.Stage = 0
							task.wait(0.3)
						end
					end
				end

				
				task.wait(1)
			end
		end)

		-- Win HitBox --
		--workspace.Generated.Progression.WinBoxes.WinBoxNormal_Stage03.Hitbox
		--workspace.Generated.Progression.WinBoxes


		-- Checkpoint --
		--workspace.Generated.Zones
		--workspace.Generated.Zones.Zone_04.ZoneHitbox_04 -- Different as Wins
	end
})

Interfaces.EquipToggle = Window:AddToggle({
	Text = "Equip Best",
	Value = false,
	Callback = function(value)
		Enableds.Equip = value

		if not Values.StretchPadsFolder then
			Enableds.Equip = false
			Interfaces.EquipToggle:Replace(false)
			return 
		end

		task.spawn(function()
			while Enableds.Equip do
				local sortStretchPads = {}

				for _, v in ipairs(Values.StretchPadsFolder:GetChildren()) do
					if not Enableds.Equip then break end
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

				if not Enableds.Equip then break end

				table.sort(sortStretchPads, function(a, b)
					return a.Tier < b.Tier
				end)

				local currentTier = ProfileData.EquippedStretchPad == nil and 0 or tonumber(tostring(ProfileData.EquippedStretchPad):match("%d+") or "0")

				for _, v in ipairs(sortStretchPads) do
					if not Enableds.Equip then break end

					if v.Tier >= currentTier then
						FireTouch(Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart"), v.Hitbox)
						task.wait()
					end
				end

				task.wait(3)
			end
		end)
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
					FireButton(Interfaces.RebirthButton)
				end
				task.wait(0.5)
			end
		end)
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo V2",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Services.GuiService:SetGameplayPausedNotificationEnabled(false)
