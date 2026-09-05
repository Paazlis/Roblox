local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds = {["Collect"] = false, ["Rebirth"] = false, ["ClaimIndex"] = false, ["ClickMultiply"] = false}
local Connections = {}
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

local Areas = {
	["Grass"] = {
		Speed = 0
	},
	["Plains"] = {
		Speed = 800
	},
	["Desert"] = {
		Speed = 9000
	},
	["Safari"] = {
		Speed = 40000
	},
	["Snow"] = {
		Speed = 150000
	},
	["Mines"] = {
		Speed = 750000
	},
	["Jungle"] = {
		Speed = 2500000
	},
	["Lava"] = {
		Speed = 15000000
	},
	["Hacked"] = {
		Speed = 500000000
	},
	["Strawb"] = {
		Speed = 1500000000
	}
}

local ProfileData = LocalPlayer:GetAttributes()

if ProfileData.Speed ~= nil then
	Connections.SpeedChanged = LocalPlayer:GetAttributeChangedSignal("Speed"):Connect(function()
		ProfileData.Speed = LocalPlayer:GetAttribute("Speed")
	end)
else
	ProfileData.Speed = 0
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local SpawnedEggs = workspace:FindFirstChild("Eggs")
if SpawnedEggs then
	for i, v in ipairs(SpawnedEggs:GetChildren()) do
		table.insert(AreasList, v.Name)
	end
end

local GuardAreas = SpawnedEggs


local Waypoints = {
	SafeArea = Vector3.new(160, 17.85, -28)
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

local UpgradeTypes = {"Treadmill","Brainrot","Buy Trail"}
local UpgradeActives = {["AllEnabled"]=true}

for _, upgradeType in ipairs(UpgradeTypes) do
	UpgradeActives[upgradeType] = false
end

local TrailInfos = {}

if Interfaces.TrailScroll then
	local sortTrails={}

	for _,layer in ipairs(Interfaces.TrailScroll:GetChildren()) do
		if layer and layer.Parent and layer:IsA("GuiObject") then
			local button=layer:QueryDescendants("#Buttons > #CashButton")[1]
			if not button then continue end

			local title=layer:QueryDescendants("#Buttons > #CashButton > #TextLabel")[1]
			if not title then continue end
			
			table.insert(sortTrails, {
				["Button"]=button,
				["Title"]=title,
				["Tier"]=layer.LayoutOrder
			})
		end
	end

	table.sort(sortTrails, function(a, b)
		return a.Tier<b.Tier
	end)

	for _,info in ipairs(sortTrails) do
		table.insert(TrailInfos,info)
	end
end

local function FireButton(button)
	if firesignal then
		--if not (button and button.Parent) then return end
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function WalkTo(humanoid, position)
	local rootPart = humanoid.RootPart
	while true do
		if not (humanoid and humanoid.Parent) then return false end
		
		humanoid:MoveTo(position)
		local reached = humanoid.MoveToFinished:Wait()

		if reached then
			return true
		end

		if rootPart and rootPart.Parent then
			local flat = (Vector2.new(rootPart.Position.X, rootPart.Position.Z) - Vector2.new(position.X, position.Z)).Magnitude
			if flat <= 4 then
				return true
			end
		else
			return false
		end
	end
end

local function GetBestArea()
	local currentSpeed = ProfileData.Speed
	local bestName, bestSpeed = nil, -1

	if Values.ChosenArea == "Automatic" then
		for name, data in pairs(Areas) do
			if data.Speed <= currentSpeed and data.Speed > bestSpeed then
				bestName = name
				bestSpeed = data.Speed
			end
		end
	else
		bestName = Values.ChosenArea
	end

	return bestName or "Plains"
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

Window:AddToggle({
	Text = "Auto Collect",
	Value = false,
	Callback = function(value)
		Enableds.Collect = value
		if not Enableds.Collect then return end
		
		task.spawn(function()
			while Enableds.Collect do
				task.wait()
				local humanoid = Character:FindFirstChildOfClass("Humanoid")
				
				local bestArea = GuardAreas[GetBestArea()]
				task.wait(0.1)
				WalkTo(humanoid, Waypoints.SafeArea)
				task.wait(0.1)
				WalkTo(humanoid, bestArea.Bounds.Position)

				--local closestEgg, closestDist = nil, nil
				--for _, v in ipairs(SpawnedEggs:GetChildren()) do
				--	if v and v.Parent then
				--		local primaryPart = v.PrimaryPart or v:FindFirstChildOfClass("BasePart")
				--		if primaryPart then
				--			if Character and Character.Parent then
				--				local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
				--				if rootPart~=nil then 
				--					local dist = (primaryPart.Position - Character.HumanoidRootPart.Position).Magnitude
				--					if not closestDist or dist < closestDist then
				--						closestDist = dist
				--						closestEgg = v
				--					end
				--				end
				--			end
				--		end
				--	end
				--end

				--if closestEgg then
				--	walkTo(humanoid, closestEgg.PrimaryPart.Position)

				--	task.wait(0.5)

				--	walkTo(humanoid, closestEgg.PrimaryPart.Position)
				--	task.wait()

				--	Packets.Steal:InvokeServer({Uid = closestEgg.Name})
				--end
				WalkTo(humanoid, Waypoints.SafeArea)
				task.wait(1)
			end
		end)
	end
})

Window:AddToggle({
	Text = "Click Multiply",
	Value = false,
	Callback = function(value)
		Enableds.ClickMultiply = value
		if  Connections.MultiplyAdded then  Connections.MultiplyAdded:Disconnect() Connections.MultiplyAdded = nil end
		if not Enableds.ClickMultiply then return end
		Connections.MultiplyAdded = Connections.MultiplyAdded or PlayerGui.ScreenGui.Multiply.ChildAdded:Connect(function(child)
			task.wait(2)
			if Enableds.ClickMultiply and child and child.Parent and child:IsA("GuiObject") and child.Visible == true then
				FireButton(child)

			end
		end)
		for _, child in ipairs(PlayerGui.ScreenGui.Multiply:GetChildren()) do
			if not Enableds.ClickMultiply then break end
			if child and child.Parent and child:IsA("GuiObject") and child.Visible == true then
				FireButton(child)

			end
		end
	end
})

Window:AddDropdown({
	Text="Upgrade Type",
	Options=#UpgradeTypes>0 and UpgradeTypes or {"No Upgrade Type"},
	Option=nil,
	Multi=true,
	Callback=function(option)
		for _,key in ipairs(UpgradeTypes) do
			UpgradeActives[key]=table.find(option,key)~=nil
		end
		UpgradeActives.AllEnabled=#option<=0
	end
})

Window:AddToggle({
	Text="Auto Upgrade",
	Value=false,
	Callback=function(value)
		Enableds.Upgrade=value
		if not Enableds.Upgrade then return end
		task.spawn(function()
			while Enableds.Upgrade do
				if UpgradeActives["Treadmill"] == true and Plot.UpgradeTreadmillButton then
					FireButton(Plot.UpgradeTreadmillButton)
				end
				task.wait(1)
			end
		end)
		Values.SlotCache = {}
		task.spawn(function()
			while Enableds.Upgrade do
				if UpgradeActives["Brainrot"] == true then
					for _, slot in ipairs(Plot.Slots:GetChildren()) do
						task.wait()
						if not (UpgradeActives["Brainrot"] and Enableds.Upgrade) then break end
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
								if info and slotState ~= "Empty" then
									FireButton(info.Button)
								end
							end
						end
					end
				end
				task.wait(1)
			end
		end)
		
		task.spawn(function()
			while Enableds.Upgrade do
				if UpgradeActives["Buy Trail"] == true then
					for _, info in ipairs(TrailInfos) do
						if not (UpgradeActives["Buy Trail"] and Enableds.Upgrade) then break end
						local key = info.Title.Text:lower()
						if key:find("equip") or key:find("equipped") or key:find("unequipped") then continue end
						if key:find("$") then
							FireButton(info.Button)
						end					
						task.wait()

					end
				end
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

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
