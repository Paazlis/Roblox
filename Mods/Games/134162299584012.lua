local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Packets, Connections = {Coins = false, Rebirth = false}, {}, {}

local RebirthFrame, RebirthCheck, RebirthButton = PlayerGui:QueryDescendants("#RebirthGui > #Frame")[1], nil, nil

if RebirthFrame then
    RebirthCheck, RebirthButton = RebirthFrame:FindFirstChild("RebirthLockedFrame"), RebirthFrame:QueryDescendants("#RebirthFrame > #RebirthButton")[1]
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function GetPlot()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end

	for _, plot in pairs(plots:GetChildren()) do
		local ownerId = plot:GetAttribute("OwnerUserId")
		if ownerId ~= nil and ownerId == LocalPlayer.UserId then
			return plot
		end
	end

	return nil
end

local Plot = GetPlot()
local LootFolder = nil
if Plot then
    LootFolder = Plot:FindFirstChild("LootSpawned")
end

local function HandleCoins()
    if not Enableds.Coins then return end
    Packets.CurrencyPickup = Packets.CurrencyPickup or ReplicatedStorage:QueryDescendants("#RemoteEvents > #CurrencyPickup")[1]
    task.spawn(function()
        while Enableds.Coins do
            local list = {}
            for _, part in ipairs(LootFolder:GetChildren()) do
                if not Enableds.Coins then break end
                table.insert(list,part.Name)
                task.wait()
            end
            if #list > 0 and Enableds.Coins then
               Packets.CurrencyPickup:FireServer(list)
            end
            task.wait(0.5)
        end
    end)
end

local function FireRebirth()
	if Enableds.Rebirth and RebirthCheck.Visible == false then
		if not RebirthButton then return end
		print("ok rebirth")
		--FireButton(RebirthButton)
	end
end

local function HandleRebirth()
    if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
    if not Enableds.Rebirth then return end
    Connections.Rebirth = RebirthCheck:GetPropertyChangedSignal("Visible"):Connect(FireRebirth)
    task.spawn(function()
        while Enableds.Rebirth do
            FireRebirth()
            task.wait(0.5)
        end
    end)
end

local Window = UI:CreateWindow({
	Name = "Build a Gun Army", 
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
	Text = "Collect Coins",
	Value = false,
	Callback = function(value)
		Enableds.Coins = value
		HandleCoins()
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Callback = function(value)
		Enableds.Rebirth = value
		HandleRebirth()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-10-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Services.GuiService:SetGameplayPausedNotificationEnabled(false)
