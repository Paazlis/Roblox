local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/Sampluy/init.luau"))()

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local LocalPlayer=game:GetService("Players").LocalPlayer
local PlayerGui=LocalPlayer.PlayerGui
local Model, Spots = nil, nil

local Window = UI:CreateWindow({
  Name = "Build A Skyscraper"
}) 

Window:AddToggle({
  Name = "Auto Building", 
  Value = false,
  Callback = function(value)
	   
  end
})

Window:AddToggle({
	Name = "Auto Collect", 
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
	Name = "Auto Rebirth", 
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
	Name = "Auto Buy Crane", 
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
