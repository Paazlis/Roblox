local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Utility/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Model, Spots = nil, nil

local Window = UI:CreateWindow({
  Name = "Build A Skyscraper"
}) 

Window:AddToggle({
  Text = "Auto Building", 
  Value = false,
  Callback = function(value)
	   
  end
})

Window:AddToggle({
	Text = "Auto Collect", 
	Value = false,
	Callback = function(value)
       getgenv().AutoCollect=value
       if value then
          while getgenv().AutoCollect do
             task.wait(1)
             for i,v in ipairs(Spots:GetChildren()) do
                local index=v:GetAttribute("Index")
                if not index then continue end
                ReplicatedStorage.Shared.Network.Remotes.Plot.Collect:FireServer(index)
             end
          end
       end
	end
})

Window:AddToggle({
	Text = "Auto Rebirth", 
	Value = false,
	Callback = function(value) 
       getgenv().AutoRebirth=value
       if value then
          while getgenv().AutoRebirth do
             task.wait(5)
             firesignal(PlayerGui.Windows.Rebirth.Buttons.Rebirth.ImageButton.Activated)
	      end
       end
    end
})

Window:AddToggle({
	Text = "Auto Buy Crane", 
	Value = false,
	Callback = function(value) 
       getgenv().AutoBuyCrane=value
       if value then
          while getgenv().AutoBuyCrane do
             task.wait(5)
             for i,v in ipairs(PlayerGui.Windows.Cranes.Cranes:GetChildren()) do
if v.ClassName=="Frame" and v.Frame.Buttons.Currency.Visible==true then
firesignal(v.Frame.Buttons.Currency.ImageButton.Activated)
task.wait(1)
end end
	      end
       end
    end
})

Model=workspace.Plots[tostring(LocalPlayer.UserId)]
Spots=Model.Spots

Window:AddLabel("YouTube: Crokyreo")
