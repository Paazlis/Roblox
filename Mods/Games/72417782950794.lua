local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local CleanEnabled = false

local GrindingMachinePosition, VendingMachinePosition = Vector3.new(122, 18, 135), Vector3.new(122, 18, 158)

local TrashFillConnection, EnergyFillConnection, DebrisAddedConnection, DebrisRemovedConnection, GameCleanConnection = nil, nil, nil, nil, nil
local TrashDebounce, EnergyDebounce = false, false
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

local Window = UI:CreateWindow({
	Name = "Clean the Backyard",
	Destroying = function()
		CleanEnabled = false
		TrashDebounce, EnergyDebounce = false, false
		if GameCleanConnection then GameCleanConnection:Disconnect() GameCleanConnection = nil end
		if TrashFillConnection then TrashFillConnection:Disconnect() TrashFillConnection = nil end
		if EnergyFillConnection then EnergyFillConnection:Disconnect() EnergyFillConnection = nil end
		if DebrisRemovedConnection then DebrisRemovedConnection:Disconnect() DebrisRemovedConnection = nil end
		if DebrisAddedConnection then DebrisAddedConnection:Disconnect() DebrisAddedConnection = nil end
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
		if DebrisRemovedConnection then DebrisRemovedConnection:Disconnect() DebrisRemovedConnection = nil end
		if DebrisAddedConnection then DebrisAddedConnection:Disconnect() DebrisAddedConnection = nil end
		table.clear(ItemsCache)
		for _, connection in ipairs(ItemsConnection) do if connection then connection:Disconnect() end end
		table.clear(ItemsConnection)

		if value then
			local energyFill = PlayerGui.InterfaceUI.StatsUI.Energy.ProgressBar.BarFrame
			local trashFill = PlayerGui.InterfaceUI.StatsUI["Garbage Bag"].ProgressBar.BarFrame
			local itemSpawns = workspace:FindFirstChild("ItemSpawns")

			TrashDebounce, EnergyDebounce = false, false

			-- Deteksi otomatis jika tas penuh atau energi habis via UI
			TrashFillConnection = trashFill:GetPropertyChangedSignal("Size"):Connect(function()
				TrashDebounce = trashFill.Size.Y.Scale >= 0.98
			end)

			EnergyFillConnection = energyFill:GetPropertyChangedSignal("Size"):Connect(function()
				EnergyDebounce = energyFill.Size.Y.Scale <= 0.2
			end)


			local spawnedDebris = workspace:FindFirstChild("SpawnedDebris")
				
			-- Loop Utama Auto Clean
			task.spawn(function()
				while CleanEnabled do
					local character = LocalPlayer.Character
					local primaryPart = character and character:FindFirstChild("HumanoidRootPart")

					if not primaryPart then 
						FastWait() 
						continue 
					end

					-- 1. LOGIK CEK ENERGI (Jika Habis)
					if EnergyDebounce or energyFill.Size.Y.Scale <= 0.2 then
						-- Teleport ke Vending Machine
						character:PivotTo(CFrame.new(VendingMachinePosition + Vector3.new(0, 3, 0)))
						FastWait(0.3)

						-- Membeli minuman/makanan lewat Remote Event yang ada di catatan kaki Cobalt kamu
						ReplicatedStorage.EVENTS.PlayerEvents.BuyRechargeItem:FireServer()
						FastWait(1)

						local success = pcall(function()
							local energy = spawnedDebris:FindFirstChild("SodaCan") or spawnedDebris:FindFirstChild("EnergyBar")
							ReplicatedStorage.EVENTS.PlayerEvents.ConsumeItem:FireServer(false, energy.Name)
						end)
						FastWait(1)
						if success then
                           ReplicatedStorage.EVENTS.PlayerEvents.ConsumeItem:FireServer(true)
						end
						EnergyDebounce = false
					end
							
					-- 2. LOGIK CEK TAS SAMPAH (Jika Penuh)
					if TrashDebounce or trashFill.Size.Y.Scale >= 0.98 then
						-- Teleport ke Grinding Machine / Tempat Pembuangan
						character:PivotTo(CFrame.new(GrindingMachinePosition + Vector3.new(0, 3, 0)))
						FastWait(0.4)

						-- Membuang sampah
						ReplicatedStorage.EVENTS.PlayerEvents.ThrowItem:FireServer(
							Vector3.new(0.96049702167511, -0.25137504935265, -0.11939886957407),
							10
						)
						FastWait(0.5)
						TrashDebounce = false
					end

					-- 3. PROSES ARCHIVE & LEOP AMBIL SAMPAH
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
										if trashFill.Size.Y.Scale >= 0.98 or energyFill.Size.Y.Scale <= 0.2 then
											break
										end
										
										
												
										local part = item:FindFirstChildWhichIsA("BasePart")
										if part then
											itemFound = true
											-- Teleport ke lokasi sampah
											character:PivotTo(part.CFrame + Vector3.new(0, 3, 0))
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
									
Window:AddLabel("YouTube: Crokyreo")
