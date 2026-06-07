local UI=loadstring(game:HttpGet("http://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/Sampluy/init.luau"))()

--local KeySystem=UI:CreateKeySystem({
--	Title="Panel", -- The main title shown at the top of the GUI
--	Description="Key System", -- The text shown below the title
--	UseNonce=true, -- To prevent replay attacks and request tampering, default: false
--	FileName="Mykey.txt", -- The name of the file where the valid key will be saved for auto-login
--	FolderName=nil,

--	ServiceId=0, -- Your PlatoBoost Service ID
--	PlatoSecret="", -- Your PlatoBoost Secret Key

--	-- [2] Anti-Bypass / Global Secret Variable
--	Secret="1234", -- This makes the script ONLY run from the key script. Even if they copy the original obfuscated script to bypass the key,they won't be able to!

--	-- [3] Scripts & Links
--	NoScriptURL=false, -- If you don't want to use the script URL, you can set this to true to want to disable the script from running on the client.
--	ScriptURL="", -- The raw URL of your main script

--	-- [4] Social Media Settings (Set to true to show,false to hide)
--	ShowDiscord=false,
--	DiscordURL="https://discord.gg/kT55J724BK",

--	ShowInstagram=false,
--	InstagramURL="https://www.instagram.com/oyb0i/",

--	ShowYoutube=false,
--	YoutubeURL="https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ",

--	-- [5] GUI Management
--	OldGuiName     =nil, -- Name of the old GUI to destroy if it's already open
--	GuiName        ="KeyUI", -- Name of the main script's GUI to check if it's already executing
--})
--KeySystem:WaitForKey()
--if not KeySystem.Pass then return end
--KeySystem:Destroy() -- Destroy the key system after the user has successfully logged in

local Window = UI:CreateWindow({
	Name = "Targeting Tools"
})

-- Label
local Label = Window:AddLabel({Name = "SYSTEM HEADERS"})
Label:Set("Credit: None")

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
	Name = "Rate", 
	Range = {0, 10},
	Value = 5,
	Callback = function(value)
		print("Rate:",value)
	end
})
Slider:Set(10)

-- Folder
local Folder = Window:AddFolder({
	Name = "Expand",
	Open = true
})
Folder:Set(false)

-- Input
local Input = Folder:AddInput({
	Name = "Speed", 
	PlaceholderText = "",
	ClearOnFocus = true,
	Callback = function(value)
		print("Speed:",value)
	end
})
Input:Set("")

-- Selector
local Selector=Folder:AddSelector({
	Type="Mode",
	Options={"Item","Bone","Other"},
	Value="Other",
	NoCap=true,
	Callback=function(value,index)
		warn("Mode:",value,index)
	end,
})
Selector:Set("Item")

-- Select
local Select = Folder:AddSelect({
	Name = "Select", 
	Callback = function(value)
		print("Select:",value)
	end
})

-- Folder 1 and Folder 2 Structure
local FolderC = Window:AddFolder("Folder1")
local Folder2 = FolderC:AddFolder("Folder2")

FolderC:AddToggle({
	Name = "AppleToggle",
	Value = true,
	Callback = function(state)
		print("Apple State: ", state)
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
