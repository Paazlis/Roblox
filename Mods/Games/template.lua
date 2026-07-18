local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Instancer = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Instancer/init.luau"))()
local Executier = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Executier/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

local YieldForChild, FindByPath, FireButton, FireTouch = Instancer.YieldForChild, Instancer.FindByPath, Executier.FireButton, Executier.FireTouch

local Window = UI:CreateWindow({
	  Name = "Your Title",
	  Destroying = function()
		    print("cleanup")
	  end
})

local Toggle = Window:AddToggle({
	  Text = "Toggle",
      Value = false,
	  Callback = function(value)
      	print(value)
  	end
})

local Slider = Window:AddSlider({
	  Text = "Fov",
      Value = 10,
	  Range = {70,170},
	  Increment = 0.1,
	  Callback = function(value)
      	print("Fov:",value)
    end
})

local Dropdown = Window:AddDropdown({
	  Text = "Fruit Type",
      Options = {"Apple", "Banana", "Avocado", "Durian"},
	  Option = nil,
	  MultipleOptions = true,
	  Callback = function(option)
      	print("Type:",table.concat(option,","))
    end
})

Window:AddLabel("YouTube: Crokyreo")
