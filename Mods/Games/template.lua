local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Instancer = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Instancer/init.luau"))()
local Executier = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Executier/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

local function FireTouch(hit, target)
    if firetouchinterset then
        firetouchinterset(hit, target, true)
        task.wait()
        firetouchinterset(hit, target, false)
    end
end

local function FireButton(button)
    if firesignal then
        firesignal(button.Activated)
        firesignal(button.MouseButton1Click)
    end
end

local Window = UI:CreateWindow({
	  Name = "Your Title",
	  Destroying = function()
		    print("cleanup")
	  end
})

local Toggle = Window:AddToggle({
	  Text = "Toggle",
    Value = false,
	  Flag = "toggle",
	  Callback = function(value)
      	print(value)
  	end
})

local Slider = Window:AddSlider({
	  Text = "Fov",
    Value = 10,
	  Range = {70,170},
	  Increment = 0.1,
    Flag = "slider",
	  Callback = function(value)
      	print("Fov:",value)
    end
})

Window:AddLabel("YouTube: Crokyreo")
