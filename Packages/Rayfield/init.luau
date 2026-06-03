--[[
	Rayfield Interface Suite
	by Sirius

	shlex  | Designing + Programming
	iRay   | Programming
	Max    | Programming
	Damian | Programming
	
	akipox | Add Feture + Programming
	Gemini AI | Just help and fix
]]

local debugX=false

if debugX then warn("Initialising Rayfield") end

local Services=setmetatable({},{
	__index=function(_,key)
		return cloneref and cloneref(game:GetService(key)) or game:GetService(key)
	end
})

-- Services
local Players,GuiService,UserInputService,TweenService,HttpService,RunService,UserService,ContextActionService=Services["Players"],Services["GuiService"],Services["UserInputService"],Services["TweenService"],Services["HttpService"],Services["RunService"],Services["UserService"],Services["ContextActionService"]

-- Utility Management
local function PackColor(Color)
	return {R=Color.R*255,G=Color.G*255,B=Color.B*255}
end    

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R,Color.G,Color.B)
end

local function FastWait(duration)
	if not duration then return RunService.RenderStepped:Wait() end
	local start=tick()
	while tick()-start<duration do RunService.RenderStepped:Wait() end
	return start-duration
end

local function RequestSafely(options)
	local func=(syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request
	if func then 
		local success,result=pcall(func,options)
		if success then 
			return result 
		end 
		return nil,result
	end
	return nil
end

-- The function below provides a safe alternative for calling error-prone functions
-- Especially useful for filesystem function (writefile,makefolder,etc.)
local function CallSafely(func,...)
	if func then 
		local success,result=pcall(func,...) 
		if not success then warn("Rayfield | Function failed with error: ",result) 
			return false 
		else 
			return result 
		end 
	end
end

-- Loads and executes a function hosted on a remote URL. Cancels the request if the requested URL takes too long to respond.
-- Errors with the function are caught and logged to the output
local function LoadWithTimeout(url,timeout)
	assert(type(url)=="string","Expected string,got " .. type(url))
	timeout=timeout or 5
	local done,success,result=false,false,nil
	local requestThread=task.spawn(function()
		local fetchSuccess,fetchResult=pcall(game.HttpGet,game,url) -- game:HttpGet(url)
		-- If the request fails the content can be empty,even if fetchSuccess is true
		if not fetchSuccess or #fetchResult==0 then
			if #fetchResult==0 then
				fetchResult="Empty response" -- Set the error message
			end
			done,success,result=true,false,fetchResult
			return
		end
		local content=fetchResult -- Fetched content
		local executeSuccess,executResult=pcall(function()
			return loadstring(content)()
		end)
		done,success,result=true,executeSuccess,executResult
		done=true
	end)
	local timeoutThread=task.delay(timeout,function()
		if not done then
			done=true
			warn("Request for " .. url .. " timed out after " .. tostring(timeout) .. " seconds")
			task.cancel(requestThread)
			result="Request timed out"
		end
	end)
	-- Wait for completion or timeout
	while not done do
		FastWait()
	end
	-- Cancel timeout thread if still running when request completes
	if coroutine.status(timeoutThread)~="dead" then
		task.cancel(timeoutThread)
	end
	if not success then
		warn("Failed to process " .. tostring(url) .. ": " .. tostring(result))
	end
	return success and result or nil
end

local _getgenv,RequestsDisabled,SecureMode,CustomAssetId=rawget(_G,"getgenv"),false,false,nil

if _getgenv then
	local ok,result=pcall(function() return _getgenv().DISABLE_RAYFIELD_REQUESTS end)
	if ok and result then RequestsDisabled=true end
	local ok2,result2=pcall(function() return _getgenv().RAYFIELD_ASSET_ID end)
	if ok2 and type(result2)=="number" then CustomAssetId=result2 end
	local ok3,result3=pcall(function() return _getgenv().RAYFIELD_SECURE end)
	if ok3 and result3 then SecureMode=true end
end

if SecureMode then
	local _error=error
	local _assert=assert
	warn=function(...) end
	print=function(...) end
	error=function(_,level) _error("",level) end
	assert=function(v,...) return _assert(v) end
end

local Library={
	["Version"]="34",
	Flags={},
	Theme={
		"Default","Ocean","AmberGlow","Light","Amethyst","Green","Bloom","DarkBlue","Serenity",
		
		Default={
			TextColor=Color3.fromRGB(240,240,240),

			Background=Color3.fromRGB(25,25,25),
			Topbar=Color3.fromRGB(34,34,34),
			Shadow=Color3.fromRGB(20,20,20),

			NotificationBackground=Color3.fromRGB(20,20,20),
			NotificationActionsBackground=Color3.fromRGB(230,230,230),

			TabBackground=Color3.fromRGB(80,80,80),
			TabStroke=Color3.fromRGB(85,85,85),
			TabBackgroundSelected=Color3.fromRGB(210,210,210),
			TabTextColor=Color3.fromRGB(240,240,240),
			SelectedTabTextColor=Color3.fromRGB(50,50,50),

			ElementBackground=Color3.fromRGB(35,35,35),
			ElementBackgroundHover=Color3.fromRGB(40,40,40),
			SecondaryElementBackground=Color3.fromRGB(25,25,25),
			ElementStroke=Color3.fromRGB(50,50,50),
			SecondaryElementStroke=Color3.fromRGB(40,40,40),

			SliderBackground=Color3.fromRGB(50,138,220),
			SliderProgress=Color3.fromRGB(50,138,220),
			SliderStroke=Color3.fromRGB(58,163,255),

			ToggleBackground=Color3.fromRGB(30,30,30),
			ToggleEnabled=Color3.fromRGB(0,146,214),
			ToggleDisabled=Color3.fromRGB(100,100,100),
			ToggleEnabledStroke=Color3.fromRGB(0,170,255),
			ToggleDisabledStroke=Color3.fromRGB(125,125,125),
			ToggleEnabledOuterStroke=Color3.fromRGB(100,100,100),
			ToggleDisabledOuterStroke=Color3.fromRGB(65,65,65),

			DropdownSelected=Color3.fromRGB(40,40,40),
			DropdownUnselected=Color3.fromRGB(30,30,30),

			InputBackground=Color3.fromRGB(30,30,30),
			InputStroke=Color3.fromRGB(65,65,65),
			PlaceholderColor=Color3.fromRGB(178,178,178),

			PlayerPickerInStroke=Color3.fromRGB(65,65,65),
			PlayerPickerSelected=Color3.fromRGB(50,138,220)
		},

		Ocean={
			TextColor=Color3.fromRGB(230,240,240),

			Background=Color3.fromRGB(20,30,30),
			Topbar=Color3.fromRGB(25,40,40),
			Shadow=Color3.fromRGB(15,20,20),

			NotificationBackground=Color3.fromRGB(25,35,35),
			NotificationActionsBackground=Color3.fromRGB(230,240,240),

			TabBackground=Color3.fromRGB(40,60,60),
			TabStroke=Color3.fromRGB(50,70,70),
			TabBackgroundSelected=Color3.fromRGB(100,180,180),
			TabTextColor=Color3.fromRGB(210,230,230),
			SelectedTabTextColor=Color3.fromRGB(20,50,50),

			ElementBackground=Color3.fromRGB(30,50,50),
			ElementBackgroundHover=Color3.fromRGB(40,60,60),
			SecondaryElementBackground=Color3.fromRGB(30,45,45),
			ElementStroke=Color3.fromRGB(45,70,70),
			SecondaryElementStroke=Color3.fromRGB(40,65,65),

			SliderBackground=Color3.fromRGB(0,110,110),
			SliderProgress=Color3.fromRGB(0,140,140),
			SliderStroke=Color3.fromRGB(0,160,160),

			ToggleBackground=Color3.fromRGB(30,50,50),
			ToggleEnabled=Color3.fromRGB(0,130,130),
			ToggleDisabled=Color3.fromRGB(70,90,90),
			ToggleEnabledStroke=Color3.fromRGB(0,160,160),
			ToggleDisabledStroke=Color3.fromRGB(85,105,105),
			ToggleEnabledOuterStroke=Color3.fromRGB(50,100,100),
			ToggleDisabledOuterStroke=Color3.fromRGB(45,65,65),

			DropdownSelected=Color3.fromRGB(30,60,60),
			DropdownUnselected=Color3.fromRGB(25,40,40),

			InputBackground=Color3.fromRGB(30,50,50),
			InputStroke=Color3.fromRGB(50,70,70),
			PlaceholderColor=Color3.fromRGB(140,160,160),

			PlayerPickerInStroke=Color3.fromRGB(50,70,70),
			PlayerPickerSelected=Color3.fromRGB(0,140,140)
		},
		
		AmberGlow={
			TextColor=Color3.fromRGB(255,245,230),

			Background=Color3.fromRGB(45,30,20),
			Topbar=Color3.fromRGB(55,40,25),
			Shadow=Color3.fromRGB(35,25,15),

			NotificationBackground=Color3.fromRGB(50,35,25),
			NotificationActionsBackground=Color3.fromRGB(245,230,215),

			TabBackground=Color3.fromRGB(75,50,35),
			TabStroke=Color3.fromRGB(90,60,45),
			TabBackgroundSelected=Color3.fromRGB(230,180,100),
			TabTextColor=Color3.fromRGB(250,220,200),
			SelectedTabTextColor=Color3.fromRGB(50,30,10),

			ElementBackground=Color3.fromRGB(60,45,35),
			ElementBackgroundHover=Color3.fromRGB(70,50,40),
			SecondaryElementBackground=Color3.fromRGB(55,40,30),
			ElementStroke=Color3.fromRGB(85,60,45),
			SecondaryElementStroke=Color3.fromRGB(75,50,35),

			SliderBackground=Color3.fromRGB(220,130,60),
			SliderProgress=Color3.fromRGB(250,150,75),
			SliderStroke=Color3.fromRGB(255,170,85),

			ToggleBackground=Color3.fromRGB(55,40,30),
			ToggleEnabled=Color3.fromRGB(240,130,30),
			ToggleDisabled=Color3.fromRGB(90,70,60),
			ToggleEnabledStroke=Color3.fromRGB(255,160,50),
			ToggleDisabledStroke=Color3.fromRGB(110,85,75),
			ToggleEnabledOuterStroke=Color3.fromRGB(200,100,50),
			ToggleDisabledOuterStroke=Color3.fromRGB(75,60,55),

			DropdownSelected=Color3.fromRGB(70,50,40),
			DropdownUnselected=Color3.fromRGB(55,40,30),

			InputBackground=Color3.fromRGB(60,45,35),
			InputStroke=Color3.fromRGB(90,65,50),
			PlaceholderColor=Color3.fromRGB(190,150,130),

			PlayerPickerInStroke=Color3.fromRGB(90,65,50),
			PlayerPickerSelected=Color3.fromRGB(250,150,75)
		},
		
		Light={
			TextColor=Color3.fromRGB(40,40,40),

			Background=Color3.fromRGB(245,245,245),
			Topbar=Color3.fromRGB(230,230,230),
			Shadow=Color3.fromRGB(200,200,200),

			NotificationBackground=Color3.fromRGB(250,250,250),
			NotificationActionsBackground=Color3.fromRGB(240,240,240),

			TabBackground=Color3.fromRGB(235,235,235),
			TabStroke=Color3.fromRGB(215,215,215),
			TabBackgroundSelected=Color3.fromRGB(255,255,255),
			TabTextColor=Color3.fromRGB(80,80,80),
			SelectedTabTextColor=Color3.fromRGB(0,0,0),

			ElementBackground=Color3.fromRGB(240,240,240),
			ElementBackgroundHover=Color3.fromRGB(225,225,225),
			SecondaryElementBackground=Color3.fromRGB(235,235,235),
			ElementStroke=Color3.fromRGB(210,210,210),
			SecondaryElementStroke=Color3.fromRGB(210,210,210),

			SliderBackground=Color3.fromRGB(150,180,220),
			SliderProgress=Color3.fromRGB(100,150,200),
			SliderStroke=Color3.fromRGB(120,170,220),

			ToggleBackground=Color3.fromRGB(220,220,220),
			ToggleEnabled=Color3.fromRGB(0,146,214),
			ToggleDisabled=Color3.fromRGB(150,150,150),
			ToggleEnabledStroke=Color3.fromRGB(0,170,255),
			ToggleDisabledStroke=Color3.fromRGB(170,170,170),
			ToggleEnabledOuterStroke=Color3.fromRGB(100,100,100),
			ToggleDisabledOuterStroke=Color3.fromRGB(180,180,180),

			DropdownSelected=Color3.fromRGB(230,230,230),
			DropdownUnselected=Color3.fromRGB(220,220,220),

			InputBackground=Color3.fromRGB(240,240,240),
			InputStroke=Color3.fromRGB(180,180,180),
			PlaceholderColor=Color3.fromRGB(140,140,140),

			PlayerPickerInStroke=Color3.fromRGB(180,180,180),
			PlayerPickerSelected=Color3.fromRGB(100,150,200)
		},
		
		Amethyst={
			TextColor=Color3.fromRGB(240,240,240),

			Background=Color3.fromRGB(30,20,40),
			Topbar=Color3.fromRGB(40,25,50),
			Shadow=Color3.fromRGB(20,15,30),

			NotificationBackground=Color3.fromRGB(35,20,40),
			NotificationActionsBackground=Color3.fromRGB(240,240,250),

			TabBackground=Color3.fromRGB(60,40,80),
			TabStroke=Color3.fromRGB(70,45,90),
			TabBackgroundSelected=Color3.fromRGB(180,140,200),
			TabTextColor=Color3.fromRGB(230,230,240),
			SelectedTabTextColor=Color3.fromRGB(50,20,50),

			ElementBackground=Color3.fromRGB(45,30,60),
			ElementBackgroundHover=Color3.fromRGB(50,35,70),
			SecondaryElementBackground=Color3.fromRGB(40,30,55),
			ElementStroke=Color3.fromRGB(70,50,85),
			SecondaryElementStroke=Color3.fromRGB(65,45,80),

			SliderBackground=Color3.fromRGB(100,60,150),
			SliderProgress=Color3.fromRGB(130,80,180),
			SliderStroke=Color3.fromRGB(150,100,200),

			ToggleBackground=Color3.fromRGB(45,30,55),
			ToggleEnabled=Color3.fromRGB(120,60,150),
			ToggleDisabled=Color3.fromRGB(94,47,117),
			ToggleEnabledStroke=Color3.fromRGB(140,80,170),
			ToggleDisabledStroke=Color3.fromRGB(124,71,150),
			ToggleEnabledOuterStroke=Color3.fromRGB(90,40,120),
			ToggleDisabledOuterStroke=Color3.fromRGB(80,50,110),

			DropdownSelected=Color3.fromRGB(50,35,70),
			DropdownUnselected=Color3.fromRGB(35,25,50),

			InputBackground=Color3.fromRGB(45,30,60),
			InputStroke=Color3.fromRGB(80,50,110),
			PlaceholderColor=Color3.fromRGB(178,150,200),

			PlayerPickerInStroke=Color3.fromRGB(80,50,110),
			PlayerPickerSelected=Color3.fromRGB(130,80,180)
		},
		
		Green={
			TextColor=Color3.fromRGB(30,60,30),

			Background=Color3.fromRGB(235,245,235),
			Topbar=Color3.fromRGB(210,230,210),
			Shadow=Color3.fromRGB(200,220,200),

			NotificationBackground=Color3.fromRGB(240,250,240),
			NotificationActionsBackground=Color3.fromRGB(220,235,220),

			TabBackground=Color3.fromRGB(215,235,215),
			TabStroke=Color3.fromRGB(190,210,190),
			TabBackgroundSelected=Color3.fromRGB(245,255,245),
			TabTextColor=Color3.fromRGB(50,80,50),
			SelectedTabTextColor=Color3.fromRGB(20,60,20),

			ElementBackground=Color3.fromRGB(225,240,225),
			ElementBackgroundHover=Color3.fromRGB(210,225,210),
			SecondaryElementBackground=Color3.fromRGB(235,245,235),
			ElementStroke=Color3.fromRGB(180,200,180),
			SecondaryElementStroke=Color3.fromRGB(180,200,180),

			SliderBackground=Color3.fromRGB(90,160,90),
			SliderProgress=Color3.fromRGB(70,130,70),
			SliderStroke=Color3.fromRGB(100,180,100),

			ToggleBackground=Color3.fromRGB(215,235,215),
			ToggleEnabled=Color3.fromRGB(60,130,60),
			ToggleDisabled=Color3.fromRGB(150,175,150),
			ToggleEnabledStroke=Color3.fromRGB(80,150,80),
			ToggleDisabledStroke=Color3.fromRGB(130,150,130),
			ToggleEnabledOuterStroke=Color3.fromRGB(100,160,100),
			ToggleDisabledOuterStroke=Color3.fromRGB(160,180,160),

			DropdownSelected=Color3.fromRGB(225,240,225),
			DropdownUnselected=Color3.fromRGB(210,225,210),

			InputBackground=Color3.fromRGB(235,245,235),
			InputStroke=Color3.fromRGB(180,200,180),
			PlaceholderColor=Color3.fromRGB(120,140,120),

			PlayerPickerInStroke=Color3.fromRGB(80,50,110),
			PlayerPickerSelected=Color3.fromRGB(70,130,70)
		},
		
		Bloom={
			TextColor=Color3.fromRGB(60,40,50),

			Background=Color3.fromRGB(255,240,245),
			Topbar=Color3.fromRGB(250,220,225),
			Shadow=Color3.fromRGB(230,190,195),

			NotificationBackground=Color3.fromRGB(255,235,240),
			NotificationActionsBackground=Color3.fromRGB(245,215,225),

			TabBackground=Color3.fromRGB(240,210,220),
			TabStroke=Color3.fromRGB(230,200,210),
			TabBackgroundSelected=Color3.fromRGB(255,225,235),
			TabTextColor=Color3.fromRGB(80,40,60),
			SelectedTabTextColor=Color3.fromRGB(50,30,50),

			ElementBackground=Color3.fromRGB(255,235,240),
			ElementBackgroundHover=Color3.fromRGB(245,220,230),
			SecondaryElementBackground=Color3.fromRGB(255,235,240),
			ElementStroke=Color3.fromRGB(230,200,210),
			SecondaryElementStroke=Color3.fromRGB(230,200,210),

			SliderBackground=Color3.fromRGB(240,130,160),
			SliderProgress=Color3.fromRGB(250,160,180),
			SliderStroke=Color3.fromRGB(255,180,200),

			ToggleBackground=Color3.fromRGB(240,210,220),
			ToggleEnabled=Color3.fromRGB(255,140,170),
			ToggleDisabled=Color3.fromRGB(200,180,185),
			ToggleEnabledStroke=Color3.fromRGB(250,160,190),
			ToggleDisabledStroke=Color3.fromRGB(210,180,190),
			ToggleEnabledOuterStroke=Color3.fromRGB(220,160,180),
			ToggleDisabledOuterStroke=Color3.fromRGB(190,170,180),

			DropdownSelected=Color3.fromRGB(250,220,225),
			DropdownUnselected=Color3.fromRGB(240,210,220),

			InputBackground=Color3.fromRGB(255,235,240),
			InputStroke=Color3.fromRGB(220,190,200),
			PlaceholderColor=Color3.fromRGB(170,130,140),

			PlayerPickerSelected=Color3.fromRGB(250,160,180)
		},
		
		DarkBlue={
			TextColor=Color3.fromRGB(230,230,230),

			Background=Color3.fromRGB(20,25,30),
			Topbar=Color3.fromRGB(30,35,40),
			Shadow=Color3.fromRGB(15,20,25),

			NotificationBackground=Color3.fromRGB(25,30,35),
			NotificationActionsBackground=Color3.fromRGB(45,50,55),

			TabBackground=Color3.fromRGB(35,40,45),
			TabStroke=Color3.fromRGB(45,50,60),
			TabBackgroundSelected=Color3.fromRGB(40,70,100),
			TabTextColor=Color3.fromRGB(200,200,200),
			SelectedTabTextColor=Color3.fromRGB(255,255,255),

			ElementBackground=Color3.fromRGB(30,35,40),
			ElementBackgroundHover=Color3.fromRGB(40,45,50),
			SecondaryElementBackground=Color3.fromRGB(35,40,45),
			ElementStroke=Color3.fromRGB(45,50,60),
			SecondaryElementStroke=Color3.fromRGB(40,45,55),

			SliderBackground=Color3.fromRGB(0,90,180),
			SliderProgress=Color3.fromRGB(0,120,210),
			SliderStroke=Color3.fromRGB(0,150,240),

			ToggleBackground=Color3.fromRGB(35,40,45),
			ToggleEnabled=Color3.fromRGB(0,120,210),
			ToggleDisabled=Color3.fromRGB(70,70,80),
			ToggleEnabledStroke=Color3.fromRGB(0,150,240),
			ToggleDisabledStroke=Color3.fromRGB(75,75,85),
			ToggleEnabledOuterStroke=Color3.fromRGB(20,100,180),
			ToggleDisabledOuterStroke=Color3.fromRGB(55,55,65),

			DropdownSelected=Color3.fromRGB(30,70,90),
			DropdownUnselected=Color3.fromRGB(25,30,35),

			InputBackground=Color3.fromRGB(25,30,35),
			InputStroke=Color3.fromRGB(45,50,60),
			PlaceholderColor=Color3.fromRGB(150,150,160),

			PlayerPickerSelected=Color3.fromRGB(0,120,210)
		},
		
		Serenity={
			TextColor=Color3.fromRGB(50,55,60),
			Background=Color3.fromRGB(240,245,250),
			Topbar=Color3.fromRGB(215,225,235),
			Shadow=Color3.fromRGB(200,210,220),

			NotificationBackground=Color3.fromRGB(210,220,230),
			NotificationActionsBackground=Color3.fromRGB(225,230,240),

			TabBackground=Color3.fromRGB(200,210,220),
			TabStroke=Color3.fromRGB(180,190,200),
			TabBackgroundSelected=Color3.fromRGB(175,185,200),
			TabTextColor=Color3.fromRGB(50,55,60),
			SelectedTabTextColor=Color3.fromRGB(30,35,40),

			ElementBackground=Color3.fromRGB(210,220,230),
			ElementBackgroundHover=Color3.fromRGB(220,230,240),
			SecondaryElementBackground=Color3.fromRGB(200,210,220),
			ElementStroke=Color3.fromRGB(190,200,210),
			SecondaryElementStroke=Color3.fromRGB(180,190,200),

			SliderBackground=Color3.fromRGB(200,220,235), -- Lighter shade
			SliderProgress=Color3.fromRGB(70,130,180),
			SliderStroke=Color3.fromRGB(150,180,220),

			ToggleBackground=Color3.fromRGB(210,220,230),
			ToggleEnabled=Color3.fromRGB(70,160,210),
			ToggleDisabled=Color3.fromRGB(180,180,180),
			ToggleEnabledStroke=Color3.fromRGB(60,150,200),
			ToggleDisabledStroke=Color3.fromRGB(140,140,140),
			ToggleEnabledOuterStroke=Color3.fromRGB(100,120,140),
			ToggleDisabledOuterStroke=Color3.fromRGB(120,120,130),

			DropdownSelected=Color3.fromRGB(220,230,240),
			DropdownUnselected=Color3.fromRGB(200,210,220),

			InputBackground=Color3.fromRGB(220,230,240),
			InputStroke=Color3.fromRGB(180,190,200),
			PlaceholderColor=Color3.fromRGB(150,150,150),

			PlayerPickerSelected=Color3.fromRGB(70,130,180)
		},
	}
}

local SecureWarnings,CustomAssets={},{}

local function SecureNotify(key,title,content)
	if SecureWarnings[key] then return end
	SecureWarnings[key]=true
	task.spawn(function()
		while not Library or not Library.Notify do FastWait(1) end
		Library:Notify({Title=title,Content=content,Duration=8})
	end)
end

local InterfaceBuild,Release,RayfieldFolder,ConfigExtension="UU2NX","Build 1.746","Rayfield",".rfld"
local ConfigFolder=RayfieldFolder.."/Configurations"
local ThemeList={"Default","Serenity"}

local SettingsData={
	General={
		rayfieldOpen={Type="bind",Value="K",Name="Rayfield Keybind"},
		themes={Type="Selector",Name="Theme",Option=ThemeList[1],Options=ThemeList}
	},
	System={
		usageAnalytics={Type="toggle",Value=true,Name="Anonymised Analytics"},
	}
}

-- Settings that have been overridden by the developer. These will not be saved to the user's configuration file
-- Overridden settings always take precedence over settings in the configuration file,and are cleared if the user changes the setting in the UI
local OverriddenSettings={} -- For example,overriddenSettings["System.rayfieldOpen"]="J"

local function OverrideSetting(category,name,value)
	OverriddenSettings[category .. "." .. name]=value
end

local function GetSetting(category,name)
	local overriddenValue=OverriddenSettings[category.."."..name]
	if overriddenValue~=nil then
		return overriddenValue
	end
	local settingObject=nil
	if SettingsData[category]~=nil then
		settingObject=SettingsData[category][name]
	end
	local settingValue=settingObject~=nil and settingObject.Value or nil
	return settingValue
end

-- If requests/analytics have been disabled by developer, set the user-facing setting to false as well
if RequestsDisabled then
	OverrideSetting("System","usageAnalytics",false)
end

-- Environment Check
local IsStudio=RunService:IsStudio() or false
local SettingsCreated=false
local SettingsInitialized=false -- Whether the UI elements in the settings page have been set to the proper values
--local Prompt=UseStudio and require(script.Parent.prompt) or LoadWithTimeout("https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/refs/heads/request/prompt.lua")

-- Validate prompt loaded correctly
--if not Prompt and not IsStudio then
--	if debugX then
--		warn("Failed to load prompt library, using fallback")
--	end
--	prompt={create=function() end}
--end


local function ToDefaults(options,defaults)
	defaults=defaults or {}
	options=options or {}
	for key,value in pairs(options) do
		if value~=nil then
			if type(value)=="table" and type(defaults[key])=="table" then
				defaults[key]=ToDefaults(value,defaults[key])
			else
				defaults[key]=value
			end
		end
	end
	return defaults
end

-- Ensures a folder exists by creating it if needed
local function EnsureFolder(folderPath)
	if isfolder and not CallSafely(isfolder,folderPath) then 
		if makefolder then
			CallSafely(makefolder,folderPath) 
		end
	end
end

local function LoadSettings()
	local file=nil
	local success,result=pcall(function()
		if isfolder and CallSafely(isfolder,RayfieldFolder) then 
			if isfile and readfile and 
				CallSafely(isfile,RayfieldFolder.."/settings"..ConfigExtension) then 
				file=CallSafely(readfile,RayfieldFolder.."/settings"..ConfigExtension) 
			end 
		end
		if IsStudio then file=[[{"General":{"rayfieldOpen":{"Value":"K","Type":"bind","Name":"Rayfield Keybind","Element":{"HoldToInteract":false,"Ext":true,"Name":"Rayfield Keybind","Set":null,"CallOnChange":true,"Callback":null,"Keybind":"K"}}},"System":{"usageAnalytics":{"Value":false,"Type":"toggle","Name":"Anonymised Analytics","Element":{"Ext":true,"Name":"Anonymised Analytics","Set":null,"CurrentValue":false,"Callback":null}}}}]] end
		if file then 
			local decodeSuccess,decodedFile=pcall(function() 
				return HttpService:JSONDecode(file) 
			end) 
			file=decodeSuccess and decodedFile or {}
		else 
			file={} 
		end
		if not SettingsCreated then return end
		if next(file)~=nil then
			for categoryName,settingCategory in pairs(SettingsData) do
				if file[categoryName] then
					for settingName,settingValue in pairs(settingCategory) do
						if file[categoryName][settingName] then
							settingValue.Value=file[categoryName][settingName].Value
							settingValue.Element:Set(GetSetting(categoryName,settingName))
						end
					end
				end
			end
		else
			for settingKey,settingValue in OverriddenSettings do
				local split=string.split(settingKey,".")
				assert(#split==2,"Rayfield | Invalid overridden setting name: " .. SettingName)
				local categoryName,settingName=split[1],split[2]
				if SettingsData[categoryName] and SettingsData[categoryName][settingName] then
					SettingsData[categoryName][settingName].Element:Set(settingValue)
				end
			end
		end
		SettingsInitialized=true
	end)
	if not success then  
		if writefile then warn("Rayfield had an issue accessing configuration saving capability.") end 
	else
		if debugX then warn("Settings Loaded") end
	end
end

if debugX then warn("Loading Settings Configuration") end

LoadSettings()

do
	--local ANALYTICS_TOKEN="05de7f9fd320d3b8428cd1c77014a337b85b6c8efee2c5914f5ab5700c354b9a"

	--local Reporter=nil
	--if not requestsDisabled and not UseStudio then
	--	local fetchSuccess,fetchResult=pcall(game.HttpGet,game,"https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/reporter.lua")
	--	if fetchSuccess and #fetchResult>0 then
	--		local execSuccess,Analytics=pcall(function() return (loadstring(fetchResult))() end)
	--		if execSuccess and Analytics then
	--			pcall(function() reporter=Analytics.new({url="https://rayfield-collect.sirius-software-ltd.workers.dev",token=ANALYTICS_TOKEN,product_name="Rayfield",category="UILibrary"}) end)
	--		end
	--	end
	--end

	--local promptUser=2

	--if promptUser==1 and prompt and prompt.create then
	--	prompt.create("Be cautious when running scripts", [[Please be careful when running scripts from unknown developers. This script has already been ran. <font transparency='0.3'>Some scripts may steal your items or in-game goods.</font>]],"Okay","",function() end)
	--end
end

if debugX then warn("Moving on to continue initialisation") end

local BaseSize=Vector2.new(1024,768)
local Connections={} -- For storing connections to disconnect when Rayfield is destroyed

local IsMobile=false
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	IsMobile=true
end

local BuildAttempts,CorrectBuild,Warned,GlobalLoaded,RayfieldDestroyed=0,false,false,false,false

local function ResizeUIScale(ui,screenSize)
	local scaleX=screenSize.X/BaseSize.X
	local scaleY=screenSize.Y/BaseSize.Y
	local scale=math.min(scaleX,scaleY)
	local minAxis=math.min(screenSize.X,screenSize.Y)
	local isSmallScreen=minAxis<=500
	local uiScale=ui:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	uiScale.Parent=ui
	local result=1
	if scale<1 then
		result=scale*1.5
	elseif scale>1 then
		result=scale*1
	else
		result=1
	end
	uiScale.Scale=result
end

if SecureMode and not CustomAssetId then
	SecureNotify("default_asset","Secure Mode","You are using the default Rayfield asset ID. Set RAYFIELD_ASSET_ID to a custom upload to avoid detection.")
end

local AssetPath=RayfieldFolder.."/Assets"
local AssetBaseURL="https://github.com/SiriusSoftwareLtd/Rayfield/blob/main/assets/"
local AssetFiles={
	["111263549366178"]=AssetBaseURL.."111263549366178.png?raw=true",
	["77891951053543"]=AssetBaseURL.."77891951053543.png?raw=true",
	["78137979054938"]=AssetBaseURL.."78137979054938.png?raw=true",
	["80503127983237"]=AssetBaseURL.."80503127983237.png?raw=true",
	["10137832201"]=AssetBaseURL.."10137832201.png?raw=true",
	["10137941941"]=AssetBaseURL.."10137941941.png?raw=true",
	["11036884234"]=AssetBaseURL.."11036884234.png?raw=true",
	["11413591840"]=AssetBaseURL.."11413591840.png?raw=true",
	["11745872910"]=AssetBaseURL.."11745872910.png?raw=true",
	["12577727209"]=AssetBaseURL.."12577727209.png?raw=true",
	["18458939117"]=AssetBaseURL.."18458939117.png?raw=true",
	["3259050989"]=AssetBaseURL.."3259050989.png?raw=true",
	["3523728077"]=AssetBaseURL.."3523728077.png?raw=true",
	["3602733521"]=AssetBaseURL.."3602733521.png?raw=true",
	["IconChevronTopMedium"]=AssetBaseURL.."IconChevronTopMedium.png?raw=true",
	["4483362458"]=AssetBaseURL.."4483362458.png?raw=true",
	["5587865193"]=AssetBaseURL.."5587865193.png?raw=true",
	["IconMagnifyingGlass2"]=AssetBaseURL.."IconMagnifyingGlass2.png?raw=true",
}
for id,_ in AssetFiles do
	CustomAssets[id]=""
end

local DragOffset=255
local DragOffsetMobile=150



---- Thanks to Latte Softworks for the Lucide integration for Roblox
local Icons=IsStudio and require(script.Parent.Icons) or LoadWithTimeout("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua")
local Strs=IsStudio and require(game.ReplicatedStorage.Packages.Strs) or loadstring(game:HttpGet("https://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/Strs/init.luau"))()

---- Variables
local CFileName=nil
local CEnabled=false
local Minimised=false
local Hidden=false
local Debounce=false
local SearchOpen=false
local UseMobileSizing=false
local HideHotkeyConnection=nil -- Has to be initialized here since the connection is made later in the script

-- UI Variables
local Rayfield,Notifications,MPrompt,Main,Elements,LoadingFrame,TabList,Topbar,DragBar,DragBarInteract,DragBarCosmetic=nil,nil,nil,nil,nil,nil,nil,nil,nil,nil

local SelectedTheme=Library.Theme.Default
Library.SelectedTheme=SelectedTheme


local function CreateObject(className,properties)
	local newObject=Instance.new(className)
	local info={}

	function info:CreateObject(className,properties)
		local finalProperties=properties or {}
		finalProperties.Parent=newObject
		return CreateObject(className,finalProperties)
	end

	function info:Tween(options,callback)
		options=ToDefaults(options,{Length=0.2,Style=Enum.EasingStyle.Linear,Direction=Enum.EasingDirection.InOut})
		if type(callback)~="function" then callback=function() return end end
		local tweenInfo=TweenInfo.new(options.Length,options.Style,options.Direction)
		options.Length=nil options.Style=nil options.Direction=nil
		local tween=TweenService:Create(newObject,tweenInfo,options)
		tween:Play()
		tween.Completed:Connect(callback)
		return tween
	end

	function info:Round(radius)
		radius=radius or 6
		CreateObject("UICorner",{CornerRadius=UDim.new(0,radius),Parent=newObject})
		return info
	end

	function info:CrossFade(instance,length)
		length=length or .2
		self:Tween({ImageTransparency=1})
		instance:Tween({ImageTransparency=0})
		return info
	end

	function info:Fade(active,colorOverride,length,instant)
		active=active and true or false
		length=length or 0.2
		if not rawget(self, "FadeFrame") then
			local absoluteCorner=self.Template:FindFirstChildOfClass("UICorner")
			local fadeFrame=self:CreateObject("Frame",{
				BackgroundColor3=colorOverride or self.BackgroundColor3,
				BackgroundTransparency=(active and 1) or 0,
				Size=UDim2.fromScale(1, 1),
				Centered=true,
				ZIndex=999
			}):Round(absoluteCorner and absoluteCorner.CornerRadius.Offset or 0)
			rawset(self,"FadeFrame",fadeFrame)
		else
			self.FadeFrame.BackgroundColor3=colorOverride or self.BackgroundColor3
		end
		if instant then
			if active then
				self.FadeFrame.BackgroundTransparency=0
				self.FadeFrame.Visible=true
			else
				self.FadeFrame.BackgroundTransparency=1
				self.FadeFrame.Visible=false
			end
		else
			if active then
				self.FadeFrame.BackgroundTransparency=1
				self.FadeFrame.Visible=true
				self.FadeFrame:Tween{BackgroundTransparency=0, Length=length}
			else
				self.FadeFrame.BackgroundTransparency=0
				self.FadeFrame:Tween({BackgroundTransparency=1, Length=length}, function()
					self.FadeFrame.Visible=false
				end)
			end
		end	
		return info
	end

	function info:Stroke(color,thickness,strokeMode)
		thickness=thickness or 1
		strokeMode=strokeMode or Enum.ApplyStrokeMode.Border
		local stroke=self:CreateObject("UIStroke",{
			ApplyStrokeMode=strokeMode,
			Thickness=thickness
		})
		--if type(color)=="table" then
		--	local theme, colorAlter=color[1], color[2] or 0
		--	local themeColor=Library.CurrentTheme[theme]
		--	local modifiedColor=themeColor
		--	--if colorAlter < 0 then
		--	--	modifiedColor=Library:Darken(themeColor, -1 * colorAlter)
		--	--elseif colorAlter > 0 then
		--	--	modifiedColor=Library:Lighten(themeColor, colorAlter)
		--	--end
		--	stroke.Color=modifiedColor
		--	--table.insert(Library.ThemeObjects[theme],{stroke, "Color", theme, colorAlter})
		--elseif type(color)=="string" then
		--	--local themeColor=Library.CurrentTheme[color]
		--	--stroke.Color=themeColor
		--	--table.insert(Library.ThemeObjects[color],{stroke, "Color", color, 0})
		--else
		--	stroke.Color=color
		--end
		return info
	end

	function info:Tooltip(text)
		local tooltipLabel=self:CreateObject("TextLabel",{
			Name="Tooltip",
			Theme={
				BackgroundColor3={"Main", 10},
				TextColor3={"WeakText"}
			},
			TextSize=16,
			Text=text,
			Position=UDim2.new(0.5,0,0,-8),
			TextXAlignment=Enum.TextXAlignment.Center,
			TextYAlignment=Enum.TextYAlignment.Center,
			AnchorPoint=Vector2.new(0.5, 1),
			BackgroundTransparency=1,
			TextTransparency=1
		}):Round(5)
		tooltipLabel.Size=UDim2.fromOffset(tooltipLabel.TextBounds.X+16,tooltipLabel.TextBounds.Y+8)
		local tooltipArrow=tooltipLabel:CreateObject("ImageLabel",{
			Name="Arrow",
			Image="http://www.roblox.com/asset/?id=4292970642",
			Theme={ImageColor3={"Main", 10}},
			AnchorPoint=Vector2.new(0.5, 0),
			Rotation=180,
			Position=UDim2.fromScale(0.5, 1),
			Size=UDim2.fromOffset(10, 6),
			BackgroundTransparency=1,
			ImageTransparency=1
		})
		local hovered=false
		self.MouseEnter:Connect(function()
			hovered=true
			task.wait(0.2)
			if hovered then
				tooltipLabel:Tween{BackgroundTransparency=0.2,TextTransparency=0.2}
				tooltipArrow:Tween{ImageTransparency=0.2}
			end
		end)
		self.MouseLeave:Connect(function()
			hovered=false
			tooltipLabel:Tween{BackgroundTransparency=1, TextTransparency=1}
			tooltipArrow:Tween{ImageTransparency=1}
		end)
		return info
	end

	local customHandlers={
		Centered=function(value)
			if value then
				newObject.AnchorPoint=Vector2.new(0.5,0.5)
				newObject.Position=UDim2.fromScale(0.5,0.5)
			end	
		end,
		Theme=function(value)
			for property,obj in next,value do
				--if type(obj)=="table" then
				--	local theme,colorAlter=obj[1],obj[2] or 0
				--	local themeColor=SelectedTheme[theme]
				--	local modifiedColor=themeColor
				--	--if colorAlter<0 then
				--	--	modifiedColor=Library:Darken(themeColor,-1*colorAlter)
				--	--elseif colorAlter>0 then
				--	--	modifiedColor=Library:Lighten(themeColor,colorAlter)
				--	--end
				--	newObject[property]=modifiedColor
				--	--table.insert(Library.ThemeObjects[theme],{info,property,theme,colorAlter})
				--else
				--	local themeColor=SelectedTheme[obj]
				--	newObject[property]=themeColor
				--	--table.insert(Library.ThemeObjects[obj],{info,property,obj,0})
				--end
			end
		end
	}

	for property,value in next,properties do
		if customHandlers[property] then
			customHandlers[property](value)
		else
			newObject[property]=value
		end
	end

	return setmetatable(info,{
		__index=function(_,property)
			return newObject[property]
		end,
		__newindex=function(_,property,value)
			newObject[property]=value
		end,
	})
end


local function Tween(instance,tweenInfo,properties)
	TweenService:Create(instance,tweenInfo,properties):Play()
end

local function Tooltip(text,frame)
	local TooltipLabel=Instance.new("TextLabel")
	TooltipLabel.Name="Tooltip"
	TooltipLabel.BackgroundColor3=SelectedTheme.Topbar
	TooltipLabel.Text=text
	TooltipLabel.TextSize=14
	TooltipLabel.Font=Enum.Font.GothamMedium
	TooltipLabel.TextColor3=SelectedTheme.TextColor
	TooltipLabel.AutomaticSize=Enum.AutomaticSize.XY
	TooltipLabel.Size=UDim2.fromOffset(0, 0)
	TooltipLabel.BorderSizePixel=0
	TooltipLabel.Position=UDim2.new(0.5,0,0,0)
	TooltipLabel.TextXAlignment=Enum.TextXAlignment.Center
	TooltipLabel.TextYAlignment=Enum.TextYAlignment.Center
	TooltipLabel.AnchorPoint=Vector2.new(0.5, 1)
	TooltipLabel.BackgroundTransparency=1
	TooltipLabel.TextTransparency=1
	TooltipLabel.ZIndex=50
	TooltipLabel.Parent=frame
	local Padding=Instance.new("UIPadding")
	Padding.PaddingTop=UDim.new(0,6)
	Padding.PaddingBottom=UDim.new(0,6)
	Padding.PaddingLeft=UDim.new(0,10)
	Padding.PaddingRight=UDim.new(0,10)
	Padding.Parent=TooltipLabel
	local Corner=Instance.new("UICorner")
	Corner.CornerRadius=UDim.new(0, 6)
	Corner.Parent=TooltipLabel
	local TooltipArrow=Instance.new("ImageLabel")
	TooltipArrow.Name="Arrow"
	TooltipArrow.BackgroundColor3=SelectedTheme.Topbar
	TooltipArrow.Image="http://www.roblox.com/asset/?id=4292970642"
	TooltipArrow.AnchorPoint=Vector2.new(0.5,0)
	TooltipArrow.Rotation=180
	TooltipArrow.BorderSizePixel=0
	TooltipArrow.Position=UDim2.new(0.5,0,1,5)
	TooltipArrow.Size=UDim2.fromOffset(10,6)
	TooltipArrow.BackgroundTransparency=1
	TooltipArrow.ImageTransparency=1
	TooltipArrow.ImageColor3=SelectedTheme.TextColor
	TooltipArrow.ZIndex=50
	TooltipArrow.Parent=TooltipLabel
	local hovered=false
	frame.MouseEnter:Connect(function()
		hovered=true
		task.wait(0.2)
		if hovered then
			Tween(TooltipLabel,TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{BackgroundTransparency=0.2,TextTransparency=0.2})
			Tween(TooltipArrow,TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{BackgroundTransparency=0.2,ImageTransparency=0.2})
		end
	end)
	frame.MouseLeave:Connect(function()
		hovered=false
		Tween(TooltipLabel,TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{BackgroundTransparency=1,TextTransparency=1})
		Tween(TooltipArrow,TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{BackgroundTransparency=1,ImageTransparency=1})
	end)
	Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
		TooltipLabel.BackgroundColor3=SelectedTheme.Topbar
		TooltipLabel.TextColor3=SelectedTheme.TextColor
		TooltipArrow.BackgroundColor3=SelectedTheme.Topbar
		TooltipArrow.Image="http://www.roblox.com/asset/?id=4292970642"
		TooltipArrow.ImageColor3=SelectedTheme.TextColor
	end)
end

local function ConnectDestroying(instance,func)
	task.defer(function()
		if not (instance and instance.Parent) then func() return end
		instance.Destroying:Connect(func)
	end)
end

local function ChangeTheme(theme)
	if not Main or not Topbar then return end
	local themeType=type(theme)
	if themeType=="string" then
		SelectedTheme=Library.Theme[theme]
	elseif themeType=="table" then
		SelectedTheme=theme
	end
	Library.SelectedTheme=SelectedTheme
	Main.BackgroundColor3=SelectedTheme.Background
	Topbar.BackgroundColor3=SelectedTheme.Topbar
	Topbar.CornerRepair.BackgroundColor3=SelectedTheme.Topbar
	Main.Shadow.Image.ImageColor3=SelectedTheme.Shadow
	Topbar.ChangeSize.ImageColor3=SelectedTheme.TextColor
	Topbar.Hide.ImageColor3=SelectedTheme.TextColor
	Topbar.Search.ImageColor3=SelectedTheme.TextColor
	if Topbar:FindFirstChild("Settings") then
		Topbar.Settings.ImageColor3=SelectedTheme.TextColor
		Topbar.Divider.BackgroundColor3=SelectedTheme.ElementStroke
	end
	Main.Search.BackgroundColor3=SelectedTheme.TextColor
	Main.Search.Shadow.ImageColor3=SelectedTheme.TextColor
	Main.Search.Search.ImageColor3=SelectedTheme.TextColor
	Main.Search.Input.PlaceholderColor3=SelectedTheme.TextColor
	Main.Search.UIStroke.Color=SelectedTheme.SecondaryElementStroke
	if Main:FindFirstChild("Notice") then
		Main.Notice.BackgroundColor3=SelectedTheme.Background
	end
	if Notifications and Rayfield then
		for _,text in ipairs(Rayfield:GetDescendants()) do
			if text and text.Parent and text.Parent.Parent~=Notifications then
				if text:IsA("TextLabel") or text:IsA("TextBox") or text:IsA("TextButton") then 
					text.TextColor3=SelectedTheme.TextColor 
				end
			end
		end
	end
	if Elements then
		for _,page in ipairs(Elements:GetChildren()) do
			for _,element in ipairs(page:GetChildren()) do
				if element.ClassName=="Frame" and element.Name~="Placeholder" and element.Name~="SectionSpacing" and element.Name~="Divider" and element.Name~="SectionTitle" and element.Name~="SearchTitle-fsefsefesfsefesfesfThanks" then
					element.BackgroundColor3=SelectedTheme.ElementBackground
					element.UIStroke.Color=SelectedTheme.ElementStroke
				end
			end
		end
	end
	
end

-- Icon Library
local function GetIcon(name)
	if not Icons then
		warn("Lucide Icons: Cannot use icons as icons library is not loaded")
		return
	end
	name=string.match(string.lower(name),"^%s*(.*)%s*$") :: string
	local sizedicons=Icons['48px']
	local r=sizedicons[name]
	if not r then
		error("Lucide Icons: Failed to find icon by the name of \"" .. name .. "\"",2)
	end
	local rirs=r[2]
	local riro=r[3]
	if type(r[1])~="number" or type(rirs)~="table" or type(riro)~="table" then
		error("Lucide Icons: Internal error: Invalid auto-generated asset entry")
	end
	local irs=Vector2.new(rirs[1],rirs[2])
	local iro=Vector2.new(riro[1],riro[2])
	local assetInfo={
		id=r[1],
		imageRectSize=irs,
		imageRectOffset=iro,
	}
	return assetInfo
end

local function GetAssetUrl(id)
	local idType,assetUrl=type(id),""
	if idType=="number" then
		assetUrl="rbxassetid://" .. id
	elseif idType=="string" and not Icons then
		warn("Rayfield | Cannot use Lucide icons as icons library is not loaded")
	else
		warn("Rayfield | The icon argument must either be an icon ID (number) or a Lucide icon name (string)")
	end
	return assetUrl
end

local function IsCustomAsset(value)
	return type(value)=="string" and (string.find(value,"rbxasset://")==1 or string.find(value,"rbxthumb://")==1)
end

local function ResolveIcon(icon)
	if not icon or icon==0 then return "",nil,nil end
	if IsCustomAsset(icon) then return icon,nil,nil end
	if SecureMode then
		SecureNotify("icon_blocked","Secure Mode","Element icons using asset IDs or Lucide names are blocked. Use getcustomasset() for icons to stay undetected.")
		return "",nil,nil
	end
	if typeof(icon)=="string" and Icons then
		local asset=GetIcon(icon)
		return "rbxassetid://" .. asset.id,asset.imageRectOffset,asset.imageRectSize
	else
		return GetAssetUrl(icon),nil,nil
	end
end

local DragFuncs={
	[1]=function(options)
		local frame=options.Main or options.Frame
		local dragging,dragInput,dragStart,startPos
		local inputBeganConnection,inputChangedConnection1,inputChangedConnection2
		inputBeganConnection=frame.InputBegan:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				dragging=true 
				dragStart=input.Position 
				startPos=frame.Position
				input.Changed:Connect(function() 
					if input.UserInputState==Enum.UserInputState.End then 
						dragging=false 
					end 
				end)
			end
		end)
		inputChangedConnection1=frame.InputChanged:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then 
				dragInput=input 
			end
		end)
		inputChangedConnection2=UserInputService.InputChanged:Connect(function(input)
			if input==dragInput and dragging then
				local delta=input.Position-dragStart
				frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
			end
		end)
		ConnectDestroying(frame,function()
			inputChangedConnection2:Disconnect()
		end)
		return function()
			inputBeganConnection:Disconnect()
			inputChangedConnection1:Disconnect()
			inputChangedConnection2:Disconnect()
		end
	end,
	[2]=function(options)
		options=ToDefaults(options,{
			IsHidden=function() return Hidden end
		})
		local dragging
		local inputBegan,inputEnded,renderStepped
		local isHidden,frame,dragInteract,dragCosmetic,tapticEnabled,tapticOffset,dragObject=options.IsHidden,options.Main or options.Frame,options.DragInteract,options.DragCosmetic,options.TapticEnabled,options.TapticOffset,options.Drag or options.DragObject
		local relative=Vector2.zero
		local offset=Vector2.zero
		local screenGui=frame:FindFirstAncestorWhichIsA("ScreenGui")
		if screenGui and screenGui.IgnoreGuiInset then
			offset+=GuiService:GetGuiInset()
		end
		local function ConnectHover()
			if DragBar and tapticEnabled then
				DragBar.MouseEnter:Connect(function()
					if not dragging and not isHidden() and dragCosmetic then
						Tween(dragCosmetic,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0.5,Size=UDim2.new(0,120,0,4)})
					end
				end)
				DragBar.MouseLeave:Connect(function()
					if not dragging and not isHidden() and dragCosmetic then
						Tween(DragBarCosmetic,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0.7,Size=UDim2.new(0,100,0,4)})
					end
				end)
			end
		end
		ConnectHover()
		local inputBegan=frame.InputBegan:Connect(function(input)
			local inputType=input.UserInputType.Name
			if inputType=="MouseButton1" or inputType=="Touch" then
				dragging=true
				relative=frame.AbsolutePosition+frame.AbsoluteSize*frame.AnchorPoint-UserInputService:GetMouseLocation()
				if tapticEnabled and not Hidden and DragBarCosmetic then
					Tween(DragBarCosmetic,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,110,0,4),BackgroundTransparency=0})
				end
			end
		end)
		local inputEnded=UserInputService.InputEnded:Connect(function(input)
			if not dragging then return end
			local inputType=input.UserInputType.Name
			if inputType=="MouseButton1" or inputType=="Touch" then
				dragging=false
				if tapticEnabled and not Hidden and DragBarCosmetic then
					Tween(DragBarCosmetic,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,100,0,4),BackgroundTransparency=0.7})
				end
			end
		end)
		local renderStepped=RunService.RenderStepped:Connect(function()
			if dragging and not Hidden then
				local position=UserInputService:GetMouseLocation()+relative+offset
				if tapticEnabled and tapticOffset then
					Tween(frame,TweenInfo.new(0.4,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Position=UDim2.fromOffset(position.X,position.Y)})
					Tween(dragObject.Parent,TweenInfo.new(0.05,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Position=UDim2.fromOffset(position.X,position.Y+((UseMobileSizing and tapticOffset[2]) or tapticOffset[1]))})
				else
					if DragBar and tapticOffset then
						DragBar.Position=UDim2.fromOffset(position.X,position.Y+((UseMobileSizing and tapticOffset[2]) or tapticOffset[1]))
					end
					frame.Position=UDim2.fromOffset(position.X,position.Y)
				end
			end
		end)
		ConnectDestroying(frame,function()
			inputEnded:Disconnect()
			renderStepped:Disconnect()
		end)
		return function()
			inputBegan:Disconnect()
			renderStepped:Disconnect()
			inputEnded:Disconnect()
		end
	end
}

function Library:CreateDraggable(DragInfo)
	local success,callback=pcall(function() return DragFuncs[DragInfo.Version](DragInfo) end)
	return success and callback or function() end
end

local function LoadConfiguration(data)
	local success,data=pcall(function() return HttpService:JSONDecode(data) end)
	local changed=false
	if not success then warn("Rayfield had an issue decoding the configuration file,please try delete the file and reopen Rayfield.") return end
	for name,flag in pairs(Library.Flags) do
		local value=data[name]
		if (typeof(value)=="boolean" and value==false) or value~=nil then
			task.spawn(function()
				if flag.Type=="ColorPicker" then
					changed=true
					flag:Set(UnpackColor(value))
				else
					if (flag.Value or flag.Keybind or flag.Option or flag.Color)~=value then 
						changed=true
						flag:Set(value) 	
					end
				end
			end)
		else
			warn("Rayfield | Unable to find '"..name.. "' in the save file.")
			print("The error above may not be an issue if new elements have been added or not been set values.")
		end
	end
	return changed
end

local function SaveConfiguration()
	if not CEnabled or not GlobalLoaded then return end
	if debugX then print("Saving") end
	local data={}
	for name,flag in pairs(Library.Flags) do
		if flag.Type=="ColorPicker" then
			data[name]=PackColor(flag.Color)
		else
			if type(flag.Value)=="boolean" then
				if flag.Value==false then 
					data[name]=false 
				else 
					data[name]=flag.Keybind or flag.Option or flag.Color or flag.Value 
				end
			else
				data[name]=flag.Keybind or flag.Option or flag.Color or flag.Value
			end
		end
	end
	local dataStr=HttpService:JSONEncode(data)
	if IsStudio then
		if script.Parent:FindFirstChild("Config") then script.Parent.Config:Destroy() end
		local ScreenGui=CreateObject("ScreenGui",{
			Name="Config",
			Parent=script.Parent
		})
		local TextBox=ScreenGui:CreateObject("TextBox",{
			Size=UDim2.new(0,800,0,50),
			AnchorPoint=Vector2.new(0.5,0),
			Position=UDim2.new(0.5,0,0,30),
			Text=dataStr,
			ClearTextOnFocus=false,
			Parent=ScreenGui
		})
	end
	if debugX then warn(dataStr) end
	if writefile then CallSafely(writefile,ConfigFolder .. "/" .. CFileName .. ConfigExtension,dataStr) end
end

local function OpenSearch()
	if not Main or not TabList then return end
	SearchOpen=true
	Main.Search.BackgroundTransparency=1
	Main.Search.Shadow.ImageTransparency=1
	Main.Search.Input.TextTransparency=1
	Main.Search.Search.ImageTransparency=1
	Main.Search.UIStroke.Transparency=1
	Main.Search.Size=UDim2.new(1,0,0,80)
	Main.Search.Position=UDim2.new(0.5,0,0,70)
	Main.Search.Input.Interactable=true
	Main.Search.Visible=true
	for _,TabButton in ipairs(TabList:GetChildren()) do
		if TabButton.ClassName=="Frame" and TabButton.Name~="Placeholder" then
			TabButton.Interact.Visible=false
			Tween(TabButton,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
			Tween(TabButton.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=1})
			Tween(TabButton.Image,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=1})
			Tween(TabButton.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=1})
		end
	end
	Main.Search.Input:CaptureFocus()
	Tween(Main.Search.Shadow,TweenInfo.new(0.05,Enum.EasingStyle.Quint),{ImageTransparency=0.95})
	Tween(Main.Search,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Position=UDim2.new(0.5,0,0,57),BackgroundTransparency=0.9})
	Tween(Main.Search.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=0.8})
	Tween(Main.Search.Input,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=0.2})
	Tween(Main.Search.Search,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=0.5})
	Tween(Main.Search,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,-35,0,35)})
end

local function CloseSearch()
	if not Main or not TabList then return end
	SearchOpen=false
	Tween(Main.Search,TweenInfo.new(0.35,Enum.EasingStyle.Quint),{BackgroundTransparency=1,Size=UDim2.new(1,-55,0,30)})
	Tween(Main.Search.Search,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{ImageTransparency=1})
	Tween(Main.Search.Shadow,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{ImageTransparency=1})
	Tween(Main.Search.UIStroke,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{Transparency=1})
	Tween(Main.Search.Input,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{TextTransparency=1})
	for _,TabButton in ipairs(TabList:GetChildren()) do
		if TabButton.ClassName=="Frame" and TabButton.Name~="Placeholder" then
			TabButton.Interact.Visible=true
			if tostring(Main.Elements.UIPageLayout.CurrentPage)==TabButton.Title.Text then
				Tween(TabButton,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
				Tween(TabButton.Image,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=0})
				Tween(TabButton.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=0})
				Tween(TabButton.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=1})
			else
				Tween(TabButton,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=0.7})
				Tween(TabButton.Image,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=0.2})
				Tween(TabButton.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=0.2})
				Tween(TabButton.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=0.5})
			end
		end
	end
	Main.Search.Input.Text=''
	Main.Search.Input.Interactable=false
end

-- Sets element visibility across all tab pages (used by Hide,Unhide,Maximise,Minimise)
local function SetElementsVisible(show)
	if not Elements then return end
	for _,tab in ipairs(Elements:GetChildren()) do
		if tab.Name~="Template" and tab.ClassName=="ScrollingFrame" and tab.Name~="Placeholder" then
			for _,element in ipairs(tab:GetChildren()) do
				if element.ClassName=="Frame" then
					if element.Name=="PlayerPicker" then
						element.Visible=show
						continue
					end
					if element.Name~="SectionSpacing" and element.Name~="Placeholder" then
						if element.Name=="SectionTitle" or element.Name=='SearchTitle-fsefsefesfsefesfesfThanks' then
							Tween(element.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=show and 0.4 or 1})
						elseif element.Name=="Divider" then
							Tween(element.Divider,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=show and 0.85 or 1})
						else
							Tween(element,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=show and 0 or 1})
							Tween(element.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=show and 0 or 1})
							Tween(element.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=show and 0 or 1})
						end
						for _,child in ipairs(element:GetChildren()) do
							if child.ClassName=="Frame" or child.ClassName=="TextLabel" or child.ClassName=="TextBox" or child.ClassName=="ImageButton" or child.ClassName=="ImageLabel" then
								child.Visible=show
							end
						end
					end
				end
			end
		end
	end
end

---- Sets tab button visibility (used by Hide,Unhide,Maximise,Minimise)
local function SetTabButtonsVisible(show)
	if not TabList or not Elements then return end
	for _,tab in ipairs(TabList:GetChildren()) do
		if tab.ClassName=="Frame" and tab.Name~="Placeholder" then
			if show then
				if tostring(Elements.UIPageLayout.CurrentPage)==tab.Title.Text then
					Tween(tab,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
					Tween(tab.Image,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=0})
					Tween(tab.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=0})
					Tween(tab.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=1})
				else
					Tween(tab,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=0.7})
					Tween(tab.Image,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=0.2})
					Tween(tab.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=0.2})
					Tween(tab.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=0.5})
				end
			else
				Tween(tab,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
				Tween(tab.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=1})
				Tween(tab.Image,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=1})
				Tween(tab.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=1})
			end
		end
	end
end

local function Hide(notify)
	if not Main or not MPrompt then return end
	if MPrompt then
		MPrompt.Title.TextColor3=Color3.fromRGB(255,255,255)
		MPrompt.Position=UDim2.new(0.5,0,0,-50)
		MPrompt.Size=UDim2.new(0,40,0,10)
		MPrompt.BackgroundTransparency=1
		MPrompt.Title.TextTransparency=1
		MPrompt.Visible=true
	end
	task.spawn(CloseSearch)
	Debounce=true
	if notify then
		if IsMobile then 
			Library:Notify({Title="Interface Hidden",Content="The interface has been hidden, you can unhide the interface by tapping 'Show'.",Duration=7,Image=4400697855})
		else
			Library:Notify({Title="Interface Hidden",Content="The interface has been hidden, you can unhide the interface by tapping " .. tostring(GetSetting("General","rayfieldOpen")) .. ".",Duration=7,Image=4400697855})
		end
	end
	Tween(Main,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,470,0,0)})
	Tween(Main.Topbar,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,470,0,45)})
	Tween(Main,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
	Tween(Main.Topbar,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
	Tween(Main.Topbar.Divider,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
	Tween(Main.Topbar.CornerRepair,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
	Tween(Main.Topbar.Title,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=1})
	Tween(Main.Topbar.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Transparency=1})
	if DragBarCosmetic then
		Tween(DragBarCosmetic,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=1})
	end
	if IsMobile and MPrompt then
		Tween(MPrompt,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,120,0,30),Position=UDim2.new(0.5,0,0,20),BackgroundTransparency=0.3})
		Tween(MPrompt.Title,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=0.3})
	end
	for _,TopbarButton in ipairs(Main.Topbar:GetChildren()) do
		if TopbarButton.ClassName=="ImageButton" then
			Tween(TopbarButton,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{ImageTransparency=1})
		end
	end
	SetTabButtonsVisible(false)
	if DragBarInteract then DragBarInteract.Visible=false end
	SetElementsVisible(false)
	FastWait(0.5)
	Main.Visible=false
	Debounce=false
end

local function Maximise()
	if not Main then return end
	Debounce=true
	Main.Topbar.ChangeSize.Image=CustomAssets["10137941941"]
	Tween(Topbar.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Transparency=1})
	Tween(Main.Shadow.Image,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{ImageTransparency=0.6})
	Tween(Main.Topbar.CornerRepair,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	Tween(Main.Topbar.Divider,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	if DragBarCosmetic then
		Tween(DragBarCosmetic,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0.7})
	end
	Tween(Main,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UseMobileSizing and UDim2.new(0,500,0,275) or UDim2.new(0,500,0,475)})
	Tween(Main.Topbar,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,500,0,45)})
	TabList.Visible=true
	FastWait(0.2)
	if Elements then
		Elements.Visible=true
	end
	SetElementsVisible(true)
	FastWait(0.1)
	SetTabButtonsVisible(true)
	FastWait(0.5)
	Debounce=false
end

local function Unhide()
	if not Main or not MPrompt then return end
	Debounce=true
	Main.Position=UDim2.new(0.5,0,0.5,0)
	Main.Visible=true
	Tween(Main,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UseMobileSizing and UDim2.new(0,500,0,275) or UDim2.new(0,500,0,475)})
	Tween(Main.Topbar,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,500,0,45)})
	Tween(Main.Shadow.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0.6})
	Tween(Main,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	Tween(Main.Topbar,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	Tween(Main.Topbar.Divider,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	Tween(Main.Topbar.CornerRepair,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	Tween(Main.Topbar.Title,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=0})
	if MPrompt then
		Tween(MPrompt,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,40,0,10),Position=UDim2.new(0.5,0,0,-50),BackgroundTransparency=1})
		Tween(MPrompt.Title,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=1})
		task.spawn(function()
			FastWait(0.5)
			MPrompt.Visible=false
		end)
	end
	if Minimised then
		task.spawn(Maximise)
	end
	if DragBar then
		DragBar.Position=UseMobileSizing and UDim2.new(0.5,0,0.5,DragOffsetMobile) or UDim2.new(0.5,0,0.5,DragOffset)
	end
	if DragBarInteract then
		DragBarInteract.Visible=true
	end
	for _,TopbarButton in ipairs(Topbar:GetChildren()) do
		if TopbarButton.ClassName=="ImageButton" then
			if TopbarButton.Name=="Icon" then
				Tween(TopbarButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0})
			else
				Tween(TopbarButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0.8})
			end
		end
	end
	SetTabButtonsVisible(true)
	SetElementsVisible(true)
	if DragBarCosmetic then
		Tween(DragBarCosmetic,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0.5})
	end
	FastWait(0.5)
	Minimised=false
	Debounce=false
end

local function Minimise()
	if not Main then return end
	Debounce=true
	Main.Topbar.ChangeSize.Image=CustomAssets["11036884234"]
	Main.Topbar.UIStroke.Color=SelectedTheme.ElementStroke
	task.spawn(CloseSearch)
	SetTabButtonsVisible(false)
	SetElementsVisible(false)
	if DragBarCosmetic then
		Tween(DragBarCosmetic,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=1})
	end
	Tween(Main.Topbar.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Transparency=0})
	Tween(Main.Shadow.Image,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{ImageTransparency=1})
	Tween(Main.Topbar.CornerRepair,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
	Tween(Main.Topbar.Divider,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
	Tween(Main,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,495,0,45)})
	Tween(Main.Topbar,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,495,0,45)})
	FastWait(0.3)
	if Elements then Elements.Visible=false end
	if TabList then TabList.Visible=false end
	FastWait(0.2)
	Debounce=false
end

local function SaveSettings()
	local data=nil
	local success,reponse=pcall(function()
		data=HttpService:JSONEncode(SettingsData)
	end)
	if success and data then
		if writefile then CallSafely(writefile,RayfieldFolder.."/settings"..ConfigExtension,data) end
	end
end

local function UpdateSettings(category,setting,value)
	if not SettingsInitialized then return end
	SettingsData[category][setting].Value=value
	OverriddenSettings[category.."."..setting]=nil 
	SaveSettings()
end

local function CreateSettings(settingsTab)
	if not (writefile and isfile and readfile and isfolder and makefolder) and not IsStudio then
		if Topbar["Settings"] then Topbar.Settings.Visible=false end
		Topbar["Search"].Position=UDim2.new(1,-75,0.5,0)
		warn("Can't create settings as no file-saving functionality is available.")
		return
	end
	for _,gui in ipairs({TabList,Elements}) do local v=gui["Rayfield Settings"] if v then v.LayoutOrder=1000 end end
	for categoryName,settingCategory in pairs(SettingsData) do
		settingsTab:CreateSection(categoryName)
		for settingName,setting in pairs(settingCategory) do
			if setting.Type=='input' then
				setting.Element=settingsTab:CreateInput({
					Name=setting.Name,
					CurrentValue=setting.Value,
					PlaceholderText=setting.Placeholder,
					Ext=true,
					RemoveTextAfterFocusLost=setting.ClearOnFocus,
					Callback=function(Value)
						UpdateSettings(categoryName,settingName,Value)
					end
				})
			elseif setting.Type=='toggle' then
				setting.Element=settingsTab:CreateToggle({
					Name=setting.Name,
					CurrentValue=setting.Value,
					Ext=true,
					Callback=function(Value)
						UpdateSettings(categoryName,settingName,Value)
					end
				})
			elseif setting.Type=='bind' then
				setting.Element=settingsTab:CreateKeybind({
					Name=setting.Name,
					Keybind=setting.Value,
					HoldToInteract=false,
					Ext=true,
					CallOnChange=true,
					Callback=function(Value)
						UpdateSettings(categoryName,settingName,Value)
					end
				})
			end
		end
	end
	SettingsCreated=true
	LoadSettings()
	SaveSettings()
end

local function FadeOutKeyUI(KeyMain)
	Tween(KeyMain,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
	Tween(KeyMain,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,467,0,175)})
	Tween(KeyMain.Shadow.Image,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{ImageTransparency=1})
	Tween(KeyMain.Title,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{TextTransparency=1})
	Tween(KeyMain.Subtitle,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=1})
	Tween(KeyMain.KeyNote,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=1})
	Tween(KeyMain.Input,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
	Tween(KeyMain.Input.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Transparency=1})
	Tween(KeyMain.Input.InputBox,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=1})
	Tween(KeyMain.NoteTitle,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{TextTransparency=1})
	Tween(KeyMain.NoteMessage,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{TextTransparency=1})
	Tween(KeyMain.Hide,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{ImageTransparency=1})
end

local function SetVisibility(visibility,notify)
	if Debounce then return end
	if visibility then
		Hidden=false
		Unhide()
	else
		Hidden=true
		Hide(notify)
	end
end

function Library:SetVisibility(visibility: boolean)
	SetVisibility(visibility,false)
end

function Library:Notify(data)
	task.spawn(function()
		if not Notifications then return end
		local layout=Notifications:FindFirstChildOfClass("UIListLayout")
		local notification=Notifications.Template:Clone()
		notification.Name=data.Title or 'No Title Provided'
		notification.Parent=Notifications
		notification.LayoutOrder=#Notifications:GetChildren()
		notification.Visible=false
		notification.Title.Text=data.Title or "Unknown Title"
		notification.Description.Text=data.Content or "Unknown Content"
		local icon=data.Image or data.Icon
		if icon then
			local image,rectOffset,rectSize=ResolveIcon(icon)
			notification.Icon.Image=image
			if rectOffset then notification.Icon.ImageRectOffset=rectOffset end
			if rectSize then notification.Icon.ImageRectSize=rectSize end
		else
			notification.Icon.Image=""
		end
		notification.Title.TextColor3=SelectedTheme.TextColor
		notification.Description.TextColor3=SelectedTheme.TextColor
		notification.BackgroundColor3=SelectedTheme.Background
		notification.UIStroke.Color=SelectedTheme.TextColor
		notification.Icon.ImageColor3=SelectedTheme.TextColor
		notification.BackgroundTransparency=1
		notification.Title.TextTransparency=1
		notification.Description.TextTransparency=1
		notification.UIStroke.Transparency=1
		notification.Shadow.ImageTransparency=1
		notification.Size=UDim2.new(1,0,0,800)
		notification.Icon.ImageTransparency=1
		notification.Icon.BackgroundTransparency=1
		notification.Visible=true
		if data.Actions then
			warn("Rayfield | Not seeing your actions in notifications?")
			print("Notification Actions are being sunset for now, keep up to date on when they're back in the discord. (sirius.menu/discord)")
		end
		local bounds={notification.Title.TextBounds.Y,notification.Description.TextBounds.Y}
		notification.Size=UDim2.new(1,-60,0,-layout.Padding.Offset)
		notification.Icon.Size=UDim2.new(0,32,0,32)
		notification.Icon.Position=UDim2.new(0,20,0.5,0)
		Tween(notification,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,0,0,math.max(bounds[1]+bounds[2]+31,60))})
		FastWait(0.15)
		Tween(notification,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{BackgroundTransparency=0.45})
		Tween(notification.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=0})
		FastWait(0.05)
		Tween(notification.Icon,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=0})
		FastWait(0.05)
		Tween(notification.Description,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=0.35})
		Tween(notification.UIStroke,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{Transparency=0.95})
		Tween(notification.Shadow,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=0.82})
		local cooldown=math.min(math.max((#notification.Description.Text * 0.1)+2.5,3),10)
		FastWait(data.Duration or cooldown)
		notification.Icon.Visible=false
		Tween(notification,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
		Tween(notification.UIStroke,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{Transparency=1})
		Tween(notification.Shadow,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=1})
		Tween(notification.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=1})
		Tween(notification.Description,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=1})
		Tween(notification,TweenInfo.new(1,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,-90,0,0)})
		FastWait(1)
		Tween(notification,TweenInfo.new(1,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,-90,0,-layout.Padding.Offset)})
		notification.Visible=false
		notification:Destroy()
	end)
end

function Library:CreateWindow(WindowInfo)
	WindowInfo=WindowInfo or {}
	WindowInfo.Name=WindowInfo.Name or "Rayfield"
	-- Interface Management
	local RayfieldAssetId=CustomAssetId or 134923138597588
	Rayfield=IsStudio and script.Parent:FindFirstChild("Rayfield") or game:GetObjects("rbxassetid://"..RayfieldAssetId)[1]
	repeat
		if Rayfield:FindFirstChild("Build") and Rayfield.Build.Value==InterfaceBuild then
			CorrectBuild=true
			break
		end

		CorrectBuild=false

		if not Warned then
			Warned=true
			warn("Rayfield | Build Mismatch")
			print("Rayfield may encounter issues as you are running an incompatible interface version ("..((Rayfield:FindFirstChild("Build") and Rayfield.Build.Value) or "No Build") ..").\n\nThis version of Rayfield is intended for interface build "..InterfaceBuild..".")
		end

		local toDestroy
		toDestroy,Rayfield=Rayfield,IsStudio and script.Parent:FindFirstChild("Rayfield") or game:GetObjects("rbxassetid://"..RayfieldAssetId)[1]
		if toDestroy and not IsStudio then toDestroy:Destroy() end

		BuildAttempts=BuildAttempts+1
	until BuildAttempts>=2
	Rayfield.Enabled=false
	do
		local HasCustomAsset=type(getcustomasset)=="function"
		local HasFilesystem=type(writefile)=="function" and type(makefolder)=="function" and type(isfile)=="function" and type(isfolder)=="function"
		if HasCustomAsset and HasFilesystem then
			local ok,err=pcall(function()
				EnsureFolder(RayfieldFolder)
				EnsureFolder(AssetPath)

				local function nextMissing()
					for id,_ in next,AssetFiles do
						if isfile and not isfile(AssetPath.."/"..tostring(id)..".png") then
							return id
						end
					end
					return nil
				end

				if nextMissing() then
					task.spawn(function()
						while true do
							local id=nextMissing()
							if not id then break end
							if writefile then writefile(AssetPath.."/"..tostring(id)..".png",RequestSafely({Url=AssetFiles[id],Method="GET"}).Body) end
							FastWait()
						end
					end)

					while nextMissing() do
						FastWait(0.1)
					end
				end

				for id,_ in AssetFiles do
					local success,asset=pcall(getcustomasset,AssetPath.."/"..tostring(id)..".png")
					if success then
						CustomAssets[tostring(id)]=asset
					else
						warn("Rayfield | Failed to load custom asset: "..tostring(id).."-"..tostring(asset))
					end
				end
			end)
			if not ok then
				warn("Rayfield | Failed to load custom assets: "..tostring(err))
				SecureNotify("asset_load_fail","Rayfield","Failed to load custom assets. UI images may not display correctly.")
			end
		else
			SecureNotify("no_getcustomasset","Rayfield","Your executor does not support getcustomasset. Some UI images may not render correctly.")
		end
		Rayfield.Main.Shadow.Image.Image=CustomAssets["5587865193"]
		Rayfield.Main.Topbar.Hide.Image=IsStudio and "http://www.roblox.com/asset/?id=8497487650" or CustomAssets["10137832201"]
		Rayfield.Main.Topbar.ChangeSize.Image=CustomAssets["10137941941"]
		Rayfield.Main.Topbar.Settings.Image=IsStudio and "http://www.roblox.com/asset/?id=8559790237" or CustomAssets["80503127983237"]
		Rayfield.Main.Topbar.Icon.Image=CustomAssets["78137979054938"]
		Rayfield.Main.Topbar.Search.Image=IsStudio and "http://www.roblox.com/asset/?id=8497489946" or CustomAssets["IconMagnifyingGlass2"]
		Rayfield.Main.Topbar.Search.ImageRectOffset=Vector2.new(0,0)
		Rayfield.Main.Topbar.Search.ImageRectSize=Vector2.new(0,0)
		Rayfield.Main.Elements.Template.Toggle.Switch.Shadow.Image=CustomAssets["3602733521"]
		Rayfield.Main.Elements.Template.Slider.Main.Shadow.Image=CustomAssets["3602733521"]
		Rayfield.Main.Elements.Template.Dropdown.Toggle.Image=CustomAssets["IconChevronTopMedium"]
		Rayfield.Main.Elements.Template.Dropdown.Toggle.ImageRectOffset=Vector2.new(0,0)
		Rayfield.Main.Elements.Template.Dropdown.Toggle.ImageRectSize=Vector2.new(0,0)
		Rayfield.Main.Elements.Template.Label.Icon.Image=CustomAssets["11745872910"]
		Rayfield.Main.Elements.Template.ColorPicker.CPBackground.MainCP.Image=CustomAssets["11413591840"]
		Rayfield.Main.Elements.Template.ColorPicker.CPBackground.MainCP.MainPoint.Image=CustomAssets["3259050989"]
		Rayfield.Main.Elements.Template.ColorPicker.ColorSlider.SliderPoint.Image=CustomAssets["3259050989"]
		Rayfield.Main.TabList.Template.Image.Image=CustomAssets["4483362458"]
		Rayfield.Main.Search.Search.Image=IsStudio and "http://www.roblox.com/asset/?id=8497489946" or CustomAssets["18458939117"]
		Rayfield.Main.Search.Shadow.Image=CustomAssets["5587865193"]
		Rayfield.Notifications.Template.Icon.Image=CustomAssets["77891951053543"]
		Rayfield.Notifications.Template.Shadow.Image=CustomAssets["3523728077"]
		Rayfield.Loading.Banner.Image=CustomAssets["111263549366178"]
	end
	ResizeUIScale(Rayfield,workspace.CurrentCamera.ViewportSize)
	local viewportSizeChanged=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		ResizeUIScale(Rayfield,workspace.CurrentCamera.ViewportSize)
	end)
	ConnectDestroying(Rayfield,function()
		viewportSizeChanged:Disconnect()
	end)
	local CoreGui=not IsStudio and Services.CoreGui
	if gethui then
		Rayfield.Parent=gethui()
	elseif syn and syn.protect_gui then 
		syn.protect_gui(Rayfield)
		Rayfield.Parent=CoreGui
	elseif not IsStudio then
		Rayfield.Parent=CoreGui
	else
		Rayfield.Parent=Players.LocalPlayer:WaitForChild("PlayerGui")
	end
	if gethui then
		for _,interface in ipairs(gethui():GetChildren()) do
			if interface.Name==WindowInfo.Name and interface~=Rayfield then
				interface:Destroy()
			end
		end
	elseif not IsStudio then
		for _,interface in ipairs(CoreGui:GetChildren()) do
			if interface.Name==Rayfield.Name and interface~=Rayfield then
				interface:Destroy()
			end
		end
	end
	if Rayfield.AbsoluteSize.X<BaseSize.X and Rayfield.AbsoluteSize.Y<BaseSize.Y then
		UseMobileSizing=true
	end
	Main=Rayfield:FindFirstChild("Main") or Rayfield:WaitForChild("Main",5)
	MPrompt=Rayfield:FindFirstChild("Prompt") or Rayfield:WaitForChild("Prompt",5)
	Notifications=Rayfield:FindFirstChild("Notifications") or Rayfield:WaitForChild("Notifications",5)
	DragBar=Rayfield:FindFirstChild("Drag") or Rayfield:WaitForChild("Drag",5)
	Elements=Main:FindFirstChild("Elements") or Main:WaitForChild("Elements",5)
	LoadingFrame=Main:FindFirstChild("LoadingFrame") or Main:WaitForChild("LoadingFrame",5)
	Topbar=Main:FindFirstChild("Topbar") or Main:WaitForChild("Topbar",5)
	TabList=Main:FindFirstChild("TabList") or Main:WaitForChild("TabList",5)
	if DragBar then
		DragBarInteract=DragBar:FindFirstChild("Interact") or DragBar:WaitForChild("Interact",5)
		DragBarCosmetic=DragBar:FindFirstChild("Drag") or DragBar:WaitForChild("Drag",5)
	end
	Rayfield.Name=WindowInfo.Name
	Rayfield.DisplayOrder=100
	Main.Visible=false
	LoadingFrame.Version.Text=Release
	Topbar.ChangeSize.MouseButton1Click:Connect(function()
		if Debounce then return end
		if Minimised then
			Minimised=false
			Maximise()
		else
			Minimised=true
			Minimise()
		end
	end)
	Main.Search.Input:GetPropertyChangedSignal("Text"):Connect(function()
		if #Main.Search.Input.Text>0 then
			if not Elements.UIPageLayout.CurrentPage:FindFirstChild("SearchTitle-fsefsefesfsefesfesfThanks") then 
				local searchTitle=Elements.Template.SectionTitle:Clone()
				searchTitle.Parent=Elements.UIPageLayout.CurrentPage
				searchTitle.Name="SearchTitle-fsefsefesfsefesfesfThanks"
				searchTitle.LayoutOrder=-100
				searchTitle.Title.Text="Results from '"..Elements.UIPageLayout.CurrentPage.Name.."'"
				searchTitle.Visible=true
			end
		else
			local searchTitle=Elements.UIPageLayout.CurrentPage:FindFirstChild("SearchTitle-fsefsefesfsefesfesfThanks")
			if searchTitle then
				searchTitle:Destroy()
			end
		end
		for _,element in ipairs(Elements.UIPageLayout.CurrentPage:GetChildren()) do
			if element.ClassName~="UIListLayout" and element.Name~="Placeholder" and element.Name~="SearchTitle-fsefsefesfsefesfesfThanks" then
				if element.Name=='SectionTitle' then
					if #Main.Search.Input.Text==0 then
						element.Visible=true
					else
						element.Visible=false
					end
				else
					if string.lower(element.Name):find(string.lower(Main.Search.Input.Text),1,true) then
						element.Visible=true
					else
						element.Visible=false
					end
				end
			end
		end
	end)
	Main.Search.Input.FocusLost:Connect(function(enterPressed)
		if #Main.Search.Input.Text==0 and SearchOpen then
			FastWait(0.12)
			CloseSearch()
		end
	end)
	Topbar.Search.MouseButton1Click:Connect(function()
		task.spawn(function()
			if SearchOpen then
				CloseSearch()
			else
				OpenSearch()
			end
		end)
	end)
	if Topbar:FindFirstChild("Settings") then
		Topbar.Settings.MouseButton1Click:Connect(function()
			task.spawn(function()
				for _,OtherTabButton in ipairs(TabList:GetChildren()) do
					if OtherTabButton.Name~="Template" and OtherTabButton.ClassName=="Frame" and OtherTabButton.Name~="Placeholder" then
						Tween(OtherTabButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.TabBackground})
						Tween(OtherTabButton.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextColor3=SelectedTheme.TabTextColor})
						Tween(OtherTabButton.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageColor3=SelectedTheme.TabTextColor})
						Tween(OtherTabButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0.7})
						Tween(OtherTabButton.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0.2})
						Tween(OtherTabButton.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0.2})
						Tween(OtherTabButton.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0.5})
					end
				end

				Elements.UIPageLayout:JumpTo(Elements['Rayfield Settings'])
			end)
		end)
	end
	Topbar.Hide.MouseButton1Click:Connect(function()
		SetVisibility(Hidden,not UseMobileSizing)
	end)
	HideHotkeyConnection=UserInputService.InputBegan:Connect(function(input,processed)
		if (input.KeyCode==Enum.KeyCode[GetSetting("General","rayfieldOpen")]) and not processed then
			if Debounce then return end
			if Hidden then
				Hidden=false
				Unhide()
			else
				Hidden=true
				Hide()
			end
		end
	end)
	if MPrompt then
		Library:CreateDraggable({["Version"]=1,["Main"]=MPrompt})
		MPrompt.Interact.MouseButton1Click:Connect(function()
			if Debounce then return end
			if Hidden then
				Hidden=false
				Unhide()
			end
		end)
	end
	for _,TopbarButton in ipairs(Topbar:GetChildren()) do
		if TopbarButton.ClassName=="ImageButton" and TopbarButton.Name~='Icon' then
			TopbarButton.MouseEnter:Connect(function()
				Tween(TopbarButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0})
			end)

			TopbarButton.MouseLeave:Connect(function()
				Tween(TopbarButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0.8})
			end)
		end
	end
	local introInfo=WindowInfo.IntroInfo
	if introInfo==nil or type(introInfo)~="table" then introInfo={Enabled=true} end
	local introFrame=Rayfield:FindFirstChild("Loading")
	if introFrame then
		if introInfo.Enabled then
			if getgenv and not getgenv().rayfieldCached then
				Rayfield.Enabled=true
				introFrame.Visible=true
				FastWait(1.4)
				introFrame.Visible=false
			end
		else
			introFrame.Visible=false
			Rayfield.Enabled=true
		end
	end
	if getgenv then getgenv().rayfieldCached=true end
	if not CorrectBuild and not WindowInfo.NoBuildWarnings then
		task.delay(3,function() Library:Notify({Title="Build Mismatch",Content='Rayfield may encounter issues as you are running an incompatible interface version ('.. ((Rayfield:FindFirstChild('Build') and Rayfield.Build.Value) or 'No Build') ..').\n\nThis version of Rayfield is intended for interface build '..InterfaceBuild..'.\n\nTry rejoining and then run the script twice.',Image=4335487866,Duration=15})	end)
	end
	if WindowInfo.ToggleUIKeybind then -- Can either be a string or an Enum.KeyCode
		local keybind=WindowInfo.ToggleUIKeybind
		if type(keybind)=="string" then
			keybind=string.upper(keybind)
			assert(pcall(function()
				return Enum.KeyCode[keybind]
			end),"ToggleUIKeybind must be a valid KeyCode")
			OverrideSetting("General","rayfieldOpen",keybind)
		elseif typeof(keybind)=="EnumItem" then
			assert(keybind.EnumType==Enum.KeyCode,"ToggleUIKeybind must be a KeyCode enum")
			OverrideSetting("General","rayfieldOpen",keybind.Name)
		else
			error("ToggleUIKeybind must be a string or KeyCode enum")
		end
	end
	EnsureFolder(RayfieldFolder)
	local Pass=false
	Topbar.Title.Text=WindowInfo.Name or WindowInfo.Text or WindowInfo.Title
	Main.Size=UDim2.new(0,420,0,100)
	Main.Visible=true
	Main.BackgroundTransparency=1
	if Main:FindFirstChild("Notice") then Main.Notice.Visible=false end
	Main.Shadow.Image.ImageTransparency=1
	LoadingFrame.Title.TextTransparency=1
	LoadingFrame.Subtitle.TextTransparency=1
	if WindowInfo.ShowText then MPrompt.Title.Text="Show "..WindowInfo.ShowText end
	LoadingFrame.Version.TextTransparency=1
	LoadingFrame.Title.Text=WindowInfo.LoadingTitle or "Rayfield"
	LoadingFrame.Subtitle.Text=WindowInfo.LoadingSubtitle or "Interface Suite"
	if WindowInfo.LoadingTitle~="Rayfield Interface Suite" then
		LoadingFrame.Version.Text="Rayfield Lite"
	end
	local windowIcon=WindowInfo.Icon
	if windowIcon and windowIcon~=0 and Topbar:FindFirstChild("Icon") then
		Topbar.Icon.Visible=true
		Topbar.Title.Position=UDim2.new(0,47,0.5,0)
		if windowIcon then
			local image,rectOffset,rectSize=ResolveIcon(WindowInfo.Icon)
			Topbar.Icon.Image=image
			if rectOffset then Topbar.Icon.ImageRectOffset=rectOffset end
			if rectSize then Topbar.Icon.ImageRectSize=rectSize end
		else
			Topbar.Icon.Image=""
		end
	end
	if DragBar then
		DragBar.Visible=false
		DragBarCosmetic.BackgroundTransparency=1
		DragBar.Visible=true
	end
	if WindowInfo.Theme then
		local success1,result=pcall(ChangeTheme,WindowInfo.Theme)
		if not success1 then
			warn("Rayfield | issue rendering theme. no theme on file")
			print(result)
			local success2,result2=pcall(ChangeTheme,"Default")
			if not success2 then
				warn("Rayfield | CRITICAL ERROR-NO DEFAULT THEME")
				print(result2)
			end
		end
	end
	Topbar.Visible=false
	Elements.Visible=false
	LoadingFrame.Visible=true
	local savingInfo=WindowInfo.SavingInfo or {}
	if savingInfo then
		if not savingInfo.FileName then
			savingInfo.FileName=tostring(game.PlaceId)
		end
		if savingInfo.Enabled==nil then
			savingInfo.Enabled=false
		end
		CFileName=savingInfo.FileName
		ConfigFolder=savingInfo.FolderName or ConfigFolder
		CEnabled=savingInfo.Enabled
		if savingInfo.Enabled then EnsureFolder(ConfigFolder) end
	end
	WindowInfo.SavingInfo=savingInfo
	Library:CreateDraggable({["Version"]=1,["Main"]=Main})
	for _,tabButton in ipairs(TabList:GetChildren()) do
		if tabButton.ClassName=="Frame" and tabButton.Name~="Placeholder" then
			tabButton.BackgroundTransparency=1
			tabButton.Title.TextTransparency=1
			tabButton.Image.ImageTransparency=1
			tabButton.UIStroke.Transparency=1
		end
	end
	local discordInfo=WindowInfo.Discord
	if discordInfo and discordInfo.Enabled and discordInfo.Invite and not UseStudio and not SecureMode then
		EnsureFolder(RayfieldFolder.."/Discord Invites")
		if isfile and not CallSafely(isfile,RayfieldFolder.."/Discord Invites".."/"..discordInfo.Invite..ConfigExtension) then
			RequestSafely({
				Url="http://127.0.0.1:6463/rpc?v=1",
				Method="POST",
				Headers={
					["Content-Type"]="application/json",
					Origin="https://discord.com"
				},
				Body=HttpService:JSONEncode({
					cmd="INVITE_BROWSER",
					nonce=HttpService:GenerateGUID(false),
					args={code=discordInfo.Invite}
				})
			})
			if discordInfo.RememberJoins and writefile then -- We do logic this way so if the developer changes this setting,the user still won't be prompted,only new users
				CallSafely(writefile,RayfieldFolder.."/Discord Invites".."/"..discordInfo.Invite..ConfigExtension,"Rayfield RememberJoins is true for this invite,this invite will not ask you to join again")
			end
		end
	end
	local keyInfo=WindowInfo.KeyInfo
	if keyInfo and keyInfo.Enabled then
		EnsureFolder(RayfieldFolder.."/Key System")
		if type(keyInfo.Key)=="string" then keyInfo.Key={keyInfo.Key} end
		local keys=keyInfo.Key
		if keyInfo.GrabKeyFromSite then
			for name,key in ipairs(keys) do
				local success,response=pcall(function()
					keys[name]=tostring(game:HttpGet(key):gsub("[\n\r]"," "))
					keys[name]=string.gsub(keyInfo.Key[name]," ","")
				end)
				if not success then
					print("Rayfield | "..key.." Error " ..tostring(response))
					warn("Check docs.sirius.menu for help with Rayfield specific development.")
				end
			end
		end
		if not keyInfo.FileName then keyInfo.FileName="No file name specified" end
		if isfile and CallSafely(isfile,RayfieldFolder.."/Key System".."/"..keyInfo.FileName..ConfigExtension) then
			for _,key in ipairs(keys) do
				if readfile then
					local savedKeys=CallSafely(readfile,RayfieldFolder.."/Key System".."/"..keyInfo.FileName..ConfigExtension)
					if savedKeys and string.find(savedKeys,key) then
						Pass=true
					end
				end
			end
		end
		if not Pass and SecureMode then
			warn("Rayfield | Secure Mode: Key system requires a valid saved key. The key UI cannot be shown as it requires loading detectable assets.")
			Rayfield.Enabled=false
			Rayfield.Name="Rayfield-Old"
			return Library
		end
		if not Pass then
			local AttemptsRemaining=keyInfo.MaxAttempts or 5
			Rayfield.Enabled=false
			local keyUI=IsStudio and script.Parent:FindFirstChild("Key") or game:GetObjects("rbxassetid://11380036235")[1]
			keyUI.Enabled=true
			if gethui then
				keyUI.Parent=gethui()
			elseif syn and syn.protect_gui then 
				syn.protect_gui(keyUI)
				keyUI.Parent=CoreGui
			elseif not IsStudio then
				keyUI.Parent=CoreGui
			end
			if gethui then
				for _,interface in ipairs(gethui():GetChildren()) do
					if interface.Name==keyUI.Name and interface~=keyUI then
						interface.Enabled=false
						interface.Name="KeyUI-Old"
					end
				end
			elseif not IsStudio then
				for _,interface in ipairs(CoreGui:GetChildren()) do
					if interface.Name==keyUI.Name and interface~=KeyUI then
						interface.Enabled=false
						interface.Name="KeyUI-Old"
					end
				end
			end
			local keyMain=keyUI.Main
			keyMain.Title.Text=keyInfo.Title or keyInfo.Name or keyInfo.Text
			keyMain.Subtitle.Text=keyInfo.Subtitle or "Key System"
			keyMain.NoteMessage.Text=keyInfo.Note or "No instructions"
			keyMain.Size=UDim2.new(0,467,0,175)
			keyMain.BackgroundTransparency=1
			keyMain.Shadow.Image.ImageTransparency=1
			keyMain.Title.TextTransparency=1
			keyMain.Subtitle.TextTransparency=1
			keyMain.KeyNote.TextTransparency=1
			keyMain.Input.BackgroundTransparency=1
			keyMain.Input.UIStroke.Transparency=1
			keyMain.Input.InputBox.TextTransparency=1
			keyMain.NoteTitle.TextTransparency=1
			keyMain.NoteMessage.TextTransparency=1
			keyMain.Hide.ImageTransparency=1
			Tween(keyMain,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			Tween(keyMain,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,500,0,187)})
			Tween(keyMain.Shadow.Image,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{ImageTransparency=0.5})
			FastWait(0.05)
			Tween(keyMain.Title,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{TextTransparency=0})
			Tween(keyMain.Subtitle,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=0})
			FastWait(0.05)
			Tween(keyMain.KeyNote,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=0})
			Tween(keyMain.Input,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			Tween(keyMain.Input.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Transparency=0})
			Tween(keyMain.Input.InputBox,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=0})
			FastWait(0.05)
			Tween(keyMain.NoteTitle,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{TextTransparency=0})
			Tween(keyMain.NoteMessage,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{TextTransparency=0})
			FastWait(0.15)
			Tween(keyMain.Hide,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{ImageTransparency=0.3})
			keyUI.Main.Input.InputBox.FocusLost:Connect(function(enter)
				if Strs.IsEmpty(keyMain.Input.InputBox.Text) or not enter then return end
				local keyFound=false
				local savedKey=""
				for _,key in ipairs(keyInfo.Key) do
					if keyMain.Input.InputBox.Text==key then
						keyFound=true
						savedKey=key
					end
				end
				if keyFound then
					FadeOutKeyUI(keyMain)
					FastWait(0.51)
					Pass=true
					keyMain.Visible=false
					if keyInfo.SaveKey and writefile then
						CallSafely(writefile,RayfieldFolder.."/Key System".."/"..keyInfo.FileName..ConfigExtension,savedKey)
						Library:Notify({Title="Key System",Content="The key for this script has been saved successfully.",Image=3605522284})
					end
				else
					if AttemptsRemaining==0 then
						FadeOutKeyUI(keyMain)
						FastWait(0.45)
						Players.LocalPlayer:Kick("No Attempts Remaining")
						game:Shutdown()
					end
					keyMain.Input.InputBox.Text=""
					AttemptsRemaining=AttemptsRemaining-1
					Tween(keyMain,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,467,0,175)})
					Tween(keyMain,TweenInfo.new(0.4,Enum.EasingStyle.Elastic),{Position=UDim2.new(0.495,0,0.5,0)})
					FastWait(0.1)
					Tween(keyMain,TweenInfo.new(0.4,Enum.EasingStyle.Elastic),{Position=UDim2.new(0.505,0,0.5,0)})
					FastWait(0.1)
					Tween(keyMain,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{Position=UDim2.new(0.5,0,0.5,0)})
					Tween(keyMain,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,500,0,187)})
				end
			end)
			keyMain.Hide.MouseButton1Click:Connect(function()
				FadeOutKeyUI(keyMain)
				FastWait(0.51)
				Pass=true
				Library:Destroy()
				keyUI:Destroy()
			end)
		else
			Pass=true
		end
		repeat FastWait() until Pass
		FastWait(0.2)
		-- Prevents animation from trying to play if the button's callback called Library:Destroy()
		if rayfieldDestroyed then return end
	end
	Notifications.Template.Visible=false
	Notifications.Visible=true
	Rayfield.Enabled=true
	FastWait(0.5)
	Tween(Main,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	Tween(Main.Shadow.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0.6})
	FastWait(0.1)
	Tween(LoadingFrame.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})
	FastWait(0.05)
	Tween(LoadingFrame.Subtitle,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})
	FastWait(0.05)
	Tween(LoadingFrame.Version,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})
	Elements.Template.LayoutOrder=100000
	Elements.Template.Visible=false
	Elements.UIPageLayout.FillDirection=Enum.FillDirection.Horizontal
	Elements.UIPageLayout.ScrollWheelInputEnabled=false
	Elements.UIPageLayout.GamepadInputEnabled=false
	Elements.UIPageLayout.TouchInputEnabled=false
	TabList.Template.Visible=false
	
	local FirstTab=false
	local Window={}
	function Window:CreateTab(name,image,Ext)
		local Tab={Order=0}
		local TabButton=TabList.Template:Clone()
		TabButton.Name=name
		TabButton.Parent=TabList
		TabButton.Title.Text=name
		TabButton.Title.TextWrapped=false
		TabButton.Size=UDim2.fromOffset(TabButton.Title.TextBounds.X+30,0,30)
		if image and image~=0 then
			local img,rectOffset,rectSize=ResolveIcon(image)
			TabButton.Image.Image=img
			if rectOffset then TabButton.Image.ImageRectOffset=rectOffset end
			if rectSize then TabButton.Image.ImageRectSize=rectSize end
			TabButton.Title.AnchorPoint=Vector2.new(0,0.5)
			TabButton.Title.Position=UDim2.new(0,37,0.5,0)
			TabButton.Image.Visible=true
			TabButton.Title.TextXAlignment=Enum.TextXAlignment.Left
			TabButton.Size=UDim2.new(0,TabButton.Title.TextBounds.X+52,0,30)
		end
		TabButton.BackgroundTransparency=1
		TabButton.Title.TextTransparency=1
		TabButton.Image.ImageTransparency=1
		TabButton.UIStroke.Transparency=1
		TabButton.Visible=not Ext or false
		Tab.Interact=TabButton
		local TabPage=Elements.Template:Clone()
		TabPage.Name=name
		TabPage.Visible=true
		TabPage.LayoutOrder=Ext and 10000 or #Elements:GetChildren()
		Tab.Page=TabPage
		for _,TemplateElement in ipairs(TabPage:GetChildren()) do
			if TemplateElement.ClassName=="Frame" and TemplateElement.Name~="Placeholder" then
				TemplateElement:Destroy()
			end
		end
		TabPage.Parent=Elements
		if not FirstTab and not Ext then
			Elements.UIPageLayout.Animated=false
			Elements.UIPageLayout:JumpTo(TabPage)
			Elements.UIPageLayout.Animated=true
		end
		TabButton.UIStroke.Color=SelectedTheme.TabStroke
		if Elements.UIPageLayout.CurrentPage==TabPage then
			TabButton.BackgroundColor3=SelectedTheme.TabBackgroundSelected
			TabButton.Image.ImageColor3=SelectedTheme.SelectedTabTextColor
			TabButton.Title.TextColor3=SelectedTheme.SelectedTabTextColor
		else
			TabButton.BackgroundColor3=SelectedTheme.TabBackground
			TabButton.Image.ImageColor3=SelectedTheme.TabTextColor
			TabButton.Title.TextColor3=SelectedTheme.TabTextColor
		end
		-- Animate
		FastWait(0.1)
		if FirstTab or Ext then
			TabButton.BackgroundColor3=SelectedTheme.TabBackground
			TabButton.Image.ImageColor3=SelectedTheme.TabTextColor
			TabButton.Title.TextColor3=SelectedTheme.TabTextColor
			Tween(TabButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0.7})
			Tween(TabButton.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0.2})
			Tween(TabButton.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0.2})
			Tween(TabButton.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0.5})
		elseif not Ext then
			FirstTab=name
			TabButton.BackgroundColor3=SelectedTheme.TabBackgroundSelected
			TabButton.Image.ImageColor3=SelectedTheme.SelectedTabTextColor
			TabButton.Title.TextColor3=SelectedTheme.SelectedTabTextColor
			Tween(TabButton.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0})
			Tween(TabButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			Tween(TabButton.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})
		end

		TabButton.Interact.MouseButton1Click:Connect(function()
			if Minimised then return end
			Tween(TabButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			Tween(TabButton.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=1})
			Tween(TabButton.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})
			Tween(TabButton.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0})
			Tween(TabButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.TabBackgroundSelected})
			Tween(TabButton.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextColor3=SelectedTheme.SelectedTabTextColor})
			Tween(TabButton.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageColor3=SelectedTheme.SelectedTabTextColor})
			for _,OtherTabButton in ipairs(TabList:GetChildren()) do
				if OtherTabButton.Name~="Template" and OtherTabButton.ClassName=="Frame" and OtherTabButton~=TabButton and OtherTabButton.Name~="Placeholder" then
					Tween(OtherTabButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.TabBackground})
					Tween(OtherTabButton.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextColor3=SelectedTheme.TabTextColor})
					Tween(OtherTabButton.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageColor3=SelectedTheme.TabTextColor})
					Tween(OtherTabButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0.7})
					Tween(OtherTabButton.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0.2})
					Tween(OtherTabButton.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0.2})
					Tween(OtherTabButton.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0.5})
				end
			end
			if Elements.UIPageLayout.CurrentPage~=TabPage then
				Elements.UIPageLayout:JumpTo(TabPage)
			end
		end)
		
		local DefaultData={
			["Toggle"]={Type="Toggle",Name="Toggle Here",Value=false,Ext=false,Callback=function(Value) end},
			["Button"]={Type="Button",Name="Button Here",Callback=function() end,Set=function(Value) end},
			["Selector"]={Type="Selector",Name="Selector Here",Value="Option 1",Options={},NoCap=true,Callback=function(Value) end,Set=function(Value,Index) end,Add=function(Value) end,Remove=function(Value) end},
			["Expand"]={Type="Expand",Name="Events",Active=false,List={},Callback=function() end,Add=function() end,Remove=function() end},
			["ColorPicker"]={Type="ColorPicker",Name="Color Picker Here",Color=Color3.fromRGB(163,162,165),Ext=false,Callback=function(Color) end},
			["Section"]={Type="Section",Name="Section Here",Set=function(Value) end},
			["Label"]={Type="Label",Text="Label Here",Icon=nil,Color=nil,IgnoreTheme=false},
			["Paragraph"]={Type="Paragraph",Title="Paragraph Here",["Content"]="Long Text Here",Ext=false,Set=function(Value) end},
			["Input"]={Type="Input",Name="Input Here",PlaceholderText="Type here",Value="",Ext=false,Callback=function(InputText) end},
			["Dropdown"]={Type="Dropdown",Name="Dropdown Here",Options={},MultipleOptions=false,CurrentOption={},Ext=false,Callback=function(Value) end},
			["Slider"]={Type="Slider",Name="Slider Here",["Version"]=1,Increment=1,Value=1,Range={1,10},Ext=false,Callback=function(Value) end},
			["Keybind"]={Type="Keybind",Name="Keybind Here",Keybind="E",Value="E",Ext=false,Callback=function(Value) end}
		}
		
		-- Section
		local SDone=false
		function Tab:CreateSection(Text)
			local SectionInfo={Type="Section",Text=Text or "Section"}
			local SectionSpace=nil
			if SDone then
				SDone=false
				SectionSpace=Elements.Template.SectionSpacing:Clone()
				Tab.Order+=1
				SectionSpace.LayoutOrder=Tab.Order
				SectionSpace.Visible=true
				SectionSpace.Parent=TabPage
			end
			SDone=true
			local Section=Elements.Template.SectionTitle:Clone()
			Tab.Order+=1
			Section.LayoutOrder=Tab.Order
			Section.Title.Text=Text
			Section.Visible=true
			Section.Title.TextTransparency=1
			Section.Parent=TabPage
			Tween(Section.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0.4})
			function SectionInfo:Set(value)
				if value==nil then value="" else value=tostring(value) end
				Section.Title.Text=value
			end
			local SectionProxy=setmetatable({},{
				__index=function(_,key)
					local LabelReturns={
						["Visible"]=Section.Visible,
						["LayoutOrder"]=Section.LayoutOrder,
						["Text"]=Section.Title.Text,
					}
					return LabelReturns[key] or SectionInfo[key]
				end,
				__newindex=function(_,key,value)
					if key=="Visible" then
						Section.Visible=value
						if SectionSpace then
							SectionSpace.Visible=value
						end
					elseif key=="LayoutOrder" then
						Section.LayoutOrder=value
					elseif key=="Text" then
						Section.Title.Text=value
					elseif key~="Type" and key~="Set" then
						SectionInfo[key]=value
					end
				end,
			})
			return SectionProxy
		end
		-- Divider
		function Tab:CreateDivider()
			local DividerInfo={Type="Divider"}
			local Divider=Elements.Template.Divider:Clone()
			DividerInfo.Template=Divider
			Tab.Order+=1
			Divider.LayoutOrder=Tab.Order
			Divider.Visible=true
			Divider.Divider.BackgroundTransparency=1
			Divider.Parent=TabPage
			Tween(Divider.Divider,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=0.85})
			function DividerInfo:Set(Value)
				Divider.Visible=Value
			end
			local DividerProxy=setmetatable({},{
				__index=function(_,key)
					local DividerReturns={
						["Visible"]=Divider.Visible,
						["LayoutOrder"]=Divider.LayoutOrder,
					}
					return DividerReturns[key] or DividerInfo[key]
				end,
				__newindex=function(_,key,value)
					if key=="Visible" then
						Divider.Visible=value
					elseif key=="LayoutOrder" then
						Divider.LayoutOrder=value
					elseif key~="Type" and key~="Set" then
						DividerInfo[key]=value
					end
				end,
			})
			return DividerProxy
		end
		-- Label
		function Tab:CreateLabel(Text,Icon,Color,IgnoreTheme)
			local LabelInfo={Type="Label",Text=Text or "Label",Icon=Icon,Color=Color,IgnoreTheme=IgnoreTheme}
			local Label=Elements.Template.Label:Clone()
			LabelInfo.Template=Label
			Tab.Order+=1
			Label.LayoutOrder=Tab.Order
			Label.Name=LabelInfo.Name or LabelInfo.Text
			Label.Title.Text=LabelInfo.Text
			Label.Visible=true
			Label.Parent=TabPage
			Label.BackgroundColor3=LabelInfo.Color and LabelInfo.Color or SelectedTheme.SecondaryElementBackground
			Label.UIStroke.Color=LabelInfo.Color and LabelInfo.Color or SelectedTheme.SecondaryElementStroke
			if LabelInfo.Icon then
				local img,rectOffset,rectSize=ResolveIcon(LabelInfo.Icon)
				Label.Icon.Image=img
				if rectOffset then Label.Icon.ImageRectOffset=rectOffset end
				if rectSize then Label.Icon.ImageRectSize=rectSize end
			else
				Label.Icon.Image=""
			end
			if LabelInfo.Icon and Label:FindFirstChild("Icon") then
				Label.Title.Position=UDim2.new(0,45,0.5,0)
				Label.Title.Size=UDim2.new(1,-100,0,14)
				Label.Icon.Visible=true
			end
			Label.Icon.ImageTransparency=1
			Label.BackgroundTransparency=1
			Label.UIStroke.Transparency=1
			Label.Title.TextTransparency=1
			Tween(Label,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=Color and 0.8 or 0})
			Tween(Label.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=Color and 0.7 or 0})
			Tween(Label.Icon,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0.2})
			Tween(Label.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=Color and 0.2 or 0})	
			function LabelInfo:Set(Text,Icon,Color)
				local labelText=Text or LabelInfo.Text or LabelInfo.Title
				if labelText then
					LabelInfo.Text=labelText
					Label.Title.Text=labelText
				end
				local labelColor=Color or SelectedTheme.SecondaryElementBackground
				Label.BackgroundColor3=labelColor
				Label.UIStroke.Color=labelColor
				LabelInfo.Color=labelColor
				local labelIcon=Icon or LabelInfo.Icon
				if labelIcon and Label:FindFirstChild("Icon") then
					LabelInfo.Icon=labelIcon
					Label.Title.Position=UDim2.new(0,45,0.5,0)
					Label.Title.Size=UDim2.new(1,-100,0,14)
					local img,rectOffset,rectSize=ResolveIcon(labelIcon)
					Label.Icon.Image=img
					if rectOffset then Label.Icon.ImageRectOffset=rectOffset end
					if rectSize then Label.Icon.ImageRectSize=rectSize end
					Label.Icon.Visible=true
				end
			end
			Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Label.BackgroundColor3=IgnoreTheme and (Color or Label.BackgroundColor3) or SelectedTheme.SecondaryElementBackground
				Label.UIStroke.Color=IgnoreTheme and (Color or Label.BackgroundColor3) or SelectedTheme.SecondaryElementStroke
			end)
			local LabelProxy=setmetatable({},{
				__index=function(_,key)
					local LabelReturns={
						["Visible"]=Label.Visible,
						["LayoutOrder"]=Label.LayoutOrder,
						["Title"]=Label.Title.Text,
					}
					LabelReturns.Text=LabelReturns.Title
					return LabelReturns[key] or LabelInfo[key]
				end,
				__newindex=function(_,key,value)
					if key=="Visible" then
						Label.Visible=value
					elseif key=="LayoutOrder" then
						Label.LayoutOrder=value
					elseif key=="Title" or key=="Text" then
						Label.Title.Text=value
					elseif key~="Type" and key~="Set" then
						LabelInfo[key]=value
					end
				end,
			})
			return LabelProxy
		end
		-- Paragraph
		function Tab:CreateParagraph(ParagraphInfo)
			ParagraphInfo=ParagraphInfo or {}
			ParagraphInfo.Type="Paragraph"
			local Paragraph=Elements.Template.Paragraph:Clone()
			ParagraphInfo.Template=Paragraph
			Tab.Order+=1
			Paragraph.LayoutOrder=Tab.Order
			Paragraph.Name=ParagraphInfo.Name or ParagraphInfo.Title or "Paragraph"
			Paragraph.Title.Text=ParagraphInfo.Title or "Paragraph"
			Paragraph.Content.Text=ParagraphInfo.Content or ParagraphInfo.Description or "Description"
			Paragraph.Visible=true
			Paragraph.Parent=TabPage
			Paragraph.BackgroundTransparency=1
			Paragraph.UIStroke.Transparency=1
			Paragraph.Title.TextTransparency=1
			Paragraph.Content.TextTransparency=1
			Paragraph.BackgroundColor3=SelectedTheme.SecondaryElementBackground
			Paragraph.UIStroke.Color=SelectedTheme.SecondaryElementStroke
			Tween(Paragraph,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			Tween(Paragraph.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0})
			Tween(Paragraph.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
			Tween(Paragraph.Content,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
			function ParagraphInfo:Set(value)
				if value==nil then value={} end
				Paragraph.Title.Text=value.Title or ""
				Paragraph.Content.Text=value.Content or value.Description or ""
			end
			Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Paragraph.BackgroundColor3=SelectedTheme.SecondaryElementBackground
				Paragraph.UIStroke.Color=SelectedTheme.SecondaryElementStroke
			end)
			local ParagraphProxy=setmetatable({},{
				__index=function(_,key)
					local ParagraphReturns={
						["Visible"]=Paragraph.Visible,
						["LayoutOrder"]=Paragraph.LayoutOrder,
						["Title"]=Paragraph.Title.Text,
						["Content"]=Paragraph.Content.Text,
					}
					ParagraphReturns.Description=ParagraphReturns.Content
					return ParagraphReturns[key] or ParagraphInfo[key]
				end,
				__newindex=function(_,key,value)
					if debugX then
						warn(`Paragraph.{key}={value}`)
					end
					if key=="Visible" then
						Paragraph.Visible=value
					elseif key=="LayoutOrder" then
						Paragraph.LayoutOrder=value
					elseif key=="Title" then
						Paragraph.Title.Text=value
					elseif key=="Content" or key=="Description" then
						Paragraph.Content.Text=value
					elseif key~="Type" and key~="Set" then
						ParagraphInfo[key]=value
					end
				end,
			})
			return ParagraphProxy
		end
		-- Button
		function Tab:CreateButton(ButtonInfo)
			ButtonInfo=ButtonInfo or {}
			ButtonInfo.Type="Button"
			local Button=Elements.Template.Button:Clone()
			ButtonInfo.Template=Button
			Tab.Order+=1
			Button.LayoutOrder=Tab.Order
			Button.Name=ButtonInfo.Name or ButtonInfo.Title or "Button"
			Button.Title.Text=ButtonInfo.Title or ButtonInfo.Name or "Button"
			Button.Visible=true
			Button.BackgroundTransparency=1
			Button.UIStroke.Transparency=1
			Button.Title.TextTransparency=1
			Button.Icon.ImageColor3=SelectedTheme.TextColor
			Button.Parent=TabPage
			for i,v in ipairs(Button:GetDescendants())
				if v.ClassName=="TextLabel" and v.Name=="ElementIndicator" then
					v.Visible=false
				end
			end
			Tween(Button,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			Tween(Button.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0})
			Tween(Button.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
			Tween(Button.Icon,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0.45})	
			function ButtonInfo:Set(value)
				if value==nil then value="" else value=tostring(value) end
				Button.Title.Text=value
				Button.Name=value
			end
			if ButtonInfo.Tooltip then Tooltip(ButtonInfo.Tooltip,Button) end
			Button.MouseEnter:Connect(function()
				Tween(Button,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
				Tween(Button.Icon,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{ImageTransparency=0.9})
			end)
			Button.MouseLeave:Connect(function()
				Tween(Button,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
				Tween(Button.Icon,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{ImageTransparency=0.45})
			end)
			Button.Interact.MouseButton1Click:Connect(function()
				local Success,Response=pcall(ButtonInfo.Callback)
				if not Success then
					Tween(Button,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
					Tween(Button.Icon,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{ImageTransparency=1})
					Tween(Button.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					Button.Title.Text="Callback Error"
					print("Rayfield | "..ButtonInfo.Name.." Callback Error " ..tostring(Response))
					warn("Check docs.sirius.menu for help with Rayfield specific development.")
					FastWait(0.5)
					Button.Title.Text=ButtonInfo.Name
					Tween(Button,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					Tween(Button.Icon,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{ImageTransparency=0.9})
					Tween(Button.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
				else
					if not ButtonInfo.Ext and ButtonInfo.Flag then SaveConfiguration(ButtonInfo.Name.."\n") end
					Tween(Button,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
					Tween(Button.Icon,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{ImageTransparency=1})
					Tween(Button.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					FastWait(0.2)
					Tween(Button,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					Tween(Button.Icon,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{ImageTransparency=0.9})
					Tween(Button.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
				end
			end)
			Button:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Button.Title.TextColor3=SelectedTheme.TextColor
				Button.Icon.ImageColor3=SelectedTheme.ImageColor or SelectedTheme.TextColor
			end)
			local ButtonProxy=setmetatable({},{
				__index=function(_,key)
					local ButtonReturns={
						["Visible"]=Button.Visible,
						["LayoutOrder"]=Button.LayoutOrder,
						["Title"]=Button.Title.Text,
					}
					return ButtonReturns[key] or ButtonInfo[key]
				end,
				__newindex=function(_,key,value)
					if key=="Visible" then
						Button.Visible=value
					elseif key=="LayoutOrder" then
						Button.LayoutOrder=value
					elseif key=="Title" then
						Button.Title.Text=value
					elseif key~="Type" and key~="Set" then
						ButtonInfo[key]=value
					end
				end,
			})
			return ButtonProxy
		end
		-- Toggle
		function Tab:CreateToggle(ToggleInfo)
			ToggleInfo=ToggleInfo or {}
			ToggleInfo.Type="Toggle"
			local Toggle=Elements.Template.Toggle:Clone()
			ToggleInfo.Template=Toggle
			Tab.Order+=1
			Toggle.LayoutOrder=Tab.Order
			Toggle.Name=ToggleInfo.Name or ToggleInfo.Title or "Toggle"
			Toggle.Title.Text=ToggleInfo.Title or ToggleInfo.Name or "Toggle"
			Toggle.Visible=true
			Toggle.Parent=TabPage
			Toggle.BackgroundTransparency=1
			Toggle.UIStroke.Transparency=1
			Toggle.Title.TextTransparency=1
			Toggle.Switch.BackgroundColor3=SelectedTheme.ToggleBackground
			if SelectedTheme~=Library.Theme.Default then
				Toggle.Switch.Shadow.Visible=false
			end
			Tween(Toggle,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			Tween(Toggle.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0})
			Tween(Toggle.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
			if ToggleInfo.Value then
				Toggle.Switch.Indicator.Position=UDim2.new(1,-20,0.5,0)
				Toggle.Switch.Indicator.UIStroke.Color=SelectedTheme.ToggleEnabledStroke
				Toggle.Switch.Indicator.BackgroundColor3=SelectedTheme.ToggleEnabled
				Toggle.Switch.UIStroke.Color=SelectedTheme.ToggleEnabledOuterStroke
			else
				Toggle.Switch.Indicator.Position=UDim2.new(1,-40,0.5,0)
				Toggle.Switch.Indicator.UIStroke.Color=SelectedTheme.ToggleDisabledStroke
				Toggle.Switch.Indicator.BackgroundColor3=SelectedTheme.ToggleDisabled
				Toggle.Switch.UIStroke.Color=SelectedTheme.ToggleDisabledOuterStroke
			end
			if ToggleInfo.Tooltip then Tooltip(ToggleInfo.Tooltip,Toggle) end
			Toggle.MouseEnter:Connect(function()
				Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
			end)
			Toggle.MouseLeave:Connect(function()
				Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
			end)
			Toggle.Interact.MouseButton1Click:Connect(function()
				local NewValue=ToggleInfo.Value
				if NewValue==true then
					NewValue=false
					ToggleInfo.Value=NewValue
					Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
					Tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					Tween(Toggle.Switch.Indicator,TweenInfo.new(0.45,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(1,-40,0.5,0)})
					Tween(Toggle.Switch.Indicator.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleDisabledStroke})
					Tween(Toggle.Switch.Indicator,TweenInfo.new(0.8,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{BackgroundColor3=SelectedTheme.ToggleDisabled})
					Tween(Toggle.Switch.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleDisabledOuterStroke})
					Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					Tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})	
				else
					NewValue=true
					ToggleInfo.Value=NewValue
					Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
					Tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					Tween(Toggle.Switch.Indicator,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(1,-20,0.5,0)})
					Tween(Toggle.Switch.Indicator.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleEnabledStroke})
					Tween(Toggle.Switch.Indicator,TweenInfo.new(0.8,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{BackgroundColor3=SelectedTheme.ToggleEnabled})
					Tween(Toggle.Switch.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleEnabledOuterStroke})
					Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					Tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})		
				end
				local Success,Response=pcall(ToggleInfo.Callback,NewValue)
				if not Success then
					Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
					Tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					Toggle.Title.Text="Callback Error"
					print("Rayfield | "..ToggleInfo.Name.." Callback Error " ..tostring(Response))
					warn("Check docs.sirius.menu for help with Rayfield specific development.")
					FastWait(0.5)
					Toggle.Title.Text=ToggleInfo.Name
					Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					Tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
				end
				if not ToggleInfo.Ext and ToggleInfo.Flag then SaveConfiguration() end
			end)
			function ToggleInfo:Replace(value)
				if value then value=true else value=false end
				if ToggleInfo.Value~=value then
					ToggleInfo.Value=value
					if value==true then
						Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
						Tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
						Tween(Toggle.Switch.Indicator,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(1,-20,0.5,0)})
						Tween(Toggle.Switch.Indicator,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,12,0,12)})
						Tween(Toggle.Switch.Indicator.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleEnabledStroke})
						Tween(Toggle.Switch.Indicator,TweenInfo.new(0.8,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{BackgroundColor3=SelectedTheme.ToggleEnabled})
						Tween(Toggle.Switch.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleEnabledOuterStroke})
						Tween(Toggle.Switch.Indicator,TweenInfo.new(0.45,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,17,0,17)})	
						Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
						Tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})	
					else
						Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
						Tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
						Tween(Toggle.Switch.Indicator,TweenInfo.new(0.45,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(1,-40,0.5,0)})
						Tween(Toggle.Switch.Indicator,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,12,0,12)})
						Tween(Toggle.Switch.Indicator.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleDisabledStroke})
						Tween(Toggle.Switch.Indicator,TweenInfo.new(0.8,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{BackgroundColor3=SelectedTheme.ToggleDisabled})
						Tween(Toggle.Switch.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleDisabledOuterStroke})
						Tween(Toggle.Switch.Indicator,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,17,0,17)})
						Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
						Tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})	
					end
					if not ToggleInfo.Ext and ToggleInfo.Flag then SaveConfiguration() end
				end
			end
			function ToggleInfo:Set(value)
				if value then value=true else value=false end
				ToggleInfo.Value=value
				if value==true then
					Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
					Tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					Tween(Toggle.Switch.Indicator,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(1,-20,0.5,0)})
					Tween(Toggle.Switch.Indicator,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,12,0,12)})
					Tween(Toggle.Switch.Indicator.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleEnabledStroke})
					Tween(Toggle.Switch.Indicator,TweenInfo.new(0.8,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{BackgroundColor3=SelectedTheme.ToggleEnabled})
					Tween(Toggle.Switch.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleEnabledOuterStroke})
					Tween(Toggle.Switch.Indicator,TweenInfo.new(0.45,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,17,0,17)})	
					Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					Tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})	
				else
					Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
					Tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					Tween(Toggle.Switch.Indicator,TweenInfo.new(0.45,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(1,-40,0.5,0)})
					Tween(Toggle.Switch.Indicator,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,12,0,12)})
					Tween(Toggle.Switch.Indicator.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleDisabledStroke})
					Tween(Toggle.Switch.Indicator,TweenInfo.new(0.8,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{BackgroundColor3=SelectedTheme.ToggleDisabled})
					Tween(Toggle.Switch.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleDisabledOuterStroke})
					Tween(Toggle.Switch.Indicator,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,17,0,17)})
					Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					Tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})	
				end
				local Success,Response=pcall(ToggleInfo.Callback,ToggleInfo.Value)
				if not Success then
					Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
					Tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					Toggle.Title.Text="Callback Error"
					print("Rayfield | "..ToggleInfo.Name.." Callback Error " ..tostring(Response))
					warn("Check docs.sirius.menu for help with Rayfield specific development.")
					FastWait(0.5)
					Toggle.Title.Text=ToggleInfo.Name
					Tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					Tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
				end
				if not ToggleInfo.Ext and ToggleInfo.Flag then SaveConfiguration() end
			end
			if savingInfo and savingInfo.Enabled and ToggleInfo.Flag then
				Library.Flags[ToggleInfo.Flag]=ToggleInfo
			end
			Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Toggle.Switch.BackgroundColor3=SelectedTheme.ToggleBackground
				if SelectedTheme~=Library.Theme.Default then
					Toggle.Switch.Shadow.Visible=false
				end
				if not ToggleInfo.Value then
					Toggle.Switch.Indicator.UIStroke.Color=SelectedTheme.ToggleDisabledStroke
					Toggle.Switch.Indicator.BackgroundColor3=SelectedTheme.ToggleDisabled
					Toggle.Switch.UIStroke.Color=SelectedTheme.ToggleDisabledOuterStroke
				else
					Toggle.Switch.Indicator.UIStroke.Color=SelectedTheme.ToggleEnabledStroke
					Toggle.Switch.Indicator.BackgroundColor3=SelectedTheme.ToggleEnabled
					Toggle.Switch.UIStroke.Color=SelectedTheme.ToggleEnabledOuterStroke
				end
			end)
			local ToggleProxy=setmetatable({},{
				__index=function(_,key)
					local ToggleReturns={
						["Visible"]=Toggle.Visible,
						["LayoutOrder"]=Toggle.LayoutOrder,
						["Title"]=Toggle.Title.Text,
					}
					return ToggleReturns[key] or ToggleInfo[key]
				end,
				__newindex=function(_,key,value)
					if key=="Visible" then
						Toggle.Visible=value
					elseif key=="LayoutOrder" then
						Toggle.LayoutOrder=value
					elseif key=="Title" then
						Toggle.Title.Text=value
					elseif key~="Type" and key~="Set" and key~="Replace" then
						ToggleInfo[key]=value
					end
				end,
			})
			return ToggleProxy
		end
		-- Selector
		function Tab:CreateSelector(SelectorInfo)
			SelectorInfo=SelectorInfo or {}
			SelectorInfo.Type="Selector"
			if not SelectorInfo.Options or type(SelectorInfo.Options)~="table" or #SelectorInfo.Options<=0 then
				SelectorInfo.Options={"Option 1","Option 2"}
			end
			if not Elements:FindFirstChild("Template") or not Elements.Template:FindFirstChild("Selector") then warn("Rayfield | Selector not found.") return SelectorInfo end
			local Selector=Elements.Template.Selector:Clone()
			SelectorInfo.Template=Selector
			Tab.Order+=1
			Selector.LayoutOrder=Tab.Order
			Selector.Name=SelectorInfo.Name or "Selector"
			Selector.Title.Text=SelectorInfo.Title or SelectorInfo.Name or "Selector"
			Selector.Visible=true
			Selector.Parent=TabPage
			Selector.BackgroundTransparency=1
			Selector.UIStroke.Transparency=1
			Selector.Title.TextTransparency=1
			Tween(Selector,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			Tween(Selector.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0})
			Tween(Selector.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
			local PreviousButton=Selector:FindFirstChild("Previous")
			local NextButton=Selector:FindFirstChild("Next")
			local Information=Selector:FindFirstChild("Information")
			local Index=1
			SelectorInfo.Index=type(SelectorInfo.Index)=="number" and SelectorInfo.Index or 0
			Information.Text=tostring(SelectorInfo.Value or SelectorInfo.Options[1])
			local function ConnectHover(frame,object)
				frame.MouseEnter:Connect(function()
					Tween(object,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0.4})
				end)
				frame.MouseLeave:Connect(function()
					Tween(object,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})
				end)
			end
			function SelectorInfo:Set(value,index)
				if SelectorInfo.Value~=value then
					SelectorInfo.Value=value
					Information.Text=tostring(value)
					if index then SelectorInfo.Index=index end
					local Success,Response=pcall(function()
						if SelectorInfo.Callback then SelectorInfo.Callback(value,index) end
					end)
					local title=SelectorInfo.Title or SelectorInfo.Name or "Selector"
					if not Success then
						Tween(Selector,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
						Tween(Selector.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
						Selector.Title.Text="Callback Error"
						print("Rayfield | "..title.." Callback Error " ..tostring(Response))
						warn("Check docs.sirius.menu for help with Rayfield specific development.")
						FastWait(0.5)
						Selector.Title.Text=title
						Tween(Selector,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
						Tween(Selector.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
					else
						if not SelectorInfo.Ext and SelectorInfo.Flag then SaveConfiguration() end
						Tween(Selector,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
						Tween(Selector.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
						FastWait(0.2)
						Tween(Selector,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
						Tween(Selector.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
					end
				end
			end
			function SelectorInfo:Add(value)
				if not table.find(SelectorInfo.Options,value) then
					table.insert(SelectorInfo.Options,value)
				end
			end
			function SelectorInfo:Remove(value)
				local pos=table.find(SelectorInfo.Options,value)
				if pos~=nil then
					table.remove(SelectorInfo.Options,pos)
				end
			end
			if SelectorInfo.Tooltip then Tooltip(SelectorInfo.Tooltip,Selector) end
			ConnectHover(PreviousButton,PreviousButton.Title)
			ConnectHover(NextButton,NextButton.Title)
			PreviousButton.Activated:Connect(function()
				local index,optionList=SelectorInfo.Index,SelectorInfo.Options
				if SelectorInfo.NoCap then
					if index<=0 then index=1 end
					index=index<=1 and #optionList or index-1
				else
					index=index<=0 and 1 or index-1
					if index<=0 then index=1 end
				end
				SelectorInfo.Index=index
				SelectorInfo:Set(tostring(optionList[index]),index)
			end)
			NextButton.Activated:Connect(function()
				local index,optionList=SelectorInfo.Index,SelectorInfo.Options
				if index<=0 then index=1 end
				if index>=#optionList then
					index=SelectorInfo.NoCap and 1 or #optionList
				else
					index+=1
				end
				SelectorInfo.Index=index
				SelectorInfo:Set(tostring(optionList[index]),index)
			end)
			if savingInfo and savingInfo.Enabled and SelectorInfo.Flag then
				Library.Flags[SelectorInfo.Flag]=SelectorInfo
			end
			local SelectorProxy=setmetatable({},{
				__index=function(_,key)
					local SelectorReturns={
						["Visible"]=Selector.Visible,
						["LayoutOrder"]=Selector.LayoutOrder,
						["Title"]=Selector.Title.Text,
					}
					return SelectorReturns[key] or SelectorInfo[key]
				end,
				__newindex=function(_,key,value)
					if key=="Visible" then
						Selector.Visible=value
					elseif key=="LayoutOrder" then
						Selector.LayoutOrder=value
					elseif key=="Title" then
						Selector.Title.Text=value
					elseif key~="Type" and key~="Set" then
						SelectorInfo[key]=value
					end
				end,
			})
			return SelectorProxy
		end
		-- Expand
		function Tab:CreateExpand(ExpandInfo)
			ExpandInfo=ExpandInfo or {}
			ExpandInfo.Type="Expand"
			if Elements.Template:FindFirstChild("Expand") then 
				local Expand=Elements.Template.Expand:Clone()
				ExpandInfo.Template=Expand
				Tab.Order+=1
				Expand.LayoutOrder=Tab.Order
				Expand.Name=ExpandInfo.Name or ExpandInfo.Title or "Expand"
				Expand.Title.Text=ExpandInfo.Title or ExpandInfo.Name or "Expand"
				Expand.Visible=true
				Expand.Parent=TabPage
				local list={}
				function ExpandInfo:Remove(value)
					if value~=nil and type(value)=="table" then
						if value.ExpandAncestryChangedConnection then
							value.ExpandAncestryChangedConnection:Disconnect() 
							value.ExpandAncestryChangedConnection=nil
						end
						local otherTemplate=value.Template
						local index=table.find(list,otherTemplate) 
						if index then table.remove(list,index) end
						if otherTemplate and otherTemplate.Parent then
							otherTemplate.Visible=true
						end
					end
				end
				function ExpandInfo:Add(value)
					if value~=nil and type(value)=="table" then
						local otherTemplate=value.Template
						if not otherTemplate then return end
						otherTemplate.Visible=ExpandInfo.Active
						table.insert(list,otherTemplate)
						value.ExpandAncestryChangedConnection=otherTemplate.AncestryChanged:Connect(function(_,parent)
							if not parent then
								ExpandInfo:Remove(value)
							end
						end)
					end
				end
				Expand.Interact.MouseButton1Click:Connect(function()
					if ExpandInfo.Debounce then return end
					ExpandInfo.Debounce=true
					local active=not ExpandInfo.Active
					ExpandInfo.Active=active
					for _,value in ipairs(list) do if value and value.Parent then value.Visible=active end end
					CallSafely(ExpandInfo.Callback,active)
					ExpandInfo.Debounce=nil
				end)
				local ExpandProxy=setmetatable({},{
					__index=function(_,key)
						local ExpandReturns={
							["Visible"]=Expand.Visible,
							["LayoutOrder"]=Expand.LayoutOrder,
							["Title"]=Expand.Title.Text,
						}
						return ExpandReturns[key] or ExpandInfo[key]
					end,
					__newindex=function(_,key,value)
						if key=="Visible" then
							Expand.Visible=value
							for _,value in ipairs(list) do
								if Expand.Visible then
									value.Visible=Expand.Active
								else
									value.Visible=false
								end
							end
						elseif key=="LayoutOrder" then
							Expand.LayoutOrder=value
						elseif key=="Title" then
							Expand.Title.Text=value
						elseif key~="Type" and key~="Add" and key~="Remove" then
							ExpandInfo[key]=value
						end
					end,
				})
				return ExpandProxy
			else
				warn("Rayfield | Expand not found, replace with section.") 
				local SectionInfo=Tab:CreateSection(ExpandInfo.Title or ExpandInfo.Name)
				SectionInfo.Type="Expand"
				SectionInfo.Active=ExpandInfo.Active
				return SectionInfo
			end
		end
		-- ColorPicker
		function Tab:CreateColorPicker(ColorPickerInfo) -- by Throit
			ColorPickerInfo=ColorPickerInfo or {}
			ColorPickerInfo.Type="ColorPicker"
			local ColorPicker=Elements.Template.ColorPicker:Clone()
			local Background=ColorPicker.CPBackground
			local Display=Background.Display
			local Main=Background.MainCP
			local Slider=ColorPicker.ColorSlider
			ColorPickerInfo.Template=ColorPicker
			Tab.Order+=1
			ColorPicker.LayoutOrder=Tab.Order
			ColorPicker.ClipsDescendants=true
			ColorPicker.Name=ColorPickerInfo.Name or ColorPickerInfo.Title or "ColorPicker"
			ColorPicker.Title.Text=ColorPickerInfo.Title or ColorPickerInfo.Name or "ColorPicker"
			ColorPicker.Visible=true
			ColorPicker.Parent=TabPage
			ColorPicker.Size=UDim2.new(1,-10,0,45)
			Background.Size=UDim2.new(0,39,0,22)
			Display.BackgroundTransparency=0
			Main.MainPoint.ImageTransparency=1
			ColorPicker.Interact.Size=UDim2.new(1,0,1,0)
			ColorPicker.Interact.Position=UDim2.new(0.5,0,0.5,0)
			ColorPicker.RGB.Position=UDim2.new(0,17,0,70)
			ColorPicker.HexInput.Position=UDim2.new(0,17,0,90)
			Main.ImageTransparency=1
			Background.BackgroundTransparency=1
			for i,v in ipairs(ColorPicker.RGB:GetChildren()) do if v:IsA("Frame") then v.BackgroundColor3=SelectedTheme.InputBackground v.UIStroke.Color=SelectedTheme.InputStroke end end
			ColorPicker.HexInput.BackgroundColor3=SelectedTheme.InputBackground
			ColorPicker.HexInput.UIStroke.Color=SelectedTheme.InputStroke
			local opened,mainDragging,sliderDragging=false,false,false
			local mouse=Players.LocalPlayer:GetMouse()
			if ColorPickerInfo.Tooltip then Tooltip(ColorPickerInfo.Tooltip,ColorPicker) end
			ColorPicker.Interact.MouseButton1Down:Connect(function()
				task.spawn(function()
					Tween(ColorPicker,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
					Tween(ColorPicker.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					FastWait(0.2)
					Tween(ColorPicker,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					Tween(ColorPicker.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
				end)
				if not opened then
					opened=true 
					Tween(Background,TweenInfo.new(0.45,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,18,0,15)})
					FastWait(0.1)
					Tween(ColorPicker,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,-10,0,120)})
					Tween(Background,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,173,0,86)})
					Tween(Display,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
					Tween(ColorPicker.Interact,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Position=UDim2.new(0.289,0,0.5,0)})
					Tween(ColorPicker.RGB,TweenInfo.new(0.8,Enum.EasingStyle.Exponential),{Position=UDim2.new(0,17,0,40)})
					Tween(ColorPicker.HexInput,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Position=UDim2.new(0,17,0,73)})
					Tween(ColorPicker.Interact,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(0.574,0,1,0)})
					Tween(Main.MainPoint,TweenInfo.new(0.2,Enum.EasingStyle.Exponential),{ImageTransparency=0})
					Tween(Main,TweenInfo.new(0.2,Enum.EasingStyle.Exponential),{ImageTransparency=SelectedTheme~=Library.Theme.Default and 0.25 or 0.1})
					Tween(Background,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
				else
					opened=false
					Tween(ColorPicker,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,-10,0,45)})
					Tween(Background,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,39,0,22)})
					Tween(ColorPicker.Interact,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,0,1,0)})
					Tween(ColorPicker.Interact,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Position=UDim2.new(0.5,0,0.5,0)})
					Tween(ColorPicker.RGB,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Position=UDim2.new(0,17,0,70)})
					Tween(ColorPicker.HexInput,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Position=UDim2.new(0,17,0,90)})
					Tween(Display,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
					Tween(Main.MainPoint,TweenInfo.new(0.2,Enum.EasingStyle.Exponential),{ImageTransparency=1})
					Tween(Main,TweenInfo.new(0.2,Enum.EasingStyle.Exponential),{ImageTransparency=1})
					Tween(Background,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
				end
			end)
			local colorPickerInputEnded=UserInputService.InputEnded:Connect(function(input,gameProcessed) 
				local inputType=input.UserInputType.Name
				if inputType=="MouseButton1" or inputType=="Touch" then
					mainDragging=false
					sliderDragging=false
				end
			end)
			Main.MouseButton1Down:Connect(function()
				if opened then mainDragging=true end
			end)
			Main.MainPoint.MouseButton1Down:Connect(function()
				if opened then mainDragging=true end
			end)
			Slider.MouseButton1Down:Connect(function()
				sliderDragging=true 
			end)
			Slider.SliderPoint.MouseButton1Down:Connect(function()
				sliderDragging=true 
			end)
			local h,s,v=ColorPickerInfo.Color:ToHSV()
			local color=Color3.fromHSV(h,s,v) 
			local hex=string.format("#%02X%02X%02X",color.R*0xFF,color.G*0xFF,color.B*0xFF)
			ColorPicker.HexInput.InputBox.Text=hex
			local function setDisplay()
				--Main
				Main.MainPoint.Position=UDim2.new(s,-Main.MainPoint.AbsoluteSize.X/2,1-v,-Main.MainPoint.AbsoluteSize.Y/2)
				Main.MainPoint.ImageColor3=Color3.fromHSV(h,s,v)
				Background.BackgroundColor3=Color3.fromHSV(h,1,1)
				Display.BackgroundColor3=Color3.fromHSV(h,s,v)
				--Slider 
				local x=h*Slider.AbsoluteSize.X
				Slider.SliderPoint.Position=UDim2.new(0,x-Slider.SliderPoint.AbsoluteSize.X/2,0.5,0)
				Slider.SliderPoint.ImageColor3=Color3.fromHSV(h,1,1)
				local color=Color3.fromHSV(h,s,v) 
				local r,g,b=math.floor((color.R*255)+0.5),math.floor((color.G*255)+0.5),math.floor((color.B*255)+0.5)
				ColorPicker.RGB.RInput.InputBox.Text=tostring(r)
				ColorPicker.RGB.GInput.InputBox.Text=tostring(g)
				ColorPicker.RGB.BInput.InputBox.Text=tostring(b)
				hex=string.format("#%02X%02X%02X",color.R*0xFF,color.G*0xFF,color.B*0xFF)
				ColorPicker.HexInput.InputBox.Text=hex
			end
			setDisplay()
			ColorPicker.HexInput.InputBox.FocusLost:Connect(function()
				if not pcall(function()
						local r,g,b=string.match(ColorPicker.HexInput.InputBox.Text,"^#?(%w%w)(%w%w)(%w%w)$")
						local rgbColor=Color3.fromRGB(tonumber(r,16),tonumber(g,16),tonumber(b,16))
						h,s,v=rgbColor:ToHSV()
						hex=ColorPicker.HexInput.InputBox.Text
						setDisplay()
						ColorPickerInfo.Color=rgbColor
					end) 
				then 
					ColorPicker.HexInput.InputBox.Text=hex 
				end
				CallSafely(ColorPickerInfo.Callback,Color3.fromHSV(h,s,v))
				local r,g,b=math.floor((h*255)+0.5),math.floor((s*255)+0.5),math.floor((v*255)+0.5)
				ColorPickerInfo.Color=Color3.fromRGB(r,g,b)
				if not ColorPickerInfo.Ext and ColorPickerInfo.Flag then
					SaveConfiguration()
				end
			end)
			local function rgbBoxes(box,toChange)
				local value=tonumber(box.Text) 
				local color=Color3.fromHSV(h,s,v) 
				local oldR,oldG,oldB=math.floor((color.R*255)+0.5),math.floor((color.G*255)+0.5),math.floor((color.B*255)+0.5)
				local origin 
				if toChange=="R" then origin=oldR;oldR=value elseif toChange=="G" then origin=oldG;oldG=value else origin=oldB;oldB=value end
				if value then 
					value=math.clamp(value,0,255)
					h,s,v=Color3.fromRGB(oldR,oldG,oldB):ToHSV()
					setDisplay()
				else 
					box.Text=tostring(origin)
				end
				local r,g,b=math.floor((h*255)+0.5),math.floor((s*255)+0.5),math.floor((v*255)+0.5)
				local rgbColor=Color3.fromRGB(r,g,b)
				ColorPickerInfo.Color=rgbColor
				if not ColorPickerInfo.Ext and ColorPickerInfo.Flag then
					SaveConfiguration()
				end
			end
			ColorPicker.RGB.RInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.RInput.InputBox,"R")
				CallSafely(ColorPickerInfo.Callback,Color3.fromHSV(h,s,v))
			end)
			ColorPicker.RGB.GInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.GInput.InputBox,"G")
				CallSafely(ColorPickerInfo.Callback,Color3.fromHSV(h,s,v))
			end)
			ColorPicker.RGB.BInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.BInput.InputBox,"B")
				CallSafely(ColorPickerInfo.Callback,Color3.fromHSV(h,s,v))
			end)
			local colorPickerLooped=RunService.RenderStepped:connect(function()
				if mainDragging then
					local localX=math.clamp(mouse.X-Main.AbsolutePosition.X,0,Main.AbsoluteSize.X)
					local localY=math.clamp(mouse.Y-Main.AbsolutePosition.Y,0,Main.AbsoluteSize.Y)
					Main.MainPoint.Position=UDim2.new(0,localX-Main.MainPoint.AbsoluteSize.X/2,0,localY-Main.MainPoint.AbsoluteSize.Y/2)
					s=localX / Main.AbsoluteSize.X
					v=1-(localY / Main.AbsoluteSize.Y)
					Display.BackgroundColor3=Color3.fromHSV(h,s,v)
					Main.MainPoint.ImageColor3=Color3.fromHSV(h,s,v)
					Background.BackgroundColor3=Color3.fromHSV(h,1,1)
					local color=Color3.fromHSV(h,s,v) 
					local r,g,b=math.floor((color.R*255)+0.5),math.floor((color.G*255)+0.5),math.floor((color.B*255)+0.5)
					ColorPicker.RGB.RInput.InputBox.Text=tostring(r)
					ColorPicker.RGB.GInput.InputBox.Text=tostring(g)
					ColorPicker.RGB.BInput.InputBox.Text=tostring(b)
					ColorPicker.HexInput.InputBox.Text=string.format("#%02X%02X%02X",color.R*0xFF,color.G*0xFF,color.B*0xFF)
					CallSafely(ColorPickerInfo.Callback,Color3.fromHSV(h,s,v))
					local value=Color3.fromRGB(r,g,b)
					ColorPickerInfo.Color=value
					if not ColorPickerInfo.Ext and ColorPickerInfo.Flag then
						SaveConfiguration()
					end
				end
				if sliderDragging then 
					local localX=math.clamp(mouse.X-Slider.AbsolutePosition.X,0,Slider.AbsoluteSize.X)
					h=localX / Slider.AbsoluteSize.X
					Display.BackgroundColor3=Color3.fromHSV(h,s,v)
					Slider.SliderPoint.Position=UDim2.new(0,localX-Slider.SliderPoint.AbsoluteSize.X/2,0.5,0)
					Slider.SliderPoint.ImageColor3=Color3.fromHSV(h,1,1)
					Background.BackgroundColor3=Color3.fromHSV(h,1,1)
					Main.MainPoint.ImageColor3=Color3.fromHSV(h,s,v)
					local color=Color3.fromHSV(h,s,v) 
					local r,g,b=math.floor((color.R*255)+0.5),math.floor((color.G*255)+0.5),math.floor((color.B*255)+0.5)
					ColorPicker.RGB.RInput.InputBox.Text=tostring(r)
					ColorPicker.RGB.GInput.InputBox.Text=tostring(g)
					ColorPicker.RGB.BInput.InputBox.Text=tostring(b)
					ColorPicker.HexInput.InputBox.Text=string.format("#%02X%02X%02X",color.R*0xFF,color.G*0xFF,color.B*0xFF)
					CallSafely(ColorPickerInfo.Callback,Color3.fromHSV(h,s,v))
					ColorPickerInfo.Color=Color3.fromRGB(r,g,b)
					if not ColorPickerInfo.Ext and ColorPickerInfo.Flag then
						SaveConfiguration()
					end
				end
			end)
			ConnectDestroying(ColorPicker,function()
				if colorPickerLooped then colorPickerLooped:Disconnect() end
				if colorPickerInputEnded then colorPickerInputEnded:Disconnect() end
			end)
			if WindowInfo.ConfigurationSaving then if WindowInfo.ConfigurationSaving.Enabled and ColorPickerInfo.Flag then Library.Flags[ColorPickerInfo.Flag]=ColorPickerInfo end end
			function ColorPickerInfo:Set(value)
				if value==nil then value=Color3.fromRGB(255,255,255) end
				ColorPickerInfo.Color=value 
				h,s,v=ColorPickerInfo.Color:ToHSV() 
				color=Color3.fromHSV(h,s,v) setDisplay()
			end
			ColorPicker.MouseEnter:Connect(function()
				Tween(ColorPicker,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
			end)
			ColorPicker.MouseLeave:Connect(function()
				Tween(ColorPicker,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
			end)
			Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				for i,v in ipairs(ColorPicker.RGB:GetChildren()) do if v:IsA("Frame") then v.BackgroundColor3=SelectedTheme.InputBackground v.UIStroke.Color=SelectedTheme.InputStroke end end ColorPicker.HexInput.BackgroundColor3=SelectedTheme.InputBackground ColorPicker.HexInput.UIStroke.Color=SelectedTheme.InputStroke
			end)
			local ColorPickerProxy=setmetatable({},{
				__index=function(_,key)
					local ColorPickerReturns={
						["Visible"]=ColorPicker.Visible,
						["LayoutOrder"]=ColorPicker.LayoutOrder,
						["Title"]=ColorPicker.Title.Text,
					}
					return ColorPickerReturns[key] or ColorPickerInfo[key]
				end,
				__newindex=function(_,key,value)
					if key=="Visible" then
						ColorPicker.Visible=value
					elseif key=="LayoutOrder" then
						ColorPicker.LayoutOrder=value
					elseif key=="Title" then
						ColorPicker.Title.Text=value
					elseif key~="Type" and key~="Set" then
						ColorPickerInfo[key]=value
					end
				end,
			})
			return ColorPickerProxy
		end
		-- Input
		function Tab:CreateInput(InputInfo)
			InputInfo=InputInfo or {}
			local Input=Elements.Template.Input:Clone()
			local InputBox:TextBox=Input.InputFrame.InputBox
			InputInfo.Template=Input
			Tab.Order+=1
			Input.LayoutOrder=Tab.Order
			Input.Name=InputInfo.Name or InputInfo.Title or "Input"
			Input.Title.Text=InputInfo.Title or InputInfo.Name or "Input"
			Input.Visible=true
			Input.Parent=TabPage
			Input.BackgroundTransparency=1
			Input.UIStroke.Transparency=1
			Input.Title.TextTransparency=1
			InputBox.Text=tostring(InputInfo.Value)
			Input.InputFrame.BackgroundColor3=SelectedTheme.InputBackground
			Input.InputFrame.UIStroke.Color=SelectedTheme.InputStroke
			Tween(Input,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			Tween(Input.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0})
			Tween(Input.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
			InputBox.PlaceholderText=InputInfo.PlaceholderText or ""
			Input.InputFrame.Size=UDim2.new(0,InputBox.TextBounds.X+24,0,30)
			if InputInfo.Tooltip then Tooltip(InputInfo.Tooltip,Input) end
			InputBox.FocusLost:Connect(function(enter)
				if not InputInfo.NoEnter and not enter then return end
				local inputText=InputBox.Text
				if InputInfo.RemoveTextAfterFocusLost or InputInfo.ClearOnFocus then InputBox.Text="" end
				local Success,Response=pcall(InputInfo.Callback,inputText)
				if not Success then
					Tween(Input,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
					Tween(Input.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					Input.Title.Text="Callback Error"
					print("Rayfield | "..InputInfo.Name.." Callback Error " ..tostring(Response))
					warn("Check docs.sirius.menu for help with Rayfield specific development.")
					FastWait(0.5)
					Input.Title.Text=InputInfo.Name
					Tween(Input,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					Tween(Input.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
				end
				if not InputInfo.Ext and InputInfo.Flag then SaveConfiguration() end
			end)
			Input.MouseEnter:Connect(function()
				Tween(Input,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
			end)
			Input.MouseLeave:Connect(function()
				Tween(Input,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
			end)
			InputBox:GetPropertyChangedSignal("Text"):Connect(function()
				Tween(Input.InputFrame,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Size=UDim2.new(0,InputBox.TextBounds.X+24,0,30)})
			end)
			function InputInfo:Replace(text)
				if InputInfo.Value~=text then
					InputInfo.Value=text
					InputBox.Text=text
					if not InputInfo.Ext and InputInfo.Flag then SaveConfiguration() end
				end
			end
			function InputInfo:Set(text)
				InputBox.Text=text
				InputInfo.Value=text
				CallSafely(InputInfo.Callback,text)
				if not InputInfo.Ext and InputInfo.Flag then SaveConfiguration() end
			end
			if savingInfo and savingInfo.Enabled and InputInfo.Flag then
				Library.Flags[InputInfo.Flag]=InputInfo
			end
			Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Input.InputFrame.BackgroundColor3=SelectedTheme.InputBackground
				Input.InputFrame.UIStroke.Color=SelectedTheme.InputStroke
			end)
			local InputProxy=setmetatable({},{
				__index=function(_,key)
					local InputReturns={
						["Visible"]=Input.Visible,
						["LayoutOrder"]=Input.LayoutOrder,
						["Title"]=Input.Title.Text,
						["Text"]=InputBox.Text,
						["PlaceholderText"]=InputBox.PlaceholderText,
						["TextColor3"]=InputBox.TextColor3,
						["PlaceholderColor3"]=InputBox.PlaceholderColor3
					}
					return InputReturns[key] or InputInfo[key]
				end,
				__newindex=function(_,key,value)
					if key=="Visible" then
						Input.Visible=value
					elseif key=="LayoutOrder" then
						Input.LayoutOrder=value
					elseif key=="Title" then
						Input.Title.Text=value
					elseif key=="Text" or key=="PlaceholderText" or key=="TextColor3" or key=="PlaceholderColor3" then
						InputBox[key]=value
					elseif key~="Type" and key~="Set" and key~="Replace" then
						InputInfo[key]=value
					end
				end,
			})
			return InputProxy
		end
		-- Dropdown
		function Tab:CreateDropdown(DropdownInfo)
			DropdownInfo=DropdownInfo or {}
			local Dropdown=Elements.Template.Dropdown:Clone()
			local InputBox=Dropdown:FindFirstChild("InputBox")
			if InputBox then
				InputBox.Visible=false
				InputBox.Text=DropdownInfo.Title or DropdownInfo.Name
			end
			DropdownInfo.Template=Dropdown
			Tab.Order+=1
			Dropdown.LayoutOrder=Tab.Order
			Dropdown.Name=DropdownInfo.Name or DropdownInfo.Title or "Dropdown"
			Dropdown.Title.Text=DropdownInfo.Title or DropdownInfo.Name or "Dropdown"
			Dropdown.Visible=true
			Dropdown.Parent=TabPage
			Dropdown.List.Visible=false
			if not DropdownInfo.Options or type(DropdownInfo.Options)~="table" or #DropdownInfo.Options<=0 then
				DropdownInfo.Options={"Option 1","Option 2"}
			end
			if DropdownInfo.Option then
				if type(DropdownInfo.Option)=="string" then
					DropdownInfo.Option={DropdownInfo.Option}
				end
				if not DropdownInfo.MultipleOptions and type(DropdownInfo.Option)=="table" then
					DropdownInfo.Option={DropdownInfo.Option[1]}
				end
				if type(DropdownInfo.Option)~="table" then
					DropdownInfo.Option={}
				end
			else
				DropdownInfo.Option={}
			end
			if DropdownInfo.MultipleOptions then
				if DropdownInfo.Option and type(DropdownInfo.Option)=="table" then
					if #DropdownInfo.Option==1 then
						Dropdown.Selected.Text=DropdownInfo.Option[1]
					elseif #DropdownInfo.Option==0 then
						Dropdown.Selected.Text="None"
					else
						Dropdown.Selected.Text="Various"
					end
				else
					DropdownInfo.Option={}
					Dropdown.Selected.Text="None"
				end
			else
				Dropdown.Selected.Text=DropdownInfo.Option[1] or "None"
			end
			Dropdown.Toggle.ImageColor3=SelectedTheme.TextColor
			Tween(Dropdown,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
			Dropdown.BackgroundTransparency=1
			Dropdown.UIStroke.Transparency=1
			Dropdown.Title.TextTransparency=1
			Dropdown.Size=UDim2.new(1,-10,0,45)
			Tween(Dropdown,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			Tween(Dropdown.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0})
			Tween(Dropdown.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
			for _,ununusedoption in ipairs(Dropdown.List:GetChildren()) do if ununusedoption.ClassName=="Frame" and ununusedoption.Name~="Placeholder" then ununusedoption:Destroy() end end
			Dropdown.Toggle.Rotation=180
			if InputBox then
				InputBox:GetPropertyChangedSignal("Text"):Connect(function()
					if InputBox.Visible and Dropdown.List.Visible then
						local inputText=string.lower(InputBox.Text)
						for _,v in ipairs(Dropdown.List:GetChildren()) do
							local visible=false
							if v and v.Parent and v.ClassName=="Frame" and v.Name~="Placeholder" then
								for j,text in ipairs({v.Name,string.lower(v.Name)}) do
									visible=string.find(text,inputText,1,true) and true or false 
									if visible then break end
								end
								if v and v.Parent then
									v.Visible=visible
								end
							end
						end
					end
				end)
			end
			local function SetInputVisible(visible)
				if InputBox then
					if visible then
						InputBox.Text=DropdownInfo.Title or DropdownInfo.Name or "Dropdown"
						InputBox.Visible=false
						Dropdown.Title.Visible=true
					else
						Dropdown.Title.Visible=false
						InputBox.Text=DropdownInfo.Title or DropdownInfo.Name or "Dropdown"
						InputBox.Visible=true
					end
				end
			end
			if DropdownInfo.Tooltip then Tooltip(DropdownInfo.Tooltip,Dropdown) end
			Dropdown.Interact.MouseButton1Click:Connect(function()
				Tween(Dropdown,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
				Tween(Dropdown.UIStroke,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{Transparency=1})
				FastWait(0.1)
				Tween(Dropdown,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
				Tween(Dropdown.UIStroke,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{Transparency=0})
				if Dropdown.List.Visible then
					if Debounce then return end
					Debounce=true
					SetInputVisible(true)
					Tween(Dropdown,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,-10,0,45)})
					for i,v in ipairs(Dropdown.List:GetChildren()) do
						if v.ClassName=="Frame" and v.Name~="Placeholder" then
							Tween(v,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
							Tween(v.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=1})
							Tween(v.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=1})
						end
					end
					Tween(Dropdown.List,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ScrollBarImageTransparency=1})
					Tween(Dropdown.Toggle,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Rotation=180})	
					FastWait(0.35)
					Dropdown.List.Visible=false
					Debounce=false
				else
					SetInputVisible(false)
					Tween(Dropdown,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,-10,0,180)})
					Dropdown.List.Visible=true
					Tween(Dropdown.List,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ScrollBarImageTransparency=0.7})
					Tween(Dropdown.Toggle,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Rotation=0})	
					for i,v in ipairs(Dropdown.List:GetChildren()) do
						if v.ClassName=="Frame" and v.Name~="Placeholder" then
							if v.Name~=Dropdown.Selected.Text then
								Tween(v.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=0})
							end
							Tween(v,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
							Tween(v.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=0})
						end
					end
				end
			end)
			Dropdown.MouseEnter:Connect(function()
				if not Dropdown.List.Visible then
					Tween(Dropdown,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
				end
			end)
			Dropdown.MouseLeave:Connect(function()
				Tween(Dropdown,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
			end)
			local function SetDropdownOptions()
				for i,v in ipairs(DropdownInfo.Options) do
					local DropdownOption=Elements.Template.Dropdown.List.Template:Clone()
					DropdownOption.Name=v
					DropdownOption.Title.Text=v
					DropdownOption.Visible=true
					DropdownOption.BackgroundTransparency=1
					DropdownOption.UIStroke.Transparency=1
					DropdownOption.Title.TextTransparency=1
					DropdownOption.Interact.ZIndex=50
					DropdownOption.Parent=Dropdown.List
					DropdownOption.Interact.MouseButton1Click:Connect(function()
						if not DropdownInfo.MultipleOptions and table.find(DropdownInfo.Option,v) then return end
						local foundIndex=table.find(DropdownInfo.Option,v)
						if foundIndex then
							table.remove(DropdownInfo.Option,foundIndex)
							if DropdownInfo.MultipleOptions then
								if #DropdownInfo.Option==1 then
									Dropdown.Selected.Text=DropdownInfo.Option[1]
								elseif #DropdownInfo.Option==0 then
									Dropdown.Selected.Text="None"
								else
									Dropdown.Selected.Text="Various"
								end
							else
								Dropdown.Selected.Text=DropdownInfo.Option[1]
							end
						else
							if not DropdownInfo.MultipleOptions then
								table.clear(DropdownInfo.Option)
							end
							table.insert(DropdownInfo.Option,v)
							if DropdownInfo.MultipleOptions then
								if #DropdownInfo.Option==1 then
									Dropdown.Selected.Text=DropdownInfo.Option[1]
								elseif #DropdownInfo.Option==0 then
									Dropdown.Selected.Text="None"
								else
									Dropdown.Selected.Text="Various"
								end
							else
								Dropdown.Selected.Text=DropdownInfo.Option[1]
							end
							Tween(DropdownOption.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=1})
							Tween(DropdownOption,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.DropdownSelected})
							Debounce=true
						end
						local Success,Response=pcall(DropdownInfo.Callback,DropdownInfo.Option)
						if not Success then
							Tween(Dropdown,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
							Tween(Dropdown.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
							Dropdown.Title.Text="Callback Error"
							print("Rayfield | "..DropdownInfo.Name.." Callback Error " ..tostring(Response))
							warn("Check docs.sirius.menu for help with Rayfield specific development.")
							FastWait(0.5)
							Dropdown.Title.Text=DropdownInfo.Name
							Tween(Dropdown,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
							Tween(Dropdown.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
						end
						for _,droption in ipairs(Dropdown.List:GetChildren()) do if droption.ClassName=="Frame" and droption.Name~="Placeholder" and not table.find(DropdownInfo.Option,droption.Name) then Tween(droption,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.DropdownUnselected}) end end
						if not DropdownInfo.MultipleOptions then
							FastWait(0.1)
							SetInputVisible(true)
							Tween(Dropdown,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,-10,0,45)})
							for _,droption in ipairs(Dropdown.List:GetChildren()) do
								if droption.ClassName=="Frame" and droption.Name~="Placeholder" then
									Tween(droption,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
									Tween(droption.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=1})
									Tween(droption.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=1})
									droption.Visible=true
								end
							end
							Tween(Dropdown.List,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ScrollBarImageTransparency=1})
							Tween(Dropdown.Toggle,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Rotation=180})	
							FastWait(0.35)
							Dropdown.List.Visible=false
						end
						Debounce=false
						if not DropdownInfo.Ext and DropdownInfo.Flag then SaveConfiguration() end
					end)
					Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
						DropdownOption.UIStroke.Color=SelectedTheme.ElementStroke
					end)
				end
			end
			SetDropdownOptions()
			for _,droption in ipairs(Dropdown.List:GetChildren()) do if droption.ClassName=="Frame" and droption.Name~="Placeholder" then if not table.find(DropdownInfo.Option,droption.Name) then droption.BackgroundColor3=SelectedTheme.DropdownUnselected else droption.BackgroundColor3=SelectedTheme.DropdownSelected end Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(function() if not table.find(DropdownInfo.Option,droption.Name) then droption.BackgroundColor3=SelectedTheme.DropdownUnselected else droption.BackgroundColor3=SelectedTheme.DropdownSelected end end) end end
			function DropdownInfo:Set(value)
				if value==nil then value={} end
				local valueType=type(value)
				if valueType=="string" then
					value={value}
				elseif valueType~="table" then
					value={}
				end
				if not DropdownInfo.MultipleOptions then
					value={value[1]}
				end
				DropdownInfo.Option=value
				if DropdownInfo.MultipleOptions then
					if #DropdownInfo.Option==1 then
						Dropdown.Selected.Text=DropdownInfo.Option[1]
					elseif #DropdownInfo.Option==0 then
						Dropdown.Selected.Text="None"
					else
						Dropdown.Selected.Text="Various"
					end
				else
					Dropdown.Selected.Text=DropdownInfo.Option[1]
				end
				local Success,Response=pcall(DropdownInfo.Callback)
				if not Success then
					Tween(Dropdown,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
					Tween(Dropdown.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					Dropdown.Title.Text="Callback Error"
					print("Rayfield | "..DropdownInfo.Name.." Callback Error " ..tostring(Response))
					warn("Check docs.sirius.menu for help with Rayfield specific development.")
					FastWait(0.5)
					Dropdown.Title.Text=DropdownInfo.Name
					Tween(Dropdown,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					Tween(Dropdown.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
				end
				for _,droption in ipairs(Dropdown.List:GetChildren()) do
					if droption.ClassName=="Frame" and droption.Name~="Placeholder" then
						if not table.find(value,droption.Name) then
							droption.BackgroundColor3=SelectedTheme.DropdownUnselected
						else
							droption.BackgroundColor3=SelectedTheme.DropdownSelected
						end
					end
				end
			end
			function DropdownInfo:Refresh(options) -- updates a dropdown with new options from optionsTable
				DropdownInfo.Options=options
				for _,option in Dropdown.List:GetChildren() do if option.ClassName=="Frame" and option.Name~="Placeholder" then option:Destroy() end end
				SetDropdownOptions()
				-- Apply selected/unselected background colors to new options
				for _,droption in ipairs(Dropdown.List:GetChildren()) do
					if droption.ClassName=="Frame" and droption.Name~="Placeholder" then
						if not table.find(DropdownInfo.Option,droption.Name) then
							droption.BackgroundColor3=SelectedTheme.DropdownUnselected
						else
							droption.BackgroundColor3=SelectedTheme.DropdownSelected
						end
					end
				end
				-- If the dropdown is currently open,make new options visible immediately
				if Dropdown.List.Visible then
					for _,DropdownOpt in ipairs(Dropdown.List:GetChildren()) do
						if DropdownOpt.ClassName=="Frame" and DropdownOpt.Name~="Placeholder" then
							DropdownOpt.BackgroundTransparency=0
							DropdownOpt.Title.TextTransparency=0
							if not table.find(DropdownInfo.Option,DropdownOpt.Name) then
								DropdownOpt.UIStroke.Transparency=0
							end
						end
					end
				end
			end
			if savingInfo and savingInfo.Enabled and DropdownInfo.Flag then Library.Flags[DropdownInfo.Flag]=DropdownInfo end
			Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Dropdown.Toggle.ImageColor3=SelectedTheme.TextColor Tween(Dropdown,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
			end)
			local DropdownProxy=setmetatable({},{
				__index=function(_,key)
					local DropdownReturns={
						["Visible"]=Dropdown.Visible,
						["LayoutOrder"]=Dropdown.LayoutOrder,
						["Title"]=Dropdown.Title.Text,
					}
					return DropdownReturns[key] or DropdownInfo[key]
				end,
				__newindex=function(_,key,value)
					if key=="Visible" then
						Dropdown.Visible=value
					elseif key=="LayoutOrder" then
						Dropdown.LayoutOrder=value
					elseif key=="Title" then
						Dropdown.Title.Text=value
					elseif key~="Type" and key~="Set" and key~="Refresh" then
						DropdownInfo[key]=value
					end
				end,
			})
			return DropdownProxy
		end
		-- Keybind
		function Tab:CreateKeybind(KeybindInfo)
			KeybindInfo=KeybindInfo or {}
			local CheckingForKey=false
			local Keybind=Elements.Template.Keybind:Clone()
			KeybindInfo.Template=Keybind
			Tab.Order+=1
			Keybind.LayoutOrder=Tab.Order
			Keybind.Name=KeybindInfo.Name or KeybindInfo.Title
			Keybind.Title.Text=KeybindInfo.Title or KeybindInfo.Name
			Keybind.Visible=true
			Keybind.Parent=TabPage
			Keybind.BackgroundTransparency=1
			Keybind.UIStroke.Transparency=1
			Keybind.Title.TextTransparency=1
			Keybind.KeybindFrame.BackgroundColor3=SelectedTheme.InputBackground
			Keybind.KeybindFrame.UIStroke.Color=SelectedTheme.InputStroke
			Tween(Keybind,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			Tween(Keybind.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0})
			Tween(Keybind.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
			Keybind.KeybindFrame.KeybindBox.Text=KeybindInfo.Keybind
			Keybind.KeybindFrame.Size=UDim2.new(0,Keybind.KeybindFrame.KeybindBox.TextBounds.X+24,0,30)
			if KeybindInfo.Tooltip then Tooltip(KeybindInfo.Tooltip,Keybind) end
			Keybind.KeybindFrame.KeybindBox.Focused:Connect(function()
				CheckingForKey=true Keybind.KeybindFrame.KeybindBox.Text="..."
			end)
			Keybind.KeybindFrame.KeybindBox.FocusLost:Connect(function()
				CheckingForKey=false
				local inputText=Keybind.KeybindFrame.KeybindBox.Text
				if Strs.IsEmpty(inputText) or inputText=="..." then
					Keybind.KeybindFrame.KeybindBox.Text=KeybindInfo.Keybind
					if not KeybindInfo.Ext and KeybindInfo.Flag then SaveConfiguration() end
				end
			end)
			Keybind.MouseEnter:Connect(function()
				Tween(Keybind,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
			end)
			Keybind.MouseLeave:Connect(function()
				Tween(Keybind,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
			end)
			local keybindInputBegan=UserInputService.InputBegan:Connect(function(input,processed)
				if CheckingForKey then
					if input.KeyCode~=Enum.KeyCode.Unknown then
						local SplitMessage=string.split(tostring(input.KeyCode),".")
						local NewKeyNoEnum=SplitMessage[3]
						Keybind.KeybindFrame.KeybindBox.Text=tostring(NewKeyNoEnum)
						KeybindInfo.Keybind=tostring(NewKeyNoEnum)
						KeybindInfo.Value=tostring(NewKeyNoEnum)
						Keybind.KeybindFrame.KeybindBox:ReleaseFocus()
						if not KeybindInfo.Ext and KeybindInfo.Flag then SaveConfiguration() end
						if KeybindInfo.CallOnChange then KeybindInfo.Callback(tostring(NewKeyNoEnum)) end
					end
				elseif not KeybindInfo.CallOnChange and KeybindInfo.Keybind~=nil and (input.KeyCode==Enum.KeyCode[KeybindInfo.Keybind] and not processed) then -- Test
					local Held=true
					local Connection
					Connection=input.Changed:Connect(function(prop)
						if prop=="UserInputState" then
							Connection:Disconnect()
							Held=false
						end
					end)
					if not KeybindInfo.HoldToInteract then
						local Success,Response=pcall(KeybindInfo.Callback)
						if not Success then
							Tween(Keybind,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
							Tween(Keybind.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
							Keybind.Title.Text="Callback Error"
							print("Rayfield | "..KeybindInfo.Name.." Callback Error " ..tostring(Response))
							warn("Check docs.sirius.menu for help with Rayfield specific development.")
							FastWait(0.5)
							Keybind.Title.Text=KeybindInfo.Name
							Tween(Keybind,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
							Tween(Keybind.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
						end
					else
						FastWait(0.25)
						if Held then
							local Loop
							Loop=RunService.Stepped:Connect(function()
								if not Held then
									KeybindInfo.Callback(false)
									Loop:Disconnect()
								else
									KeybindInfo.Callback(true)
								end
							end)
						end
					end
				end
			end)
			table.insert(Connections,keybindInputBegan)
			Keybind.KeybindFrame.KeybindBox:GetPropertyChangedSignal("Text"):Connect(function()
				Tween(Keybind.KeybindFrame,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Size=UDim2.new(0,Keybind.KeybindFrame.KeybindBox.TextBounds.X+24,0,30)})
			end)
			function KeybindInfo:Set(value)
				Keybind.KeybindFrame.KeybindBox.Text=tostring(value)
				KeybindInfo.Keybind=tostring(value)
				Keybind.KeybindFrame.KeybindBox:ReleaseFocus()
				if not KeybindInfo.Ext and KeybindInfo.Flag then SaveConfiguration() end
				if KeybindInfo.CallOnChange then CallSafely(KeybindInfo.Callback,tostring(value)) end
			end
			if savingInfo and savingInfo.Enabled and KeybindInfo.Flag then
				Library.Flags[KeybindInfo.Flag]=KeybindInfo
			end
			Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Keybind.KeybindFrame.BackgroundColor3=SelectedTheme.InputBackground
				Keybind.KeybindFrame.UIStroke.Color=SelectedTheme.InputStroke
			end)
			local KeybindProxy=setmetatable({},{
				__index=function(_,key)
					local KeybindReturns={
						["Visible"]=Keybind.Visible,
						["LayoutOrder"]=Keybind.LayoutOrder,
						["Title"]=Keybind.Title.Text,
					}
					return KeybindReturns[key] or KeybindInfo[key]
				end,
				__newindex=function(_,key,value)
					if key=="Visible" then
						Keybind.Visible=value
					elseif key=="LayoutOrder" then
						Keybind.LayoutOrder=value
					elseif key=="Title" then
						Keybind.Title.Text=value
					elseif key~="Type" and key~="Set" then
						KeybindInfo[key]=value
					end
				end,
			})
			return KeybindProxy
		end
		-- Slider
		function Tab:CreateSlider(SliderInfo) -- V1 by Rayfield, V2, by Paazlis
			SliderInfo=SliderInfo or {}
			if SliderInfo.Value==nil then SliderInfo.Value=0 end
			local SLDragging,Slider,total=false,nil,10
			local ApplyPercent=function(value)
				local percent,multi=SliderInfo.Percent,1
				for i=2,total do multi=multi+((percent*i)/100) end
				SliderInfo.Range={value,math.floor(value*multi)}
			end
			if SliderInfo.Percent then
				ApplyPercent(SliderInfo.Value)
			else
				if type(SliderInfo.Range)~="table" then SliderInfo.Range={10,100} end
				for i=1,2 do if SliderInfo.Range[i]==nil then if i==1 then SliderInfo.Range[1]=10 else SliderInfo.Range[2]=100 end end end
			end
			Tab.Order+=1
			local ApplyTextLabel=function(label,value)
				local valueStr,suffix=Strs.ToNumberString(value),SliderInfo.Suffix
				if not Strs.IsEmpty(suffix) then label.Text=valueStr.." "..suffix else label.Text=valueStr end
			end
			if SliderInfo.Version==2 and Elements.Template:FindFirstChild("SliderPro") then
				Slider=Elements.Template.SliderPro:Clone()
				SliderInfo.Template=Slider
				Slider.LayoutOrder=Tab.Order
				Slider.Name=SliderInfo.Name or SliderInfo.Title or "Slider"
				Slider.Title.Text=SliderInfo.Title or SliderInfo.Name or "Slider"
				Slider.Parent=TabPage
				local SliderPlus,SliderMinus,SliderIndicator,SliderTextBox=Slider:FindFirstChild("Plus"),Slider:FindFirstChild("Minus"),Slider:FindFirstChild("Indicator"),Slider:FindFirstChild("TextBox")
				local Bars,List={},{}
				SliderTextBox.Text=""
				SliderIndicator.Bar.Visible=false
				local ConnectHover=function(frame,object)
					frame.MouseEnter:Connect(function()
						Tween(object,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0.4})
					end)
					frame.MouseLeave:Connect(function()
						Tween(object,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})
					end)
				end
				local ApplyTheme=function()
					local textColor=SelectedTheme.TextColor
					SliderPlus.TextColor3=textColor
					SliderMinus.TextColor3=textColor
					SliderTextBox.TextColor3=textColor
					SliderTextBox.PlaceholderColor3=SelectedTheme.PlaceholderColor
					for i,v in ipairs(Bars) do
						v.BackgroundColor3=i<=SliderInfo.Index and SelectedTheme.TabBackgroundSelected or SelectedTheme.TabBackground
					end
				end
				local UpdateBar=function()
					local min,max=SliderInfo.Range[1],SliderInfo.Range[2]
					for i=1,total do
						local bar=SliderIndicator.Bar:Clone()
						bar.Name=tostring(i)
						bar.LayoutOrder=i
						bar.Visible=true
						bar.Parent=SliderIndicator
						local nextValue=0
						if i~=1 then
							i=i-1
							if SliderInfo.Reverse then
								nextValue=min-(max-min)*(i/total)
							else
								nextValue=min+(max-min)*(i/total)
							end
						else
							nextValue=SliderInfo.Value
						end
						if not SliderInfo.NoCap then
							nextValue=math.clamp(nextValue,min,max)
						end
						table.insert(List,nextValue)
						table.insert(Bars,bar)
					end
				end
				local UpdateMinusOrPlus=function()
					SliderPlus.Visible=SliderInfo.Index<total and true or false
					SliderMinus.Visible=SliderInfo.Index>1
					for i,v in ipairs(Bars) do
						v.BackgroundColor3=i<=SliderInfo.Index and SelectedTheme.TabBackgroundSelected or SelectedTheme.TabBackground
					end
				end
				local GetIndex=function(value)
					local newIndex,newValue,trying=SliderInfo.Index or 1,SliderInfo.Value or List[1],false
					for nextIndex,nextValue in ipairs(List) do if nextValue<=value then trying=true newValue=nextValue newIndex=nextIndex end end
					if not trying then return 1,List[1] end
					return newIndex,newValue
				end
				ConnectHover(SliderPlus,SliderPlus)
				ConnectHover(SliderMinus,SliderMinus)
				UpdateBar()
				local ThisIndex,ThisValue=GetIndex(SliderInfo.Value)
				SliderInfo.Index=ThisIndex
				UpdateMinusOrPlus()
				ApplyTextLabel(Slider.TextBox,ThisValue)
				ApplyTheme()
				local sliderInputEnded=UserInputService.InputEnded:Connect(function(input)
					local userInputType=input.UserInputType
					if userInputType==Enum.UserInputType.MouseButton1 or userInputType==Enum.UserInputType.Touch and SLDragging==true then
						SLDragging=false
					end
				end)
				table.insert(Connections,sliderInputEnded)
				function SliderInfo:Set(value,index)
					if SliderInfo.Index~=index then
						SliderInfo.Index=index
						local nextValue=value or List[index]
						SliderInfo.Value=nextValue
						UpdateMinusOrPlus()
						ApplyTextLabel(Slider.TextBox,nextValue)
						CallSafely(SliderInfo.Callback,nextValue)
					end
				end
				function SliderInfo:Refresh(value)
					SliderInfo.Value=value
					SliderInfo.Index=1
					if SliderInfo.Percent then
						ApplyPercent(value)
					else
						if type(SliderInfo.Range)~="table" then SliderInfo.Range={10,100} end
						for i=1,2 do if SliderInfo.Range[i]==nil then if i==1 then SliderInfo.Range[1]=10 else SliderInfo.Range[2]=100 end end end
					end
					local min,max=SliderInfo.Range[1],SliderInfo.Range[2]
					for i=1,#List do
						local nextValue=0
						if i~=1 then
							i=i-1
							if SliderInfo.Reverse then
								nextValue=min-(max-min)*(i/total)
							else
								nextValue=min+(max-min)*(i/total)
							end
						else
							nextValue=value
						end
						if not SliderInfo.NoCap then
							nextValue=math.clamp(nextValue,min,max)
						end
						List[i]=nextValue
					end
					for i,v in ipairs(List) do
						if i==1 then
							v=value
						else
							v-=value
						end
						List[i]=v
					end
					UpdateMinusOrPlus()
					ApplyTextLabel(Slider.TextBox,value)
				end
				for i,v in ipairs(Bars) do
					v.MouseButton1Down:Connect(function(input)
						SLDragging=true 
						SliderInfo:Set(List[i],i)
					end)
					v.MouseButton1Up:Connect(function()
						SLDragging=false
					end)
					v.MouseEnter:Connect(function()
						if SLDragging==true then 
							SliderInfo:Set(List[i],i) 
						end
					end)
				end
				SliderPlus.MouseButton1Click:Connect(function()
					local NewValue,NewIndex=SliderInfo.Value,SliderInfo.Index
					NewIndex+=1
					if NewIndex>=total then NewIndex=total end
					NewValue=List[NewIndex]
					SliderInfo.Index=NewIndex
					SliderInfo.Value=NewValue
					UpdateMinusOrPlus()
					ApplyTextLabel(Slider.TextBox,NewValue)
					CallSafely(SliderInfo.Callback,NewValue)
				end)
				SliderMinus.Activated:Connect(function()
					local NewValue,NewIndex=SliderInfo.Value,SliderInfo.Index
					if NewIndex>1 then 
						NewIndex-=1
						NewValue=List[NewIndex]
						SliderInfo.Index=NewIndex
						SliderInfo.Value=NewValue
						UpdateMinusOrPlus()
						ApplyTextLabel(Slider.TextBox,NewValue)
						CallSafely(SliderInfo.Callback,NewValue)
					end
				end)
				SliderTextBox.FocusLost:Connect(function(enter)
					if not enter then return end 
					if Strs.IsEmpty(Slider.TextBox.Text) then ApplyTextLabel(Slider.TextBox,tostring(SliderInfo.Value)) return end
					local NewIndex,NewValue,InputText=SliderInfo.Index,SliderInfo.Value,SliderTextBox.Text 
					if Strs.IsOriginal(InputText) then 
						SliderInfo:Set(List[1],1) 
					else 
						local InputNumber=tonumber(InputText) 
						if InputNumber then
							NewIndex=GetIndex(InputNumber)  
							NewValue=InputNumber 
						end 
						SliderInfo.Index=NewIndex 
						SliderInfo.Value=NewValue 
						UpdateMinusOrPlus() 
						ApplyTextLabel(Slider.TextBox,NewValue)
						CallSafely(SliderInfo.Callback,NewValue)
					end
				end)
				if savingInfo and savingInfo.Enabled and SliderInfo.Flag then
					Library.Flags[SliderInfo.Flag]=SliderInfo
				end
				Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(ApplyTheme)
			else
				Slider=Elements.Template.Slider:Clone()
				SliderInfo.Template=Slider
				Slider.LayoutOrder=Tab.Order
				Slider.Name=SliderInfo.Name or SliderInfo.Title or "Slider"
				Slider.Title.Text=SliderInfo.Title or SliderInfo.Name or "Slider"
				Slider.Visible=true
				Slider.Parent=TabPage
				Slider.BackgroundTransparency=1
				Slider.UIStroke.Transparency=1
				Slider.Title.TextTransparency=1
				local ApplyTheme=function()
					if SelectedTheme~=Library.Theme.Default then
						Slider.Main.Shadow.Visible=false
					end
					Slider.Main.BackgroundColor3=SelectedTheme.SliderBackground
					Slider.Main.UIStroke.Color=SelectedTheme.SliderStroke
					Slider.Main.Progress.UIStroke.Color=SelectedTheme.SliderStroke
					Slider.Main.Progress.BackgroundColor3=SelectedTheme.SliderProgress
				end
				ApplyTheme()
				Tween(Slider,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
				Tween(Slider.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0})
				Tween(Slider.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
				Slider.Main.Progress.Size=UDim2.new(0,Slider.Main.AbsoluteSize.X * ((SliderInfo.Value-SliderInfo.Range[1]) / (SliderInfo.Range[2]-SliderInfo.Range[1]))>5 and Slider.Main.AbsoluteSize.X * ((SliderInfo.Value-SliderInfo.Range[1]) / (SliderInfo.Range[2]-SliderInfo.Range[1])) or 5,1,0)
				ApplyTextLabel(Slider.Main.Information,SliderInfo.Value)
				Slider.MouseEnter:Connect(function()
					Tween(Slider,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
				end)
				Slider.MouseLeave:Connect(function()
					Tween(Slider,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
				end)
				Slider.Main.Interact.InputBegan:Connect(function(Input)
					if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then 
						Tween(Slider.Main.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
						Tween(Slider.Main.Progress.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
						SLDragging=true 
					end 
				end)
				Slider.Main.Interact.InputEnded:Connect(function(Input) 
					if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then 
						Tween(Slider.Main.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0.4})
						Tween(Slider.Main.Progress.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0.3})
						SLDragging=false 
					end 
				end)
				Slider.Main.Interact.MouseButton1Down:Connect(function(X)
					local Current=Slider.Main.Progress.AbsolutePosition.X+Slider.Main.Progress.AbsoluteSize.X
					local Start=Current
					local Location=X
					local Loop; Loop=RunService.Stepped:Connect(function()
						if SLDragging then
							Location=UserInputService:GetMouseLocation().X
							Current=Current+0.025 * (Location-Start)
							if Location<Slider.Main.AbsolutePosition.X then
								Location=Slider.Main.AbsolutePosition.X
							elseif Location>Slider.Main.AbsolutePosition.X+Slider.Main.AbsoluteSize.X then
								Location=Slider.Main.AbsolutePosition.X+Slider.Main.AbsoluteSize.X
							end
							if Current<Slider.Main.AbsolutePosition.X+5 then
								Current=Slider.Main.AbsolutePosition.X+5
							elseif Current>Slider.Main.AbsolutePosition.X+Slider.Main.AbsoluteSize.X then
								Current=Slider.Main.AbsolutePosition.X+Slider.Main.AbsoluteSize.X
							end
							if Current <= Location and (Location-Start)<0 then
								Start=Location
							elseif Current >= Location and (Location-Start)>0 then
								Start=Location
							end
							Tween(Slider.Main.Progress,TweenInfo.new(0.45,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Size=UDim2.new(0,Current-Slider.Main.AbsolutePosition.X,1,0)})
							local NewValue=SliderInfo.Range[1]+(Location-Slider.Main.AbsolutePosition.X) / Slider.Main.AbsoluteSize.X * (SliderInfo.Range[2]-SliderInfo.Range[1])
							NewValue=math.floor(NewValue / SliderInfo.Increment+0.5) * (SliderInfo.Increment * 10000000) / 10000000
							NewValue=math.clamp(NewValue,SliderInfo.Range[1],SliderInfo.Range[2])
							if not SliderInfo.Suffix then
								Slider.Main.Information.Text=tostring(NewValue)
							else
								Slider.Main.Information.Text=tostring(NewValue) .. " " .. SliderInfo.Suffix
							end
							if SliderInfo.Value~=NewValue then
								SliderInfo.Value=NewValue
								local Success,Response=pcall(SliderInfo.Callback,NewValue)
								if not Success then
									Tween(Slider,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
									Tween(Slider.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
									Slider.Title.Text="Callback Error"
									print("Rayfield | "..SliderInfo.Name.." Callback Error " ..tostring(Response))
									warn("Check docs.sirius.menu for help with Rayfield specific development.")
									FastWait(0.5)
									Slider.Title.Text=SliderInfo.Name
									Tween(Slider,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
									Tween(Slider.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
								end
								if not SliderInfo.Ext and SliderInfo.Flag then
									SaveConfiguration()
								end
							end
						else
							Tween(Slider.Main.Progress,TweenInfo.new(0.3,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Size=UDim2.new(0,Location-Slider.Main.AbsolutePosition.X>5 and Location-Slider.Main.AbsolutePosition.X or 5,1,0)})
							Loop:Disconnect()
						end
					end)
				end)
				function SliderInfo:Set(NewValue)
					NewValue=math.clamp(NewValue,SliderInfo.Range[1],SliderInfo.Range[2])
					Tween(Slider.Main.Progress,TweenInfo.new(0.45,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Size=UDim2.new(0,Slider.Main.AbsoluteSize.X * ((NewValue-SliderInfo.Range[1]) / (SliderInfo.Range[2]-SliderInfo.Range[1]))>5 and Slider.Main.AbsoluteSize.X * ((NewValue-SliderInfo.Range[1]) / (SliderInfo.Range[2]-SliderInfo.Range[1])) or 5,1,0)})
					Slider.Main.Information.Text=tostring(NewValue) .. " " .. (SliderInfo.Suffix or "")
					local Success,Response=pcall(SliderInfo.Callback,NewValue)
					if not Success then
						Tween(Slider,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
						Tween(Slider.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
						Slider.Title.Text="Callback Error"
						print("Rayfield | "..SliderInfo.Name.." Callback Error " ..tostring(Response))
						warn("Check docs.sirius.menu for help with Rayfield specific development.")
						FastWait(0.5)
						Slider.Title.Text=SliderInfo.Name
						Tween(Slider,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
						Tween(Slider.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
					end
					SliderInfo.Value=NewValue
					if not SliderInfo.Ext and SliderInfo.Flag then
						SaveConfiguration()
					end
				end
				function SliderInfo:Refresh()
					warn("Slider Set version 1 is coming soon!")
				end
				if savingInfo and savingInfo.Enabled and SliderInfo.Flag then
					Library.Flags[SliderInfo.Flag]=SliderInfo
				end
				Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(ApplyTheme)
			end
			if SliderInfo.Tooltip then Tooltip(SliderInfo.Tooltip,Slider) end
			local SliderProxy=setmetatable({},{
				__index=function(_,key)
					local SliderReturns={
						["Visible"]=Slider.Visible,
						["LayoutOrder"]=Slider.LayoutOrder,
						["Title"]=Slider.Title.Text,
					}
					return SliderReturns[key] or SliderInfo[key]
				end,
				__newindex=function(_,key,value)
					if key=="Visible" then
						Slider.Visible=value
					elseif key=="LayoutOrder" then
						Slider.LayoutOrder=value
					elseif key=="Title" then
						Slider.Title.Text=value
					elseif key~="Type" and key~="Set" and key=="Refresh" then
						SliderInfo[key]=value
					end
				end,
			})
			return SliderProxy
		end
		-- Select
		function Tab:CreateSelect(SelectInfo)
			SelectInfo=type(SelectInfo)=="table" and SelectInfo or {}
			local DefaultInfo={Type="Select",Name="Select Here",Active=false,Value="None",Callback=function() end,Set=function() end}
			for key,value in pairs(DefaultInfo) do if SelectInfo[key]==nil then SelectInfo[key]=value end end
			if not Elements:FindFirstChild("Template") or not Elements.Template:FindFirstChild("Select") then warn("Rayfield | Select not found.") return SelectInfo end
			local TurnSysmbols={[true]="■",[false]="□"}
			local Select=Elements.Template.Select:Clone()
			local DisplayFrame=Select:FindFirstChild("DisplayFrame")
			SelectInfo.Template=Select
			Tab.Order+=1
			Select.LayoutOrder=Tab.Order
			Select.Name=SelectInfo.Name or SelectInfo.Title
			Select.Title.Text=SelectInfo.Title or SelectInfo.Name
			Select.Visible=true
			Select.Interact.Text=TurnSysmbols[SelectInfo.Active]
			Select.Information.Text=SelectInfo.Value
			Select.Parent=TabPage
			local SelectConnection=nil
			function SelectInfo:Set(value)
				if SelectInfo.Value~=value then
					SelectInfo.Value=value
					local name=value and value.Name
					if type(value)=="table" then
						Select.Display.BackgroundColor3=value.Color or Color3.fromRGB(200,200,200)
					elseif typeof(value)=="Instance" and value:IsA("BasePart") then
						Select.Display.BackgroundColor3=value.Color
					end
					if name then
						Select.Information.Text=name
					end
					local Success,Response=pcall(SelectInfo.Callback,value)
					if not Success then
						Tween(Select,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
						Tween(Select.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
						Select.Title.Text="Callback Error"
						print("Rayfield | "..SelectInfo.Name.." Callback Error " ..tostring(Response))
						warn("Check docs.sirius.menu for help with Rayfield specific development.")
						FastWait(0.5)
						Select.Title.Text=SelectInfo.Name
						Tween(Select,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
						Tween(Select.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
					end
				end
			end
			if SelectInfo.Tooltip then Tooltip(SelectInfo.Tooltip,Select) end
			Select.Interact.Activated:Connect(function()
				if SelectConnection then SelectConnection:Disconnect() SelectConnection=nil end
				local active=not SelectInfo.Active
				SelectInfo.Active=active
				Select.Interact.Text=TurnSysmbols[active]
				if active then
					local mouse=Players.LocalPlayer:GetMouse()
					SelectConnection=mouse.Button1Down:Connect(function()
						if SelectInfo.Active then
							local target=mouse.Target
							if not (target and target.Parent) then return end
							SelectInfo:Set(target)
						end
					end)
				end
			end)
			Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Select.Title.TextColor3=SelectedTheme.TextColor
				Select.Interact.TextColor3=SelectedTheme.TextColor
				Select.Information.TextColor3=SelectedTheme.TextColor
			end)
			local SelectProxy=setmetatable({},{
				__index=function(_,key)
					local SelectReturns={
						["Visible"]=Select.Visible,
						["LayoutOrder"]=Select.LayoutOrder,
						["Title"]=Select.Title.Text,
					}
					return SelectReturns[key] or SelectInfo[key]
				end,
				__newindex=function(_,key,value)
					if key=="Visible" then
						Select.Visible=value
					elseif key=="LayoutOrder" then
						Select.LayoutOrder=value
					elseif key=="Title" then
						Select.Title.Text=value
					elseif key~="Type" and key~="Set" then
						SelectInfo[key]=value
					end
				end,
			})
			return SelectProxy
		end
		-- Addon
		-- PlayerPicker
		local FirstPlayerPicker=false
		function Tab:CreatePlayerPicker(PlayerPickerInfo) -- by HowToRoblox
			PlayerPickerInfo=type(PlayerPickerInfo)=="table" and PlayerPickerInfo or {}
			local DefaultInfo={Type="PlayerPicker",Name="Player Picker Here",Observe=function() return function() end end,Value="None",Callback=function() end,Set=function() end,View=function() end,Unview=function() end}
			for key,value in pairs(DefaultInfo) do if PlayerPickerInfo[key]==nil then PlayerPickerInfo[key]=value end end
			if not Elements:FindFirstChild("Template") or not Elements.Template:FindFirstChild("PlayerPicker") then warn("Rayfield | PlayerPicker not found.")  return PlayerPickerInfo end
			local PlayerPicker=nil
			local success,message=pcall(function()
				if FirstPlayerPicker then warn("Rayfield | You can only have one PlayerPicker in a single tab") return end
				FirstPlayerPicker=true
				if not UserService then UserService=Services.UserService end
				local PlayerCache={}
				local PlayerPicker=Elements.Template.PlayerPicker:Clone()
				PlayerPickerInfo.Template=PlayerPicker
				Tab.Order+=1
				PlayerPicker.LayoutOrder=Tab.Order
				local PlayerInfo=PlayerPicker.Info
				local PlayerLabel=PlayerInfo.List.Label
				local PlayerTemplate=PlayerPicker.List.Template
				local PlayerViews=PlayerPicker.Views
				PlayerLabel.Visible=false
				PlayerTemplate.Visible=false
				local PlayerTitles={}
				local ThisPlayer=Players.LocalPlayer
				local PlayerInstance=nil
				local PlayerInfoConfig={["Name"]="Roblox",["Display"]="Roblox",["Age"]="0",["ID"]="1"}
				local SelectPlayerIndex,SelectPlayerInfo,SelectedPlayerTemplate,ViewEnabled,ViewInstance,ViewCharAddedConnection=1,nil,nil,false,nil,nil
				for i,v in pairs({{"Name","@Roblox","NameLabel"},{"Display","Roblox","DisplayLabel"},{"ID","1","IdLabel"},{"Age","Inf","AgeLabel"},{"In Game","No","InGameLabel"}}) do
					local variable=v[1]
					local newLabel=PlayerLabel:Clone()
					newLabel.Name=v[3]
					newLabel.LayoutOrder=i
					newLabel.Visible=true
					newLabel.Text=v[1]..": "..v[2]
					table.insert(PlayerTitles,newLabel)
					if PlayerInfoConfig[variable] then
						newLabel.Activated:Connect(function()
							local value=PlayerInfoConfig[variable]
							if value then
								if PlayerPickerInfo.InfoCallback then
									pcall(PlayerPickerInfo.InfoCallback,value,variable)
								end
							end
						end)
					end
					newLabel.Parent=PlayerInfo.List
				end
				PlayerPicker.Parent=TabPage
				local function GetPlayer(object,func)
					if type(object)=="nil" then return nil end
					local result,objectType=nil,typeof(object)
					if objectType=="Instance" then
						if object and object.Parent then
							if object.ClassName=="Model" then 
								for i,v in ipairs(Players:GetPlayers()) do if v and v.Parent and (v.Character and v.Character.Parent) and v.Character==object then result=v break end end
							elseif object.ClassName=="Player" then
								result=object 
							end
						end
					elseif objectType=="string" or objectType=="number" then
						local inputNumber=tonumber(object)
						if inputNumber then
							for i,v in ipairs(Players:GetPlayers()) do if v and v.Parent and v.UserId==inputNumber then result=v break end end
						else
							local s=tostring(object) or ""
							local ls=string.lower(s)
							if ls=="!me" then
								if ThisPlayer and ThisPlayer.Parent then result=ThisPlayer end
							elseif ls=="!random" then
								local matches={}
								for i,v in ipairs(Players:GetPlayers()) do if v.Parent and ThisPlayer.Parent and v.UserId~=ThisPlayer.UserId then table.insert(matches,v) end end
								if #matches>=2 then result=matches[math.random(1,#matches)] end
							else
								for i=1,4 do
									for j,v in ipairs(Players:GetPlayers()) do
										if v and v.Parent then
											local name=if i==1 then v.Name elseif i==2 then v.DisplayName elseif i==3 then string.lower(v.Name) else string.lower(v.DisplayName)
											if string.find(name,s) then result=v break end
										end
									end
									if typeof(result)=="Instance" then break end
								end
							end
						end
					end
					if type(func)=="function" and typeof(result)=="Instance" then func(result) end
					return result
				end
				local function View(player)
					ViewEnabled=true
					PlayerViews.Button.Text="Unview"
					ViewInstance=player
					workspace.CurrentCamera.CameraSubject=player.Character
					if ViewCharAddedConnection then ViewCharAddedConnection:Disconnect() end
					ViewCharAddedConnection=player.CharacterAdded:Connect(function(newChar) workspace.CurrentCamera.CameraSubject=newChar end)
				end
				local function Unview()
					ViewEnabled=false
					PlayerViews.Button.Text="View"
					ViewInstance=nil
					if ViewCharAddedConnection then ViewCharAddedConnection:Disconnect() ViewCharAddedConnection=nil end
					pcall(function()
						ContextActionService:UnbindAction("FreecamKeyboard")
						ContextActionService:UnbindAction("FreecamMousePan")
						RunService:UnbindFromRenderStep("Freecam")
					end)
					workspace.CurrentCamera.CameraSubject=ThisPlayer.Character or ThisPlayer.CharacterAdded:Wait()
				end
				local function GetUserInfo(userId)
					local results={}
					results.UserId=userId
					local player=Players:GetPlayerByUserId(userId)
					results.Player=player
					results.Value=player
					results.InServer=player and true or false
					results.Icon=`rbxthumb://type=AvatarHeadShot&id={userId}&w=420&h=420`
					if player then
						results.Name=player.Name
						results.DisplayName=player.DisplayName
						results.Age=player.AccountAge
					else
						local success,userInfo=pcall(function()
							return UserService and UserService:GetUserInfosByUserIdsAsync({userId})[1]
						end)
						if success and userInfo then
							results.Name=userInfo.Username or 'nil'
							results.DisplayName=userInfo.DisplayName or 'nil'
							results.Age=0
						end
					end
					return results
				end
				local function SetPlayerFrameColor(template)
					if SelectedPlayerTemplate and SelectedPlayerTemplate.Parent then
						SelectedPlayerTemplate.BackgroundColor3=Color3.fromRGB(163,162,165)
						SelectedPlayerTemplate.BackgroundTransparency=1
						SelectedPlayerTemplate=nil
					end
					if template and template.Parent then
						SelectedPlayerTemplate=template
						template.BackgroundColor3=SelectedTheme.PlayerPickerSelected
						template.BackgroundTransparency=0
					end
				end
				local function SetPlayerFrame(userIdOrName)
					local userIdOrNameType=type(userIdOrName)
					if not (userIdOrNameType=='number' or userIdOrNameType=='string') then return end
					local success,userId=false,1
					if not tonumber(userIdOrName) then
						success,userId=pcall(function() return Players:GetUserIdFromNameAsync(userIdOrName) end)
						if not (success and tonumber(userId)) then return end
						userId=tonumber(userId)
					else
						userId=tonumber(userIdOrName)
					end
					local userInfo=GetUserInfo(userId)
					local newContext={
						Name=userInfo.Name or "Roblox",
						DisplayName=userInfo.DisplayName or "Roblox",
						UserId=userId,
						Icon=userInfo.Icon,
						Age=userInfo.Age or 0,
						InServer=userInfo.InServer
					}
					if userInfo.Value~=nil and PlayerInstance~=userInfo.Value  then 
						PlayerInstance=userInfo.Value 
						PlayerPickerInfo.Value=PlayerInstance 
						newContext.IsViewing=ViewInstance~=nil and ViewInstance==PlayerInstance
						CallSafely(PlayerPickerInfo.Callback,PlayerInstance,newContext)
					end
					pcall(function()
						PlayerInfoConfig["Name"]=newContext.Name
						PlayerInfoConfig["Display"]=newContext.DisplayName
						PlayerInfoConfig["Age"]=tostring(newContext.Age)
						PlayerInfoConfig["ID"]=tostring(userId)
						local playerInfoFrame=PlayerInfo.List
						playerInfoFrame.Visible=false
						playerInfoFrame.NameLabel.Text="Name: @"..newContext.Name
						playerInfoFrame.DisplayLabel.Text="Display: "..newContext.DisplayName
						playerInfoFrame.IdLabel.Text="ID: "..tostring(userId)
						playerInfoFrame.AgeLabel.Text="Age: "..tostring(newContext.Age)
						playerInfoFrame.InGameLabel.Text="In Game: "..(userInfo.InServer and 'Yes' or 'No')
						PlayerInfo.Icon.Image=newContext.Icon
						PlayerPickerInfo.Context=newContext
						playerInfoFrame.Visible=true
					end)
				end
				local function ApplyPlayerFrame()
					if not next(SelectPlayerInfo) then return end
					local player,userId,template=SelectPlayerInfo.Value,SelectPlayerInfo.UserId,SelectPlayerInfo.Template
					PlayerInstance=player
					if ViewEnabled then View(player) end
					if template then SetPlayerFrameColor(template) end
					SetPlayerFrame(userId)
				end
				local function ObservePlayer(callback)
					local playerAddedConnection
					local playerRemovedConnection
					local playerCache={}

					local function OnPlayerAdded(player)
						task.defer(function()
							if playerAddedConnection.Connected and player and player.Parent then
								local cleanup=callback(player)
								if type(cleanup)~="function" then return end
								if playerAddedConnection.Connected and player and player.Parent then
									playerCache[player]=cleanup
								else
									task.spawn(cleanup)
								end
							end
						end)
					end

					local function OnPlayerRemoving(player)
						local cleanup=playerCache[player]
						playerCache[player]=nil
						if type(cleanup)~="function" then return end
						task.spawn(cleanup)
					end

					-- Listen for changes:
					playerAddedConnection=Players.PlayerAdded:Connect(OnPlayerAdded)
					playerRemovedConnection=Players.PlayerRemoving:Connect(OnPlayerRemoving)

					-- Initial:
					task.defer(function()
						if not playerAddedConnection.Connected then return end
						local plrs=Players:GetPlayers()
						for i,player in ipairs(plrs) do
							OnPlayerAdded(player)
						end
					end)

					-- Cleanup:
					return function()
						playerAddedConnection:Disconnect()
						playerRemovedConnection:Disconnect()
						local player=next(playerCache)
						while player do
							OnPlayerRemoving(player::Player)
							player=next(playerCache)
						end
					end
				end
				local function AddPlayerFrame(player,index)
					local userId,userName=player.UserId,player.Name
					local data=PlayerCache[index]
					local template=PlayerTemplate:Clone()
					template.Name=player.Name
					template.Title.Text=player.DisplayName
					template.Icon.Image=`rbxthumb://type=AvatarHeadShot&id={userId}&w=420&h=420`
					template.MouseButton1Click:Connect(function()
						SelectPlayerIndex,SelectPlayerInfo=index,{['Value']=player,['Name']=userName,['UserId']=userId,['Template']=template}
						ApplyPlayerFrame()
					end)
					template.Visible=true
					template.Parent=PlayerPicker.List
					data.Template=template
					PlayerCache[index]=data
					if userId==ThisPlayer.UserId then
						SelectPlayerIndex,SelectPlayerInfo=index,data
						ApplyPlayerFrame()
					end
					return function()
						template:Destroy()
						PlayerCache[index]=nil
					end
				end
				local function NextValue(t,i)
					if i>=#t then i=1 else i=i+1 end if not t[i] then i=i+1 end if not t[i] then i=1 end return i,t[i]
				end
				local function PreviousValue(t,i)
					if i==0 or i==1 then i=#t else i=i-1 end if not t[i] then i=i-1 end if not t[i] then i=#t end return i,t[i]
				end
				local function NextSelectPlayer()
					SelectPlayerIndex,SelectPlayerInfo=NextValue(PlayerCache,SelectPlayerIndex)
					ApplyPlayerFrame()
				end
				local function PreviousSelectPlayer()
					SelectPlayerIndex,SelectPlayerInfo=PreviousValue(PlayerCache,SelectPlayerIndex)
					ApplyPlayerFrame()
				end
				local function ApplyTheme()
					local AllBackground=SelectedTheme.InputBackground
					if SelectedPlayerTemplate and SelectedPlayerTemplate.Parent then
						SelectedPlayerTemplate.BackgroundColor3=SelectedTheme.PlayerPickerSelected
					end
					PlayerViews.BackgroundColor3=AllBackground
					PlayerInfo.BackgroundColor3=AllBackground
					PlayerPicker.List.BackgroundColor3=AllBackground
					PlayerPicker.TextBox.BackgroundColor3=AllBackground
					PlayerPicker.TextBox.PlaceholderColor3=SelectedTheme.PlaceholderColor
					for i,v in ipairs(PlayerViews:GetChildren()) do
						if v:IsA("TextButton") then
							v.TextColor3=SelectedTheme.TextColor
						end
					end
					for i,v in ipairs(PlayerTitles) do
						if v and v.Parent then v.TextColor3=SelectedTheme.TextColor end
					end
				end
				ApplyTheme()
				function PlayerPickerInfo:Set(Object)
					if not Object then return end
					local value=nil
					if typeof(Object)=="Instance" and Object.ClassName=="Player" then value=Object.UserId elseif type(Object)=="number" or type(Object)=="string" then value=Object else return end
					SetPlayerFrame(value)
					if ViewEnabled then 
						local player=GetPlayer(value) 
						if player then View(player) end 
					end
				end
				function PlayerPickerInfo:Unview() Unview() end
				function PlayerPickerInfo:View(Player) View(Player) end
				PlayerPicker.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
					local inputText=string.lower(PlayerPicker.TextBox.Text)
					local inputNumber=tonumber(inputText)
					for k,v in pairs(PlayerCache) do 
						local template=v.Template
						if template and template.Parent then 
							local visible=inputText==""
							if inputNumber then
								visible=string.find(tostring(v.UserId),inputText,1,true) and true or false 
							else
								for j,text in ipairs({v.Name,string.lower(v.Name),v.DisplayName,string.lower(v.DisplayName)}) do
									visible=string.find(text,inputText,1,true) and true or false 
									if visible then break end
								end
							end
							if template and template.Parent then
								v.Template.Visible=visible 
							end
						end
					end
				end)
				PlayerPicker.TextBox.FocusLost:Connect(function(enterPress)
					if not enterPress then return end
					local inputText=PlayerPicker.TextBox.Text
					SetPlayerFrame(inputText)
					local player=GetPlayer(inputText)
					if not (player and player.Parent) then return end
					local userId,userName,template=player.UserId,player.Name,nil
					for i,v in ipairs(PlayerCache) do if v.Template and v.Template.Parent and v.UserId and v.UserId==userId then template=v.Template SelectPlayerIndex=i break end end
					SelectPlayerInfo={["Value"]=player,["Name"]=userName,["UserId"]=userId,["Template"]=template}
					ApplyPlayerFrame()
				end)
				PlayerViews.Button.MouseButton1Click:Connect(function()
					if not ViewEnabled then View(PlayerInstance) else Unview() end
				end)
				PlayerViews.Next.MouseButton1Click:Connect(NextSelectPlayer)
				PlayerViews.Previous.MouseButton1Click:Connect(PreviousSelectPlayer)
				SetPlayerFrame(ThisPlayer.UserId)
				PlayerPicker:GetPropertyChangedSignal("BackgroundColor3"):Connect(ApplyTheme)
				local cleanObservePlayer=ObservePlayer(function(player)
					FastWait(1)
					if player and player.Parent then
						local index=#PlayerCache+1
						PlayerCache[index]={["Index"]=index,["Value"]=player,["UserId"]=player.UserId,["Name"]=player.Name,["DisplayName"]=player.DisplayName,["Age"]=player.AccountAge}
						local cleanAddPlayer=AddPlayerFrame(player,index)
						local sortThread=task.defer(function()
							table.sort(PlayerCache,function(a,b) if a~=nil and b~=nil and a.Age~=nil and b.Age~=nil then return a.Age<b.Age else return false end end)
							for i,v in ipairs(PlayerCache) do if player and player.Parent then if v and v.Template and v.Template.Parent then v.Template.LayoutOrder=i end else break end end
						end)
						local onPlayerRemoving=CallSafely(PlayerPickerInfo.Observe,player)
						return function()
							local wasCancelled=nil if coroutine.running()~=sortThread then wasCancelled=pcall(function() task.cancel(sortThread) end) end if not wasCancelled then local toClean=sortThread task.defer(function() task.cancel(toClean) end) end
							cleanAddPlayer()
							CallSafely(onPlayerRemoving,player)
						end
					end
				end)
				ConnectDestroying(PlayerPicker,function()
					cleanObservePlayer() table.clear(PlayerCache) table.clear(PlayerTitles) 
				end)
			end)
			if not success then warn("Rayfield | Fatal Error for PlayerPicker,",message) end
			local PlayerPickerProxy=setmetatable({},{
				__index=function(_,key)
					local value=nil
					if PlayerPicker~=nil then
						local PlayerPickerReturns={
							["Visible"]=PlayerPicker.Visible,
							["LayoutOrder"]=PlayerPicker.LayoutOrder
						}
						value=PlayerPickerReturns[key] 
					end
					return value or PlayerPickerInfo[key]
				end,
				__newindex=function(_,key,value)
					if PlayerPicker~=nil then
						local done=true
						if key=="Visible" then
							PlayerPicker.Visible=value
						elseif key=="LayoutOrder" then
							PlayerPicker.LayoutOrder=value
						else
							done=false
						end
						if done then return end
					end
					if key~="Type" and key~="Set" then
						PlayerPickerInfo[key]=value
					end
				end,
			})
			return PlayerPickerProxy
		end
		-- ThemeButton
		local FirstThemePicker=false
		function Tab:CreateThemePicker(ThemePickerInfo) 
			if FirstThemePicker then warn("Rayfield | You can only have one ThemeButton in a single tab") return end
			FirstThemePicker=true
			ThemePickerInfo=type(ThemePickerInfo)=="table" and ThemePickerInfo or {}
			ThemePickerInfo.Type="ThemePicker"
			local list,index={},1
			for k,v in next,Library.Theme do 
				table.insert(list,k) 
			end
			for i,v in ipairs(list) do 
				local newTheme=Library.Theme[v] 
				if newTheme and SelectedTheme==newTheme then 
					index=i 
					break 
				end 
			end
			ThemePickerInfo.Value=list[index]
			local ButtonInfo
			ButtonInfo=Tab:CreateButton({
				Name="Modify Theme: "..list[index],
				Callback=function()
					index=index+1
					if index>#list then index=1 end
					local themeName=list[index]
					local newValue=Library.Theme[themeName or ""]
					Window:ModifyTheme(newValue)
					ButtonInfo:Set(`Change Theme: {themeName}`)
					ThemePickerInfo.Value=themeName
					if not ThemePickerInfo.Ext and ThemePickerInfo.Flag then SaveConfiguration() end
					table.clear(list)
					for k,v in ipairs(Library.Theme) do table.insert(list,v) end
				end,
			})
			function ThemePickerInfo:Set(NewTheme)
				if type(NewTheme)=="string" then
					ThemePickerInfo.Value=NewTheme
					local newIndex=table.find(list,NewTheme)
					if not newIndex then
						newIndex=index
					end
					local newValue=list[newIndex]
					if newValue then
						index=newIndex
						Window:ModifyTheme(newValue)
						ButtonInfo:Set(`Change Theme: {newValue}`)
					end
				end
			end
			if savingInfo and savingInfo.Enabled and ThemePickerInfo.Flag then
				Library.Flags[ThemePickerInfo.Flag]=ThemePickerInfo
			end
			local ThemePickerProxy=setmetatable({},{
				__index=function(_,key)
					local ThemePickerReturns={
						["Visible"]=ButtonInfo.Visible,
						["LayoutOrder"]=ButtonInfo.LayoutOrder,
					}
					return ThemePickerReturns[key] or ThemePickerInfo[key]
				end,
				__newindex=function(_,key,value)
					if key=="Visible" then
						ButtonInfo.Visible=value
					elseif key=="LayoutOrder" then
						ButtonInfo.LayoutOrder=value
					elseif key~="Type" and key~="Set" then
						ThemePickerInfo[key]=value
					end
				end,
			})
			return ThemePickerProxy
		end
		
		local ListOfTab={
			["Label"]=Tab.CreateLabel,
			["Button"]=Tab.CreateButton,
			["ColorPicker"]=Tab.CreateColorPicker,
			["Section"]=Tab.CreateSection,
			["Divider"]=Tab.CreateDivider,
			["Paragraph"]=Tab.CreateParagraph,
			["Input"]=Tab.CreateInput,
			["Dropdown"]=Tab.CreateDropdown,
			["Keybind"]=Tab.CreateKeybind,
			["Toggle"]=Tab.CreateToggle,
			["Slider"]=Tab.CreateSlider,
			["Select"]=Tab.CreateSelect,
			["PlayerPicker"]=Tab.CreatePlayerPicker,
			["ThemePicker"]=Tab.CreateThemePicker,
			["Expand"]=Tab.CreateExpand,
			["Selector"]=Tab.CreateSelector,
		}
		ListOfTab.Bind=ListOfTab.Keybind
		ListOfTab.ThemeButton=ListOfTab.ThemePicker
		
		function Tab:AddContext(ContextInfo)
			ContextInfo=type(ContextInfo)=="table" and ContextInfo or {}
			local MainInfo=nil
			local TypeName=ContextInfo.Type or ""
			local TabFunc=ListOfTab[TypeName]
			local MainInfo={}
			if TabFunc~=nil then
				if TypeName=="Label" then
					MainInfo=TabFunc(Tab,ContextInfo.Name or ContextInfo.Title or ContextInfo.Text,ContextInfo.Icon,ContextInfo.Color,ContextInfo.IgnoreTheme)
				elseif TypeName=="Section" then
					MainInfo=TabFunc(Tab,ContextInfo.Name or ContextInfo.Title or ContextInfo.Text)
				else
					MainInfo=TabFunc(Tab,ContextInfo)
				end
			else
				warn("Rayfield | UI not found by",TypeName)
			end
			return MainInfo
		end

		Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
			TabButton.UIStroke.Color=SelectedTheme.TabStroke

			if Elements.UIPageLayout.CurrentPage==TabPage then
				TabButton.BackgroundColor3=SelectedTheme.TabBackgroundSelected
				TabButton.Image.ImageColor3=SelectedTheme.SelectedTabTextColor
				TabButton.Title.TextColor3=SelectedTheme.SelectedTabTextColor
			else
				TabButton.BackgroundColor3=SelectedTheme.TabBackground
				TabButton.Image.ImageColor3=SelectedTheme.TabTextColor
				TabButton.Title.TextColor3=SelectedTheme.TabTextColor
			end
		end)

		return Tab
	end
	Elements.Visible=true
	FastWait(1.1)
	Tween(Main,TweenInfo.new(0.7,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut),{Size=UDim2.new(0,390,0,90)})
	FastWait(0.3)
	Tween(LoadingFrame.Title,TweenInfo.new(0.2,Enum.EasingStyle.Exponential),{TextTransparency=1})
	Tween(LoadingFrame.Subtitle,TweenInfo.new(0.2,Enum.EasingStyle.Exponential),{TextTransparency=1})
	Tween(LoadingFrame.Version,TweenInfo.new(0.2,Enum.EasingStyle.Exponential),{TextTransparency=1})
	FastWait(0.1)
	Tween(Main,TweenInfo.new(0.6,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Size=useMobileSizing and UDim2.new(0,500,0,275) or UDim2.new(0,500,0,475)})
	Tween(Main.Shadow.Image,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{ImageTransparency=0.6})
	Topbar.BackgroundTransparency=1
	Topbar.Divider.Size=UDim2.new(0,0,0,1)
	Topbar.Divider.BackgroundColor3=SelectedTheme.ElementStroke
	Topbar.CornerRepair.BackgroundTransparency=1
	Topbar.Title.TextTransparency=1
	Topbar.Search.ImageTransparency=1
	if Topbar:FindFirstChild("Settings") then
		Topbar.Settings.ImageTransparency=1
	end
	Topbar.ChangeSize.ImageTransparency=1
	Topbar.Hide.ImageTransparency=1
	FastWait(0.5)
	Topbar.Visible=true
	Tween(Topbar,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	Tween(Topbar.CornerRepair,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	FastWait(0.1)
	Tween(Topbar.Divider,TweenInfo.new(1,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,0,0,1)})
	Tween(Topbar.Title,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{TextTransparency=0})
	FastWait(0.05)
	Tween(Topbar.Search,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{ImageTransparency=0.8})
	FastWait(0.05)
	if Topbar:FindFirstChild("Settings") then
		Tween(Topbar.Settings,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{ImageTransparency=0.8})
		FastWait(0.05)
	end
	Tween(Topbar.ChangeSize,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{ImageTransparency=0.8})
	FastWait(0.05)
	Tween(Topbar.Hide,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{ImageTransparency=0.8})
	FastWait(0.3)

	if DragBar then
		Tween(DragBarCosmetic,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundTransparency=0.7})
	end

	function Window:ModifyTheme(NewTheme)
		if debugX then warn("Rayfiled | Modify Theme") end
		local success=pcall(ChangeTheme,NewTheme)
		if not success then
			Library:Notify({Title='Unable to Change Theme',Content='We are unable find a theme on file.',Image=4400704299})
		else
			Library:Notify({Title='Theme Changed',Content='Successfully changed theme to '..(typeof(NewTheme)=='string' and NewTheme or 'Custom Theme')..'.',Image=4483362748})
		end
	end

	local settingsTab=Window:CreateTab("Rayfield Settings",0,true)
	local success,result=pcall(CreateSettings,settingsTab)
	Window.SettingsTab=settingsTab
	
	if not success then warn("Rayfield had an issue creating settings.") end
	-- Report after createSettings so loadSettings() has run and usageAnalytics reflects the user's saved preference
	--if Reporter and GetSetting("System","usageAnalytics") then
	--	local themeName="Default"
	--	local newTheme=WindowInfo.Theme
	--	if newTheme then
	--		if type(newTheme)=="string" then
	--			themeName=newTheme
	--		elseif type(newTheme)=="table" then
	--			themeName="Custom"
	--		end
	--	end

	--	local discordInvite=nil
	--	if discordInfo and discordInfo.Enabled and discordInfo.Invite and discordInfo.Invite~="" then
	--		local raw=tostring(discordInfo.Invite)
	--		-- Normalize: strip URL prefixes to extract just the invite code
	--		discordInvite=(raw:match("discord%.gg/([%w%-]+)") or raw:match("discord%.com/invite/([%w%-]+)") or raw):sub(1,32)
	--	end

	--	local sampleSend=false

	--	-- Random Sampling Test
	--	if not WindowInfo.ScriptID and math.random()>0.4 then
	--		sampleSend=true
	--	end

	--	--if WindowInfo.ScriptID then
	--	--	Reporter:windowCreated({
	--	--		script_name=WindowInfo.Name or "Unknown",
	--	--		script_version=Release,
	--	--		interface_version=InterfaceBuild,
	--	--		theme=themeName,
	--	--		is_mobile=useMobileSizing and true or false,
	--	--		has_key_system=(keyInfo and keyInfo.Enabled) and true or false,
	--	--		discord_invite=discordInvite,
	--	--		config_saving=(savingInfo and savingInfo.Enabled) and true or false,
	--	--		script_id=WindowInfo.ScriptID or sampleSend and 'sid_tzfyxawonjx9' or nil,
	--	--		verification_token=WindowInfo.VerificationToken,
	--	--	})
	--	--end
	--end
	Library.Gui=Rayfield
	return Window
end

function Library:IsVisible()
	return not Hidden
end

function Library:Destroy()
	if not Rayfield then return end
	Main=nil Topbar=nil TabList=nil Elements=nil
	rayfieldDestroyed=true
	if HideHotkeyConnection then
		HideHotkeyConnection:Disconnect()
	end
	for _,connection in Connections do
		connection:Disconnect()
	end
	Rayfield:Destroy()
end

function Library:LoadConfiguration()
	local config
	if debugX then warn("Loading Configuration") end
	if IsStudio then config=[[{"Toggle1adwawd":true,"ColorPicker1awd":{"B":255,"G":255,"R":255},"Slider1dawd":100,"ColorPicfsefker1":{"B":255,"G":255,"R":255},"Slidefefsr1":80,"dawdawd":"","Input1":"hh","Keybind1":"B","Dropdown1":["Ocean"]}]] end
	if CEnabled then
		local notified,data=false,nil
		local success,result=pcall(function()
			if IsStudio and config then
				data=LoadConfiguration(config)
				return
			end
			if isfile then 
				if CallSafely(isfile,ConfigFolder .. "/" .. CFileName .. ConfigExtension) and readfile then
					data=LoadConfiguration(CallSafely(readfile,ConfigFolder .. "/" .. CFileName .. ConfigExtension))
				end
			else
				notified=true
				Library:Notify({Title="Rayfield Configurations",Content="We couldn't enable Configuration Saving as you are not using software with filesystem support.",Image=4384402990})
			end
		end)
		if success and data and not notified then
			Library:Notify({Title="Rayfield Configurations",Content="The configuration file for this script has been loaded from a previous session.",Image=4384403532})
		elseif not success and not notified then
			warn("Rayfield Configurations Error | "..tostring(result))
			Library:Notify({Title="Rayfield Configurations",Content="We've encountered an issue loading your configuration correctly.\n\nCheck the Developer Console for more information.",Image=4384402990})
		end
	end
	GlobalLoaded=true
end

if CEnabled and Main and Main:FindFirstChild("Notice") then
	Main.Notice.BackgroundTransparency=1
	Main.Notice.Title.TextTransparency=1
	Main.Notice.Size=UDim2.new(0,0,0,0)
	Main.Notice.Position=UDim2.new(0.5,0,0,-100)
	Main.Notice.Visible=true
	Tween(Main.Notice,TweenInfo.new(0.5,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut),{Size=UDim2.new(0,280,0,35),Position=UDim2.new(0.5,0,0,-50),BackgroundTransparency=0.5})
	Tween(Main.Notice.Title,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=0.1})
end

task.delay(5,function()
	Library:LoadConfiguration()
	while not Main do FastWait(0.5) end
	Main.Notice.BackgroundTransparency=1
	Main.Notice.Title.TextTransparency=1
	Main.Notice.Size=UDim2.new(0,0,0,0)
	Main.Notice.Position=UDim2.new(0.5,0,0,-100)
	Main.Notice.Visible=true
	Tween(Main.Notice,TweenInfo.new(0.5,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut),{Size=UDim2.new(0,280,0,35),Position=UDim2.new(0.5,0,0,-50),BackgroundTransparency=0.5})
	Tween(Main.Notice.Title,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=0.1})
	if Main:FindFirstChild("Notice") and Main.Notice.Visible then
		Tween(Main.Notice,TweenInfo.new(0.5,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut),{Size=UDim2.new(0,100,0,25),Position=UDim2.new(0.5,0,0,-100),BackgroundTransparency=1})
		Tween(Main.Notice.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=1})
		FastWait(0.5)
		Main.Notice.Visible=false
	end
end)

return Library
