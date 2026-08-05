local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer : LocalScript = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local RebirthFrame, RebirthFill, RebirthButton = nil, nil, nil
local Packets = {}
local UpgradeTypes, UpgradeActives, UpgradeInfos = {}, {}, {}

local Enableds, Connections, Values = {}, {}, {}

Values.GameGui = PlayerGui:FindFirstChild("GameGui")

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

if UpgradeScroll then
	local sortUpgrades = {}

	for _, layer in ipairs(UpgradeScroll:GetChildren()) do
		if layer and layer.Parent and layer:IsA("GuiObject") then
			local buyButton = layer:FindFirstChild("Buy")
			if not buyButton then continue end

			local title = layer:QueryDescendants("#Improve > #Title")[1]
			if not title then continue end

			local key = title.Text

			if not UpgradeInfos[key] then
				UpgradeInfos[key] = {}
				UpgradeActives[key] = false
				table.insert(sortUpgrades, {
					Name = key,
					Tier = layer.LayoutOrder,
				})
			end

			table.insert(UpgradeInfos[key], {
				Name = key,
				UpgradeButton = buyButton
			})
		end
	end

	table.sort(sortUpgrades, function(a, b)
		return a.Tier < b.Tier
	end)

	for _, info in ipairs(sortUpgrades) do
		table.insert(UpgradeTypes, info.Name)
	end
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function FirePrompt(prompt)
	if fireproximityprompt then
		fireproximityprompt(prompt, 0)
	end
end

local function PlayerRequestStreamAroundAsync(position, timeOut)
	pcall(function()
		LocalPlayer:RequestStreamAroundAsync(position, timeOut)
	end)
end

local function Click2XGrassAdded(child)
	if not (child and child.Parent) then return end
	if not child.Name:lower():find("2x") then return end
	if not (child:IsA("ImageButton") or child:IsA("TextButton")) then return end
	FireButton(child)
end

local function HandleClickX2Grass()
	if Connections.Click2XTrainAdded then Connections.Click2XTrainAdded:Disconnect() Connections.Click2XTrainAdded = nil end
	if not Enableds.ClickX2Train then return end

	Connections.Click2XTrainAdded = Values.GameGui.ChildAdded:Connect(function(child)
		task.wait(1)
		Click2XGrassAdded(child)
	end)
	
	for _, child in ipairs(Values.GameGui:GetChildren()) do
		if not (Connections.Click2XTrainAdded and Connections.Click2XTrainAdded.Connected) then break end
		Click2XGrassAdded(child)
	end
end

local function HandleSell()
	if Values.SaveCharacterCFrame then Character:PivotTo(Values.SaveCharacterCFrame) Values.SaveCharacterCFrame = nil end
	if not Enableds.Sell then return end
	
	local sellPart = (Values.SellPart ~= nil and Values.SellPart.Parent ~= nil) and Values.SellPart or workspace:QueryDescendants("#ServerServiceZones > #Map_1 > #BackpackFullActionsSellTarget")[1]
	local backpackLabel = (Values.BakcpackLabel ~= nil and Values.BakcpackLabel.Parent ~= nil) and Values.BakcpackLabel or PlayerGui:QueryDescendants("#GameGui > #MainUI > #Left_GUI > #Value_GUI > #Bakcpack > #TextValue")[1]
	
	Values.SellPart = sellPart
	Values.BakcpackLabel = backpackLabel
	
	local saveCharacterCFrame = nil
	local saveSellCFrame = nil
	
	task.spawn(function()
		while Enableds.Sell do
			saveCharacterCFrame = Character:GetPivot()
			Values.SaveCharacterCFrame = saveCharacterCFrame
			saveSellCFrame = sellPart.CFrame
			task.wait(0.5)
			PlayerRequestStreamAroundAsync(saveSellCFrame.Position, 5)
			Character:PivotTo(saveSellCFrame)
			task.wait(0.1)
			local sellPrompt = nil
			repeat
				sellPrompt = workspace:QueryDescendants("#PlayerPets > #Baby_penguin856 > #SellZone1 > #Attachment  > #R22GrassSellPrompt")[1]
				task.wait()
			until not Enableds.Sell or sellPrompt ~= nil
			if sellPrompt ~= nil and sellPrompt:IsA("ProximityPrompt") then
				FirePrompt(sellPrompt)
				task.wait(1)
				PlayerRequestStreamAroundAsync(saveCharacterCFrame.Position, 5)
				Character:PivotTo(saveCharacterCFrame)
				Values.SaveCharacterCFrame = nil
			end
			task.wait(5)
		end
	end)
end

local function HandleClickBuff()
	if not Enableds.ClickBuff then return end
	
	local clickBuffFrame = Values.ClickBuffFrame or PlayerGui:QueryDescendants("#GameGui > #R22_TimedBuffPrompt")[1]
	local timedBuffActionPacket = Packets.TimedBuffAction or ReplicatedStorage:QueryDescendants("#R22 > #Remotes > #TimedBuffAction")[1]
	
	Packets.TimedBuffAction = timedBuffActionPacket
	Values.ClickBuffFrame = clickBuffFrame

	task.spawn(function()
		while Enableds.ClickBuff do
			if clickBuffFrame.Visible == true then
				timedBuffActionPacket:FireServer("Click")
			end
			task.wait()
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "+1 Kaiju Power Per Click",
	Destroying = function()
		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end

		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
	end
})

Window:AddToggle({
	Text = "Click 2X Grass",
	Value = false,
	Flag = "click_2x_grass_enabled",
	Callback = function(value)
		Enableds.Train = value
		HandleClickX2Grass()
	end
})

Window:AddToggle({
	Text = "Auto Sell",
	Value = false,
	Flag = "sell_enabled",
	Callback = function(value)
		Enableds.Sell = value
		HandleSell()
	end
})

Window:AddToggle({
	Text = "Click Buff",
	Value = false,
	Flag = "click_buff_enabled",
	Callback = function(value)
		Enableds.ClickBuff = value
		HandleClickBuff()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
