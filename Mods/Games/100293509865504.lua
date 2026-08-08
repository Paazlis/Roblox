local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService
local VirtualInputManager=Services.VirtualInputManager

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

local Enableds, Connections = {Aim = false, Upgrade = false, Sell = false}, {}
local AimSettings = {Speed = 0.8}

local DuckFolder = workspace:FindFirstChild("Ume")

local UpgradeTypes, UpgradeActives, UpgradeInfos, UpgradeOption = {}, {}, {}, {}
UpgradeActives["AllEnabled"] = true

local ClickPoint = Vector2.new(500, 500)

local SellButton = nil
local UpgradeScroll = PlayerGui:QueryDescendants("#Upgrades > #Widget")[1]


if UpgradeScroll then
	local sortUpgrades = {}
	
	local upgradeList = {}
	
	local dogWidgets = UpgradeScroll:QueryDescendants("#Dog > #DogsContent > #Stats")[1]
	if dogWidgets then
		table.insert(upgradeList, {
			["Id"] = "Dog",
			["Scroll"] = dogWidgets
		})
	end
	
	local meWidgets = UpgradeScroll:QueryDescendants("#Me > #MeContent > #Stats")[1]
	if meWidgets then
		table.insert(upgradeList, {
			["Id"] = "Player",
			["Scroll"] = meWidgets
		})
	end
	
	for _, info in ipairs(upgradeList) do
		local scroll = info.Scroll
		local id = info.Id
		
		for _, layer in ipairs(scroll:GetChildren()) do
			local buyButton = layer:QueryDescendants("#BuyButton > #S_Button")[1]
			if not buyButton then continue end

			local buttons = layer:QueryDescendants("#S_Button_1 > #Container")[1]
			local title = nil

			if buttons then
				for _, label in ipairs(buttons:GetChildren()) do
					if label:IsA("TextLabel") and not label.Text:find("->") and label.Name == "ButtonText" then
						title = label
					end
				end
			end
			if not title then continue end


			local key = id.." "..title.Text

			if not UpgradeInfos[key] then
				UpgradeInfos[key] = {}
				UpgradeActives[key] = false
				table.insert(sortUpgrades, {
					Name = key,
					Tier = layer.LayoutOrder,
				})

				if key:find("Speed") or key:find("Damage") or key:find("De") then
					table.insert(UpgradeOption, key)
				end
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

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

-- Fungsi untuk mendapatkan Duck terdekat
local function GetNearestDuck()
	local nearestPart = nil
	local shortestDistance = 850
	
	local playerRootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
	if not playerRootPart then return nil end
	
	local playerPos = playerRootPart.Position

	if DuckFolder then
		for _, child in ipairs(DuckFolder:GetChildren()) do
			if child and child.Parent then
			    local childName = child.Name
				
				local rootPart = child:FindFirstChild("RootPart")

				if string.find(childName, "BossController_Client") then 
					nearestPart = rootPart
					break
				end
				
				if rootPart then
					local distance = (playerPos - rootPart.Position).Magnitude

					if distance <= shortestDistance then
						shortestDistance = distance
						nearestPart = rootPart
					end
				end
			end
		end
	end

	return nearestPart
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function PlayerRequestStreamAroundAsync(position, timeOut)
	-- Minta Roblox memuat area lokasi teleport agar mengurangi durasi GameplayPaused
	pcall(function()
		LocalPlayer:RequestStreamAroundAsync(position, timeOut)
	end)
end

local function SendClick(x,y)
	VirtualInputManager:SendMouseButtonEvent(x,y,0,true,game,0)
	task.wait()
	VirtualInputManager:SendMouseButtonEvent(x,y,0,false,game,0)
end

local function HandleAim()
	if Connections.Aim then
		Connections.Aim:Disconnect()
		Connections.Aim = nil
	end
	if not Enableds.Aim then return end

	Connections.Aim = RunService.RenderStepped:Connect(function(deltaTime)
		local target = GetNearestDuck()

		if target then
			local cameraPos = Camera.CFrame.Position
			local targetPos = target.Position

			-- Kalkulasi rotasi kamera untuk melihat ke target
			local goalCFrame = CFrame.lookAt(cameraPos, targetPos)

			-- Menggunakan Lerp agar kamera tidak snap instan (lebih manusiawi)
			-- Kecepatan bergantung pada Slider, Frame Rate, dan pengali konstan
			local lerpAlpha = math.clamp(AimSettings.Speed * deltaTime * 10, 0.01, 1)
			Camera.CFrame = Camera.CFrame:Lerp(goalCFrame, lerpAlpha)
		end
	end)
end

local function HandleSell()
	if not Enableds.Sell then return end
	
	SellButton = SellButton or PlayerGui:QueryDescendants("#Upgrades > #Widget > #Me > #MeContent > #ButtonContainer > #Button_Sell > #S_Button")[1]

	task.spawn(function()
		while Enableds.Sell do
			FireButton(SellButton)
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
				if UpgradeActives.AllEnabled == true then active = true end
				if key == "AllEnabled" or not active then continue end

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

local Window = UI:CreateWindow({
	Name = "Catch 1 Billion Ducks",
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

Window:AddSlider({
	Text = "Aim Speed",
	Range = {0.1, 2},
	Value = 0.8,
	Increment = 0.1,
	Flag = "aim_speed",
	Callback = function(value)
		AimSettings.Speed = value
	end
})

Window:AddToggle({
	Text = "Auto Aim",
	Value = false,
	Flag = "aim_enabled",
	Callback = function(value)
		Enableds.Aim = value
		HandleAim()
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
	Option = UpgradeOption,
	MultipleOptions = true,
	Flag = "upgrade_options",
	Callback = function(option)
		UpgradeActives["AllEnabled"] = #option <= 0
		for _, mode in ipairs(UpgradeTypes) do
			UpgradeActives[mode] = table.find(option, mode) ~= nil and true or false
		end
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

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-07-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
