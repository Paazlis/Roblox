local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local SwordFolder = workspace:FindFirstChild("SwordsRuntime")

local Enableds, Connections, Packets = {Merge = false, Upgrade = false, Rebirth = false}, {}, {}
local SwordCache = {}
local TeleportCFrame = nil
local UpgradeTypes, UpgradeActives, UpgradeInfos = {}, {}, {}
UpgradeActives["AllEnabled"] = true

local RebirthButton = PlayerGui:QueryDescendants("#ScreenGui > #Frames > #Rebirth > #Main > #Holder > #Buttons > #RebirthButton")[1]

Packets.Event = Packets.Event or ReplicatedStorage:QueryDescendants("#NetRemotes > #Event")[1]

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

Connections.TeleportLoop = RunService.Heartbeat:Connect(function()
	if TeleportCFrame ~= nil then
		Character:PivotTo(TeleportCFrame)
	end
end)

local function TryAttribute(instance, name, attemptCount)
	if not (instance ~= nil and instance.Parent ~= nil) then return nil end
	local value = instance:GetAttribute(name)
	if value ~= nil then return value end
	local attempt = attemptCount or 10
	while attempt > 0 and value == nil and instance.Parent ~= nil do
		value = sword:GetAttribute(name)
		if value ~= nil then return value end
		attempt -= 1
		task.wait(1)
	end
	return value
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
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
						task.wait(0.05)
					end
				else
					local info = list[1]
					if not info then continue end

					local button = info.UpgradeButton
					if not button then continue end

					FireButton(button)
				end

				task.wait(0.05)
			end
			task.wait(0.5)
		end
	end)
end

local function HandleMerge()
	if not Enableds.Merge then return end

	task.spawn(function()
		local filterMerges = {}

		while Enableds.Merge do
			filterMerges = {}
			for _, sword in ipairs(SwordFolder:GetChildren()) do
			    if not Enableds.Merge then break end
			    if not (sword ~= nil and sword.Parent ~= nil and sword:IsA("Model")) then continue end
			    local ownerId, swordId = sword:GetAttribute("OwnerUserId"), sword:GetAttribute("SwordId")
			    if not (ownerId ~= nil and swordId ~= nil) then continue end
				if tostring(ownerId) ~= tostring(LocalPlayer.UserId) then continue end
				if not filterMerges[swordId] then 
					filterMerges[swordId] = {}
				end
				table.insert(filterMerges[swordId], sword)
				task.wait()
				if #filterMerges[swordId] >= 2 then
					Packets.Event:FireServer("DropSword", nil)
					local cframe, size = Character:GetBoundingBox()
					for i = 1, 2 do
						if not Enableds.Merge then break end
						local newSword = table.remove(filterMerges[swordId])
						if not (newSword ~= nil and newSword.Parent ~= nil) then continue end
			            local targetPart = newSword.PrimaryPart or newSword:FindFirstChild("Handle")
						if targetPart then
							--[[if i == 2 then
								local humanoid = Character:FindFirstChildOfClass("Humanoid")
								if humanoid then
									humanoid:MoveTo(targetPart.Position)
									humanoid.MoveToFinished:Wait()
								end
							else]]
						     	Character:PivotTo(CFrame.new(Vector3.new(targetPart.Position.X, Character.PrimaryPart.Position.Y, targetPart.Position.Z)))
							--end
						end
						task.wait(0.3)
					end
				end
			end
			task.wait(1)
		end
	end)
end

local function HandleRebirth()
	if not Enableds.Rebirth then return end

	task.spawn(function()
		while Enableds.Rebirth do
			FireButton(RebirthButton)
			task.wait(5)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Merge Swords And Kill Zombies", 
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
	Text = "Auto Merge",
	Value = false,
	Callback = function(value)
		Enableds.Merge = value
		HandleMerge()
	end
})

local UpgradeDropdown = Window:AddDropdown({
	Text = "Upgrade Type (Empty = All)",
	Options = #UpgradeTypes > 0 and UpgradeTypes or {"No Upgrade Type"},
	Option = nil,
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

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-09-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

task.spawn(function()
	local UpgradeScroll = PlayerGui:QueryDescendants("#ScreenGui > #Frames > #Upgrades > #Main > #Cards")[1]
	if UpgradeScroll then
		local sortUpgrades = {}

		for _, layer in ipairs(UpgradeScroll:GetChildren()) do
			if layer and layer.Parent and layer:IsA("GuiObject") then
				local buyButton = layer:QueryDescendants("#Buy > #BuyButton")[1]
				if not buyButton then continue end

				local title = layer:FindFirstChild("Header")
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
		end

		table.sort(sortUpgrades, function(a, b)
			return a.Tier < b.Tier
		end)

		for _, info in ipairs(sortUpgrades) do
			table.insert(UpgradeTypes, info.Name)
		end

		UpgradeDropdown.Options = UpgradeTypes
		UpgradeDropdown:Refresh()
	end
end)
