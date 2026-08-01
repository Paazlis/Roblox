local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local Enableds, Connections = {Click = false, ThrowClick = false, Farm = false, Rebirth = false}, {}
local Packets = {
	ClickEnergy = ReplicatedStorage:QueryDescendants("#Packages > #Network > #RemoteEventStorage > #ClickEnergy")[1],
	ThrowReward = ReplicatedStorage:QueryDescendants("#Packages > #Network > #RemoteEventStorage > #ThrowReward")[1],
	ClickThrow = ReplicatedStorage:QueryDescendants("#Packages > #Network > #RemoteEventStorage > #ThrowBoostClick")[1]
}
local RebirthScroll = PlayerGui:QueryDescendants("#Main > #Frames > #Rebirth > #Rebirths")[1]
local RebirthCache = {}

local function FireButton(button)
   if firesignal then
	  firesignal(button.Activated)
	  firesignal(button.MouseButton1Click)
   end
end

local function HandleClick()
	if not Enableds.Click then return end

	task.spawn(function()
		while Enableds.Click do
			Packets.ClickEnergy:FireServer()
			task.wait()
		end
	end)
end

local function HandleThrowClick()
	if not Enableds.ThrowClick then return end

	task.spawn(function()
		while Enableds.ThrowClick do
			Packets.ClickThrow:FireServer()
			task.wait()
		end
	end)
end

local function HandleFarm()
	if not Enableds.Farm then return end
	
	if Packets.ThrowReward then
		warn("Cash Farm Working")
	end
	
	task.spawn(function()
		while Enableds.Farm do
			--Packets.ThrowReward:FireServer(math.random(99999999, 99999999999))
			task.wait()
		end
	end)
end

local RebirthAddThread = nil

local function RebirthAdded(child)
	if not Enableds.Rebirth then return end
	
	if child:IsA("Frame") then
		if RebirthAddThread and coroutine.status(RebirthAddThread) ~= "dead" then
			task.cancel(RebirthAddThread)
			RebirthAddThread = nil
		end
		
		local childName = child.Name
		local confirmButton = child:FindFirstChild("Confirm")
		
		if not confirmButton then 
			return 
		end
		
		if childName == "MaxRebirthButton" or childName == "Padding" or childName == "RebirthUpgradeButton" then
           return
		end
		
		table.insert(RebirthCache, {
			Name = childName,
			Tier = child.LayoutOrder,
			ConfirmButton = confirmButton
		})

		local lastLength = #RebirthCache
		
		RebirthAddThread = task.delay(2, function()
			if #RebirthCache == lastLength then
				task.sort(RebirthCache, function(a, b)
                    return a.Tier < b.Tier
				end)
			end
		end)
	end
	--game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.Rebirth.Rebirths["2.5K Rebirth"]
--game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.Rebirth.Rebirths["2.5K Rebirth"].Confirm

--game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.Rebirth.Best
--game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.Rebirth.Best.TextLabel
end

local function HandleRebirth()
	if RebirthAddThread and coroutine.status(RebirthAddThread) ~= "dead" then
		task.cancel(RebirthAddThread)
		RebirthAddThread = nil
	end
    if Connections.RebirthAdded then Connections.RebirthAdded:Disconnect() Connections.RebirthAdded = nil end
	table.clear(RebirthCache)
	if not Enableds.Rebirth then return end
	Connections.RebirthAdded = RebirthScroll.ChildAdded:Connect(RebirthAdded)
	for _, child in ipairs(RebirthScroll:GetChildren()) do
       if not Enableds.Rebirth then return end
	   RebirthAdded(child)
	end

	task.spawn(function()
		while Enableds.Rebirth do
			for _, rebirthStats in ipairs(RebirthCache) do
			   task.wait()
			   if not Enableds.Rebirth then break end
			   local confirmButton = rebirthStats.ConfirmButton
			   if confirmButton then
				  FireButton(confirmButton)
			   end
			end
			task.wait(0.5)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "+1 Speed Per Click",
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
		
		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end

		if RebirthAddThread and coroutine.status(RebirthAddThread) ~= "dead" then
		   task.cancel(RebirthAddThread)
		   RebirthAddThread = nil
		end

		table.clear(RebirthCache)
	end
})

Window:AddToggle({
	Text = "Cash Farm",
	Value = false,
	Flag = "cash_enabled",
	Callback = function(value)
		Enableds.Farm = value
		HandleFarm()
	end
})

Window:AddToggle({
	Text = "Fast Click",
	Value = false,
	Flag = "click_enabled",
	Callback = function(value)
		Enableds.Click = value
		HandleClick()
	end
})

Window:AddToggle({
	Text = "Fast Throw Click",
	Value = false,
	Flag = "throw_click_enabled",
	Callback = function(value)
		Enableds.ThrowClick = value
		HandleThrowClick()
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

-- Game Info --
--[[
-- Fast Click --
local Event = game:GetService("ReplicatedStorage").Packages.Network.RemoteEventStorage.ClickEnergy
Event:FireServer()

-- Fast Cash --
local Event = game:GetService("ReplicatedStorage").Packages.Network.RemoteEventStorage.ThrowStarted
Event:FireServer(
	100990612.19127,
	6933723.119628
)

local Event = game:GetService("ReplicatedStorage").Packages.Network.RemoteEventStorage.RefreshPlayerMovement
Event:FireServer()

-- Instant
local Event = game:GetService("ReplicatedStorage").Packages.Network.RemoteEventStorage.ThrowReward
Event:FireServer(
	99999999
)

-- Fast Throw Click --
local Event = game:GetService("ReplicatedStorage").Packages.Network.RemoteEventStorage.ThrowBoostClick
Event:FireServer()

-- Auto Rebirth --
-- 0 0.839216 1 0.345098 0 0.0675 0.839216 1 0.345098 0 1 0.27451 1 0.305882 0 


-- no fill and button --
game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.Rebirth.Rebirths
game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.Rebirth.Rebirths["2.5K Rebirth"]
game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.Rebirth.Rebirths["2.5K Rebirth"].Confirm

game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.Rebirth.Best
game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.Rebirth.Best.TextLabel

-- DeniedName
-- MaxRebirthButton, Padding, RebirthUpgradeButton
]]
