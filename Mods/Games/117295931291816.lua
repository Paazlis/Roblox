local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local Enableds, Connections = {["DropOff"] = false, ["Tool"] = false}, {}
local HitboxCache = {}
local Packets = {
	ResourceDropOff = ReplicatedStorage:QueryDescendants("#Libs > #Remote > #__comm__ > #RE > #ResourceDropOff")[1]
}

local function HitboxAdded(descendant)
	if descendant and descendant.Parent and descendant:IsA("BasePart") and descendant.Name == "Hitbox" and descendant.Parent ~= nil and descendant.Parent.Name == "DropOffPad" then
		table.insert(HitboxCache, {
			Hitbox = descendant,
			Model = descendant.Parent
		})
	end
end

Connections.HitboxAdded = workspace.DescendantAdded:Connect(HitboxAdded)

task.spawn(function()
	for _, descendant in pairs(workspace:GetDescendants()) do
		if not (Connections.HitboxAdded and Connections.HitboxAdded.Connected) then
			break
		end
		HitboxAdded(descendant)
	end
end)

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function HandleDropOff()
	if not Enableds.DropOff then return end
	
	task.spawn(function()
		while Enableds.DropOff do
			for _, cache in ipairs(HitboxCache) do
				task.wait()
				
				if not Enableds.DropOff then break end
				
				local model = cache.Model
				if not model then continue end
				
				Packets.ResourceDropOff:FireServer(
					model,
					true
				)
				
				task.wait(0.25)
			end
			
			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "One Block",
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end

		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end

		table.clear(HitboxCache)
	end
})

Window:AddToggle({
	Text = "Drop Off",
	Value = false,
	Flag = "drop_off_enabled",
	Callback = function(value)
		Enableds.DropOff = value
		HandleDropOff()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-02-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
