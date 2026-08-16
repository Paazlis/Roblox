local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections, Values = {["Collect"] = false, ["Cooking"] = false}, {}, {}

local SpawnBahanFolder = workspace:FindFirstChild("SpawnBahan")
local BahanTypes, BahanActives, BahanInfos = {"Melati", "Kemenyan", "Kepiting Sungai", "Jamur Kuburan", "Gagak", "Dupa"}, {["AllEnabled"] = true}, {}

local ResepScroll = PlayerGui:QueryDescendants("#MemasakGui > #Overlay > #Card > #PanelRow > #ResepPanel > #Scroll > #List")[1]

if SpawnBahanFolder then
	local sortBahans = {}

	for _, item in ipairs(SpawnBahanFolder:GetChildren()) do
		if item and item.Parent and item:IsA("BasePart") then
			local ambilPrompt = nil

			for _, prompt in ipairs(item:GetDescendants()) do
				if prompt and prompt.Parent and prompt:IsA("ProximityPrompt") and prompt.Name == "AmbilPrompt" then
					ambilPrompt = prompt
					break
				end
			end

			if not ambilPrompt then continue end

			local objectText = ambilPrompt.ObjectText

			table.insert(sortBahans, {
				Name = objectText,
				Tier = tonumber(string.match(objectText, "%d+")),
				SpawnPoint = item,
				Prompt = ambilPrompt
			})
		end
	end

	for _, bahanStats in ipairs(sortBahans) do
		if not BahanInfos[bahanStats.Name] then
			BahanInfos[bahanStats.Name] = {}
		end
		table.insert(BahanInfos[bahanStats.Name], bahanStats)
	end

	for key, _ in pairs(BahanInfos) do
		if not table.find(BahanTypes, key) then
			table.insert(BahanTypes, key)
		end
		BahanActives[key] = false
	end
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function FirePrompt(prompt)
	if fireproximityprompt  then
		fireproximityprompt(prompt)
	end
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function HandleMaterial()
	if not Enableds.Collect then
		if Values.SaveMaterialCFrame then
			Character:PivotTo(Values.SaveMaterialCFrame)
			Values.SaveMaterialCFrame = nil
		end
		return
	end
	local saveCFrame = Character:GetPivot()
	Values.SaveMaterialCFrame = saveCFrame
	local teleporting = false
	task.spawn(function()
		while Enableds.Collect do
			teleporting = false
			for key, active in pairs(BahanActives) do
				task.wait(0.1)
				if not Enableds.Collect then break end
				if key == "AllEnabled" then continue end
				if BahanActives.AllEnabled then active = true end
				if not active then continue end
				local list = BahanInfos[key]
				if not list then continue end
				for _, info in ipairs(list) do
					local spawnPoint = info.SpawnPoint
					local prompt = info.Prompt
					if spawnPoint and prompt then
						if prompt.Enabled == true and Enableds.Collect then
							teleporting = true
							Character:PivotTo(spawnPoint.CFrame)
							task.wait(0.2)
							FirePrompt(prompt)
							task.wait(0.1)
						end
					end
				end
			end
			if not Enableds.Collect then break end
			if teleporting and Enableds.Collect then
				Character:PivotTo(saveCFrame)
			end
			task.wait(1)
		end
	end)
end

local function HandleCooking()
	if not Enableds.Cooking then return end
	task.spawn(function()
		while Enableds.Cooking do
			for _, item in ipairs(ResepScroll:GetChildren()) do
				if not Enableds.Cooking then break end
				local rowFrame = item:FindFirstChild("Row")
				if not rowFrame then continue end
				local masakButton = rowFrame:FindFirstChild("MasakBtn")
				if not masakButton then continue end
				if Enableds.Cooking then
					FireButton(masakButton)
					task.wait(0.1)
				end
			end
			task.wait(0.5)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Pasar Setan", 
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

Window:AddDropdown({
	Text = "Material Type (Empty = All)",
	Options = #BahanTypes > 0 and BahanTypes or {"No Meterial Type"},
	Option = nil,
	MultipleOptions = true,
	Flag = "material_options",
	Callback = function(option)
		for _, mode in ipairs(BahanTypes) do
			BahanActives[mode] = table.find(option, mode) ~= nil and true or false
		end
		BahanActives.AllEnabled = #option <= 0
	end
})

Window:AddToggle({
	Text = "Collect Material",
	Value = false,
	Callback = function(value)
		Enableds.Collect = value
		HandleMaterial()
	end
})

Window:AddToggle({
	Text = "Auto Cooking",
	Value = false,
	Callback = function(value)
		Enableds.Cooking = value
		HandleCooking()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-01-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
