local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Farming = false
local DrainConnection = nil
local Connections = {}
local DrainActives = {}

local function IsFillFull()
	if PlayerGui.Interface.Holder.BucketFill.Bar.Scale.Size.X.Scale >= 1 then
		return true
	end
	return false
end

local function CheckPointAdded(checkpoint)
	if checkpoint and checkpoint.Parent and tonumber(checkpoint.Name) then
		for _, model in ipairs(checkpoint:GetChildren()) do
			if model.Name:lower():find("drain") and not table.find(DrainActives, model) and model:FindFirstChild("Scripted") then
				table.insert(DrainActives, model)
				local ancestryChangedConnection
				ancestryChangedConnection = model.AncestryChanged:Connect(function(_, parent)
					if not parent then
						ancestryChangedConnection:Disconnect()

						local index1 = table.find(DrainActives, model)
						if index1 then
							table.remove(DrainActives, index1)
						end

						local index2 = table.find(Connections, ancestryChangedConnection)
						if index2 then
							table.remove(Connections, index2)
						end
					end
				end)
				table.insert(Connections, ancestryChangedConnection)
			end
		end
	end
end

local function ApplyDrains()
	local checkpoints = workspace.Scripted.CheckpointParts

	DrainConnection = checkpoints.ChildAdded:Connect(CheckPointAdded)

	for _, checkpoint in ipairs(checkpoints:GetChildren()) do
		CheckPointAdded(checkpoint)
	end
end

pcall(function()
	ApplyDrains()
	return nil
end)

local Window = UI:CreateWindow({
	Name = "Drain the Lake",
	Destroying = function()
		Farming = false
		if DrainConnection then DrainConnection:Disconnect() DrainConnection = nil end
		for _, connection in ipairs(Connections) do
			if connection then
				connection:Disconnect()   
			end
		end
		table.clear(Connections)
	end
})

Window:AddToggle({
	Text = "Auto Farming", 
	Value = false, 
	Callback = function(value)
		Farming = value
		if value then
			task.spawn(function()
				while Farming do
					if not IsFillFull() then
						ReplicatedStorage.VerdantRemotes["VDT_Bucket.Used"]:FireServer()
					end
					for i = #DrainActives, 1, -1 do
						local drain = DrainActives[i]
						if drain and drain.Parent then
							task.wait()
									
							local scripted = drain.Scripted
							local drainPrompt = scripted.ProximityPosition.ProximityPrompt
							local tokensPrompt = scripted.TakeTokens.ProximityPrompt
										
							if tokensPrompt and drainPrompt and tokensPrompt.Enabled and Farming then
                                ReplicatedStorage.VerdantRemotes["VDT_Tokens.Take"]:FireServer(drainPrompt)
								task.wait(1)
							end
								
							if drainPrompt and drainPrompt.Enabled and IsFillFull() and Farming then
								ReplicatedStorage.VerdantRemotes["VDT_Bucket.Poured"]:FireServer(drainPrompt)
							end
						end
							
					end
							
					task.wait(0.5)
				end
			end)
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")

--[[
-- Drain Machine --
game:GetService("ReplicatedStorage").VerdantRemotes["VDT_Bucket.Poured"]:FireServer(
    workspace.Scripted.CheckpointParts["1"]:GetChildren()[3].Scripted.ProximityPosition.ProximityPrompt
)

 local Event = game:GetService("ReplicatedStorage").VerdantRemotes["VDT_Tokens.Take"]
Event:FireServer(workspace.Scripted.CheckpointParts["1"]:GetChildren()[3].Scripted.ProximityPosition.ProximityPrompt)
]]
