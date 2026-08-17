local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections, Packets = {["Click"] = false, ["Upgrade"] = false, ["Cash"] = false, ["Hit"] = false, ["Sell"] = false, ["Rebirth"] = false}, {}, {}
local UpgradeTypes, UpgradeActives, UpgradeInfos = {}, {["AllEnabled"] = true}, {}
local RebirthFrame, RebirthFill, RebirthButton = nil, nil, nil

local TollCache = {}

local UpgradeScroll = PlayerGui:QueryDescendants("#UpgradeBoardGUI > #ScrollingFrame")[1]
if UpgradeScroll then
	for _, layer in ipairs(UpgradeScroll:GetChildren()) do
		if layer and layer.Parent and layer:IsA("GuiObject") then
			local buyButton = layer:FindFirstChild("UpgradeButton")
			if not buyButton then continue end

			local title = layer:FindFirstChild("DisplayName")
			if not title then continue end

			local key = title.Text

			if not UpgradeInfos[key] then
				UpgradeInfos[key] = {}
				UpgradeActives[key] = false
				table.insert(UpgradeTypes, key)
			end

			table.insert(UpgradeInfos[key], {
				Name = key,
				UpgradeButton = buyButton
			})
		end
	end
end

do
	UpgradeInfos["Toll"] = {}
	UpgradeActives["Toll"] = false
	table.insert(UpgradeTypes, "Toll")
	
	local function GuiAdded(gui)
		if gui and gui.Parent and gui.Name:find("TollUpgradeGUI_Line_") then
			local buyButton = gui:FindFirstChild("UpgradeButton")
			if not buyButton then return end

			local order = gui.Name:match("%d+") or ""

			table.insert(UpgradeInfos["Toll"], {
				Name = "Toll",
				UpgradeButton = buyButton,
				AlertGui = PlayerGui:FindFirstChild("TollAlertUpgradeGUI_Line_"..tostring(order))
			})
		end
	end
	
	Connections.GuiAdded = PlayerGui.ChildAdded:Connect(function(gui)
		task.wait(2)
		GuiAdded(gui)
	end)

	for _, gui in ipairs(PlayerGui:GetChildren()) do
		GuiAdded(gui)
	end
end

local RollScroll = PlayerGui:QueryDescendants("#Main > #Frames > #RollUpgradesFrame")[1]
if RollScroll then
	for _, layer in ipairs(RollScroll:GetChildren()) do
		if layer and layer.Parent and layer:IsA("GuiObject") then
			local buyButton = layer:FindFirstChild("UpgradeButton")
			if not buyButton then continue end

			local title = layer:FindFirstChild("Title")
			if not title then continue end
			
			local key = title.Text
			
			if not UpgradeInfos[key] then
				UpgradeInfos[key] = {}
				UpgradeActives[key] = false
				table.insert(UpgradeTypes, key)
			end

			table.insert(UpgradeInfos[key], {
				Name = key,
				UpgradeButton = buyButton
			})
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

local function FireRebirth()
	if IsFillFull(RebirthFill) and Enableds.Rebirth then
		FireButton(RebirthButton)
	end
end

local function HandleRebirth()
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	if not Enableds.Rebirth then return end
	RebirthFrame = RebirthFrame or PlayerGui:QueryDescendants("#Main > #Frames > #RebirthFrame")[1]
	if RebirthFrame then
		RebirthFill = RebirthFill or RebirthFrame:QueryDescendants("#CanvasGroup > #Bar")[1]
		RebirthButton = RebirthButton or RebirthFrame:FindFirstChild("RebirthButton")
	end
	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(FireRebirth)
	task.spawn(function()
		while Enableds.Rebirth do
			FireRebirth()
			task.wait(1)
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
						
						if key == "Toll" then
							local alertGui = info.AlertGui
							if alertGui and (alertGui:IsA("SurfaceGui") or alertGui:IsA("BillboardGui")) and alertGui.Enabled == false then
								continue
							end
						end
						
						FireButton(button)
						task.wait(0.05)
					end
				else
					local info = list[1]
					if not info then continue end

					local button = info.UpgradeButton
					if not button then continue end
					
					if key == "Toll" then
						local alertGui = info.AlertGui
						if alertGui and (alertGui:IsA("SurfaceGui") or alertGui:IsA("BillboardGui")) and alertGui.Enabled == false then
							continue
						end
					end
					
					FireButton(button)
				end

				task.wait(0.05)
			end
			task.wait(0.5)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "My Toll Farm", 
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
	Text = "Roll, Buy & Replace Car",
	Value = false,
	Flag = "upgrade_enabled",
	Callback = function(value)
		Enableds.Upgrade = value
		HandleUpgrade()
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

-- Do not change
Window:AddLabel({
	Text = "YouTube: Crokyreo",
})

Window:AddLabel({
	Text = "Date: 08-16-2026",
})

--[[
-- Roll, Buy & Equip Car --
workspace.Plots.Plot_06 -- OwnerUserId
workspace.Plots.Plot_06.RollStands.Lever.ProximityPrompt.ProximityPrompt
workspace.Plots.Plot_06.RollStands.NewCars.Base
workspace.Plots.Plot_06.RollStands.Stand_01 -- RollState is ReadyToClaim
workspace.Plots.Plot_06.RollStands.Stand_01.RollPreview["Cozy Rover"] -- PurchasePrice

game:GetService("Players").LocalPlayer.Money.Value

game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.CarIndexFrame.ScrollingFrame
game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.CarIndexFrame.ScrollingFrame["Car_2ad60e9d-e8fa-4dbb-b3de-200b8585ea49"] -- SortPrice
game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.CarIndexFrame.ScrollingFrame["Car_2ad60e9d-e8fa-4dbb-b3de-200b8585ea49"].UnequipButton

-- Other
-- BasePrice
]]
