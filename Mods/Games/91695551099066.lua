local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local RebirthConnection = nil
local MoveEnabled, MoveRadius = false, 5

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
		
			local savePosition = rootPart.Position
			
			task.wait(math.random() * 0.1)
				
			local randomX, randomZ = math.random(-MoveRadius, MoveRadius), math.random(-MoveRadius, MoveRadius)
			local targetPosition = rootPart.Position + Vector3.new(randomX, 0, randomZ)

			
			humanoid:MoveTo(targetPosition)
			
			local timeElapsed = 0
			repeat
				local deltaTime = task.wait()
				timeElapsed = timeElapsed + deltaTime
				if not MoveEnabled or not (character and character.Parent and rootPart.Parent) then break end
				local flatPosition = rootPart.Position * Vector3.new(1, 0, 1)
				local flatTarget = targetPosition * Vector3.new(1, 0, 1)
				local distance = (flatPosition - flatTarget).Magnitude
			until distance <= 3 or timeElapsed >= 8
			
			task.wait(math.random() * 0.1)

			if not MoveEnabled then
				if rootPart.Parent ~= nil then
					humanoid:MoveTo(rootPart.Position)
				end
				continue
			end

			humanoid:MoveTo(savePosition)
		
			timeElapsed = 0
			repeat
				local deltaTime = task.wait()
				timeElapsed = timeElapsed + deltaTime
				if not MoveEnabled or not (character and character.Parent and rootPart.Parent) then break end
				local flatPosition = rootPart.Position * Vector3.new(1, 0, 1)
				local flatTarget = savePosition * Vector3.new(1, 0, 1)
				local distance = (flatPosition - flatTarget).Magnitude
			until distance <= 2 or timeElapsed >= 8
				
			task.wait(math.random() * 0.1)

			if not MoveEnabled and rootPart.Parent ~= nil then
				humanoid:MoveTo(rootPart.Position)
			end
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
