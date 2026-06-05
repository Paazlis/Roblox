local UI=loadstring(game:HttpGet("http://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/Sampluy/init.luau"))()

local Window = UI:CreateWindow({
	Name = "Targeting Tools"
})

-- Label
Window:AddLabel({Name = "SYSTEM HEADERS"})

-- Button
Window:AddButton({
	Name = "Show", 
	Callback = function()
	    print("Show Button Pressed")
	end
})

-- Toggle
Window:AddToggle({
	Name = "Master Override", 
	Value = false,
	Callback = function(value)
	    print("Master Override:",value)
	end
})

-- Slider
Window:AddSlider({
	Name = "Rate", 
	Range = {0, 10},
	Value = 5,
	Callback = function(value)
	    print("Rate:",value)
	end
})

-- Folder 1 Structure
local FolderC = Window:AddFolder("Folder1")
FolderC:AddToggle({
	Name = "AppleToggle",
	Value = true,
	Callback = function(state)
		print("Apple State: ", state)
	end
})

-- Folder 2 Structure
local Folder2 = FolderC:AddFolder("Folder2")
Folder2:AddButton({
	Name = "BananaButton",
	Callback = function()
		print("Banana Button Pressed!")
	end
})

-- Folder 3 Structure
local FolderA = Folder2:AddFolder("Folder3")
FolderA:AddButton({
	Name = "SuperButton",
	Callback = function()
		print("Super Button Pressed!")
	end
})

-- Folder 4 Structure
local Folder4 = FolderA:AddFolder("Folder4")
Folder4:AddToggle({Name = "Visible", CurrentValue = true})
Folder4:AddButton({
	Name = "GodlyButton",
	Callback = function()
		print("Godly Button Pressed!")
	end
})
