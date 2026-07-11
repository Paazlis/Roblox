local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Instancer = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Instancer/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local CleanEnabled = false

local GrindingMachinePosition, VendingMachinePosition = Vector3.new(122, 18, 135), Vector3.new(122, 18, 158)

local TrashFillConnection, EnergyFillConnection, DebrisAddedConnection, DebrisRemovedConnection, GameCleanConnection = nil, nil, nil, nil, nil
local FullGarbagebags, RunOutEnergy = false, false
local FoodList = {"SodaCan", "EnergyBar"}
local ItemsCache = {}
local ItemsConnection = {}

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
		CleanEnabled = false
		FullGarbagebags, RunOutEnergy = false, false
		if GameCleanConnection then GameCleanConnection:Disconnect() GameCleanConnection = nil end
		if TrashFillConnection then TrashFillConnection:Disconnect() TrashFillConnection = nil end
		if EnergyFillConnection then EnergyFillConnection:Disconnect() EnergyFillConnection = nil end
		if CharacterAddedConnection then CharacterAddedConnection:Disconnect() CharacterAddedConnection = nil end
		table.clear(ItemsCache)
		for _, connection in ipairs(ItemsConnection) do if connection then connection:Disconnect() end end
		table.clear(ItemsConnection)
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
		
		table.clear(ItemsCache)
		for _, connection in ipairs(ItemsConnection) do if connection then connection:Disconnect() end end
		table.clear(ItemsConnection)

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
						-- Teleport ke Vending Machine
						Character:PivotTo(CFrame.new(Vector3.new(VendingMachinePosition.X, rootPart.Position.Y + 3, VendingMachinePosition.Z)))
						FastWait(0.3)

						-- Membeli minuman/makanan lewat Remote Event yang ada di catatan kaki Cobalt kamu
						ReplicatedStorage.EVENTS.PlayerEvents.BuyRechargeItem:FireServer()
						FastWait(1)
						
						local energyItem = Instancer.YieldForChild(spawnedDebris, function(child)
							return not RunOutEnergy or energyFill.Size.Y.Scale >= 0.2 or child.Name == "SodaCan" or child.Name == "EnergyBar"
						end)
						
						if energyItem and energyItem.Name == "SodaCan" or energyItem.Name == "EnergyBar"  then
							-- Ambil energi via Remote
							ReplicatedStorage.EVENTS.PlayerEvents.CollectItem:FireServer(energyItem)
							FastWait(1)

							ReplicatedStorage.EVENTS.PlayerEvents.ConsumeItem:FireServer(false, energyItem.Name)

							task.wait(1)
							ReplicatedStorage.EVENTS.PlayerEvents.ConsumeItem:FireServer(true)
							
							RunOutEnergy = energyFill.Size.Y.Scale >= 0.2
						end
					end

					-- 2. Periksa Kantong Sampah (Jika Penuh)
					if FullGarbagebags or garbagebagsFill.Size.Y.Scale >= 0.98 then
						-- Teleport ke Grinding Machine / Tempat Pembuangan
						Character:PivotTo(CFrame.new(Vector3.new(GrindingMachinePosition.X, rootPart.Position.Y + 3, GrindingMachinePosition.Z)))
						FastWait(0.4)

						-- Membuang sampah
						ReplicatedStorage.EVENTS.PlayerEvents.ThrowItem:FireServer(
							Vector3.new(0.96049702167511, -0.25137504935265, -0.11939886957407),
							10
						)
						
						FullGarbagebags = garbagebagsFill.Size.Y.Scale < 0.98
					end

					-- 3. Periksa dan Proses Ambil Sampah
					local itemFound = false
					if itemSpawns then
						for _, area in ipairs(itemSpawns:GetChildren()) do
							if not CleanEnabled then break end

							for _, spwn in ipairs(area:GetChildren()) do
								if not CleanEnabled then break end

								local itemsFolder = spwn:FindFirstChild("Items")
								if itemsFolder then
									for _, item in ipairs(itemsFolder:GetChildren()) do
										if not CleanEnabled then break end
										if not item or not item.Parent then continue end

										-- Interupsi jika tiba-tiba tas penuh atau energi habis saat sedang nge-loop item
										if (FullGarbagebags or garbagebagsFill.Size.Y.Scale >= 0.98) or (RunOutEnergy or energyFill.Size.Y.Scale <= 0.2) then
											break
										end

										local part = item:FindFirstChildWhichIsA("BasePart")
										if part then
											itemFound = true
											-- Teleport ke lokasi sampah
											Character:PivotTo(part.CFrame + Vector3.new(0, 3, 0))
											FastWait(0.1)

											-- Ambil sampah via Remote
											ReplicatedStorage.EVENTS.PlayerEvents.CollectItem:FireServer(item)
											FastWait(0.1)
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

Window:AddButton({
	Text = "Go Home",
	MethodType = "DoubleClick",
	Callback = function()
		-- 1. Ambil posisi dan rotasi (Pivot) karakter saat ini
		local charPivot = Character:GetPivot()

		-- 2. Ambil X dan Z dari part, dan Y dari karakter
		local targetX = VendingMachinePosition.X
		local targetZ = VendingMachinePosition.Z
		local targetY = charPivot.Position.Y

		-- 3. Buat posisi baru
		local newPosition = Vector3.new(targetX, targetY, targetZ)

		-- 4. Gabungkan rotasi asli karakter dengan posisi yang baru
		local newCFrame = charPivot.Rotation + newPosition

		-- 5. Pindahkan karakter
		Character:PivotTo(newCFrame)
	end
})

Window:AddLabel("YouTube: Crokyreo")
