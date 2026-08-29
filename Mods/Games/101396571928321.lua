local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer

local ItemCache = {}
local ItemFolder = nil
local ItemGridFolder = nil

local Enableds = {["Merge"] = false, ["Buy"] = false, ["Rebirth"] = false}
local Connections = {}
local Cleans = {}
local Packets = {
	["Rebirth"] = ReplicatedStorage:QueryDescendants("#Remotes > #Rebirth")[1],
	["BuySpinner"] = ReplicatedStorage:QueryDescendants("#Remotes > #BuyMaxSpinner")[1],
	["DropSpinner"] = ReplicatedStorage:QueryDescendants("#Remotes > #DropSpinner")[1],
	["PickupSpinner"] = ReplicatedStorage:QueryDescendants("#Remotes > #PickupSpinner")[1]
}

local function ObserveChild(instance,callback,noInitial)
	local childAddedConnection
	local childCache={}

	local function OnChildRemoved(child)
		local childInfo=childCache[child]
		if childInfo==nil then return end
		childCache[child]=nil
		childInfo.AncestryChanged:Disconnect()
		local cleanup=childInfo.Cleanup
		if cleanup==nil or type(cleanup)~="function" then return end
		task.spawn(cleanup,child)
	end

	local function OnChildAdded(child)
		if childAddedConnection.Connected and child~=nil and child.Parent~=nil then
			local cleanup=callback(child)
			if cleanup~=nil and type(cleanup)=="function" then
				if childAddedConnection.Connected and child~=nil and child.Parent~=nil then
					local childInfo={["Cleanup"]=cleanup}
					childInfo.AncestryChanged=child.AncestryChanged:Connect(function(_,parent)
						if not (parent~=nil and child:IsDescendantOf(instance)) then
							OnChildRemoved(child)
						end
					end)
					childCache[child]=childInfo
				else
					task.spawn(cleanup,child)
				end
			end
		end
	end

	-- Listen for changes:
	childAddedConnection=instance.ChildAdded:Connect(OnChildAdded)

	-- Initial:
	task.defer(function()
		if not childAddedConnection.Connected or noInitial then return end
		local children=instance:GetChildren()
		for i,child in ipairs(children) do
			if not childAddedConnection.Connected then break end
			task.defer(OnChildAdded,child)
		end
	end)

	-- Cleanup:
	return function()
		childAddedConnection:Disconnect()
		local child=next(childCache)
		while child do
			OnChildRemoved(child)
			child=next(childCache)
		end
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

-- Rebirth Function --
local function HandleRebirth()
	if not Enableds.Rebirth then return end
	task.spawn(function()
		while Enableds.Rebirth do
			Packets.Rebirth:FireServer()
			task.wait(5)
		end
	end)
end

-- Buy Function --
local function HandleBuy()
	if not Enableds.Buy then return end
	task.spawn(function()
		while Enableds.Buy do
			Packets.BuySpinner:FireServer()
			task.wait(3)
		end
	end)
end

-- Merge Function --
local function OnItemRemoved(item)
	local itemInfo = ItemCache[item]
	if itemInfo then
		ItemCache[item] = nil
		local itemConnections = itemInfo.Connections
		if itemConnections then
			for key, value in pairs(itemConnections) do
				if value then
					value:Disconnect()
				end
			end
		end
	end
end

local function OnItemObserve(item)
	if not (item and item.Parent) then return end
	local itemInfo = {Parent = true, Tier = item:GetAttribute("Tier")}
	ItemCache[item] = itemInfo
	return OnItemRemoved
end

local function SortItemCheck(a, b)
	return a.Tier < b.Tier
end

local function HandleMerge()
	if Cleans.ObserveItem then Cleans.ObserveItem() Cleans.ObserveItem = nil end
	local item, itemInfo = next(ItemCache)
	while itemInfo do
		OnItemRemoved(item)
		item, itemInfo = next(ItemCache)
	end
	if not Enableds.Merge then return end
	Cleans.ObserveItem = ObserveChild(ItemFolder, OnItemObserve)
	task.spawn(function()
		local sortItems, groupedItems = {}, {}
		while Enableds.Merge do
			task.wait(1)

			table.clear(sortItems)

			for _, item in pairs(ItemCache) do
				if not Enableds.Merge then break end
				if item and item.Tier then
					table.insert(sortItems, item)
				end
			end

			table.sort(sortItems, SortItemCheck)

			if not Enableds.Merge then break end

			table.clear(groupedItems)

			for _, sortItem in ipairs(sortItems) do
				if not Enableds.Merge then break end
				if sortItem then
					if sortItem.Tier then
						local tierKey = tostring(sortItem.Tier)
						if groupedItems[tierKey] == nil then
							groupedItems[tierKey] = {}
						end
						table.insert(groupedItems[tierKey], sortItem)
					end
				end
			end


			-- Cari grup MaxHealth atau TroopId yang isinya 2 troop atau lebih
			for key, group in pairs(groupedItems) do
				if not Enableds.Merge then break end

				if #group >= 2 then
					task.wait(0.1)
				end
			end

			if not Enableds.Merge then break end
		end
	end)
end

local Plot = GetPlot()
if Plot then
	ItemFolder = Plot:FindFirstChild("PlayerSpinners")
	GridFolder = ReplicatedStorage:QueryDescendants("#Grids > #MergeGrids")[1]
end

local Window = UI:CreateWindow({
	Name = "Merge a Spinner",
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end

		for key, value in pairs(Connections) do
			if value then
				value:Disconnect()
			end
		end

		local item, itemInfo = next(ItemCache)
		while itemInfo do
			OnItemRemoved(item)
			item, itemInfo = next(ItemCache)
		end
	end
})

Window:AddToggle({
	Text = "Auto Merge",
	Value = false,
	Flag = "merge_enabled",
	Callback = function(value)
		Enableds.Merge = value
		HandleMerge()
	end
})

Window:AddToggle({
	Text = "Buy Spinner",
	Value = false,
	Flag = "buy_enabled",
	Callback = function(value)
		Enableds.Buy = value
		HandleBuy()
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

--[[
-- Plot
workspace.Plots.Plot3 -- OwnerUserId

-- This code was generated by Cobalt
-- https://gitlab.com/upio/cobalt

local Event = game:GetService("ReplicatedStorage").Remotes.PickupSpinner
Event:FireServer(
    workspace.Plots.Plot1.PlayerSpinners.Spinner3 -- Tier
)

-- This code was generated by Cobalt
-- https://gitlab.com/upio/cobalt

local Event = game:GetService("ReplicatedStorage").Remotes.DropSpinner
Event:FireServer(
    nil,
    2, -- TileIndex -- workspace.Plots.Plot1.Grids.MergeGrids:GetChildren()[6]
    "Merge"
)



-- Buy Spinner --
-- This code was generated by Cobalt
-- https://gitlab.com/upio/cobalt

local Event = game:GetService("ReplicatedStorage").Remotes.BuyMaxSpinner
Event:FireServer()


-- Rebirth --
-- This code was generated by Cobalt
-- https://gitlab.com/upio/cobalt

local Event = game:GetService("ReplicatedStorage").Remotes.Rebirth
Event:FireServer()
]]
