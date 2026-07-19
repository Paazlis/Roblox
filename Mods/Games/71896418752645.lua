local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local SaveEnableds, Enableds, Connections, FarmToggles = {}, {["Collectable"] = false, ["Cash"] = false, ["Merge"] = false, ["Deposit"] = false, ["Buy"] = false, ["Upgrade"] = true}, {}, {}
local MergePart, DepositPart, CashPart, UpgradePart, BuyParts = nil, nil, nil, nil, table.create(4)
local SpawnClientGumballPacket = ReplicatedStorage:QueryDescendants("#GumballRemotes > #SpawnClientGumball")[1]
local CollectClientGumballPacket = ReplicatedStorage:QueryDescendants("#GumballRemotes > #CollectClientGumball")[1]

local Balls = {}

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

local function GetPlot()
	local plots = workspace:FindFirstChild("NewPlots")
	if not plots then return nil end
	
	for _, plot in ipairs(plots:GetChildren()) do
		if plot and plot.Parent then
			local ownerId = plot:GetAttribute("Owner")
			if ownerId ~= nil and tostring(ownerId) == tostring(LocalPlayer.UserId) then
				return plot
			end
			
			local ownerName = plot:GetAttribute("OwnerName")
			if ownerName ~= nil and tostring(ownerName) == tostring(LocalPlayer.Name) then
				return plot
			end
		end
	end
	
	return nil
end

if SpawnClientGumballPacket then
	Connections["SpawnClientGumballPacket"] = SpawnClientGumballPacket.OnClientEvent:Connect(function(id, colorName, position, level, otherName, ballName)
		table.insert(Balls, id)
		
		if Enableds["Collectable"] then
			if CollectClientGumballPacket then
				CollectClientGumballPacket:FireServer(id)
			end
			
			local index = table.find(Balls, id)
			if index then
				table.remove(Balls, index)
			end
		end
	end)
end

Connections["CharacterAdded"] = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local Plot = GetPlot()

local Window = UI:CreateWindow({
	Name = "Gumball Tycoon",
	Destroying = function()
		for key, value in pairs(Connections) do
			if value then
				value:Disconnect()
			end
		end
		
		for key, value in pairs(Enableds) do
			Enableds[key] = false
		end
	end
})

Window:AddToggle({
	Text = "Auto Farm",
	Value = false,
	Flag = "farm_enabled",
	Callback = function(value)
		Enableds["Farm"] = value
		if value then 
			for key, value in pairs(Enableds) do
				if not Enableds["Farm"] then return end
				SaveEnableds[key] = value
			end
			
			if not Enableds["Farm"] then return end
			
			for key, toggle in pairs(FarmToggles) do
				if not Enableds["Farm"] then return end
				
				if toggle then
					toggle.Visible = false
					toggle:Set(true)
				end
			end
		else
			for key, toggle in next, FarmToggles do
				if Enableds["Farm"] then return end
				
				if toggle then
					toggle.Visible = true
					toggle:Set(SaveEnableds[key])
				end
			end
		end
	end
})

FarmToggles["Collectable"] = Window:AddToggle({
	Text = "Collect Ball",
	Value = false,
	Flag = "collectable_enabled",
	Callback = function(value)
		Enableds["Collectable"] = value
		if value then 
			task.spawn(function()
				while Enableds["Collectable"] do
					task.wait(1)

					for _, id in ipairs(Balls) do
						task.wait()
						if id and Enableds["Collectable"] then 
							CollectClientGumballPacket:FireServer(id)
							local index = table.find(Balls, id)
							if index then
								table.remove(Balls, index)
							end
						end
					end
				end
			end)
		end
	end
})

FarmToggles["Deposit"] = Window:AddToggle({
	Text = "Auto Deposit",
	Value = false,
	Flag = "deposit_enabled",
	Callback = function(value)
		Enableds["Deposit"] = value
		if value then
			task.spawn(function()
				DepositPart = DepositPart or Plot:FindFirstChild("Process")
				while Enableds["Deposit"] do
					task.wait(1)
					local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChildWhichIsA("BasePart")
					if rootPart and Enableds["Deposit"] then
						FireTouch(rootPart, DepositPart)
					end
				end
			end)
		end
	end
})

FarmToggles["Cash"] = Window:AddToggle({
	Text = "Collect Cash",
	Value = false,
	Flag = "cash_enabled",
	Callback = function(value)
		Enableds["Cash"] = value
		if value then
			task.spawn(function()
				CashPart = CashPart or Plot:FindFirstChild("ProcessComplete")
				while Enableds["Cash"] do
					task.wait(1)
					local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChildWhichIsA("BasePart")
					if rootPart and Enableds["Cash"] then
						FireTouch(rootPart, CashPart)
					end
				end
			end)
		end
	end
})

FarmToggles["Merge"] = Window:AddToggle({
	Text = "Auto Merge",
	Value = false,
	Flag = "merge_enabled",
	Callback = function(value)
		Enableds["Merge"] = value
		if value then
			task.spawn(function()
				MergePart = MergePart or Plot:FindFirstChild("Merge")
				while Enableds["Merge"] do
					task.wait(1)
					local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChildWhichIsA("BasePart")
					if rootPart and Enableds["Merge"] then
						FireTouch(rootPart, MergePart)
					end
				end
			end)
		end
	end
})

FarmToggles["Buy"] = Window:AddToggle({
	Text = "Buy Gumball",
	Value = false,
	Flag = "buy_enabled",
	Callback = function(value)
		Enableds["Buy"] = value
		if value then 
			task.spawn(function()
				for index, buyName in ipairs({"Buy1", "Buy5", "Buy25", "Buy100"}) do
					BuyParts[index] = BuyParts[index] or Plot:FindFirstChild(buyName)
				end

				while Enableds["Buy"] do
					task.wait(1)
					for _, buyPart in ipairs(BuyParts) do
						task.wait()
						local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChildWhichIsA("BasePart")
						if rootPart and Enableds["Buy"] then
							FireTouch(rootPart, buyPart)
						end
					end
				end
			end)
		end
	end
})

FarmToggles["Upgrade"] = Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Flag = "upgrade_enabled",
	Callback = function(value)
		Enableds["Upgrade"] = value
		if value then
			task.spawn(function()
				UpgradePart = UpgradePart or  Plot:FindFirstChild("ProcessUpgrade")
				while Enableds["Upgrade"] do
					task.wait(1)
					local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChildWhichIsA("BasePart")
					if rootPart and Enableds["Upgrade"] then
						FireTouch(rootPart, UpgradePart)
					end
				end
			end)
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
