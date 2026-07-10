local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local CleanEnabled = false

local VendingMachineCFrame, GrindingMachineCFrame = CFrame.new(), CFrame.new()
local PositionType, PositionButton = "None", nil

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
				VendingMachineCFrame = character.PrimaryPart.CFrame
			elseif PositionType == "GrindingMachine" then
				GrindingMachineCFrame = character.PrimaryPart.CFrame
			end
		end

		if VendingMachineCFrame ~= nil and GrindingMachineCFrame ~= nil and VendingMachineCFrame ~= GrindingMachineCFrame and VendingMachineCFrame ~= CFrame.new() and GrindingMachineCFrame ~= CFrame.new() then
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
		if not VendingMachineCFrame or not GrindingMachineCFrame or VendingMachineCFrame == GrindingMachineCFrame or VendingMachineCFrame == CFrame.new() or GrindingMachineCFrame == CFrame.new() then
			CleanToggle:Replace(false)
			return
		end

		CleanEnabled = value

		if value then
			task.spawn(function()
				local energyFill = PlayerGui.InterfaceUI.StatsUI.Energy.ProgressBar.BarFrame
				local trashFill = PlayerGui.InterfaceUI.StatsUI["Garbage Bag"].ProgressBar.BarFrame

				local character = LocalPlayer.Character
				local saveCFrame = character.PrimaryPart.CFrame
				local spawnedDebris = workspace:FindFirstChild("SpawnedDebris")
				
				while CleanEnabled do
					task.wait(5)
					
					local items = SpawnsItems or (workspace:FindFirstChild("ItemSpawns") and workspace.ItemSpawns:FindFirstChild("StartArea") and workspace.ItemSpawns.StartArea:FindFirstChild("Spawn1") and workspace.ItemSpawns.StartArea.Spawn1:FindFirstChild("Items"))
					if not items or #items:GetChildren() <= 0 then 
						continue 
					end

					for _, item in ipairs(items:GetChildren()) do
						task.wait(1)

						if not CleanEnabled then break end

						if energyFill.Size.Y.Scale <= 0.25 then
							local checkFood = spawnedDebris:FindFirstChild("SodaCan") or spawnedDebris:FindFirstChild("EnergyBar")
							if not checkFood then
								character:MoveTo(Vector3.new(VendingMachineCFrame.Position.X, character.PrimaryPart.Position.Y, VendingMachineCFrame.Position.Z))
								task.wait(1)
								ReplicatedStorage.EVENTS.PlayerEvents.BuyRechargeItem:FireServer()
								
								repeat task.wait(0.1) until spawnedDebris:FindFirstChild("SodaCan") or spawnedDebris:FindFirstChild("EnergyBar") or energyFill.Size.Y.Scale >= 0.25
							end

							if not CleanEnabled then break end

							local food = spawnedDebris:FindFirstChild("SodaCan") or spawnedDebris:FindFirstChild("EnergyBar")
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
						end

						if not CleanEnabled then break end

						local itemPart = item:FindFirstChildWhichIsA("BasePart")
						if itemPart then
							character:MoveTo(Vector3.new(itemPart.Position.X, character.PrimaryPart.Position.Y, itemPart.Position.Z))
							task.wait(0.1)
						end
						ReplicatedStorage.EVENTS.PlayerEvents.CollectItem:FireServer(item)
						task.wait(0.2)

						if trashFill.Size.Y.Scale >= 0.5 then
							character:PivotTo(GrindingMachineCFrame)
							task.wait(1)
							ReplicatedStorage.EVENTS.PlayerEvents.ThrowItem:FireServer(
								Vector3.new(0.96049702167511, -0.25137504935265, -0.11939886957407),
								10
							)
						end
					end
				end
			end)
		end
	end
})

Window:AddLabel("YouTube: Crokyreo V5")
