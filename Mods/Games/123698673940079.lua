local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds = {["Collect"] = false, ["Rebirth"] = false, ["BuyTrail"] = false, ["UpgradeBrainrot"] = false, ["UpgradeTreadmill"] = false, ["ClaimIndex"] = false}

local Values = {}

local Packets = {
	["Rebirth"] = ReplicatedStorage:QueryDescendants("#Remotes > #Rebirth")[1],
	["ClaimIndex"] = ReplicatedStorage:QueryDescendants("#Remotes > #ClaimIndexRewards")[1]
}

local Interfaces = {
	["RebirthFill"] = PlayerGui:QueryDescendants("#ScreenGui > #Rebirth > #Frame > #Progress > #Bar")[1],
	["RebirthButton"] = PlayerGui:QueryDescendants("#ScreenGui > #Rebirth > #Frame > #Rebirth")[1],
	["TrailScroll"] = PlayerGui:QueryDescendants("#ScreenGui > #TrailShop > #ScrollingFrame")[1],
}

local Plot = {}

local AreasList = {
	"Automatic"
}

Values.ChosenArea = "Automatic"

local SpawnedEggs = workspace:FindFirstChild("Eggs")
if SpawnedEggs then
	for i, v in ipairs(SpawnedEggs:GetChildren()) do
		table.insert(AreasList, v.Name)
	end
end

--[[
all need fixing 
Equipped and Equip

160.93484497070312, 17.85004425048828, -28.55618667602539

Plains: 800
Deserts: 9000
Safari: 40000
Snow: 150000
Mines: 750000
Juggle: 2500000
Lava: 15000000
Hacked: 500000000
Strawb: 1500000000

-- click multiply --
game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Multiply
game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Multiply:GetChildren()[3]
]]
local Areas = {
	["Forest"] = {
		Speed = 0
	},
	["Lake"] = {
		Speed = 900
	},
	["Desert"] = {
		Speed = 10000
	},
	["Jungle"] = {
		Speed = 40000
	},
	["Snow"] = {
		Speed = 450000
	},
	["Volcano"] = {
		Speed = 700000
	},
	["Abyss Ocean"] = {
		Speed = 2500000
	},
	["Prehistoric"] = {
		Speed = 17000000
	},
	["Cosmic"] = {
		Speed = 700000000
	}
}

local Waypoints = {
	SafeArea = Vector3.new(542, 71, -363)
}

local treadmills = workspace:QueryDescendants("#Treadmills > #Base1")[1]
if treadmills then
	treadmills = treadmills.Parent
	for _, treadmill in ipairs(treadmills:GetChildren()) do
		local ownerId = treadmill:GetAttribute("OwnerId")
		if ownerId ~= nil and ownerId == LocalPlayer.UserId then
			Plot.Treadmill = treadmill
			break
		end
	end
	if Plot.Treadmill then
		Plot.UpgradeTreadmillButton = Plot.Treadmill:QueryDescendants("#UpgradeFrame > #SurfaceGui > #CanvasGroup > #Buy")
	end
end

local bases = workspace:QueryDescendants("#Bases > #Base1")[1]
if bases then
	bases = bases.Parent
	for _, base in ipairs(bases:GetChildren()) do
		local ownerId = base:GetAttribute("OwnerId")
		if ownerId ~= nil and ownerId == LocalPlayer.UserId then
			Plot.Base = base
			break
		end
	end
	if Plot.Base then
		Plot.Slots = Plot.Base:FindFirstChild("Slots")
	end
end

local function FireButton(button)
	if firesignal then
		if not (button and button.Parent) then return end
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local Window = UI:CreateWindow({
	Name = "Steal A Lucky Egg",
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
	end
})

Window:AddDropdown({
	Name = "Area",
	Options = AreasList,
	Option = Values.ChosenArea,
	Multi = false,
	Callback = function(option)
		Values.ChosenArea = option[1]
	end
})

Interfaces.CollectToggle = Window:AddToggle({
	Text = "Auto Collect",
	Value = false,
	Callback = function(value)
		Interfaces.CollectToggle:Replace(false)
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Callback = function(value)
		Enableds.Rebirth = value
		if not Enableds.Rebirth then return end
		task.spawn(function()
			while Enableds.Rebirth do
				if Interfaces.RebirthFill.Size.X.Scale >= 1 then
					if Packets.Rebirth then
						Packets.Rebirth:FireServer()
					else
						FireButton(Interfaces.RebirthButton)
					end
				end
				task.wait()
			end
		end)
	end
})

Window:AddToggle({
	Text = "Buy Trail",
	Value = false,
	Callback = function(value)
		Enableds.BuyTrail = value
		if not Enableds.BuyTrail then return end
		Values.TrailCache = {}
		task.spawn(function()
			while Enableds.BuyTrail do
				for _, layer in ipairs(Interfaces.TrailScroll:GetChildren()) do
					task.wait()
					if not Enableds.BuyTrail then break end
					if layer and layer.Parent and layer:IsA("GuiObject") and layer.Visible == true then
						local info = Values.TrailCache[layer]
						if info == nil then
							info = {}
							info.Button = info.Button or layer:QueryDescendants("#Buttons > #CashButton")[1]
							info.Title = info.Title or layer:QueryDescendants("#Buttons > #CashButton > #TextLabel")[1]
							if not (info.Button and info.Title) then continue end
							Values.TrailCache[layer] = info
						end
						info = Values.TrailCache[layer]
						if info and info.Button and info.Title and info.Title.Text:find("$") then
							FireButton(info.Button)
						end
					end
				end
				
				task.wait(1)
			end
		end)
	end
})

Window:AddToggle({
	Text = "Upgrade Brainrot",
	Value = false,
	Callback = function(value)
		Enableds.UpgradeBrainrot = value
		if not Enableds.UpgradeBrainrot then return end
		Values.SlotCache = {}
		task.spawn(function()
			while Enableds.UpgradeBrainrot do
				for _, slot in ipairs(Plot.Slots:GetChildren()) do
					task.wait()
					if not Enableds.UpgradeBrainrot then break end
					if slot and slot.Parent then
						local slotState = slot:GetAttribute("SlotState")
						if slotState ~= nil then
							local info = Values.SlotCache[slot]
							if info == nil then
								info = {}
								info.Button = info.Button or slot:QueryDescendants("#UpgradeModel > #UpgradePart > #SurfaceGui > #ImageButton")[1]
								if not info.Button then continue end
								Values.SlotCache[slot] = info
							end
							info = Values.SlotCache[slot]
							if info and slotState == "Empty" then
								FireButton(info.Button)
							end
						end
					end
				end
				task.wait(1)
			end
		end)
	end
})

Window:AddToggle({
	Text = "Upgrade Treadmill",
	Value = false,
	Callback = function(value)
		Enableds.UpgradeTreadmill = value
		if not Enableds.UpgradeTreadmill then return end
		task.spawn(function()
			while Enableds.UpgradeTreadmill do
				FireButton(Plot.UpgradeTreadmillButton)
				task.wait(1)
			end
		end)
	end
})

Window:AddToggle({
	Text = "Claim Index",
	Value = false,
	Callback = function(value)
		Enableds.ClaimIndex = value
		if not Enableds.ClaimIndex then return end
		task.spawn(function()
			while Enableds.ClaimIndex do
				Packets.ClaimIndex:FireServer()
				task.wait(3)
			end
		end)
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
