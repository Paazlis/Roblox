local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local Enableds = {["Deposit"] = false}

local function AutoDeposit()
	if Enableds.Deposit then
		task.spawn(function()
			while Enableds.Deposit do
				ReplicatedStorage.RemoveLastBottle:FireServer()
				task.wait(0.5)
			end
		end)
	end
end

local Window = UI:CreateWindow({
	Name = "Deposit Simulator", 
	Destroying = function()
		Enableds.Deposit = false
	end
})

Window:AddToggle({
	Text = "Auto Deposit",
	Value = false,
	Callback = function(value)
		DepositEnabled = value
		AutoDeposit()
	end
})

Window:AddLabel("YouTube: Crokyreo")
