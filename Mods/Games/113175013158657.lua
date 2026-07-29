if true then return end

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local ProximityPromptService = Services.ProximityPromptService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local Enableds, Connections = {["Grab"] = false, ["Shred"] = false, ["Crank"] = false}, {}

local Packets = {
	["ShredAction"] = nil
}

local NetworkFolder = ReplicatedStorage:QueryDescendants("#Packages > #Net")[1]
if NetworkFolder then
   for _, child in ipairs(NetworkFolder:GetChildren()) do
	   if child:IsA("RemoteEvent") and child.Name:find("Shred_Action") and not Packets.ShredAction then
		   Packets.ShredAction = child
	   end
   end
end


local RoomFolder = workspace:FindFirstChild("Rooms")
local RoomData = {}

if RoomFolder then
	for _, room in ipairs(RoomFolder:GetChildren()) do
		local roomName = room.Name
		local roomNum = tonumber(roomName:match("%d+") or "")
		if not roomNum or not roomName:find("Room") then continue end

		RoomData[roomName] = {
			Gameplay = room:FindFirstChild("Gameplay")
		}
	end
end

local function FirePrompt(prompt)
	if fireproximityprompt  then
		fireproximityprompt(prompt)
	end
end

local function HandleGrab()
	Connections.GrabPromptShown = ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
		if not Enableds.Grab then return end
		
		local actionText = prompt.ActionText:lower()
		local objectText = prompt.ObjectText:lower()
		
		if actionText:find("grab") or objectText:find("grab") then
			FirePrompt(prompt)
		end
	end)
end

local function HandleShred()
	task.spawn(function()
		while Enableds.Shred do
			task.wait(0.5)
			
			for key, room in pairs(RoomData) do
				local gameplay = room.Gameplay
				if not gameplay then continue end

				for _, shredder in ipairs(gameplay:GetChildren()) do
					task.wait()
					
					local prompt = shredder:QueryDescendants("#Cube > #ProximityPrompt")[1]
					if not prompt or not prompt.Parent or prompt.Parent.Name ~= "Cube" then continue end

					local cube = prompt.Parent
					Packets.ShredAction:FireServer("Insert", cube)
				end
			end
		end
		
	end)
end

local function HandleCrank()
	task.spawn(function()
		while Enableds.Crank do
			task.wait(0.5)

			for key, room in pairs(RoomData) do
				local gameplay = room.Gameplay
				if not gameplay then continue end

				for _, shredder in ipairs(gameplay:GetChildren()) do
					task.wait()

					local handle = shredder:QueryDescendants("BasePart#handle")[1]
					if not handle then continue end

					Packets.ShredAction:FireServer("Crank", handle)
				end
			end
		end

	end)
end

local Window = UI:CreateWindow({
	Name = "Shred the Secrets",
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
	end
})

Window:AddToggle({
	Text = "Auto Grab",
	Value = false,
	Callback = function(value)
		Enableds.Grab = value
		if Connections.GrabPromptShown then Connections.GrabPromptShown:Disconnect() Connections.GrabPromptShown = nil end
		if value then
			HandleGrab()
		end
	end
})

Window:AddToggle({
	Text = "Auto Shred",
	Value = false,
	Callback = function(value)
		Enableds.Shred = value
		if value then
			HandleShred()
		end
	end
})

Window:AddToggle({
	Text = "Auto Crank",
	Value = false,
	Callback = function(value)
		Enableds.Shred = value
		if value then
			HandleShred()
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
