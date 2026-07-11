local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Instancer = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Instancer/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService
workspace.Map.InteractParts.ShreddingMachine.ShredderBase

121, 18, 149
workspace.ItemSpawns.StartArea.Spawn5.Items["Small Plant"].TrashPrimary
game:GetService("Players").LocalPlayer.PlayerGui.MainGui.MainUI.ShopUpgrades.ListFrame.ItemsList.Alarm.MainFrame.UpgradeButton
235, 80, 80

game:GetService("Players").LocalPlayer.PlayerGui.MainGui.MainUI.StatUpgrades.ListFrame.ItemsList["Collect Speed"].MainFrame.UpgradeButton
game:GetService("Players").LocalPlayer.PlayerGui.MainGui.MainUI.StatUpgrades.ListFrame.ItemsList["Collect Speed"].MainFrame.MaxButton
235, 80, 80


FullBag in SpawnedDebris

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local CleanEnabled, GameCleanEnabled, UpgradeAllEnabled = false, false, false

local GrindingMachinePosition, VendingMachinePosition, GameCleanPosition = Vector3.new(122, 18, 135), Vector3.new(122, 18, 158), Vector3.new(140, 18, 143)

local TrashFillConnection, EnergyFillConnection, DebrisAddedConnection, DebrisRemovedConnection, GameCleanConnection = nil, nil, nil, nil, nil
local FullGarbagebags, RunOutEnergy = false, false
local CleanState = "Cleaning"
local FoodList = {"SodaCan", "EnergyBar"}

local function FastWait(duration)
	if not duration then RunService.RenderStepped:Wait() return end
	local start = tick()
	while tick() - start < duration do
		RunService.RenderStepped:Wait()
	end
	return tick() - start
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function IsCursorPerfect(cursor)
	local currentY = cursor.Position.X.Scale
	if currentY >= 0.45 and currentY <= 0.48 then
		return true
	end
	return false
end

local Character = LocalPlayer.Character

local CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local Window = UI:CreateWindow({
	Name = "Clean the Backyard",
	Destroying = function()
		CleanEnabled, GameCleanEnabled, UpgradeAllEnabled = false, false, false
		FullGarbagebags, RunOutEnergy = false, false
		if GameCleanConnection then GameCleanConnection:Disconnect() GameCleanConnection = nil end
		if TrashFillConnection then TrashFillConnection:Disconnect() TrashFillConnection = nil end
		if EnergyFillConnection then EnergyFillConnection:Disconnect() EnergyFillConnection = nil end
	end
})

Window:AddToggle({
	Text = "Auto Clean",
	Value = false,
	Flag = "clean_enabled",
	Callback = function(value)
		CleanEnabled = value

		-- Bersihkan koneksi lama agar tidak menumpuk (Memory Leak)
		if TrashFillConnection then TrashFillConnection:Disconnect() TrashFillConnection = nil end
		if EnergyFillConnection then EnergyFillConnection:Disconnect() EnergyFillConnection = nil end

		if value then
			local energyFill = PlayerGui.InterfaceUI.StatsUI.Energy.ProgressBar.BarFrame
			local garbagebagsFill = PlayerGui.InterfaceUI.StatsUI["Garbage Bag"].ProgressBar.BarFrame
			local itemSpawns = workspace:FindFirstChild("ItemSpawns")
			local spawnedDebris = workspace:FindFirstChild("SpawnedDebris")

			FullGarbagebags, RunOutEnergy = false, false

			-- Deteksi otomatis jika tas penuh atau energi habis via UI
			TrashFillConnection = garbagebagsFill:GetPropertyChangedSignal("Size"):Connect(function()
				FullGarbagebags = garbagebagsFill.Size.Y.Scale >= 0.98
			end)

			EnergyFillConnection = energyFill:GetPropertyChangedSignal("Size"):Connect(function()
				RunOutEnergy = energyFill.Size.Y.Scale <= 0.2
			end)

			-- Loop Utama Auto Clean
			task.spawn(function()
				while CleanEnabled do
					if not (Character and Character.Parent) then
						LocalPlayer.CharacterAdded:Wait()
					end

					local rootPart = Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart
					if not rootPart then 
						FastWait() 
						continue 
					end

					-- 1. Periksa Energi (Jika Habis)
					if RunOutEnergy or energyFill.Size.Y.Scale <= 0.2 then
						if CleanState == "Cleaning" then
							-- Teleport ke Vending Machine
							Character:PivotTo(CFrame.new(Vector3.new(VendingMachinePosition.X, rootPart.Position.Y, VendingMachinePosition.Z)))
							FastWait(0.3)

							-- Membeli minuman/makanan lewat Remote Event yang ada di catatan kaki Cobalt kamu
							ReplicatedStorage.EVENTS.PlayerEvents.BuyRechargeItem:FireServer()
							FastWait(1)

							local energyItem = Instancer.YieldForChild(spawnedDebris, function(child)
								return child.Name == "SodaCan" or child.Name == "EnergyBar"
							end)

							if energyItem and energyItem.Name == "SodaCan" or energyItem.Name == "EnergyBar"  then
								-- Ambil energi via Remote
								ReplicatedStorage.EVENTS.PlayerEvents.CollectItem:FireServer(energyItem)
								FastWait(1)

								ReplicatedStorage.EVENTS.PlayerEvents.ConsumeItem:FireServer(false, energyItem.Name)

								FastWait(1)
								ReplicatedStorage.EVENTS.PlayerEvents.ConsumeItem:FireServer(true)
							end

							RunOutEnergy = false
						end
					end

					-- 2. Periksa Kantong Sampah (Jika Penuh)
					if FullGarbagebags or garbagebagsFill.Size.Y.Scale >= 0.98 then
						if CleanState == "Cleaning" then
							-- Teleport ke Grinding Machine / Tempat Pembuangan
							Character:PivotTo(CFrame.new(Vector3.new(GrindingMachinePosition.X, rootPart.Position.Y, GrindingMachinePosition.Z)))
							FastWait(0.4)

							-- Membuang sampah
							ReplicatedStorage.EVENTS.PlayerEvents.ThrowItem:FireServer(
								Vector3.new(0.96049702167511, -0.25137504935265, -0.11939886957407),
								10
							)
							FullGarbagebags = false
						end
					end

					-- 3. Periksa dan Proses Ambil Sampah
					local itemFound = false

					if itemSpawns and CleanState == "Cleaning" then
						for _, area in ipairs(itemSpawns:GetChildren()) do
							if not CleanEnabled or CleanState ~= "Cleaning" then break end

							for _, spwn in ipairs(area:GetChildren()) do
								if not CleanEnabled or CleanState ~= "Cleaning" then break end

								local itemsFolder = spwn:FindFirstChild("Items")
								if itemsFolder then
									for _, item in ipairs(itemsFolder:GetChildren()) do
										if not CleanEnabled or CleanState ~= "Cleaning" then break end
										if not item or not item.Parent then continue end

										if item:FindFirstChild("DirtParts") and item:FindFirstChild("GameLight") then
											continue
										end

										-- Interupsi jika tiba-tiba tas penuh atau energi habis saat sedang nge-loop item
										if (FullGarbagebags or garbagebagsFill.Size.Y.Scale >= 0.98) or (RunOutEnergy or energyFill.Size.Y.Scale <= 0.2) then
											itemFound = true
											break
										end

										local part = item:FindFirstChildWhichIsA("BasePart")
										if part and CleanState == "Cleaning" then
											itemFound = true

											local charPivot = Character:GetPivot()
											local newPosition = Vector3.new(part.Position.X, charPivot.Position.Y, part.Position.Z)
											local newCFrame = charPivot.Rotation + newPosition
											Character:PivotTo(newCFrame)
											FastWait(0.4)

											-- Ambil sampah via Remote
											ReplicatedStorage.EVENTS.PlayerEvents.CollectItem:FireServer(item)
											FastWait(0.25)
										end
									end
								end
							end
						end
					end

					-- Jika halaman bersih/tidak ada sampah, tunggu sebentar sebelum check ulang agar tidak lag
					if not itemFound then
						FastWait(0.5)
					end
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Auto Game Clean",
	Value = false,
	Flag = "game_clean_enabled",
	Callback = function(value)
		if GameCleanConnection then GameCleanConnection:Disconnect() GameCleanConnection = nil end
		GameCleanEnabled = value
		if value then
			local gamesFolder = workspace.Map.GameCleanScene.Games
			local gameCleanGui = PlayerGui.GameCleanUI
			local clickButton = gameCleanGui.MainFrame.ClickButton
			local movingLine = gameCleanGui.MainFrame.LineFrame.MovingLine
			local boxFrame = gameCleanGui.MainFrame.LineFrame.BoxFrame
			
			GameCleanConnection = movingLine:GetPropertyChangedSignal("Position"):Connect(function()
				if IsCursorPerfect(movingLine) then
					FireButton(clickButton)
				end
			end)
			
			task.spawn(function()
				while GameCleanEnabled do
					FastWait()

					if #gamesFolder:GetChildren() >= 1 and GameCleanEnabled then
						if not (Character and Character.Parent) then
							LocalPlayer.CharacterAdded:Wait()
						end

						local rootPart = Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart
						if not rootPart then 
							FastWait()
							continue 
						end
						
						if #gamesFolder:GetChildren() >= 1 and GameCleanEnabled then
							-- Teleport ke Grinding Machine / Tempat Pembuangan
							Character:PivotTo(CFrame.new(Vector3.new(GameCleanPosition.X, rootPart.Position.Y, GameCleanPosition.Z)))
							FastWait(0.4)

							ReplicatedStorage.EVENTS.PlayerEvents.OpenCleanMenu:FireServer()
							FastWait(2)

							local attempt = 0

							repeat
								FastWait(1)
								attempt += 1
							until gameCleanGui.Enabled or attempt >= 5 or not GameCleanEnabled

							if gameCleanGui.Enabled and GameCleanEnabled then
								CleanState = "Waiting"
								FastWait(1)
							end
						end
					end
				

					if not gameCleanGui.Enabled then
						CleanState = "Cleaning"
					end
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Upgrade All",
	Value = false,
	Flag = "upgrade_all_enabled",
	Callback = function(value)
		UpgradeAllEnabled = value
		if value then
			task.spawn(function()
				while UpgradeAllEnabled do
					FastWait(5)
				end
			end)
		end
	end
})

Window:AddButton({
	Text = "Go Home",
	MethodType = "DoubleClick",
	Callback = function()
		local charPivot = Character:GetPivot()
		local newPosition = Vector3.new(VendingMachinePosition.X, charPivot.Position.Y, VendingMachinePosition.Z)
		local newCFrame = charPivot.Rotation + newPosition
		Character:PivotTo(newCFrame)
	end
})

Window:AddLabel("YouTube: Crokyreo")
Window:AddLabel("YouTube: Tora IsMe")
