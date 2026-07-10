local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local CleanEnabled = false

local VendingMachineCFrame, GrindingMachineCFrame = CFrame.new(), CFrame.new()
local PositionType, PositionButton = "None", nil

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

				local items = workspace.ItemSpawns.StartArea.Spawn1.Items

				for _, item in ipairs(items:GetChildren()) do
					task.wait()

					if not CleanEnabled then break end

					if energyFill.Size.Y.Scale <= 0.25 then
						local checkSodaCan = spawnedDebris:FindFirstChild("SodaCan")
						if not checkSodaCan then
							character:PivotTo(VendingMachineCFrame)
							task.wait(1)
							ReplicatedStorage.EVENTS.PlayerEvents.BuyRechargeItem:FireServer()
							spawnedDebris.ChildAdded:Wait()
						end

						if not CleanEnabled then break end

						local sodaCan = spawnedDebris:FindFirstChild("SodaCan")
						if sodaCan then
							local sodaPart = sodaCan:FindFirstChildWhichIsA("BasePart")
							if sodaPart then
								character:PivotTo(sodaPart.CFrame)
								task.wait(1)
							end

							-- Collect soda can
							ReplicatedStorage.EVENTS.PlayerEvents.CollectItem:FireServer(sodaCan)
							task.wait(0.5)

							-- Consume soda can 
							ReplicatedStorage.EVENTS.PlayerEvents.ConsumeItem:FireServer(false,"SodaCan")

							task.wait(0.2)
						end
					end

					if not CleanEnabled then break end

					local itemPart = item:FindFirstChildWhichIsA("BasePart")
					if itemPart then
						local rootPart = character.PrimaryPart
						character:PivotTo(CFrame.lookAt(rootPart.Position, Vector3.new(rootPart.Position.X, itemPart.Position.Y, rootPart.Position.Z)))
						task.wait(0.1)
					end
					ReplicatedStorage.EVENTS.PlayerEvents.CollectItem:FireServer(item)
					task.wait(0.2)

					if trashFill.Size.Y.Scale >= 1 then
						character:PivotTo(GrindingMachineCFrame)
						task.wait(1)
						ReplicatedStorage.EVENTS.PlayerEvents.ThrowItem:FireServer(
							Vector3.new(0.96049702167511, -0.25137504935265, -0.11939886957407),
							10
						)
					end
				end
			end)
		end
	end
})

Window:AddLabel("YouTube: Crokyreo V2")
