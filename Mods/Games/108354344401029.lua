local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local Enableds, Connections, Packets = {["Click"] = false, ["Rebirth"] = false}, {}, {}
local RebirthFrame, RebirthFill, RebirthButton = nil, nil, nil

Packets.ScreamClicked = ReplicatedStorage:QueryDescendants("#Remotes > #ScreamClicked")[1]

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

local function HandleClick()
	if not Enableds.Click then return end

	task.spawn(function()
		while Enableds.Click do
			Packets.ScreamClicked:FireServer()
			task.wait()
		end
	end)
end

local function HandleRebirth()
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end

	RebirthFrame = RebirthFrame or PlayerGui:QueryDescendants("#MainUI > #Frames > #Rebirth")[1]

	if RebirthFrame then
		RebirthFill = RebirthFill or RebirthFrame:QueryDescendants("#Main > #FillBar > #Bar")[1]
		RebirthButton = RebirthButton or RebirthFrame:QueryDescendants("#Main > #Rebirth")[1]
	end

	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
		if IsFillFull(RebirthFill) and Enableds.Rebirth then
			FireButton(RebirthButton)
		end
	end)

	task.spawn(function()
		while Enableds.Rebirth do
			if IsFillFull(RebirthFill) then
				FireButton(RebirthButton)
			end
			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "+1 Scream Per Click",
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
	Text = "Fast Click",
	Value = false,
	Flag = "click_enabled",
	Callback = function(value)
		Enableds.Click = value
		HandleClick()
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

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-13-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
