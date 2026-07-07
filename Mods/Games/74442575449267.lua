local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Utility/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager = Services.VirtualInputManager
local UserInputService = Services.UserInputService

local GameCore, UtilityCore = nil, nil

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer.PlayerGui

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local LaunchEnabled, BuyEnabled, CashEnabled, TrainEnabled, RebirthEnabled, Farming = false, false, false, false, false, false
local LaunchConnection = nil

local ClickPoint=UserInputService:GetMouseLocation()

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
for key, value in pairs(RarityChances)
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


-- Collect Cash Function --
local function AutoCash()
	if CashEnabled then
		task.spawn(function()
			while CashEnabled do
				task.wait(1)
				Plot = (Plot ~= nil and Plot.Parent ~= nil) and Plot or GetPlot()
				if Plot then
					local slots = Plot:FindFirstChild("PlotModel") and Plot.PlotModel:FindFirstChild("PlaceIUnitModel")
					if slots then
						for _, slot in ipairs(slots:GetChildren()) do
							if slot:IsA("Model") or slot:IsA("Folder") then
								task.wait()
                                local touchButton = slot:FindFirstChild("PlaceBrainrotModel") and slot.PlaceBrainrotModel:FindFirstChild("CollectGoldTouch") 
                                if touchButton and CashEnabled and LocalPlayer.Character then
                                   FireTouch(LocalPlayer.Character,touchButton)
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
		LaunchEnabled, BuyEnabled, CashEnabled, TrainEnabled, RebirthEnabled, Farming = false, false, false, false, false, false
		LaunchConnection = Utility.Cleanup(LaunchConnection)
	end
})

Window:AddDropdown({
    Text = "Rarity",
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
