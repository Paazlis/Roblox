local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Utility/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local DepositEnabled = false

-- Deposit Function --
local function AutoDeposit()
	if DepositEnabled then
		task.spawn(function()
			while DepositEnabled do
				task.wait(0.5)
				ReplicatedStorage.RemoveLastBottle:FireServer()
			end
		end)
	end
end

-- Main UI --
local Window = UI:CreateWindow({
	Name = "Deposit Simulator", 
	Destroying = function()
		DepositEnabled = false
	end
})

Window:AddToggle({
	Name = "Auto Deposit",
	Value = false,
	Callback = function(value)
		DepositEnabled = value
		AutoDeposit()
	end
})

Window:AddLabel("YouTube: Crokyreo")
