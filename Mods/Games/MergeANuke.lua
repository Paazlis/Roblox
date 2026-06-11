local UI=loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local basesFolder = workspace:WaitForChild("Bases")

getgenv().CollectNukeEnabled = false

local Window=UI:CreateWindow({Name="Merge a Nuke"})

Window:AddToggle({Name="Collect Nuke", Callback=function(value)
getgenv().CollectNukeEnabled = value
})
      
local function getMyBase()
 local allBases = basesFolder:GetChildren()
 for _, base in ipairs(allBases) do
  local ownerId = base:GetAttribute("OwnerUserId")
  if ownerId == localPlayer.UserId then
   return base
  end
 end
 return nil
end

task.spawn(function()
while getgenv().CollectNukeEnabled do
 task.wait(0.5)
	
 local myBase = getMyBase()
	
 if myBase then
  local validNukes = {}
  local nukeContainer = myBase:FindFirstChild("Nukes") or myBase
  local objects = nukeContainer:GetChildren()
  
  for _, object in ipairs(objects) do
   local tierVal = object:GetAttribute("Tier")
   if tierVal ~= nil and tonumber(tierVal) then
    table.insert(validNukes, object)
   end
  end
  
  table.sort(validNukes, function(a, b)
   return tonumber(a:GetAttribute("Tier")) < tonumber(b:GetAttribute("Tier"))
  end)
  
  local character = localPlayer.Character
  local humanoid = character and character:FindFirstChild("Humanoid")
  local hrp = character and character:FindFirstChild("HumanoidRootPart")
  
  if humanoid and hrp then
   for _, nuke in ipairs(validNukes) do
    if not getgenv().CollectNukeEnabled then break end
    
    local targetPosition = nil
    if nuke:IsA("BasePart") then
     targetPosition = nuke.Position
    elseif nuke:IsA("Model") and nuke.PrimaryPart then
     targetPosition = nuke.PrimaryPart.Position
    end
    
    if targetPosition and nuke:IsDescendantOf(workspace) then
     humanoid:MoveTo(targetPosition)
     
     while (hrp.Position - targetPosition).Magnitude > 4 and nuke:IsDescendantOf(workspace) and getgenv().CollectNukeEnabled do
      task.wait(0.1)
      humanoid:MoveTo(targetPosition)
     end
    end
   end
  end
 end
end
end)
