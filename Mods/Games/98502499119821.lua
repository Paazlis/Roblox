local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Packets = {}
local Enableds, Connections, Threads = {["Fishing"] = false, ["Code"] = false, ["Sell"] = false, ["Quest"] = false}, {}, {}

local PlayerDataFolder = ReplicatedStorage:FindFirstChild("Data")
Packets.RedeemCode = ReplicatedStorage:QueryDescendants("#Events > #RedeemCode")[1]
Packets.SellFish = ReplicatedStorage:QueryDescendants("#Events > #SellFish")[1]
Packets.ClaimQuest = ReplicatedStorage:QueryDescendants("#Events > #ClaimQuest")[1]

local MaxDailyQuest = 4
local HookCFrame = CFrame.new(-309.3076171875, 9.7615242004395, 106.26274871826, -0.15476256608963, -4.7383696966108e-08, 0.98795169591904, -2.7558765935964e-08, 1, 4.3644472924598e-08, -0.98795169591904, -2.0472198158927e-08, -0.15476256608963)

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function FireTouch(hitPart, targetPart)
	if firetouchinterest and hitPart and targetPart then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

local function FireButton(button)
	if firesignal and button then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function HandleQuest()
	if not Enableds.Quest then return end

	task.spawn(function()
		while Enableds.Quest do
			for i = 1, MaxDailyQuest do
				if not Enableds.Quest then break end
				Packets.ClaimQuest:FireServer(tostring(i))
				task.wait(0.1)
			end
			task.wait(1)
		end
	end)
end

local function IsCursorPerfect(cursor)
	local currentX=cursor.Position.X.Scale
	if currentX>=0.4 and currentX<=0.6 then
		return true
	end
	return false
end

local function IsFillRunOut(fill)
	if fill.Size.Scale.X <= 0 then
		return true
	end
	return false
end

local FishingThread = nil

local function HandleFishing()
	if Connections.Fishing then Connections.Fishing:Disconnect() Connections.Fishing=nil end
	if Threads.Fishing and coroutine.status(Threads.Fishing) ~= "dead" then task.cancel(Threads.Fishing) Threads.Fishing = nil end
	if not Enableds.Fishing then return end
	
	Packets.Fishing = ReplicatedStorage:QueryDescendants("#Events > #Fishing")[1]
	Packets.FishingMinigame = ReplicatedStorage:QueryDescendants("#Events > #FishingMinigame")[1]
    
	local fishingFrame = PlayerGui:QueryDescendants("#MainGui > #Fishing")[1]
	
	local mainFill = nil
	local mainCursor = nil
	
	if fishingFrame then
       mainFill = fishingFrame:QueryDescendants("#ProgressionBar > #Bar")[1]
	   mainCursor = fishingFrame:QueryDescendants("#BarFrame > #Bar")[1]
	end

	local fishingButton = PlayerGui:QueryDescendants("#MainGui > #Mobile > #Fishing")[1]
	
	Connections.Fishing = mainCursor:GetPropertyChangedSignal("Position"):Connect(function()
	    if not IsCursorPerfect(mainCursor) and Enableds.Fishing then
			FireButton(fishingButton)
		end
	end)
	
	Threads.Fishing = task.spawn(function()
		while Enableds.Fishing do
			Packets.Fishing:FireServer(HookCFrame)
			local args = Packets.FishingMinigame.OnClientEvent:Wait()
			local fishId = args[3]
			repeat task.wait() until fishingFrame.Visible == true
			repeat task.wait() until fishingFrame.Visible == false
			Packets.FishingMinigame:FireServer(false, fishId)
			task.wait(1)
		end
	end)
end

local function HandleCode()
	if not Enableds.Code then return end

	task.spawn(function()
		while Enableds.Code do
			local codes = {}
			
			for _, playerFolder in ipairs(PlayerDataFolder:GetChildren()) do
				if not Enableds.Code then break end
				if not (playerFolder and playerFolder.Parent) then continue end
				
				local codesFolder = playerFolder:FindFirstChild("Code")
				if not codesFolder then continue end
				
				for _, codeValue in ipairs(codesFolder:GetChildren()) do
					if not Enableds.Code then break end
					if not (codeValue and codeValue.Parent) then continue end
					local codeName = codeValue.Name
					if codes[codeName] then continue end
					codes[codeName] = true
				end
			end
			
			if not Enableds.Code then break end
			
			for code, _ in pairs(codes) do
				if not Enableds.Code then break end
				Packets.RedeemCode:FireServer(code)
				task.wait(0.1)
			end
			
			codes = {}
			task.wait(30)
		end
	end)
end

local function HandleSell()
	if not Enableds.Sell then return end

	task.spawn(function()
		while Enableds.Sell do
			Packets.SellFish:FireServer("All")
			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Heavyweight Fishing",
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end
		for key, thread in pairs(Threads) do
			if thread and coroutine.status(thread) ~= "dead" then 
				task.cancel(thread)
			end
		end
	end
})

Window:AddToggle({
	Text = "Auto Fishing",
	Value = false,
	Flag = "fishing_enabled",
	Callback = function(value)
		Enableds.Fishing = value
		HandleFishing()
	end
})

Window:AddButton({
	Text = "Hook Point",
	MethodType = "DoubleClick",
	Callback = function()
		local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
		if rootPart then
		   HookCFrame = rootPart.CFrame
		end
	end
})

Window:AddToggle({
	Text = "Sell All",
	Value = false,
	Flag = "sell_enabled",
	Callback = function(value)
		Enableds.Sell = value
		HandleSell()
	end
})

Window:AddToggle({
	Text = "Claim Code",
	Value = false,
	Flag = "code_enabled",
	Callback = function(value)
		Enableds.Code = value
		HandleCode()
	end
})

Window:AddToggle({
	Text = "Claim Quest",
	Value = false,
	Flag = "quest_enabled",
	Callback = function(value)
		Enableds.Quest = value
		HandleQuest()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
