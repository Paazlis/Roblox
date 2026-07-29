local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections = {["Speedsters"] = false, ["Rebirth"] = false}, {}

local RebirthFrame, RebirthFill, RebirthButton = PlayerGui:QueryDescendants("#MainHUD > #Menus > #RebirthFrame")[1], nil, nil
if RebirthFrame then
	RebirthFill = RebirthFrame:QueryDescendants("#BarBG > #BarFill")[1]
	RebirthButton = RebirthFrame:FindFirstChild("RebirthButton")
end

local SpeedstersSuccessColor, SpeedstersEquipColor = Color3.new(210, 160, 40), Color3.new(30, 160, 90)
local SpeedstersData = {}
local SpeedstersScroll = PlayerGui:QueryDescendants("#MainHUD > #Menus > #SpeedstersFrame > #ScrollingFrame")[1]
if SpeedstersScroll then
	local sortSpeedsters = {}

	for _, speedstersLayer in ipairs(SpeedstersScroll:GetChildren()) do
		if speedstersLayer:IsA("GuiObject") then
			local speedstersTitle = speedstersLayer:FindFirstChild("UpgradeName")
			if not speedstersTitle then continue end
			table.insert(sortSpeedsters, {
				Name = speedstersTitle.Text,
				Tier = speedstersLayer.LayoutOrder,
				EquipButton = speedstersLayer:FindFirstChild("EquipButton")
			})
		end
	end

	table.sort(sortSpeedsters, function(a, b)
		return a.Tier < b.Tier
	end)
	
	SpeedstersData = sortSpeedsters
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function IsFillFull(fill)
	if fill.Size.X.Scale >= 1 then
		return true
	end
	return false
end

local function HandleSpeedsters()
	task.spawn(function()
		while Enableds.Speedsters do
			for _,  speedstersStats in ipairs(SpeedstersData) do
				if not Enableds.Speedsters then break end
				
				local equipButton = speedstersStats.EquipButton
				if not equipButton then continue end
				
				if equipButton.BackgroundColor3 == SpeedstersSuccessColor then
					FireButton(equipButton)
					task.wait()
					
					if equipButton.BackgroundColor3 ~= SpeedstersEquipColor then
						repeat task.wait() until not Enableds.Speedsters or equipButton.BackgroundColor3 ~= SpeedstersEquipColor
					end
					FireButton(equipButton)
				end
			end
			task.wait(0.5)
		end
	end)
end

local function HandleRebirth()
	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
		if Enableds.Rebirth and IsFillFull(RebirthFill) then
			FireButton(RebirthButton)
		end
	end)

	if Enableds.Rebirth then
		task.spawn(function()
			while Enableds.Rebirth do
				if IsFillFull(RebirthFill) then
					FireButton(RebirthButton)
				end
				task.wait(0.5)
			end
		end)
	end
end

local function HandleFinishRace()
	
end

local Window = UI:CreateWindow({
	Name = "Speedsters Infinite",
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

Window:AddButton({
	Text = "Finish Race",
	MethodType = "DoubleClick",
	Callback = HandleFinishRace
})

Window:AddToggle({
	Text = "Buy Speedsters",
	Value = false,
	Flag = "speedsters_enabled",
	Callback = function(value)
		Enableds.Speedsters = value
		if value then
			HandleSpeedsters()
		end
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		Enableds.Rebirth = value
		if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
		if value then
			HandleRebirth()
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
