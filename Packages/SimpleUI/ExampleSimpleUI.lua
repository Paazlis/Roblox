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
Folder1:CreateSlider({
	Name = "Apple Range",
	Range = {10, 100},
	CurrentValue = 50
})

-- Folder 2 Structure
local Folder2 = MyWindow:AddFolder("Folder2")
Folder2:CreateButton({
	Name = "BananaButton",
	Callback = function()
		print("Banana Button Pressed!")
	end
})
Folder2:CreateToggle({Name = "Banana Multiplier", CurrentValue = false})
