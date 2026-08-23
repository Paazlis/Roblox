local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections, Packets, Modules = {["Cash"] = false, ["Upgrade"] = false, ["Rebirth"] = false}, {}, {}, {}
local UpgradeTypes, UpgradeActives, UpgradeInfos = {"Buy Slot", "Roll Luck", "Security", "Upgrade Conveyor"}, {["AllEnabled"] = true}, {}
local CodeTypes = {}
local RebirthButton, RebirthFill = nil, nil

local PlacedItemFolder = nil
local CodeDropdown = nil

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function GetPlot()
	local plots = workspace:QueryDescendants("#Map > #Plots")[1]
	if not plots then return nil end
	
	for _, plot in ipairs(plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId") or tonumber(plot.Name:match("%d+") or "")
		if ownerId ~= nil and ownerId == LocalPlayer.UserId then return plot end
	end
	
	return nil
end

local Plot = GetPlot()
if Plot then
	UpgradeInfos["Buy Slot"] = {
		UpgradeButton = Plot:QueryDescendants("#UpgradeBoard > #Part > #SurfaceGui > #BuySlot > #Essential > #Stats > #BuyButton")[1],
	}
	UpgradeInfos["Roll Luck"] = {
		UpgradeButton = Plot:QueryDescendants("#UpgradeBoard > #Part > #SurfaceGui > #LuckUpgrade > #Essential > #Stats > #BuyButton")[1],
	}
	UpgradeInfos["Security"] = {
		UpgradeButton = Plot:QueryDescendants("#Boards > #UpgradeSecurity > #Display > #SurfaceGui > #SecurityUpgrade > #Essential > #BuyButton")[1],
	}
	UpgradeInfos["Upgrade Conveyor"] = {
		Hitbox = Plot:QueryDescendants("#RollArea > #UpgradeConveyor > #Button")[1],
	}

	for mode, info in pairs(UpgradeInfos) do
		if info.UpgradeButton == nil and info.Hitbox == nil then
			table.remove(UpgradeTypes, table.find(UpgradeTypes, mode))
			continue
		end
		UpgradeActives[mode] = false
	end
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

local function IsFillFull(fill)
	if fill.Size.X.Scale >= 1 then
		return true
	end
	return false
end

-- Cash Function --
local function HandleCash(info)
	if not Enableds.Cash then return end
	PlacedItemFolder = PlacedItemFolder or Plot:FindFirstChild("PlacedItems")
	Packets.CustomerCollect = Packets.CustomerCollect or ReplicatedStorage:QueryDescendants("#Events > #RequestCustomerCashCollect")[1]
	task.spawn(function()
		while Enableds.Cash do
			for _, model in ipairs(PlacedItemFolder:GetChildren()) do
				if not Enableds.Cash then break end
				if model and model.Parent then
					local hitbox = model:FindFirstChild("CashCollectHitbox")
					if hitbox then
						local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
						if rootPart then
							FireTouch(rootPart, hitbox)
						end
					end
					if Packets.CustomerCollect then
						Packets.CustomerCollect:FireServer(model)
					end
					task.wait(0.1)
				end
			end
			task.wait(1)
		end
	end)
end

-- Upgrade Function --
local function FireUpgrade(info)
	if not Enableds.Upgrade then return end
	local hitbox = info.Hitbox
	if hitbox then
		local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			FireTouch(rootPart,hitbox)
		end
	end
	local button = info.UpgradeButton
	if button then 
		FireButton(button)
	end
end

local function HandleUpgrade()
	if not Enableds.Upgrade then return end
	task.spawn(function()
		while Enableds.Upgrade do
			for mode, active in pairs(UpgradeActives) do
				if not Enableds.Upgrade then break end
				if mode == "AllEnabled" then continue end
				if UpgradeActives.AllEnabled then active = true end
				if not active then continue end
				local info = UpgradeInfos[mode]
				if not info then continue end
				FireUpgrade(info)
				task.wait(0.05)
			end
			task.wait(0.5)
		end
	end)
end

-- Code Function --
local function HandleCode()
	Modules.CodeData = Modules.CodeData or require(ReplicatedStorage:QueryDescendants("#DataModules > #CodesConfig")[1]:Clone())
	Packets.RedeemCode = Packets.RedeemCode or ReplicatedStorage:QueryDescendants("#Events > #RequestRedeemCode")[1]
	table.clear(CodeTypes)
	for code, info in pairs(Modules.CodeData.Codes) do
		Packets.RedeemCode:InvokeServer(code)
		table.insert(CodeTypes, code)
	end
	CodeDropdown.Options = CodeTypes
	CodeDropdown:Refresh()
end

-- Rebirth Function --
local function FireRebirth()
	if IsFillFull(RebirthFill) and Enableds.Rebirth then
		FireButton(RebirthButton)
	end
end

local function HandleRebirth()
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end
	RebirthButton = RebirthButton or PlayerGui:QueryDescendants("#GameUI > #Frames > #Rebirth > #Container > #Buttons > #Rebirth")[1]
	RebirthFill = RebirthFill or PlayerGui:QueryDescendants("#GameUI > #Frames > #Rebirth > #Container > #Progress > #Fill")[1]
	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(FireRebirth)
	task.spawn(function()
		while Enableds.Rebirth do
			FireRebirth()
			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Make an Party",
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
	Text = "Collect Cash",
	Value = false,
	Callback = function(value)
		Enableds.Cash = value
		HandleCash()
	end
})

Window:AddDropdown({
	Text = "Upgrade Type (Empty = All)",
	Options = #UpgradeTypes > 0 and UpgradeTypes or {"No Upgrade Type"},
	Option = nil,
	MultipleOptions = true,
	Callback = function(option)
		for _, mode in ipairs(UpgradeTypes) do
			UpgradeActives[mode] = table.find(option, mode) ~= nil and true or false
		end
		UpgradeActives["AllEnabled"] = #option <= 0
	end
})

Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Callback = function(value)
		Enableds.Upgrade = value
		HandleUpgrade()
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Callback = function(value)
		Enableds.Rebirth = value
		HandleRebirth()
	end
})

CodeDropdown = Window:AddDropdown({
	Text = "Code List",
	Options = {"No Code"},
	Option = nil,
	MultipleOptions = true,
	Callback = function() end
})

Window:AddButton({
	Text = "Claim Code",
	Callback = HandleCode
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
