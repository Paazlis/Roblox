local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local RebirthFrame, RebirthFill, RebirthButton = PlayerGui:QueryDescendants("#GUI > #Frames > #Rebirth")[1], nil, nil
local MultiplierFrame = PlayerGui:QueryDescendants("#GUI > #Multiplier")[1]
local TrainHUDButton, TrainHUDButtonTitle = PlayerGui:QueryDescendants("#GUI > #TrainButton")[1], nil

local Enableds, Connections, Values = {["Wins"] = false, ["Train"] = false, ["Rebirth"] = false}, {}, {}
local WinsCFrame = CFrame.new(Vector3.new(-5815.99854, 314.874481, -18))

if RebirthFrame then
	RebirthFill, RebirthButton = RebirthFrame:QueryDescendants("#Bar > #Progress")[1], RebirthFrame:FindFirstChild("RebirthButton")
end

if TrainHUDButton then
	TrainHUDButtonTitle = TrainHUDButton:FindFirstChild("Text")
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function IsFillFull(fill)
	if fill.Size.X.Scale >= 1 then
		return true
	end
	return false
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function HandleWins()
	if not Enableds.Wins then return end
	task.spawn(function()
		while Enableds.Wins do
			Character:PivotTo(WinsCFrame)
			task.wait()
		end
	end)
end

local function TrainAdded(button)
	if button:IsA("TextButton") or button:IsA("ImageButton") then
		task.wait(0.5)
		if not (button and button.Parent) then return end
		FireButton(button)
	end
end

local function HandleTrain()
	if Connections.TrainAdded then Connections.TrainAdded:Disconnect() Connections.TrainAdded = nil end
	if not Enableds.Train then return end
	Connections.TrainAdded = MultiplierFrame.ChildAdded:Connect(function(button)
		TrainAdded(button)
	end)
	for _, button in ipairs(MultiplierFrame:GetChildren()) do
		TrainAdded(button)
	end
	task.spawn(function()
		while Enableds.Train do
			if TrainHUDButtonTitle.Text == "Train" then
				FireButton(TrainHUDButton)
			end
			task.wait(0.5)
		end
	end)
end

local function FireRebirth()
	if Enableds.Rebirth and IsFillFull(RebirthFill) then
		FireButton(RebirthButton)
	end
end

local function HandleRebirth()
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end
	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Position"):Connect(FireRebirth)
	task.spawn(function()
		while Enableds.Rebirth do
			FireRebirth()
			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "+1 Stretch Escape",
	Destroying = function()
		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
	end
})

Window:AddToggle({
	Text = "Wins Farm (Last Area)",
	Value = false,
	Flag = "wins_enabled",
	Callback = function(value)
		Enableds.Wins = value
		HandleWins()
	end
})

Window:AddToggle({
	Text = "Auto Train",
	Value = false,
	Flag = "train_enabled",
	Callback = function(value)
		Enableds.Train = value
		HandleTrain()
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		Enableds.Rebirth = value
		HandleRebirth()
	end
})

--[[
Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-14-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
]]
Services.GuiService:SetGameplayPausedNotificationEnabled(false)
