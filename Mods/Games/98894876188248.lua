local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})

local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager = Services.VirtualInputManager
local RunService = Services.RunService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
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
local TeacherInfo = {
	["Distance"] = 100,
	["Angle"] = 0,
	["UseSweep"] = true,
	["SweepSpeed"] = 20, 
	["SweepRange"] = 25,
	["DeltaTime"] = 0,
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

TeacherInfo.TargetAngles = BaseTargetAngles
TeacherInfo.CurrentAngles = CurrentAngles

Cacheds.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function GetBackpack()
	return LocalPlayer:FindFirstChildOfClass("Backpack")
end

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

-- Fungsi respons cepat untuk menyembunyikan HP seketika
local function HidePhone()
	local bp = GetBackpack()
	local pencil = (bp and bp:FindFirstChild("Pencil")) or (Character and Character:FindFirstChild("Pencil"))
	if pencil then
		EquipTool(pencil)
	else
		UnequipTools()
	end
end

local function Directionalcast(origin, baseCFrame, info)
	info = info or {}
	local raycastParams = info.RaycastParams
	local results = {}

	local sweepOffset = 0
	if info.UseSweep == true then
		sweepOffset = math.sin(os.clock() * (info.SweepSpeed or 2.5)) * (info.SweepRange or 25)
	end

	local caught = false
	
	for name, baseAngle in pairs(info.TargetAngles) do
		local targetAngle = baseAngle + sweepOffset
		local lerpFactor = 1 - math.exp(-(info.Speed or 14) * info.DeltaTime)
		info.CurrentAngles[name] = info.CurrentAngles[name] + (targetAngle - (info.CurrentAngles[name] or 0)) * lerpFactor

		local angleRotation = CFrame.Angles(0, math.rad(info.CurrentAngles[name]), 0)
		local directionVector = (baseCFrame * angleRotation).LookVector * info.Distance

		local raycastResult = workspace:Raycast(origin, directionVector, raycastParams)
		
		local result = {
			["Direction"] = directionVector,
			["Dectected"] = false
		}
		
		if raycastResult then
			result = {
				["Distance"] = raycastResult.Distance,
				["Position"] = raycastResult.Position,
				["Normal"] = raycastResult.Normal,
				["Material"] = raycastResult.Material,
				["Instance"] = raycastResult.Instance,
				["Direction"] = raycastResult.Position - origin,
				["Dectected"] = true
			}
			caught = true 
		end

		results[name] = result
	end
	
	return results, caught
end

local function IsCaughtcast(plrModel, npcModel, info)
	if not (plrModel and npcModel) then return false end

	local rootPart = plrModel.PrimaryPart or plrModel:FindFirstChild("HumanoidRootPart")
	local npcHead = npcModel:FindFirstChild("Head")
	if not (rootPart and npcHead) then return false end

	local results, caught = Directionalcast(npcHead.Position, npcHead.CFrame, info)
	
	if results and caught then
		for _, result in pairs(results) do
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

	-- Tunggu logo wifi hilang atau ketahuan (responsif 0.05s)
	repeat 
		task.wait(0.05) 
		if IsCaught then
			HidePhone()
			return nil
		end
	until logo.Visible == false

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

local Teacher = nil
local CheatToggle = nil

Cacheds.TeacherLoop = RunService.RenderStepped:Connect(function(deltaTime)
	TeacherInfo.DeltaTime = deltaTime
	if Teacher then 
		-- Filter hanya model Teacher agar dinding/objek lain tetap memblokir Raycast
		TeacherInfo.RaycastParams.FilterDescendantsInstances = {Teacher}
		IsCaught = IsCaughtcast(Character, Teacher, TeacherInfo)
		
		if CaughtLabel then
			CaughtLabel:Set("Caught: " .. tostring(IsCaught))
		end

		-- Jika mendadak ketahuan saat Auto Cheat aktif, langsung sembunyikan HP detik itu juga
		if IsCaught and Enableds.Cheat then
			HidePhone()
		end
	end
end)

local function FireAnxiety()
	if Enableds.Anxiety and AnxietyFill and AnxietyFill.Size.X.Scale >= 0.5 then
		if not Enableds.AnxietyActive then
			Enableds.AnxietyActive = true 

			while Enableds.Anxiety and AnxietyFill and AnxietyFill.Parent and AnxietyFill.Size.X.Scale > 0.2 do
				local bp = GetBackpack()
				local tool = bp and bp:FindFirstChild("Pencil")
				if tool then
					EquipTool(tool)
				end
				task.wait(0.5)
			end
			
			local tool = Character:FindFirstChildOfClass("Tool")
			if tool and tool.Name == "Pencil" then
				UnequipTools()
			end
			
			Enableds.AnxietyActive = false
		end
	end
end

local function WaitTimeoutOrCaught(duration)
	local startTime = os.clock()
	while os.clock() - startTime < duration do
		if IsCaught or Enableds.AnxietyActive then
			HidePhone()
			return false
		end
		task.wait(0.05)
	end
	
	if IsCaught or Enableds.AnxietyActive then
		HidePhone()
		return false
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
			task.wait(0.05)

			if Enableds.AnxietyActive then continue end

			if IsCaught then
				HidePhone()
			else
				local bp = GetBackpack()
				local phone = bp and bp:FindFirstChild("Phone1")
				
				if phone and not IsCaught then
					EquipTool(phone)
					if not WaitTimeoutOrCaught(1) then continue end
				end

				-- Check ulang sebelum tekan Q
				if IsCaught then HidePhone() continue end

				-- Take Photo
				SendKey(Enum.KeyCode.Q)
				if not WaitTimeoutOrCaught(2) then
					continue 
				end

				bp = GetBackpack()
				phone = bp and bp:FindFirstChild("Phone1")
				if phone and not IsCaught then
					EquipTool(phone)
					if not WaitTimeoutOrCaught(1) then continue end
				end

				-- Check ulang sebelum tekan E
				if IsCaught then HidePhone() continue end

				-- View Answers
				SendKey(Enum.KeyCode.E)
				if not WaitTimeoutOrCaught(2) then
					continue 
				end

				local tool = Character:FindFirstChildOfClass("Tool")
				if tool and tool.Name == "Phone1" then
					local newPhoneStatus = WaitForPhoneStatus(PhoneStatus, tool)
					if newPhoneStatus and newPhoneStatus.Answers and not IsCaught then
						PhoneStatus = newPhoneStatus
						SendKey(Enum.KeyCode.E)
						for _, v in ipairs(newPhoneStatus.Answers) do
							Packets.PlayerAnswerTable:InvokeServer(v.Index, v.Letter)
						end
					else
						HidePhone()
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

Window:AddSlider({
	Text = "Distance",
	Range = {50, 1000},
	Value = 100,
	Increment = 1,
	Flag = "distance",
	Callback = function(value)
		TeacherInfo.Distance = value
	end
})

CaughtLabel = Window:AddLabel({
	Text = "Caught: false",
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
