local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/Sampluy/init.luau"))()

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer.PlayerGui

local EatEnabled,RebirtEnabled=false,false
local Rebirthing=nil

local Window = UI:CreateWindow({
  Name = "Get Fat to Break Tape",
  Destroying=function()
     if Rebirthing then Rebirthing:Disconnect() Rebirthing=nil end
     EatEnabled,RebirtEnabled=false,false
  end
}) 


Window:AddToggle({
  Name = "Auto Eat", 
  Value = false,
  Callback = function(value)
     EatEnabled=value
     if value then
        task.spawn(function()
           while EatEnabled do
              task.wait()
              local Event=ReplicatedStorage.Remote.Event.Eat.PlayerTryClickRE
              Event:FireServer(true)
           end
        end)
     end
  end
})

Window:AddToggle({
	Name = "Auto Rebirth", 
	Value = false,
	Callback = function(value)
       RebirthEnabled=value
       if Rebirthing then Rebirthing:Disconnect() Rebirthing=nil end
       if value then
          local Event = ReplicatedStorage.Remote.Event.Rebirth.TryRebirth
 
          local fill=PlayerGui.Main.Rebirth.Main["progress bar"]["01"]["02"]
          if fill.Size.X.Scale>=1 then
             Event:FireServer()
          end
           
          Rebirthing=fill:GetPropertyChangedSignal("Size"):Connect(function()
             if fill.Size.X.Scale>=1 and RebirthEnabled then
                Event:FireServer()
             end
          end)
       end
	end
})

Window:AddLabel({Name="YouTube: Crokyreo"})
