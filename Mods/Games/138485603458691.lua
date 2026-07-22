local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local RebirthFrame, RebirthFill, RebirthButton, RebirthItemRequired = PlayerGui:QueryDescendants("#RebirthGui > #RebirthFrame > #Main")[1], nil, nil, nil
local UpgradeScroll = PlayerGui:QueryDescendants("#UpgradesGui > #UpgradesFrame > #Main > #Rows")[1]
local HomeButton = PlayerGui:QueryDescendants("#HudGuiSafe > #Frame > #Top > #Top > #TopButtons > #HomeButton_BufferParent > #HomeButton")[1]

local UpgradeTypes, UpgradeActives, UpgradeButtons = {}, {}, {}
local Enableds = {["Upgrade"] = false, ["Rebirth"] = false}
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

if UpgradeScroll then
	for _, upgradeLayer in ipairs(UpgradeScroll:GetChildren()) do
		local upgradeTitle = upgradeLayer:FindFirstChild("Upgrades_Entry_CurrentLevel")
		if not upgradeTitle or not upgradeTitle:IsA("TextLabel") then continue end

		local upgradeButton = upgradeLayer:QueryDescendants("#UpgradeTiers > #Upgrades_Entry_Tier_1 > #Upgrades_Entry_Tier_BuyButton")[1]
		if not upgradeButton then continue end
		
		local upgradeKey = upgradeTitle.Text
		table.insert(UpgradeTypes, upgradeKey)
		UpgradeButtons[upgradeKey] = {
			["UpgradeButton"] = upgradeButton,
			["WarningLabel"] = upgradeLayer:FindFirstChild("Upgrades_Entry_WarningLabel")
		}
	end
end


for _, mode in ipairs(UpgradeTypes) do
	UpgradeActives[mode] = false
end

local Window = UI:CreateWindow({
	Name = "Dig for Dinos",
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

Window:AddButton({
	Text = "Home",
	Callback = function()
		FireButton(HomeButton)
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
							local upgradeInfo = UpgradeButtons[mode]
							if upgradeInfo then
								local warningLabel = upgradeInfo.WarningLabel
								if warningLabel and warningLabel.Visible == true then
									continue
								end
								
								local upgradeButton = upgradeInfo.UpgradeButton
								if upgradeButton then
									FireButton(upgradeButton)
								end
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
		Enableds.Rebirth = value
		
		if value then
			RebirthItemRequired = RebirthItemRequired or RebirthFrame:QueryDescendants("#Frame > #Requirements > #DinosRequired")
			RebirthFill = RebirthFill or RebirthFrame:QueryDescendants("#Frame > #Requirements > #CashRequired > #RebirthProgressBar_Bar")[1] 
			RebirthButton = RebirthButton or RebirthFrame:QueryDescendants("#Frame > #BuyButton_BufferParent > #BuyButton")[1]
			
			task.spawn(function()
				local maxRebirthRequirement, rebirthRequirementIndex = 0, 0
				
				while Enableds.Rebirth do
					task.wait()
					
					maxRebirthRequirement, rebirthRequirementIndex = 1, 0
					
					if IsFillFull(RebirthFill) then
						rebirthRequirementIndex += 1
					end
					
					for _, item in ipairs(RebirthItemRequired:GetChildren()) do
						task.wait()
						
						local checkmark = item:FindFirstChild("CheckMark")
						if not checkmark then continue end
						
						maxRebirthRequirement += 1
						
						if checkmark.Visible == true then
							rebirthRequirementIndex += 1
						end
					end
					
					if rebirthRequirementIndex >= maxRebirthRequirement and Enableds.Rebirth then
						FireButton(RebirthButton)
					end
				end
			end)
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
