local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local CashEnabled = false
local CashIndex = 0

-- Auto Rebirth --
game:GetService("Players").LocalPlayer.PlayerGui["1"]["1"]["33"]["33"]["2"]["4"]["3"]["3"]["1"]

game:GetService("Players").LocalPlayer.PlayerGui["1"]["1"]["33"]["33"]["2"]["4"]["3"]["4"]["2"]["2"]

-- Auto Tap --
-- game:GetService("Players").LocalPlayer.PlayerGui["1"]["1"]:GetChildren()[8]["1"]

game:GetService("Players").LocalPlayer.PlayerGui["1"]["1"]:GetChildren()[8]["1"]["1"]["3"]

local Window = UI:CreateWindow({
	Name = "BE A FISH BAIT",
	Destroying = function()
		 CashEnabled = false
	end
})

Window:AddToggle({
	Text = "Collect Cash [X]", 
	Value = false, 
	Callback = function(value)
		CashEnabled = value
		if value then
			task.spawn(function()
				while CashEnabled do
				   task.wait(2)
			       ReplicatedStorage["shared/network@globalFunctions"].collectPlotMoney:FireServer(CashIndex,tostring(LocalPlayer.UserId))
                   CashIndex += 1
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Auto Rebirth", 
	Value = false, 
	Callback = function(value)
		RebirthEnabled = value
		
	end
})


Window:AddLabel("YouTube: Crokyreo")
