-- workspace:GetChildren()[51].HiddenStolenItems  TheftType  workspace.Customer_Maya  workspace.Customer_Zoe

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Workspace = Services.Workspace
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

-- Library UI
local Enableds, Connections = {}, {}
local ParentGui = nil

--------------------------------------------------------------------------------
-- OBJECT POOLING SYSTEM (MEMORI EFEKTIF)
--------------------------------------------------------------------------------
local BillboardPool = {} -- Pool menampung BillboardGui
local ActiveESP = {}     -- Menampung ESP aktif: [CustomerModel] = {Billboard, Connections}

-- Mengambil BillboardGui dari Pool
local function GetBillboard()
	local billboard = table.remove(BillboardPool)

	if not billboard then
		billboard = Instance.new("BillboardGui")
		billboard.Name = "NOC_ESP"
		billboard.Size = UDim2.new(0, 150, 0, 30)
		billboard.AlwaysOnTop = true
		billboard.StudsOffset = Vector3.new(0, 2, 0)

		local label = Instance.new("TextLabel")
		label.Name = "ESPLabel"
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(255, 30, 30)
		label.TextSize = 14
		label.Font = Enum.Font.SourceSansBold
		label.TextStrokeTransparency = 0
		label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		label.Parent = billboard
	end

	billboard.Enabled = true
	return billboard
end

-- Mengembalikan BillboardGui ke Pool (TIDAK Di-Destroy)
local function ReleaseBillboard(billboard)
	billboard.Enabled = false
	billboard.Adornee = nil
	billboard.Parent = nil
	table.insert(BillboardPool, billboard)
end

--------------------------------------------------------------------------------
-- CUSTOMER LOGIC & ESP CONTROL
--------------------------------------------------------------------------------

local function RemoveESP(customer)
	local data = ActiveESP[customer]
	if data then
		if data.Connections then
			for _, conn in ipairs(data.Connections) do
				conn:Disconnect()
			end
		end
		
		ReleaseBillboard(data.Billboard)
		ActiveESP[customer] = nil
	end
end

local function AddESP(customer)
	-- Cegah duplikasi atau jika toggle dimatikan di tengah jalan
	if ActiveESP[customer] or not Enableds.Customer then return end

	-- Cari part penempel ESP (Tunggu sejenak jika belum tereplikasi)
	local adornee = customer:FindFirstChild("Head")
		or customer:FindFirstChild("HumanoidRootPart")
		or customer.PrimaryPart
		or customer:FindFirstChildOfClass("BasePart")

	if not adornee then return end

	-- Ambil BillboardGui dari Pool
	local billboard = GetBillboard()
	billboard.Adornee = adornee
	billboard.Parent = ParentGui

	local label = billboard:FindFirstChild("ESPLabel")
	local theftVal = customer:GetAttribute("TheftType") or "None"
	label.Text = "Theft: " .. tostring(theftVal)

	local customerConns = {}

	-- Update teks real-time jika TheftType berubah
	table.insert(customerConns, customer:GetAttributeChangedSignal("TheftType"):Connect(function()
		local updatedVal = customer:GetAttribute("TheftType")
		if updatedVal == nil then
			RemoveESP(customer)
		else
			label.Text = "Theft: " .. tostring(updatedVal)
		end
	end))

	-- Kembalikan ke pool saat customer dihancurkan / keluar dari Workspace
	table.insert(customerConns, customer.AncestryChanged:Connect(function(_, parent)
		if not parent then
			RemoveESP(customer)
		end
	end))

	ActiveESP[customer] = {
		Billboard = billboard,
		Connections = customerConns
	}
end

-- Fungsi khusus memproses Customer yang baru muncul (Mencegah Replication Delay)
local function ProcessCustomer(child)
	task.wait(2) 
	
	if not (child and child.Parent) then return end
	if not (child and child:IsA("Model")) then return end
	if not string.match(child.Name, "^Customer_") then return end

	-- Tunggu Humanoid ter-load (Maksimal 3 detik)
	local humanoid = child:FindFirstChildOfClass("Humanoid") or child:WaitForChild("Humanoid", 3)
	if not humanoid then return end

	-- Cek apakah customer adalah pencuri
	local thetfType = child:GetAttribute("TheftType") or child:GetAttributeChangedSignal("TheftType"):Wait()
	if thetfType == "none" then return end
	
	AddESP(child)
end

local function ClearAllESP()
	for customer, _ in pairs(ActiveESP) do
		RemoveESP(customer)
	end
end

local function SpyCustomer()
	if Connections.CustomerWorkspace then
		Connections.CustomerWorkspace:Disconnect()
		Connections.CustomerWorkspace = nil
	end

	if Enableds.Customer then
		-- Scan Customer yang sudah ada sebelumnya
		for _, child in ipairs(Workspace:GetChildren()) do
			task.spawn(ProcessCustomer, child)
		end

		-- Listener saat Customer baru spawn di Workspace
		Connections.CustomerWorkspace = Workspace.ChildAdded:Connect(function(child)
			task.spawn(ProcessCustomer, child)
		end)
	else
		ClearAllESP()
	end
end

--------------------------------------------------------------------------------
-- UI WINDOW & TOGGLE
--------------------------------------------------------------------------------
local Window = UI:CreateWindow({
	Name = "Secure the Supermarket",
	Destroying = function()
		Enableds.Customer = false
		SpyCustomer()
		
		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end
	end
})

ParentGui = Window.Gui

Window:AddToggle({
	Text = "ESP Customer", 
	Value = false, 
	Callback = function(value)
		Enableds.Customer = value
		SpyCustomer()
	end
})

Window:AddLabel({
  Text = "YouTube: Crokyreo",
  TextColor3 = Color3.fromRGB(255, 255, 255)
})
