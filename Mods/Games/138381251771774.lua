local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Farming = false
local ChestDebounce = false

local function IsFillFull()
	if PlayerGui.Interface.Holder.BucketFill.Bar.Scale.Size.X.Scale >= 1 then
		return true
	end
	return false
end

local Window = UI:CreateWindow({
	Name = "Drain the Lake",
	Destroying = function()
		Farming = false
	end
})

Window:AddToggle({
	Text = "Auto Drain", 
	Value = false, 
	Callback = function(value)
		Farming = value
		if value then
			task.spawn(function()
				while Farming do
					task.wait(0.1)
					if not IsFillFull() and Farming then
						ReplicatedStorage.VerdantRemotes["VDT_Bucket.Used"]:FireServer()
					end
				end
			end)
		end
	end
})

Window:AddButton({
	Text = "Claim All Chest",
	MethodType = "DoubleClick",
	ClickThreshold = 0.5,
	MaxClick = 2,
    Callback = function()
		if ChestDebounce then return end
		ChestDebounce = true
		local pass = false
		local character = LocalPlayer.Character
		local saveCFrame = character.PrimaryPart.CFrame
		for _, chest in ipairs(workspace.Scripted.Chests:GetChildren()) do
			local part = chest:FindFirstChild("Part")
		    if part then
			   local prompt = part:FindFirstChildOfClass("ProximityPrompt")
			   if prompt and prompt.Enabled then
				   task.wait()
				   if character and character.Parent and part:IsA("BasePart") then
						character:PivotTo(part.CFrame)
				   end
				   task.wait(0.5)
		           ReplicatedStorage.VerdantRemotes["VDT_Chest.Open"]:FireServer(part)
				   pass = true
				end
			end
		end
		if character and character.Parent and pass then
		   character:PivotTo(saveCFrame)
		end
		ChestDebounce = false
	end
})

-- Window:AddLabel("YouTube: Crokyreo")
