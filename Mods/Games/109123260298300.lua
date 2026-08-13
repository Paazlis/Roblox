local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
--local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
--local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Breakables = workspace:FindFirstChild("Breakables")

local Enableds, Connections = {["Breakable"] = false}, {}
local Packets = {
	HitBreakables = ReplicatedStorage:QueryDescendants("#Assets > #Events > #HitBreakables > #RemoteEvent")[1]
}

local function HandleBreakable()
  -- if not Enableds.Breakable then return end
   for _, child in ipairs(Breakables:GetChildren()) do
      if child and child.Parent then
          local id = child.Name
          for i = 1, 2 do
			Packets.HitBreakables:FireServer({{
              Slot = i, BreakableId = id
            }})
			task.wait(0.1)
          end
          task.wait(0.5)
		  if child.Parent then
			 warn("gagal")
			 LocalPlayer.Character:PivotTo(CFrame.new(child.Position))
		  end
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
