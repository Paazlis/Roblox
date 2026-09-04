local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds = {["Pickup"] = false, ["Sell"] = false}

local Packets = {
	["Pickup"]= ReplicatedStorage:QueryDescendants("#NeedleHaystack > #PickHay")[1],
	["Sell"] = ReplicatedStorage:QueryDescendants("#NeedleHaystack > #SellHay")[1]
}
local Values = {}

local Window = UI:CreateWindow({
	Name = "Search For The Needle",
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
	end
})

Window:AddToggle({
	Text = "Auto Pickup",
	Value = false,
	Callback = function(value)
		Enableds.Pickup = value
		if not Enableds.Pickup then return end
		
		task.spawn(function()
			while Enableds.Pickup do
				local children = workspace.HaystackClient:GetChildren()
				for _, part in ipairs(children) do
					if part and part.Parent then
						local hayId = part:GetAttribute("HayId")
						if hayId ~= nil then
							Packets.Pickup:FireServer(hayId, {})
							task.wait(0.5)
						end
					end
				end
				task.wait()
			end
		end)
	end
})

Window:AddToggle({
	Text = "Auto Sell",
	Value = false,
	Callback = function(value)
		Enableds.Sell = value
		if not Enableds.Sell then return end
		task.spawn(function()
			while Enableds.Sell do
				Packets.Sell:FireServer()
				task.wait()
			end
		end)
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
