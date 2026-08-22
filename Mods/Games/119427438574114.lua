local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections, Packets = {["Stage"] = false, ["Rebirth"] = false}, {}, {}
local RebirthFill, RebirthButton = nil, nil

local TycoonFolder = nil
local StageFolder = nil
local StagePart = nil
local StageToggle = nil
local LastStagePart = {Size = Vector3.new(10, 1, 10), Position = Vector3.new(-7293.0126953125, 59.9652099609375, 1594.1334228515625)}
local SaveStagePart = nil

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

local function PlayerRequestStreamAroundAsync(position, timeOut)
	LocalPlayer:RequestStreamAroundAsync(position, timeOut)
end

local function TryChidNoCharacter(instance, name)  
    for _, child in ipairs(instance:GetChildren()) do
		if child and child.Parent and child.Name:find(name) and not child:FindFirstChildOfClass("Humanoid") then
		   return child
		end
	end
	return nil
end

local function HandleStage()
	if not Enableds.Stage then return end
	if StagePart == nil then
		Enableds.Stage = false
		StageToggle:Replace(false)
		return
	end
	task.spawn(function()
		local teleportStage = nil
		while Enableds.Stage do
			local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
			local humanoid = Character:FindFirstChildOfClass("Humanoid")
			if rootPart and humanoid and StagePart ~= nil then
				if teleportStage ~= StagePart then
				   teleportStage = StagePart
				   PlayerRequestStreamAroundAsync(teleportStage.Position, 5)
				end
				SuperPivoTo(Character, StagePart, rootPart, humanoid.HipHeight)
			end
			task.wait()
		end
	end)
end

local function HandleBuild()
	if not Enableds.Build then return end
	TycoonFolder = TycoonFolder or TryChidNoCharacter(workspace, "TycoonButtons")
	task.spawn(function()
		while Enableds.Build do
			for _, button in ipairs(TycoonFolder:GetChildren()) do
		       if not Enableds.Build then break end
		       if not (button and button.Parent) then continue end
		       local hitbox = button:FindFirstChild("TriggerPart")
		       if not hitbox then continue end
               local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
		       if not rootPart then continue end
			   FireTouch(rootPart, hitbox) 
			   task.wait(0.1)
		    end
			task.wait(1)
		end
	end)
end

local function FireRebirth()
	if IsFillFull(RebirthFill) and Enableds.Rebirth then
		--Packets.Rebirth:FireServer()
		FireButton(RebirthButton)
	end
end

local function HandleRebirth()
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end
	--Packets.Rebirth = Packets.Rebirth or ReplicatedStorage:QueryDescendants("#Remotes > #Rebirth")[1]
	RebirthFill = RebirthFill or PlayerGui:QueryDescendants("#HudGui > #Rebirth > #ProgressBar > #Bar")[1]
	RebirthButton = RebirthButton or PlayerGui:QueryDescendants("#HudGui > #Rebirth > #Rebirth")[1]
	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(FireRebirth)
	task.spawn(function()
		while Enableds.Rebirth do
			FireRebirth()
			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Save Your Cat",
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

local StageSelect = Window:AddSelect({
	Text = "Stage Target",
	Callback = function(target)
		StageFolder = StageFolder or TryChidNoCharacter(workspace, "StageButtons")
		if StageFolder ~= nil and target:IsDescendantOf(StageFolder) and target.Name == "TriggerPart" then
			StagePart = target
		end
	end
})

Window:AddToggle({
	Text = "Use Last Stage",
	Value = false,
	Callback = function(value)
		if value then
			if StageSelect.Active == true then StageSelect.Active = false end
			StageSelect.Visible = false
			SaveStagePart = StagePart
			StagePart = LastStagePart
		else
			if StageSelect.Active == false then StageSelect.Active = true end
			StageSelect.Visible = true
			StagePart = SaveStagePart
			SaveStagePart = nil
		end
	end
})

StageToggle = Window:AddToggle({
	Text = "Auto Stage",
	Value = false,
	Callback = function(value)
		Enableds.Stage = value
		HandleStage()
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Callback = function(value)
		Enableds.Rebirth = value
		HandleRebirth()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
