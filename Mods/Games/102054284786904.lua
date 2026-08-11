local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer

local Enableds, Connections = {["NPC"] = false, ["Luggage"] = false}, {}
local ActiveESPs = {} 
local NPCFolder = workspace:QueryDescendants("#WorkspaceScriptable > #Storage > #NormalStorage > #NPCWorkspace")[1]
local RealContrabandFolder = ReplicatedStorage:QueryDescendants("#Resources > #NPCAssets > #Items > #RealContraband")[1]
local LuggageFolder = workspace:QueryDescendants("#WorkspaceScriptable > #Storage > #NormalStorage > #LuggageOpenWorkspace")[1]
local ParentGui = nil

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

local function EspNpc(npc)
	if not Enableds.NPC then return end
	local xrayVisible=npc.XrayVisible
	local denied=false
	for i,item in ipairs(xrayVisible:GetChildren()) do
		if not Enableds.NPC then return end
		for j,contraband in ipairs(RealContrabandFolder:GetChildren()) do
			if not Enableds.NPC then return end
			if string.find(item.Name,contraband.Name) then
				denied=true
				break
			end
		end
	end
	if not Enableds.NPC then return end
	local fakePassport=npc:QueryDescendants("#Properties > #RandomVariables > #FakePassport")
	if fakePassport.Value then
		denied=true
	end
	if denied and Enableds.NPC then
		local humanoid=npc:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.DisplayDistanceType="Viewer" end
	end
end

local function EspLuggage(child)
	if ActiveESPs[child] then return end
	local denied = false
	local textToShow = "⚠️ Contraband"
	for i, item in ipairs(child:GetChildren()) do
		if not Enableds.Luggage then return end
		local lowerName = string.lower(item.Name)
		for j, str in ipairs({"lotsofcontraband", "bomb"}) do
			if not Enableds.Luggage then return end
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
	if denied and Enableds.Luggage and not ActiveESPs[child] then
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

local function HandleNPC()
	if Connections.NPCAdded then Connections.NPCAdded:Disconnect() Connections.NPCAdded=nil end
	if Enableds.NPC then
		Connections.NPCAdded=NPCFolder.ChildAdded:Connect(EspNpc)
		for _, npc in ipairs(NPCFolder:GetChildren()) do EspNpc(npc) end
	else
		for _, npc in ipairs(NPCFolder:GetChildren()) do UnespNpc(npc) end
	end
end

local function HandleLuggage()
	if Connections.LuggageAdded then Connections.LuggageAdded:Disconnect() Connections.LuggageAdded = nil end
	if Connections.LuggageRemoved then Connections.LuggageRemoved:Disconnect() Connections.LuggageRemoved = nil end
	if Enableds.Luggage then
		Connections.LuggageAdded = LuggageFolder.ChildAdded:Connect(EspLuggage)
		Connections.LuggageRemoved = LuggageFolder.ChildRemoved:Connect(UnespLuggage)
		for _, luggage in ipairs(LuggageFolder:GetChildren()) do EspLuggage(luggage) end
	else
		for _, luggage in ipairs(LuggageFolder:GetChildren()) do UnespLuggage(luggage) end
	end
end

local Window = UI:CreateWindow({
	Name = "Secure the Airport",
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end

		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end

		if NPCFolder then
			for _, npc in ipairs(NPCFolder:GetChildren()) do UnespNpc(npc) end
		end

		if LuggageFolder then
			for _, luggage in ipairs(LuggageFolder:GetChildren()) do UnespLuggage(luggage) end
		end
	end
})

ParentGui = Window.Gui

Window:AddToggle({
	Text = "ESP NPC", 
	Value = false, 
	Callback = function(value)
		Enableds.NPC=value
		HandleNPC()
	end
})

Window:AddToggle({
	Text = "ESP Luggage", 
	Value = false, 
	Callback = function(value)
		Enableds.Luggage = value
		HandleLuggage()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255),
})

Window:AddLabel({
	Text = "Date: 07-03-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255),
})
