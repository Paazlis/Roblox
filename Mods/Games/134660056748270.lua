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

local function HandleRebirth()
	if not Enableds.Rebirth then return end

	task.spawn(function()
		while Enableds.Rebirth do
			task.wait()
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
]]
