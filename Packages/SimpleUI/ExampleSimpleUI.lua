local SimpleUI=loadstring(game:HttpGet("http://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/SimpleUI/init.luau"))()

local MyWindow = SimpleUI:CreateWindow({
	Name = "Targeting Tools"
})

-- Root-level items (outside any folders)
MyWindow:CreateToggle({Name = "Master Override", CurrentValue = false})

-- Folder 1 Structure
local FolderC = MyWindow:AddFolder("Folder1")
FolderC:CreateToggle({
	Name = "AppleToggle",
	CurrentValue = true,
	Callback = function(state)
		print("Apple State: ", state)
	end
})

-- Folder 2 Structure
local Folder2 = FolderC:AddFolder("Folder2")
Folder2:CreateButton({
	Name = "BananaButton",
	Callback = function()
		print("Banana Button Pressed!")
	end
})
