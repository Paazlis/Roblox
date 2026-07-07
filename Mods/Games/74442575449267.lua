local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local CashEnabled, RebirthEnabled, Farming = false, false, false

local RarityChances = {
  ["Nexus"] = 10000000000000000,
  ["Astral"] = 100000000000000,
  ["Quantum"] = 1000000000000,
  ["OG"] = 100000000000,
  ["StarTech"] = 99999000000,
  ["Exclusive"] = 9990000000,
  ["Forbidden"] = 1000000000,
  ["Secret"] = 100000000,
  ["Void"] = 10000000,
  ["Devine"] = 1000000,
  ["God"] = 100000,
  ["Mythic"] = 10000,
  ["Legendary"] = 1000,
  ["Epic"] = 100,
  ["Rare"] = 50,
  ["Uncommon"] = 1,
  ["Common"] = 0.025
}
local RarityType = "Void"
local RarityList = {}

local SortRarity = {}
for key, value in pairs(RarityChances) do
   table.insert(SortRarity,{key,value})
end
table.sort(SortRarity, function(a,b)
    return a[2] < b[2]
end)
for _, value in ipairs(SortRarity) do
   table.insert(RarityList, value[1])
end
table.clear(SortRarity)

local function GetPlot()
	local plots = workspace:FindFirstChild("\229\156\176\229\155\190")
	if not plots then return nil end
    local ownTerritory = LocalPlayer:GetAttribute("OwnTerritory")
	for _, base in pairs(plots:GetChildren()) do
		local ownerId = base.Name
        if ownerId == ownTerritory then
           return base
        end
	end
	return nil
end

local function GetTerritory()
	local territorys = workspace:FindFirstChild("TerritoryFolder")
	if not territorys then return nil end

	for _, base in pairs(territorys:GetChildren()) do
        if base.Name == LocalPlayer.Name then
           return base
        end
	end
	
	return nil
end

local function FireTouch(a,b)
	if firetouchinterest then
		firetouchinterest(a,b,1)
		task.wait()
        firetouchinterest(a,b,0)
	end
end

local function FireButton(object)
	if firesignal then
		firesignal(object.MouseButton1Click)
		firesignal(object.Activated)
	end
end

local Plot = GetPlot()
local Territory = GetTerritory()

-- Farm Function --
local function AutoFarm()
	if Farming then
		task.spawn(function()
			while Farming do
               ReplicatedStorage.ModuleScripts["Manager_\229\133\179\229\141\161"].Event:FireServer({
                 "GetBoxAndBrainrot",
                 LocalPlayer,
                 RarityChances[RarityType or "Common"] or 1
               })
               task.wait(0.1)
			end
		end)
	end
end



-- Cash Function --
local function AutoCash()
	if CashEnabled then
		task.spawn(function()
			while CashEnabled do
				task.wait(1)
				Plot = (Plot ~= nil and Plot.Parent ~= nil) and Plot or GetPlot()
				if Plot then
					local slots = Plot:FindFirstChild("PlotModel") and Plot.PlotModel:FindFirstChild("PlaceIUnitModel")
					if slots then
						local placeItemFolder = Territory.PlaceItemFolder -> index attribute  
                        for _, model in ipairs(placeItemFolder:GetChildren()) do
                            local index = model:GetAttribute("index")
							if index == nil then continue end
							for _, slot in ipairs(slots:GetChildren()) do
							    if slot.Name:lower():find("place_".. tostring(index)) then
								   local touchButton = slot:FindFirstChild("PlaceBrainrotModel") and slot.PlaceBrainrotModel:FindFirstChild("CollectGoldTouch") 
                                   if touchButton and CashEnabled and LocalPlayer.Character then
                                      FireTouch(LocalPlayer.Character,touchButton)
								   end
								   break
								end
						    end
						end
					end
				end
			end
		end)
	end
end

-- Rebirth Function --
local function AutoRebirth()
	if RebirthEnabled then
		task.spawn(function()
			while RebirthEnabled do
               task.wait()
               if PlayerGui.RebirthGui.Frame.ProgressBar.Bar.Size.X.Scale >= 1 then
                  FireButton(PlayerGui.RebirthGui.Frame.Rebirth)
               end
               task.wait(0.1)
			end
		end)
	end
end

-- Main UI --
local Window = UI:CreateWindow({
	Name = "Throw Hammers for Brainrots", 
	Destroying = function()
		CashEnabled, RebirthEnabled, Farming = false, false, false
	end
})

Window:AddDropdown({
    Text = "Rarity Type",
    Options= RarityList,
    Option = RarityType,
	Callback = function(option)
	    RarityType = option[1]
	end
})

Window:AddToggle({
	Text = "Auto Farm",
	Value = false,
	Callback = function(value)
		Farming = value
		AutoFarm()
	end
})

Window:AddToggle({
	Text = "Collect Cash",
	Value = false,
	Callback = function(value)
		CashEnabled = value
		AutoCash()
	end
})

Window:AddToggle({
	Name = "Auto Rebirth",
	Value = false,
	Callback = function(value)
		RebirthEnabled = value
		AutoRebirth()
	end
})

Window:AddLabel("YouTube: Crokyreo")
Window:AddLabel("YouTube: vaehz")
