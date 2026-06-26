-- Load UI Library
local UI=loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau", true))()

-- Get Services
local Players=game:GetService("Players")

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer.PlayerGui

local DropEnabled,RebirthEnabled,CollectCashEnabled=false,false,false

local Window=UI:CreateWindow({Name="Secure the Airport",Destroying=function()
     DropEnabled,RebirthEnabled,CollectCashEnabled=false,false,false
end})

local Plot=nil

Window:AddToggle({
    Name="Fast Drop",
    Callback=function(value)
       DropEnabled=value
       if value then
          task.spawn(function()
             while DropEnabled do
                task.wait()
                if PlayerGui.BallDrop.BottomContainer.Visible then
                   if firesignal then
                     firesignal(PlayerGui.BallDrop.BottomContainer.DropButton.Activated)
                   end
                end
             end
          end
       end
    end
})

Window:AddToggle({
    Name="Collect Cash",
    Callback=function(value)
       CollectCashEnabled=value
       if value then
          task.spawn(function()
             while CollectCashEnabled do
                task.wait(1)
                
                if not Plot then
                   for _,v in ipairs(workspace.Plots:GetChildren()) do
                      local owner=v:GetAttribute("Owner")
                      if owner~=nil and owner==LocalPlayer.Name then
                          Plot=v
                          break
                      end
                   end
                end

                if Plot then
                   local slots=Plot.Slots
                   for _,slot in ipairs(slots:GetChildren()) do
                      local collectButton=slot:FindFirstChild("CollectButton")
                      if collectButton then
                         local targetPart=collectButton:FindFirstChild("Top")
                         if targetPart and targetPart.Transparency==0 then
                            local hitPart=LocalPlayer.Character.Head
                            if firetouchinterest then
                              firetouchinterest(hitPart,targetPart,1)
                              task.wait()
                              firetouchinterest(hitPart,targetPart,0)
                            end
                         end
                      end
                   end
                end
             end
          end
       end
    end
})
    
Window:AddToggle({
    Name="Auto Rebirth",
    Callback=function(value)
       RebirthEnabled=value
       if value then
          task.spawn(function()
             while RebirthEnabled do
                firesignal(PlayerGui.Frames.Rebirth.RebirthButton.Activated)
                task.wait(5)
             end
          end
       end
    end
})

Window:AddLabel({Name="YouTube: Crokyreo"})
