local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager=Services.VirtualInputManager

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local ClaimTypes, ClaimObjects, ClaimActives = {"Speed", "Stamina"}, {}, {}
local Enableds, Connections = {["Win"] = false, ["Rebirth"] = false, ["Speed"] = false, ["Stamina"] = false}, {}
local SpeedPads, StaminaPads = {}, {}
local RebirthFrame, RebirthFill, RebirthButton = PlayerGui:QueryDescendants("#Main > #Frames > #Rebirth")[1], nil, nil
local TrailScroll = PlayerGui:QueryDescendants("#Main > #Frames > #Trails > #Main > #ScrollingFrame")[1]
local WinFolder = workspace:QueryDescendants("#WinPads > #NormalPads")[1]

if RebirthFrame then
	RebirthFill, RebirthButton = RebirthFrame:QueryDescendants("#RebirthProgressBar > #Main")[1], RebirthFrame:FindFirstChild("RebirthButton")
end

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

local function SendClick(x,y)
	VirtualInputManager:SendMouseButtonEvent(x,y,0,true,game,0)
	task.wait()
	VirtualInputManager:SendMouseButtonEvent(x,y,0,false,game,0)
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

---- buy trails --

--[[
	-- claim speed pads --
	workspace.SpeedMultiplierPads
	workspace.SpeedMultiplierPads.Tier1.Hitbox

	-- claim stamina pads --
	workspace.HeroPads.Tier1
	workspace.HeroPads.Tier1.Hitbox
	
]]

local function GetPads(instance)
	if not (instance and instance.Parent) then return {} end

	local list = {}

	for _, pad in ipairs(instance:GetChildren()) do
		local padName = pad.Name
		local padTier = tonumber(padName:match("%d+") or "")
		if not padTier then continue end

		local padHitbox = pad:QueryDescendants("BasePart#Hitbox")[1]
		if not padHitbox then continue end

		table.insert(list, {
			Name = padName,
			Tier = padTier,
			Hitbox = padHitbox
		})
	end

	table.sort(list, function(a, b)
		return a.Tier < b.Tier
	end)

	return list
end

local function HandleWin()
	local winPads = {}

	if WinFolder then
		for _, pad in ipairs(WinFolder:GetChildren()) do
			if not pad:IsA("Model") then continue end

			local padTier = tonumber(pad.Name:match("%d+") or "")
			if not padTier then continue end

			table.insert(winPads, {
				Tier = padTier,
				Model = pad
			})
		end
	end

	table.sort(winPads, function(a, b)
		return a.Tier > b.Tier
	end)

	task.spawn(function()
		while Enableds.Win do
			task.wait()

			local winPadModel = winPads[1]
			if winPadModel then
				Character:PivotTo(winPadModel:GetPivot())
			end
		end
	end)
end

local function HandleSpeed()
	local speedPads = GetPads(workspace:FindFirstChild("SpeedMultiplierPads"))

	task.spawn(function()
		while Enableds.Speed do
			for _, pad in ipairs(speedPads) do
				task.wait()
				local hitbox = pad.Hitbox
				local rootbox = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
				if hitbox and rootbox and Enableds.Speed then
					FireTouch(rootbox, hitbox)
				end 
			end
		end
		task.wait(5)
	end)
end

local function HandleStamina()
	local staminaPads = GetPads(workspace:FindFirstChild("HeroPads"))

	task.spawn(function()
		while Enableds.Stamina do
			for _, pad in ipairs(staminaPads) do
				task.wait()
				local hitbox = pad.Hitbox
				local rootbox = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
				if hitbox and rootbox and Enableds.Stamina then
					FireTouch(rootbox, hitbox)
				end
			end
		end
		task.wait(5)
	end)
end

local function HandleTrail()
	--game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.Trails.ScrollingFrame
	--game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.Trails.ScrollingFrame.FlamingTrail.Wins
end

local function FireRebirth()
	if Enableds.Rebirth and IsFillFull(RebirthFill) then
		FireButton(RebirthButton)
	end
end

local function HandleRebirth()
	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Position"):Connect(FireRebirth)

	task.spawn(function()
		while Enableds.Rebirth do
			FireRebirth()
			task.wait(1)
		end
	end)
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local Window = UI:CreateWindow({
	Name = "+1 Speed Super Hero Escape",
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
	Text = "Auto Win",
	Value = false,
	Flag = "wins_enabled",
	Callback = function(value)
		Enableds.Win = value
		if value then
			HandleWin()
		end
	end
})

Window:AddToggle({
	Text = "Claim Speed",
	Value = false,
	Flag = "speed_enabled",
	Callback = function(value)
		Enableds.Speed = value
		if value then
			HandleSpeed()
		end
	end
})

Window:AddToggle({
	Text = "Claim Stamina",
	Value = false,
	Flag = "stamina_enabled",
	Callback = function(value)
		Enableds.Stamina = value
		if value then
			HandleStamina()
		end
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		Enableds.Rebirth = value
		if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
		if value then
			HandleRebirth()
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
