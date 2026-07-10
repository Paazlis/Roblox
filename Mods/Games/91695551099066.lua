local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local RebirthConnection = nil
local MovementIntensity = "Low"

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

local Window = UI:CreateWindow({
	Name = "+1 Shrink Per Step",
	Destroying = function()
		if RebirthConnection then RebirthConnection:Disconnect() RebirthConnection = nil end
	end
})

Window:AddToggle({
	Text = "Auto Move",
    Callback = function(value)
		MoveEnabled = value
		local character = script.Parent
        local humanoid = character:WaitForChild("Humanoid")
        local rootPart = character:WaitForChild("HumanoidRootPart")

local movementIntensity = "Medium"

local moveRadius = 10
local waitTime = 2

if movementIntensity == "Low" then
	moveRadius = 5
	waitTime = 3
elseif movementIntensity == "Medium" then
	moveRadius = 15
	waitTime = 1.5
elseif movementIntensity == "High" then
	moveRadius = 30
	waitTime = 0.5
end

local function moveRandomly()
	while humanoid.Health > 0 do
		local randomX = math.random(-moveRadius, moveRadius)
		local randomZ = math.random(-moveRadius, moveRadius)
		
		local targetPosition = rootPart.Position + Vector3.new(randomX, 0, randomZ)
		
		humanoid:MoveTo(targetPosition)
		
		local timeElapsed = 0
		repeat
			local deltaTime = task.wait(0.1)
			timeElapsed = timeElapsed + deltaTime
			
			local flatPosition = rootPart.Position * Vector3.new(1, 0, 1)
			local flatTarget = targetPosition * Vector3.new(1, 0, 1)
			local distance = (flatPosition - flatTarget).Magnitude
			
		until distance <= 3 or timeElapsed >= 8
		
		task.wait(math.random() * waitTime)
	end
end

task.spawn(moveRandomly)
			
    end

})
Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		if RebirthConnection then RebirthConnection:Disconnect() RebirthConnection = nil end
		if value then
			local rebirthFill = PlayerGui.Main.Frames.Rebirths.Progress.CanvasGroup.Bar
			local rebirthButton = PlayerGui.Main.Frames.Rebirths.RebirthButton
			RebirthConnection = rebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
				if IsFillFull(rebirthFill) then
					FireButton(rebirthButton)
				end
			end)
			if IsFillFull(rebirthFill) then
				FireButton(rebirthButton)
			end
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
