local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local RunService = Services.RunService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds, Connections = {["Evolve"] = false, ["Food"] = false}, {}

local EvolveHudButton, EvolveConfirm = nil, nil
local ObjectFolder = workspace:FindFirstChild("Food")
local TpCF = nil

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

Connections.Looped = RunService.Heartbeat:Connect(function()
	if TpCF then
		Character:PivotTo(TpCF + Vector3.new(0, Character.PrimaryPart.Position.Y, 0))
	end
end)

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function HandleEvolve()
	if not Enableds.Evolve then return end
	EvolveHudButton = EvolveHudButton or PlayerGui:QueryDescendants("#Experience > #Container > #Evolve")[1]
	
	task.spawn(function()
		while Enableds.Evolve do
			if EvolveHudButton.Visible == true then
				FireButton(EvolveHudButton)
				task.wait(0.2)
				local confirmButton = PlayerGui:QueryDescendants("#Menus > #EvolveSelect > #Frame > #View > #EvolveCard > #Confirm")[1]
				if confirmButton then
					FireButton(confirmButton)
					task.wait(0.1)
				end
			end
			task.wait()
		end
	end)
end

local function HandleFood()
	if not Enableds.Food then return end

	task.spawn(function()
		while Enableds.Food do
			for _, part in ipairs(ObjectFolder:GetChildren()) do
				if not Enableds.Food then break end
				if part and part.Parent and part:IsA("BasePart") then
					TpCF = CFrame.new(part.Position)
					repeat 
						if not Enableds.Food then break end 
						local humanoid = Character:FindFirstChildOfClass("Humanoid")
						if humanoid then
							humanoid.Jump = true
						end
						task.wait(0.35) 
					until not part.Parent
					TpCF = nil
					task.wait(0.1)
				end
			end

			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "My Dino Life", 
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
	Text = "Collect Food",
	Value = false,
	Callback = function(value)
		Enableds.Food = value
		HandleFood()
	end
})

Window:AddToggle({
	Text = "Auto Evolve",
	Value = false,
	Callback = function(value)
		Enableds.Evolve = value
		HandleEvolve()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 08-13-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
