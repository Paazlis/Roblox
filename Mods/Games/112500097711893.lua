local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Packets = {}
local Enableds, Connections = {Cash = false, Train = false, Rebirth = false, Farm = false}, {}
local Plot = nil

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function GetPlot()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end

	for _, base in pairs(plots:GetChildren()) do
		local ownerId = base:GetAttribute("Owner")
		if tostring(ownerId) == tostring(LocalPlayer.UserId) then
			return base
		end
	end

	return nil
end

local function FireButton(button)
	if firesignal then
		firesignal(button.MouseButton1Click)
		firesignal(button.Activated)
	end
end

-- Train Function --
local function TrainAdded(child)
	if child.Name:lower() == "doublebutton" and Enableds.Train then
		FireButton(child)
	end
end

local function  HandleTrain()
	if Connections.Train then Connections.Train:Disconnect() Connections.Train = nil end
	if Enableds.Train then
		task.spawn(function()
			Packets.SendDoubleStrength = Packets.SendDoubleStrength or ReplicatedStorage.Remotes.doubleStrength
			while Enableds.Train do
				local gym = Backpack:FindFirstChild("Gym")
				if gym then
					local humanoid = Character:FindFirstChildOfClass("Humanoid")
					if humanoid and Enableds.Train then
						humanoid:EquipTool(gym)
					end
				end
				if Enableds.Train then
					Packets.SendDoubleStrength:FireServer()
				end
				task.wait(0.5)
			end
		end)

		local frame = PlayerGui:FindFirstChild("Main")
		if not frame then return end
		
		Connections.Train = frame.ChildAdded:Connect(TrainAdded)
		for _, child in pairs(frame:GetChildren()) do
			if not Enableds.Train then break end
			TrainAdded(child)
		end
	end
end

-- Farm Function --
local function HandleFarm()
	if Enableds.Farm then
		task.spawn(function()
			Packets.OnCast = Packets.OnCast or ReplicatedStorage.Remotes.OnCast
			Packets.StartRun = Packets.StartRun or ReplicatedStorage.Remotes.StartRun
			Packets.FinishRun = Packets.FinishRun or ReplicatedStorage.Remotes.FinishRun
			
			while Enableds.Farm do
				task.spawn(function()
					Packets.OnCast:InvokeServer(1)
					Packets.StartRun:InvokeServer()
					Packets.FinishRun:InvokeServer(true)
				end)
				
				task.wait(0.5)
			end
		end)
	end
end

-- Collect Cash Function --
local function HandleCash()
	if Enableds.Cash then
		task.spawn(function()
			Packets.ClaimCash = Packets.ClaimCash or ReplicatedStorage.Remotes.Claim
			
			while Enableds.Cash do
				Plot = (Plot ~= nil and Plot.Parent) and Plot or GetPlot()
				if Plot then
					local slots = Plot:FindFirstChild("Slots")
					if slots then
						for _, slot in pairs(slots:GetChildren()) do
							task.wait()
							if not Enableds.Cash then break end
							local slotTier = tonumber(slot.Name) or 1
							if not slotTier then continue end
							Packets.ClaimCash:InvokeServer(slotTier)
						end
					end
				end
				
				task.wait(0.5)
			end
		end)
	end
end

-- Rebirth Function --
local function HandleRebirth()
	if Enableds.Rebirth then
		Packets.RequestRebirth = Packets.RequestRebirth or ReplicatedStorage.Remotes.Rebirth
		task.spawn(function()
			while Enableds.Rebirth do
				Packets.RequestRebirth:InvokeServer()
				task.wait(5)
			end
		end)
	end
end

Plot = GetPlot()

local Window = UI:CreateWindow({
	Name = "Lick A Brainrots", 
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end
	end
})

Window:AddToggle({
	Text = "Auto Farm",
	Value = false,
	Callback = function(value)
		Enableds.Farm = value
		HandleFarm()
	end
})

Window:AddToggle({
	Text = "Auto Train",
	Value = false,
	Callback = function(value)
		Enableds.Train = value
		HandleTrain()
	end
})

Window:AddToggle({
	Text = "Collect Cash",
	Value = false,
	Callback = function(value)
		Enableds.Cash = value
		HandleCash()
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

Window:AddLabel({
	Text = "YouTube: vaehz",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
