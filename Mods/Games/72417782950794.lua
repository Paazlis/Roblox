local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local CleanEnabled = false

local function FireTouch(hit, target)
	if firetouchinterset then
		firetouchinterset(hit, target, true)
		task.wait()
		firetouchinterset(hit, target, false)
	end
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local Window = UI:CreateWindow({
	Name = "Clean the Backyard",
	Destroying = function()
		CleanEnabled = false
	end
})

Window:AddToggle({
	Text = "Auto Clean",
	Value = false,
	Flag = "clean_enabled",
	Callback = function(value)
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
					task.wait(0.1)
					if not CleanEnabled then break end

					if energyFill.Size.Y.Scale <= 0.25 then
						repeat 
							task.wait(0.1) 
							
							local sodaCan = spawnedDebris:FindFirstChild("SodaCan")
							if not sodaCan then
								ReplicatedStorage.EVENTS.PlayerEvents.BuyRechargeItem:FireServer()
								repeat sodaCan = spawnedDebris:FindFirstChild("SodaCan") task.wait(0.1) until sodaCan ~= nil or not CleanEnabled
							end

							if not CleanEnabled then break end

							if sodaCan then
								local sodaPart = sodaCan:FindFirstChildWhichIsA("BasePart")
								if sodaPart then
									character:PivotTo(sodaPart.CFrame + Vector3.new(0, 3, 0))
									task.wait(0.1)
								end

								-- Collect soda can
								ReplicatedStorage.EVENTS.PlayerEvents.CollectItem:FireServer(sodaCan)
								task.wait(0.5)

								-- Consume soda can 
								ReplicatedStorage.EVENTS.PlayerEvents.ConsumeItem:FireServer(false,"SodaCan")

								task.wait(0.2)
							end
						until not CleanEnabled or energyFill.Size.Y.Scale >= 0.1 or trashFill.Size.Y.Scale >= 1
					end
					
					if not CleanEnabled then break end
					
					local part = item:FindFirstChildWhichIsA("BasePart")
					if part then
						character:PivotTo(part.CFrame + Vector3.new(0, 3, 0))
						task.wait(0.1)
					end
					ReplicatedStorage.EVENTS.PlayerEvents.CollectItem:FireServer(item)
					task.wait(0.2)

					if trashFill.Size.Y.Scale >= 1 then
						character:PivotTo(saveCFrame)

						task.wait(0.5)
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

Window:AddLabel("YouTube: Crokyreo")
