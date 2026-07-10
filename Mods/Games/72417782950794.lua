local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local CleanEnabled = false

local VendingMachinePosition, GrindingMachinePosition = Vector3.zero, Vector3.zero
local PositionType, PositionButton = "None", nil
local TrashFillConnection, EnergyFillConnection, DebrisAddedConnection = nil, nil, nil
local TrashDebounce, EnergyDebounce = false, false

local function FindMatchAncestor(instance, finish, match)
	local current = instance

	while current ~= nil and current ~= (finish or game) do
		local success = match(current)
		if success then
			return current
		end
		current = current.Parent
	end

	return nil
end

local Window = UI:CreateWindow({
	Name = "Clean the Backyard",
	Destroying = function()
		CleanEnabled = false
		TrashDebounce, EnergyDebounce = false, false
		if TrashFillConnection then TrashFillConnection:Disconnect() TrashFillConnection = nil end
		if EnergyFillConnection then EnergyFillConnection:Disconnect() EnergyFillConnection = nil end
	end
})

Window:AddLabel("Position Type")

local PositionSelector = Window:AddSelector({
	Options = {"None", "VendingMachine", "GrindingMachine"},
	Value = "None",
	Callback = function(value)
		PositionButton.Visible = value ~= "None"
		PositionType = value
	end
})

PositionButton = Window:AddButton({
	Text = "Set Position",
	Visible = false,
	Callback = function()
		local character = LocalPlayer.Character
		if character and character.Parent then
			if PositionType == "VendingMachine" then
				VendingMachinePosition = character.PrimaryPart.Position
			elseif PositionType == "GrindingMachine" then
				GrindingMachinePosition = character.PrimaryPart.Position
			end
		end

		if VendingMachinePosition ~= nil and GrindingMachinePosition ~= nil and VendingMachinePosition ~= GrindingMachinePosition and VendingMachinePosition ~= Vector3.zero and GrindingMachinePosition ~= Vector3.zero then
			PositionSelector:Set("None")
		end
	end
})

local SpawnsItems = nil

Window:AddSelect({
	Text = "Clean Target",
	Callback = function(target)
		SpawnsItems = FindMatchAncestor(target, workspace, function(instance)
			if instance and instance.Name:find("Items") then
				return true
			end

			return false
		end)
	end
})

local CleanToggle = nil
CleanToggle = Window:AddToggle({
	Text = "Auto Clean",
	Value = false,
	Flag = "clean_enabled",
	Callback = function(value)
		if not VendingMachinePosition or not GrindingMachinePosition or VendingMachinePosition == GrindingMachinePosition or VendingMachinePosition == Vector3.zero or GrindingMachinePosition == Vector3.zero then
			CleanToggle:Replace(false)
			return
		end

		CleanEnabled = value

		if TrashFillConnection then TrashFillConnection:Disconnect() TrashFillConnection = nil end
		if EnergyFillConnection then EnergyFillConnection:Disconnect() EnergyFillConnection = nil end

		if value then
			local energyFill = PlayerGui.InterfaceUI.StatsUI.Energy.ProgressBar.BarFrame
			local trashFill = PlayerGui.InterfaceUI.StatsUI["Garbage Bag"].ProgressBar.BarFrame

			local character = LocalPlayer.Character
			local saveCFrame = character.PrimaryPart.CFrame
			local spawnedDebris = workspace:FindFirstChild("SpawnedDebris")
			
			local food = nil
			
			TrashDebounce, EnergyDebounce = false, false
			
			DebrisAddedConnection = spawnedDebris.ChildAdded:Connect(function(child)
				if child.Name == "SodaCan" or child.Name == "EnergyBar" then
					food = child
				end
			end)
			
			food = (food ~= nil and food.Parent) and food or (spawnedDebris:FindFirstChild("SodaCan") or spawnedDebris:FindFirstChild("EnergyBar"))
		
			TrashFillConnection = trashFill:GetPropertyChangedSignal("Size"):Connect(function()
				if trashFill.Size.Y.Scale >= 1 and not TrashDebounce then
					TrashDebounce = true
					character:MoveTo(Vector3.new(GrindingMachinePosition.X, character.PrimaryPart.Position.Y, GrindingMachinePosition.Z))
					task.wait(1)
					ReplicatedStorage.EVENTS.PlayerEvents.ThrowItem:FireServer(Vector3.new(0.96049702167511,-0.25137504935265,-0.11939886957407),10)
					task.wait(0.1)
					TrashDebounce = false
				end
			end)
		
			EnergyFillConnection = energyFill:GetPropertyChangedSignal("Size"):Connect(function()
				if energyFill.Size.Y.Scale <= 0.25 and not EnergyDebounce then
					EnergyDebounce = true

					local checkFood = spawnedDebris:FindFirstChild("SodaCan") or spawnedDebris:FindFirstChild("EnergyBar")
					if not checkFood then
						character:MoveTo(Vector3.new(VendingMachinePosition.X, character.PrimaryPart.Position.Y, VendingMachinePosition.Z))
						task.wait(1)
						ReplicatedStorage.EVENTS.PlayerEvents.BuyRechargeItem:FireServer()
						task.wait(0.1)
						
						if not (food and food.Parent) then
							repeat
								task.wait()
								food = (food ~= nil and food.Parent) and food or (spawnedDebris:FindFirstChild("SodaCan") or spawnedDebris:FindFirstChild("EnergyBar"))
							until (food ~= nil and food.Parent ~= nil)
						end
					end

					if food and energyFill.Size.Y.Scale <= 0.25 then
						local foodPart = food:FindFirstChildWhichIsA("BasePart")
						if foodPart then
							character:MoveTo(Vector3.new(foodPart.Position.X, character.PrimaryPart.Position.Y, foodPart.Position.Z))
							task.wait(1)
						end

						ReplicatedStorage.EVENTS.PlayerEvents.CollectItem:FireServer(food)
						task.wait(1)

						ReplicatedStorage.EVENTS.PlayerEvents.ConsumeItem:FireServer(false,food.Name)
						task.wait(1)
					end

					task.wait(0.1)
					EnergyDebounce = false
				end
			end)
			
			task.spawn(function()
				while CleanEnabled do
					task.wait()
					
					local items = SpawnsItems or (workspace:FindFirstChild("ItemSpawns") and workspace.ItemSpawns:FindFirstChild("StartArea") and workspace.ItemSpawns.StartArea:FindFirstChild("Spawn1") and workspace.ItemSpawns.StartArea.Spawn1:FindFirstChild("Items"))
					if not items then 
						continue 
					end

					for _, item in ipairs(items:GetChildren()) do
						task.wait()

						if not CleanEnabled then break end

						if energyFill.Size.Y.Scale <= 0.25 then
							repeat task.wait(1) until not EnergyDebounce or not CleanEnabled
						end

						if not CleanEnabled then break end

						local itemPart = item:FindFirstChildWhichIsA("BasePart")
						if itemPart then
							character:MoveTo(Vector3.new(itemPart.Position.X, character.PrimaryPart.Position.Y, itemPart.Position.Z))
							task.wait(0.5)
						end
						ReplicatedStorage.EVENTS.PlayerEvents.CollectItem:FireServer(item)
						task.wait(0.5)
						if not CleanEnabled then break end
						if trashFill.Size.Y.Scale >= 1 then
							repeat task.wait(1) until not TrashDebounce or not CleanEnabled
						end
					end
				end
			end)
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
