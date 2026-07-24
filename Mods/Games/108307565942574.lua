local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	
-- Auto Prestige Paths
local PrestigeButton = PlayerGui:QueryDescendants("#Main > #Center > #Prestige > #Prestige")[1]
local PrestigeFill = PlayerGui:QueryDescendants("#Main > #Center > #Prestige > #LevelBar > #ProgressBar > #UIGradient")[1]
local FillFullOffset = Vector2.new(0, 0)

-- Auto Upgrade Paths
local UpgradeScroll = PlayerGui:QueryDescendants("#Main > #Upgrades > #Canvas > #Content")[1]
local UpgradeBackButton = PlayerGui:QueryDescendants("#Main > #Upgrades > #Back")[1]

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

--[[
Create a script in Roblox Studio based on the script I provided.

-- UI Library --
local UI = --my own module
local Connections, Enableds = {}, {["Prestige"] = false, ["Upgrade"] = false, ["Loot"] = false}

local Window = UI:CreateWindow({
    Name = "RNG Heroes",
    Destroying= function()
       -- cleanup
    end
})

Window:CreateToggle({
    Text = "",
    Value = false,
    Callback= function()
       -- Logic for Auto Prestige, Auto Upgrade and Auto Collect
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

local function FireButton(button)
   -- my own logic
end

-- Auto Prestige --
local PrestigeButton = game:GetService("Players").LocalPlayer.PlayerGui.Main.Center.Prestige.Prestige
local PrestigeFill = game:GetService("Players").LocalPlayer.PlayerGui.Main.Center.Prestige.LevelBar.ProgressBar.UIGradient
-- Logic: 
-- When PrestigeFill Offset is 0 FireButton(PrestigeButton)


-- Auto Upgrade --
local UpgradeScroll = game:GetService("Players").LocalPlayer.PlayerGui.Main.Upgrades.Canvas.Content
local UpgradeButton = UpgradeScroll["Tile_3 Enemies"]
local UpgradeBackButton = game:GetService("Players").LocalPlayer.PlayerGui.Main.Upgrades.Back

-- UpgradeLayer Attributes: UpgradeState = Owned, Affordable, Locked, OpenTab, Unaffordable
-- Logic: 
-- #1 If the "Affordable" attribute is present, use FireButton(UpgradeButton).
-- #2 If the "OpenTab" attribute is present, it indicates navigation to another upgrade; return to #1. To exit, use FireButton(UpgradeBackButton).


-- auto collect --
local Loots = workspace.Loot
-- ClassName = Model
-- Loots:GetChildren()[11].BillboardGui
-- BasePart to find
-- Logic: 
-- When the toggle is pressed, the player character will teleport to that lootPart; if it does not exist, the player character no move.

]]

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

			task.wait(0.5) -- Loop delay to prevent crashing/rate limits
		end
	end)
end

local function HandleLoot()
	task.spawn(function()
		while Enableds.Loot do
			for _, lootModel in ipairs(Loots:GetChildren()) do
				if not Enableds.Loot then break end
				if lootModel:IsA("Model") then
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

					-- Teleport player if the part exists
					if lootPart and Enableds.Loot then
						Character:PivotTo(lootPart.CFrame + Vector3.new(0, 3, 0))
						task.wait(0.1) -- Small delay to allow the server to register collection
					end
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

Window:AddToggle("YouTube: Crokyreo")
