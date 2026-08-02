--[[
game:GetService("Players").LocalPlayer.PlayerGui.UI.Menus.Upgrades.Pages.Options.ScrollingFrame.SecurityLane.ImageButton
game:GetService("Players").LocalPlayer.PlayerGui.UI.Menus.Upgrades.Pages.Options.ScrollingFrame.SecurityLane.GateName.Text
game:GetService("Players").LocalPlayer.PlayerGui.UI.Menus.Upgrades.Pages.Options.Back

game:GetService("Players").LocalPlayer.PlayerGui.UI.Menus.Upgrades.Pages.Upgrade.Back
game:GetService("Players").LocalPlayer.PlayerGui.UI.Menus.Upgrades.Pages.Upgrade.Upgrade
]]

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local MoneyValue = LocalPlayer:QueryDescendants("#leaderstats > #Money")[1]
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections = {Button = false, Rebirth = false}, {}
local ProfileData ={Money = 0}
local ButtonCache = {}
local Packets = {
	ResourceDropOff = ReplicatedStorage:QueryDescendants("#Libs > #Remote > #__comm__ > #RE > #ResourceDropOff")[1]
}

local RebirthFrame, RebirthButton, RebirthHeader = PlayerGui:QueryDescendants("#UI > #Menus > #Rebirth")[1], nil, nil

local UpgradeTypes = {}
local UpgradeScroll = PlayerGui:QueryDescendants("#UI > #Menus > #Upgrades > #Pages > #Types > #Container")[1]

if UpgradeScroll then
	for _, child in pairs(UpgradeScroll:GetChildren()) do
		if child:IsA("GuiObject") then
			local header = child:FindFirstChild("Header")
			if not header then continue end
			
			table.insert(UpgradeTypes, header.Text)
		end
	end
end

if RebirthButton then
	RebirthButton = RebirthFrame:FindFirstChild("Rebirth")
	
	if RebirthButton then
		RebirthHeader = RebirthButton:FindFirstChild("Header")
	end
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local AirpotTycoonFolder = workspace:FindFirstChild("AirportTycoonClientRuntime")

if MoneyValue then
	ProfileData.Money = MoneyValue.Value
	
	Connections.MoneyChanged = MoneyValue:GetPropertyChangedSignal("Value"):Connect(function()
		ProfileData.Money = MoneyValue.Value
	end)
end

local function ButtonAdded(child)
	task.wait(1)
	
	if not (child and child.Parent) then return end
	
	local tier = tonumber(child.Name:match("%d+") or "")
	if not tier then return end
	
	local attempt = 50
	local buttons = nil
	
	repeat
		if not (Connections.ButtonAdded and Connections.ButtonAdded.Connected) then return end
		if not (child and child.Parent) then return end
		buttons = child:FindFirstChild("Buttons")
		if not buttons then
			attempt -= 1
		end
		task.wait(0.5)
	until buttons ~= nil or attempt <= 0
	
	if not buttons then return end
	
	for _, buttonModel in pairs(buttons:GetDescendants()) do
		if not (Connections.ButtonAdded and Connections.ButtonAdded.Connected) then return end
		
		local hitbox = buttonModel:FindFirstChild("Touch")
		local config = buttonModel:FindFirstChild("Config")
		
		local newData = {}
		
		newData.Root = child
		newData.Hitbox = hitbox
		newData.Model = buttonModel
		
		if config ~= nil then
			local costValue = config:FindFirstChild("Costs")
			if costValue ~= nil and costValue:IsA("NumberValue") or costValue:IsA("IntValue") then 
				newData.Cost = costValue.Value
			end
		end
		
		table.insert(ButtonCache, newData)
	end
end

if AirpotTycoonFolder then
	Connections.ButtonAdded = AirpotTycoonFolder.ChildAdded:Connect(ButtonAdded)

	task.spawn(function()
		for _, descendant in pairs(AirpotTycoonFolder:GetChildren()) do
			if not (Connections.ButtonAdded and Connections.ButtonAdded.Connected) then
				break
			end
			ButtonAdded(descendant)
		end
	end)
end


local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

-- Collect Button Function --
local function HandleCollectButton()
	if not Enableds.Button then return end

	task.spawn(function()
		while Enableds.Button do
			for index = #ButtonCache, 1, -1 do
				if not Enableds.Button then break end
				
				local cache = ButtonCache[index]
				if not cache then continue end
				
				local model = cache.Model
				if not (model and model.Parent) then
					table.remove(ButtonCache, index)
					continue
				end
				
				local hitbox = cache.Hitbox
				local cost = cache.Cost
				
				if cost ~= nil and ProfileData.Money < cost then
					continue
				end
				
				if not hitbox then continue end
				
				local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
				if rootPart and Enableds.Button then
					FireTouch(rootPart, hitbox)
					task.wait()
				end
			end
			
			task.wait(0.5)
		end
	end)
end

-- Rebirth Function --
local function HandleRebirth()
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end
	
	Connections.Rebirth = RebirthHeader:GetPropertyChangedSignal("Text"):Connect(function()
		if RebirthHeader.Text == "NOT READY" and Enableds.Rebirth then
			FireButton(RebirthButton)
		end
	end)
	
	task.spawn(function()
		while Enableds.Rebirth do
			if RebirthHeader.Text == "NOT READY" then
				FireButton(RebirthButton)
			end
			task.wait(0.5)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Airport Tycoon",
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
	Text = "Collect Button",
	Value = false,
	Flag = "button_enabled",
	Callback = function(value)
		Enableds.Button = value
		HandleCollectButton()
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		Enableds.Rebirth = value
		HandleRebirth()
	end
})

Window:AddDropdown({
	Text = "Upgrade Type",
	Options = #UpgradeTypes > 0 and UpgradeTypes or {"No Upgrade Type"},
	Option = nil,
	MultipleOptions = true,
	Flag = "upgrade_options",
	Callback = function(option)
		
	end
})

Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Flag = "upgrade_enabled",
	Callback = function(value)
		warn("[Airport Tycoon] Auto Upgrade still coming soon")
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
