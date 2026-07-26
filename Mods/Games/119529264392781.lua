local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager=Services.VirtualInputManager

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local Enableds, Connections = {["BuyBall"] = false, ["Prestige"] = false}, {}
local BuyBallButton = nil
local TextButtonDescendantsIn2Step = PlayerGui:QueryDescendants("#RingUI > Frame > TextButton")

for _, textButton in ipairs(TextButtonDescendantsIn2Step) do
   if textButton and string.find(textButton.Text, "Buy Ball") then
      BuyBallButton = textButton
      break
   end
end

local UpgradeTypes, UpgradeActives, UpgradeButtons = {}, {}, {}
local UpgradeScroll = nil
local ScrollingFrameDescendantsIn1Step = PlayerGui:QueryDescendants("#RingUI > ScrollingFrame")

for _, upgradeLayer in ipairs(ScrollingFrameDescendantsIn1Step) do
   if upgradeLayer and upgradeLayer:IsA("Frame") then
      local labels = upgradeLayer:QueryDescendants("TextButton > TextLabel")
	  local titleLabel = nil

	  for _, label in ipairs(labels) do
		if label and label.Text:lower():find("lv.") then
			titleLabel = label
			break
		end
	  end
		
      if titleLabel then
		 local upgradeKey = titleLabel.Text
		 UpgradeActives[upgradeKey] = false
		 UpgradeButtons[upgradeKey] = titleLabel.Parent
		 table.insert(UpgradeTypes, upgradeKey)
	  end
   end
end

local PrestigeButton = nil
local PrestigeFill = PlayerGui:QueryDescendants("#RingPages > TextButton > Frame > Frame > Frame")[1]
if PrestigeFill and PrestigeFill.Parent then
	PrestigeButton = PrestigeFill.Parent.Parent:FindFirstChildOfClass("TextButton")
end

--[[
-- Auto Upgrade --
game:GetService("Players").LocalPlayer.PlayerGui.RingUI.ScrollingFrame
game:GetService("Players").LocalPlayer.PlayerGui.RingUI.ScrollingFrame.Frame.TextButton.TextLabel.Text == "Add Ring"
Add Ring


game:GetService("Players").LocalPlayer.PlayerGui.RingUI.ScrollingFrame:GetChildren()[10].TextButton.TextLabel.Text == "$"

-- auto Prestige --
game:GetService("Players").LocalPlayer.PlayerGui.RingPages.TextButton.Frame.Frame.TextButton

game:GetService("Players").LocalPlayer.PlayerGui.RingPages.TextButton.Frame.Frame.Frame
game:GetService("Players").LocalPlayer.PlayerGui.RingPages.TextButton.Frame.Frame.TextLabel.Text == "/" or "Ready"
]]

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function HandleBuyBall()
	task.spawn(function()
		while Enableds.BuyBall do
			FireButton(BuyBallButton)
			task.wait(0.1)
		end
	end)
end

local function HandleUpgrade()
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

local function FirePrestige()
	if Enableds.Prestige and IsFillFull(PrestigeFill) then
		FireButton(PrestigeButton)
	end
end

local function HandleRebirth()
	Connections.Prestige = RebirthFill:GetPropertyChangedSignal("Size"):Connect(FirePrestige)

	task.spawn(function()
		while Enableds.Prestige do
			FirePrestige()
			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Idle Balls",
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
			HandleUpgrade()
		end
	end
})


Window:AddToggle({
	Text = "Buy Ball",
	Value = false,
	Flag = "buy_ball_enabled",
	Callback = function(value)
		Enableds.BuyBall = value
		if value then 
			HandleBuyBall()
		end
	end
})

Window:AddToggle({
	Text = "Auto Prestige",
	Value = false,
	Flag = "prestige_enabled",
	Callback = function(value)
		Enableds.Prestige = value
		if value then 
			HandlePestige()
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
