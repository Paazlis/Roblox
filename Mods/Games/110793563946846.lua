
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections, Packets = {["Buy"] = false, ["Upgrade"] = false, ["Phone"] = false}, {}, {}
local BuyButtonFolder = nil
local PhoneFrame = nil

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

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function GetPlot()
	local plots = workspace:QueryDescendants("#Game > #Plots")[1]
	if not plots then return nil end

	for _, plot in ipairs(plots:GetChildren()) do
		local occupiedByValue = plot:FindFirstChild("OccupiedBy")
		if not occupiedByValue then continue end

		if occupiedByValue:IsA("ObjectValue") and occupiedByValue.Value ~= nil and occupiedByValue.Value:IsA("Player") and occupiedByValue.Value == LocalPlayer or occupiedByValue.Value.UserId == LocalPlayer.UserId then
			return plot
		elseif not occupiedByValue:IsA("ObjectValue") then
			local value = tostring(occupiedByValue.Value)
			if value == LocalPlayer.Name or value == tostring(LocalPlayer.UserId) then
				return plot
			end
		end

	end

	return nil
end

-- Buy Function --
local function FireBuyButton(child)
	local hitbox = child:FindFirstChild("Touch")
	if not hitbox then return end

	local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChildWhichIsA("BasePart")
	if not rootPart  then return end

	FireTouch(rootPart, hitbox)
end

local function HandleBuy()
	if not Enableds.Buy then return end

	task.spawn(function()
		while Enableds.Buy do
			for _, stand in ipairs(BuyButtonFolder:GetChildren()) do
				if not Enableds.Buy then break end
				if not (stand and stand.Parent) then continue end

				for _, child in pairs(stand:GetChildren()) do
					if not (child and child.Parent) then continue end
					FireBuyButton(child)
				end
			end
			task.wait(1)
		end
	end)
end

local function FirePhone()
	if PhoneFrame.Visible and Enableds.Phone then
		local acceptButton = PhoneFrame:QueryDescendants("#Screen > #Choices > [LayoutOrder = 1] > #Message > #TextButton")[1]
		if acceptButton and acceptButton:IsA("TextButton") then
			FireButton(acceptButton)
		else
			if Packets.Phone then
				Packets.Phone:FireServer("Accept", 1)
			end
		end
	end
end

local function HandlePhone()
	if Connections.Phone then Connections.Phone:Disconnect() Connections.Phone = nil end
	if not Enableds.Phone then return end

	Packets.Phone = Packets.Phone or ReplicatedStorage:QueryDescendants("#Events > #Phone")[1]
	
	PhoneFrame = PhoneFrame or PlayerGui:QueryDescendants("#Game > #Main > #PhoneFrame")[1]
	
	Connections.Phone = PhoneFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		task.wait(1)
		FirePhone()
	end)
	
	task.spawn(function()
		while Enableds.Phone do
			FirePhone()
			task.wait(1)
		end
	end)
end

-- Upgrade Function --
local function FireIncomeButton(child)
	if child.Name ~= "IncomeSource" then return end

	local upgradeButton = child:QueryDescendants("#Container > #Upgrade > #Holder > #TextButton")[1]
	if not upgradeButton then return end

	FireButton(upgradeButton)
end

local function HandleUpgrade()
	if not Enableds.Upgrade then return end

	task.spawn(function()
		while Enableds.Upgrade do
			for _, child in ipairs(PlayerGui:GetChildren()) do
				if not Enableds.Upgrade then break end
				if not (child and child.Parent) then continue end
				FireIncomeButton(child)
			end
			task.wait(0.5)
		end
	end)
end

local Plot = GetPlot()

if Plot then
	BuyButtonFolder = Plot:FindFirstChild("Buttons")
end

local Window = UI:CreateWindow({
	Name = "Sell Ice Cream",
	Destroying = function()
		for key, value in pairs(Enableds) do
			Enableds[key] = false
		end

		for key, value in pairs(Connections) do
			if value then
				value:Disconnect()
			end
		end
	end
})

Window:AddToggle({
	Text = "Complete Tycoon",
	Value = false,
	Flag = "buy_enabled",
	Callback = function(value)
		Enableds.Buy = value
		HandleBuy()
	end
})

Window:AddToggle({
	Text = "Upgrade Income",
	Value = false,
	Flag = "upgrade_enabled",
	Callback = function(value)
		Enableds.Upgrade = value
		HandleUpgrade()
	end
})

Window:AddToggle({
	Text = "Phone Offer",
	Value = false,
	Flag = "phone_offer_enabled",
	Callback = function(value)
		Enableds.Phone = value
		HandlePhone()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255,255,255)
})

--[[
Window:AddLabel({
	Text = "Date: 08-05-2026",
	TextColor3 = Color3.fromRGB(255,255,255)
})

-- Game Info --
--[[
game:GetService("Players").LocalPlayer.PlayerGui.Game.Main.PhoneFrame.Screen.Choices:GetChildren()[3]. LayoutOrder == 1
game:GetService("Players").LocalPlayer.PlayerGui.Game.Main.PhoneFrame.Visible == true

-- Upgrade Income --
--game:GetService("Players").LocalPlayer.PlayerGui.IncomeSource.Container.Upgrade.Holder.TextButton

-- Click Stand --
--local Event = game:GetService("ReplicatedStorage").Events.IncomeSource
--Event:FireServer(
--	"Basic_Stand"
--)
--workspace.Game.Plots["4"].Buttons.Basic_Stand

-- Complete Tycoon --
--workspace.Game.Plots["4"].OccupiedBy.Value
--workspace.Game.Plots["4"].Buttons
--workspace.Game.Plots["4"].Buttons.Basic_Stand.Tips_Jar.Touch
--workspace.Game.Plots["4"].Buttons.Basic_Stand.Cone_Stand.Touch
]]
