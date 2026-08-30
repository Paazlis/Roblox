local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService
local VirtualInputManager = Services.VirtualInputManager

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local AnxietyFill = PlayerGui:QueryDescendants("#StatGui > #Anxiety > #AnxietyBarClip > #AnxietyBar")[1]
local Enableds = {["Farm"] = false, ["Anxiety"] = false, ["AnxietyDebounce"] = false}
local Cacheds = {}
local CaughtWarning = nil
local SendProcessed = true

local Packets = {
	["ToolAction"] = ReplicatedStorage:QueryDescendants("#ToolEvents > #ToolAction")[1],
	["PlayerAnswerTable"] = ReplicatedStorage:FindFirstChild("PlayerAnswerTable"),
}

local PhoneStatus = {}

local TeacherInfo = {
	MaxDistance = 100,
	MaxAngle = 0.7,
	["RaycastParams"] = RaycastParams.new()
}
TeacherInfo.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude

Cacheds.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function SendKey(keyCode)
	if keypress then
		keypress(keyCode)
	else
		VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
	end
	task.wait(0.05)
	if keyrelease then
		keyrelease(keyCode)
	else
		VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
	end
end

local function Cleanup(object)
	local objectType=typeof(object)
	if objectType=='function' then
		pcall(function() object() end)
	elseif objectType=='RBXScriptConnection' then
		object:Disconnect()
	elseif objectType=='thread' then
		local wasCancelled:boolean?=nil
		if coroutine.running()~=object then
			wasCancelled=pcall(function()
				task.cancel(object)
			end)
		end
		if not wasCancelled then
			local toClean=object
			task.defer(function()
				task.cancel(toClean)
			end)
		end
	end
	return nil
end

local function IsCaughtRaycast(plrModel, npcModel, raycastInfo)
	if not (plrModel and npcModel) then return nil end

	local rootRoot = plrModel.PrimaryPart or plrModel:FindFirstChild("HumanoidRootPart")
	local npcRootPart = npcModel.PrimaryPart or npcModel:FindFirstChild("HumanoidRootPart")
	local npcHead = npcModel:FindFirstChild("Head")

	if not (rootRoot and npcHead) then return false end

	local npcLookVector = npcHead.CFrame.LookVector
	local directionToPlayer = (rootRoot.Position - npcHead.Position).Unit

	local dotProduct = npcLookVector:Dot(directionToPlayer)
	local maxAngle = raycastInfo.MaxAngle or 0.7

	-- If the player is within the head's forward field of view
	if dotProduct >= maxAngle then
		-- Check distance
		--local distance = (rootRoot.Position - npcRootPart.Position).Magnitude
		--local maxDistance = raycastInfo.MaxDistance or 10
		--if distance > maxDistance then return false end

		-- Ignore the instance so the raycast does not hit itself.
		if not raycastInfo.RaycastParams then
			raycastInfo.RaycastParams = RaycastParams.new()
			raycastInfo.RaycastParams.FilterDescendantsInstances = {npcModel}
			raycastInfo.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
		end
		local raycastParams = raycastInfo.RaycastParams
		local raycastResult  = workspace:Raycast(npcHead.Position, npcHead.CFrame.LookVector * 150, raycastParams)

		if raycastResult then
			local hit = raycastResult.Instance
			if hit then
				return hit:IsDescendantOf(npcModel)
			end
		end

		return true
	end

	return false
end

local function GetPhoneStatus(data, tool)
	local frame =  tool:QueryDescendants("#Phone > #Screen > #SurfaceGui > #Frame")[1]
	if frame == nil then return nil end
	local title = frame:FindFirstChild("AnswersText")
	local logo = frame:FindFirstChild("WifiLogo")
	if not (title and logo) then return nil end

	repeat task.wait(1) until logo.Visible == false

	local key = title.Text

	data.Anwers = data.Anwers or {}
	table.clear(data.Anwers)

	local lines = string.split(key, "\n")
	for index, line in ipairs(lines) do
		local num, letter = string.match(line, "(%d+)%.%s*(%a+)")
		if num and letter then
			table.insert(data.Anwers, {
				Index = tonumber(num),
				Letter = letter
			})
		end
	end

	return data
end

local function FindFirstChildOfNPC(instance,name) : Model
	for _, npc in ipairs(instance:GetChildren()) do
		if npc and npc.Parent and npc.Name==name and npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(npc) then
			return npc
		end
	end
	return nil
end

local function EquipTool(tool)
	local humanoid = Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:EquipTool(tool)
	end
end

local function UnequipTools()
	local humanoid = Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:UnequipTools()
	end
end
local Teacher = nil
local IsCaught = false

Cacheds.TeacherChanged = RunService.Heartbeat:Connect(function()
	if not Teacher then return end
	TeacherInfo.RaycastParams.FilterDescendantsInstances = {Teacher}
	IsCaught = IsCaughtRaycast(Character, Teacher, TeacherInfo)
	if CaughtWarning then
		CaughtWarning.Visible = IsCaught
	end
end)

local function FireAnxiety()
	if Enableds.Anxiety and AnxietyFill.Size.X.Scale >= 0.5 then
		if not Enableds.AnxietyDebounce then
			Enableds.AnxietyDebounce = true 
			
			while Enableds.Anxiety and AnxietyFill.Size.X.Scale <= 0.2 do
				local tool = Backpack:FindFirstChild("Pencil")
				if tool then
					local humanoid = Character:FindFirstChildOfClass("Humanoid")
					if humanoid then
						humanoid:EquipTool(tool)
					end
				end
				task.wait(1)
			end
		
			Enableds.AnxietyDebounce = false
		end
	end
end

local function FindFirstChildOfContextActionButton(name)
	local frame = PlayerGui:QueryDescendants("#ContextActionGui > #ContextButtonFrame")[1]
	if frame then
		for _, button in ipairs(frame:GetChildren()) do
			if button and button.Parent then
				local title = button:FindFirstChild("ActionTitle")
				if not title then continue end
				
				local key = string.gsub(title.Text:lower(), "^%s*(.-)%s*$", "%1")
				if string.find(key, name) then
					return button
				end
			end
		end
	end
	

	return nil
end

local function HandleFarm()
	if Cacheds.AnxietyThread then Cacheds.AnxietyThread = Cleanup(Cacheds.AnxietyThread) end
	if Cacheds.FarmThread then Cacheds.FarmThread = Cleanup(Cacheds.FarmThread) end
	if Cacheds.TeacherChanged then Cacheds.TeacherChanged = Cleanup(Cacheds.TeacherChanged) end
	if not Enableds.Farm then Enableds.Anxiety = false return end

	Teacher = FindFirstChildOfNPC(workspace, "Teacher")
	
	Cacheds.AnxietyThread = task.spawn(function()
		while Enableds.Farm do
			if AnxietyFill.Size.X.Scale >= 0.5 then
				Enableds.Anxiety = true
				FireAnxiety()
				Enableds.Anxiety = false
			end
			task.wait()
		end
	end)
	
	Cacheds.FarmThread = task.spawn(function()
		while Enableds.Farm do
			task.wait(0.5)

			if Enableds.Anxiety then continue end
			if not Enableds.Farm then break end

			--local tool = nil

			--if IsCaught then
			--	tool = Character:FindFirstChildOfClass("Tool")
			--	if tool then
			--		UnequipTools()
			--	end
			--else
			--	tool = Backpack:FindFirstChild("Phone1")
			--	if tool then
			--		EquipTool(tool)
			--		task.wait(1)
			--	end
				
			--	-- Take Photo --
			--	SendKey(Enum.KeyCode.Q)
			--	task.wait(2)
				
			--	if Enableds.Anxiety then continue end
				
			--	tool = Backpack:FindFirstChild("Phone1")
			--	if tool then
			--		EquipTool(tool)
			--		task.wait(1)
			--	end
				
			--	-- View Answers --
			--	SendKey(Enum.KeyCode.E)
			--	task.wait(2)
				
			--	tool = Character:FindFirstChildOfClass("Tool")
			--	if tool and tool.Name == "Phone1" then
			--		local newPhoneStatus = GetPhoneStatus(PhoneStatus,tool)
			--		if newPhoneStatus then
			--			PhoneStatus = newPhoneStatus
			--			for _, v in ipairs(newPhoneStatus.Anwers) do
			--				Packets.PlayerAnswerTable:InvokeServer(v.Index,v.Letter)
			--			end
			--		end
			--	end
			--end

		end
	end)
end

local function HandleAnxiety()
	if not Enableds.Anxiety then Enableds.AnxietyDebounce = false return end
	task.spawn(function()
		while Enableds.Anxiety do
			FireAnxiety()
			task.wait()
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Cheating During Testing",
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
		for key, object in pairs(Cacheds) do
			if object then
				Cleanup(object)
			end
		end
	end
})

CaughtWarning = Window:AddLabel({
	Text = "Caught Detected",
	Visible = false,
	TextColor3 = Color3.fromRGB(255, 170, 0)
})

Window:AddToggle({
	Text = "Auto Farm",
	Value = false,
	Flag = "farm_enabled",
	Callback = function(value)
		Enableds.Farm = value
		HandleFarm()
	end
})

Window:AddLabel({
	Text = "Version: 16",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
