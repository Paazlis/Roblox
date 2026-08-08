
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

local Enableds, Connections, Packets = {Aim = false, Upgrade = false, Sell = false, Shoot = false}, {}, {}
local AimSettings = {Speed = 0.8}

local DummyFolder = nil

local UpgradeTypes, UpgradeActives, UpgradeInfos, UpgradeOption = {}, {}, {}, {}
UpgradeActives["AllEnabled"] = true

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local WeaponCache = {}

local function WeaponAdded(weapon)
   if weapon and weapon.Parent and weapon.Name:find("_Orbit_" .. tostring(LocalPlayer.UserId)) ~= nil and WeaponCache[child] == nil  then
         local newName = string.gsub(weapon.Name, "_Orbit_%d+", "")
        
         WeaponCache[weapon] = newName

        local ancestryChanged = nil
        ancestryChanged = weapon.AncestryChanged:Connect(function(_, parent)
            if not parent or not weapon:IsDescendantOf(workspace) then
               WeaponCache[weapon] = nil
               ancestryChanged:Disconnect()
            end
        end)
    end
end

local function HandleShoot()
  if Connections.WeaponAdded then Connections.WeaponAdded:Disconnect() Connections.WeaponAdded = nil end
  if not Enableds.Shoot then return end

  Packets.DummyShoot = Packets.DummyShoot or ReplicatedStorage.Remotes.DummyShoot
  DummyFolder = DummyFolder or workspace:QueryDescendants("#PlayerDummies > #Shared")[1]
  
  Connections.WeaponAdded = workspace.ChildAdded:Connect(function(weapon)
      task.wait(2)
      WeaponAdded(weapon)
  end)
  
  for _, weapon in ipairs(workspace:GetChildren()) do
     WeaponAdded(weapon)
  end
  
	task.spawn(function()
		while Enableds.Shoot do
           for _, dummy in ipairs(DummyFolder:GetChildren()) do
              if not (dummy and dummy.Parent) then continue end
              local humanoid = dummy:FindFirstChildOfClass("Humanoid")
              if not humanoid or humanoid.Health <= 0 or humanoid.MaxHealth <= 0 then continue end
              if not next(WeaponCache) then break end
              repeat 
                 for _, weaponName in pairs(WeaponCache) do
					if not (dummy and dummy.Parent) then break end
                    Packets.DummyShoot:FireServer(dummy, weaponName)
                    task.wait()
                 end
                 task.wait(0.1)
              until not dummy.Parent or not humanoid.Parent or humanoid.Health <= 0 or humanoid.MaxHealth <= 0 or not next(WeaponCache)
              task.wait()
           end
           task.wait(5)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Roll to Survive",
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end

		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end
	end
})

Window:AddToggle({
	Text = "Auto Shoot",
	Value = false,
	Flag = "shoot_enabled",
	Callback = function(value)
		Enableds.Shoot = value
		HandleShoot()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-07-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
