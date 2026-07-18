local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Instancer = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Instancer/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

local RarityIndex = 0
local Enableds = {["CollectCash"] = false, ["Roll"] = false}
local RollPrompt, RollCrateFolder = nil, nil

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

local function GetItemData()
	local itemData = {}
	local itemScroll = Instancer.FindByPath(PlayerGui, "CollectionGui.CollectionFrame.ScrollingFrame")
	local itemRaritys = {}
	
	if itemScroll then
		for _, frame in ipairs(itemScroll:GetChildren()) do
			local rarity = frame:GetAttribute("rarity")
			if not rarity then continue end
			
			itemData[frame.Name] = {
				Rarity = rarity
			}
			
			if not table.find(itemRaritys, rarity) then
				table.insert(itemRaritys, rarity)
			end
		end
	end
	
	return itemData, #itemRaritys
end

local CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local Plot = GetPlot()
local ItemData, TotalRarity = GetItemData()

local Window = UI:CreateWindow({
	Name = "My Giant Sandwich",
	Destroying = function()
		for key, value in pairs(Enableds) do
			Enableds[key] = false
		end
		CharacterAddedConnection:Disconnect()
	end
})

Window:AddSlider({
	Text = "Roll Index (1-".. tostring(TotalRarity) ..")",
	Range = {1, TotalRarity},
	Value = 1,
	Increment = 1,
	Callback = function(value)
		RarityIndex = value
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
					local rarity = item:GetAttribute("rarity") or item:GetAttribute("Rarity")
					if rarity ~= nil and tostring(rarity) == tostring(RarityIndex) then
						local buyRollPrompt = Instancer.FindByPath(item, "Handle.ProximityPrompt")
						if buyRollPrompt then
							FirePrompt(buyRollPrompt)
						end
					else
						task.wait(2)
						continue
					end
					repeat task.wait() until not item.Parent
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
						if rootPart then 
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
