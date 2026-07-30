local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local SeedScroll = PlayerGui:QueryDescendants("#Frames > #IndexFrame > #SeedsFrame > #FrameItemsScrollingFrame > #AllItemsScrollingFrame")[1]
local SeedFolder = ReplicatedStorage:FindFirstChild("Seeds")

local Packets = {
	["AddPepper"] = nil,
	["PickupPepper"] = nil
}

local Enableds, Connections = {["Roll"] = false, ["Pickup"] = false, ["Add"] = false, ["Upgrade"] = false}, {}
local PickupConnections = {}
local SeedTypes, SeedActives = {}, {}
local UpgradeTypes, UpgradeActives, UpgradeInfos = {}, {}, {}
local Plot = nil

local function FireClick(clickDetector)
	if fireclickdetector then
		fireclickdetector(clickDetector)
	end
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function ApplySeedTypes()
	table.clear(SeedTypes)
	
	local sortSeeds = {}
	
	if SeedScroll then
		for _, seed in ipairs(SeedScroll:GetChildren()) do
			if seed:IsA("GuiObject") then
				local seedTitle = seed:QueryDescendants("#Btn > #txt")[1]
				if not seedTitle then continue end
				
				table.insert(sortSeeds, {
					Name = seedTitle.Text,
					Tier = seed.LayoutOrder
				})
			end
		end
		
		table.sort(sortSeeds, function(a, b)
			return a.Tier < b.Tier
		end)
	end
	
	--if #sortSeeds <= 0 and SeedFolder then
	--	for _, seed in ipairs(SeedFolder:GetChildren()) do
	--		table.insert(sortSeeds, {
	--			Name = seed.Name
	--		})
	--	end
	--end
	
	--if #sortSeeds <= 0 then
	--	for _, seedName in ipairs({"Deadly Seed","Painful Seed", "Spicy Seed", "Tame Seed"}) do
	--		table.insert(sortSeeds, {
	--			Name = seedName
	--		})
	--	end
	--end
	
	for _, seedStats in ipairs(sortSeeds) do
		table.insert(SeedTypes, seedStats.Name)
		SeedActives[seedStats.Name] = false
	end
end

local function ApplyUpgradeTypes()
	if Plot then
		table.clear(UpgradeTypes)
		local sortUpgrades = {}
		
		table.insert(sortUpgrades, {
			Name = "Higher Multiplier",
			Tier = 3,
			UpgradeButton = Plot:QueryDescendants("#Important > #Brewing > #SpicierSauceButton > #SurfaceGui > #TextButton")[1]
		})
		
		for _, upgradeModel in ipairs(workspace:GetChildren()) do
			local restockTimerFrame = upgradeModel:QueryDescendants("BasePart#Sign > #SurfaceGui > #Frame > #RestockTimer")[1]
			if not restockTimerFrame then continue end

			local upgradeTitle = restockTimerFrame:FindFirstChild("Title")
			local upgradeButton = restockTimerFrame:FindFirstChild("UpgradeButton")
			if not upgradeTitle or not upgradeButton then continue end
			
			local upgradeKey = upgradeTitle.Text
			local upgradeTier = 0
			
			if upgradeKey:find("Faster Time") then
				upgradeTier = 2
			elseif upgradeKey:find("Better Chance") then
				upgradeTier = 1
			elseif upgradeKey:find("Customer Buy Chance") then
				upgradeTier = 0
			end
			
			table.insert(sortUpgrades, {
				Name = upgradeKey,
				Tier = upgradeTier,
				UpgradeButton = upgradeButton
			})
		end
		
		table.sort(sortUpgrades, function(a, b)
			return a.Tier < b.Tier
		end)
		
		for _, upgradeStats in ipairs(sortUpgrades) do
			table.insert(UpgradeTypes, upgradeStats.Name)
			UpgradeInfos[upgradeStats.Name] = upgradeStats
			UpgradeActives[upgradeStats.Name] = false
		end
	end

	-- Higher Multiplier --
	--workspace.PlayerLots.KopiPahitGamer.Important.Brewing.SpicierSauceButton.SurfaceGui.TextButton

	---- Faster Time --
	--workspace.UpgradeSpawnerSign_Local.Sign.SurfaceGui.Frame.RestockTimer.Title
	--workspace.UpgradeSpawnerSign_Local.Sign.SurfaceGui.Frame.RestockTimer.UpgradeButton

	---- Better Chance --
	--workspace.UpgradeChancesSign_Local.Sign.SurfaceGui.Frame.RestockTimer.Title
	--workspace.UpgradeChancesSign_Local.Sign.SurfaceGui.Frame.RestockTimer.UpgradeButton

	---- Customer Buy Chance --
	--workspace.UpgradeCustomerChances_Local.Sign.SurfaceGui.Frame.RestockTimer.UpgradeButton
	--workspace.UpgradeCustomerChances_Local.Sign.SurfaceGui.Frame.RestockTimer.Title
end

local function GetPlot()
	local playerLots = workspace:FindFirstChild("PlayerLots")
	if playerLots ~= nil then 
		for _, base in pairs(playerLots:GetChildren()) do
			if base.Name:find(LocalPlayer.Name) then
				return base
			end
		end
	end

	print("Plot tidak bisa di dapatkan")
	return nil
end

-- Roll Function --
local function HandleRoll()
	if Enableds.Roll then
		task.spawn(function()
			while Enableds.Roll do
				task.wait(0.5)
				
				Plot = (Plot ~= nil and Plot.Parent ~= nil) and Plot or GetPlot()
				if not Plot then continue end
				
				local seedMachine = Plot.Important.SeedMachine
				
				local rollDetector = seedMachine.Button.ClickDetector

				local foundSeed = nil

				for _, seed in pairs(seedMachine:GetChildren()) do
					if seed:IsA("Model") and seed.Name:lower():find("seed") then
						local isSeed = SeedActives[seed.Name]

						if isSeed then
							foundSeed = seed
							break
						end
					end
				end

				if foundSeed then
					if rollDetector and Enableds.Roll then
						FireClick(rollDetector)
					end

					task.wait(1)

					repeat
						if foundSeed and foundSeed.Parent then
							local seedLayer = PlayerGui:QueryDescendants("#SeedLabelTemplate > #Content")[1]
							
							if seedLayer then
								local pickupButton = seedLayer:FindFirstChild("PickupButton")
								local nameLabel = seedLayer:FindFirstChild("NameLabel")

								if nameLabel and pickupButton and SeedActives[nameLabel.Text] and Enableds.Roll then
									FireButton(pickupButton)
									task.wait(0.5)
								end
							end
						end
						task.wait(1)
					until not Enableds.Roll or not (foundSeed and foundSeed.Parent)
				else
					if rollDetector and Enableds.Roll then
						FireClick(rollDetector)
					end
				end
			end
		end)
	end
end

-- Pickup Function --
local function PickupPepperAdded(pepper)
	if pepper.Name:lower():find("pepper") and Enableds.Pickup then
		Packets.PickupPepper:InvokeServer(pepper)
	end
end

local function PickupCropAdded(crop)
	if crop:IsA("Model") and crop.Name == "Crop" and Enableds.Pickup then
		local connection = crop.ChildAdded:Connect(PickupPepperAdded)
		table.insert(PickupConnections, connection)
		
		for _, pepper in ipairs(crop:GetChildren()) do
			PickupPepperAdded(pepper)
		end
	end
end

local function HandlePickup()
	while #PickupConnections > 0 do local connection = table.remove(PickupConnections, 1) if connection then connection:Disconnect() end end
	Packets.PickupPepper = (Packets.PickupPepper ~= nil and Packets.PickupPepper.Parent ~= nil) and Packets.PickupPepper or ReplicatedStorage.Events.Pepper.PickupPepper
	if Enableds.Pickup then
		Plot = (Plot ~= nil and Plot.Parent ~= nil) and Plot or GetPlot()
		if Plot then
			for _, crop in ipairs(Plot:GetChildren()) do
				PickupCropAdded(crop)
			end
			local connection = Plot.ChildAdded:Connect(PickupCropAdded)
			table.insert(PickupConnections, connection)
		end
	end
end

-- Add Function --
local function AddPepperAdded(tool)
	if tool.Name:lower():find("pepper") and Enableds.Add then
		Packets.AddPepper:InvokeServer(false, tool.Name)
	end
end

local function HandleAdd()
	if Connections.Add then Connections.Add:Disconnect() Connections.Add = nil end
	Packets.AddPepper = (Packets.AddPepper ~= nil and Packets.AddPepper.Parent ~= nil) and Packets.AddPepper or ReplicatedStorage.Events.Brewing.AddPepper

	if Enableds.Add then
		for _, tool in ipairs(Backpack:GetChildren()) do
			AddPepperAdded(tool)
		end
		
		Connections.Add = Backpack.ChildAdded:Connect(AddPepperAdded)
		
		task.spawn(function()
			while Enableds.Add do
				for _, tool in ipairs(Backpack:GetChildren()) do
					task.wait()
					AddPepperAdded(tool)
				end
				
				task.wait(0.5)
			end
		end)
	end
end

-- Upgrade Function --
local function HandleUpgrade()
	if Enableds.Upgrade then
		task.spawn(function()
			while Enableds.Upgrade do
				task.wait(0.5)
				for key, active in pairs(UpgradeActives) do
					if not Enableds.Upgrade then break end
					if not active then continue end
					
					local upgradeStats = UpgradeInfos[key]
					if not upgradeStats then continue end
					
					local upgradeButton = upgradeStats.UpgradeButton
					if upgradeButton then
						FireButton(upgradeButton)
					end
				end
			end
		end)
	end
end

local Plot = GetPlot()
ApplySeedTypes()
ApplyUpgradeTypes()

local Window = UI:CreateWindow({
	Name = "Make Hotsauce",
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
		
		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end
		
		for key, connection in pairs(PickupConnections) do
			if connection then
				connection:Disconnect()
			end
		end
	end
})

Window:AddDropdown({
	Text = "Seed Type",
	Options = #SeedTypes > 0 and SeedTypes or {"No Seed Type"},
	Option = SeedTypes[1],
	MultipleOptions = true,
	Callback = function(option)
		for _, mode in ipairs(SeedTypes) do
			SeedActives[mode] = table.find(option, mode) ~= nil and true or false
		end 
	end
})

Window:AddToggle({
	Text = "Auto Roll", 
	Value = false,
	Flag = "roll_enabled",
	Callback = function(value)
		Enableds.Roll = value
		HandleRoll()
	end
})

Window:AddToggle({
	Text = "Auto Pickup", 
	Value = false,
	Flag = "pickup_enabled",
	Callback = function(value)
		Enableds.Pickup = value
		HandlePickup()
	end
})

Window:AddToggle({
	Text = "Auto Add", 
	Value = false,
	Flag = "add_enabled",
	Callback = function(value)
		Enableds.Add = value
		HandleAdd()
	end
})

Window:AddDropdown({
	Text = "Upgrade Type",
	Options = #UpgradeTypes > 0 and UpgradeTypes or {"No Upgrade Type"},
	Option = UpgradeTypes[1],
	MultipleOptions = true,
	Callback = function(option)
		for _, mode in ipairs(UpgradeTypes) do
			UpgradeActives[mode] = table.find(option, mode) ~= nil and true or false
		end 
	end
})

Window:AddToggle({
	Text = "Auto Upgrade", 
	Value = false,
	Flag = "upgrade_enabled",
	Callback = function(value)
		Enableds.Upgrade = value
		HandleRoll()
	end
})

Window:AddLabel("YouTube: Crokyreo")
Window:AddLabel("Version: 7")
--[[

-- Auto Roll --
game:GetService("Players").LocalPlayer.PlayerGui.SeedLabelTemplate
game:GetService("Players").LocalPlayer.PlayerGui.SeedLabelTemplate.Content.PickupButton
game:GetService("Players").LocalPlayer.PlayerGui.SeedLabelTemplate.Content.NameLabel

-- Roll Click --
workspace.PlayerLots.KopiPahitGamer.Important.SeedMachine
workspace.PlayerLots.KopiPahitGamer.Important.SeedMachine.Button.ClickDetector

-- Seed info --
game:GetService("Players").LocalPlayer.PlayerGui.Frames.IndexFrame
game:GetService("Players").LocalPlayer.PlayerGui.Frames.IndexFrame.SeedsFrame.FrameItemsScrollingFrame.AllItemsScrollingFrame
game:GetService("Players").LocalPlayer.PlayerGui.Frames.IndexFrame.SeedsFrame.FrameItemsScrollingFrame.AllItemsScrollingFrame["Tame Seed"]
game:GetService("Players").LocalPlayer.PlayerGui.Frames.IndexFrame.SeedsFrame.FrameItemsScrollingFrame.AllItemsScrollingFrame["Tame Seed"].Btn.Txt


-- Upgrade Info --
]]
