local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Utility/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer=Players.LocalPlayer

local LocalPlayer = Players.LocalPlayer

local DepositEnabled = false
local DepositConnection = nil

-- Deposit Function --
local function FireDeposit(child)
   if not DepositEnabled then return end
   ReplicatedStorage.RemoveLastBottle:FireServer()
end

local function AutoDeposit()
  DepositConnection = Utility.Cleanup(DepositConnection)
	if DepositEnabled then
     local folder = LocalPlayer:FindFirstChild("Ekwipunek")
     if folder then
        DepositConnection = folder.ChildAdded:Connect(FireDeposit)
        for _, child in ipairs(folder:GetChildren()) do
           task.wait()
           FireDeposit(child)
        end
     else
        while DepositEnabled do
            task.wait(0.5)
            FireDeposit()
        end
    end
	end
end

-- Main UI --
local Window = UI:CreateWindow({
	Name = "Deposit Simulator", 
	Destroying = function()
		DepositEnabled = false
		DepositConnection = Utility.Cleanup(DepositConnection)
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
