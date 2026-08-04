local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Packets= {}
local Enableds, Connections = {["Escape"] = false, ["Upgrade"] = false}, {}
local UpgradeTypes, UpgradeActives = {"bot", "speed", "crate", "extragen"}, {}

for _, mode in ipairs(UpgradeTypes) do
    UpgradeActives[mode] = false
end

local function HandleUpgrade()
	if not Enableds.Upgrade then
		return
	end
    
	task.spawn(function()
		while Enableds.Upgrade do
			for key, active in pairs(UpgradeActives) do
                if not Enableds.Upgrade then break end
                if not active then continue end
                ReplicatedStorage.Shared.Remotes.BuyUpgrade:FireServer(key)
            end
			task.wait(0.5)
		end
	end)
end

local function HandleEscape()
	if not Enableds.Escape then return end
	
	task.spawn(function()
		while Enableds.Escape do
			ReplicatedStorage.Shared.Remotes.BotReachedExit:FireServer(1, 1, "normal")
			task.wait(0.5)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "AI Grows Smarter", 
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
	Text = "Auto Escape",
	Value = false,
	Callback = function(value)
		Enableds.Escape = value
		HandleEscape()
	end
})

Window:AddDropdown({
	Text = "Upgrade Type",
	Options = #UpgradeTypes > 0 and UpgradeTypes or {"No Upgrade Type"},
	Option = nil,
	MultipleOptions = true,
	Flag = "upgrade_options",
	Callback = function(option)
		for _, mode in ipairs(BahanTypes) do
			UpgradeActives[mode] = table.find(option, mode) ~= nil and true or false
		end
	end
})

Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Callback = function(value)
		Enableds.Upgrade = value
		HandleUpgrade()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255),
})
