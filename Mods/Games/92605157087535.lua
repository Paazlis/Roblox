local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Utility/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local DepositEnabled, BuyEnabled, MergeEnabled, CashEnabled, PickupEnabled = false, false, false, false, false

local Threads = {}
local PickupConnection = nil

local function GetPlot()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end

	for _, base in pairs(plots:GetChildren()) do
		local ownerId = base:GetAttribute("OwnerUserId")
		if ownerId ~= nil and tostring(ownerId) == tostring(LocalPlayer.UserId) then
			return base
		elseif base.Name:find(LocalPlayer.Name) then
			return base
		end
	end

	return nil
end

local Plot = GetPlot()

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

-- Pickup Function --
local function PickupAdded(child)
	if child.Parent and child.Name:lower():find("rollsphere") and child:IsA("BasePart") and child:GetAttribute("Tier") ~= nil and LocalPlayer.Character and PickupEnabled then
		FireTouch(LocalPlayer.Character.PrimaryPart, child)  
	end
end

local function AutoPickup()
	PickupConnection = Utility.Cleanup(PickupConnection)
	if PickupEnabled then
		PickupConnection = workspace.ChildAdded:Connect(function(child)
			PickupAdded(child)
		end)
		for _, child in ipairs(workspace:GetChildren()) do
			PickupAdded(child)
		end
	end
end

-- Deposit Function --
local function AutoDeposit()
	if DepositEnabled then
		Utility.Cleanup(Threads["Deposit"])

		Threads["Deposit"] = task.spawn(function()
			while DepositEnabled do
				task.wait(1)
				ReplicatedStorage.Remotes.DepositShells:FireServer()
			end
		end)
	end
end

-- Cash Function --
local function AutoCash()
	if CashEnabled then
		Utility.Cleanup(Threads["Cash"])

		Threads["Cash"] = task.spawn(function()
			while CashEnabled do
				task.wait(1)
				ReplicatedStorage.Remotes.CollectCash:FireServer()
			end
		end)
	end
end
	
-- Merge Function --
local function AutoMerge()
	if MergeEnabled then
		Utility.Cleanup(Threads["Merge"])
		
		Threads["Merge"] = task.spawn(function()
			while MergeEnabled do
				task.wait(1)
				ReplicatedStorage.Remotes.MergeCrab:FireServer()
			end
		end)
	end
end

-- Buy Function --
local function AutoBuy()
	if BuyEnabled then
		Utility.Cleanup(Threads["Buy"])

		Threads["Buy"] = task.spawn(function()
			while BuyEnabled do
				task.wait(1)
				if Plot then
					for _, model in ipairs(Plot:GetChildren()) do
						task.wait()
						if model.Name:lower():find("buy") then
							local no = tonumber(string.match(model.Name, "%d+"))
							if no and BuyEnabled then
								ReplicatedStorage.Remotes.BuyCrab:FireServer(no)
							end
						end
					end
				end
			end
		end)
	end
end

-- Main UI --
local Window = UI:CreateWindow({
	Name = "Crab Tycoon", 
	Destroying = function()
		PickupConnection = Utility.Cleanup(PickupConnection)
		DepositEnabled, BuyEnabled, MergeEnabled, CashEnabled, PickupEnabled = false, false, false, false, false
		local key, value = next(Threads)
		while value do
			Threads[key] = nil
			Utility.Cleanup(value)
			key, value = next(Threads)
		end
	end
})

Window:AddToggle({
	Name = "Auto Pickup",
	Value = false,
	Callback = function(value)
		PickupEnabled = value
		AutoPickup()
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

Window:AddToggle({
	Name = "Collect Cash",
	Value = false,
	Callback = function(value)
		CashEnabled = value
		AutoCash()
	end
})

Window:AddToggle({
	Name = "Auto Merge",
	Value = false,
	Callback = function(value)
		MergeEnabled = value
		AutoMerge()
	end
})

Window:AddToggle({
	Name = "Auto Buy",
	Value = false,
	Callback = function(value)
		BuyEnabled = value
		AutoBuy()
	end
})

Window:AddLabel("YouTube: Crokyreo")
