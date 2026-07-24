game:GetService("Players").LocalPlayer.PlayerGui.Main.Bottom.PowerRoll.Arc.UIGradient
game:GetService("Players").LocalPlayer.PlayerGui.Main.Bottom.PowerRoll

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character, Humanoid, RootPart = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait(), nil, nil

-- Auto Prestige Paths
local PrestigeFrame, PrestigeButton, PrestigeFill = PlayerGui:QueryDescendants("#Main > #Center > #Prestige")[1], nil, nil
local FillFullOffset = Vector2.new(0, 0)

if PrestigeFrame then
	PrestigeButton = PrestigeFrame:QueryDescendants("#Prestige")[1]
	PrestigeFill = PrestigeFrame:QueryDescendants("#LevelBar > #ProgressBar > #UIGradient")[1]
end

-- Auto Upgrade Paths
local UpgradeFrame, UpgradeScroll, UpgradeBackButton = PlayerGui:QueryDescendants("#Main > #Upgrades")[1], nil, nil

if UpgradeFrame then
	UpgradeScroll = UpgradeFrame:QueryDescendants("#Canvas > #Content")[1]
	UpgradeBackButton = UpgradeFrame:QueryDescendants("#Back")[1]
end

-- Auto Collect Paths
local Loots = workspace:FindFirstChild("Loot")

local Connections = {}
local Enableds = {["Prestige"] = false, ["Upgrade"] = false, ["Loot"] = false}

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function IsFillFull(fill)
	if fill.Offset == FillFullOffset or fill.Offset.X >= 0 then
		return true
	end
	return false
end

local function MoveTo(humanoid, targetPoint)
	local targetReached = false

	-- listen for the humanoid reaching its target
	local connection = nil
	connection = humanoid.MoveToFinished:Connect(function(reached)
		targetReached = true
		connection:Disconnect()
		connection = nil

	end)

	-- start walking
	humanoid:MoveTo(targetPoint)

	task.spawn(function()
		-- execute on a new thread so as to not yield function
		while not targetReached do
			-- does the humanoid still exist?
			if not (humanoid and humanoid.Parent) then
				break
			end
			-- has the target changed?
			if humanoid.WalkToPoint ~= targetPoint then
				break
			end
			-- refresh the timeout
			humanoid:MoveTo(targetPoint)
			task.wait(6)
		end

		-- disconnect the connection if it is still connected
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end)
	
	humanoid.MoveToFinished:Wait()
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

-- /// LOGIC FUNCTIONS /// --
local function HandlePrestige()
	-- Connect to the Offset changing instead of running a heavy while loop
	Connections.Prestige = PrestigeFill:GetPropertyChangedSignal("Offset"):Connect(function()
		if not Enableds.Prestige then return end

		-- Assuming a Vector2 Offset. Adjust to your specific fill axis (X or Y) if needed.
		if IsFillFull(PrestigeFill) then
			FireButton(PrestigeButton)
		end
	end)

	-- Assuming a Vector2 Offset. Adjust to your specific fill axis (X or Y) if needed.
	if IsFillFull(PrestigeFill) and Enableds.Prestige then
		FireButton(PrestigeButton)
	end

	if Enableds.Prestige then
		task.spawn(function()	
			while Enableds.Upgrade do
				if IsFillFull(PrestigeFill) then
					FireButton(PrestigeButton)
				end
				task.wait(1)
			end
		end)
	end
end

local function HandleUpgrade()
	task.spawn(function()
		while Enableds.Upgrade do
			-- Loop through all children in the UpgradeScroll
			for _, child in ipairs(UpgradeScroll:GetChildren()) do
				if not Enableds.Upgrade then break end

				if child:IsA("GuiObject") then
					local state = child:GetAttribute("UpgradeState")

					if state == "Affordable" then
						-- #1 If Affordable, fire the button
						FireButton(child)
						task.wait(0.1) -- Small delay to prevent input dropping
					elseif state == "OpenTab" then
						-- #2 If OpenTab, navigate into it
						FireButton(child)
						task.wait(0.2) -- Brief wait for the UI tab to transition/load

						-- Attempt to buy the newly revealed upgrades inside the tab
						for _, innerChild in ipairs(UpgradeScroll:GetChildren()) do
							if not Enableds.Upgrade then break end
							if innerChild:IsA("GuiObject") and innerChild:GetAttribute("UpgradeState") == "Affordable" then
								FireButton(innerChild)
								task.wait(0.1)
							end
						end

						if not Enableds.Upgrade then break end

						-- Exit back out to return to the main list
						FireButton(UpgradeBackButton)
						task.wait(0.2) -- Brief wait for UI to transition back
					end
				end
			end

			if not Enableds.Upgrade then break end

			-- Exit back out to return to the main list
			FireButton(UpgradeBackButton)
			task.wait(0.5) -- Loop delay to prevent crashing/rate limits
		end
	end)
end

local function HandleLoot()
	task.spawn(function()
		local SavePoint = Character.PrimaryPart.Position * Vector3.new(1, 0, 1)

		while Enableds.Loot do
			for _, lootModel in ipairs(Loots:GetChildren()) do
				if not Enableds.Loot then break end

				if lootModel ~= nil and lootModel.Parent ~= nil and lootModel:IsA("Model") then
					-- Find the BasePart (could be the PrimaryPart, or a part holding the BillboardGui)
					local lootPart = lootModel.PrimaryPart or lootModel:FindFirstChildWhichIsA("BasePart")

					-- Fallback to find part attached to BillboardGui as mentioned in comments
					if not lootPart then
						for _, desc in ipairs(lootModel:GetDescendants()) do
							if desc:IsA("BillboardGui") and desc.Parent:IsA("BasePart") then
								lootPart = desc.Parent
								break
							end
						end
					end

					if not lootPart then continue end

					Humanoid = (Humanoid ~= nil and Humanoid.Parent ~= nil) and Humanoid or Character:FindFirstChildOfClass("Humanoid")
					RootPart = (RootPart ~= nil and RootPart.Parent ~= nil) and RootPart or (Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart"))

					local targetPoint = lootPart.Position * Vector3.new(1, 0, 1)

					-- Teleport player if the part exists
					if lootPart and Enableds.Loot then
						MoveTo(Humanoid, targetPoint)

						-- Berjalan sampai nuke terambil
						--while RootPart.Parent ~= nil and (RootPart.Position - targetPosition).Magnitude > 4 and lootModel.Parent ~= nil and Enableds.Loot do
						--	Humanoid:MoveTo(targetPosition)
						--	task.wait(0.05)
						--end

						task.wait(0.1) -- Small delay to allow the server to register collection
						
						if not Enableds.Loot then break end
						MoveTo(Humanoid, SavePoint)
						task.wait(0.1)
					end

					--if Enableds.Loot then 
					--	MoveTo(Humanoid, SavePoint)

					--	-- Berjalan sampai nuke terambil
					--	--while RootPart.Parent ~= nil and (RootPart.Position - SavePosition).Magnitude > 4 and Enableds.Loot do
					--	--	Humanoid:MoveTo(SavePosition)
					--	--	task.wait(0.05)
					--	--end

					--	task.wait(0.1) -- Small delay to allow the server to register collection
					--end
				end
			end

			task.wait(0.2) -- Search for new loot every 0.2 seconds
		end
	end)
end


local Window = UI:CreateWindow({
	Name = "RNG Heroes",
	Destroying = function()
		-- cleanup
		for key, _ in pairs(Enableds) do
			Enableds[key] = false
		end
		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end
	end
})

-- /// TOGGLE CREATION /// --
Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Callback = function(value)
		Enableds.Upgrade = value
		if value then
			HandleUpgrade()
		end
	end
})

Window:AddToggle({
	Text = "Collect Loot",
	Value = false,
	Callback = function(value)
		Enableds.Loot = value
		if value then
			HandleLoot()
		end
	end
})

Window:AddToggle({
	Text = "Auto Prestige",
	Value = false,
	Callback = function(value) 
		Enableds.Prestige = value
		if Connections.Prestige then Connections.Prestige:Disconnect() Connections.Prestige = nil end
		if value then
			HandlePrestige()
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
