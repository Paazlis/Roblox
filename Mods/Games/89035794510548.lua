local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager = Services.VirtualInputManager
local RunService = Services.RunService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Packets = {}
local Enableds, Connections = {NAME = false, Scan = true}, {}
local GameStageFolder = workspace:FindFirstChild("GameStage")
local StatusLabel = nil
local GameMode = "None"
local GameStats = {}
local BallColor = Color3.fromRGB(24, 26, 32)

local function ScanGameStage(child)
	if child:IsA("Folder") and child.Name == "GameStage" then
		GameStageFolder = child

		local done = false

		local knife = child:FindFirstChild("Knife")
		local log = nil
		
		for _, v1 in ipairs(child:GetChildren()) do if v1.Name == "Log" and v1:IsA("Model") then log = v1 break end end
		
		if knife ~= nil and log ~= nil then
			GameStats.Knife = knife
			GameStats.Log = log
			GameMode = "Knife Combo"
			done = true
		end

		if not done	then
			for _, v1 in ipairs(child:GetChildren()) do
				if v1:IsA("BasePart") and #v1:GetChildren() > 0 then
					local particleEmitter = v1:FindFirstChildOfClass("ParticleEmitter")
					local trail = v1:FindFirstChildOfClass("Trail")
					if trail ~= nil and particleEmitter ~= nil and v1.Color == BallColor then
						GameStats.Ball = v1
						GameMode = "Sharp Turns"
						done = false
						break
					end
				end
			end
		end

		if StatusLabel then
			StatusLabel:Set("Game Name: "..GameMode)
		end
	end
end

Connections.GameStageAdded = workspace.ChildAdded:Connect(ScanGameStage)

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local Window = UI:CreateWindow({
	Name = "Endless GAMES",
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

StatusLabel = Window:AddLabel({
	Text = "Game Name: "..GameMode,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextScaled = true
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
