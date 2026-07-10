local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local LocalPlayer = Players.LocalPlayer

local autoEquipEnabled = false
local autoClaimEnabled = false

local Window = UI:CreateWindow({
	Name = "Fish a Slime",
	Destroying = function()
		autoEquipEnabled = false
		autoClaimEnabled = false
	end
})

-- Daftar Multiplier Mutasi
local Mutations = {
	["Normal"] = 1,
	["Frozen"] = 1.2, ["Poison"] = 1.2, ["Electric"] = 1.3, ["Rainbow"] = 1.3,
	["Lightning"] = 1.4, ["Spooky"] = 1.4, ["Magma"] = 1.5, ["Shadow"] = 2,
	["Cosmic"] = 2.5, ["Blood"] = 2.5, ["Burnt"] = 2, ["Planetary"] = 2,
	["Blue Blood"] = 3,
}

-- Remotes Setup (Menggunakan WaitForChild agar tidak nil saat loading)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
if not Remotes then
	warn("[-] Folder 'Remotes' tidak ditemukan di ReplicatedStorage!")
end

local PlaceEvent = Remotes and Remotes:WaitForChild("Place", 5)
local PickupEvent = Remotes and Remotes:WaitForChild("PickupMob", 5)
local ClaimEvent = Remotes and Remotes:WaitForChild("Claim", 5)

local MyPlot = nil

-- Fungsi hitung skor kekuatan alat/slime
local function getToolScore(instance)
	if not instance then return -1 end
	local level = instance:GetAttribute("Level") or 1
	local mutation = instance:GetAttribute("Mutation")
	local mutationMult = Mutations[mutation] or 1
	return level * mutationMult
end

-- Cari plot berdasarkan UserId ATAU Nama Player (Lebih Aman)
local function getMyPlot()
	local plots = workspace:FindFirstChild("Plots")
	if plots then
		for _, plot in ipairs(plots:GetChildren()) do
			local ownerId = plot:GetAttribute("Owner")
			if ownerId then
				-- Cek kecocokan menggunakan string id maupun nama player
				if tostring(ownerId) == tostring(LocalPlayer.UserId) or tostring(ownerId) == LocalPlayer.Name then
					return plot
				end
			end
		end
	end
	return nil
end

-- Cari slot kosong urut dari angka terkecil
local function getEmptySlot()
	MyPlot = MyPlot or getMyPlot()
	if not MyPlot then return nil end

	local occupiedSlots = {}

	local placedHolder = MyPlot:FindFirstChild("PlacedHolder")
	if placedHolder then
		for _, model in ipairs(placedHolder:GetChildren()) do
			if model:IsA("Model") then
				local slotValue = model:FindFirstChild("slotValue")
				if slotValue and slotValue:IsA("ValueBase") then
					occupiedSlots[tostring(slotValue.Value)] = true
				end
			end
		end
	end

	local slotsFolder = MyPlot:FindFirstChild("Slots")
	if slotsFolder then
		local slots = {}
		for _, slot in ipairs(slotsFolder:GetChildren()) do
			if tonumber(slot.Name) then
				table.insert(slots, slot)
			end
		end

		table.sort(slots, function(a, b)
			return tonumber(a.Name) < tonumber(b.Name)
		end)
		
		for _, slot in ipairs(slots) do
			if not occupiedSlots[tostring(slot.Name)] then
				return tonumber(slot.Name)
			end
		end
	end

	return nil
end

-- Fungsi utama Auto Equip & Place
local function autoEquip()
	MyPlot = MyPlot or getMyPlot()
	if not MyPlot then 
		return 
	end

	local bestTool = nil
	local highestScore = -1
	local bestLocation = "" -- "Backpack", "Character", atau "Plot"

	-- 1. Scan isi Backpack
	for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
		if item:IsA("Tool") and item.Name ~= "Gym" then
			local score = getToolScore(item)
			if score > highestScore then
				highestScore = score
				bestTool = item
				bestLocation = "Backpack"
			end
		end
	end

	-- 2. Scan Karakter (Sedang dipegang)
	if LocalPlayer.Character then
		for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
			if item:IsA("Tool") and item.Name ~= "Gym" then
				local score = getToolScore(item)
				if score > highestScore then
					highestScore = score
					bestTool = item
					bestLocation = "Character"
				end
			end
		end
	end

	-- 3. Scan PlacedHolder di Plot (Apakah slime terbaik ada di luar?)
	local placedHolder = MyPlot:FindFirstChild("PlacedHolder")
	if placedHolder then
		for _, model in ipairs(placedHolder:GetChildren()) do
			local score = getToolScore(model)
			if score > highestScore then
				highestScore = score
				bestTool = model
				bestLocation = "Plot"
			end
		end
	end

	-- Jika tidak ada slime/tool sama sekali, hentikan fungsi
	if highestScore == -1 or not bestTool then 
		return 
	end

	-- FASE AKSI 1: Ambil slime jika posisinya ada di Plot
	if bestLocation == "Plot" then
		if PickupEvent then
			PickupEvent:InvokeServer(bestTool) 
			task.wait(0.4) -- Beri jeda replikasi server ke inventory
			
			-- Cari ulang slime yang baru diambil di dalam Backpack
			for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
				if item:IsA("Tool") and getToolScore(item) >= highestScore then
					bestTool = item
					bestLocation = "Backpack"
					break
				end
			end
		else
			return
		end
	end

	-- FASE AKSI 2: Equip ke tangan karakter
	if LocalPlayer.Character then
		local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			-- Jika belum di tangan, pindahkan ke tangan
			if bestTool.Parent ~= LocalPlayer.Character then
			    local newTool=nil
				
		        for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
			        if item:IsA("Tool") then
					   newTool=item
					end
				end
	            
				humanoid:EquipTool(bestTool)
				task.wait(0.2)

				if newTool then
					humanoid:EquipTool(newTool)
				end
			end
			
			-- Ambil target slot kosong
			local targetSlot = getEmptySlot()
			if not targetSlot then
				return
			end

			-- Taruh ke Plot menggunakan remote Cobalt
			if PlaceEvent then
				PlaceEvent:InvokeServer(targetSlot)
			end
		end
	end
end

-- Fungsi Auto Collect Cash
local function autoClaim()
	MyPlot = MyPlot or getMyPlot()
	if not MyPlot then return end

	local placedHolder = MyPlot:FindFirstChild("PlacedHolder")
	if placedHolder then
		for _, model in ipairs(placedHolder:GetChildren()) do
			if model:IsA("Model") then
				local slotValueObj = model:FindFirstChild("slotValue")
				if slotValueObj and slotValueObj:IsA("ValueBase") then
					if ClaimEvent then
						ClaimEvent:InvokeServer(slotValueObj.Value)
					end
				end
			end
		end
	end
end

-- UI Interaksi Button & Toggle
Window:AddButton({
	Name = "Teleport",
	Callback = function()
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-879, 304, 20)
		end
	end
})

Window:AddToggle({
	Text = "Equip Best",
	Callback = function(value)
		autoEquipEnabled = value
		if autoEquipEnabled then
			task.spawn(function()
				while autoEquipEnabled do
					autoEquip()
					task.wait(5)
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Collect Cash",
	Callback = function(value)
		autoClaimEnabled = value
		if value then
			task.spawn(function()
				while autoClaimEnabled do
					autoClaim()
					task.wait(1)
				end
			end)
		end
	end
})

Window:AddLabel( "YouTube: Crokyreo")
