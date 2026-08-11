local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local Enableds, Packets = {["Deposit"] = false}, {}

local function HandleDeposit()
	if not Enableds.Deposit then return end
	Packets.RemoveLastBottle = Packets.RemoveLastBottle or ReplicatedStorage:FindFirstChild("RemoveLastBottle")
	task.spawn(function()
		while Enableds.Deposit do
			Packets.RemoveLastBottle:FireServer()
			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Deposit Simulator", 
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
	end
})

Window:AddToggle({
	Text = "Auto Deposit",
	Value = false,
	Callback = function(value)
		Enableds.Deposit = value
		HandleDeposit()
	end
})

Window:AddLabel({
   Text = "YouTube: Crokyreo",
   TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
   Text = "Date: 07-04-2026",
   TextColor3 = Color3.fromRGB(255, 255, 255)
})
