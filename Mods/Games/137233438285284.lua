local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players

local LocalPlayer = Players.LocalPlayer
local DepositEnabled, UpgradeEnabled, MergeEnabled, CashEnabled = false, false, false, false
local EggConnection = nil

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

local function GetPlot()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end
	
	for _, base in ipairs(plots:GetChildren()) do
		if base.Name == LocalPlayer.Name then 
			return base
		end
	end
	
	return nil
end

-- Collect Egg Function --
local function EggAdded(egg)
	if egg.Parent then
		local targetPart = egg:FindFirstChild("Part")
		if targetPart and LocalPlayer.Character then
			FireTouch(LocalPlayer.Character.PrimaryPart, targetPart)
		end
	end
end

local Plot = GetPlot()

local Window = UI:CreateWindow({
	Name = "Chicken Farm", 
	Destroying = function()
		if EggConnection then EggConnection:Disconnect() EggConnection = nil end
		DepositEnabled, UpgradeEnabled, MergeEnabled, CashEnabled = false, false, false, false
	end
})

Window:AddToggle({
	Text = "Collect Egg",
	Value = false,
	Callback = function(value)
		if EggConnection then EggConnection:Disconnect() EggConnection = nil end
		if value then
			local eggs = workspace:FindFirstChild("Eggs")
			if not eggs then return end
			EggConnection = eggs.ChildAdded:Connect(function(egg)
				task.wait(1)
				EggAdded(egg)
			end)
			for _, egg in ipairs(eggs:GetChildren()) do
				EggAdded(egg)
			end
		end
	end
})

Window:AddToggle({
	Text = "Auto Deposit",
	Value = false,
	Callback = function(value)
		DepositEnabled = value
		if value then
			task.spawn(function()
				while DepositEnabled do
					task.wait(1)
					if Plot then
						local targetPart = Plot.Buttons.DepositEggs.Hitbox
						if targetPart and LocalPlayer.Character then
							FireTouch(LocalPlayer.Character.PrimaryPart, targetPart)
						end
					end
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Collect Cash",
	Value = false,
	Callback = function(value)
		CashEnabled = value
		if value then
			task.spawn(function()
				while CashEnabled do
					task.wait(1)
					if Plot then
						local targetPart = Plot.Buttons.CollectMoney.Button
						if targetPart and LocalPlayer.Character then
							FireTouch(LocalPlayer.Character.PrimaryPart, targetPart)
						end
					end
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Auto Merge",
	Value = false,
	Callback = function(value)
		MergeEnabled = value
		if value then
			task.spawn(function()
				while MergeEnabled do
					task.wait(1)
					if Plot then
						local targetPart = Plot.Buttons.MergeChickens.Button
						if targetPart and LocalPlayer.Character then
							FireTouch(LocalPlayer.Character.PrimaryPart, targetPart)
						end
					end
				end
			end)
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
