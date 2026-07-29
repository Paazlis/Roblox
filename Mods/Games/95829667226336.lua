local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections, Values = {["Fight"] = false, ["Train"] = false}, {}, {["Distance"] = 15}
local BossesFolder = workspace:FindFirstChild("Bosses") 
local TrainX2SpeedScroll = PlayerGui:QueryDescendants("#SpeedEffect > #LeftContainer > #Currency > #Speed")[1]

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

local function GetPlot()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return end
	
	for _, plot in pairs(plots:GetChildren()) do
		local ownerId = plot:GetAttribute("Owner")
		if ownerId ~= nil and tostring(ownerId) == tostring(LocalPlayer.UserId) then
			return plot
		end
	end
	
	--workspace.Plots["1"] -- Owner number 
	--workspace.Plots["1"]["1"].Containers["10"]["10"].Collection.CollectionPad
	
	return nil

end

local function GetNearestMobs(mobList)
	if #mobList <= 0 then return nil end

	local nearestMob = nil
	local shortestDistance = math.huge

	local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return nil end

	for _, mob in ipairs(mobList) do
		if mob and mob.Parent and mob:IsA("Model") then 
			local mobHumanoid = mob:FindFirstChildOfClass("Humanoid")
			local mobRootPart = mob.PrimaryPart or mob:FindFirstChild("HumanoidRootPart")

			if mobHumanoid and mobHumanoid.Health > 0 and mobRootPart then
				local mobDistance = (rootPart.Position - mobRootPart.Position).Magnitude

				if mobDistance < shortestDistance then
					nearestMob = mob
					shortestDistance = mobDistance
				end
			end
		end
	end

	return nearestMob
end

local function HandleFight()
	task.spawn(function()
		while Enableds.Fight do
			task.wait()
			if Character and Character.Parent then
				local tool = Character:FindFirstChildOfClass("Tool")
				if tool and tool.Parent then
					if firesignal then
						firesignal(tool.Activated)
					end
				end
			end
		end
	end)
	
	local TargetMob = nil
	Connections.MobsHeartbeat = RunService.Heartbeat:Connect(function()
		if Enableds.Fight then
			if Character and Character.Parent then
				if not (TargetMob and TargetMob.Parent) then
					TargetMob = GetNearestMobs(BossesFolder:GetChildren())
				end
				if not (TargetMob and TargetMob.Parent) then return end
				if not (Character and Character.Parent) then return end

				local rootPart : BasePart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
				if not rootPart then return end

				local mobRootPart = TargetMob.PrimaryPart or TargetMob:FindFirstChild("HumanoidRootPart")
				if not mobRootPart then return end

				local maxDistance = Values.Distance
				local targetPosition = mobRootPart.Position * Vector3.new(1, maxDistance > 1 and maxDistance or 1, 1)
				local lookAtPosition = mobRootPart.Position

				Character:PivotTo(CFrame.new(targetPosition, lookAtPosition) * CFrame.Angles(0, 0, 0))
			end
		end
	end)
end

local function HandleTrain()
	task.spawn(function()
		while Enableds.Train do
			task.wait()
			
			local trainX2ButtonChildren = TrainX2SpeedScroll:GetChildren()
			
			for _, trainX2SpeedButton in ipairs(trainX2ButtonChildren) do
				if not Enableds.Train then break end
				if trainX2SpeedButton and trainX2SpeedButton.Parent and trainX2SpeedButton.Name=="x2Speed" and trainX2SpeedButton:IsA("TextButton") or trainX2SpeedButton:IsA("ImageButton") and trainX2SpeedButton.Visible == true then
					FireButton(trainX2SpeedButton)
					task.wait()
				end
			end
			
			table.clear(trainX2ButtonChildren)
		end
	end)
end

local Plot = GetPlot()

---- Auto Train --
--game:GetService("Players").LocalPlayer.PlayerGui.SpeedEffect.LeftContainer.Currency.Speed.x2Speed
--game:GetService("Players").LocalPlayer.PlayerGui.SpeedEffect.LeftContainer.Currency.Speed.x2Speed.Visible == true

---- Collect Cash --
--workspace.Plots["1"] -- Owner number 
--workspace.Plots["1"]["1"].Containers["10"]["10"].Collection.CollectionPad

---- YouTube: Tora IsMe
---- YouTube: Crokyreo

local Window = UI:CreateWindow({
	Name = "Dumpling Stars",
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

Window:AddSlider({
	Text = "Distance",
	Range = {2, 15},
	Value = 5,
	Increment= 1,
	Flag = "distance",
	Callback = function(value)
		Values.Distance = value
	end
})

Window:AddToggle({
	Text = "Auto Fight",
	Value = false,
	Flag = "fight_enabled",
	Callback = function(value)
		Enableds.Fight = value
		if Connections.MobsHeartbeat then Connections.MobsHeartbeat:Disconnect() Connections.MobsHeartbeat = nil end
		if value then
			HandleFight()
		end
	end
})

Window:AddToggle({
	Text = "Auto Train",
	Value = false,
	Flag = "train_enabled",
	Callback = function(value)
		Enableds.Train = value
		if value then
			HandleTrain()
		end
	end
})

Window:AddLabel("YouTube: Tora IsMe")
Window:AddLabel("YouTube: Crokyreo")
