local UI = (loadstring or load)(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager = Services.VirtualInputManager
local RunService = Services.RunService
local UserInputService = Services.UserInputService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = nil

local Packets = {}
local Enableds, Connections = {}, {}
local GameStageFolder = workspace:FindFirstChild("GameStage")
local StatusLabel = nil
local GameMode = "None"
local GameStats = {}
local BallColor = Color3.fromRGB(24, 26, 32)
local GameDebounce = false
local ClickPoint = Vector2.new(500, 500)
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Exclude
overlapParams.MaxParts = 10
overlapParams.ExcludeInstances = {}

local function ScanGameStage(child)
	if child:IsA("Folder") and child.Name == "GameStage" then
		GameStageFolder = child
		
		task.wait(1)
		
		GameDebounce = false
		
		local success = false

		local knife = child:FindFirstChild("Knife")
		local log = nil
		
		for _, v1 in ipairs(child:GetChildren()) do task.wait() if v1.Name == "Log" and v1:IsA("Model") then log = v1 break end end
		
		if knife ~= nil and log ~= nil then
			GameStats.Knife = knife
			GameStats.Log = log
			GameMode = "Knife Combo"
			success = true
		end
		
		if not success then
			local bird = nil
			for _, v1 in ipairs(child:GetChildren()) do task.wait() if v1.Name == "Bird" and v1:IsA("Model") then bird = v1 break end end
			if bird ~= nil then
				GameStats.Bird = bird
				GameMode = "Flappy Wings"
				success = true
			end
		end
		
		if not success	then
			for _, v1 in ipairs(child:GetChildren()) do
				task.wait()
				if v1:IsA("BasePart") and #v1:GetChildren() > 0 then
					local particleEmitter = v1:FindFirstChildOfClass("ParticleEmitter")
					local trail = v1:FindFirstChildOfClass("Trail")
					if trail ~= nil and particleEmitter ~= nil and v1.Color == BallColor then
						GameStats.Ball = v1
						GameMode = "Sharp Turns"
						success = false
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
Connections.GameStageRemoved = workspace.ChildRemoved:Connect(function(child)
    if child == GameStageFolder then
		GameStageFolder = nil
	end
end)

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function SendClick(x,y)
	VirtualInputManager:SendMouseButtonEvent(x,y,0,true,game,0)
	task.wait()
	VirtualInputManager:SendMouseButtonEvent(x,y,0,false,game,0)
end

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

local function HandleGame()
	if Connections.GameLooped then Connections.GameLooped:Disconnect() Connections.GameLooped = nil end
	if not Enableds.Active then return end
	
	Connections.GameLooped = RunService.RenderStepped:Connect(function(deltaTime)
		if not Enableds.Active then return end
		
		if GameMode == "Flappy Wings" then
			local birdModel = GameStats.Bird
			if not (birdModel ~= nil and birdModel.Parent ~= nil) then return end
			overlapParams.ExcludeInstances = {birdModel}
			local cframe, size = birdModel:GetBoundingBox()
			
			local parts = workspace:GetPartBoundsInRadius(cframe.Position, 25, overlapParams)
			if #parts > 2 then
				if not GameDebounce then
					GameDebounce = true
					
					SendClick(ClickPoint.X, ClickPoint.Y)
					
					GameDebounce = false
				end
			end
			
			table.clear(parts)
		end
	end)
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

Window:AddToggle({
	Text = "Game Active",
	Value = false,
	Flag = "active_enabled",
	Callback = function(value)
		Enableds.Active = value
		HandleGame()
	end
})

local ClickPointLabel=Window:AddLabel({
	Text="Click Point: "..tostring(ClickPoint)
})

Window:AddButton({
	Name="Click Point",
	Callback=function(s)
		task.delay(2,function()
			ClickPoint=UserInputService:GetMouseLocation()
			ClickPointLabel:Set("Click Point: " .. tostring(ClickPoint))
		end)
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
