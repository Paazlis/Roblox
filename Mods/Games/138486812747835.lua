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
local ProfileData = {Money = 0}
local Packets = {
	ResourceDropOff = ReplicatedStorage:QueryDescendants("#Libs > #Remote > #__comm__ > #RE > #ResourceDropOff")[1]
}

local RebirthFrame, RebirthButton, RebirthHeader = PlayerGui:QueryDescendants("#UI > #Menus > #Rebirth")[1], nil, nil

--[[
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
]]

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

local function FirePurchaseButton(child)
	if not (child and child.Parent) then return end
	local tier = tonumber(child.Name:match("%d+") or "")
	if not tier then return end
	local buttonsFolder = child:FindFirstChild("Buttons")
	if not buttonsFolder then return end
	for _, model in ipairs(buttonsFolder:GetDescendants()) do
		if not Enableds.Purchase then break end
		if not (model and model.Parent) then continue end
		local hitbox = model:FindFirstChild("Touch")
		local config = model:FindFirstChild("Config")
		if not config then continue end
		if not hitbox then continue end
		local devProduct = config:FindFirstChild("DevProduct")
		if devProduct ~= nil then continue end
		local costValue = config:FindFirstChild("Costs")
		if costValue ~= nil and (costValue:IsA("NumberValue") or costValue:IsA("IntValue")) and ProfileData.Money < costValue.Value then
			continue
		end
		local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
		if not rootPart then continue end
		if not hitbox.Parent then continue end
		FireTouch(rootPart, hitbox)
		task.wait(0.1)
	end
end

-- Purchase Button Function --
local function HandlePurchaseButton()
	if not Enableds.Purchase then return end

	task.spawn(function()
		while Enableds.Purchase do
			for _, child in ipairs(AirpotTycoonFolder:GetChildren()) do
				if not Enableds.Purchase then break end
				FirePurchaseButton(child)
				task.wait()
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
	Text = "Purchase Button",
	Value = false,
	Flag = "button_enabled",
	Callback = function(value)
		Enableds.Purchase = value
		HandlePurchaseButton()
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

--[[
Window:AddToggle({
	Text = "Collect Trash",
	Value = false,
	Flag = "trash_enabled",
	Callback = function(value)
		warn("[Airport Tycoon] Collect Trash still coming soon")
	end
})
]]

 --[[
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
]]

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

--[[
workspace.AirportTycoonTrash
workspace.AirportTycoonTrash.Trash_3_4291.Sphere.CleanTrashPrompt
workspace.AirportTycoonTrash.Trash_3_4300.Sphere
]]
