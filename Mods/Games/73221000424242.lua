local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Packets = {}
local Enableds, Connections = {CompleteTycoon = false, Upgrade = false, Phone = false, Hack = false}, {}

local PhoneFrame, PhoneAcceptButton = nil, nil
local HackFrame, HackButton = nil, nil

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
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end
	plots = plots.Parent
	local userIdText = tostring(LocalPlayer.UserId)
	for _, plot in ipairs(plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId ~= nil and tostring(ownerId) == userIdText then
			return plot
		end
	end
	return nil
end

local Plot = GetPlot()
local ButtonsFolder = nil

if Plot then
	ButtonsFolder = Plot:FindFirstChild("Buttons")
end

local function HandleCompleteTycoon()
	if not Enableds.CompleteTycoon then return end
	Plot = Plot or GetPlot()
	if Plot then
		ButtonsFolder = ButtonsFolder or Plot:FindFirstChild("Buttons")
	end
	task.spawn(function()
		while Enableds.CompleteTycoon do
			for _, model in ipairs(ButtonsFolder:GetChildren()) do
				if not Enableds.CompleteTycoon then break end
				if model and model.Parent then -- [DIPERBAIKI]: Menambahkan titik pada model.Parent
					local hitbox = model:FindFirstChild("Button")
				    if hitbox and hitbox.Transparency == 0 then 
						local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
				        if rootPart then
					       FireTouch(rootPart, hitbox)
						end
				    end
				end
				task.wait(0.1)
			end
			task.wait(1)
		end
	end)
end

local function HandleUpgrade()
	if not Enableds.Upgrade then return end
	task.spawn(function()
		while Enableds.Upgrade do
			for _, billboardGui in ipairs(PlayerGui:GetChildren()) do
				if not Enableds.Upgrade then break end
				local upgradeButton = nil
				if billboardGui and billboardGui.Parent and billboardGui:IsA("BillboardGui") then
					for _, frame in ipairs(billboardGui:GetChildren()) do
						if not Enableds.Upgrade then break end
						if frame.Name ~= "StandFrame" then continue end
						for _, button in ipairs(frame:GetChildren()) do
							if not Enableds.Upgrade then break end
							-- [DIPERBAIKI]: Menambahkan tanda kurung untuk logika and/or
							if button.Name == "UpgradeButton" and (button:IsA("TextButton") or button:IsA("ImageButton")) then
								upgradeButton = button
								break
							end
							if upgradeButton then break end
						end
					end
				end
			    if not upgradeButton then continue end
				FireButton(upgradeButton)
				task.wait(0.1)
			end
			task.wait(1)
		end
	end)
end

local function HandlePhone()
	if not Enableds.Phone then return end
	PhoneFrame = PhoneFrame or PlayerGui:QueryDescendants("#MainUI > #Frames > #PhoneFrame")[1]
	task.spawn(function()
		while Enableds.Phone do
			if PhoneFrame.Visible == true then
				PhoneAcceptButton = (PhoneAcceptButton ~= nil and PhoneAcceptButton.Parent ~= nil) and PhoneAcceptButton or PhoneFrame:QueryDescendants("#Frame > #MainFrame > #OptionsFrame > GuiObject#Option[LayoutOrder = 1]")[1]
				if PhoneAcceptButton then
					FireButton(PhoneAcceptButton)
				end
			end
			task.wait(1)
		end
	end)
end

local function FireHack()
	if HackFrame.Visible == true and Enableds.Hack then
		if Packets.HackableTap then
			Packets.HackableTap:FireServer()
		else
			FireButton(HackButton)
		end
	end
end

local function HandleHack()
	if Connections.Hack then Connections.Hack:Disconnect() Connections.Hack = nil end
	if not Enableds.Hack then return end
	Packets.HackableTap = Packets.HackableTap or ReplicatedStorage:QueryDescendants("#RemoteEvents > #Game > #HackableTap")[1]
	HackFrame = HackFrame or PlayerGui:QueryDescendants("#MainUI > #Frames > #HackFrame")[1]
	if HackFrame then
		HackButton = HackButton or HackFrame:FindFirstChild("HackButton")
	end
	Connections.Hack = HackFrame:GetPropertyChangedSignal("Visible"):Connect(FireHack)
	task.spawn(function()
		while Enableds.Hack do
			FireHack()
			task.wait() -- Do not change
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Hack the World",
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
	Text = "Complete Tycoon",
	Value = false,
	Flag = "complete_tycoon_enabled",
	Callback = function(value)
		Enableds.CompleteTycoon = value
		HandleCompleteTycoon()
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
	Flag = "phone_enabled",
	Callback = function(value)
		Enableds.Phone = value
		HandlePhone()
	end
})

Window:AddToggle({
	Text = "Auto Hack",
	Value = false,
	Flag = "hack_enabled",
	Callback = function(value)
		Enableds.Hack = value
		HandleHack()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-11-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
