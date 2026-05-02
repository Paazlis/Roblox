local RunService=game:GetService("RunService")
local UILibrary=if RunService:IsStudio() then require(game.ReplicatedStorage.Packages.PaazlisUI) else loadstring(game:HttpGet('https://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/PaazlisUI/init.luau'))()

--! Author: oyb0i
-- KeySystem UI
--[[
	Remove this from 10 line to 17 line, 
	If you just want to create it directly from the window, then use this:
	
local Window=UILibrary:CreateWindow({
	Title="Panel",
	KeySystem=--Same as this
})
]]

local KeySystemUI=UILibrary:CreateKeySystem({
	Title          ="Panel", -- The main title shown at the top of the GUI
	Description    ="Key System", -- The text shown below the title
	UseNonce       =true, -- To prevent replay attacks and request tampering, default: false
	FileName       ="Mykey.txt", -- The name of the file where the valid key will be saved for auto-login

	-- [1] PlatoBoost Settings
	ServiceId      =24751, -- Your PlatoBoost Service ID
	PlatoSecret    ="4ce8695c-5918-4704-a778-786e74424a0e", -- Your PlatoBoost Secret Key

	-- [2] Anti-Bypass / Global Secret Variable
	Secret         ="1234", -- This makes the script ONLY run from the key script. Even if they copy the original obfuscated script to bypass the key,they won't be able to!

	-- [3] Scripts & Links
	NoScriptURL    =false, -- If you don't want to use the script URL, you can set this to true to want to disable the script from running on the client.
	ScriptURL      ="", -- The raw URL of your main script

	-- [4] Social Media Settings (Set to true to show,false to hide)
	ShowDiscord    =false,
	DiscordURL     ="https://discord.gg/kT55J724BK",

	ShowInstagram  =false,
	InstagramURL   ="https://www.instagram.com/oyb0i/",

	ShowYoutube    =false,
	YoutubeURL     ="https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ",

	-- [5] GUI Management
	OldGuiName     ="KeyUI-Old", -- Name of the old GUI to destroy if it's already open
	GuiName        ="KeyUI", -- Name of the main script's GUI to check if it's already executing
})

KeySystemUI:WaitForKey()
if not KeySystemUI.Pass then return end

--! To check if Secret key has found for specific script
-- _G[Secret]~=nil or use UILibrary:IsSecretKey(Secret)
--[[
if _G[Secret]==nil or not UILibrary:IsSecretKey(Secret) then
	LocalPlayer:Kick()
	game:Shutdown()
end
]]
local Window=UILibrary:CreateWindow({
	Title="Sample Panel",
	--KeySystem={
	--	Title="Test Panel",
	--	Description="Key System",
	--	NoScriptURL=true,
	--	Secret="12345",
	--	ShowYoutube=true,
	--}
})

--[[
Name = <string> The name of the dropdown
Value = <boolean> Open and close the dropdown
]]
local Dropdown=Window:AddContext({
	Type="Dropdown",
	Name="Something",
	Active=false,
})

-- The property of the Dropdown
task.delay(10,function()
  	Dropdown.Active=not Dropdown.Active -- To toggle of dropdown
	-- AnyUI.Parent=Dropdown -- To insert any UI to the dropdown except selector in mode is 2
end)



-- TextLabel UI
--[[
Name = <string> The name of the text label
]]
local TextLabel=Window:AddContext({
	Type="TextLabel",
	Name="Text Here"
})

TextLabel.Parent=Dropdown

-- The property of the TextLabel
task.delay(10,function()
	TextLabel.Text="Apply Text Here"
end)



-- TextButton UI
--[[
Name = <string> The name of the button
Callback = <function> The function of the button
]]
local TextButton=Window:AddContext({
	Type="TextButton",
	Name="Text Here",
	Callback=function()
		warn("Button Pressed")
	end
})
TextButton.Parent=Dropdown

-- The property of the TextButton
task.delay(10,function()
	TextButton.Text="Apply Text Here"
end)



-- TextBox UI
--[[
PlaceholderText = <string> the placeholder text of the TextBox
Callback = <function> The function of the TextBox
]]
local TextBox=Window:AddContext({
	Type="TextBox",
	PlaceholderText="Text Here",
	Callback=function(text)
		warn("Input:",text)
	end,
})
TextBox.Parent=Dropdown

-- The property of the TextBox
--task.delay(10,function()
--	TextBox.PlaceholderText="Apply Text Here"
--end)



-- Toggle UI
--[[
Value = <string> The current value of the Toggle
Callback = <function> The function of the Toggle
]]
local Toggle=Window:AddContext({
	Type="Toggle",
	Name="Text Here",
	Value=false,
	Callback=function(value)
		warn("Toggle:",value)
	end
})
Toggle.Parent=Dropdown
-- The property of the Toggle
--[[
Text = <string> The text to changed of the Toggle
Value = <string> The value to changed of the Toggle
]]
--task.delay(10,function()
--	Toggle.Value=true
--end)



-- Select UI
--[[
Pressed = <boolean> The pressed of the Select
Callback = function(value: Instance | table) The function of the Select
]]
local Select=Window:AddContext({
	Type="Select",
	Pressed=false,
	Callback=function(value)
		warn("Select:",value.Name,value.Color)
	end,
})
Select.Parent=Dropdown
--[[
Value = <Instance | table> The value to changed of the Select
]]
--task.delay(10,function()
--	Select.Value={Name="Sample",Color=Color3.fromRGB(226,155,64)}
--end)

-- Selector UI
--[[
Options = {<string>} The option text array of the Selector
Value = <string> The current value of the Selector
Mode = <number> The mode of the Selector
1/nil = Default
2 = Dropdown : This can't be parented 
Callback = function(value: string, index: number) The function of the Selector
]]
local Selector=Window:AddContext({
	Type="Selector",
	Options={"Option 1","Option 2","Option 3"},
	Value="Option 1",
	Pressed=true,
	Callback=function(value,index)
		warn("Selector:",value,index)
	end,
})

--[[
Value = <string> The value to changed of the Selector
]]
--task.delay(10,function()
--	Selector.Value="Option 2"
--end)

-- This notify is default function
UILibrary:Notify("Panel","This script has been loaded",15)

-- Modify Theme UI
task.spawn(function()
	local index=0
	while Window and Window.Parent do
		task.wait(2)
		index+=1
		local themeName=UILibrary.Theme[index]
		if not themeName then
			index=1
			themeName=UILibrary.Theme[index]
		end
		
		Window:ModifyTheme(themeName,{Recursive=true})
		
		-- This notify can changed the theme of the UI
		Window:Notify("Theme Changed",themeName,10)
	end
end)

-- Destroy
-- Window:Destroy()
