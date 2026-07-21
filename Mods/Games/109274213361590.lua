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
local TroopFolder, TroopCache = workspace:QueryDescendants("#Prefabs > #TroopVisuals")[1], {}

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
	if not plots then return nil end

	for _, plot in ipairs(plots:GetChildren()) do
		local ownerId = plot:GetAttribute("Owner")
		if ownerId ~= nil and ownerId == LocalPlayer.UserId then
			return plot
		end
	end

	return nil
end

local function OnTroopAdded(troop)
	task.wait(0.5)
	if troop and troop.Parent and Enableds.Merge then
		local attributes = troop:GetAttributes()
		
		if attributes.OwnerUserId ~= LocalPlayer.UserId then return end
		
		local troopInfo = {
			Parent = troop.Parent ~= nil,
			Instance = troop,
			Name = troop.Name,
			MaxHealth = attributes.MaxHealth,
			OwnerUserId = attributes.OwnerUserId,
			TroopId = attributes.TroopId,
			PrimaryPart = troop.PrimaryPart or troop:FindFirstChild("HumanoidRootPart"),
			IsHeld = string.find(troop.Name, "Held") ~= nil,
			Connections = {}
		}

		troopInfo.Connections.Name = troop:GetPropertyChangedSignal("Name"):Connect(function()
			local newTroopInfo = TroopCache[troop]
			if newTroopInfo then
				newTroopInfo.Name = troop.Name
				newTroopInfo.IsHeld = string.find(troop.Name, "Held") ~= nil

				if troop and troop.Parent and Enableds.Merge then
					TroopCache[troop] = newTroopInfo
				end
			end
		end)
		
		troopInfo.Connections.Parent = troop.AncestryChanged:Connect(function(_, parent)
			local newTroopInfo = TroopCache[troop]
			if newTroopInfo then
				newTroopInfo.Parent = parent ~= nil
				if troop and troop.Parent and Enableds.Merge then
					TroopCache[troop] = newTroopInfo
				end
			end
		end)
		
		TroopCache[troop] = troopInfo 
	end
end

local function SortTroopCheck(a, b)
	return a.MaxHealth < b.MaxHealth
end

local Plot = GetPlot()

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

for _, mode in ipairs(UpgradeTypes) do
	UpgradeActives[mode] = false
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

		local troopKey, troopInfo = next(TroopCache)
		while troopInfo do
			TroopCache[troopKey] = nil
			
			local troopConnections = troopInfo.Connections
			if troopConnections then
				for key, value in pairs(troopConnections) do
					if value then
						value:Disconnect()
					end
				end
			end
			
			troopKey, troopInfo = next(TroopCache)
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

		local oldTroopKey, oldTroopInfo = next(TroopCache)
		while oldTroopInfo do
			TroopCache[oldTroopKey] = nil

			local troopConnections = oldTroopInfo.Connections
			if troopConnections then
				for key, value in pairs(troopConnections) do
					if value then
						value:Disconnect()
					end
				end
			end
			oldTroopKey, oldTroopInfo = next(TroopCache)
		end

		if value then 
			Connections["TroopAdded"] = TroopFolder.ChildAdded:Connect(OnTroopAdded)
			Connections["TroopRemoved"] = TroopFolder.ChildRemoved:Connect(function(troop)
				local troopInfo = TroopCache[troop]
				if troopInfo then
					troopInfo.Parent = false
					
					local troopConnections = troopInfo.Connections
					if troopConnections then
						for key, value in pairs(troopConnections) do
							if value then
								value:Disconnect()
							end
						end
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
				local groundTroops, heldTroop, groupedTroops = {}, nil, {}

				while Enableds.Merge do
					task.wait(0.5)

					if not Character or not Character.Parent then continue end

					local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
					if not rootPart then continue end
					
					groundTroops = {}
					heldTroop = nil

					-- Pisahkan mana troop yang dipegang dan yang ada di lantai
					for _, troop in pairs(TroopCache) do
						if not Enableds.Merge then break end
						
						if troop.Parent then
							if troop.IsHeld and not heldTroop then
								heldTroop = troop
							else
								table.insert(groundTroops, troop)
							end
						end
					end
					
					table.sort(groundTroops, SortTroopCheck)
					
					if not Enableds.Merge then break end

					-- LOGIKA JIKA SEDANG MEMEGANG TROOP
					if heldTroop and heldTroop.Parent then
						local troopMatch = nil

						-- Mencari troop di lantai dengan MaxHealth atau TroopId yang sama persis
						for _, groundTroop in ipairs(groundTroops) do
							if not Enableds.Merge then break end
							
							if groundTroop.Parent then
								if heldTroop.MaxHealth ~= nil and groundTroop.MaxHealth ~= nil and heldTroop.MaxHealth == groundTroop.MaxHealth then
									troopMatch = groundTroop
									break
								elseif heldTroop.TroopId ~= nil and groundTroop.TroopId ~= nil and heldTroop.TroopId == groundTroop.TroopId then
									troopMatch = groundTroop
									break
								end
							end
						end

						if not Enableds.Merge then break end

						if troopMatch and troopMatch.Parent then
							-- Teleport ke pasangan yang cocok untuk digabungkan
							Character:PivotTo(troopMatch.PrimaryPart.CFrame + Vector3.new(0, rootPart.Position.Y, 0))
							
							--humanoid:MoveTo(targetPosition)
							-- Berjalan sampai troop merge

							--while (rootPart.Position - targetPosition).Magnitude > 4 and Enableds.Merge and humanoid.Parent do
							--	task.wait(0.05)
							--	humanoid:MoveTo(targetPosition)
							--end
						else
							-- Jika memegang troop tapi tidak ada pasangan yang sama, jatuhkan
							if DropHeldTroopPacket then
								DropHeldTroopPacket:FireServer()
							end
						end
						
						task.wait(0.5) -- Tunggu proses
						
						-- LOGIKA JIKA TANGAN KOSONG (TIDAK MEMEGANG TROOP)
					else
						groupedTroops = {}
						for _, groundTroop in ipairs(groundTroops) do
							if not Enableds.Merge then break end
							if groundTroop then
								if groundTroop.MaxHealth then
									local maxHealthName = tostring(groundTroop.MaxHealth)
									if not groupedTroops[maxHealthName] then
										groupedTroops[maxHealthName] = {}
									end
									table.insert(groupedTroops[maxHealthName], groundTroop)
								end
								if groundTroop.TroopId then
									local troopIdName = tostring(groundTroop.TroopId)
									if not groupedTroops[troopIdName] then
										groupedTroops[troopIdName] = {}
									end
									table.insert(groupedTroops[troopIdName], groundTroop)
								end
							end
						end

						local troopToPickup = nil
						
						-- Cari grup MaxHealth atau TroopId yang isinya 2 troop atau lebih
						for health, group in pairs(groupedTroops) do
							if not Enableds.Merge then break end
							
							if #group >= 2 then
								local index = 1
								local troopToPickup = group[index]
								
								while index < #group or not troopToPickup or not troopToPickup.Parent do
									task.wait()
									troopToPickup = group[index]
									index += 1
								end
								
								if not troopToPickup or not troopToPickup.Parent then
									print("Tidak ada troop yang tersedia untuk diambil.")
									continue
								end
								
								break
							end
						end

						if not Enableds.Merge then break end

						if troopToPickup and troopToPickup.Parent then
							-- Teleport untuk mengambil troop pertama
							Character:PivotTo(troopToPickup.PrimaryPart.CFrame + Vector3.new(0, rootPart.Position.Y, 0))
							task.wait(0.5) -- Tunggu animasi/sistem gamenya pick up

							--humanoid:MoveTo(targetPosition)
							-- Berjalan sampai troop terambil

							--while (rootPart.Position - targetPosition).Magnitude > 4 and Enableds.Merge and humanoid.Parent do
							--	task.wait(0.05)
							--	humanoid:MoveTo(targetPosition)
							--end
						end
					end

				end
				
				groundTroops, heldTroop, groupedTroops = {}, nil, {}
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
