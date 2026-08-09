local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections = {Rebirth = false}, {}

local ScrapFolder = workspace:FindFirstChild("PitScrap")

local RebirthHUD = PlayerGui:QueryDescendants("#SideRail > #Frame > #rebirth")[1]
local RebirthFrame, RebirthButton, RebirthCheck = nil, nil, nil

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

local function PlayerRequestStreamAroundAsync(position, timeOut)
	-- Minta Roblox memuat area lokasi teleport agar mengurangi durasi GameplayPaused
	pcall(function()
		LocalPlayer:RequestStreamAroundAsync(position, timeOut)
	end)
end

local function HandleScrap()
	if Enableds.ScrapDebounce then return end
	Enableds.ScrapDebounce = true
	
	local saveCFrame = Character:GetPivot()
	local teleporting = false
	local teleportIndex = 0
	
	for _, part in ipairs(ScrapFolder:GetChildren()) do
		if part and part.Parent and part:IsA("BasePart") then
			teleportIndex += 1
			teleporting = true
			task.spawn(function() PlayerRequestStreamAroundAsync(part.Position, 5) end)
			Character:PivotTo(part.CFrame)
			task.wait(0.1)
			task.spawn(function() PlayerRequestStreamAroundAsync(saveCFrame.Position, 5) end)
			Character:PivotTo(saveCFrame)
			task.wait(0.1)
		end
	end
	
	if teleporting then
		PlayerRequestStreamAroundAsync(saveCFrame.Position, 5)
		Character:PivotTo(saveCFrame)
		
		local duration = 5
		if teleportIndex >= 10 then
			duration = 20
		elseif teleportIndex >= 5 then
			duration = 10
		end
		
		task.wait(duration)
	else
		task.wait(1)
	end
	
	Enableds.ScrapDebounce = false
end

local function HandleRebirth()
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end
	
	if not RebirthFrame then
		FireButton(RebirthHUD)
		task.wait(1)
		
		local hiddenFrame = nil
		repeat
			hiddenFrame = PlayerGui:QueryDescendants("#Rebirth > #Frame > #window")[1]
			task.wait()
		until not Enableds.Rebirth or hiddenFrame ~= nil
		
		if hiddenFrame and Enableds.Rebirth then
			RebirthFrame = RebirthFrame or hiddenFrame:QueryDescendants("#panel > #face > #content > #content > #body")[1]
		end
	end
	
	if not RebirthFrame then return end
	if not Enableds.Rebirth then return end
	
	if RebirthFrame then
		RebirthButton = RebirthButton or RebirthFrame:FindFirstChild("confirm")
		RebirthCheck = RebirthCheck or RebirthFrame:QueryDescendants("#confirm > #face > #label")[1]
	end

	Connections.Rebirth = RebirthCheck:GetPropertyChangedSignal("Text"):Connect(function()
		if not RebirthCheck.Text:lower():find("not yet") and Enableds.Rebirth then
			FireButton(RebirthButton)
		end
	end)

	task.spawn(function()
		while Enableds.Rebirth do
			if not RebirthCheck.Text:lower():find("not yet") then
				FireButton(RebirthButton)
			end
			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Grow a Chicken Fighter", 
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

Window:AddButton({
	Text = "Collect Scrap",
	MethodType = "DoubleClick",
	Callback = HandleScrap
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		Enableds.Rebirth = value
		HandleRebirth()
	end,
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-09-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
