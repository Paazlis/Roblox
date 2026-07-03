local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Utility/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager = Services.VirtualInputManager
local UserInputService = Services.UserInputService

local Plot = nil
local CollectEnabled, SellEnabled = false, false
local WarningPlotStatus, CollectToggle = nil, nil

-- Collect Function --
local function AutoCollect()
  if not Plot then CollectEnabled = false CollectToggle:Replace(false) WarningPlotStatus.Visible = true task.wait(2) WarningPlotStatus.Visible = false return end

  local buildings = Plot:FindFirstChild("Buildings")
  if not buildings then return end

  if not CollectEnabled then return end

  task.spawn(function()
      while CollectEnabled do
          task.wait(1)
          for _, building in ipairs(buildings:GetChildren()) do
             task.wait()
             ReplicatedStorage.rbxts_include.node_modules["@rbxts"].remo.src.container["bait.collectAllFish"]:FireServer(building.Name)
          end
      end
  end)
end

-- Sell Function --
local function AutoSell()
   if not SellEnabled then return end
   task.spawn(function()
      while SellEnabled do
          task.wait(1)
          ReplicatedStorage.rbxts_include.node_modules["@rbxts"].remo.src.container["sellFish.sellAllFish"]:FireServer()
      end
  end)
end

local Window = UI:CreateWindow({
    Name = "Farm a Fish",
    Destroying = function()
       CollectEnabled, SellEnabled = false, false
    end
})

local PlotTargetSelect = nil
PlotTargetSelect = Window:AddSelect({
    Text = "Plot Target",
    Callback = function(target)
       local current = target

       -- Loop terus berjalan selama 'current' itu ADA dan namanya BUKAN "Plot"
       while current do
           if current:IsA("Model") then
			  local buildings = current:FindFirstChild("Buildings")
			  if buildings and buildings.Parent and buildings.Parent.Parent and buildings.Parent.Parent.Parent and buildings.Parent.Parent.Parent.Name:lower() == "workspace" then
				 break
		      end
           end
           task.wait()
	       current = current.Parent -- Naik satu tingkat ke Parent-nya
       end

       Plot = current -- saya mau targetnya plot dari worspace.Plots.Plot nah jadi plotnya model dan parentnya Plots
       if Plot and Plot:IsA("Model") and Plot:FindFirstChild("Buildings") then
          PlotTargetSelect.Visible = false
          PlotTargetSelect.Active = false
       end
    end
})

PlotTargetStatus = Window:AddLabel({Text = "You need select Plot Target first", Visible = false})

CollectToggle = Window:AddToggle({
	Name = "Collect Fish",
	Value = false,
	Callback = function(value)
		CollectEnabled = value
		AutoCollect()
	end
})

Window:AddToggle({
	Name = "Auto Sell",
	Value = false,
	Callback = function(value)
		SellEnabled = value
		AutoSell()
	end
})

Window:AddLabel("YouTube: Crokyreo")
