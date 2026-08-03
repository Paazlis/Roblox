local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Remove this
task.spawn(function()
	for _, v in pairs(Character:GetChildren()) do
		if v:IsA("SurfaceGui") or v:IsA("BillboardGui") then
			v.Enabled = false
		end
	end
end)

local Packets = {}
local Enableds, Connections = {["Fishing"] = false, ["Code"] = false, ["Sell"] = false, ["Quest"] = false}, {}

local PlayerDataFolder = ReplicatedStorage:FindFirstChild("Data")

Packets.RedeemCode = ReplicatedStorage:QueryDescendants("#Events > #RedeemCode")[1]
Packets.SellFish = ReplicatedStorage:QueryDescendants("#Events > #SellFish")[1]

local CollectSecretStarButton = nil

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

local function HandleFishing()
	if not Enableds.Fishing then return end
	
	Packets.Fishing = ReplicatedStorage:QueryDescendants("#Events > #Fishing")[1]
	Packets.FishingMinigame = ReplicatedStorage:QueryDescendants("#Events > #FishingMinigame")[1]

	local fishingCFrame = CFrame.new(-309.3076171875, 9.7615242004395, 106.26274871826, -0.15476256608963, -4.7383696966108e-08, 0.98795169591904, -2.7558765935964e-08, 1, 4.3644472924598e-08, -0.98795169591904, -2.0472198158927e-08, -0.15476256608963)
		
	task.spawn(function()
		while Enableds.Fishing do
			Packets.Fishing:FireServer(fishingCFrame)
			
			local args = Packets.FishingMinigame.OnClientEvent:Wait()
			local fishId = args[3]
			
			task.wait(3)
			
			Packets.FishingMinigame:FireServer(false, fishId)
			
			--local Event = game:GetService("ReplicatedStorage").Events.FishingMinigame
			--firesignal(Event.OnClientEvent, 
			--	nil,
			--	nil,
			--	"586c9af7-45fb-4c2f-8f7c-6f8a7ef8dec0"
			--)

			-- click --
			--local Event = game:GetService("ReplicatedStorage").Events.UpdateFishProgression
			--Event:FireServer()

			--game:GetService("Players").LocalPlayer.PlayerGui.MainGui.Fishing
			--game:GetService("Players").LocalPlayer.PlayerGui.MainGui.Fishing.BarFrame.Bar -- 0.45 - 0.55
			--game:GetService("Players").LocalPlayer.PlayerGui.MainGui.Mobile.Fishing


			--local Event = game:GetService("ReplicatedStorage").Events.FishingMinigame
			--Event:FireServer(
			--	false,
			--	"c8f5cc50-8f33-493f-ae9f-99212569bf2b"
			--)
			
			task.wait(1)
		end
	end)
end

local function HandleCode()
	if not Enableds.Code then return end

	task.spawn(function()
		while Enableds.Code do
			local codes = {}
			
			for _, playerFolder in ipairs({PlayerDataFolder:GetChildren()}) do
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
	Flag = "quest_enabled",
	Callback = function(value)
		Enableds.Code = value
		HandleCode()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
