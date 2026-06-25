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
local luggages = Workspace.WorkspaceScriptable.Storage.NormalStorage.LuggageOpenWorkspace
local luggageAssets = ReplicatedStorage.Resources.LuggageAssets

local activeESPs = {} 

local function unespNpc(npc)
   local humanoid=npc:FindFirstChildOfClass("Humanoid")
   if humanoid and humanoid.DisplayDistanceType=="Viewer" then 
      humanoid.DisplayDistanceType="Subject"
   end
end

local function unespLuggage(child)
   if activeESPs[child] then
      activeESPs[child]:Destroy()
      activeESPs[child] = nil
   end
end

local Window = UI:CreateWindow({Name="Secure the Airport",Destroying=function()
    ESPNPCEnabled=false
    if npcAdded then npcAdded:Disconnect() npcAdded=nil end
    for i,v in ipairs(npcs:GetChildren()) do unespNpc(v) end
    ESPLuggageEnabled = false
    if luggageAdded then luggageAdded:Disconnect() luggageAdded = nil end
    if luggageRemoved then luggageRemoved:Disconnect() luggageRemoved = nil end
    for i, v in ipairs(luggages:GetChildren()) do unespLuggage(v) end
end})

local ParentGui = Window.Gui

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

local function espLuggage(child)
   if activeESPs[child] then return end

   local denied = false
   local textToShow = "⚠️ Contraband" -- Teks default jika terdeteksi aman/bahaya

   for i, item in ipairs(child:GetChildren()) do
      local lowerName = string.lower(item.Name)

      for j, str in ipairs({"lotsofcontraband", "bomb"}) do
         if string.find(lowerName, str) then
            denied = true
            if str == "bomb" then textToShow = "💣 BOMB!" end
            break
         end
      end
      
      if denied then break end

      if string.find(lowerName, "set") then  
         local contraband = item:FindFirstChild("Contraband")
         if contraband and contraband.Transparency <= 0 then
            denied = true
            break
         end
      end
   end

   if denied and ESPLuggageEnabled then
      -- Membuat BillboardGui (Wadah teks)
      local billboard = Instance.new("BillboardGui")
      billboard.Name = "LuggageTextESP"
      billboard.Size = UDim2.new(0, 150, 0, 30)
      billboard.AlwaysOnTop = true -- Agar tembus pandang melewati dinding
      billboard.StudsOffset = Vector3.new(0, 2, 0) -- Posisi teks (2 stud di atas koper)
      
      -- Menghubungkan teks ke koper tanpa memasukkannya ke dalam koper tersebut
      billboard.Adornee = child.PrimaryPart or child:FindFirstChildOfClass("Part") or child
      
      -- Membuat TextLabel (Teksnya)
      local label = Instance.new("TextLabel")
      label.Parent = billboard
      label.Size = UDim2.new(1, 0, 1, 0)
      label.BackgroundTransparency = 1 -- Menghilangkan background kotak
      label.Text = textToShow
      label.TextColor3 = Color3.fromRGB(255, 30, 30) -- Warna teks merah terang
      label.TextSize = 14
      label.Font = Enum.Font.SourceSansBold
      
      -- Menambahkan stroke/garis tepi hitam agar teks jelas di tempat gelap/terang
      label.TextStrokeTransparency = 0
      label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

      -- Taruh di CoreGui agar TIDAK terdeteksi oleh script lokal game
      billboard.Parent = ParentGui

      -- Simpan ke tabel tracker
      activeESPs[child] = billboard
   end
end

Window:AddToggle("ESP Luggage", false, function(value)
    ESPLuggageEnabled = value
    
    if luggageAdded then luggageAdded:Disconnect() luggageAdded = nil end
    if luggageRemoved then luggageRemoved:Disconnect() luggageRemoved = nil end
    
    if value then
       luggageAdded = luggages.ChildAdded:Connect(espLuggage)
       luggageRemoved = luggages.ChildRemoved:Connect(unespLuggage)
       
       for i, v in ipairs(luggages:GetChildren()) do espLuggage(v) end
    else
       for i, v in ipairs(luggages:GetChildren()) do unespLuggage(v) end
    end
end)


Window:AddLabel("YouTube: Crokyreo")

-- m9, condor, Contraband, workspace.WorkspaceScriptable.Storage.NormalStorage.LuggageOpenWorkspace
