local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections, Packets = {["Click"] = false, ["Upgrade"] = false, ["Rebirth"] = false}, {}, {}
local ClickIndex = 0

local UpgradeScroll = Players:QueryDescendants("#Main > #Upgrades > #Main > #ScrollingFrame")[1]
local UpgradeTypes, UpgradeActives, UpgradeInfos = {}, {}, {}

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
				if StageFolder then
					break
				end
			end
			
		end
		if StageFolder then
			break
		end
	end
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
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
		local num = tonumber(plot.Name:match("%d+") or "")
		if not num then continue end

		local humanoid = plot:FindFirstChildOfClass("Humanoid")
		if humanoid then continue end

		if fishShowPlotId ~= nil and num == fishShowPlotId then
			return plot
		end
	end

	return nil
end

local Plot = GetPlot()

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

local function HandleHit()
	if not Enableds.Hit then return end

	task.spawn(function()
		local level = 1
		
		while Enableds.Hit do
			local levelFolder = StageFolder:FindFirstChild("关卡"..tostring(level))
			if levelFolder then
				local checkPart = levelFolder:FindFirstChild("光门")
				local surfacePart = levelFolder:FindFirstChild("水面")
				local humanoid = Character:FindFirstChildOfClass("Humanoid")
				local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
				
				local offset = surfacePart.Size.Y / 2
				local secondOffset = (rootPart.Size.Y/2) + humanoid.HipHeight
				local location = Vector3.zero
				
				repeat
					offset = surfacePart.Size.Y / 2
					secondOffset = (rootPart.Size.Y/2) + humanoid.HipHeight
					location = Vector3.new(surfacePart.Position.X, surfacePart.Position.Y + offset + secondOffset, surfacePart.Position.Z)
					local worldDistance = (rootPart.Position - location).Magnitude
					if worldDistance <= 200 then
						Character:PivotTo(CFrame.new(location))
					else
						level = 1
						break
					end
					task.wait()
				until not Enableds.Hit or checkPart.CanCollide == false
				
				level += 1
			else
				level = 1
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

Window:AddToggle({
	Text = "Collect Cash",
	Value = false,
	Flag = "cash_enabled",
	Callback = function(value)
		Enableds.Cash = value
		if value then
			if Plot then
				warn("Plot ada")
			end
		end
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

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		Enableds.Rebirth = value
		HandleRebirth()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255),
})

Window:AddLabel({
	Text = "Date: 08-15-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255),
})

--[[
-- cash --
workspace["4"]["玩家区域"]["玩家区域"].Touch
-- plot is LocalPlayer FishShowPlotId attribute 

-- click
-- This code was generated by Cobalt
-- https://gitlab.com/upio/cobalt

local Event = game:GetService("ReplicatedStorage").Remote.Event.Level["[C-S]Click"]
Event:FireServer(
    59 -- index
)

-- hit
workspace.主场景.验证场景.关卡1.光门 and 水面
workspace["主场景"]["关卡4"]["水面"] -- target
workspace["主场景"]["关卡4"]["光门"] -- check CanCollide

-- upgrade --
game:GetService("Players").LocalPlayer.PlayerGui.Main.Upgrades.Main.ScrollingFrame
game:GetService("Players").LocalPlayer.PlayerGui.Main.Upgrades.Main.ScrollingFrame["1"]["1"].Sell.go
game:GetService("Players").LocalPlayer.PlayerGui.Main.Upgrades.Main.ScrollingFrame["1"]["1"].Flame.name

-- rebirth --
game:GetService("Players").LocalPlayer.PlayerGui.Main["Rebirth+1water"].UI1
game:GetService("Players").LocalPlayer.PlayerGui.Main["Rebirth+1water"].UI1["Progress bar"]["Internal progress bar"]
game:GetService("Players").LocalPlayer.PlayerGui.Main["Rebirth+1water"].UI1.RebirthButton.TextButton
]]
