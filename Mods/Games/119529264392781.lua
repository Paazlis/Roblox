local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager=Services.VirtualInputManager

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local Enableds, Connections = {["BuyBall"] = false, ["Rebirth"] = false, ["Case"] = false}, {}
local BuyBallButton = nil
local TextButtonDescendants = PlayerGui:QueryDescendants("#RingUI > Frame > TextButton")

for _, textButton in ipairs(TextButtonDescendants) do
   if textButton and string.find(textButton.Text, "Buy Ball") then
      BuyBallButton = textButton
      break
   end
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function HandleBuyBall()
	task.spawn(function()
		while Enableds.BuyBall do
			FireButton(BuyBallButton)
			task.wait(0.1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Idle Balls",
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
	Text = "Buy Ball",
	Value = false,
	Flag = "buy_ball_enabled",
	Callback = function(value)
		Enableds.BuyBall = value
		if value then 
			HandleBuyBall()
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
