local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local RebirthConnection = nil
local MoveEnabled = false

local CircleRadius = 0
local AngleStep, CurrentAngle = 0.1, 0

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
		CurrentAngle = 0
		while MoveEnabled do
			task.wait()

			local character = LocalPlayer.Character
			if not (character and character.Parent) then continue end
			
			local rootPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
			if not rootPart then continue end
			
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not humanoid then continue end

			local characterSize = character:GetExtentsSize()
            local baseRadius = math.max(characterSize.X, characterSize.Z) / 2

			CircleRadius = baseRadius * 0.8
			
			local centerPoint = rootPart.Position
				
			local targetX = centerPoint.X + math.cos(CurrentAngle) * CircleRadius
			local targetZ = centerPoint.Z + math.sin(CurrentAngle) * CircleRadius
			
			local targetPosition = Vector3.new(targetX, rootPart.Position.Y, targetZ)
			
			humanoid:MoveTo(targetPosition)
			
			CurrentAngle = CurrentAngle + AngleStep
			if CurrentAngle >= math.pi * 2 then
				CurrentAngle = 0
			end
			
			task.wait(0.1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "+1 Shrink Per Step",
	Destroying = function()
		MoveEnabled = false
		if RebirthConnection then RebirthConnection:Disconnect() RebirthConnection = nil end
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
