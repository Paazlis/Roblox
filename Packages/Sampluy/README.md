# Sampluy Library
A simple UI library featuring a clean, polished design.
Credit To Crokyreo
### Setup The Library
```lua
local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau",true))()
```




### Adding Window
```lua
local Window = UI:CreateWindow("Your Title")
```



### Adding Button
```lua
local Button = Window:AddButton({
	Text = "Click me",
	Callback = function()
      print("hello world")
  end
})
```



### Adding Toggle
```lua
local Toggle = Window:AddToggle({
	Text = "Toggle",
  Value = false,
	Flag = "toggle",
	Callback = function(value)
      print(value)
  end
})
```



### Adding Label
```lua
local Label = Window:AddLabel({
	Text = "Credits: None",
})
```



### Adding Slider
```lua
local Slider = Window:AddSlider({
	Text = "Fov",
    Value = 10,
	Range = {70,170},
	Increment = 0.1,
    Flag = "slider",
	Callback = function(value)
      print("Fov:",value)
  end
})
```



### Adding Input
```lua
local Input = Window:AddInput({
	Text = "Speed",
    Value = "",
	Callback = function(value)
      print(value)
  end
})
```



### Adding Dropdown
```lua
local Dropdown=Folder:AddDropdown({
    Text = "Color",
    Options = {"Red", "Green", "Blue"},
	Option = "Green",
	MultipleOptions = false,
  	Flag = "color_option"
    Callback = function(option)
        print("Selected color:", unpack(option))
    end
})
```



### Adding Selector
```lua
local Selector = Window:AddSelector({
	Text = "Selector",
	Options = {"Item","Bone","Other"},
	Value = "Other",
	NoCap = true,
	Callback = function(value)
		print("Selector:",value)
	end
})
```



### Adding Folder
```lua
local Folder = Window:AddFolder("Folder")

Folder:AddToggle({
	Text = "Toggle",
    Value = false,
	Flag = "toggle2",
	Callback = function(value)
      print(value)
  end
})
```



### Destroy Function
```lua
Window:Destroy()
```



### Adding Key System
Credit To OYB Offical
```lua
local KeySystem=UI:CreateKeySystem({
	["Style"] = nil, -- The version of the gui style you want. (number or string Only)

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

	ShowYoutube = true,
	YoutubeURL = "https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ",

	-- [5] GUI Management
	Name = "Key", -- Name of the main script's GUI to check if it's already executing
	OldName = nil -- Name of the old GUI to destroy if it's already open
})
KeySystem:WaitForKey()
if not KeySystem.Pass then return end
KeySystem:Destroy() -- Destroy the key system after the user has successfully logged in
```



### GetProtectGui Function
```lua
UI:GetProtectGui(ScreenGui)
```


### Credits: Crokyreo
