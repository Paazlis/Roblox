local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})

local Enableds, Connections = {Customer = false}, {}
local CustomersFolder = workspace

local BillboardPool = {}
local ActiveESP = {}

local function GetBillboard()
	local billboard = table.remove(BillboardPool)

	if not billboard then
		billboard = Instance.new("BillboardGui")
		billboard.Name = math.random()
		billboard.Size = UDim2.new(0, 150, 0, 30)
		billboard.AlwaysOnTop = true
		billboard.StudsOffset = Vector3.new(0, 2, 0)

		local label = Instance.new("TextLabel")
		label.Name = "Title"
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

local function ReleaseBillboard(billboard)
	billboard.Enabled = false
	billboard.Adornee = nil
	table.insert(BillboardPool, billboard)
end

local function RemoveESP(child)
	local data = ActiveESP[child]
	if data then
		ActiveESP[child] = nil

		if data.Connections then
			for _, conn in ipairs(data.Connections) do
				conn:Disconnect()
			end
		end

		ReleaseBillboard(data.Billboard)
	end
end

local function AddESP(child)
	-- Cegah duplikasi atau jika toggle dimatikan di tengah jalan
	if ActiveESP[child] or not Enableds.Customer then return end

	-- Cari part penempel ESP (Tunggu sejenak jika belum tereplikasi)
	local adornee = child:FindFirstChild("Head")
		or child:FindFirstChild("HumanoidRootPart")
		or child.PrimaryPart
		or child:FindFirstChildOfClass("BasePart")

	if not adornee then return end

	-- Ambil BillboardGui dari Pool
	local billboard = GetBillboard()
	billboard.Adornee = adornee
	billboard.Parent = ParentGui

	local label = billboard:FindFirstChild("Title")
	label.Text = "Theft: " .. tostring(child:GetAttribute("TheftType") or "None")

	local childConnections = {}

	-- Update teks real-time jika TheftType berubah
	table.insert(childConnections, child:GetAttributeChangedSignal("TheftType"):Connect(function()
		label.Text = "Theft: " .. tostring(child:GetAttribute("TheftType") or "None")
	end))

	-- Kembalikan ke pool saat customer dihancurkan / keluar dari Workspace
	table.insert(childConnections, child.AncestryChanged:Connect(function(_, parent)
		if not parent or not child:IsDescendantOf(CustomersFolder) then
			RemoveESP(child)
		end
	end))

	ActiveESP[child] = {
		Billboard = billboard,
		Connections = childConnections
	}
end

local function ProcessCustomer(child)
	task.wait(2) 

	if ActiveESP[child] or not Enableds.Customer then return end
	if not (child and child.Parent and child:IsA("Model")) then return end
	if not string.match(child.Name, "^Customer_") then return end

	local humanoid = child:FindFirstChildOfClass("Humanoid") or child:WaitForChild("Humanoid", 3)
	if not humanoid then return end

	local thetfType = child:GetAttribute("TheftType") or child:GetAttributeChangedSignal("TheftType"):Wait()
	if thetfType == "none" then return end

	AddESP(child)
end

local function ClearAllESP()
	for child, _ in pairs(ActiveESP) do
		RemoveESP(child)
	end
end

local function ESPCustomer()
	if Connections.Customer then Connections.Customer:Disconnect() Connections.Customer = nil end
	ClearAllESP()

	if Enableds.Customer then
		Connections.Customer = CustomersFolder.ChildAdded:Connect(function(child)
			task.spawn(ProcessCustomer, child)
		end)

		task.spawn(function()
			while Enableds.Customer do
				for _, child in ipairs(CustomersFolder:GetChildren()) do
					if not ActiveESP[child] then
						ProcessCustomer(child)
						task.wait()
					end
				end
				task.wait(1)
			end
		end)
	end
end

local Window = UI:CreateWindow({
	Name = "Secure the Supermarket",
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

ParentGui = Window.Gui

Window:AddToggle({
	Text = "ESP Child", 
	Value = false, 
	Callback = function(value)
		Enableds.Child = value
		ESPCustomer()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
