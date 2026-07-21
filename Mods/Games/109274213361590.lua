local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local UpgradeTypes, UpgradeActives, UpgradeButtons = {}, {}, {}
local Enableds, Connections = {["Merge"] = false, ["Upgrade"] = false, ["Rebirth"] = false}, {}
local RebirtFrame, RebirthButton, RebirthFill = PlayerGui:QueryDescendants("#Rebirth > #View")[1], nil, nil
local UpgradeScroll = PlayerGui:QueryDescendants("#Upgrade > #View > #Upgrades")[1]
local DropHeldTroopPacket = ReplicatedStorage:QueryDescendants("#Network > #DropHeldTroop")[1]
local TroopFolder, TroopCache = nil, {}

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

local function GetPlot()
	local plots = workspace:QueryDescendants("#ScriptableObjects > #Plots")[1]
	if not plots or plots.Name~="Plots" then return nil end

	for _, plot in ipairs(plots:GetChildren()) do
		local ownerId = plot:GetAttribute("Owner")
		if ownerId ~= nil and ownerId == LocalPlayer.UserId then
			return plot
		end
	end

	return nil
end

local Plot = GetPlot()
local ItemFolder = nil

for _, mode in ipairs(UpgradeTypes) do
	UpgradeActives[mode] = false
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)


if UpgradeScroll then
	for _, upgradeLayer in ipairs(UpgradeScroll:GetChildren()) do
		local backgroundFrame = upgradeLayer:FindFirstChild("Background")
		if not backgroundFrame then continue end

		local upgradeTitle = backgroundFrame:FindFirstChild("Title")
		if not upgradeTitle or not upgradeTitle:IsA("TextLabel") then continue end

		local upgradeButton = backgroundFrame:QueryDescendants("#ButtonContainer > #Purchase > #Container > #Button")[1]
		if not upgradeButton then continue end

		local upgradeKey = upgradeTitle.Text
		table.insert(UpgradeTypes, upgradeKey)
		UpgradeButtons[upgradeKey] = upgradeButton
	end
end

local Window = UI:CreateWindow({
	Name = "Merge an Army",
	Destroying = function()
		for key, value in pairs(Connections) do
			if value then
				value:Disconnect()
			end
		end

		for key, value in pairs(Enableds) do
			Enableds[key] = false
		end

		for _, mode in ipairs(UpgradeTypes) do
			UpgradeActives[mode] = false
		end

		local oldKey, oldTroop = next(TroopCache)
		while oldTroop do
			TroopCache[oldKey] = nil
			if oldTroop.NameConnection then
				oldTroop.NameConnection:Disconnect()
				oldTroop.NameConnection = nil
			end
			oldKey, oldTroop = next(TroopCache)
		end
	end
})

Window:AddToggle({
	Text = "Auto Merge",
	Value = false,
	Flag = "merge_enabled",
	Callback = function(value)
		Enableds.Merge = value

		-- Bersihkan koneksi lama jika ada
		if Connections["TroopAdded"] then Connections["TroopAdded"]:Disconnect() Connections["TroopAdded"] = nil end
		if Connections["TroopRemoved"] then Connections["TroopRemoved"]:Disconnect() Connections["TroopRemoved"] = nil end

		local oldKey, oldTroop = next(TroopCache)
		while oldTroop do
			TroopCache[oldKey] = nil
			if oldTroop.NameConnection then
				oldTroop.NameConnection:Disconnect()
				oldTroop.NameConnection = nil
			end
			oldKey, oldTroop = next(TroopCache)
		end

		if value then 

			TroopFolder = TroopFolder or workspace:QueryDescendants("#Prefabs > #TroopVisuals")[1]

			local function OnTroopAdded(troop)
				if not troop or not troop.Parent then return end

				task.wait(0.5)
				if not troop or not troop.Parent then return end

				local attributes = troop:GetAttributes()

				local troopInfo = {
					Instance = troop,
					Name = troop.Name,
					MaxHealth = attributes.MaxHealth,
					OwnerUserId = attributes.OwnerUserId,
					TroopId = attributes.TroopId,
					PrimaryPart = troop.PrimaryPart or troop:FindFirstChild("HumanoidRootPart"),
					IsHeld = string.find(troop.Name, "Held") ~= nil,
					NameConnection = nil
				}

				troopInfo.NameConnection = troop:GetPropertyChangedSignal("Name"):Connect(function()
					if troop and troop.Parent then
						troopInfo.Name = troop.Name
						troopInfo.IsHeld = string.find(troop.Name, "Held") ~= nil
					end
				end)

				TroopCache[troop] = troopInfo 
			end

			Connections["TroopAdded"] = TroopFolder.ChildAdded:Connect(OnTroopAdded)

			Connections["TroopRemoved"] = TroopFolder.ChildRemoved:Connect(function(troop)
				local troopInfo = TroopCache[troop]
				if troopInfo then
					if troopInfo.NameConnection then
						troopInfo.NameConnection:Disconnect()
						troopInfo.NameConnection = nil
					end
					TroopCache[troop] = nil
				end
			end)

			for _, troop in ipairs(TroopFolder:GetChildren()) do
				if not Enableds.Merge then break end
				task.spawn(OnTroopAdded, troop)
			end

			-- Main Merge Loop
			task.spawn(function()
				while Enableds.Merge do
					task.wait(0.5)

					if not Character or not Character.Parent then continue end

					local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
					if not rootPart then continue end

					local heldTroop = nil
					local groundTroops = {}

					-- Pisahkan mana troop yang dipegang dan yang ada di lantai
					for _, info in pairs(TroopCache) do
						if not Enableds.Merge then break end
						if info.Instance and info.Instance.Parent and info.PrimaryPart and info.OwnerUserId == LocalPlayer.UserId then
							if info.IsHeld then
								heldTroop = info
							else
								table.insert(groundTroops, info)
							end
						end
					end

					if not Enableds.Merge then break end

					-- LOGIKA JIKA SEDANG MEMEGANG TROOP
					if heldTroop then
						local targetMatch = nil

						-- Cari troop di lantai dengan MaxHealth yang sama persis
						for _, groundTroop in ipairs(groundTroops) do
							if not Enableds.Merge then break end
							if groundTroop.MaxHealth == heldTroop.MaxHealth then
								targetMatch = groundTroop
								break
							end
						end

						if not Enableds.Merge then break end

						if targetMatch then
							-- Teleport ke pasangan yang cocok untuk digabungkan
							Character:PivotTo(targetMatch.PrimaryPart.CFrame + Vector3.new(0, rootPart.Position.Y, 0))
							task.wait(0.5) -- Tunggu proses merge

							--humanoid:MoveTo(targetPosition)
							-- Berjalan sampai nuke terambil

							--while (rootPart.Position - targetPosition).Magnitude > 4 and Enableds.Merge and humanoid.Parent do
							--	task.wait(0.05)
							--	humanoid:MoveTo(targetPosition)
							--end
						else
							-- Jika memegang troop tapi tidak ada pasangan yang sama, jatuhkan
							if DropHeldTroopPacket then
								DropHeldTroopPacket:FireServer()
								task.wait(0.5)
							end
						end

						-- LOGIKA JIKA TANGAN KOSONG (TIDAK MEMEGANG TROOP)
					else
						local groupedTroops = {}
						for _, groundTroop in ipairs(groundTroops) do
							if not Enableds.Merge then break end
							if not groupedTroops[groundTroop.MaxHealth] then
								groupedTroops[groundTroop.MaxHealth] = {}
							end
							table.insert(groupedTroops[groundTroop.MaxHealth], groundTroop)
						end

						local troopToPickup = nil
						-- Cari grup MaxHealth yang isinya 2 troop atau lebih
						for health, group in pairs(groupedTroops) do
							if not Enableds.Merge then break end
							if #group >= 2 then
								troopToPickup = group[1]
								break
							end
						end

						if not Enableds.Merge then break end

						if troopToPickup then
							-- Teleport untuk mengambil troop pertama
							Character:PivotTo(troopToPickup.PrimaryPart.CFrame + Vector3.new(0, rootPart.Position.Y, 0))
							task.wait(0.3) -- Tunggu animasi/sistem gamenya pick up

							--humanoid:MoveTo(targetPosition)
							-- Berjalan sampai nuke terambil

							--while (rootPart.Position - targetPosition).Magnitude > 4 and Enableds.Merge and humanoid.Parent do
							--	task.wait(0.05)
							--	humanoid:MoveTo(targetPosition)
							--end
						end
					end

				end
			end)
		end
	end
})

Window:AddDropdown({
	Text = "Upgrade Type",
	Options = UpgradeTypes,
	Option = nil,
	MultipleOptions = true,
	Flag = "upgrade_options",
	Callback = function(option)
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
		if value then

			task.spawn(function()	
				while Enableds.Upgrade do
					task.wait(0.5)
					for key, active in pairs(UpgradeActives) do
						if not Enableds.Upgrade then break end
						if active then
							local upgradeButton = UpgradeButtons[key]
							if upgradeButton then
								FireButton(upgradeButton)
							end
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
		if Connections["Rebirth"] then Connections["Rebirth"]:Disconnect() Connections["Rebirth"] = nil end
		if value then
			RebirthButton = RebirthButton or RebirtFrame:QueryDescendants("#ButtonContainer > #Rebirth > #Container > #Button")[1]
			RebirthFill = RebirthFill or RebirtFrame:QueryDescendants("#UpgradeProgress > #Fill")[1]

			Connections["Rebirth"] = RebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
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

Window:AddLabel("YouTube: Crokyreo")
Window:AddLabel("Version: 12")
