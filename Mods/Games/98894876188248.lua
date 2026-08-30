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
local Enableds = {["Cheat"] = false, ["Anxiety"] = false, ["AnxietyActive"] = false}
local Cacheds = {}
local CaughtLabel = nil
local SendProcessed = true
local IsCaught = false

local Packets = {
	["ToolAction"] = ReplicatedStorage:QueryDescendants("#ToolEvents > #ToolAction")[1],
	["PlayerAnswerTable"] = ReplicatedStorage:FindFirstChild("PlayerAnswerTable"),
}

local PhoneStatus = {}

local IgnoreList = {}
local TeacherInfo = {
	["MaxDistance"] = 100,
	["MaxAngle"] = 0,
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
	if not (plrModel and npcModel) then return false end

	local rootRoot = plrModel.PrimaryPart or plrModel:FindFirstChild("HumanoidRootPart")
	local npcHead = npcModel:FindFirstChild("Head")

	if not (rootRoot and npcHead) then return false end

	local npcLookVector = npcHead.CFrame.LookVector
	local directionToPlayer = (rootRoot.Position - npcHead.Position).Unit

	local dotProduct = npcLookVector:Dot(directionToPlayer)
	local maxAngle = raycastInfo.MaxAngle or 0.7

	-- If the player is within the head's forward field of view
	if dotProduct >= maxAngle then
		local maxDistance = raycastInfo.MaxDistance or 100
		
		-- Ignore the instance so the raycast does not hit itself.
		if not raycastInfo.RaycastParams then
			raycastInfo.RaycastParams = RaycastParams.new()
			raycastInfo.RaycastParams.FilterDescendantsInstances = {npcModel}
			raycastInfo.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
		end
		local raycastParams = raycastInfo.RaycastParams
		local raycastResult  = workspace:Raycast(npcHead.Position, npcLookVector * maxDistance, raycastParams)

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

local function WaitForPhoneStatus(data, tool)
	local frame =  tool:QueryDescendants("#Phone > #Screen > #SurfaceGui > #Frame")[1]
	if frame == nil then return nil end
	local title = frame:FindFirstChild("AnswersText")
	local logo = frame:FindFirstChild("WifiLogo")
	if not (title and logo) then return nil end

	repeat task.wait(1) until logo.Visible == false or IsCaught == true

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

local function FindFirstChildOfNPC(instance,name)
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
local CheatToggle = nil

local function ObserveChild(instance,callback,noInitial)
	local childAddedConnection
	local childCache={}

	local function OnChildRemoved(child)
		local childInfo=childCache[child]
		if childInfo==nil then return end
		childCache[child]=nil
		childInfo.AncestryChanged:Disconnect()
		local cleanup=childInfo.Cleanup
		if cleanup==nil or type(cleanup)~="function" then return end
		task.spawn(cleanup,child)
	end

	local function OnChildAdded(child)
		if childAddedConnection.Connected and child~=nil and child.Parent~=nil then
			local cleanup=callback(child)
			if cleanup~=nil and type(cleanup)=="function" then
				if childAddedConnection.Connected and child~=nil and child.Parent~=nil then
					local childInfo={["Cleanup"]=cleanup}
					childInfo.AncestryChanged=child.AncestryChanged:Connect(function(_,parent)
						if not (parent~=nil and child:IsDescendantOf(instance)) then
							OnChildRemoved(child)
						end
					end)
					childCache[child]=childInfo
				else
					task.spawn(cleanup,child)
				end
			end
		end
	end

	-- Listen for changes:
	childAddedConnection=instance.ChildAdded:Connect(OnChildAdded)

	-- Initial:
	task.defer(function()
		if not childAddedConnection.Connected or noInitial then return end
		local children=instance:GetChildren()
		for i,child in ipairs(children) do
			if not childAddedConnection.Connected then break end
			task.defer(OnChildAdded,child)
		end
	end)

	-- Cleanup:
	return function()
		childAddedConnection:Disconnect()
		local child=next(childCache)
		while child do
			OnChildRemoved(child)
			child=next(childCache)
		end
	end
end

Cacheds.IgnoreObserve = ObserveChild(workspace, function(child)
	if child ~= Character then
		table.insert(IgnoreList, child)
		return function()
			table.remove(IgnoreList)
		end
	end
end)

Cacheds.TeacherThread = task.spawn(function()
	while true do
		task.wait()
		if Teacher ~= nil then 
			TeacherInfo.RaycastParams.FilterDescendantsInstances = IgnoreList
			IsCaught = IsCaughtRaycast(Character, Teacher, TeacherInfo)
			if CaughtLabel then
				CaughtLabel:Set("Caught: "..(IsCaught and "True" or "False"))
			end
		end
	end
end)

local function FireAnxiety()
	if Enableds.Anxiety and AnxietyFill.Size.X.Scale >= 0.5 then
		if not Enableds.AnxietyActive then
			Enableds.AnxietyActive = true 
			
			while Enableds.Anxiety and AnxietyFill.Size.X.Scale > 0.2 do
				local tool = Backpack:FindFirstChild("Pencil")
				if tool then
					EquipTool(tool)
				end
				task.wait(1)
			end
		
			Enableds.AnxietyActive = false
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

local function HandleCheat()
	if Cacheds.CheatThread then Cacheds.CheatThread = Cleanup(Cacheds.CheatThread) end
	if not Enableds.Cheat then return end

	Teacher = FindFirstChildOfNPC(workspace,"Teacher")
	if not Teacher then
		Enableds.Cheat = false
		CheatToggle:Replace(false)
		return 
	end
	
	Cacheds.CheatThread = task.spawn(function()
		while Enableds.Cheat do
			task.wait()

			if Enableds.AnxietyActive then continue end
			
			local tool = nil
			local runningThread = nil
			local runningActive = false
				
			if IsCaught then
				tool = Character:FindFirstChildOfClass("Tool")
				if tool then
					if Enableds.AnxietyActive then continue end
					UnequipTools()
				end
			else
				tool = Backpack:FindFirstChild("Phone1")
				if tool then
					EquipTool(tool)
					task.wait(1)
				end
				
				-- Take Photo --
				SendKey(Enum.KeyCode.Q)
				runningThread = task.spawn(function()
					task.wait(2)
					runningActive = true
				end
				repeat task.wait() until runningActive == true or IsCaught == true
				
				if IsCaught == true then
					local pencilTool = Backpack:FindFirstChild("Pencil")
				    if pencilTool then
					   EquipTool(pencilTool)
				    end
					Cleanup(runningThread)
					continue 
				end
				
				if Enableds.AnxietyActive then continue end
				
				tool = Backpack:FindFirstChild("Phone1")
				if tool and not Enableds.AnxietyActive then
					EquipTool(tool)
				    runningActive = false
					runningThread = task.spawn(function()
					   task.wait(1)
					   runningActive = true
				    end
			     	repeat task.wait() until runningActive == true or IsCaught == true
				end

			    if IsCaught == true then
					local pencilTool = Backpack:FindFirstChild("Pencil")
				    if pencilTool then
					   EquipTool(pencilTool)
				    end
					Cleanup(runningThread)
					continue 
				end
						
				-- View Answers --
				SendKey(Enum.KeyCode.E)
				runningActive = false
			    runningThread = task.spawn(function()
					   task.wait(1)
					   runningActive = true
			    end
			    repeat task.wait() until runningActive == true or IsCaught == true
				
				if IsCaught == true then
					local pencilTool = Backpack:FindFirstChild("Pencil")
				    if pencilTool then
					   EquipTool(pencilTool)
				    end
					Cleanup(runningThread)
					continue 
				end
				
				tool = Character:FindFirstChildOfClass("Tool")
				if tool and tool.Name == "Phone1" then
					local newPhoneStatus = WaitForPhoneStatus(PhoneStatus,tool)
					SendKey(Enum.KeyCode.E)
					if newPhoneStatus then
						PhoneStatus = newPhoneStatus
						for _, v in ipairs(newPhoneStatus.Anwers) do
							Packets.PlayerAnswerTable:InvokeServer(v.Index,v.Letter)
						end
					end
				end
			end
		end
	end)
end

local function HandleAnxiety()
	if Cacheds.AnxietyThread then Cacheds.AnxietyThread = Cleanup(Cacheds.AnxietyThread) end
	if not Enableds.Anxiety then Enableds.AnxietyActive = false return end
	Cacheds.AnxietyThread = task.spawn(function()
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

CaughtLabel = Window:AddLabel({
	Text = "Caught: False",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

CheatToggle = Window:AddToggle({
	Text = "Auto Cheat",
	Value = false,
	Flag = "cheat_enabled",
	Callback = function(value)
		Enableds.Cheat = value
		HandleCheat()
	end
})

Window:AddToggle({
	Text = "Auto Anxiety",
	Value = false,
	Flag = "anxiety_enabled",
	Callback = function(value)
		Enableds.Anxiety = value
		HandleAnxiety()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
