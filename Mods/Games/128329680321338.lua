local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local RebirthFrame, RebirthFill, RebirthButton = PlayerGui:QueryDescendants("#NewGui > #MainFrames > #RebirthFrame > #RebirthBackground")[1], nil, nil
local BoostScroll = PlayerGui:QueryDescendants("#NewGui > #MainFrames > #BoostsFrame > #BoostsBackground > #BoostsInnerFrame")[1]
local UpgradeScroll = PlayerGui:QueryDescendants("#NewGui > #MainFrames > #UpgradesFrame > #UpgradesBackground > #ScrollingFrame")[1]

local UpgradeTypes, UpgradeActives, UpgradeButtons = {}, {}, {}
local Enableds = {["Upgrade"] = false}
local Connections = {}

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

for _, mode in ipairs(UpgradeTypes) do
	UpgradeActives[mode] = false
end

if UpgradeScroll then
	for _, upgradeLayer in ipairs(UpgradeScroll:GetChildren()) do
		local upgradeTitle = upgradeLayer:FindFirstChild("Name")
		if not upgradeTitle or not upgradeTitle:IsA("TextLabel") then continue end

		local upgradeButton = upgradeLayer:FindFirstChild("CashButton")
		if not upgradeButton then continue end

		local upgradeKey = upgradeTitle.Text
		table.insert(UpgradeTypes, upgradeKey)
		UpgradeButtons[upgradeKey] = upgradeButton
	end
end

if BoostScroll then
	for _, upgradeLayer in ipairs(BoostScroll:GetChildren()) do
		local upgradeTitle = upgradeLayer:FindFirstChild("Name")
		if not upgradeTitle or not upgradeTitle:IsA("TextLabel") then continue end

		local upgradeButton = upgradeLayer:FindFirstChild("CashButton")
		if not upgradeButton then continue end

		local upgradeKey = upgradeTitle.Text
		table.insert(UpgradeTypes, upgradeKey)
		UpgradeButtons[upgradeKey] = upgradeButton
	end
end

local Window = UI:CreateWindow({
	Name = "+1 Fat Per Click",
	Destroying = function()
		for key, value in pairs(Enableds) do
			Enableds[key] = false
		end

		for key, value in pairs(Connections) do
			if value then
				value:Disconnect()
			end
		end
		
		for _, mode in ipairs(UpgradeTypes) do
			UpgradeActives[mode] = false
		end
	end
})

local LoadAutoClickerButton = nil
LoadAutoClickerButton = Window:AddButton({
	Text = "Load Auto Clicker",
	MethodType = "DoubleClick",
	Callback = function()
		local success, url = pcall(function()
			return game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Mods/Universal/AutoClick.lua")
		end)
		
		if success and url then
			local ok, func = pcall(function()
				return loadstring(url)
			end)
			
			if ok and func then
				func()
				LoadAutoClickerButton.Visible = false
			end
		end
	end
})

Window:AddDropdown({
	Text = "Upgrade Type",
	Options = UpgradeTypes,
	Option = nil,
	MultipleOptions = true,
	Flag = "upgrade_options",
	Callback = function(option)
		for _, mode in ipairs(UpgradeTypes) do
			UpgradeActives[mode] = table.find(option, mode) ~= nil and true or false
		end
	end
})

Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Flag = "upgrade_enabled",
	Callback = function(value)
		Enableds.Upgrade = value
		if value then
			task.spawn(function()	
				while Enableds.Upgrade do
					task.wait(0.5)
					for mode, active in pairs(UpgradeActives) do
						if not Enableds.Upgrade then break end

						
						if active then
							local upgradeButton = UpgradeButtons[mode]
							if upgradeButton then
								FireButton(upgradeButton)
							end
						end
					end
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
		if value then
			RebirthFill = RebirthFill or RebirthFrame:QueryDescendants("#Bar > #BarCanvas > #Progress")[1] 
			RebirthButton = RebirthButton or RebirthFrame:FindFirstChild("RebirthButton")

			Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
				if IsFillFull(RebirthFill) then
					FireButton(RebirthButton)
				end
			end)
			
			if IsFillFull(RebirthFill) then
				FireButton(RebirthButton)
			end
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
