local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local RebirthConnection = nil
local MoveEnabled, MoveIntensity, MoveRadius = false, "Low", 10

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

local function AutoMove()
	if not MoveEnabled then return end
	task.spawn(function()
		while MoveEnabled do
			task.wait()
			
			local character = LocalPlayer.Character
			if not (character and character.Parent) then continue end
			
			local rootPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
			if not rootPart then continue end
			
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not humanoid then continue end
			local centerPoint = rootPart.Position
	local angle = 0
	
	while humanoid.Health > 0 do
	local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local movementIntensity = "Medium"

local circleRadius = 10
local angleStep = 0.1

if movementIntensity == "Low" then
	circleRadius = 5
	angleStep = 0.05
elseif movementIntensity == "Medium" then
	circleRadius = 15
	angleStep = 0.1
elseif movementIntensity == "High" then
	circleRadius = 30
	angleStep = 0.2
end

local function moveCircularly()
	local centerPoint = rootPart.Position
	local angle = 0
	
	while humanoid.Health > 0 do
		local targetX = centerPoint.X + math.cos(angle) * circleRadius
		local targetZ = centerPoint.Z + math.sin(angle) * circleRadius
		
		local targetPosition = Vector3.new(targetX, rootPart.Position.Y, targetZ)
		
		humanoid:MoveTo(targetPosition)
		
		angle = angle + angleStep
		if angle >= math.pi * 2 then
			angle = 0
		end
		
		task.wait(0.1)
	end
end

task.spawn(moveCircularly)

	
	while humanoid.Health > 0 do
		local targetX = centerPoint.X + math.cos(angle) * circleRadius
		local targetZ = centerPoint.Z + math.sin(angle) * circleRadius
		
		local targetPosition = Vector3.new(targetX, rootPart.Position.Y, targetZ)
		
		humanoid:MoveTo(targetPosition)
		
		angle = angle + angleStep
		    if angle >= math.pi * 2 then
			angle = 0
		     end
		
		       task.wait(0.1)
	        end
				
			
			local timeElapsed = 0
			repeat
				local deltaTime = task.wait(0.1)
				timeElapsed = timeElapsed + deltaTime
				if not (character and character.Parent and rootPart.Parent) then break end
				local flatPosition = rootPart.Position * Vector3.new(1, 0, 1)
				local flatTarget = targetPosition * Vector3.new(1, 0, 1)
				local distance = (flatPosition - flatTarget).Magnitude
			until distance <= 3 or timeElapsed >= 8
			
			task.wait(math.random() * 1)
			
			humanoid:MoveTo(savePosition)
			
			timeElapsed = 0
			repeat
				local deltaTime = task.wait(0.1)
				timeElapsed = timeElapsed + deltaTime
				if not (character and character.Parent and rootPart.Parent) then break end
				local flatPosition = rootPart.Position * Vector3.new(1, 0, 1)
				local flatTarget = savePosition * Vector3.new(1, 0, 1)
				local distance = (flatPosition - flatTarget).Magnitude
			until distance <= 3 or timeElapsed >= 8
			
			task.wait(math.random() * 1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "+1 Shrink Per Step",
	Destroying = function()
		if RebirthConnection then RebirthConnection:Disconnect() RebirthConnection = nil end
	end
})

Window:AddSelector({
	Text = "Move Intensity",
	Options = {"Low", "Medium", "High", "Ultra"},
	Value = MoveIntensity,
	NoCap = true,
	Callback = function(value)
		MoveIntensity = value
	end

})

Window:AddToggle({
	Text = "Auto Move",
	Value = false,
	Flag = "move_enabled",
	Callback = function(value)
		MoveEnabled = value
		AutoMove()
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
