local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Packets = {}
local Enableds, Connections = {Bonk = false, Cash = false, Upgrade = false, Rebirth = false}, {}
local Plot = nil

Packets.PlayerRequest = ReplicatedStorage:QueryDescendants("#Remotes > #PlayerRequest")[1]

local RebirthFrame, RebirthButton, RebirthFill = PlayerGui:QueryDescendants("#MainGui > #RebirthFrame > #Holder > #MainFrame")[1], nil, nil

if RebirthFrame then
	RebirthButton = RebirthFrame:QueryDescendants("#Buttons > #RebirthButton")[1]
	RebirthFill = RebirthFrame:QueryDescendants("#ProgressBar > #FillBar")[1]
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function GetPlot()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end

	for _, child in pairs(plots:GetChildren()) do
		local ownerId = child:GetAttribute("OwnerUserId")
		if ownerId ~= nil and tostring(ownerId) == tostring(LocalPlayer.UserId) then
			return child
		end
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

local function Mouse1Click(x,y)
	VirtualInputManager:SendMouseButtonEvent(x,y,0,true,game,0)
	task.wait()
	VirtualInputManager:SendMouseButtonEvent(x,y,0,false,game,0)
end

local function FireButton(object)
	if firesignal then
		firesignal(object.MouseButton1Click)
		firesignal(object.Activated)
	end
end

local function IsFillFull(fill)
	if fill.Size.Scale.X >= 1 then
		return true
	end
	return false
end

-- Bonk Function --
local function HandleBonk()
	if not Enableds.Bonk then return end
  task.spawn(function()
    while Enableds.Bonk do
        ReplicatedStorage.Remotes.PlayerRequest:InvokeServer("Bonk", "Start")
        task.wait()
    end
  end)
end

-- Collect Cash Function --
local function HandleCash()
  if not Enableds.Cash then return end

		task.spawn(function()
			while Enableds.Cash do
				Plot = (Plot ~= nil and Plot.Parent ~= nil) and Plot or GetPlot()
				if Plot then
					local slots = Plot:FindFirstChild("Pads")
					if slots then
						for _, slot in ipairs(slots:GetChildren()) do
							if not Enableds.Cash then break end
              if not (slot and slot.Parent) then continue end
              local hitbox = slot:QueryDescendants("#CollectPad > BasePart#GuiPart")[1]
							if not hitbox then continue end
              local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
              if not rootPart then continue end
              FireTouch(rootPart, hitbox)
              task.wait(0.1)
						end
					end
				end
        task.wait(1)
			end
		end)
end

-- Upgrade Function --
local function HandleUpgrade()
  if not Enableds.Upgrade then return end

		task.spawn(function()
			while Enableds.Upgrade do
				Plot = (Plot ~= nil and Plot.Parent ~= nil) and Plot or GetPlot()
				if Plot then
					local slots = Plot:FindFirstChild("Pads")
					if slots then
						for _, slot in ipairs(slots:GetChildren()) do
							if not Enableds.Upgrade then break end
              if not (slot and slot.Parent) then continue end
              local hitbox = slot:QueryDescendants("#CollectPad > BasePart#GuiPart")[1]
							if not hitbox then continue end
              Packets.PlayerRequest:InvokeServer("Pad", "Upgrade", slot)
              task.wait(0.1)
						end
					end
				end
        task.wait(1)
			end
		end)
end

-- Rebirth Function --
local function HandleRebirth()
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end
	
	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
		if IsFillFull(RebirthFull) and Enableds.Rebirth then
			FireButton(RebirthButton)
		end
	end)
	
	task.spawn(function()
		while Enableds.Rebirth do
			if IsFillFull(RebirthFull) then
				FireButton(RebirthButton)
			end
			task.wait(0.5)
		end
	end)
end

Plot = GetPlot()

local Window = UI:CreateWindow({
	Name = "BONK for Brainrots",
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
	Text = "Auto BONK",
	Value = false,
  Flag = "bonk_enabled",
	Callback = function(value)
		value = false
		Enableds.Bonk = value
		HandleBonk()
	end
})

Window:AddToggle({
	Text = "Collect Cash",
	Value = false,
  Flag = "cash_enabled",
	Callback = function(value)
		value = false
		Enableds.Cash = value
		HandleCash()
	end
})

Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
  Flag = "upgrade_enabled",
	Callback = function(value)
		value = false
		Enableds.Upgrade = value
		HandleUpgrade()
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		value = false
		Enableds.Rebirth = value
		HandleRebirth()
	end
})

--[[
Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
]]
