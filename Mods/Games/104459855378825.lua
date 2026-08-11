local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local Packets = {}
local Enableds, Connections = {KickBall = false, Rebirth = false}, {}

local RebirthFrame, RebirthFill, RebirthButton = nil, nil, nil

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

local function HandleKickBall()
	if not Enableds.KickBall then return end
	Packets.KickBall = Packets.KickBall or ReplicatedStorage:QueryDescendants('#Remotes > #KickBall')[1]

	task.spawn(function()
		while Enableds.KickBall do
			Packets.KickBall:FireServer()
			task.wait(0.1)
		end
	end)
end

local function HandleRebirth()
	if Connections.Rebiirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end

	RebirthFrame = RebirthFrame or PlayerGui:QueryDescendants("#Main > #Container > #Frames > #Rebirth")[1]

	if RebirthFrame then
		RebirthFill = RebirthFill or RebirthFrame:QueryDescendants("#Bar > #CanvasGroup > #Filler")[1]
		RebirthButton = RebirthButton or RebirthFrame:QueryDescendants("#ProductHolders > #Purchaseyes")[1]
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
			task.wait(0.5)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "+1 Strength Soccer Escape",
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

Window:AddToggle({
	Text = "Wins Farm",
	Value = false,
	Flag = "wins_enabled",
	Callback = function(value)
		--[[
		workspace.Stages
		workspace.Stages.Stage5.Wall
		workspace.Stages.Stage5.ClaimWins.Main
		]]
	end
})

Window:AddToggle({
	Text = "Kick Ball",
	Value = false,
	Flag = "kick_ball_enabled",
	Callback = function(value)
		Enableds.KickBall = value
		HandleKickBall()
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
	Text = "Date: 08-05-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
