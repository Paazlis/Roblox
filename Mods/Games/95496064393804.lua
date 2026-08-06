local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})

local Enableds, Connections = {["Chameleon"] = false}, {}
local ChameleonsFolder = workspace:FindFirstChild("Characters")
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
		ReleaseBillboard(data.Billboard)
	end
end

local function DestroyESP(child)
	local data = ActiveESP[child]
	if data then
		ActiveESP[child] = nil

		if data.Connections then
			for _, connection in ipairs(data.Connections) do
				connection:Disconnect()
			end
		end

		ReleaseBillboard(data.Billboard)
	end
end

local function SetESP(child, data)
   local billboard = data.Billboard

	local adornee = child
    if not adornee then continue end

    billboard.Adornee = adornee
	billboard.Enabled = true

	local label = billboard:FindFirstChild("Title")
	label.Text = child.Name
	
	local billboardGui = child:FindFirstChildOfClass("BillboardGui")

	if billboardGui then
	   label.TextColor3 = billboardGui.Enabled == true and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 30, 30)
	end
end

local function AddESP(child)
	-- Cegah duplikasi atau jika toggle dimatikan di tengah jalan
	if ActiveESP[child] ~= nil or not Enableds.Chameleon then return end

	-- Cari part penempel ESP (Tunggu sejenak jika belum tereplikasi)
	local adornee = child
	if not adornee then return end

	-- Ambil BillboardGui dari Pool
	local billboard = GetBillboard()
	billboard.Adornee = adornee
	billboard.Parent = ParentGui

	local label = billboard:FindFirstChild("Title")
	label.Text = child.Name
	
	local childConnections = {}

	local billboardGui = child:FindFirstChildOfClass("BillboardGui")

	if billboardGui then
	   label.TextColor3 = billboardGui.Enabled == true and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 30, 30)

	   childConnections.BillboardGuiChanged = billboardGui:GetPropertyChangedSignal("Enabled"):Connect(function(_, parent)
		  label.TextColor3 = billboardGui.Enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 30, 30)
	   end)
	end
	
	-- Kembalikan ke pool saat customer dihancurkan / keluar dari Workspace
	childConnections.AncestryChanged = child.AncestryChanged:Connect(function(_, parent)
		if not parent or not child:IsDescendantOf(ChameleonsFolder) then
			DestroyESP(child)
		end
	end)
	
	ActiveESP[child] = {
		Billboard = billboard,
		Connections = childConnections
	}
end

local function ProcessChameleon(child)
	task.wait(1) 

	if ActiveESP[child] or not Enableds.Chameleon then return end
	if not (child and child.Parent) then return end

	AddESP(child)
end

local function RemoveAllESP()
	for child, _ in pairs(ActiveESP) do
		RemoveESP(child)
	end
end

local function ClearAllESP()
	for child, _ in pairs(ActiveESP) do
		DestroyESP(child)
	end
end

local function ESPChameleon()
	if Connections.ChameleonAdded then Connections.ChameleonAdded:Disconnect() Connections.ChameleonAdded = nil end
	RemoveAllESP()
	if not Enableds.Chameleon then return end
	
	Connections.ChameleonAdded = ChameleonsFolder.ChildAdded:Connect(function(child)
		task.spawn(ProcessChameleon, child)
	end)

	if next(ActiveESP) then
		for child, data in pairs(ActiveESP) do
			if not Enableds.Chameleon then break end
			SetESP(child, data)
	    end
	end
	
	task.spawn(function()
		while Enableds.Chameleon do
			for _, child in ipairs(ChameleonsFolder:GetChildren()) do
				if not Enableds.Chameleon then break end
				ProcessChameleon(child)
				task.wait()
			end
			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Find the Chameleons",
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end

		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end

		ClearAllESP()
	end
})

ParentGui = Window.Gui

Window:AddToggle({
	Text = "ESP Chameleon", 
	Value = false, 
	Callback = function(value)
		Enableds.Chameleon = value
		ESPChameleon()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-06-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
