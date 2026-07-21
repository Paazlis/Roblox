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
local TroopFolder = nil

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

local function GetTroops()
	TroopFolder = TroopFolder or workspace:QueryDescendants("#Prefabs > #TroopVisuals")[1]

	local troops = {}

	for _, troop in ipairs(TroopFolder:GetChildren()) do
		if troop:IsA("Model") then
			local ownerId = troop:GetAttribute("OwnerUserId")
			if ownerId ~= nil and tostring(ownerId) == tostring(LocalPlayer.UserId) then
				local maxHealth = troop:GetAttribute("MaxHealth")
				if maxHealth ~= nil then 
					table.insert(troops, {
						["Instance"] = troop,
						Name = troop.Name,
						MaxHealth = maxHealth,
						PrimaryPart = troop.PrimaryPart or troop:FindFirstChildWhichIsA("BasePart"),
						IsHeld = string.find(troop.Name, "Held") ~= nil
					})
				end
			end
		end
	end

	table.sort(troops, function(a, b)
		return a.MaxHealth < b.MaxHealth
	end)

	return troops
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
	end
})

Window:AddToggle({
	Text = "Auto Merge",
	Value = false,
	Flag = "merge_enabled",
	Callback = function(value)
		Enableds.Merge = value

		if value then 
			--[[
				workspace.Prefabs.TroopVisuals.Troop1_Visual -- OwnerUserId and MaxHealth
				workspace.ScriptableObjects.Plots:GetChildren()[8].MergeArea
			]]
			task.spawn(function()
				local HeldTroop = nil
				while Enableds.Merge do
					task.wait(1)

					local humanoid = Character:FindFirstChildOfClass("Humanoid")
					local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")

					if not humanoid or not rootPart then continue end
					
					local foundHeldTroop, foundCheckTroop = false, false
					
					local troops = GetTroops()
					
					for i, troop in ipairs(troops) do
						if not troop or not troop.Instance or not troop.Instance.Parent then continue end
						if not Enableds.Merge then break end
						
						if HeldTroop and HeldTroop.MaxHealth == troop.MaxHealth and not foundCheckTroop then
							foundCheckTroop = true
						end
						
						if troop and troop.IsHeld and not foundHeldTroop then
							foundHeldTroop = true
							HeldTroop = troop
							troops[i] = nil
						end
						
						if foundCheckTroop and foundHeldTroop then
							break
						end
					end
					
					if not foundCheckTroop then continue end
					
					for i, troop in ipairs(troops) do
						task.wait()
	
						if not troop or not troop.Instance or not troop.Instance.Parent then continue end
						if not Enableds.Merge then break end
						
						local isHeld = troop.IsHeld
						
						if (not HeldTroop or not HeldTroop.Instance or not HeldTroop.Instance.Parent) then
							HeldTroop = troop
							troops[i] = nil
						end
						
						if HeldTroop then
							local foundTroop = false
							
							for j, troopResult in ipairs(troops) do
								if troopResult and not troopResult.IsHeld and troopResult ~= HeldTroop and troop.MaxHealth == troopResult.MaxHealth then
									HeldTroop = nil
									troop = troopResult
									troops[j] = nil
									foundTroop = true
									break
								end
							end
							
							if not foundTroop then
								HeldTroop = nil
								
								if DropHeldTroopPacket then
									DropHeldTroopPacket:FireServer()
								end
								
								break
							else
								troop = HeldTroop
							end
						end
						
						local troopRootPart = troop.PrimaryPart

						local targetPosition = nil
						if troopRootPart and troopRootPart.Parent then
							targetPosition = troopRootPart.Position
						end
						
						if not targetPosition then continue end
						
						task.wait(0.1)
						Character:PivotTo(troopRootPart.CFrame + Vector3.new(0, rootPart.Position.Y, 0))
						troops[i] = nil
						
						--humanoid:MoveTo(targetPosition)

						---- Berjalan sampai nuke terambil
						--while (rootPart.Position - targetPosition).Magnitude > 4 and Enableds.Merge and humanoid.Parent do
						--	task.wait(0.05)

						--	humanoid:MoveTo(targetPosition)
						--end
		
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
