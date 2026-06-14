local UI=loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local KeySystem=UI:CreateKeySystem({
	["Version"] = nil, -- The version of the gui style you want. (Number Only)

	Title = "Panel", -- The main title shown at the top of the GUI
	Description = "Key System", -- The text shown below the title
	UseNonce = true, -- To prevent replay attacks and request tampering, default: false
	FileName = "Mykey.txt", -- The name of the file where the valid key will be saved for auto-login
	FolderName = nil, -- The name of the folder where the key is stored

	ServiceId = 0, -- Your PlatoBoost Service ID
	PlatoSecret = "", -- Your PlatoBoost Secret Key

	-- [2] Anti-Bypass / Global Secret Variable
	Secret = "1234", -- This makes the script ONLY run from the key script. Even if they copy the original obfuscated script to bypass the key, they won't be able to!

	-- [3] Scripts & Links
	ShowScript = false, -- If you don't want to use the script URL, you can set this to false to want to disable the script from running on the client.
	ScriptURL = "", -- The raw URL of your main script.

	-- [4] Social Media Settings (Set to true to show,false to hide)
	ShowDiscord = true,
	DiscordURL = "https://discord.gg/kT55J724BK",

	ShowInstagram = true,
	InstagramURL = "https://www.instagram.com/oyb0i/",

	ShowYoutube=true,
	YoutubeURL = "https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ",

	-- [5] GUI Management
	Name = "Key", -- Name of the main script's GUI to check if it's already executing
	OldName = nil -- Name of the old GUI to destroy if it's already open
})
KeySystem:WaitForKey()
if not KeySystem.Pass then return end
KeySystem:Destroy() -- Destroy the key system after the user has successfully logged in

-- Window
local Window = UI:CreateWindow({
	Name = "Targeting Tools",
	Size = UDim2.new(0,230,0,40)
})

-- Label
local Label = Window:AddLabel({Name = "SYSTEM HEADERS"})

-- Button
local Button = Window:AddButton({
	Name = "Show", 
	Callback = function()
		print("Show/Hide Pressed")
	end
})
Button:Set("Hide")

-- Toggle
local Toggle = Window:AddToggle({
	Name = "Master Override", 
	Value = false,
	Callback = function(value)
		print("Master Override:",value)
	end
})
Toggle:Set(true)

-- Slider
local Slider = Window:AddSlider({
	Version=0,
	Name = "Rate", 
	Range = {0.1, 10},
	Value = 5,
	Increment = 0.1,
	Callback = function(value)
		print("Rate:",value)
	end
})
Slider:Set(5)

-- Dropdown
local Dropdown = Window:AddDropdown({
	Name = "Fruit (Empty = All)",
	Options = {"Apple", "Banana", "Avocado", "Mango", "Durian", "Pineapple", "Peach", "Pear", "Grape", "Watermelon", "Strawberry", "Blueberry", "Orange"},
	Option = nil,
	MultipleOptions = true,
	Callback = function(option)
		print("Fruit:", unpack(option))
	end
})

-- Input
local Input = Window:AddInput({
	Name = "Speed", 
	PlaceholderText = "",
	ClearOnFocus = true,
	Callback = function(value)
		print("Speed:",value)
	end
})
Input:Set("")

-- Selector
local Selector=Window:AddSelector({
	Type="Mode",
	Options={"Item","Bone","Other"},
	Value="Other",
	NoCap=true,
	Callback=function(value,index)
		print("Mode:",value,index)
	end
})
Selector:Set("Item")

-- Select
local Select = Window:AddSelect({
	Name = "Select", 
	Callback = function(target)
		print("Select:",target)
	end
})

-- Folder 1 and Folder 2 Structure
local FolderC = Window:AddFolder("Folder1")
FolderC:Set(false)

local Folder2 = FolderC:AddFolder("Folder2")

FolderC:AddToggle({
	Name = "AppleToggle",
	Value = true,
	Callback = function(value)
		print("Apple State: ", value)
	end
})

-- Folder 2 Structure
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

-- Window:Destroy()
