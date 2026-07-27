local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager=Services.VirtualInputManager

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local ClaimTypes, ClaimObjects, ClaimActives = {"Speed", "Stamina"}, {}, {}
local Enableds, Connections = {["Claim"] = false, ["Rebirth"] = false, ["Win"] = false}, {}
local SpeedPads, StaminaPads = {}, {}
local RebirthFrame, RebirthFill, RebirthButton = PlayerGui:QueryDescendants("#Main > #Frames > #Rebirth")[1], nil, nil

if RebirthFrame then
	RebirthFill, RebirthButton = RebirthFrame:QueryDescendants("#RebirthProgressBar > #Main")[1], RebirthFrame:FindFirstChild("RebirthButton")
end

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

local function SendClick(x,y)
	VirtualInputManager:SendMouseButtonEvent(x,y,0,true,game,0)
	task.wait()
	VirtualInputManager:SendMouseButtonEvent(x,y,0,false,game,0)
end

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

---- buy trails --
--game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.Trails.ScrollingFrame
--game:GetService("Players").LocalPlayer.PlayerGui.Main.Frames.Trails.ScrollingFrame.FlamingTrail.Wins


--[[
	-- claim speed pads --
	workspace.SpeedMultiplierPads
	workspace.SpeedMultiplierPads.Tier1.Hitbox

	-- claim stamina pads --
	workspace.HeroPads.Tier1
	workspace.HeroPads.Tier1.Hitbox
	
]]

local function GetPads(instance)
	if not (instance and instance.Parent) then return {} end
	
    local list = {}
	
	for _, pad in ipairs(instance:GetChildren()) do
	   local padName = pad.Name
	   local padTier = tonumber(padName:match("%d+") or "")
	   if not padTier then continue end

       local padHitbox = pad:QueryDescendants("BasePart#Hitbox")[1]
       if not padHitbox then continue end

       table.insert(list, {
		  Name = padName,
		  Tier = padTier,
		  Hitbox = padHitbox
	   })
	end
	
	table.sort(list, function(a, b)
		return a.Tier < b.Tier
	end)

	return list
end

local function RefreshForMode(mode)
	if mode == "HeroPads" or mode ==  then
		local padFolder = 
		if not padFolder then return end

		local TargetPads = mode == "HeroPads" and StaminaPads or SpeedPads
		table.clear(TargetPads)

		

		
		if next(TargetPads) then
			local objectKey = mode == "HeroPads" and "Stamina" or "Speed"
			ClaimObjects[objectKey] = TargetPads
			ClaimActives[objectKey] = false
		end
	else
		local winFolder = workspace:QueryDescendants("#WinPads > #NormalPads")[1]
		if not winFolder then return end
		
		local TargetCFrames = {}
		
		for _, pad in ipairs(winFolder:GetChildren()) do
			if not pad:IsA("Model") then continue end
			
			local padTier = tonumber(pad.Name:match("%d+") or "")
			if not padTier then continue end
			
			table.insert(TargetCFrames, {
				Tier = padTier,
				CFrame = pad:GetPivot()
			})
		end
		
		table.sort(TargetCFrames, function(a, b)
			return a.Tier > b.Tier
		end)
		
		if next(TargetCFrames) then
			ClaimObjects["Win"] = TargetCFrames
		end
	end
end

local function HandleClaim()
	task.spawn(function()
		while Enableds.Claim do
			for mode, active in pairs(ClaimActives) do
				if not Enableds.Claim then break end
				if not active then continue end
				if mode == "Win" then continue end
				
				local pads = ClaimObjects[mode]
				if not pads then continue end
				
				for _, hitbox in ipairs(pads) do
					task.wait()
					if not Enableds.Claim then break end
					FireTouch(hitbox)
				end
			end
			task.wait(1)
		end
	end)
end

local function HandleWin()
	
end

local function FireRebirth()
	if Enableds.Rebirth and IsFillFull(RebirthFill) then
		FireButton(RebirthButton)
	end
end

local function HandleRebirth()
	Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Position"):Connect(FireRebirth)

	task.spawn(function()
		while Enableds.Rebirth do
			FireRebirth()
			task.wait(1)
		end
	end)
end

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

RefreshForMode("HeroPads")
RefreshForMode("SpeedMultiplierPads")
RefreshForMode("Win")

local Window = UI:CreateWindow({
	Name = "+1 Speed Super Hero Escape",
	Destroying = function()
		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end

		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
	end
})

Window:AddToggle({
	Text = "Auto Win",
	Value = false,
	Flag = "wins_enabled",
	Callback = function(value)
		Enableds.Win = value
		if value then
			local winPads = {}

			for _, pad in ipairs(winFolder:GetChildren()) do
			if not pad:IsA("Model") then continue end
			
			local padTier = tonumber(pad.Name:match("%d+") or "")
			if not padTier then continue end
			
			table.insert(TargetCFrames, {
				Tier = padTier,
				CFrame = pad:GetPivot()
			})
			end
				
			task.spawn(function()
		while Enableds.Win do
			task.wait()
			
			      local winCFrames = ClaimObjects["Win"]
			      if not winCFrames then continue end

			      Character:PivotTo(winCFrames[1])
		       end
	       end)
		end
	end
})

Window:AddToggle({
	Text = "Claim Speed",
	Value = false,
	Flag = "claim_speed_enabled",
	Callback = function(value)
		Enableds.ClaimSpeed = value
		if value then
			local speedPads = GetPads(workspace:FindFirstChild("SpeedMultiplierPads"))
			
			task.spawn(function()
				while Enableds.ClaimSpeed do
					for _, pad in ipairs(speedPads)
						local hitbox = pad.Hitbox
						local rootbox = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
						if hitbox and rootbox then
							FireTouch(rootbox, hitbox)
						end
					end
					task.wait(5)
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Claim Stamina",
	Value = false,
	Flag = "claim_stamina_enabled",
	Callback = function(value)
		Enableds.ClaimStamina = value
		if value then
			local staminaPads = GetPads(workspace:FindFirstChild("HeroPads"))
			
			task.spawn(function()
				while Enableds.ClaimStamina do
					for _, pad in ipairs(staminaPads)
						local hitbox = pad.Hitbox
						local rootbox = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
						if hitbox and rootbox then
							FireTouch(rootbox, hitbox)
						end
					end
					task.wait(5)
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
		Enableds.Rebirth = value
		if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
		if value then
			HandleRebirth()
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
