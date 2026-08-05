local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer : LocalScript = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local RebirthFrame, RebirthFill, RebirthButton = nil, nil, nil
local Packets = {}
local UpgradeTypes, UpgradeActives, UpgradeInfos = {}, {}, {}

local Enableds, Connections, Values = {}, {}, {}

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function FirePrompt(prompt)
	if fireproximityprompt then
		fireproximityprompt(prompt, 0)
	end
end

local function PlayerRequestStreamAroundAsync(position, timeOut)
	pcall(function()
		LocalPlayer:RequestStreamAroundAsync(position, timeOut)
	end)
end

local function Click2XGrassAdded(child)
	if not (child and child.Parent) then return end
	if not child.Name:lower():find("2x") then return end
	if not (child:IsA("ImageButton") or child:IsA("TextButton")) then return end
	FireButton(child)
end

local function HandleClickX2Grass()
	if not Enableds.ClickX2Train then return end

	task.spawn(function()
		while Enableds.ClickX2Train do
			Values.Click2XButton = PlayerGui:QueryDescendants("#GameGui > #R22_Grass2xPrompt")[1]
			if Values.Click2XButton then FireButton(Values.Click2XButton) end
			task.wait(0.5)
		end
	end)
end

local function HandleClickBuff()
	if not Enableds.ClickBuff then return end
	
	task.spawn(function()
		while Enableds.ClickBuff do
			Values.ClickBuffFrame = Values.ClickBuffFrame or PlayerGui:QueryDescendants("#GameGui > #R22_TimedBuffPrompt")[1]
			Packets.TimedBuffAction = Packets.TimedBuffAction or ReplicatedStorage:QueryDescendants("#R22 > #Remotes > #TimedBuffAction")[1]
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
	Text = "Click Buff",
	Value = false,
	Flag = "click_buff_enabled",
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
