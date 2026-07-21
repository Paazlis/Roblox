local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local UpgradeTypes, UpgradeActives = {"WalkSpeed", "PaintTank", "RollerSize", "WorkerSpeed", "RollLuck", "RollSpeed", "BuyWorker"}, {}
local Enableds, Connections = {["Paint"] = false, ["Upgrade"] = false, ["Rebirth"] = false}, {}
local Keysteps = {}
local Packets = {["PaintInput"] = nil, ["RequestBuyUpgrade"] = nil, ["RequestBuyWorker"] = nil}
local RebirtFrame = PlayerGui:QueryDescendants("#GameUI > #Frames > #Rebirth")[1]

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function IsFillFull(fill)
	if fill.Size.X.Scale >= 1 then
		return true
	end
	return false
end

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

local Plot = GetPlot()
local ItemFolder = nil

for _, mode in ipairs(UpgradeTypes) do
	UpgradeActives[mode] = false
end

local Window = UI:CreateWindow({
	Name = "Crunch My Butter",
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
	Text = "Auto Paint",
	Value = false,
	Flag = "paint_enabled",
	Callback = function(value)
		Enableds.Paint = value
		
		if value then 
			ItemFolder = ItemFolder or Plot:FindFirstChild("Items")
			Packets.PaintInput = Packets.PaintInput or ReplicatedStorage:QueryDescendants("#Events > #PaintInput")[1]
			
			local Keysteps = {}
			
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
			
			Connections["ItemKeystepAdded"] = ItemFolder.ChildAdded:Connect(function(item)
				
			end)

			task.spawn(function()
				while Enableds.Paint do
					for _, item in ipairs(ItemFolder:GetChildren()) do
						task.wait()
						if not Enableds.Paint then break end
						
						local objectFolder = item:FindFirstChild("Objects")
						if not objectFolder then continue end
						
						--for _, keystep in ipairs(objectFolder:GetChildren()) do
						--	task.wait()
						--	if not Enableds.Paint then break end

						--	if keystep:IsA("Model") then
						--		Packets.PaintInput:FireServer({keystep})
						--	end
						--end
						
						Packets.PaintInput:FireServer(objectFolder:GetChildren())
					end
					
					task.wait(0.5)
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
	Flag = "upgrade_enabled",
	Callback = function(value)
		Enableds.Upgrade = value
		if value then
			Packets.RequestBuyUpgrade = Packets.RequestBuyUpgrade or ReplicatedStorage:QueryDescendants("#Events > #RequestBuyUpgrade")[1]
			Packets.RequestBuyWorker = Packets.RequestBuyWorker or ReplicatedStorage:QueryDescendants("#Events > #RequestBuyWorker")[1]

			task.spawn(function()	
				while Enableds.Upgrade do
					task.wait(0.5)
					for mode, active in pairs(UpgradeActives) do
						if not Enableds.Upgrade then break end
						if active then
							if mode == "BuyWorker" then
								Packets.RequestBuyWorker:InvokeServer()
							else
								Packets.RequestBuyUpgrade:InvokeServer(mode)
							end
						end
					end
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		if Connections["Rebirth"] then Connections["Rebirth"]:Disconnect() Connections["Rebirth"] = nil end
		if value then
			local rebirthButton = RebirtFrame:FindFirstChild("Rebirth")
			local rebirthFill = RebirtFrame:QueryDescendants("#Progress > #Fill")[1]
			
			Connections["Rebirth"] = rebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
				if IsFillFull(rebirthFill) then
					FireButton(rebirthButton)
				end
			end)
			
			if IsFillFull(rebirthFill) then
				FireButton(rebirthButton)
			end
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
