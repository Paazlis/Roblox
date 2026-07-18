local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Instancer = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Instancer/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

local RarityTypes = {"Common", "Rare", "Epic", "Legendary", "Mythic", "Secret"}
local Enableds = {["CollectCash"] = false, ["Roll"] = false}
local RollType = "Common"
local RollPrompt, RollCrateFolder, ItemScroll = nil, nil
local ItemData = {}

local function FirePrompt(prompt)
	if fireproximityprompt then
		fireproximityprompt(prompt)
	end
end

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

local function GetPlot()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end

	for _, plot in ipairs(plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId ~= nil and ownerId == LocalPlayer.UserId then
			return plot
		end
	end

	return nil
end

local function SetupItemAndRarityData()
	ItemScroll = ItemScroll or Instancer.FindByPath(PlayerGui, "CollectionGui.CollectionFrame.ScrollingFrame")
	
	if ItemScroll then
		table.clear(ItemData)
		local rarityList = {}
		
		for _, frame in ipairs(ItemScroll:GetChildren()) do
			local id = frame:GetAttribute("id")
			if not id then continue end
			
			local rarity = frame:GetAttribute("rarity")
			if not rarity then continue end
			
			local rarityIndex = tonumber(rarity)
			
			local newData = {
				Name = frame.Name,
				Rarity = rarityIndex and RarityTypes[rarityIndex] or tostring(rarity),
				Id = id
			}

			table.insert(ItemData, newData)
			print(`{newData.Name} - {newData.Rarity} - {newData.Id}`)
			
			if not table.find(rarityList, rarity) then
				table.insert(rarityList, rarity)
			end
		end
		
		if #RarityTypes == #rarityList then
		else
			for i = #RarityTypes, #rarityList do
				table.insert(RarityTypes,tostring(rarityList[i]))
			end
		end
		
		table.clear(rarityList)
	end
end

local function IsItem(id)
	for _, data in ipairs(ItemData) do
		if data.Id == id then
			return true
		end
	end
	
	return false
end

local CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local Plot = GetPlot()
SetupItemAndRarityData()

local Window = UI:CreateWindow({
	Name = "My Giant Sandwich",
	Destroying = function()
		for key, value in pairs(Enableds) do
			Enableds[key] = false
		end
		CharacterAddedConnection:Disconnect()
	end
})

Window:AddDropdown({
	Text = "Roll Type",
	Options = RarityTypes,
	Value = nil,
	Callback = function(value)
		RollType = value
	end
})

Window:AddToggle({
	Text = "Auto Roll",
	Value = false,
	Callback = function(value)
		Enableds["Roll"] = value
		if value then 
			RollCrateFolder = RollCrateFolder or Instancer.FindByPath(Plot, "CrateSpawn.CrateFolder")
			RollPrompt = RollPrompt or Instancer.FindByPath(Plot, "SpawnLever.Base.ProximityPrompt")
			task.spawn(function()
				while Enableds["Roll"] do
					task.wait(1)
					FirePrompt(RollPrompt)
					local item = RollCrateFolder.ChildAdded:Wait()
					local id = item:GetAttribute("id")
					if id ~= nil and IsItem(id) then
						local buyRollPrompt = Instancer.FindByPath(item, "Handle.ProximityPrompt")
						if buyRollPrompt and Enableds["Roll"] then
							FirePrompt(buyRollPrompt)
						end
					end
					repeat task.wait() until not item.Parent or not Enableds["Roll"]
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Collect Cash",
	Value = false,
	Callback = function(value)
		Enableds["CollectCash"] = value
		if value then 
			task.spawn(function()
				while Enableds["CollectCash"] do
					task.wait(1)
					if Character and Character.Parent then
						local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
						if rootPart and Enableds["CollectCash"] then 
							local collisionPart = Plot.CollectButtons.CollectButton1.Hitbox
							FireTouch(rootPart, collisionPart)
						end
					end
				end
			end)
		end
	end
})

local DupeButton = nil
DupeButton = Window:AddButton({
	Text = "Dupe Item",
	MethodType = "DebounceClick",
	ClickDuration = 1,
	Callback = function()
		DupeButton.Visible = false
	end
})

Window:AddLabel("YouTube: Crokyreo")
Window:AddLabel("YouTube: ...")
