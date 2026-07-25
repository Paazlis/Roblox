


-- auto critical --
game:GetService("Players").LocalPlayer.PlayerGui.CritUI


local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Packets = {
  ["Click"] = ReplicatedStorage:QueryDescendants("#Remotes > #Click")[1]
}

local Enableds, Connections = {["Click"] = false, ["Rebirth"] = false}, {}
local RebirthFrame, RebirthFill, RebirthButton = PlayerGui:QueryDescendants("#Rebirth > #Container > #Content")[1], nil, nil

if RebirthFrame then
   RebirthFill, RebirthButton = RebirthFrame:QueryDescendants("#Bar > #CanvasGroup > #InsideBar")[1], RebirthFrame:FindFirstChild("ClaimBtn")
end
-- Auto Rebirth --
game:GetService("Players").LocalPlayer.PlayerGui.Rebirth.Container.Background.Content.ClaimBtn
game:GetService("Players").LocalPlayer.PlayerGui.Rebirth.Container.Background.Content.Bar.CanvasGroup.InsideBar.Position.X.Scale >= 0

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function IsFillFull(fill)
	if fill.Size.X.Scale >= 1 then
		return true
	end
	return false
end

local function HandleFlip()
  task.spawn(function()
      while Enableds.Click do
         Packets.Click:FireServer()
      end
  end)
end

local Window = UI:CreateWindow({
	Name = "Butterfly Legends",
	Destroying = function()
		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end

		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
	end
})

Window:AddToggle({
	Text = "Fast Flip",
	Value = false,
	Flag = "flip_enabled",
	Callback = function(value)
		Enableds.Click = value

		if value then 
			 HandleFlip()
		end
	end
})


Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
		if value then
			RebirthButton = RebirthButton or RebirthFrame:FindFirstChild("Rebirth")
			RebirthFill = RebirthFill or RebirthFrame:QueryDescendants("#Bar > #Progress")[1]
			
			Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
				if IsFillFull(RebirthFill) then
					FireButton(RebirthButton)
				end
			end)

			if IsFillFull(RebirthFill) then
				FireButton(RebirthButton)
			end
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
