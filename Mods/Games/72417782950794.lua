local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local function FireTouch(hit, target)
	if firetouchinterset then
		firetouchinterset(hit, target, true)
		task.wait()
		firetouchinterset(hit, target, false)
	end
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local Window = UI:CreateWindow({
	Name = "Clean the Backyard",
	Destroying = function()
		
	end
})

Window:AddToggle({
	Text = "Auto Clean",
	Value = false,
	Flag = "clean_enabled",
	Callback = function(value)
		
		if value then
            local energyFill = PlayerGui.InterfaceUI.StatsUI.Energy.ProgressBar.BarFrame
            local trashFill = PlayerGui.InterfaceUI.StatsUI["Garbage Bag"].ProgressBar.BarFrame
				
			local character = LocalPlayer.Character
			local saveCFrame = character.PrimaryPart.CFrame
			
			local items = workspace.ItemSpawns.StartArea.Spawn1.Items
			
			-- Typo diperbaiki: spawn1Items diganti menjadi items
			for _, item in ipairs(items:GetChildren()) do
				task.wait(0.1)

				-- IMPLEMENTASI KOMENTAR 1: Periksa Energy
				if energyFill.Size.Y.Scale <= 0 then
					local sodaCan = workspace.SpawnedDebris:FindFirstChild("SodaCan")
			
					if sodaCan then
						local sodaPart = sodaCan:FindFirstChildWhichIsA("BasePart")
						if sodaPart then
							character:PivotTo(sodaPart.CFrame + Vector3.new(0, 3, 0))
							task.wait(0.1)
						end
						
						-- Collect soda can
						ReplicatedStorage.EVENTS.PlayerEvents.CollectItem:FireServer(sodaCan)
						task.wait(0.5)
							
						-- Consume soda can 
						ReplicatedStorage.EVENTS.PlayerEvents.ConsumeItem:FireServer(false,sodaCan.Name)
						
						task.wait(0.2)
					end
				end

				local part = item:FindFirstChildWhichIsA("BasePart")
				if part then
					character:PivotTo(part.CFrame + Vector3.new(0, 3, 0))
					task.wait(0.1)
				end
				ReplicatedStorage.EVENTS.PlayerEvents.CollectItem:FireServer(item)
				task.wait(0.2)

				-- IMPLEMENTASI KOMENTAR 2: Periksa Trash Bag penuh atau tidak
				if trashFill.Size.Y.Scale < 1 then
					-- Jika belum penuh (scale kurang dari 1), skip sisa kode di bawah dan lanjut ke item berikutnya
					continue
				end
				
				character:PivotTo(saveCFrame)
				
				task.wait(0.5)
				ReplicatedStorage.EVENTS.PlayerEvents.ThrowItem:FireServer(
					Vector3.new(0.96049702167511, -0.25137504935265, -0.11939886957407),
					10
				)
			end
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
