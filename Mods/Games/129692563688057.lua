local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paazlis/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local RunService = Services.RunService
local TweenService = Services.TweenService

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera
local objectFolder = workspace:WaitForChild("Food")

local Enableds, Connections = {["Evolve"] = false, ["Food"] = false}, {}

local EvolveHudButton = nil
local MaxDistance = 100
local TeleportTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function HandleEvolve()
	if not Enableds.Evolve then return end

	task.spawn(function()
		while Enableds.Evolve do
			local hudButton = PlayerGui:QueryDescendants("#Experience > #Container > #Evolve")[1]
			EvolveHudButton = EvolveHudButton or hudButton

			if EvolveHudButton and EvolveHudButton.Visible == true then
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
			task.wait()
			local rootPart = Character ~= nil and Character.Parent ~= nil and (Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart"))
			local humanoid = Character ~= nil and Character.Parent ~= nil and Character:FindFirstChildOfClass("Humanoid")
			
			if objectFolder and rootPart and humanoid then
				for _, part in ipairs(objectFolder:GetChildren()) do
					if not Enableds.Food then break end
					if not (rootPart and rootPart.Parent) then break end

					if part and part.Parent and part:IsA("BasePart") then
						local worldDistance = (Camera.CFrame.Position - part.Position).Magnitude
						if worldDistance <= MaxDistance then
							local startCFrame = Character:GetPivot()
							local targetCFrame = part.CFrame
							local duration = (worldDistance / humanoid.WalkSpeed)
							local elapsedTime = 0

							while elapsedTime < duration and Enableds.Food and Character and Character.Parent do
								local deltaTime = RunService.Heartbeat:Wait()
								elapsedTime = elapsedTime + deltaTime
								local alpha = math.clamp(elapsedTime / duration, 0, 1)
								if TeleportTweenInfo then
									alpha = TweenService:GetValue(alpha, TeleportTweenInfo.EasingStyle, TeleportTweenInfo.EasingDirection)
								end
								local orientation = rootPart.Orientation
								local rotation = CFrame.fromEulerAngles(math.rad(orientation.X), math.rad(orientation.Y), math.rad(orientation.Z), Enum.RotationOrder.YXZ)
								startCFrame = CFrame.new(startCFrame.X, rootPart.Position.Y, startCFrame.Z) * rotation
								local endCFrame =  CFrame.new(Vector3.new(targetCFrame.Position.X, math.max(targetCFrame.Position.Y, rootPart.Position.Y), targetCFrame.Position.Z)) * rotation
								Character:PivotTo(startCFrame:Lerp(endCFrame, alpha))
							end
						end
						task.wait(0.1)
					end
				end
			end

			task.wait(1)
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "My Dino Life", 
	Destroying = function()
		for key in pairs(Enableds) do
			Enableds[key] = false
		end

		for _, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end
	end
})

Window:AddSlider({
	Text = "Distance", 
	Range = {50, 1000}, 
	Value = 100,
	Increment = 1,
	Callback = function(value)
		MaxDistance = value
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
