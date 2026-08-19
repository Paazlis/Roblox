local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections, Packets = {["Click"] = false, ["Rebirth"] = false}, {}, {}
local RebirthFrame, RebirthFill, RebirthButton = nil, nil, nil

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function IsFillFull(fill)
	return fill.Size.X.Scale >= 1
end

local function PlayerRequestStreamAroundAsync(position, timeOut)
	pcall(function()
		LocalPlayer:RequestStreamAroundAsync(position, timeOut)
	end)
end

local function HandleClick()
	if not Enableds.Click then return end
	Packets.Click = Packets.Click or ReplicatedStorage:QueryDescendants("#Remotes > #JumpXpEvent")[1]
	task.spawn(function()
		while Enableds.Click do
			Packets.Click:FireServer()
			task.wait()
		end
	end)
end

local function FireRebirth()
	if IsFillFull(RebirthFill) and Enableds.Rebirth then
		FireButton(RebirthButton)
	end
end

local function HandleRebirth()
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end
	RebirthFrame = RebirthFrame or PlayerGui:QueryDescendants("#MainUI > #Frames > #Rebirth > #Main > #Holder")[1]
	if RebirthFrame then
		RebirthFill = RebirthFill or RebirthFrame:QueryDescendants("#RequirementsFrame > #Main > #Main > #Progress")[1]
		RebirthButton = RebirthButton or RebirthFrame:QueryDescendants("#Frame > #Rebirth")[1]
	end
	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(FireRebirth)
	task.spawn(function()
		while Enableds.Rebirth do
			FireRebirth()
			task.wait(1)
		end
	end)
end

local function HandleFinishRace()
	local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local rayOrigin = rootPart.Position
	local rayDirection = Vector3.new(0, -100, 0)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	if raycastResult then
		local hit = raycastResult.Instance
		if not hit then return end

		local target = hit

		while target ~= workspace do
			task.wait()

			for _, child in ipairs(target:GetChildren()) do
				if child and child:IsA("BasePart") and child.Name:find("Win") then
					target = child
					break
				end
			end

			if target and target.Name:find("Win")  then
				break
			end

			target = target.Parent
		end

		if not (target and target.Name:find("Win")) then
			return
		end

		if target then
			while LocalPlayer.GameplayPaused do
				task.wait(0.1)
			end

			local newCFrame = target.CFrame
			PlayerRequestStreamAroundAsync(newCFrame.Position, 5)
			Character:MoveTo(newCFrame.Position)
		end
	end
end

local Window = UI:CreateWindow({
	Name = "+1 Web Swing Escape",
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
	Text = "Level Up",
	Value = false,
	Flag = "click_enabled",
	Callback = function(value)
		Enableds.Click = value
		HandleRebirth()
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

Window:AddButton({
	Text = "Finish Race",
	MethodType = "DebounceClick",
	Callback = HandleFinishRace
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-19-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
