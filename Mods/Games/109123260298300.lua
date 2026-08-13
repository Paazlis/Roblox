local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
--local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Breakables = workspace:FindFirstChild("Breakables")

local Enableds, Connections = {["Breakable"] = false}, {}
local Packets = {
	HitBreakables = ReplicatedStorage:QueryDescendants("#Assets > #Events > #HitBreakables > #RemoteEvent")[1]
}

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function HandleBreakable()
  -- if not Enableds.Breakable then return end
   for _, model in ipairs(Breakables:GetChildren()) do
      if model and model.Parent then
		  local part = model.PrimaryPart or model:FindFirstChildOfClass("BasePart") or model:GetPivot()
		  Character:PivotTo(CFrame.new(part.Position))
		  task.wait(0.2)
          local id = model.Name
          Packets.HitBreakables:FireServer({{
              Slot = i, BreakableId = id
          }})
      end
   end
end

local Window = UI:CreateWindow({
	Name = "RNG vs Fruit", 
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

Window:AddButton({
    Text = "Auto Breakable",
    Callback = HandleBreakable
})
