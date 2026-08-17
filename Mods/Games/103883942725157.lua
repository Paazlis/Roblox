local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections, Packets = {["Click"] = false, ["Upgrade"] = false, ["Cash"] = false, ["Hit"] = false, ["Sell"] = false, ["Rebirth"] = false}, {}, {}
local ClickIndex = 0

local UpgradeScroll = LocalPlayer:QueryDescendants("#Main > #Upgrades > #Main > #ScrollingFrame")[1]
local UpgradeTypes, UpgradeActives, UpgradeInfos = {}, {["AllEnabled"] = true}, {}
local CashHitbox = nil

local ProfileData ={}

local StageValue = LocalPlayer:QueryDescendants("#Stage > #stage")[1]
local CashToggle = nil

if StageValue and (StageValue:IsA("NumberValue") or StageValue:IsA("IntValue")) then
	ProfileData.Stage = StageValue.Value
	Connections.StageChanged = StageValue:GetPropertyChangedSignal("Value"):Connect(function()
		ProfileData.Stage = StageValue.Value
	end)
end

if UpgradeScroll then
	local sortUpgrades = {}

	for _, layer in ipairs(UpgradeScroll:GetChildren()) do
		if layer and layer.Parent and layer:IsA("GuiObject") then
			local frame = layer:FindFirstChild("1")
			if not frame then continue end

			local buyButton = frame:QueryDescendants("#Sell > #go")[1]
			if not buyButton then continue end

			local title = frame:QueryDescendants("#Flame > #name")[1]
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

local StageFolder = nil
local MainGui = PlayerGui:FindFirstChild("Main")
local RebirthFrame, RebirthFill, RebirthButton = nil, nil, nil

for _, v1 in ipairs(workspace:GetChildren()) do
	if not (v1 and v1.Parent) then continue end
	if v1.Name == "主场景" then
		for _, v2 in ipairs(v1:GetChildren()) do
			if not (v2 and v2.Parent) then continue end
			if v2.Name == "验证场景" then
				for _, v3 in ipairs(v2:GetChildren()) do
					if not (v3 and v3.Parent) then continue end
					if v3.Name:find("关卡") then
						StageFolder = v2
						break
					end
				end
				if StageFolder then break end
			end
		end
		if StageFolder then break end
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

local function GetPlot()
	local fishShowPlotId = LocalPlayer:GetAttribute("FishShowPlotId")
	for _, plot in ipairs(workspace:GetChildren()) do
		local plotId = tonumber(plot.Name:match("%d+") or "")
		if not plotId then continue end
		local humanoid = plot:FindFirstChildOfClass("Humanoid")
		if humanoid then continue end
		if fishShowPlotId ~= nil and plotId == fishShowPlotId then
			return plot
		end
	end
	return nil
end

local Plot = GetPlot()

local function HandleCash()
	if not Enableds.Cash then return end

	if not CashHitbox then
		local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local rayOrigin = rootPart.Position
			local rayDirection = Vector3.new(0, -100, 0)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = {Character}
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			local raycastInfo = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
			if raycastInfo then
				local target = raycastInfo.Instance
				while Enableds.Cash and target ~= workspace do
					if target.Name == "Touch" and target.Parent ~= nil and target.Parent.Name == "收集按钮" and CashHitbox:IsA("BasePart") and CashHitbox:IsDescendantOf(Plot) then
						break
					end
					target = target.Parent
					task.wait()
				end
				if target.Name == "Touch" and target.Parent ~= nil and target.Parent.Name == "收集按钮" and CashHitbox:IsA("BasePart") and CashHitbox:IsDescendantOf(Plot) then
					CashHitbox = target
				end
			end
		end
	end

	if not CashHitbox then
		local target = Plot
		for _, s in ipairs({"玩家区域", "收集按钮", "Touch"}) do
			if not Enableds.Cash then break end 
			local value = target:FindFirstChild(s)
			if value then
				target = value
			end
		end
		CashHitbox = target
	end

	if not Enableds.Cash then return end

	if not (CashHitbox ~= nil and CashHitbox.Parent ~= nil and CashHitbox.Name == "Touch" and CashHitbox.Parent.Name == "收集按钮" and CashHitbox:IsDescendantOf(Plot)) then
		CashHitbox = nil
		Enableds.Cash = false
		CashToggle:Replace(false)
		return
	end

	if not Enableds.Cash then return end

	task.spawn(function()
		while Enableds.Cash do
			local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
			if rootPart then
				FireTouch(rootPart, CashHitbox)
			end
			task.wait(1)
		end
	end)
end

local function HandleClick()
	if not Enableds.Click then return end
	Packets.Click = Packets.Click or ReplicatedStorage.Remote.Event.Level["[C-S]Click"]
	task.spawn(function()
		while Enableds.Click do
			Packets.Click:FireServer(ClickIndex)
			ClickIndex += 1
			task.wait(0.1)
		end
	end)
end

local function HandleUpgrade()
	if not Enableds.Upgrade then return end

	task.spawn(function()
		while Enableds.Upgrade do
			for key, active in pairs(UpgradeActives) do
				if not Enableds.Upgrade then break end
				if key == "AllEnabled" then continue end
				if UpgradeActives.AllEnabled then active = true end
				if not active then continue end

				local list = UpgradeInfos[key]
				if not list then continue end

				if #list > 1 then
					for _, info in ipairs(list) do
						if not Enableds.Upgrade then break end

						local button = info.UpgradeButton
						if not button then continue end

						FireButton(button)
						task.wait(0.05)
					end
				else
					local info = list[1]
					if not info then continue end

					local button = info.UpgradeButton
					if not button then continue end

					FireButton(button)
				end

				task.wait(0.05)
			end
			task.wait(0.5)
		end
	end)
end

local function HandleSell()
	if not Enableds.Sell then return end
	Packets.SellAll = Packets.SellAll or ReplicatedStorage.Remote.Function.Fish["[C-S]SellAllFish"]
	while Enableds.Sell do
		Packets.SellAll:InvokeServer()
		task.wait(1)
	end
end

local function HandleHit()
	if not Enableds.Hit then return end
	task.spawn(function()
		while Enableds.Hit do
			local level = ProfileData.Stage
			local levelFolder = StageFolder:FindFirstChild("关卡"..tostring(level))
			if levelFolder then
				local checkPart = levelFolder:FindFirstChild("光门")
				local surfacePart = levelFolder:FindFirstChild("水面")
				local humanoid = Character:FindFirstChildOfClass("Humanoid")
				local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
				local extraHeight = (surfacePart.Size.Y / 2) + (rootPart.Size.Y/2) + humanoid.HipHeight
				local newPosition, orientation = Vector3.zero, rootPart.Orientation
				while Enableds.Hit and checkPart.CanCollide do
					extraHeight = (surfacePart.Size.Y / 2) + (rootPart.Size.Y/2) + humanoid.HipHeight
					newPosition = Vector3.new(surfacePart.Position.X, surfacePart.Position.Y + extraHeight, surfacePart.Position.Z)
					Character:PivotTo(CFrame.new(newPosition) * CFrame.fromEulerAngles(math.rad(orientation.X), math.rad(orientation.Y), math.rad(orientation.Z), Enum.RotationOrder.YXZ))
					task.wait()
				end
			end
			task.wait(1)
		end
	end)
end

local function FireRebirth()
	if IsFillFull(RebirthFill) and Enableds.Rebirth then
		FireButton(RebirthButton)
	end
end

local function HandleRebirth()
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end
	RebirthFrame = RebirthFrame or (MainGui:FindFirstChild("Rebirth+1water") ~= nil and MainGui["Rebirth+1water"]:FindFirstChild("UI1") or nil)
	if RebirthFrame then
		RebirthFill = RebirthFill or (RebirthFrame:FindFirstChild("Progress bar") ~= nil and RebirthFrame["Progress bar"]:FindFirstChild("Internal progress bar") or nil)
		RebirthButton = RebirthButton or RebirthFrame:QueryDescendants("#RebirthButton > #TextButton")[1]
	end
	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(FireRebirth)
	task.spawn(function()
		while Enableds.Rebirth do
			FireRebirth()
			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "+1 Drain Water Per Click", 
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
	Text = "Fast Click",
	Value = false,
	Flag = "click_enabled",
	Callback = function(value)
		Enableds.Click = value
		HandleClick()
	end
})

Window:AddToggle({
	Text = "Auto Hit",
	Value = false,
	Flag = "hit_enabled",
	Callback = function(value)
		Enableds.Hit = value
		HandleHit()
	end
})

CashToggle = Window:AddToggle({
	Text = "Collect Cash",
	Value = false,
	Flag = "cash_enabled",
	Callback = function(value)
		Enableds.Cash = value
		HandleCash()
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

Window:AddToggle({
	Text = "Auto Sell",
	Value = false,
	Flag = "sell_enabled",
	Callback = function(value)
		Enableds.Sell = value
		HandleSell()
	end
})

Window:AddDropdown({
	Text = "Upgrade Type (Empty = All)",
	Options = #UpgradeTypes > 0 and UpgradeTypes or {"No Upgrade Type"},
	Option = nil,
	MultipleOptions = true,
	Flag = "upgrade_options",
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
	Flag = "upgrade_enabled",
	Callback = function(value)
		Enableds.Upgrade = value
		HandleUpgrade()
	end
})

--[[
workspace["2"]["玩家区域"]["收集按钮"].Cash.Attachment.BillboardGui.Frame.Text
workspace["2"]["玩家区域"]["收集按钮"].Touch
关卡1

workspace["主场景"]["验证场景"].WorldFish
workspace["主场景"]["验证场景"].WorldFish.Fish_1_7.FishRoot.PickupPrompt -- StageId and Price
]]

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255),
})

Window:AddLabel({
	Text = "YouTube: Tora IsMe",
	TextColor3 = Color3.fromRGB(255, 255, 255),
})

Window:AddLabel({
	Text = "Date: 08-15-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255),
})
