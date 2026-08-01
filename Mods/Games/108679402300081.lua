local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players

local LocalPlayer=Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections, Values = {["Collect"] = false}, {}, {}

local SpawnBahanFolder = workspace:FindFirstChild("SpawnBahan")
local BahanTypes, BahanActives, BahanInfos = {"Melati", "Kemenyan", "Kepiting Sungai", "Jamur Kuburan", "Gagak", "Dupa"}, {}, {}
local BahanDuration = 1

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

BahanActives["AllEnabled"] = true

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function FirePrompt(prompt)
	if fireproximityprompt  then
		fireproximityprompt(prompt)
	end
end

-- Collect Material Function --
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
				task.wait()
				if not Enableds.Collect then break end

				if key == "AllEnabled" then
					continue
				end

				if BahanActives["AllEnabled"] then
					active = true
				end

				if active then
					local bahanList = BahanInfos[key]
					if not bahanList then continue end

					for _, bahanStats in ipairs(bahanList) do
						local spawnPoint = bahanStats.SpawnPoint
						local prompt = bahanStats.Prompt

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
			end

			if not Enableds.Collect then break end

			if teleporting and Enableds.Collect then
				Character:PivotTo(saveCFrame)
			end

			task.wait(BahanDuration)
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
		BahanActives["AllEnabled"] = #option <= 0
		for _, mode in ipairs(BahanTypes) do
			BahanActives[mode] = table.find(option, mode) ~= nil and true or false
		end
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

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255),
})

-- Game Info --
--[[
-- Jasmine Flower / Melati --
workspace.SpawnBahan.Spawn_Melati.BahanVisual.e -- Transparency == 0
workspace.SpawnBahan.Spawn_Melati.BahanVisual.Grip.AmbilPrompt

-- Frankincense/ Kemenyan --
workspace.SpawnBahan.Spawn_Kemenyan
workspace.SpawnBahan.Spawn_Kemenyan.BahanVisual.Handle.AmbilPrompt 

-- River Crab / Kepiting Sungai --
workspace.SpawnBahan.Spawn_KepitingSungai.BahanVisual.Grip
workspace.SpawnBahan.Spawn_KepitingSungai.BahanVisual.Grip.AmbilPrompt
workspace.SpawnBahan.Spawn_KepitingSungai.BahanVisual.node_0


-- Graveyard Mushroom / Jamur Kuburan --
workspace.SpawnBahan.Spawn_JamurKuburan
workspace.SpawnBahan.Spawn_JamurKuburan.BahanVisual.Grip.AmbilPrompt


-- Carrion Bird / Gagak --
workspace.SpawnBahan.Spawn_Gagak
workspace.SpawnBahan.Spawn_Gagak.BahanVisual.defaultMaterial
workspace.SpawnBahan.Spawn_Gagak.BahanVisual.Grip.AmbilPrompt

-- Incense / Dupa --
workspace.SpawnBahan.Spawn_Dupa.BahanVisual.Grip.AmbilPrompt

]]
