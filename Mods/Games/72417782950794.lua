local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Instancer = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Instancer/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local CleanEnabled, GameCleanEnabled, UpgradeOrBuyAllEnabled, KillThiefEnabled, FarmEnabled, Destroyed = false, false, false, false, false, false
local SaveAllEnableds = {}

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
		--firesignal(button.MouseButton1Click)
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
		Destroyed = true
		CleanEnabled, GameCleanEnabled, UpgradeOrBuyAllEnabled, KillThiefEnabled, FarmEnabled = false, false, false, false, false
		FullGarbagebags, RunOutEnergy = false, false
		if GameCleanConnection then GameCleanConnection:Disconnect() GameCleanConnection = nil end
		if TrashFillConnection then TrashFillConnection:Disconnect() TrashFillConnection = nil end
		if EnergyFillConnection then EnergyFillConnection:Disconnect() EnergyFillConnection = nil end
	end
})

local CleanToggle, GameCleanToggle, UpgradeOrBuyAllToggle, KillThiefToggle = nil, nil, nil, nil
local FarmDebounce = false

Window:AddToggle({
	Text = "Auto Farm",
	Value = false,
	Flag = "farm_enabled",
	Callback = function(value)
		FarmEnabled = value

		if value then
			SaveAllEnableds = {CleanEnabled, GameCleanEnabled, UpgradeOrBuyAllEnabled, KillThiefEnabled}

			for _, toggle in ipairs({CleanToggle, GameCleanToggle, UpgradeOrBuyAllToggle, KillThiefToggle}) do
				FastWait()
				if not FarmEnabled then break end
				toggle.Visible = false
				toggle:Set(true)
			end
		else
			for _, toggle in ipairs({CleanToggle, GameCleanToggle, UpgradeOrBuyAllToggle, KillThiefToggle}) do
				FastWait()
				if FarmEnabled then break end
				toggle.Visible = true
				toggle:Set(false)
			end

			if FarmEnabled then return end
			CleanEnabled, GameCleanEnabled, UpgradeOrBuyAllEnabled, KillThiefEnabled = unpack(SaveAllEnableds)

			if not Destroyed and not FarmEnabled then
				CleanToggle:Set(CleanEnabled)
			end
			if not Destroyed and not FarmEnabled then
				GameCleanToggle:Set(GameCleanEnabled)
			end
			if not Destroyed and not FarmEnabled then
				GameCleanToggle:Set(UpgradeOrBuyAllEnabled)
			end
			if not Destroyed and not FarmEnabled then
				GameCleanToggle:Set(KillThiefEnabled)
			end
		end
	end,
})

local function ThrowTrashCan()
	if CleanState == "Cleaning" then
		-- Teleport ke Grinding Machine / Tempat Pembuangan
		Character:MoveTo(Vector3.new(GrindingMachinePosition.X, GrindingMachinePosition.Y + 3, GrindingMachinePosition.Z))
		FastWait(0.4)

		-- Membuang sampah
		ReplicatedStorage.EVENTS.PlayerEvents.ThrowItem:FireServer(
			Vector3.new(0.96049702167511, -0.25137504935265, -0.11939886957407),
			10
		)
	end
end

local function ConsumeItem(name)
	ReplicatedStorage.EVENTS.PlayerEvents.ConsumeItem:FireServer(false, name)

	FastWait(1)
	ReplicatedStorage.EVENTS.PlayerEvents.ConsumeItem:FireServer(true)
end

CleanToggle = Window:AddToggle({
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

			pcall(function()
				local sodaCanButton = PlayerGui.InterfaceUI.SideButtons.RechargeButton

				task.spawn(function()
					while CleanEnabled do
						FastWait(0.1)
						if sodaCanButton.ItemAmount.TopText.Text ~= "0x" then
							FastWait(1)
							
							if RunOutEnergy or energyFill.Size.Y.Scale <= 0.2 then
								ConsumeItem("SodaCan")
							end
						end
					end
				end)
				
				--local energyBarButton = PlayerGui.InterfaceUI.SideButtons.EneryBar.TopText

				--EnergyButtonConnection = 
				
				return nil
			end)
			
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
					FastWait()
					if CleanState == "None" then
						CleanState = "Cleaning"
					end

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
							if garbagebagsFill.Size.Y.Scale >= 0.1 then
								ThrowTrashCan()
								task.wait(1)
							end

							-- Teleport ke Vending Machine
							Character:MoveTo(Vector3.new(VendingMachinePosition.X, VendingMachinePosition.Y + 3, VendingMachinePosition.Z))
							FastWait(0.3)

							-- Membeli minuman/makanan lewat Remote Event yang ada di catatan kaki Cobalt kamu
							ReplicatedStorage.EVENTS.PlayerEvents.BuyRechargeItem:FireServer()
							FastWait(4)

							local energyItem = Instancer.YieldForChild(spawnedDebris, function(child)
								return child.Name == "SodaCan" or child.Name == "EnergyBar"
							end, function()
								if not CleanEnabled then return true end
								
								-- Interupsi jika tiba-tiba tas penuh atau energi habis saat sedang nge-loop item
								if (FullGarbagebags or garbagebagsFill.Size.Y.Scale >= 0.98) or (not RunOutEnergy or energyFill.Size.Y.Scale >= 0.21) then
									return true
								end

								return false
							end)

							if energyItem and energyItem.Name == "SodaCan" or energyItem.Name == "EnergyBar" then
								-- Ambil energi via Remote
								ReplicatedStorage.EVENTS.PlayerEvents.CollectItem:FireServer(energyItem)
								FastWait(1)

								ConsumeItem(energyItem.Name)
							end

							RunOutEnergy = false
						end
					end

					-- 2. Periksa Kantong Sampah (Jika Penuh)
					if FullGarbagebags or garbagebagsFill.Size.Y.Scale >= 0.98 then
						ThrowTrashCan()

						if FullGarbagebags or garbagebagsFill.Size.Y.Scale >= 0.98 then
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

										-- Interupsi jika tiba-tiba tas penuh atau energi habis saat sedang nge-loop item
										if (FullGarbagebags or garbagebagsFill.Size.Y.Scale >= 0.98) or (RunOutEnergy or energyFill.Size.Y.Scale <= 0.2) then
											itemFound = true
											break
										end
										
										local part = nil
										
										if item:FindFirstChild("DirtParts") and item:FindFirstChild("GameLight") then
											if garbagebagsFill.Size.Y.Scale >= 0.1 then
												ThrowTrashCan()
												FastWait(1)
											end
											
											part = item:FindFirstChildWhichIsA("BasePart")
											
											if part and CleanState == "Cleaning" then
												local charPivot = Character:GetPivot()
												local newPosition = Vector3.new(part.Position.X, part.Position.Y, part.Position.Z)
												local newCFrame = charPivot.Rotation + newPosition
												Character:PivotTo(newCFrame)
												FastWait(2)

												-- Ambil sampah via Remote
												ReplicatedStorage.EVENTS.PlayerEvents.CollectItem:FireServer(item)
												FastWait(1)
											end
	
											itemFound = true
											continue
										end
										
										part = item:FindFirstChild("TrashPrimary")
										if part and CleanState == "Cleaning" then
											itemFound = true

											local charPivot = Character:GetPivot()
											local newPosition = Vector3.new(part.Position.X, part.Position.Y, part.Position.Z)
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
					if not itemFound and CleanState == "Cleaning" and spawnedDebris then 
						for _, item in ipairs(spawnedDebris:GetChildren()) do
							if not CleanEnabled or CleanState ~= "Cleaning" then break end
							if item and item.Parent and CleanEnabled then
								local part = item:FindFirstChildWhichIsA("BasePart")
								if part then
									ThrowTrashCan()
									FastWait(1)
									local charPivot = Character:GetPivot()
									local newPosition = Vector3.new(part.Position.X, part.Position.Y, part.Position.Z)
									local newCFrame = charPivot.Rotation + newPosition
									Character:PivotTo(newCFrame)
									FastWait(1)
									-- Ambil sampah via Remote
									ReplicatedStorage.EVENTS.PlayerEvents.CollectItem:FireServer(item)
									FastWait(1)
								end
								itemFound = true
							end
						end
						FastWait(0.5)
					end
				end
			end)
		end
	end
})

GameCleanToggle = Window:AddToggle({
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
						if CleanState == "None" then
							CleanState = "Cleaning"
						end

						if not (Character and Character.Parent) then
							LocalPlayer.CharacterAdded:Wait()
						end

						local rootPart = Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart
						if not rootPart then 
							FastWait()
							continue 
						end

						if #gamesFolder:GetChildren() >= 1 and GameCleanEnabled and CleanState ~= "KillThief" then
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

							if gameCleanGui.Enabled and GameCleanEnabled and CleanState ~= "KillThief" then
								CleanState = "Waiting"
								FastWait(1)
							end
						end
					end

					if not gameCleanGui.Enabled and CleanState ~= "KillThief" then
						CleanState = "Cleaning"
					end
				end
			end)
		end
	end
})

UpgradeOrBuyAllToggle = Window:AddToggle({
	Text = "Upgrade/Buy All",
	Value = false,
	Flag = "upgrade_or_buy_all_enabled",
	Callback = function(value)
		UpgradeOrBuyAllEnabled = value
		if value then
			--workspace.Map.InteractParts.ShreddingMachine.ShredderBase

			local shopUpgrades = PlayerGui.MainGui.MainUI.ShopUpgrades
			local statUpgrades = PlayerGui.MainGui.MainUI.StatUpgrades

			--local upgradeButton = PlayerGui.MainGui.MainUI.ShopUpgrades.ListFrame.ItemsList.Alarm.MainFrame.UpgradeButton

			--121, 18, 149
			--workspace.ItemSpawns.StartArea.Spawn5.Items["Small Plant"].TrashPrimary
			--game:GetService("Players").LocalPlayer.PlayerGui
			--235, 80, 80

			--game:GetService("Players").LocalPlayer.PlayerGui.MainGui.MainUI.StatUpgrades.ListFrame.ItemsList["Collect Speed"].MainFrame.UpgradeButton
			--game:GetService("Players").LocalPlayer.PlayerGui.MainGui.MainUI.StatUpgrades.ListFrame.ItemsList["Collect Speed"].MainFrame.MaxButton

			-- FullBag in SpawnedDebris

			task.spawn(function()
				while UpgradeOrBuyAllEnabled do
					FastWait()
					for i, upgrades in ipairs({statUpgrades, shopUpgrades}) do
						local itemsList = upgrades:FindFirstChild("ListFrame") and upgrades.ListFrame:FindFirstChild("ItemsList")
						if itemsList then
							for j, frame in ipairs(itemsList:GetChildren()) do
								local mainFrame = frame:FindFirstChild("MainFrame")
								if mainFrame then
									local upgradeButton = mainFrame:FindFirstChild("UpgradeButton")
									if upgradeButton and upgradeButton:IsA("ImageButton") and upgradeButton.Visible and upgradeButton.ImageColor3 ~= Color3.fromRGB(235, 80, 80) and UpgradeOrBuyAllEnabled then
										FireButton(upgradeButton)
										FastWait(1)
									end
								end
							end
						end
					end
				end
			end)
		end
	end
})

KillThiefToggle = Window:AddToggle({
	Text = "Kill Maling Uang",--"Respect Corruptors", -- "Kill Thief",
	Value = false,
	Flag = "kill_thief_enabled",
	Callback = function(value)
		KillThiefEnabled = value
		if value then
			task.spawn(function()
				local ThiefNPC = nil
				while KillThiefEnabled do
					FastWait()

					if not Instancer.IsAlive(ThiefNPC) and KillThiefEnabled then
						for _, npc in ipairs(workspace:GetChildren()) do
							if npc and npc.Parent and npc:IsA("Model") and npc.Name == "ThiefNPC" then
								local primary = npc:FindFirstChild("Primary")
								local prompt = primary and primary:FindFirstChild("HitThiefPrompt")
								if prompt and KillThiefEnabled then
									ThiefNPC = npc
									break
								end
							end
						end
					end

					if Instancer.IsAlive(ThiefNPC) and KillThiefEnabled then
						CleanState = "KillThief"
						FastWait(2)
						repeat 
							if not Instancer.IsAlive(ThiefNPC) or not KillThiefEnabled then break end
							local primary = ThiefNPC:FindFirstChild("Primary")
							local prompt = primary and primary:FindFirstChild("HitThiefPrompt")
							if prompt and KillThiefEnabled then
								FastWait(0.1)
								Character:MoveTo(Vector3.new(primary.Position.X, primary.Position.Y + 3, primary.Position.Z))
								if fireproximityprompt then
									fireproximityprompt(prompt)
								end
							end
							FastWait(0.1)
						until not Instancer.IsAlive(ThiefNPC) or not KillThiefEnabled

						CleanState = "None"
					end
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
		local newPosition = Vector3.new(VendingMachinePosition.X, VendingMachinePosition.Y + 3, VendingMachinePosition.Z)
		local newCFrame = charPivot.Rotation + newPosition
		Character:PivotTo(newCFrame)
	end
})

Window:AddLabel("YouTube: Crokyreo")
Window:AddLabel("YouTube: Tora IsMe")
