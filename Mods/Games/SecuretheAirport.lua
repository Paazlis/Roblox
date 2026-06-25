-- Load UI Library
local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau", true))()

-- Get Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer


local npcs=Workspace.WorkspaceScriptable.Storage.NormalStorage.NPCWorkspace
local realItem=ReplicatedStorage.Resources.NPCAssets.Items.RealContraband
local ESPNPCEnabled,npcAdded=false,nil

local unespNpc(npc)
   local humanoid=npc:FindFirstChildOfClass("Humanoid")
   if humanoid and humanoid.DisplayDistanceType=="Viewer" then 
      humanoid.DisplayDistanceType="Subject"
   end
end

local Window = UI:CreateWindow({Name="Secure the Airport",Destroying=function()
    ESPNPCEnabled=false
    if npcAdded then npcAdded:Disconnect() npcAdded=nil end
    for i,v in ipairs(npcs:GetChildren()) do unespNpc(v) end
end})


function espNpc(npc)
    local xrayVisible=npc.XrayVisible
      
    local bans={}
    for i,item in ipairs(xrayVisible:GetChildren()) do
       for j,object in ipairs(realItem:GetChildren()) do
           if string.find(item.Name,object.Name) then
              table.insert(bans,item)
              break
           end
        end
     end
  
     if #bans > 0 and ESPNPCEnabled then
        local humanoid=npc:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.DisplayDistanceType="Viewer" end
     end
  
     table.clear(bans)
end



Window:AddToggle("ESP NPC",true,function(value)
    ESPNPCEnabled=value
    if npcAdded then npcAdded:Disconnect() npcAdded=nil end
    if value then
       npcAdded=npcs.ChildAdded:Connect(espNpc)
       for i,v in ipairs(npcs:GetChildren()) do espNpc(v) end
    else
       for i,v in ipairs(npcs:GetChildren()) do unespNpc(v) end
    end
end)

Window:AddToggle("ESP Luggage",true,function(value)

end)

Window:AddLabel("YouTube: Crokyreo")

-- m9, condor, Contraband, workspace.WorkspaceScriptable.Storage.NormalStorage.LuggageOpenWorkspace
