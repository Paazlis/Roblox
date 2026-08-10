-- UI Library --
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer : Player = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections, Packets = {Build = false}, {}, {}

-- Mencari RemoteEvents dengan aman
Packets.PlaceBrickRequest = ReplicatedStorage:QueryDescendants("#Remotes > #PlaceBrickRequest")[1] or ReplicatedStorage:FindFirstChild("PlaceBrickRequest", true)
Packets.BrickPileRequest = ReplicatedStorage:QueryDescendants("#Remotes > #BrickPileRequest")[1] or ReplicatedStorage:FindFirstChild("BrickPileRequest", true)

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

-- Fungsi untuk mendapatkan semua bata yang belum dibangun (Material == Glass) dan mengurutkannya
local function GetBuildQueue()
	local queue = {}
	local testBuilding = workspace:FindFirstChild("TestBuilding")

	if not testBuilding then return queue end

	for _, layer in ipairs(testBuilding:GetChildren()) do
		-- Ekstrak angka dari nama Layer (contoh: "Layer1" -> 1)
		local layerNum = tonumber(layer.Name:match("%d+")) or 999 

		for _, brick in ipairs(layer:GetChildren()) do
			-- Periksa apakah ini bata dan materialnya adalah Glass
			if brick:IsA("BasePart") and brick.Material == Enum.Material.Glass then
				-- Ekstrak angka dari nama bata (contoh: "Wall4_Row5_Brick14")

				local splits = string.split(brick.Name, "_")
				if #splits >= 3 then
					local wallName, rowName, brickName = splits[1], splits[2], splits[3]
					
					local wallNum = tonumber(wallName:match("Wall(%d+)")) or 999
					local rowNum = tonumber(rowName:match("Row(%d+)")) or 999
					local brickNum = tonumber(brickName:match("Brick(%d+)")) or 999
					
					-- Gabungkan nama untuk dikirim ke server (contoh: "Layer1_Wall4_Row5_Brick14")
					local requestString = layer.Name .. "_" .. wallName .. "_" .. rowName .. "_" .. brickName
					
					table.insert(queue, {
						Instance = brick,
						LayerNum = layerNum,
						RowNum = rowNum,
						BrickNum = brickNum,
						RequestString = requestString
					})
				end
			
			end
		end
	end
	
	-- Mengurutkan antrean: Layer terkecil -> Row terkecil -> Brick terkecil
	table.sort(queue, function(a, b)
		return a.LayerNum < b.LayerNum
	end)
	
	table.sort(queue, function(a, b)
		return a.RowNum < b.RowNum
	end)
	
	table.sort(queue, function(a, b)
		return a.BrickNum < b.BrickNum
	end)

	return queue
end

local function HandleBuild()
	if not Enableds.Build then return end
	
	local BrickCache = GetBuildQueue()
	
	task.spawn(function()
		while Enableds.Build do
			-- Dapatkan daftar bata yang harus dibangun
			if #BrickCache == 0 then
				BrickCache = GetBuildQueue()
				-- Jika tidak ada yang perlu dibangun, tunggu sebelum mengecek lagi
				task.wait(1)
				continue
			end
			
			local heldItems = Character:FindFirstChild("ClientHeldItems")
			if not heldItems then
				for i=1,3 do
					if not Enableds.Build then break end
					-- Mengambil Brick dari Pile
					if Packets.BrickPileRequest then
						Packets.BrickPileRequest:FireServer("Brick")
					end
					task.wait(0.1)
				end
			end
			
			while #BrickCache > 0 do
				task.wait()
				
				if not Enableds.Build then break end
				
				local brickData = table.remove(BrickCache)
				
				-- Pastikan bata masih ada dan belum dibangun orang lain (masih Glass)
				if brickData and brickData.Instance and brickData.Instance.Parent and brickData.Instance.Material == Enum.Material.Glass then
					heldItems = Character:FindFirstChild("ClientHeldItems")
					if not heldItems then table.insert(BrickCache, brickData) break end

					task.wait(0.2) -- Beri jeda sangat singkat agar server mendaftarkan bata di tangan kita

					-- Menempatkan Brick ke target
					if Packets.PlaceBrickRequest then
						Packets.PlaceBrickRequest:FireServer(brickData.RequestString)
					end

					---- Tunggu sampai material bata berubah (tidak Glass lagi), agar tidak spam event berkali-kali
					--local attempt = 0
					--while Enableds.Build and brickData.Instance.Material == Enum.Material.Glass and attempt < 20 do
					--	attempt += 1
					--	task.wait(0.1)

					--	-- Coba ambil dan tempatkan lagi jika setelah 0.5 detik tidak ada perubahan
					--	if attempt % 5 == 0 then
					--		if Packets.BrickPileRequest then Packets.BrickPileRequest:FireServer("Brick") end
					--		if Packets.PlaceBrickRequest then Packets.PlaceBrickRequest:FireServer(brickData.RequestString) end
					--	end
					--end
				end
			end
		

			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Build a House",
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end

		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end
	end
})

Window:AddToggle({
	Text = "Auto Build",
	Value = false,
	Callback = function(value)
		Enableds.Build = value
		if value then
			HandleBuild()
		end
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
Window:AddLabel({
	Text = "Version: 5",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
Window:AddLabel({
	Text = "Date: 08-10-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
