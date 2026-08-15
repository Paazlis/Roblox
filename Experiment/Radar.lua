local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local RunService = Services.RunService

local player = Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()

-- =========================================
-- KONFIGURASI RADAR
-- =========================================
local targetMaterial = Enum.Material.Neon -- Ganti "Neon" dengan material yang ingin dilacak
local radarRange = 150 -- Jarak maksimal radar dalam studs
local blipColor = Color3.fromRGB(255, 50, 50) -- Warna titik di radar (Merah)
-- =========================================

-- 1. Membuat GUI Radar secara otomatis melalui script
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MaterialRadarGui"
screenGui.ResetOnSpawn = false

local radarBackground = Instance.new("Frame")
radarBackground.Name = "Background"
radarBackground.Size = UDim2.new(0, 200, 0, 200)
radarBackground.Position = UDim2.new(1, -220, 1, -220) -- Berada di pojok kanan bawah
radarBackground.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
radarBackground.BackgroundTransparency = 0.5
radarBackground.ClipsDescendants = true
radarBackground.Parent = screenGui

-- Membuat radar berbentuk lingkaran
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = radarBackground

-- Membuat titik putih di tengah (Posisi Player)
local centerPlayer = Instance.new("Frame")
centerPlayer.Size = UDim2.new(0, 6, 0, 6)
centerPlayer.Position = UDim2.new(0.5, -3, 0.5, -3)
centerPlayer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
centerPlayer.ZIndex = 2
local centerCorner = Instance.new("UICorner")
centerCorner.CornerRadius = UDim.new(1, 0)
centerCorner.Parent = centerPlayer
centerPlayer.Parent = radarBackground

local blipTemp = Instance.new("Frame")
blipTemp.Size = UDim2.new(0, 6, 0, 6)
blipTemp.BackgroundColor3 = blipColor
blipTemp.Visible = false

local blipCorner = Instance.new("UICorner")
blipCorner.CornerRadius = UDim.new(1, 0)
blipCorner.Parent = blipTemp

blipTemp.Parent = radarBackground

screenGui.Parent = UI:GetProtectGui(screenGui)

-- 2. Mencari Part berdasarkan Material
local targetParts = {}
for _, obj in pairs(workspace:GetDescendants()) do
	if obj:IsA("BasePart") and obj.Material == targetMaterial then
		table.insert(targetParts, obj)
	end
end

player.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
end)

local blips = {} -- Tabel untuk menyimpan UI titik part

-- 3. Fungsi Utama Radar (Berjalan setiap frame)
local function updateRadar()
	if not (Character and Character.Parent) then return end
  
	local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
  
	local radarRadius = radarBackground.AbsoluteSize.X / 2

	-- Bersihkan cache jika part hancur/dihapus dari workspace
	for i = #targetParts, 1, -1 do
		local part = targetParts[i]
		if not part or not part.Parent then
			if blips[part] then
				blips[part]:Destroy()
				blips[part] = nil
			end
			table.remove(targetParts, i)
		end
	end

	-- Update posisi titik blip di radar
	for _, part in ipairs(targetParts) do
		-- CFrame:ToObjectSpace mengubah posisi dunia (3D) menjadi posisi relatif terhadap rotasi/arah pandang player
		local relativePos = rootPart.CFrame:ToObjectSpace(part.CFrame).Position
		
		-- Hitung jarak mendatar (Sumbu X dan Z saja)
		local distance = Vector2.new(relativePos.X, relativePos.Z).Magnitude

		if distance <= radarRange then
			-- Jika belum ada titik/blip untuk part ini, buat baru
			local blip = blips[part]
			if not blip then
        blip = blipTemp:Clone()
				blip.Parent = radarBackground
				blips[part] = blip
			end

			-- Skalakan jarak dunia (studs) ke jarak piksel UI
			local mapScale = radarRadius / radarRange
			local blipX = relativePos.X * mapScale
			local blipY = relativePos.Z * mapScale

			-- Set posisi blip (relatif dari tengah frame radar)
			blip.Position = UDim2.new(0.5, blipX - 3, 0.5, blipY - 3)
			blip.Visible = true
		else
			-- Sembunyikan titik jika di luar jangkauan radar
			if blips[part] then 
				blips[part].Visible = false 
			end
		end
	end
end

-- Hubungkan fungsi ke RenderStepped agar diperbarui secara halus setiap frame
RunService.RenderStepped:Connect(updateRadar)
