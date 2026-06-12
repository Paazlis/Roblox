local Services=setmetatable({},{
	__index=function(_,i) 
		return cloneref and cloneref(game:GetService(i)) or game:GetService(i) 
	end
})

local UI=loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local KeySystem=UI:CreateKeySystem({
	Title="Fish a Slime",
	Description="Key System",
	UseNonce=true,
	FileName="FishASlimeKey",
	FolderName="Rayfield",
	ServiceId=24751,
	PlatoSecret="4ce8695c-5918-4704-a778-786e74424a0e",
	Secret="MASWA_awjw761!82t6N187h2`ub94y-h",
	ShowScript=false,
	ShowYoutube=true,
	YoutubeURL="https://www.youtube.com/@Crokyreo?sub_confirmation=1",
	Name="Fish A Slime Key"
})

KeySystem:WaitForKey()
if not KeySystem.Pass then return end
KeySystem:Destroy()

-- Local state control (Replaced _G)
local autoEquipEnabled=false
local autoClaimEnabled=false

local Window=UI:CreateWindow({
	Name="Fish a Slime",
	Destroying=function()
		autoEquipEnabled=false
		autoClaimEnabled=false
	end
})

-- Mutation Multipliers
local Mutations={
	["Normal"]=1,
	["Frozen"]=1.2,["Poison"]=1.2,["Electric"]=1.3,["Rainbow"]=1.3,
	["Lightning"]=1.4,["Spooky"]=1.4,["Magma"]=1.5,["Shadow"]=2,
	["Cosmic"]=2.5,["Blood"]=2.5,["Burnt"]=2,["Planetary"]=2,
	["Blue Blood"]=3,
}

local Players=Services.Players
local ReplicatedStorage= Services.ReplicatedStorage
local LocalPlayer=Players.LocalPlayer

-- Remotes setup
local Remotes=ReplicatedStorage:FindFirstChild("Remotes")
local PlaceEvent=Remotes and Remotes:FindFirstChild("Place")
local PickupEvent=Remotes and  Remotes:FindFirstChild("PickupMob")
local ClaimEvent=Remotes and Remotes:FindFirstChild("Claim")

local MyPlot=nil

-- Calculate tool power score (Works on both Tools and Workspace Models)
local function getToolScore(instance)
	if not instance then return -1 end
	local level=instance:GetAttribute("Level") or 1
	local mutation=instance:GetAttribute("Mutation")
	local mutationMult=Mutations[mutation] or 1
	return level * mutationMult
end

-- Find your plot strictly ordered from 1 upwards
local function getMyPlot()
	local plots=workspace:FindFirstChild("Plots")
	if plots then
		for _,plot in ipairs(plots:GetChildren()) do
			local ownerId=tonumber(plot:GetAttribute("Owner"))
			if ownerId and ownerId == LocalPlayer.UserId then
				return plot
			end
		end
	end
	return nil
end


local function getEmptySlot()
	MyPlot=MyPlot or getMyPlot()
	if not MyPlot then return end

	local occupiedSlots={}

	local placedHolder=MyPlot:FindFirstChild("PlacedHolder")
	if placedHolder then
		for _,model in ipairs(placedHolder:GetChildren()) do
			if model:IsA("Model") then
				local slotValue=model:FindFirstChild("slotValue")
				if slotValue and slotValue:IsA("ValueBase") then
					occupiedSlots[tostring(slotValue.Value)]=true
				end
			end
		end
	end

	local slotsFolder=MyPlot:FindFirstChild("Slots")
	if slotsFolder then
		local slots={}
		
		for _,slot in ipairs(slotsFolder:GetChildren()) do
			if tonumber(slot.Name) and not occupiedSlots[slot.Name] then
				table.insert(slots,slot)
			end
		end

		table.sort(slots,function(a,b)
			return tonumber(a.Name)<tonumber(b.Name)
		end)
		
		for _,slot in ipairs(slots) do
			if not occupiedSlots[slot.Name] then
				return tonumber(slot.Name)
			end
		end
	end

	return nil
end

-- Main automation manager
local function autoEquip()
	MyPlot=MyPlot or getMyPlot()
	if not MyPlot then return end

	local bestTool=nil
	local highestScore=-1
	local bestLocation="" -- Tracked as: "Backpack","Character",or "Plot"

	-- 1. Scan Backpack
	for _,item in ipairs(LocalPlayer.Backpack:GetChildren()) do
		if item:IsA("Tool") and item.Name~="Gym" then
			local score=getToolScore(item)
			if score > highestScore then
				highestScore=score
				bestTool=item
				bestLocation="Backpack"
			end
		end
	end

	-- 2. Scan Character (Currently equipped)
	if LocalPlayer.Character then
		for _,item in ipairs(LocalPlayer.Character:GetChildren()) do
			if item:IsA("Tool") and item.Name~="Gym" then
				local score=getToolScore(item)
				if score > highestScore then
					highestScore=score
					bestTool=item
					bestLocation="Character"
				end
			end
		end
	end

	-- 3. Scan PlacedHolder on your plot (Check if a better tool is deployed)
	local placedHolder=MyPlot:FindFirstChild("PlacedHolder")
	if placedHolder then
		for _,model in ipairs(placedHolder:GetChildren()) do
			local score=getToolScore(model)
			if score > highestScore then
				highestScore=score
				bestTool=model
				bestLocation="Plot"
			end
		end
	end

	-- If no tools are found anywhere,stop here
	if highestScore == -1 or not bestTool then return end

	-- Action Phase: Retrieve the tool if it's on the plot
	if bestLocation == "Plot" then
		if PickupEvent then
			print("Found a superior slime in PlacedHolder. Picking up instance: " .. bestTool.Name)

			-- FIXED: Passes the Instance model directly to the server remote
			PickupEvent:InvokeServer(bestTool) 
			task.wait(0.3) -- Brief pause to allow inventory replication

			-- Re-verify tool inside backpack after picking it up
			for _,item in ipairs(LocalPlayer.Backpack:GetChildren()) do
				if item:IsA("Tool") and getToolScore(item) >= highestScore then
					bestTool=item
					bestLocation="Backpack"
					break
				end
			end
		else
			return
		end
	end

	-- Action Phase: Equip the tool to your character
	if (bestLocation == "Backpack" or bestTool.Parent == LocalPlayer.Backpack) and LocalPlayer.Character then
		local humanoid=LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:UnequipTools()
			humanoid:EquipTool(bestTool)
			task.wait(0.1)
			
			local targetSlot=getEmptySlot()

			-- Fire the Cobalt placement remote
			if PlaceEvent and targetSlot then
				PlaceEvent:InvokeServer(targetSlot)
				print("Successfully equipped and placed the best slime: " .. bestTool.Name .. " (Score: " .. highestScore .. ")")
			end
		end

		
	end
end

local function autoClaim()
	MyPlot=MyPlot or getMyPlot()
	if not MyPlot then return end

	local placedHolder=MyPlot:FindFirstChild("PlacedHolder")
	if placedHolder then
		for _,model in ipairs(placedHolder:GetChildren()) do
			if model:IsA("Model") then
				local slotValueObj=model:FindFirstChild("slotValue")
				if slotValueObj and slotValueObj:IsA("ValueBase") then
					if ClaimEvent then
						ClaimEvent:InvokeServer(slotValueObj.Value)
					end
				end
			end
		end
	end
end

Window:AddButton({
	Name="Teleport",
	Callback=function(value)
		LocalPlayer.Character:MoveTo(Vector3.new(-879,304,20))
	end
})

-- UI Toggle Setup
Window:AddToggle({
	Name="Equip Best",
	Callback=function(value)
		autoEquipEnabled=value

		if autoEquipEnabled then
			task.spawn(function()
				while autoEquipEnabled do
					autoEquip()
					task.wait(5) -- 5-second interval loop
				end
			end)
		end
	end
})


Window:AddToggle({
	Name="Collect Cash",
	Callback=function(value)
		autoClaimEnabled=value

		if autoClaimEnabled then
			task.spawn(function()
				while autoClaimEnabled do
					autoClaim()
					task.wait(1)
				end
			end)
		end
	end
})


Window:AddLabel({
	Name="YouTube: Crokyreo"
})
