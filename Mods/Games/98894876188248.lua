local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})

local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager = Services.VirtualInputManager
local RunService = Services.RunService

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

-- [KONFIGURASI CONE VISION]
local TeacherInfo = {
	["Distance"] = 200,       -- Jarak pandang maksimal
	["DotThreshold"] = -0.25, -- 0 = Kiri/Kanan pas (180° FOV). -0.25 = Agak ke belakang sedikit (~208° FOV).
	["RaycastParams"] = RaycastParams.new(),
}
TeacherInfo.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude

Cacheds.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
	Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
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

local function HidePhone()
	local pencil = (Backpack and Backpack:FindFirstChild("Pencil")) or (Character and Character:FindFirstChild("Pencil"))
	if pencil then
		EquipTool(pencil)
	else
		UnequipTools()
	end
end

-- [SISTEM DETEKSI CONE / FOV BARU]
local function IsCaughtByCone(plrModel, npcModel, info)
	if not (plrModel and npcModel) then return false end

	local rootPart = plrModel.PrimaryPart or plrModel:FindFirstChild("HumanoidRootPart")
	local npcHead = npcModel:FindFirstChild("Head")
	if not (rootPart and npcHead) then return false end

	local npcPos = npcHead.Position
	local plrPos = rootPart.Position
	
	local vectorToPlayer = plrPos - npcPos
	local distanceToPlayer = vectorToPlayer.Magnitude
	
	-- 1. Cek apakah pemain berada di dalam radius jarak
	if distanceToPlayer > info.Distance then return false end
	
	local directionToPlayer = vectorToPlayer.Unit
	local npcLookVector = npcHead.CFrame.LookVector
	
	-- 2. Cek apakah pemain berada di dalam "Kerucut" pandangan (Depan, Kiri, Kanan, s/d Agak Belakang)
	local dotProduct = npcLookVector:Dot(directionToPlayer)
	
	if dotProduct >= info.DotThreshold then
		-- 3. Jika masuk kerucut, tembak 1 Raycast untuk memastikan tidak terhalang dinding/meja
		local raycastResult = workspace:Raycast(npcPos, directionToPlayer * distanceToPlayer, info.RaycastParams)
		
		if raycastResult then
			local hit = raycastResult.Instance
			-- Jika yang tertabrak adalah bagian tubuh pemain, maka ketahuan
			if hit and hit:IsDescendantOf(plrModel) then
				return true
			end
		end
	end

	return false
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

local function WaitForPhoneStatus(data, tool)
	if not tool then return nil end
	local frame = tool:QueryDescendants("#Phone > #Screen > #SurfaceGui > #Frame")[1]
	if not frame then return nil end

	local title = frame:FindFirstChild("AnswersText")
	--local logo = frame:FindFirstChild("WifiLogo")
	if not title then return nil end

	repeat 
		task.wait()
	until title.Visible == true or IsCaught or Enableds.AnxietyActive 

	if not title.Visible then return nil end
	
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

Cacheds.TeacherLoop = RunService.RenderStepped:Connect(function()
	if Teacher then 
		TeacherInfo.RaycastParams.FilterDescendantsInstances = {Teacher}
		
		-- Gunakan sistem Cone baru
		IsCaught = IsCaughtByCone(Character, Teacher, TeacherInfo)
		
		if CaughtLabel then
			CaughtLabel:Set("Caught: " .. tostring(IsCaught))
		end

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
				local tool = Backpack and Backpack:FindFirstChild("Pencil")
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

local function HandleCheat()
	if Cacheds.CheatThread then Cacheds.CheatThread = Cleanup(Cacheds.CheatThread) end
	if not Enableds.Cheat then return end

	Teacher = FindFirstChildOfNPC(workspace, "Teacher")
	if not Teacher then
		Enableds.Cheat = false
		if CheatToggle then CheatToggle:Replace(false) end
		return 
	end

	local TakePhotoActive = false
	
	Cacheds.CheatThread = task.spawn(function()
		while Enableds.Cheat do
			task.wait(0.05)

			if Enableds.AnxietyActive then continue end

			if IsCaught then
				HidePhone()
			else
				local phone = Backpack:FindFirstChild("Phone1")
				
				if phone and not IsCaught then
					EquipTool(phone)
					if not WaitTimeoutOrCaught(1) then continue end
				end

				if IsCaught then HidePhone() continue end

				-- Take Photo
				if not TakePhotoActive then
				   SendKey(Enum.KeyCode.Q)
				   if not WaitTimeoutOrCaught(1) then
					   continue 
			       end
				   TakePhotoActive = true
			    end
					
				if IsCaught then HidePhone() continue end

				-- View Answers
				SendKey(Enum.KeyCode.E)
				if not WaitTimeoutOrCaught(1) then
					SendKey(Enum.KeyCode.E)
					continue 
				end
					
				if IsCaught then HidePhone() continue end
				
				local tool = Character:FindFirstChildOfClass("Tool")
				if tool and tool.Name == "Phone1" then
					local newPhoneStatus = WaitForPhoneStatus(PhoneStatus, tool)
					if newPhoneStatus and newPhoneStatus.Answers and not IsCaught then
						PhoneStatus = newPhoneStatus
						for _, v in ipairs(newPhoneStatus.Answers) do
							Packets.PlayerAnswerTable:InvokeServer(v.Index, v.Letter)
							task.wait()
						end
						SendKey(Enum.KeyCode.E)
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

CaughtLabel = Window:AddLabel({
	Text = "Caught: false",
	TextColor3 = Color3.fromRGB(255, 255, 255)
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
