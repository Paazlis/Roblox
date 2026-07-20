local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local UpgradeTypes, UpgradeActives = {"WalkSpeed", "PaintTank", "RollerSize", "WorkerSpeed", "RollLuck", "RollSpeed", "BuyWorker"}, {}
local Enableds, Connections = {["Step"] = false, ["Upgrade"] = false}, {}
local Keysteps = {}
local Packets = {
	["PaintInput"] = ReplicatedStorage:QueryDescendants("#Events > #PaintInput")[1],
	["RequestBuyUpgrade"] = ReplicatedStorage:QueryDescendants("#Events > #RequestBuyUpgrade")[1],
	["RequestBuyWorker"] = ReplicatedStorage:QueryDescendants("#Events > #RequestBuyWorker")[1]
}

local function GetPlot()
	local plots = workspace:QueryDescendants("#Map > #Plots")[1]
	if not plots or plots.Name~="Plots" then return nil end

	for _, plot in ipairs(plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId ~= nil and ownerId == LocalPlayer.UserId then
			return plot
		elseif plot.Name:find(tostring(LocalPlayer.UserId)) then
			return plot
		end
	end

	return nil
end

Connections["CharacterAdded"] = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local Plot = GetPlot()
local ItemFolder = nil

for _, mode in ipairs(UpgradeTypes) do
	UpgradeActives[mode] = false
end

local Window = UI:CreateWindow({
	Name = "My Fishing Empire",
	Destroying = function()
		for key, value in pairs(Connections) do
			if value then
				value:Disconnect()
			end
		end

		for key, value in pairs(Enableds) do
			Enableds[key] = false
		end
		
		for _, mode in ipairs(UpgradeTypes) do
			UpgradeActives[mode] = false
		end
	end
})

Window:AddToggle({
	Text = "Auto Step",
	Value = false,
	Flag = "step_enabled",
	Callback = function(value)
		Enableds.Step = value
		
		if value then 
			ItemFolder = ItemFolder or Plot:FindFirstChild("Items")
			
			--if not Connections["ItemConnections"] then
			--	Connections["ItemConnections"] = {}
			--end
			
			--local function OnItemKeystepAdded(item:Instance)
			--	if tonumber(item.Name) then
			--		local objectFolder = item:WaitForChild("Objects", 5)
			--		if not objectFolder then return end

			--		table.insert()
			--	end
			--end
			
			--Connections["ItemKeystepAdded"] = ItemFolder.ChildAdded:Connect(function(item)
				
			--end)

			task.spawn(function()
				while Enableds.Step do
					for _, item in ipairs(ItemFolder:GetChildren()) do
						task.wait()
						if not Enableds.Step then break end
						
						local objectFolder = item:FindFirstChild("Objects")
						if not objectFolder then continue end
						
						for _, keystep in ipairs(objectFolder:GetChildren()) do
							task.wait()
							if not Enableds.Step then break end
							
							if keystep:IsA("Model") then
								Packets["PaintInput"]:FireServer({keystep})
							end
						end
					end
					
					task.wait(1)
				end
			end)
		end
	end
})

Window:AddDropdown({
	Text = "Upgrade Type",
	Options = UpgradeTypes,
	Option = nil,
	MultipleOptions = true,
	Flag = "upgrade_options",
	Callback = function(option)
		for _, mode in ipairs(UpgradeTypes) do
			UpgradeActives[mode] = table.find(option, mode) ~= nil and true or false
		end
	end
})

Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Callback = function(value)
		Enableds.Upgrade = value
		if value then
			task.spawn(function()
				while Enableds.Upgrade do
					task.wait(1)
					for mode, active in pairs(UpgradeActives) do
						if not Enableds.Upgrade then break end
						if active then
							if mode == "BuyWorker" then
								Packets["RequestBuyWorker"]:InvokeServer()
							else
								Packets["RequestBuyUpgrade"]:InvokeServer(mode)
							end
						end
					end
				end
			end)
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
