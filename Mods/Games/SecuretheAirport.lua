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
local ESPNPCEnabled,ESPLuggageEnabled,npcAdded,luggageAdded,luggageRemoved=false,false,nil,nil,nil

local function unespNpc(npc)
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


local function espNpc(npc)
    local xrayVisible=npc.XrayVisible
      
    local denied=false
    for i,item in ipairs(xrayVisible:GetChildren()) do
       for j,object in ipairs(realItem:GetChildren()) do
           if string.find(item.Name,object.Name) then
              denied=true
              break
           end
        end
     end
     local fakePassport=npc.Properties.RandomVariables.FakePassport
     if fakePassport.Value then
        denied=true
     end
     if denied and ESPNPCEnabled then
        local humanoid=npc:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.DisplayDistanceType="Viewer" end
     end
end

Window:AddToggle("ESP NPC",false,function(value)
    ESPNPCEnabled=value
    if npcAdded then npcAdded:Disconnect() npcAdded=nil end
    if value then
       npcAdded=npcs.ChildAdded:Connect(espNpc)
       for i,v in ipairs(npcs:GetChildren()) do espNpc(v) end
    else
       for i,v in ipairs(npcs:GetChildren()) do unespNpc(v) end
    end
end)

local luggages=workspace.WorkspaceScriptable.Storage.NormalStorage.LuggageOpenWorkspace
local luggageAssets=ReplicatedStorage.Resources.LuggageAssets

local function espLuggage(child)
   local denied=false

   for i,item in ipairs(child:GetChildren()) do
      local lowerName=string.lower(item.Name)

      for j,str in ipairs({"lotsofcontraband","bomb"}) do
         if string.find(lowerName,str) then
            denied=true
            break
         end
      end
      
      if denied then break end

      if string.find(lowerName,"set") then  
         local contraband=item:FindFirstChild("Contraband")
         if contraband and contraband.Transparency<=0 then
            denied=true
            break
         end
      end
   end

   if denied and ESPLuggageEnabled then
      -- Add esp logic here
   end
end

local function unespLuggage(child)
   -- Add un esp logic here
end


Window:AddToggle("ESP Luggage",false,function(value)
    ESPLuggageEnabled=value
    if luggageAdded then luggageAdded:Disconnect() luggageAdded=nil end
    if value then
       luggageAdded=luggages.ChildAdded:Connect(espLuggage)
       luggageRemoved=luggages.ChildRemoved:Connect(unespLuggage)
       for i,v in ipairs(luggages:GetChildren()) do espLuggage(v) end
    else
       for i,v in ipairs(luggages:GetChildren()) do unespLuggage(v) end
    end
end)

Window:AddLabel("YouTube: Crokyreo")

-- m9, condor, Contraband, workspace.WorkspaceScriptable.Storage.NormalStorage.LuggageOpenWorkspace
