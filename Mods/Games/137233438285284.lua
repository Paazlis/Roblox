local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections = {Deposit = false, Upgrade = false, Merge = false, Cash = false, Egg = false}, {}

local EggFolder = nil

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

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

local Plot = GetPlot()

local function EggAdded(egg)
	if not (egg and egg.Parent) then return end
	
	local hitbox = egg:FindFirstChild("Part")
	if not hitbox then return end

	local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	FireTouch(rootPart, hitbox)
end

local function HandleEgg()
	if Connections.EggAdded then Connections.EggAdded:Disconnect() Connections.EggAdded = nil end
	if not Enableds.Egg then return end
	EggFolder = EggFolder or workspace:FindFirstChild("Eggs")
	
	Connections.EggAdded = EggFolder.ChildAdded:Connect(function(egg)
		task.wait(1)
		EggAdded(egg)
	end)
	
	task.spawn(function()
		while Enableds.Egg do
			for _, egg in ipairs(EggFolder:GetChildren()) do
				if not Enableds.Egg then break end
				EggAdded(egg)
			end
			task.wait(1)
		end
	end)
end

local function HandleCash()
	if not Enableds.Cash then return end

	Plot = (Plot ~= nil and Plot.Parent ~= nil) and Plot or GetPlot()

	task.spawn(function()
		while Enableds.Cash do
			task.wait(1)
			if Plot then
				local hitbox = Plot:QueryDescendants("#Buttons > #CollectMoney > #Button")[1]
				if hitbox then 
					local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
					if rootPart then 
						FireTouch(rootPart, hitbox)
					end
				end
			end
		end
	end)
end

local function HandleDeposit()
	if not Enableds.Deposit then return end
	
	Plot = (Plot ~= nil and Plot.Parent ~= nil) and Plot or GetPlot()
	
	task.spawn(function()
		while Enableds.Deposit do
			local hitbox = Plot:QueryDescendants("#Buttons > #DepositEggs > #Hitbox")[1]
			if hitbox then 
				local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
				if rootPart then 
					FireTouch(rootPart, hitbox)
				end
			end
			task.wait(1)
		end
	end)
end

local function HandleMerge()
	if not Enableds.Merge then return end

	Plot = (Plot ~= nil and Plot.Parent ~= nil) and Plot or GetPlot()

	task.spawn(function()
		while Enableds.Merge do
			local hitbox = Plot:QueryDescendants("#Buttons > #MergeChickens > #Button")[1]
			if hitbox then 
				local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
				if rootPart then 
					FireTouch(rootPart, hitbox)
				end
			end
			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Chicken Farm", 
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end

		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end
	end
})

Window:AddToggle({
	Text = "Collect Egg",
	Value = false,
	Flag = "egg_enabled",
	Callback = function(value)
		Enableds.Egg = value
		HandleEgg()
	end
})

Window:AddToggle({
	Text = "Auto Deposit",
	Value = false,
	Flag = "deposit_enabled",
	Callback = function(value)
		Enableds.Deposit = value
		HandleDeposit()
	end
})

Window:AddToggle({
	Text = "Collect Cash",
	Value = false,
	Callback = function(value)
		Enableds.Cash = value
		HandleCash()
	end
})

Window:AddToggle({
	Text = "Auto Merge",
	Value = false,
	Callback = function(value)
		Enableds.Merge = value
		HandleMerge()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 07-03-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
