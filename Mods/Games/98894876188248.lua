local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})

local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager = Services.VirtualInputManager

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local AnxietyFill = PlayerGui:QueryDescendants("#StatGui > #Anxiety > #AnxietyBarClip > #AnxietyBar")[1]
local Enableds = {["Cheat"] = false, ["Anxiety"] = false, ["AnxietyActive"] = false}
local Cacheds = {}
local CaughtLabel = nil
local IsCaught = false

local Packets = {
	["ToolAction"] = ReplicatedStorage:QueryDescendants("#ToolEvents > #ToolAction")[1],
	["PlayerAnswerTable"] = ReplicatedStorage:FindFirstChild("PlayerAnswerTable"),
}

local PhoneStatus = {}
local IgnoreList = {}
local TeacherInfo = {
	["Distance"] = 1000,
	["Angle"] = 0,
	["UseSweep"]=true,
	["SweepSpeed"] = 2.5, 
	["SweepRange"]=25,
	["DeltaTime"]=0,
	["RaycastParams"] = RaycastParams.new(),
}
TeacherInfo.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude

local BaseTargetAngles = {
	["Front"]         = 0,
	["LeftFront"]     = 30,
	["RightFront"]    = -30,
	["LeftMid"]       = 60,
	["RightMid"]      = -60,
	["Left"]          = 90,
	["Right"]         = -90,
}

local CurrentAngles = {}
for name in pairs(BaseTargetAngles) do
	CurrentAngles[name] = 0
end

TeacherInfo.TargetAngles=BaseTargetAngles
TeacherInfo.CurrentAngles=CurrentAngles

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
	local objectType = typeof(object)
	if objectType == 'function' then
		pcall(object)
	elseif objectType == 'RBXScriptConnection' then
		object:Disconnect()
	elseif objectType == 'thread' then
		if coroutine.running() ~= object then
			pcall(function() task.cancel(object) end)
		end
	end
	return nil
end

local function Directionalcast(origin, baseCFrame, info)
	info = info or {}

	local raycastParams = info.RaycastParams

	--local rootPart = character:FindFirstChild("HumanoidRootPart")
	--if not rootPart then return {} end

	--local origin = cframe.Position
	--local baseCFrame = rootPart.CFrame

	--raycastParams.FilterDescendantsInstances = {character}

	local results = {}

	-- Hitung offset ayunan derajat halus menggunakan Gelombang Sinus (Sine Wave)
	local sweepOffset = 0
	if info.UseSweep~=nil and info.UseSweep==true then
		sweepOffset = math.sin(os.clock() * (info.SweepSpeed or 2.5)) * (info.SweepRange or 25)
	end

	for name, baseAngle in pairs(info.TargetAngles) do
		-- Sudut target aktual + ayunan pemindai
		local targetAngle = baseAngle + sweepOffset

		-- Formula Derajat Mendaki Halus (Eksponensial Lerp berdasarkan Delta Time)
		local lerpFactor = 1 - math.exp(-(info.Speed or 14) * info.DeltaTime)
		info.CurrentAngles[name] = info.CurrentAngles[name] + (targetAngle - info.CurrentAngles[name] or 0) * lerpFactor

		-- Rotasi CFrame berdasarkan derajat saat ini
		local angleRotation = CFrame.Angles(0, math.rad(info.CurrentAngles[name]), 0)
		local directionVector = (baseCFrame * angleRotation).LookVector * info.Distance

		-- Raycast
		local raycastResult = workspace:Raycast(origin, directionVector, raycastParams)
		
		local newResult = {}
		-- Tentukan Warna & Panjang Sinar
		local detected = false -- saat tidak kena objek
		local direction = directionVector

		if raycastResult then
			newResult = {
				["Distance"] = raycastResult.Distance,
				["Position"] = raycastResult.Position,
				["Normal"] = raycastResult.Normal,
				["Material"] = raycastResult.Material,
				["Instance"] = raycastResult.Instance
			}

			detected = true
			direction = raycastResult.Position - origin

			newResult.Direction = direction
			newResult.Dectected = detected

			results[name] = newResult
		end
	end

	if not next(results) then return nil end

	return results
end

local function IsCaughtcast(plrModel, npcModel, info)
	if not (plrModel and npcModel) then return false end

	local rootRoot = plrModel.PrimaryPart or plrModel:FindFirstChild("HumanoidRootPart")
	local npcHead = npcModel:FindFirstChild("Head")
	local npcRootPart = npcModel.PrimaryPart or npcModel:FindFirstChild("HumanoidRootPart")
	
	if not (rootRoot and npcHead and npcRootPart) then return false end

	local results1 = Directionalcast(npcHead.Position, npcHead.CFrame, info)
	
	if results1 ~= nil then
		for _, result in pairs(results1) do
			local hit = result.Instance
			if hit ~= nil and hit:IsDescendantOf(plrModel) then
				return true
			end
		end
	end
	
	local results2 = Directionalcast(npcRootPart.Position, npcRootPart.CFrame, info)
	if results2 ~= nil then
		for _, result in pairs(results2) do
			local hit = result.Instance
			if hit ~= nil and hit:IsDescendantOf(plrModel) then
				return true
			end
		end
	end

	return false
end

local function WaitForPhoneStatus(data, tool)
	if not tool then return nil end
	local frame = tool:QueryDescendants("#Phone > #Screen > #SurfaceGui > #Frame")[1]
	if not frame then return nil end

	local title = frame:FindFirstChild("AnswersText")
	local logo = frame:FindFirstChild("WifiLogo")
	if not (title and logo) then return nil end

	repeat task.wait(1) until logo.Visible == false

	local key = title.Text
	data.Answers = data.Answers or {}
	table.clear(data.Answers)

	for _, line in ipairs(string.split(key, "\n")) do
		local num, letter = string.match(line, "(%d+)%.%s*(%a+)")
		if num and letter then
			table.insert(data.Answers, {
				Index = tonumber(num),
				Letter = letter
			})
		end
	end

	return data
end

local function FindFirstChildOfNPC(instance, name)
	for _, npc in ipairs(instance:GetChildren()) do
		if npc and npc.Parent and npc.Name == name and npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(npc) then
			return npc
		end
	end
	return nil
end

local function EquipTool(tool)
	local humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	if humanoid and tool then
		humanoid:EquipTool(tool)
	end
end

local function UnequipTools()
	local humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:UnequipTools()
	end
end

local Teacher = nil
local CheatToggle = nil

local function ObserveChild(instance, callback, noInitial)
	local childAddedConnection
	local childCache = {}

	local function OnChildRemoved(child)
		local childInfo = childCache[child]
		if not childInfo then return end
		childCache[child] = nil
		childInfo.AncestryChanged:Disconnect()
		if type(childInfo.Cleanup) == "function" then
			task.spawn(childInfo.Cleanup, child)
		end
	end

	local function OnChildAdded(child)
		if childAddedConnection.Connected and child and child.Parent then
			local cleanup = callback(child)
			if type(cleanup) == "function" then
				if childAddedConnection.Connected and child and child.Parent then
					local childInfo = {["Cleanup"] = cleanup}
					childInfo.AncestryChanged = child.AncestryChanged:Connect(function(_, parent)
						if not (parent and child:IsDescendantOf(instance)) then
							OnChildRemoved(child)
						end
					end)
					childCache[child] = childInfo
				else
					task.spawn(cleanup, child)
				end
			end
		end
	end

	childAddedConnection = instance.ChildAdded:Connect(OnChildAdded)

	task.defer(function()
		if not childAddedConnection.Connected or noInitial then return end
		for _, child in ipairs(instance:GetChildren()) do
			if not childAddedConnection.Connected then break end
			task.defer(OnChildAdded, child)
		end
	end)

	return function()
		childAddedConnection:Disconnect()
		local child = next(childCache)
		while child do
			OnChildRemoved(child)
			child = next(childCache)
		end
	end
end

Cacheds.IgnoreObserve = ObserveChild(workspace, function(child)
	if child ~= Character then
		table.insert(IgnoreList, child)
		return function()
			local idx = table.find(IgnoreList, child)
			if idx then
				table.remove(IgnoreList, idx)
			end
		end
	end
end)

Cacheds.TeacherThread = task.spawn(function()
	while true do
		local deltaTime = task.wait()
		TeacherInfo.DeltaTime=deltaTime
		if Teacher then 
			TeacherInfo.RaycastParams.FilterDescendantsInstances = IgnoreList
			IsCaught = IsCaughtcast(Character, Teacher, TeacherInfo)
			if CaughtLabel then
				CaughtLabel:Set("Caught: " .. tostring(IsCaught))
			end
		end
	end
end)

local function FireAnxiety()
	if Enableds.Anxiety and AnxietyFill.Size.X.Scale >= 0.5 then
		if not Enableds.AnxietyActive then
			Enableds.AnxietyActive = true 

			while Enableds.Anxiety and AnxietyFill and AnxietyFill.Parent and AnxietyFill.Size.X.Scale > 0.2 do
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

local function WaitTimeoutOrCaught(duration)
	local startTime = os.clock()
	while os.clock() - startTime < duration do
		if IsCaught then
			local tool = Backpack:FindFirstChild("Pencil")
			if tool then
				EquipTool(tool)
			end
			return false
		end
		task.wait()
	end
	return true
end

local function HandleCheat()
	if Cacheds.CheatThread then Cacheds.CheatThread = Cleanup(Cacheds.CheatThread) end
	if not Enableds.Cheat then return end

	Teacher = FindFirstChildOfNPC(workspace, "Teacher")
	if not Teacher then
		Enableds.Cheat = false
		if CheatToggle then CheatToggle:Replace(false) end
		return 
	end

	Cacheds.CheatThread = task.spawn(function()
		while Enableds.Cheat do
			task.wait()

			if Enableds.AnxietyActive then continue end

			if IsCaught then
				local tool = Backpack:FindFirstChild("Pencil")
				if tool then
					EquipTool(tool)
				end
			else
				local phone = Backpack:FindFirstChild("Phone1")
				if phone then
					EquipTool(phone)
					if not WaitTimeoutOrCaught(1) then continue end
				end

				-- Take Photo
				SendKey(Enum.KeyCode.Q)
				if not WaitTimeoutOrCaught(2) then
					continue 
				end

				phone = Backpack:FindFirstChild("Phone1")
				if phone then
					EquipTool(phone)
					if not WaitTimeoutOrCaught(1) then continue end
				end

				-- View Answers
				SendKey(Enum.KeyCode.E)
				if not WaitTimeoutOrCaught(2) then
					continue 
				end

				local tool = Character:FindFirstChildOfClass("Tool")
				if tool and tool.Name == "Phone1" then
					local newPhoneStatus = WaitForPhoneStatus(PhoneStatus, tool)
					SendKey(Enum.KeyCode.E)
					if newPhoneStatus and newPhoneStatus.Answers then
						PhoneStatus = newPhoneStatus
						for _, v in ipairs(newPhoneStatus.Answers) do
							Packets.PlayerAnswerTable:InvokeServer(v.Index, v.Letter)
						end
					end
				end
			end
		end
	end)
end

local function HandleAnxiety()
	if Cacheds.AnxietyThread then Cacheds.AnxietyThread = Cleanup(Cacheds.AnxietyThread) end
	if not Enableds.Anxiety then 
		Enableds.AnxietyActive = false 
		return 
	end

	Cacheds.AnxietyThread = task.spawn(function()
		while Enableds.Anxiety do
			FireAnxiety()
			task.wait(0.1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Cheating During Testing",
	Destroying = function()
		for key in pairs(Enableds) do
			Enableds[key] = false
		end
		for _, object in pairs(Cacheds) do
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
	Text = "YouTube: Crokyreo | V39",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
