local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local RebirthConnection = nil
local MoveEnabled = false

local CircleRadius = 5
local AngleStep = 0.1

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
				
			local targetX = centerPoint.X + math.cos(angle) * CircleRadius
			local targetZ = centerPoint.Z + math.sin(angle) * CircleRadius
			
			local targetPosition = Vector3.new(targetX, rootPart.Position.Y, targetZ)
			
			humanoid:MoveTo(targetPosition)
			
			angle = angle + AngleStep
			if angle >= math.pi * 2 then
				angle = 0
			end
			
			task.wait(0.1)
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
