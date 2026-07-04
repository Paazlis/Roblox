local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Utility/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager = Services.VirtualInputManager
local UserInputService = Services.UserInputService

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer.PlayerGui

local UpgradeEnabled, AttackEnabled = false, false
local NpcAddedConnection, NpcRemovedConnection = nil, nil
local ClickPoint=UserInputService:GetMouseLocation()
local NpcActives = {}

local function GetPlot()
	local plots = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Plots")
	if not plots then return nil end

	for _, base in pairs(plots:GetChildren()) do
		local owner = base:GetAttribute("Owner")
		if owner and LocalPlayer.Name then
			 return base
		end
	end

	return nil
end

local Plot = GetPlot()

-- Train Function --
local function AutoUpgrade()
	if UpgradeEnabled then
		task.spawn(function()
			while UpgradeEnabled do
				 task.wait(1)
				 Plot = Plot or GetPlot()
         if Plot then
            local structures = Plot.Main.Plot.Structures
            for _, structure in ipairs(structures:GetChildren()) do
                ReplicatedStorage.Remotes.Plot.Building:InvokeServer("UpgradeStructure", structure.Name)
            end
            task.wait(1)
            ReplicatedStorage.Remotes.Plot.UpgradeKing:InvokeServer()
         end
			end
		end)
	end
end

-- Attack Function --
local function AutoAttack()
   NpcAddedConnection = Utility.Cleanup(NpcAddedConnection)
   NpcRemovedConnection = Utility.Cleanup(NpcRemovedConnection)
  
	 if AttackEnabled then
      Plot = Plot or GetPlot()
      if not Plot then break end
    
      local npcs = Plot.Npcs
    
      NpcAddedConnection = npcs.ChildAdded:Connect(function(v)
         NpcActives[v] = v
      end

      NpcRemovedConnection = npcs.RwmovedAdded:Connect(function(v)
         NpcActives[v] = nil
      end
        
      task.spawn(function() 
          while AttackEnabled do
             task wait(0.5)
             
             for k, v in pairs(NpcActives) do
                 LocalPlayer.Character:MoveTo(v.PrimaryPart)
             end
          end
      end)
      
      task.spawn(function()
          local sword = nil
          while AttackEnabled do
             task.wait(1)
             local character = LocalPlayer.Character
             if character then
                if not sword or sword.Parent ~= character then
                   for _, tool in ipairs(character:GetChildren()) do
                       if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                          sword = tool
                          break
                       end
                    end
                end
                if sword and sword.Parent == character then
                   firesignal(sword.Activated)
                end
             end
          end
      end)
	 end
end

-- Main UI --
local Window = UI:CreateWindow({
	Name = "Build a Slime Defense", 
	Destroying = function()
		 UpgradeEnabled, AttackEnabled = false, false
		 NpcAddedConnection = Utility.Cleanup(NpcAddedConnection)
     NpcRemovedConnection = Utility.Cleanup(NpcRemovedConnection)
	end
})

Window:AddToggle({
	Name = "Auto Attack",
	Value = false,
	Callback = function(value)
		AttackEnabled = value
		AutoAttack()
	end
})

Window:AddToggle({
	Name = "Auto Upgrade",
	Value = false,
	Callback = function(value)
		UpgradeEnabled = value
		AutoUpgrade()
	end
})

Window:AddLabel("YouTube: Crokyreo")
