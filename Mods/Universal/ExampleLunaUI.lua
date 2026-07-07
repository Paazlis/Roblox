--[[https://github.com/Nebula-Softworks/Luna-Interface-Suite/blob/main/Documentation.md]]
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

local Window = Luna:CreateWindow({
	Name = "Luna Example Window", -- This Is Title Of Your Window
	Subtitle = "A Gray Subtitle", -- A Gray Subtitle next To the main title.
	LogoID = "82795327169782", -- The Asset ID of your logo. Set to nil if you do not have a logo for Luna to use.
	LoadingEnabled = true, -- Whether to enable the loading animation. Set to false if you do not want the loading screen or have your own custom one.
	LoadingTitle = "Luna Interface Suite", -- Header for loading screen
	LoadingSubtitle = "by Nebula Softworks", -- Subtitle for loading screen

	ConfigSettings = {
		RootFolder = nil, -- The Root Folder Is Only If You Have A Hub With Multiple Game Scripts and u may remove it. DO NOT ADD A SLASH
		ConfigFolder = "Big Hub" -- The Name Of The Folder Where Luna Will Store Configs For This Script. DO NOT ADD A SLASH
	},

	KeySystem = true, -- As Of Beta 6, Luna Has officially Implemented A Key System!
	KeySettings = {
		Title = "Luna Example Key",
		Subtitle = "Key System",
		Note = "Best Key System Ever! Also, Please Use A HWID Keysystem like Pelican, Luarmor etc. that provide key strings based on your HWID since putting a simple string is very easy to bypass, the key is 1234!",
		SaveInRoot = false, -- Enabling will save the key in your RootFolder (YOU MUST HAVE ONE BEFORE ENABLING THIS OPTION)
		SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
		Key = {"1234"},
		SecondAction = {
			Enabled = true,
			Type = "Link", -- You can also put discord as an option, if your are doing that, don’t include discord.gg as Luna will auto add it as a prefix, just replace it with your identifier, example, if your are doing discord.gg/mspaint, just use mspaint.
			Parameter = ""
		}
	}
})

Window:CreateHomeTab({
	SupportedExecutors = {
		"Synapse X",
		"Krnl",
		"ProtoSmasher",
		"Fluxus",
		"Script-Ware",
		"EasyExploits",
		"Electron",
		"JJSploit",
		"Calamari",
		"SirHurt",
		"Sentinel",
		"WEAREDEVS",
		"Comet",
		"Cellery",
		"Wave",
		"CODex",
		"Delta"
	},
	DiscordInvite = "1234", -- same thing here
	Icon = 1
})

local Tab = Window:CreateTab({
	Name = "Tab Example",
	Icon = "view_in_ar",
	ImageSource = "Material",
	ShowTitle = true
})

Luna:Notification({
	Title = "Luna Notification Example",
	Icon = "notifications_active",
	ImageSource = "Material",
	Content = "This Is A Preview Of Luna's Dynamic Notification System Entailing Estimated/Calculated Wait Times, A Sleek Design, Icons, And A Glassmorphic Look"
})

local Button = Tab:CreateButton({
	Name = "Button Example!",
	Description = nil,
	Callback = function()
		print("Button Example Pressed!")
	end
})

local Toggle = Tab:CreateToggle({
	Name = "Toggle Example",
	Description = nil,
	CurrentValue = false,
	Callback = function(Value)
		print("Toggle state is:", Value)
	end
}, "Toggle")

Tab:CreateSection("This Is a section, below is a divider")
Tab:CreateDivider()

local Slider = Tab:CreateSlider({
	Name = "Slider Example",
	Range = {0, 200},
	Increment = 5,
	CurrentValue = 100,
	Callback = function(Value)
		print("Slider value is:", Value)
	end
}, "Slider")

local ColorPicker = Tab:CreateColorPicker({
	Name = "Color Picker Example",
	Color = Color3.fromRGB(86, 171, 128),
	Flag = "ColorPicker1",
	Callback = function(Value)
		print("Selected Color RGB:", Value.R * 255, Value.G * 255, Value.B * 255)
	end
}, "ColorPicker")

local Input = Tab:CreateInput({
	Name = "Dynamic Input Example",
	Description = nil,
	PlaceholderText = "Input Placeholder",
	CurrentValue = "",
	Numeric = false,
	MaxCharacters = nil,
	Enter = false,
	Callback = function(Text)
		print("Input box text:", Text)
	end
}, "Input")

local Dropdown = Tab:CreateDropdown({
	Name = "Dropdown Example",
	Description = nil,
	Options = {
		"Option 1", "Option 2", "Option 3", "Option 4", "Option 5",
		"Option 6", "Option 7", "Option 8", "Option 9", "Option 10",
		"Option 11", "Option 12", "Option 13", "Option 14", "Option 15",
		"Option 16", "Option 17", "Option 18", "Option 19", "Option 20",
		"Option 21", "Option 22", "Option 23", "Option 24", "Option 25"
	},
	CurrentOption = {"Option 1"},
	MultipleOptions = false,
	SpecialType = nil,
	Callback = function(Options)
		print("Dropdown selected:", Options)
	end
}, "Dropdown")

local Bind = Tab:CreateBind({
	Name = "Bind Example",
	Description = nil,
	CurrentBind = "Q",
	HoldToInteract = false,
	Callback = function(BindState)
		print("Keybind activated. State:", BindState)
	end,
	OnChangedCallback = function(Bind)
		print("Keybind changed to:", Bind.Name)
	end,
}, "Bind")

local Label1 = Tab:CreateLabel({
	Text = "This is a Default Label",
	Style = 1
})

local Label2 = Tab:CreateLabel({
	Text = "This is an Information Label",
	Style = 2
})

local Label3 = Tab:CreateLabel({
	Text = "This is a Warning Label",
	Style = 3
})

local Paragraph = Tab:CreateParagraph({
	Title = "Paragraph Example ",
	Text = "This Is A Paragraph. You Can Type Very Long Strings Here And They'll Automatically Fit! This Counts As A Description Right? Right? Right? Right? Right? Right? Right? Right? Right? Right? Right? Right? Right? Right? Right? Also Did I Mention This Has Rich Text? Also Did I Mention This Has Rich Text? Also Did I Mention This Has Rich Text? Also Did I Mention This Has Rich Text? Also Did I Mention This Has Rich Text? Also Did I Mention This Has Rich Text?"
})

local ThemeTab = Window:CreateTab({
	Name = "Theme Tab",
	Icon = "palette",
	ImageSource = "Material",
	ShowTitle = true
})

ThemeTab:BuildThemeSection()

local ConfigTab = Window:CreateTab({
	Name = "Config Tab",
	Icon = "settings",
	ImageSource = "Material",
	ShowTitle = true
})

ConfigTab:BuildConfigSection()
