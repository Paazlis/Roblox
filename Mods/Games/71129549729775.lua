local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Packets, Enableds, Connections, Values = {}, {}, {}, {}

local function IsAlive(instance)
	return (instance ~= nil and instance.Parent ~= nil) and true or false
end

local function FireButton(button)
	if firesignal and button and button.Parent and (button:IsA("ImageButton") or button:IsA("TextButton")) then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function HandleClickX2Grass()
	if not Enableds.ClickX2Train then return end

	task.spawn(function()
		while Enableds.ClickX2Train do
			FireButton(PlayerGui:QueryDescendants("#GameGui > #R22_Grass2xPrompt")[1])
			task.wait(0.5)
		end
	end)
end

local function HandleClickBuff()
	if not Enableds.ClickBuff then return end
	
	Values.ClickBuffFrame = IsAlive(Values.TimedBuffAction) and Values.TimedBuffAction or PlayerGui:QueryDescendants("#GameGui > #R22_TimedBuffPrompt")[1]
	Packets.TimedBuffAction = IsAlive(Packets.TimedBuffAction) and Packets.TimedBuffAction or ReplicatedStorage:QueryDescendants("#R22 > #Remotes > #TimedBuffAction")[1]
	
	task.spawn(function()
		while Enableds.ClickBuff do
			if Values.ClickBuffFrame.Visible == true then
				Packets.TimedBuffAction:FireServer("Click")
			end
			task.wait()
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Mow League",
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
	Text = "Click 2X Grass",
	Value = false,
	Flag = "train_enabled",
	Callback = function(value)
		Enableds.ClickX2Train = value
		HandleClickX2Grass()
	end
})

Window:AddToggle({
	Text = "Click Grass Boost",
	Value = false,
	Flag = "click_boost_enabled",
	Callback = function(value)
		Enableds.ClickBuff = value
		HandleClickBuff()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-04-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
