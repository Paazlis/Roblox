local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local UpgradeTypes, UpgradeActives, UpgradeInfos = {"Buy Worker", "Walk Speed", "Paint Tank", "Roller Size", "Worker Speed", "Roll Luck", "Roll Speed"}, {AllEnabled = true}, {
	["Buy Worker"] = "BuyWorker",
	["Walk Speed"] = "WalkSpeed",
	["Paint Tank"] = "PaintTank",
	["Roller Size"] = "RollerSize",
	["Worker Speed"] = "WorkerSpeed",
	["Roll Luck"] = "RollLuck",
	["Roll Speed"] = "RollSpeed"
}

local Enableds, Connections = {["Paint"] = false, ["Upgrade"] = false, ["Rebirth"] = false}, {}
local Keysteps = {}
local Packets = {["PaintInput"] = nil, ["RequestBuyUpgrade"] = nil, ["RequestBuyWorker"] = nil}
local RebirtFrame, RebirthFill, RebirthButton = nil, nil, nil

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
	local plots = workspace:QueryDescendants("#Map > #Plots")[1]
	if not plots then return nil end
	for _, plot in ipairs(plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId ~= nil and ownerId == LocalPlayer.UserId then
			return plot
		elseif plot.Name:find(tostring(LocalPlayer.UserId)) then
			return plot
		end
	end
	return nil
end

local Plot = GetPlot()
local ItemFolder = nil

for _, mode in ipairs(UpgradeTypes) do
	UpgradeActives[mode] = false
end

local function HandlePaint()
	if not Enableds.Paint then return end
	ItemFolder = ItemFolder or Plot:FindFirstChild("Items")
	Packets.PaintInput = Packets.PaintInput or ReplicatedStorage:QueryDescendants("#Events > #PaintInput")[1]
	task.spawn(function()
		while Enableds.Paint do
			for _, item in ipairs(ItemFolder:GetChildren()) do
				if not Enableds.Paint then break end
				local objectFolder = item:FindFirstChild("Objects")
				if not objectFolder then continue end
				Packets.PaintInput:FireServer(objectFolder:GetChildren())
				task.wait(0.1)
			end
			task.wait(1)
		end
	end)
end

local function HandleUpgrade()
	if not Enableds.Upgrade then return end
	Packets.RequestBuyUpgrade = Packets.RequestBuyUpgrade or ReplicatedStorage:QueryDescendants("#Events > #RequestBuyUpgrade")[1]
	Packets.RequestBuyWorker = Packets.RequestBuyWorker or ReplicatedStorage:QueryDescendants("#Events > #RequestBuyWorker")[1]
	task.spawn(function()	
		while Enableds.Upgrade do
			for key, active in pairs(UpgradeActives) do
				if not Enableds.Upgrade then break end
				if key == "AllEnabled" then continue end
				if UpgradeActives.AllEnabled then active = true end
				if active then
					local mode = UpgradeInfos[key] or "None"
					if mode == "BuyWorker" then
						Packets.RequestBuyWorker:InvokeServer()
					else
						Packets.RequestBuyUpgrade:InvokeServer(mode)
					end
				end
				task.wait(0.1)
			end
			task.wait(1)
		end
	end)
end

local function HandleRebirth()
	if not Enableds.Rebirth then return end
	if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
	RebirtFrame = RebirtFrame or PlayerGui:QueryDescendants("#GameUI > #Frames > #Rebirth")[1]
	if RebirtFrame then
		RebirthButton = RebirthButton or RebirtFrame:FindFirstChild("Rebirth")
		RebirthFill = RebirthFill or RebirtFrame:QueryDescendants("#Progress > #Fill")[1]
	end
	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
		if IsFillFull(RebirthFill) and Enableds.Rebirth then
			FireButton(RebirthButton)
		end
	end)
	task.spawn(function()
		while Enableds.Rebirth do
			if IsFillFull(RebirthFill) then
				FireButton(RebirthButton)
			end
			task.wait(1)
		end
	end)	
end

local Window = UI:CreateWindow({
	Name = "Crunch My Butter",
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
	Text = "Auto Paint",
	Value = false,
	Flag = "paint_enabled",
	Callback = function(value)
		Enableds.Paint = value
		HandlePaint()
	end
})

Window:AddDropdown({
	Text = "Upgrade Type (Empty = All)",
	Options = UpgradeTypes,
	Option = nil,
	MultipleOptions = true,
	Flag = "upgrade_options",
	Callback = function(option)
		for _, mode in ipairs(UpgradeTypes) do
			UpgradeActives[mode] = table.find(option, mode) ~= nil and true or false
		end
		UpgradeActives.AllEnabled = #option <= 0
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
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 07-21-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
