local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections, Packets = {["Stage"] = false, ["Build"] = false, ["Rebirth"] = false}, {}, {}
local RebirthFill = nil

local TycoonFolder = nil
local StageFolder = nil
local StagePart = nil
local StageToggle = nil

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

local function IsFillFull(fill)
	return fill.Size.X.Scale >= 1
end

local function SuperPivoTo(model, p1, p2, height)
	local orientation = p2.Orientation
	local extraHeight = (p1.Size.Y / 2) + (p2.Size.Y / 2) + height
	local newPosition = Vector3.new(p1.Position.X, p1.Position.Y + extraHeight, p1.Position.Z)
	local newRotation = CFrame.fromEulerAngles(math.rad(orientation.X), math.rad(orientation.Y), math.rad(orientation.Z), Enum.RotationOrder.YXZ)
	model:PivotTo(CFrame.new(newPosition) * newRotation)
end

local function HandleStage()
	if not Enableds.Stage then return end
	if StagePart == nil then
		Enableds.Stage = false
		StageToggle:Replace(false)
		return
	end
	task.spawn(function()
		while Enableds.Stage do
			task.wait()
			local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
			local humanoid = Character:FindFirstChildOfClass("Humanoid")
			if rootPart and humanoid and StagePart ~= nil then
				SuperPivoTo(Character, StagePart, rootPart, humanoid.HipHeight)
			end
		end
	end)
end

local function HandleBuild()
	if not Enableds.Build then return end
	if not TycoonFolder then
		for _, child in ipairs(workspace:GetChildren()) do
			if TycoonFolder ~= nil then break end
			if not (child and child.Parent) then continue end
			if child:FindFirstChildOfClass("Humanoid") then continue end
			if not child.Name:find("TycoonButtons") then continue end
			if TycoonFolder == nil then
				TycoonFolder = child
			end
			break
		end
	end
	for _, model in ipairs(TycoonFolder:GetChildren()) do
		if not Enableds.Build then break end
		if not (model and model.Parent) then continue end
		
		local triggerPart = model:FindFirstChild("TriggerPart")
		if not triggerPart then continue end
		
		print("Build ".. model.Name)
	end
	
	--task.spawn(function()
	--	while Enableds.Build do
			
	--		task.wait(1)
	--	end
	--end)
end

local function FireRebirth()
	if IsFillFull(RebirthFill) and Enableds.Rebirth then
		Packets.Rebirth:FireServer()
	end
end

local function HandleRebirth()
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end
	Packets.Rebirth = Packets.Rebirth or ReplicatedStorage:QueryDescendants("#Remotes > #Rebirth")
	RebirthFill = RebirthFill or PlayerGui:QueryDescendants("#HudGui > #Rebirth > #ProgressBar > #Bar")[1]
	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(FireRebirth)
	task.spawn(function()
		while Enableds.Rebirth do
			FireRebirth()
			task.wait(1)
		end
	end)
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

Window:AddSelect({
	Text = "Stage Target",
	Callback = function(target)
		if not StageFolder then
			for _, child in ipairs(workspace:GetChildren()) do
				if StageFolder ~= nil then break end
				if not (child and child.Parent) then continue end
				if child:FindFirstChildOfClass("Humanoid") then continue end
				if not child.Name:find("StageButtons") then continue end
				if StageFolder == nil then
					StageFolder = child
				end
				break
			end
		end

		if StageFolder ~= nil and target:IsDescendantOf(StageFolder) and target.Name == "TriggerPart" then
			StageFolder = target
			print("Stage target found in ".. target:GetFullName())
		end
	end
})

StageToggle = Window:AddToggle({
	Text = "Auto Stage",
	Value = false,
	Flag = "stage_enabled",
	Callback = function(value)
		Enableds.Stage = value
		HandleStage()
	end
})

Window:AddToggle({
	Text = "Auto Build",
	Value = false,
	Flag = "build_enabled",
	Callback = function(value)
		Enableds.Build = value
		HandleBuild()
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
	Text = "Date: 08-21-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
