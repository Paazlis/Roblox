-- UI Library --
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer

local Enableds, Connections, Packets = {Build = false}, {}, {}

-- Mencari RemoteEvents dengan aman
Packets.PlaceBrickRequest = ReplicatedStorage:QueryDescendants("#Remotes > #PlaceBrickRequest")[1] or ReplicatedStorage:FindFirstChild("PlaceBrickRequest", true)
Packets.BrickPileRequest = ReplicatedStorage:QueryDescendants("#Remotes > #BrickPileRequest")[1] or ReplicatedStorage:FindFirstChild("BrickPileRequest", true)

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
				local rowNum = tonumber(brick.Name:match("Row(%d+)")) or 999
				local brickNum = tonumber(brick.Name:match("Brick(%d+)")) or 999

				-- Gabungkan nama untuk dikirim ke server (contoh: "Layer1_Wall4_Row5_Brick14")
				local requestString = layer.Name .. "_" .. brick.Name

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

	-- Mengurutkan antrean: Layer terkecil -> Row terkecil -> Brick terkecil
	table.sort(queue, function(a, b)
		if a.LayerNum ~= b.LayerNum then
			return a.LayerNum < b.LayerNum
		elseif a.RowNum ~= b.RowNum then
			return a.RowNum < b.RowNum
		else
			return a.BrickNum < b.BrickNum
		end
	end)

	return queue
end

local function HandleBuild()
	if not Enableds.Build then return end

	task.spawn(function()
		while Enableds.Build do
			-- Dapatkan daftar bata yang harus dibangun
			local queue = GetBuildQueue()

			if #queue == 0 then
				-- Jika tidak ada yang perlu dibangun, tunggu sebelum mengecek lagi
				task.wait(1)
				continue
			end

			for _, brickData in ipairs(queue) do
				if not Enableds.Build then break end

				-- Pastikan bata masih ada dan belum dibangun orang lain (masih Glass)
				if brickData.Instance and brickData.Instance.Parent and brickData.Instance.Material == Enum.Material.Glass then
					
					-- Mengambil Brick dari Pile
					if Packets.BrickPileRequest then
						Packets.BrickPileRequest:FireServer("Brick")
					end

					task.wait(0.05) -- Beri jeda sangat singkat agar server mendaftarkan bata di tangan kita

					-- Menempatkan Brick ke target
					if Packets.PlaceBrickRequest then
						Packets.PlaceBrickRequest:FireServer(brickData.RequestString)
					end

					-- Tunggu sampai material bata berubah (tidak Glass lagi), agar tidak spam event berkali-kali
					local attempt = 0
					while Enableds.Build and brickData.Instance.Material == Enum.Material.Glass and attempt < 20 do
						attempt += 1
						task.wait(0.1)

						-- Coba ambil dan tempatkan lagi jika setelah 0.5 detik tidak ada perubahan
						if attempt % 5 == 0 then
							if Packets.BrickPileRequest then Packets.BrickPileRequest:FireServer("Brick") end
							if Packets.PlaceBrickRequest then Packets.PlaceBrickRequest:FireServer(brickData.RequestString) end
						end
					end
				end
			end

			task.wait(0.5)
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
	Text = "Date: 08-10-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
