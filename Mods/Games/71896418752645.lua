local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()
local Instancer = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Instancer/init.luau"))()
local Executier = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Executier/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds = {["Collectable"] = false, ["Cash"] = false, ["Merge"] = false, ["Deposit"] = false, ["Buy"] = false, ["Upgrade"] = true}
local MergePart, DepositPart, CashPart, UpgradePart, BuyParts = nil, nil, nil, nil, table.create(4)
local SpawnClientGumballPacket = ReplicatedStorage:QueryDescendants("#GumballRemotes > #SpawnClientGumball")[1]
local CollectClientGumballPacket = ReplicatedStorage:QueryDescendants("#GumballRemotes > #CollectClientGumball")[1]

local Balls = {}

if SpawnClientGumballPacket then
	SpawnClientGumballPacket.OnClientEvent:Connect(function(id, colorName, position, level, otherName, ballName)
		table.insert(Balls, id)
	end)
end

local CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local Plot = Instancer.GetPlot("NewPlots",LocalPlayer)

local Window = UI:CreateWindow({
	Name = "Gumball Tycoon",
	Destroying = function()
		CharacterAddedConnection:Disconnect()

		for key, value in pairs(Enableds) do
			Enableds[key] = false
		end
	end
})

Window:AddToggle({
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
						if Enableds["Collectable"] then 
							CollectClientGumballPacket:FireServer(id)
							local newIndex = table.find(Balls, id)
							if newIndex then
								table.remove(Balls, newIndex)
							end
						end
					end
				end
			end)
		end
	end
})

Window:AddToggle({
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
						Executier.FireTouch(rootPart, DepositPart)
					end
				end
			end)
		end
	end
})

Window:AddToggle({
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
						Executier.FireTouch(rootPart, CashPart)
					end
				end
			end)
		end
	end
})

Window:AddToggle({
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
						Executier.FireTouch(rootPart, MergePart)
					end
				end
			end)
		end
	end
})

Window:AddToggle({
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
							Executier.FireTouch(rootPart, buyPart)
						end
					end
				end
			end)
		end
	end
})

Window:AddToggle({
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
						Executier.FireTouch(rootPart, UpgradePart)
					end
				end
			end)
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
