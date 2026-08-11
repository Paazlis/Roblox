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
local HackFrame, HackButton, MinigameFrame, MinigameButton = nil, nil, nil, nil

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

local function FireButton(button, i)
	if firesignal then
		if not i then 
		   firesignal(button.Activated)
	       firesignal(button.MouseButton1Click) 
		elseif i == 3 then 
			firesignal(button.InputBegan, {UserInputType = Enum.UserInputType.MouseButton1}) 
		end
	end
end

local function GetPlot()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end
	for _, plot in ipairs(plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId ~= nil and tostring(ownerId) == tostring(LocalPlayer.UserId) then
			return plot
		end
	end
	return nil
end

local Plot = GetPlot()
local ButtonsFolder = nil
local ButtonCache = {}

if Plot then
	ButtonsFolder = Plot:FindFirstChild("Buttons")
end

local function FireTycoonButton(hitbox)
    if Enableds.CompleteTycoon and hitbox and hitbox.Parent and hitbox.Transparency == 0 then
		local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
	    if rootPart then
		   FireTouch(rootPart, hitbox)
	    end
	end
end

local function ButtonAdded(model)
	if not (model and model.Parent) then return end
	if ButtonCache[model] ~= nil then return end
	local hitbox = model:FindFirstChild("Button") or model:WaitForChild("Button", 10)
	if not hitbox then return end
	local buttonConnections = {}
	local transparencyChanged = hitbox:GetPropertyChangedSignal("Transparency"):Connect(function()
		FireTycoonButton(hitbox)
	end)
	FireTycoonButton(hitbox)
	local ancestryChanged = nil
    ancestryChanged = model.AncestryChanged:Connect(function(_, parent)
		if not parent then
		   local newData = ButtonCache[model]
			if newData and newData.Connections then
				for key, connection in pairs(newData.Connections) do
			        if connection then
				        connection:Disconnect()
			        end
		        end
			end
		   ButtonCache[model] = nil
		   ancestryChanged:Disconnect()
		   transparencyChanged:Disconnect()
		end
	end)
	table.insert(buttonConnections, ancestryChanged)
	table.insert(buttonConnections, ancestryChanged)
    if model and model.Parent then
		ButtonCache[model] = {
			Connections = buttonConnections
		}
	end
end

local function HandleCompleteTycoon()
	if Connections.ButtonAdded then Connections.ButtonAdded:Disconnect() Connections.ButtonAdded = nil end
	if not Enableds.CompleteTycoon then return end
	Plot = Plot or GetPlot()
	if Plot then
		ButtonsFolder = ButtonsFolder or Plot:FindFirstChild("Buttons")
	end
	Connections.ButtonAdded = ButtonsFolder.ChildAdded:Connect(ButtonAdded)
	task.spawn(function()
		while Enableds.CompleteTycoon do
			for _, model in ipairs(ButtonsFolder:GetChildren()) do
				if not Enableds.CompleteTycoon then break end
				if model and model.Parent then -- [DIPERBAIKI]: Menambahkan titik pada model.Parent
					if ButtonCache[model] == nil then
                       ButtonAdded(model)
					end
				end
				task.wait(0.1)
			end
			task.wait(0.5) -- Do not change
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
				FireButton(upgradeButton, 3)
				task.wait(0.1)
			end
			task.wait() -- Do not change
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
		FireButton(HackButton)
	end
end

local function FireMinigame()
	if MinigameFrame.Visible == true and Enableds.Hack then
		FireButton(MinigameButton)
		FireButton(MinigameButton, 3)
	end
end

local function HandleHack()
	if Connections.Minigame then Connections.Minigame:Disconnect() Connections.Minigame = nil end
	if Connections.Hack then Connections.Hack:Disconnect() Connections.Hack = nil end
	if not Enableds.Hack then return end
	Packets.HackableTap = Packets.HackableTap or ReplicatedStorage:QueryDescendants("#RemoteEvents > #Game > #HackableTap")[1]
	HackFrame = HackFrame or PlayerGui:QueryDescendants("#MainUI > #Frames > #HackFrame")[1]
	if HackFrame then
		HackButton = HackButton or HackFrame:FindFirstChild("HackButton")
	end
	MinigameButton = MinigameButton or PlayerGui:QueryDescendants("#MainUI > #Minigames > #LayersGame > #HackButton")[1]
	if MinigameButton then
		MinigameFrame = MinigameFrame or MinigameButton.Parent
	end
    Connections.Hack = HackFrame:GetPropertyChangedSignal("Visible"):Connect(FireHack)
	if MinigameFrame then
		Connections.Minigame = MinigameFrame:GetPropertyChangedSignal("Visible"):Connect(FireMinigame)
	end
	task.spawn(function()
		while Enableds.Hack do
			FireHack()
			task.wait() -- Do not change
		end
	end)
	task.spawn(function()
		while Enableds.Hack do
			FireMinigame()
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
