local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local ActiveESPs = {} 
local NPCEnabled, LuggageEnabled, NPCAddedConnection, LuggageAddedConnection, LuggageRemovedConnection = false, false, nil, nil, nil
local npcs, realItem, luggages = nil, nil, nil

local function UnespNpc(npc)
	if npc.Parent then
		local humanoid=npc:FindFirstChildOfClass("Humanoid")
		if humanoid then 
			humanoid.DisplayDistanceType="Subject"
		end
	end
end

local function UnespLuggage(child)
	if ActiveESPs[child] then
		ActiveESPs[child]:Destroy()
		ActiveESPs[child] = nil
	end
end

local Window = UI:CreateWindow({
	Name = "Secure the Airport",
	Destroying = function()
		NPCEnabled=false
		if NPCAddedConnection then NPCAddedConnection:Disconnect() NPCAddedConnection = nil end
		for _, npc in ipairs(npcs:GetChildren()) do UnespNpc(npc) end
		LuggageEnabled = false
		if LuggageAddedConnection then LuggageAddedConnection:Disconnect() LuggageAddedConnection = nil end
		if LuggageRemovedConnection then LuggageRemovedConnection:Disconnect() LuggageRemovedConnection = nil end
		for _, luggage in ipairs(luggages:GetChildren()) do UnespLuggage(luggage) end
	end
})

local ParentGui = Window.Gui

local function EspNpc(npc)
	local xrayVisible=npc.XrayVisible

	local denied=false
	for i,item in ipairs(xrayVisible:GetChildren()) do
		for j,object in ipairs(realItem:GetChildren()) do
			if string.find(item.Name,object.Name) then
				denied=true
				break
			end
		end
	end
	local fakePassport=npc.Properties.RandomVariables.FakePassport
	if fakePassport.Value then
		denied=true
	end
	if denied and NPCEnabled then
		local humanoid=npc:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.DisplayDistanceType="Viewer" end
	end
end

local function EspLuggage(child)
	if ActiveESPs[child] then return end

	local denied = false
	local textToShow = "⚠️ Contraband"

	for i, item in ipairs(child:GetChildren()) do
		local lowerName = string.lower(item.Name)

		for j, str in ipairs({"lotsofcontraband", "bomb"}) do
			if string.find(lowerName, str) then
				denied = true
				if str == "bomb" then textToShow = "💣 BOMB!" end
				break
			end
		end

		if denied then break end

		if string.find(lowerName, "set") then  
			local contraband = item:FindFirstChild("Contraband")
			if contraband and contraband.Transparency <= 0 then
				denied = true
				break
			end
		end
	end

	if denied and LuggageEnabled then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "LuggageTextESP"
		billboard.Size = UDim2.new(0, 150, 0, 30)
		billboard.AlwaysOnTop = true
		billboard.StudsOffset = Vector3.new(0, 2, 0)
		billboard.Adornee = child.PrimaryPart or child:FindFirstChildOfClass("Part") or child

		local label = Instance.new("TextLabel")
		label.Parent = billboard
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = textToShow
		label.TextColor3 = Color3.fromRGB(255, 30, 30)
		label.TextSize = 14
		label.Font = Enum.Font.SourceSansBold

		label.TextStrokeTransparency = 0
		label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

		billboard.Parent = ParentGui
		ActiveESPs[child] = billboard
	end
end

Window:AddToggle({
	Text = "ESP Luggage", 
	Value = false, 
	Callback = function(value)
		NPCEnabled=value
		if NPCAddedConnection then NPCAddedConnection:Disconnect() NPCAddedConnection=nil end
		if value then
			NPCAddedConnection=npcs.ChildAdded:Connect(EspNpc)
			for _, npc in ipairs(npcs:GetChildren()) do EspNpc(npc) end
		else
			for _, npc in ipairs(npcs:GetChildren()) do UnespNpc(npc) end
		end
	end
})

Window:AddToggle({
	Text = "ESP Luggage", 
	Value = false, 
	Callback = function(value)
		LuggageEnabled = value
		if LuggageAddedConnection then LuggageAddedConnection:Disconnect() LuggageAddedConnection = nil end
		if LuggageRemovedConnection then LuggageRemovedConnection:Disconnect() LuggageRemovedConnection = nil end
		if value then
			LuggageAddedConnection = luggages.ChildAdded:Connect(EspLuggage)
			LuggageRemovedConnection = luggages.ChildRemoved:Connect(UnespLuggage)
			for _, luggage in ipairs(luggages:GetChildren()) do EspLuggage(luggage) end
		else
			for _, luggage in ipairs(luggages:GetChildren()) do UnespLuggage(luggage) end
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")

npcs = workspace.WorkspaceScriptable.Storage.NormalStorage.NPCWorkspace
realItem = ReplicatedStorage.Resources.NPCAssets.Items.RealContraband
luggages = workspace.WorkspaceScriptable.Storage.NormalStorage.LuggageOpenWorkspace
