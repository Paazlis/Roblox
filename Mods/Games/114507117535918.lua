local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections = {["Train"] = false, ["Cash"] = false,  ["Rebirth"] = false, ["Apple"] = false}, {}

local CashToggle = nil

local Packets = {
	["ZAP_RELIABLE"] = ReplicatedStorage:QueryDescendants("#ZAP > #ZAP_RELIABLE")[1]
}

local RebirthBufferString = buffer.fromstring(" ") 
local EquipTrainBufferString,  DoubleTrainBufferString = buffer.fromstring("\x1AT\nGB<yY@\x96\xCD\x16Btt\xD31\xAA\xC7E@\xE62m\xB1"), buffer.fromstring("\x1D") 
local Plot = nil

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function GetPlot()
	local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return nil end

	local rayOrigin = rootPart.Position
	local rayDirection = Vector3.new(0, -100, 0)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	if raycastResult then
		local hit = raycastResult.Instance
		if not hit then return nil end

		local success, current, last = false, hit, nil

		repeat
			last = current

			if current and current.Parent then
				current = current.Parent
			end
			
			if current then
				local baseTower = current:FindFirstChild("BaseTower")
				if baseTower then success = true end
			end
			
			task.wait()
		until success == true or last == workspace or current == workspace


		return current
	end

	return nil
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

local function IsFillFull(fill)
	if fill.Size.X.Scale >= 1 then
		return true
	end
	return false
end

local function TeleportTo(cframe)
	Character:PivotTo(cframe)
end

-- Train Function (Working) --
local function HandleTrain()
	if not Enableds.Train then
		Packets.ZAP_RELIABLE:FireServer(EquipTrainBufferString,{})
		return 
	end

	task.spawn(function()
		Packets.ZAP_RELIABLE:FireServer(EquipTrainBufferString,{})

		while Enableds.Train do
			Packets.ZAP_RELIABLE:FireServer(DoubleTrainBufferString,{})
			task.wait(0.5)
		end
	end)
end

-- Cash Function (Working) --
local function HandleCash()
	if not Enableds.Cash then return end

	Plot = (Plot ~= nil and Plot.Parent ~= nil) and Plot or GetPlot()
	if Plot == nil then
		if CashToggle then
			Enableds.Cash = false
			CashToggle:Replace(false)
		end
		return
	end

	local baseTowerFolder = Plot:FindFirstChild("BaseTower")
	if not baseTowerFolder then
		Plot = nil
		if CashToggle then
			Enableds.Cash = false
			CashToggle:Replace(false)
		end
		return
	end
	
	if Enableds.Cash then
		task.spawn(function()
			while Enableds.Cash do
				for _, slotPad in pairs(baseTowerFolder:GetChildren()) do
					if slotPad:IsA("BasePart") and slotPad.Name == "SlotPad" then
						task.wait()
						if not Enableds.Cash then break end
						local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
						if rootPart then 
							FireTouch(rootPart, slotPad)
						end
					end
				end

				task.wait(1)
			end
		end)
	end
end

-- Rebirth Function (Working) --
local function HandleRebirth()
	if not Enableds.Rebirth then return end


	task.spawn(function()
		while Enableds.Rebirth do
			Packets.ZAP_RELIABLE:FireServer(RebirthBufferString,{})
			task.wait(5)
		end
	end)
end

-- Apple Function (Working) --
local function HandleApple()
	if not Enableds.Apple then return end
	
	local saveCFrame = Character:GetPivot()

	for _, apple in ipairs(workspace:GetChildren()) do
		if apple ~= nil and apple.Parent ~= nil and apple:IsA("BasePart") and apple:FindFirstChildOfClass("TouchTransmitter") then
			if not Enableds.Apple then return end
			TeleportTo(apple.CFrame)
			task.wait(0.1)
			local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
			if rootPart then 
				FireTouch(rootPart, apple)
			end
			task.wait(0.5)
		end
	end
	
	if not Enableds.Apple then return end
	
	TeleportTo(saveCFrame)
	
	task.wait(2)
	
	saveCFrame = Character:GetPivot()
	
	if not Enableds.Apple then return end
	
	local huntSlotFolder = workspace:FindFirstChild("HuntSlots")
	if not huntSlotFolder then return end
	
	for _, huntSlot in ipairs(huntSlotFolder:GetChildren()) do
		local applesFolder = huntSlot:FindFirstChild("Apples")
		if not applesFolder then continue end

		for _, apple in ipairs(applesFolder:GetChildren()) do
			if apple ~= nil and apple.Parent ~= nil and apple:IsA("BasePart") and apple:FindFirstChildOfClass("TouchTransmitter") then
				if not Enableds.Apple then return end
				TeleportTo(apple.CFrame)
				task.wait(0.1)
				local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
				if rootPart then 
					FireTouch(rootPart, apple)
				end
				task.wait(0.5)
			end
		end
	end
end

local Window = UI:CreateWindow({
	Name = "Find the Egg for a Brainrot",
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
	Text = "Auto Train",
	Value = false,
	Flag = "train_enabled",
	Callback = function(value)
		Enableds.Train = value
		HandleTrain()
	end
})

CashToggle = Window:AddToggle({
	Text = "Collect Cash",
	Value = false,
	Flag = "cash_enabled",
	Callback = function(value)
		Enableds.Cash = value
		HandleCash()
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

local AppleToggle = nil
AppleToggle = Window:AddToggle({
	Text = "Collect Apple",
	Value = false,
	Flag = "apple_enabled",
	Callback = function(value)
		Enableds.Apple = value
		HandleApple()
		if Enableds.Apple then
			Enableds.Apple = false
			AppleToggle:Replace(false)
		end
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
