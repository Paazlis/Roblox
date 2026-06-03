local SimpleUI=loadstring(game:HttpGet("http://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/SimpleUI/init.luau"))()

local MyWindow = SimpleUI:CreateWindow({
	Name = "Targeting Tools"
})

-- Root-level items (outside any folders)
MyWindow:CreateToggle({Name = "Master Override", CurrentValue = false})

-- Folder 1 Structure
local Folder1 = MyWindow:AddFolder("Folder1")
Folder1:CreateToggle({
	Name = "AppleToggle",
	CurrentValue = true,
	Callback = function(state)
		print("Apple State: ", state)
	end
})

-- Folder 2 Structure
local Folder2 = Folder1:AddFolder("Folder2")
Folder2:CreateButton({
	Name = "BananaButton",
	Callback = function()
		print("Banana Button Pressed!")
	end
})
Folder2:CreateToggle({Name = "Banana Multiplier", CurrentValue = false})
