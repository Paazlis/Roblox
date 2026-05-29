--[[

	Rayfield Interface Suite
	by Sirius

	shlex  | Designing + Programming
	iRay   | Programming
	Max    | Programming
	Damian | Programming

]]

local debugX=false

if debugX then
	warn('Initialising Rayfield')
end

local function getService(name)
	local service=game:GetService(name)
	return if cloneref then cloneref(service) else service
end

-- Services
local Services={}
for i,v in ipairs({"Players","UserInputService","TweenService","HttpService","RunService","UserService","ContextActionService"}) do if Services[v]==nil then Services[v]=getService(v) end end
local Players,UserInputService,TweenService,HttpService,RunService,UserService,ContextActionService=Services["Players"],Services["UserInputService"],Services["TweenService"],Services["HttpService"],Services["RunService"],Services["UserService"],Services["ContextActionService"]

-- Loads and executes a function hosted on a remote URL. Cancels the request if the requested URL takes too long to respond.
-- Errors with the function are caught and logged to the output
local function loadWithTimeout(url,timeout)
	assert(type(url)=="string","Expected string,got " .. type(url))
	timeout=timeout or 5
	local requestCompleted=false
	local success,result=false,nil

	local requestThread=task.spawn(function()
		local fetchSuccess,fetchResult=pcall(game.HttpGet,game,url) -- game:HttpGet(url)
		-- If the request fails the content can be empty,even if fetchSuccess is true
		if not fetchSuccess or #fetchResult==0 then
			if #fetchResult==0 then
				fetchResult="Empty response" -- Set the error message
			end
			success,result=false,fetchResult
			requestCompleted=true
			return
		end
		local content=fetchResult -- Fetched content
		local execSuccess,execResult=pcall(function()
			return loadstring(content)()
		end)
		success,result=execSuccess,execResult
		requestCompleted=true
	end)

	local timeoutThread=task.delay(timeout,function()
		if not requestCompleted then
			warn("Request for " .. url .. " timed out after " .. tostring(timeout) .. " seconds")
			task.cancel(requestThread)
			result="Request timed out"
			requestCompleted=true
		end
	end)

	-- Wait for completion or timeout
	while not requestCompleted do
		task.wait()
	end
	-- Cancel timeout thread if still running when request completes
	if coroutine.status(timeoutThread)~="dead" then
		task.cancel(timeoutThread)
	end
	if not success then
		warn("Failed to process " .. tostring(url) .. ": " .. tostring(result))
	end
	return if success then result else nil
end

local _getgenv,requestsDisabled,secureMode,customAssetId=rawget(_G,"getgenv"),false,false,nil

if _getgenv then
	local ok,result=pcall(function() return _getgenv().DISABLE_RAYFIELD_REQUESTS end)
	if ok and result then requestsDisabled=true end
	local ok2,result2=pcall(function() return _getgenv().RAYFIELD_ASSET_ID end)
	if ok2 and type(result2)=="number" then customAssetId=result2 end
	local ok3,result3=pcall(function() return _getgenv().RAYFIELD_SECURE end)
	if ok3 and result3 then secureMode=true end
end

if secureMode then
	local _error=error
	local _assert=assert
	warn=function(...) end
	print=function(...) end
	error=function(_,level) _error("",level) end
	assert=function(v,...) return _assert(v) end
end

local Library={
	Flags={},
	Theme={
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
	},
}

local secureWarnings,customAssets={},{}

local function secureNotify(wType,title,content)
	if secureWarnings[wType] then return end
	secureWarnings[wType]=true
	task.spawn(function()
		while not Library or not Library.Notify do task.wait(1) end
		Library:Notify({Title=title,Content=content,Duration=8})
	end)
end

local InterfaceBuild,Release,RayfieldFolder,ConfigurationExtension="UU2NX","Build 1.746","Rayfield",".rfld"
local ConfigurationFolder=RayfieldFolder.."/Configurations"
local settingsData={
	General={
		-- if needs be in order just make getSetting(name)
		rayfieldOpen={Type='bind',Value='K',Name='Rayfield Keybind'},
	},
	System={
		usageAnalytics={Type='toggle',Value=true,Name='Anonymised Analytics'},
	}
}

-- Settings that have been overridden by the developer. These will not be saved to the user's configuration file
-- Overridden settings always take precedence over settings in the configuration file,and are cleared if the user changes the setting in the UI
local overriddenSettings={} -- For example,overriddenSettings["System.rayfieldOpen"]="J"

local function overrideSetting(category,name,value)
	overriddenSettings[category .. "." .. name]=value
end

local function getSetting(category,name)
	if overriddenSettings[category.."."..name]~=nil then
		return overriddenSettings[category.."."..name]
	elseif settingsData[category][name]~=nil then
		return settingsData[category][name].Value
	end
end

-- If requests/analytics have been disabled by developer, set the user-facing setting to false as well
if requestsDisabled then
	overrideSetting("System","usageAnalytics",false)
end

-- Environment Check
local useStudio=RunService:IsStudio() or false
local settingsCreated=false
local settingsInitialized=false -- Whether the UI elements in the settings page have been set to the proper values
local prompt=useStudio and require(script.Parent.prompt) or loadWithTimeout('https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/refs/heads/request/prompt.lua')

-- Validate prompt loaded correctly
if not prompt and not useStudio then
	warn("Failed to load prompt library, using fallback")
	prompt={create=function() end}
end

local function requestSafely(options)
	local func=(syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request
	if func then 
		local success,result=pcall(func,options)
		if success then return result end return nil,result
	end
	return nil
end

-- The function below provides a safe alternative for calling error-prone functions
-- Especially useful for filesystem function (writefile,makefolder,etc.)
local function callSafely(func,...)
	if func then local success,result=pcall(func,...) if not success then warn("Rayfield | Function failed with error: ",result) return false else return result end end
end

-- Ensures a folder exists by creating it if needed
local function ensureFolder(folderPath)
	if isfolder and not callSafely(isfolder,folderPath) then callSafely(makefolder,folderPath) end
end

local function loadSettings()
	local file=nil

	local success,result=pcall(function()
		if isfolder and callSafely(isfolder,RayfieldFolder) then if isfile and readfile and callSafely(isfile,RayfieldFolder..'/settings'..ConfigurationExtension) then file=callSafely(readfile,RayfieldFolder..'/settings'..ConfigurationExtension) end end

		-- for debug in studio
		if useStudio then file=[[{"General":{"rayfieldOpen":{"Value":"K","Type":"bind","Name":"Rayfield Keybind","Element":{"HoldToInteract":false,"Ext":true,"Name":"Rayfield Keybind","Set":null,"CallOnChange":true,"Callback":null,"Keybind":"K"}}},"System":{"usageAnalytics":{"Value":false,"Type":"toggle","Name":"Anonymised Analytics","Element":{"Ext":true,"Name":"Anonymised Analytics","Set":null,"CurrentValue":false,"Callback":null}}}}]] end

		if file then local decodeSuccess,decodedFile=pcall(function() return HttpService:JSONDecode(file) end) if decodeSuccess then file=decodedFile else file={} end else file={} end

		if not settingsCreated then return end

		if next(file)~=nil then
			for categoryName,settingCategory in pairs(settingsData) do
				if file[categoryName] then
					for settingName,setting in pairs(settingCategory) do
						if file[categoryName][settingName] then
							setting.Value=file[categoryName][settingName].Value
							setting.Element:Set(getSetting(categoryName,settingName))
						end
					end
				end
			end
		else -- If no settings saved,apply overridden settings only
			for settingName,settingValue in overriddenSettings do
				local split=string.split(settingName,".")
				assert(#split==2,"Rayfield | Invalid overridden setting name: " .. settingName)
				local categoryName=split[1]
				local settingNameOnly=split[2]
				if settingsData[categoryName] and settingsData[categoryName][settingNameOnly] then
					settingsData[categoryName][settingNameOnly].Element:Set(settingValue)
				end
			end
		end
		settingsInitialized=true
	end)

	if not success then  
		if writefile then warn("Rayfield had an issue accessing configuration saving capability.") end 
	else
		if debugX then warn("Settings Loaded") end
	end
end

if debugX then warn("Now Loading Settings Configuration") end

loadSettings()

--local ANALYTICS_TOKEN="05de7f9fd320d3b8428cd1c77014a337b85b6c8efee2c5914f5ab5700c354b9a"

local reporter=nil
--if not requestsDisabled and not useStudio then
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

if debugX then warn("Moving on to continue initialisation") end


-- Interface Management
local RayfieldAssetId=customAssetId or 134923138597588 --10804731440
local Rayfield=useStudio and script.Parent:FindFirstChild('Rayfield') or game:GetObjects("rbxassetid://"..RayfieldAssetId)[1]
local buildAttempts=0
local correctBuild=false
local warned
local globalLoaded
local rayfieldDestroyed=false -- True when Library:Destroy() is called
Rayfield.Main.Visible=false
repeat
	if Rayfield:FindFirstChild("Build") and Rayfield.Build.Value==InterfaceBuild then
		correctBuild=true
		break
	end

	correctBuild=false

	if not warned then
		warn('Rayfield | Build Mismatch')
		print('Rayfield may encounter issues as you are running an incompatible interface version ('.. ((Rayfield:FindFirstChild("Build") and Rayfield.Build.Value) or "No Build") ..').\n\nThis version of Rayfield is intended for interface build '..InterfaceBuild..'.')
		warned=true
	end

	local toDestroy
	toDestroy,Rayfield=Rayfield,useStudio and script.Parent:FindFirstChild('Rayfield') or game:GetObjects("rbxassetid://"..RayfieldAssetId)[1]
	if toDestroy and not useStudio then toDestroy:Destroy() end

	buildAttempts=buildAttempts+1
until buildAttempts >= 2

Rayfield.Enabled=false

local baseSize=Vector2.new(1024,768)

local Main=Rayfield.Main
local Elements=Main.Elements

local CoreGui=not useStudio and getService("CoreGui")
if gethui then
	Rayfield.Parent=gethui()
elseif syn and syn.protect_gui then 
	syn.protect_gui(Rayfield)
	Rayfield.Parent=CoreGui
elseif not useStudio and CoreGui:FindFirstChild("RobloxGui") then
	Rayfield.Parent=CoreGui:FindFirstChild("RobloxGui")
elseif not useStudio then
	Rayfield.Parent=CoreGui
else
	Rayfield.Parent=Players.LocalPlayer:WaitForChild("PlayerGui")
end

if gethui then
	for _,Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name==Rayfield.Name and Interface~=Rayfield then
			Interface.Enabled=false
			Interface.Name="Rayfield-Old"
		end
	end
elseif not useStudio then
	for _,Interface in ipairs(CoreGui:GetChildren()) do
		if Interface.Name==Rayfield.Name and Interface~=Rayfield then
			Interface.Enabled=false
			Interface.Name="Rayfield-Old"
		end
	end
end

local function resizeUIScale(ui,screenSize)
	local scaleX=screenSize.X/baseSize.X
	local scaleY=screenSize.Y/baseSize.Y
	local scale=math.min(scaleX,scaleY)
	local minAxis=math.min(screenSize.X,screenSize.Y)
	local isSmallScreen=minAxis<=500
	local uiScale:UIScale=ui:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
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

resizeUIScale(Rayfield,workspace.CurrentCamera.ViewportSize)
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	resizeUIScale(Rayfield,workspace.CurrentCamera.ViewportSize)
end)

if secureMode and not customAssetId then
	secureNotify("default_asset","Secure Mode","You are using the default Rayfield asset ID. Set RAYFIELD_ASSET_ID to a custom upload to avoid detection.")
end

do
	local AssetPath=RayfieldFolder.."/Assets"
	local AssetBaseURL="https://github.com/SiriusSoftwareLtd/Rayfield/blob/main/assets/"
	local assetFiles={
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
	for id,_ in assetFiles do
		customAssets[id]=""
	end
	local hasCustomAsset=type(getcustomasset)=="function"
	local hasFilesystem=type(writefile)=="function" and type(makefolder)=="function" and type(isfile)=="function" and type(isfolder)=="function"
	if hasCustomAsset and hasFilesystem then
		local ok,err=pcall(function()
			ensureFolder(RayfieldFolder)
			ensureFolder(AssetPath)

			local function nextMissing()
				for id,_ in assetFiles do
					if not isfile(AssetPath.."/"..tostring(id)..".png") then
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
						writefile(AssetPath.."/"..tostring(id)..".png",requestSafely({Url=assetFiles[id],Method="GET"}).Body)
						task.wait()
					end
				end)

				while nextMissing() do
					task.wait(0.1)
				end
			end

			for id,_ in assetFiles do
				local success,asset=pcall(getcustomasset,AssetPath.."/"..tostring(id)..".png")
				if success then
					customAssets[tostring(id)]=asset
				else
					warn("Rayfield | Failed to load custom asset: "..tostring(id).."-"..tostring(asset))
				end
			end
		end)

		if not ok then
			warn("Rayfield | Failed to load custom assets: "..tostring(err))
			secureNotify("asset_load_fail","Rayfield","Failed to load custom assets. UI images may not display correctly.")
		end
	else
		secureNotify("no_getcustomasset","Rayfield","Your executor does not support getcustomasset. Some UI images may not render correctly.")
	end
	Rayfield.Main.Shadow.Image.Image=customAssets["5587865193"]
	Rayfield.Main.Topbar.Hide.Image=customAssets["10137832201"]
	Rayfield.Main.Topbar.ChangeSize.Image=customAssets["10137941941"]
	Rayfield.Main.Topbar.Settings.Image=customAssets["80503127983237"]
	Rayfield.Main.Topbar.Icon.Image=customAssets["78137979054938"]
	Rayfield.Main.Topbar.Search.Image=customAssets["IconMagnifyingGlass2"]
	Rayfield.Main.Topbar.Search.ImageRectOffset=Vector2.new(0,0)
	Rayfield.Main.Topbar.Search.ImageRectSize=Vector2.new(0,0)
	Rayfield.Main.Elements.Template.Toggle.Switch.Shadow.Image=customAssets["3602733521"]
	Rayfield.Main.Elements.Template.Slider.Main.Shadow.Image=customAssets["3602733521"]
	Rayfield.Main.Elements.Template.Dropdown.Toggle.Image=customAssets["IconChevronTopMedium"]
	Rayfield.Main.Elements.Template.Dropdown.Toggle.ImageRectOffset=Vector2.new(0,0)
	Rayfield.Main.Elements.Template.Dropdown.Toggle.ImageRectSize=Vector2.new(0,0)
	Rayfield.Main.Elements.Template.Label.Icon.Image=customAssets["11745872910"]
	Rayfield.Main.Elements.Template.ColorPicker.CPBackground.MainCP.Image=customAssets["11413591840"]
	Rayfield.Main.Elements.Template.ColorPicker.CPBackground.MainCP.MainPoint.Image=customAssets["3259050989"]
	Rayfield.Main.Elements.Template.ColorPicker.ColorSlider.SliderPoint.Image=customAssets["3259050989"]
	Rayfield.Main.TabList.Template.Image.Image=customAssets["4483362458"]
	Rayfield.Main.Search.Search.Image=customAssets["18458939117"]
	Rayfield.Main.Search.Shadow.Image=customAssets["5587865193"]
	Rayfield.Notifications.Template.Icon.Image=customAssets["77891951053543"]
	Rayfield.Notifications.Template.Shadow.Image=customAssets["3523728077"]
	Rayfield.Loading.Banner.Image=customAssets["111263549366178"]
end -- custom asset block

local useMobileSizing
if Rayfield.AbsoluteSize.X<baseSize.X and Rayfield.AbsoluteSize.Y<baseSize.Y then
	useMobileSizing=true
end
local useMobilePrompt=false
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	useMobilePrompt=true
end

-- Object Variables
local MPrompt=Rayfield:FindFirstChild("Prompt")
local Topbar=Main.Topbar
local LoadingFrame=Main.LoadingFrame
local TabList=Main.TabList
local dragBar=Rayfield:FindFirstChild("Drag")
local dragInteract=dragBar and dragBar.Interact or nil
local dragBarCosmetic=dragBar and dragBar.Drag or nil
local dragOffset=255
local dragOffsetMobile=150

Rayfield.DisplayOrder=100
LoadingFrame.Version.Text=Release

-- Thanks to Latte Softworks for the Lucide integration for Roblox
local Icons=useStudio and require(script.Parent.icons) or loadWithTimeout("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua")
local Strs=useStudio and require(game.ReplicatedStorage.Packages.Strs) or loadstring(game:HttpGet("https://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/Strs/init.luau"))()

-- Variables
local CFileName=nil
local CEnabled=false
local Minimised=false
local Hidden=false
local Debounce=false
local searchOpen=false
local Notifications=Rayfield.Notifications
local keybindConnections={} -- For storing keybind connections to disconnect when Rayfield is destroyed

local SelectedTheme=Library.Theme.Default
Library.SelectedTheme=SelectedTheme

local function tween(instance,tweenInfo,properties)
	TweenService:Create(instance,tweenInfo,properties):Play()
end

local function ChangeTheme(theme)
	local themeType=type(theme)
	if themeType=="string" then
		SelectedTheme=Library.Theme[theme]
	elseif themeType=="table" then
		SelectedTheme=theme
	end
	Library.SelectedTheme=SelectedTheme
	Rayfield.Main.BackgroundColor3=SelectedTheme.Background
	Rayfield.Main.Topbar.BackgroundColor3=SelectedTheme.Topbar
	Rayfield.Main.Topbar.CornerRepair.BackgroundColor3=SelectedTheme.Topbar
	Rayfield.Main.Shadow.Image.ImageColor3=SelectedTheme.Shadow
	Rayfield.Main.Topbar.ChangeSize.ImageColor3=SelectedTheme.TextColor
	Rayfield.Main.Topbar.Hide.ImageColor3=SelectedTheme.TextColor
	Rayfield.Main.Topbar.Search.ImageColor3=SelectedTheme.TextColor
	if Topbar:FindFirstChild('Settings') then
		Rayfield.Main.Topbar.Settings.ImageColor3=SelectedTheme.TextColor
		Rayfield.Main.Topbar.Divider.BackgroundColor3=SelectedTheme.ElementStroke
	end
	Main.Search.BackgroundColor3=SelectedTheme.TextColor
	Main.Search.Shadow.ImageColor3=SelectedTheme.TextColor
	Main.Search.Search.ImageColor3=SelectedTheme.TextColor
	Main.Search.Input.PlaceholderColor3=SelectedTheme.TextColor
	Main.Search.UIStroke.Color=SelectedTheme.SecondaryElementStroke

	if Main:FindFirstChild('Notice') then
		Main.Notice.BackgroundColor3=SelectedTheme.Background
	end

	for _,text in ipairs(Rayfield:GetDescendants()) do
		if text.Parent.Parent~=Notifications then
			if text:IsA('TextLabel') or text:IsA('TextBox') then text.TextColor3=SelectedTheme.TextColor end
		end
	end

	for _,TabPage in ipairs(Elements:GetChildren()) do
		for _,Element in ipairs(TabPage:GetChildren()) do
			if Element.ClassName=="Frame" and Element.Name~="Placeholder" and Element.Name~="SectionSpacing" and Element.Name~="Divider" and Element.Name~="SectionTitle" and Element.Name~="SearchTitle-fsefsefesfsefesfesfThanks" then
				Element.BackgroundColor3=SelectedTheme.ElementBackground
				Element.UIStroke.Color=SelectedTheme.ElementStroke
			end
		end
	end
end

local function getIcon(name)
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

	local asset={
		id=r[1],
		imageRectSize=irs,
		imageRectOffset=iro,
	}

	return asset
end

local function getAssetUri(id)
	local idType,assetUri=type(id),""
	if idType=="number" then
		assetUri="rbxassetid://" .. id
	elseif idType=="string" and not Icons then
		warn("Rayfield | Cannot use Lucide icons as icons library is not loaded")
	else
		warn("Rayfield | The icon argument must either be an icon ID (number) or a Lucide icon name (string)")
	end
	return assetUri
end

local function isCustomAsset(value)
	return type(value)=="string" and (string.find(value,"rbxasset://")==1 or string.find(value,"rbxthumb://")==1)
end

local function resolveIcon(icon)
	if not icon or icon==0 then
		return "",nil,nil
	end

	if isCustomAsset(icon) then
		return icon,nil,nil
	end

	if secureMode then
		secureNotify("icon_blocked","Secure Mode","Element icons using asset IDs or Lucide names are blocked. Use getcustomasset() for icons to stay undetected.")
		return "",nil,nil
	end

	if typeof(icon)=="string" and Icons then
		local asset=getIcon(icon)
		return "rbxassetid://" .. asset.id,asset.imageRectOffset,asset.imageRectSize
	else
		return getAssetUri(icon),nil,nil
	end
end

local function makeDraggable(object,dragObject,enableTaptic,tapticOffset)
	local dragging,relative,inputConnection=false,nil,nil
	local offset=Vector2.zero
	local screenGui=object:FindFirstAncestorWhichIsA("ScreenGui")
	if screenGui and screenGui.IgnoreGuiInset then
		offset += getService('GuiService'):GetGuiInset()
	end

	local function connectFunctions()
		if dragBar and enableTaptic then
			dragBar.MouseEnter:Connect(function()
				if not dragging and not Hidden then
					tween(dragBarCosmetic,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0.5,Size=UDim2.new(0,120,0,4)})
				end
			end)

			dragBar.MouseLeave:Connect(function()
				if not dragging and not Hidden then
					tween(dragBarCosmetic,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0.7,Size=UDim2.new(0,100,0,4)})
				end
			end)
		end
	end

	connectFunctions()

	dragObject.InputBegan:Connect(function(input,processed)
		if processed then return end
		local inputType=input.UserInputType.Name
		if inputType=="MouseButton1" or inputType=="Touch" then
			dragging=true
			relative=object.AbsolutePosition+object.AbsoluteSize * object.AnchorPoint-UserInputService:GetMouseLocation()
			if enableTaptic and not Hidden then
				tween(dragBarCosmetic,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,110,0,4),BackgroundTransparency=0})
			end
		end
	end)

	local inputEnded=UserInputService.InputEnded:Connect(function(input)
		if not dragging then return end
		local inputType=input.UserInputType.Name
		if inputType=="MouseButton1" or inputType=="Touch" then
			dragging=false
			--if inputConnection then inputConnection:Disconnect() inputConnection=nil end
			if enableTaptic and not Hidden then
				tween(dragBarCosmetic,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,100,0,4),BackgroundTransparency=0.7})
			end
		end
	end)

	local renderStepped=RunService.RenderStepped:Connect(function()
		if dragging and not Hidden then
			local position=UserInputService:GetMouseLocation()+relative+offset
			if enableTaptic and tapticOffset then
				tween(object,TweenInfo.new(0.4,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Position=UDim2.fromOffset(position.X,position.Y)})
				tween(dragObject.Parent,TweenInfo.new(0.05,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Position=UDim2.fromOffset(position.X,position.Y+((useMobileSizing and tapticOffset[2]) or tapticOffset[1]))})
			else
				if dragBar and tapticOffset then
					dragBar.Position=UDim2.fromOffset(position.X,position.Y+((useMobileSizing and tapticOffset[2]) or tapticOffset[1]))
				end
				object.Position=UDim2.fromOffset(position.X,position.Y)
			end
		end
	end)

	object.Destroying:Connect(function()
		if inputConnection then inputConnection:Disconnect() inputConnection=nil end
		if inputEnded then inputEnded:Disconnect() end
		if renderStepped then renderStepped:Disconnect() end
	end)
end

local function packColor(Color)
	return {R=Color.R * 255,G=Color.G * 255,B=Color.B * 255}
end    

local function unpackColor(Color)
	return Color3.fromRGB(Color.R,Color.G,Color.B)
end

local function LoadConfiguration(Configuration)
	local success,data=pcall(function() return HttpService:JSONDecode(Configuration) end)
	local changed=false
	if not success then warn("Rayfield had an issue decoding the configuration file,please try delete the file and reopen Rayfield.") return end
	-- Iterate through current UI elements' flags
	for flagName,flag in pairs(Library.Flags) do
		local flagValue=data[flagName]
		if (typeof(flagValue)=="boolean" and flagValue==false) or flagValue~=nil then
			task.spawn(function()
				if flag.Type=="ColorPicker" then
					changed=true
					flag:Set(unpackColor(flagValue))
				else
					if (flag.Value or flag.Keybind or flag.Option or flag.Color)~=flagValue then 
						changed=true
						flag:Set(flagValue) 	
					end
				end
			end)
		else
			warn("Rayfield | Unable to find '"..flagName.. "' in the save file.")
			print("The error above may not be an issue if new elements have been added or not been set values.")
		end
	end
	return changed
end

local function SaveConfiguration()
	if not CEnabled or not globalLoaded then return end
	if debugX then print("Saving") end
	local data={}
	for i,v in pairs(Library.Flags) do
		if v.Type=="ColorPicker" then
			data[i]=packColor(v.Color)
		else
			if type(v.Value)=="boolean" then
				if v.Value==false then data[i]=false else data[i]=v.Keybind or v.Option or v.Color or v.Value end
			else
				data[i]=v.Keybind or v.Option or v.Color or v.Value
			end
		end
	end
	local dataStr=HttpService:JSONEncode(data)
	if useStudio then
		if script.Parent:FindFirstChild("Configuration") then script.Parent.Configuration:Destroy() end
		local ScreenGui=Instance.new("ScreenGui")
		ScreenGui.Parent=script.Parent
		ScreenGui.Name="Configuration"
		local TextBox=Instance.new("TextBox")
		TextBox.Parent=ScreenGui
		TextBox.Size=UDim2.new(0,800,0,50)
		TextBox.AnchorPoint=Vector2.new(0.5,0)
		TextBox.Position=UDim2.new(0.5,0,0,30)
		TextBox.Text=dataStr
		TextBox.ClearTextOnFocus=false
	end
	if debugX then warn(dataStr) end
	if writefile then callSafely(writefile,ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension,dataStr) end
end

function Library:Notify(data) -- action e.g open messages
	task.spawn(function()
		-- Notification Object Creation
		local newNotification=Notifications.Template:Clone()
		newNotification.Name=data.Title or 'No Title Provided'
		newNotification.Parent=Notifications
		newNotification.LayoutOrder=#Notifications:GetChildren()
		newNotification.Visible=false
		-- Set Data
		newNotification.Title.Text=data.Title or "Unknown Title"
		newNotification.Description.Text=data.Content or "Unknown Content"
		if data.Image then
			local img,rectOffset,rectSize=resolveIcon(data.Image)
			newNotification.Icon.Image=img
			if rectOffset then newNotification.Icon.ImageRectOffset=rectOffset end
			if rectSize then newNotification.Icon.ImageRectSize=rectSize end
		else
			newNotification.Icon.Image=""
		end
		-- Set initial transparency values
		newNotification.Title.TextColor3=SelectedTheme.TextColor
		newNotification.Description.TextColor3=SelectedTheme.TextColor
		newNotification.BackgroundColor3=SelectedTheme.Background
		newNotification.UIStroke.Color=SelectedTheme.TextColor
		newNotification.Icon.ImageColor3=SelectedTheme.TextColor
		newNotification.BackgroundTransparency=1
		newNotification.Title.TextTransparency=1
		newNotification.Description.TextTransparency=1
		newNotification.UIStroke.Transparency=1
		newNotification.Shadow.ImageTransparency=1
		newNotification.Size=UDim2.new(1,0,0,800)
		newNotification.Icon.ImageTransparency=1
		newNotification.Icon.BackgroundTransparency=1
		newNotification.Visible=true
		if data.Actions then
			warn('Rayfield | Not seeing your actions in notifications?')
			print("Notification Actions are being sunset for now, keep up to date on when they're back in the discord. (sirius.menu/discord)")
		end
		-- Calculate textbounds and set initial values
		local bounds={newNotification.Title.TextBounds.Y,newNotification.Description.TextBounds.Y}
		newNotification.Size=UDim2.new(1,-60,0,-Notifications:FindFirstChild("UIListLayout").Padding.Offset)
		newNotification.Icon.Size=UDim2.new(0,32,0,32)
		newNotification.Icon.Position=UDim2.new(0,20,0.5,0)
		tween(newNotification,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,0,0,math.max(bounds[1]+bounds[2]+31,60))})
		task.wait(0.15)
		tween(newNotification,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{BackgroundTransparency=0.45})
		tween(newNotification.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=0})
		task.wait(0.05)
		tween(newNotification.Icon,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=0})
		task.wait(0.05)
		tween(newNotification.Description,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=0.35})
		tween(newNotification.UIStroke,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{Transparency=0.95})
		tween(newNotification.Shadow,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=0.82})
		local cooldown=math.min(math.max((#newNotification.Description.Text * 0.1)+2.5,3),10)
		task.wait(data.Duration or cooldown)
		newNotification.Icon.Visible=false
		tween(newNotification,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
		tween(newNotification.UIStroke,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{Transparency=1})
		tween(newNotification.Shadow,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=1})
		tween(newNotification.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=1})
		tween(newNotification.Description,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=1})
		tween(newNotification,TweenInfo.new(1,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,-90,0,0)})
		task.wait(1)
		tween(newNotification,TweenInfo.new(1,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,-90,0,-Notifications:FindFirstChild("UIListLayout").Padding.Offset)})
		newNotification.Visible=false
		newNotification:Destroy()
	end)
end

local function openSearch()
	searchOpen=true
	Main.Search.BackgroundTransparency=1
	Main.Search.Shadow.ImageTransparency=1
	Main.Search.Input.TextTransparency=1
	Main.Search.Search.ImageTransparency=1
	Main.Search.UIStroke.Transparency=1
	Main.Search.Size=UDim2.new(1,0,0,80)
	Main.Search.Position=UDim2.new(0.5,0,0,70)
	Main.Search.Input.Interactable=true
	Main.Search.Visible=true
	for i,v in ipairs(TabList:GetChildren()) do
		if v.ClassName=="Frame" and v.Name~="Placeholder" then
			v.Interact.Visible=false
			tween(v,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
			tween(v.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=1})
			tween(v.Image,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=1})
			tween(v.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=1})
		end
	end
	Main.Search.Input:CaptureFocus()
	tween(Main.Search.Shadow,TweenInfo.new(0.05,Enum.EasingStyle.Quint),{ImageTransparency=0.95})
	tween(Main.Search,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Position=UDim2.new(0.5,0,0,57),BackgroundTransparency=0.9})
	tween(Main.Search.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=0.8})
	tween(Main.Search.Input,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=0.2})
	tween(Main.Search.Search,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=0.5})
	tween(Main.Search,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,-35,0,35)})
end

local function closeSearch()
	searchOpen=false
	tween(Main.Search,TweenInfo.new(0.35,Enum.EasingStyle.Quint),{BackgroundTransparency=1,Size=UDim2.new(1,-55,0,30)})
	tween(Main.Search.Search,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{ImageTransparency=1})
	tween(Main.Search.Shadow,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{ImageTransparency=1})
	tween(Main.Search.UIStroke,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{Transparency=1})
	tween(Main.Search.Input,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{TextTransparency=1})
	for _,tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName=="Frame" and tabbtn.Name~="Placeholder" then
			tabbtn.Interact.Visible=true
			if tostring(Elements.UIPageLayout.CurrentPage)==tabbtn.Title.Text then
				tween(tabbtn,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
				tween(tabbtn.Image,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=0})
				tween(tabbtn.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=0})
				tween(tabbtn.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=1})
			else
				tween(tabbtn,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=0.7})
				tween(tabbtn.Image,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=0.2})
				tween(tabbtn.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=0.2})
				tween(tabbtn.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=0.5})
			end
		end
	end
	Main.Search.Input.Text=''
	Main.Search.Input.Interactable=false
end

-- Sets element visibility across all tab pages (used by Hide,Unhide,Maximise,Minimise)
local function setElementsVisible(show)
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
							tween(element.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=show and 0.4 or 1})
						elseif element.Name=="Divider" then
							tween(element.Divider,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=show and 0.85 or 1})
						else
							tween(element,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=show and 0 or 1})
							tween(element.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=show and 0 or 1})
							tween(element.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=show and 0 or 1})
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

-- Sets tab button visibility (used by Hide,Unhide,Maximise,Minimise)
local function setTabButtonsVisible(show)
	for _,tab in ipairs(TabList:GetChildren()) do
		if tab.ClassName=="Frame" and tab.Name~="Placeholder" then
			if show then
				if tostring(Elements.UIPageLayout.CurrentPage)==tab.Title.Text then
					tween(tab,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
					tween(tab.Image,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=0})
					tween(tab.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=0})
					tween(tab.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=1})
				else
					tween(tab,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=0.7})
					tween(tab.Image,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=0.2})
					tween(tab.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=0.2})
					tween(tab.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=0.5})
				end
			else
				tween(tab,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
				tween(tab.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=1})
				tween(tab.Image,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ImageTransparency=1})
				tween(tab.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=1})
			end
		end
	end
end

local function Hide(notify)
	if MPrompt then
		MPrompt.Title.TextColor3=Color3.fromRGB(255,255,255)
		MPrompt.Position=UDim2.new(0.5,0,0,-50)
		MPrompt.Size=UDim2.new(0,40,0,10)
		MPrompt.BackgroundTransparency=1
		MPrompt.Title.TextTransparency=1
		MPrompt.Visible=true
	end
	task.spawn(closeSearch)
	Debounce=true
	if notify then
		if useMobilePrompt then 
			Library:Notify({Title="Interface Hidden",Content="The interface has been hidden, you can unhide the interface by tapping 'Show'.",Duration=7,Image=4400697855})
		else
			Library:Notify({Title="Interface Hidden",Content="The interface has been hidden, you can unhide the interface by tapping " .. tostring(getSetting("General","rayfieldOpen")) .. ".",Duration=7,Image=4400697855})
		end
	end
	tween(Main,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,470,0,0)})
	tween(Main.Topbar,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,470,0,45)})
	tween(Main,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
	tween(Main.Topbar,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
	tween(Main.Topbar.Divider,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
	tween(Main.Topbar.CornerRepair,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
	tween(Main.Topbar.Title,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=1})
	tween(Main.Shadow.Image,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{ImageTransparency=1})
	tween(Topbar.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Transparency=1})
	if dragBarCosmetic then
		tween(dragBarCosmetic,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=1})
	end
	if useMobilePrompt and MPrompt then
		tween(MPrompt,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,120,0,30),Position=UDim2.new(0.5,0,0,20),BackgroundTransparency=0.3})
		tween(MPrompt.Title,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=0.3})
	end
	for _,topbarButton in ipairs(Topbar:GetChildren()) do
		if topbarButton.ClassName=="ImageButton" then
			tween(topbarButton,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{ImageTransparency=1})
		end
	end
	setTabButtonsVisible(false)
	if dragInteract then dragInteract.Visible=false end
	setElementsVisible(false)
	task.wait(0.5)
	Main.Visible=false
	Debounce=false
end

local function Maximise()
	Debounce=true
	Topbar.ChangeSize.Image=customAssets[tostring(10137941941)]
	tween(Topbar.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Transparency=1})
	tween(Main.Shadow.Image,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{ImageTransparency=0.6})
	tween(Topbar.CornerRepair,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	tween(Topbar.Divider,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	tween(dragBarCosmetic,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0.7})
	tween(Main,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=useMobileSizing and UDim2.new(0,500,0,275) or UDim2.new(0,500,0,475)})
	tween(Topbar,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,500,0,45)})
	TabList.Visible=true
	task.wait(0.2)
	Elements.Visible=true
	setElementsVisible(true)
	task.wait(0.1)
	setTabButtonsVisible(true)
	task.wait(0.5)
	Debounce=false
end

local function Unhide()
	Debounce=true
	Main.Position=UDim2.new(0.5,0,0.5,0)
	Main.Visible=true
	tween(Main,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=useMobileSizing and UDim2.new(0,500,0,275) or UDim2.new(0,500,0,475)})
	tween(Main.Topbar,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,500,0,45)})
	tween(Main.Shadow.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0.6})
	tween(Main,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	tween(Main.Topbar,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	tween(Main.Topbar.Divider,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	tween(Main.Topbar.CornerRepair,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	tween(Main.Topbar.Title,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=0})

	if MPrompt then
		tween(MPrompt,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,40,0,10),Position=UDim2.new(0.5,0,0,-50),BackgroundTransparency=1})
		tween(MPrompt.Title,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=1})

		task.spawn(function()
			task.wait(0.5)
			MPrompt.Visible=false
		end)
	end

	if Minimised then
		task.spawn(Maximise)
	end

	dragBar.Position=useMobileSizing and UDim2.new(0.5,0,0.5,dragOffsetMobile) or UDim2.new(0.5,0,0.5,dragOffset)

	dragInteract.Visible=true

	for _,TopbarButton in ipairs(Topbar:GetChildren()) do
		if TopbarButton.ClassName=="ImageButton" then
			if TopbarButton.Name=='Icon' then
				tween(TopbarButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0})
			else
				tween(TopbarButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0.8})
			end
		end
	end

	setTabButtonsVisible(true)

	setElementsVisible(true)

	tween(dragBarCosmetic,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0.5})

	task.wait(0.5)
	Minimised=false
	Debounce=false
end

local function Minimise()
	Debounce=true
	Topbar.ChangeSize.Image=customAssets[tostring(11036884234)]

	Topbar.UIStroke.Color=SelectedTheme.ElementStroke

	task.spawn(closeSearch)

	setTabButtonsVisible(false)

	setElementsVisible(false)

	tween(dragBarCosmetic,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=1})
	tween(Topbar.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Transparency=0})
	tween(Main.Shadow.Image,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{ImageTransparency=1})
	tween(Topbar.CornerRepair,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
	tween(Topbar.Divider,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
	tween(Main,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,495,0,45)})
	tween(Topbar,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,495,0,45)})

	task.wait(0.3)

	Elements.Visible=false
	TabList.Visible=false

	task.wait(0.2)
	Debounce=false
end

local function saveSettings() -- Save settings to config file
	local encoded
	local success,err=pcall(function()
		encoded=HttpService:JSONEncode(settingsTable)
	end)

	if success then
		if useStudio then
			if script.Parent['get.val'] then
				script.Parent['get.val'].Value=encoded
			end
		end
		callSafely(writefile,RayfieldFolder..'/settings'..ConfigurationExtension,encoded)
	end
end

local function updateSetting(category: string,setting: string,value: any)
	if not settingsInitialized then
		return
	end
	settingsTable[category][setting].Value=value
	overriddenSettings[category .. "." .. setting]=nil -- If user changes an overriden setting,remove the override
	saveSettings()
end

local function createSettings(window)
	if not (writefile and isfile and readfile and isfolder and makefolder) and not useStudio then
		if Topbar["Settings"] then Topbar.Settings.Visible=false end
		Topbar["Search"].Position=UDim2.new(1,-75,0.5,0)
		warn("Can't create settings as no file-saving functionality is available.")
		return
	end

	local newTab=window:CreateTab('Rayfield Settings',0,true)

	if TabList["Rayfield Settings"] then
		TabList["Rayfield Settings"].LayoutOrder=1000
	end

	if Elements["Rayfield Settings"] then
		Elements["Rayfield Settings"].LayoutOrder=1000
	end

	-- Create sections and elements
	for categoryName,settingCategory in pairs(settingsTable) do
		newTab:CreateSection(categoryName)

		for settingName,setting in pairs(settingCategory) do
			if setting.Type=='input' then
				setting.Element=newTab:CreateInput({
					Name=setting.Name,
					CurrentValue=setting.Value,
					PlaceholderText=setting.Placeholder,
					Ext=true,
					RemoveTextAfterFocusLost=setting.ClearOnFocus,
					Callback=function(Value)
						updateSetting(categoryName,settingName,Value)
					end,
				})
			elseif setting.Type=='toggle' then
				setting.Element=newTab:CreateToggle({
					Name=setting.Name,
					CurrentValue=setting.Value,
					Ext=true,
					Callback=function(Value)
						updateSetting(categoryName,settingName,Value)
					end,
				})
			elseif setting.Type=='bind' then
				setting.Element=newTab:CreateKeybind({
					Name=setting.Name,
					Keybind=setting.Value,
					HoldToInteract=false,
					Ext=true,
					CallOnChange=true,
					Callback=function(Value)
						updateSetting(categoryName,settingName,Value)
					end,
				})
			end
		end
	end

	settingsCreated=true
	loadSettings()
	saveSettings()
end

local function fadeOutKeyUI(KeyMain)
	tween(KeyMain,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
	tween(KeyMain,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,467,0,175)})
	tween(KeyMain.Shadow.Image,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{ImageTransparency=1})
	tween(KeyMain.Title,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{TextTransparency=1})
	tween(KeyMain.Subtitle,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=1})
	tween(KeyMain.KeyNote,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=1})
	tween(KeyMain.Input,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
	tween(KeyMain.Input.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Transparency=1})
	tween(KeyMain.Input.InputBox,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=1})
	tween(KeyMain.NoteTitle,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{TextTransparency=1})
	tween(KeyMain.NoteMessage,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{TextTransparency=1})
	tween(KeyMain.Hide,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{ImageTransparency=1})
end

function Library:CreateWindow(windowInfo)
	if Rayfield:FindFirstChild("Loading") then
		if getgenv and not getgenv().rayfieldCached then
			Rayfield.Enabled=true
			Rayfield.Loading.Visible=true
			task.wait(1.4)
			Rayfield.Loading.Visible=false
		end
	end
	if getgenv then getgenv().rayfieldCached=true end
	if not correctBuild and not windowInfo.DisableBuildWarnings then
		task.delay(3,function() Library:Notify({Title='Build Mismatch',Content='Rayfield may encounter issues as you are running an incompatible interface version ('.. ((Rayfield:FindFirstChild('Build') and Rayfield.Build.Value) or 'No Build') ..').\n\nThis version of Rayfield is intended for interface build '..InterfaceBuild..'.\n\nTry rejoining and then run the script twice.',Image=4335487866,Duration=15})	end)
	end
	if windowInfo.ToggleUIKeybind then -- Can either be a string or an Enum.KeyCode
		local keybind=windowInfo.ToggleUIKeybind
		if type(keybind)=="string" then
			keybind=string.upper(keybind)
			assert(pcall(function()
				return Enum.KeyCode[keybind]
			end),"ToggleUIKeybind must be a valid KeyCode")
			overrideSetting("General","rayfieldOpen",keybind)
		elseif typeof(keybind)=="EnumItem" then
			assert(keybind.EnumType==Enum.KeyCode,"ToggleUIKeybind must be a KeyCode enum")
			overrideSetting("General","rayfieldOpen",keybind.Name)
		else
			error("ToggleUIKeybind must be a string or KeyCode enum")
		end
	end
	ensureFolder(RayfieldFolder)
	local Pass=false
	Topbar.Title.Text=windowInfo.Name or windowInfo.Text or windowInfo.Title
	Main.Size=UDim2.new(0,420,0,100)
	Main.Visible=true
	Main.BackgroundTransparency=1
	if Main:FindFirstChild("Notice") then Main.Notice.Visible=false end
	Main.Shadow.Image.ImageTransparency=1
	LoadingFrame.Title.TextTransparency=1
	LoadingFrame.Subtitle.TextTransparency=1
	if windowInfo.ShowText then MPrompt.Title.Text="Show "..windowInfo.ShowText end
	LoadingFrame.Version.TextTransparency=1
	LoadingFrame.Title.Text=windowInfo.LoadingTitle or "Rayfield"
	LoadingFrame.Subtitle.Text=windowInfo.LoadingSubtitle or "Interface Suite"
	if windowInfo.LoadingTitle~="Rayfield Interface Suite" then
		LoadingFrame.Version.Text="Rayfield Lite"
	end
	if windowInfo.Icon and windowInfo.Icon~=0 and Topbar:FindFirstChild("Icon") then
		Topbar.Icon.Visible=true
		Topbar.Title.Position=UDim2.new(0,47,0.5,0)

		if windowInfo.Icon then
			local img,rectOffset,rectSize=resolveIcon(windowInfo.Icon)
			Topbar.Icon.Image=img
			if rectOffset then Topbar.Icon.ImageRectOffset=rectOffset end
			if rectSize then Topbar.Icon.ImageRectSize=rectSize end
		else
			Topbar.Icon.Image=""
		end
	end
	if dragBar then
		dragBar.Visible=false
		dragBarCosmetic.BackgroundTransparency=1
		dragBar.Visible=true
	end
	if windowInfo.Theme then
		local success1,result=pcall(ChangeTheme,windowInfo.Theme)
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
	local configurationSaving=windowInfo.ConfigurationSaving
	if configurationSaving then
		if not configurationSaving.FileName then
			configurationSaving.FileName=tostring(game.PlaceId)
		end
		if configurationSaving.Enabled==nil then
			configurationSaving.Enabled=false
		end
		CFileName=configurationSaving.FileName
		ConfigurationFolder=configurationSaving.FolderName or ConfigurationFolder
		CEnabled=configurationSaving.Enabled
		if configurationSaving.Enabled then ensureFolder(ConfigurationFolder) end
	end
	makeDraggable(Main,Topbar,false,{dragOffset,dragOffsetMobile})
	if dragBar then dragBar.Position=useMobileSizing and UDim2.new(0.5,0,0.5,dragOffsetMobile) or UDim2.new(0.5,0,0.5,dragOffset) makeDraggable(Main,dragInteract,true,{dragOffset,dragOffsetMobile}) end
	for _,tabButton in ipairs(TabList:GetChildren()) do
		if tabButton.ClassName=="Frame" and tabButton.Name~="Placeholder" then
			tabButton.BackgroundTransparency=1
			tabButton.Title.TextTransparency=1
			tabButton.Image.ImageTransparency=1
			tabButton.UIStroke.Transparency=1
		end
	end
	local discordInfo=windowInfo.Discord
	if discordInfo and discordInfo.Enabled and discordInfo.Invite and not useStudio and not secureMode then
		ensureFolder(RayfieldFolder.."/Discord Invites")
		if isfile and not callSafely(isfile,RayfieldFolder.."/Discord Invites".."/"..discordInfo.Invite..ConfigurationExtension) then
			requestSafely({
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
			if discordInfo.RememberJoins then -- We do logic this way so if the developer changes this setting,the user still won't be prompted,only new users
				callSafely(writefile,RayfieldFolder.."/Discord Invites".."/"..discordInfo.Invite..ConfigurationExtension,"Rayfield RememberJoins is true for this invite,this invite will not ask you to join again")
			end
		end
	end
	local keyInfo=windowInfo.KeyInfo
	if keyInfo and keyInfo.Enabled then
		ensureFolder(RayfieldFolder.."/Key System")
		if type(keyInfo.Key)=="string" then keyInfo.Key={keyInfo.Key} end
		if keyInfo.GrabKeyFromSite then
			for i,key in ipairs(keyInfo.Key) do
				local success,response=pcall(function()
					keyInfo.Key[i]=tostring(game:HttpGet(key):gsub("[\n\r]"," "))
					keyInfo.Key[i]=string.gsub(keyInfo.Key[i]," ","")
				end)
				if not success then
					print("Rayfield | "..key.." Error " ..tostring(response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
				end
			end
		end
		if not keyInfo.FileName then keyInfo.FileName="No file name specified" end
		if isfile and readfile and callSafely(isfile,RayfieldFolder.."/Key System".."/"..keyInfo.FileName..ConfigurationExtension) then
			for _,mKey in ipairs(KeyInfo.Key) do
				local savedKeys=callSafely(readfile,RayfieldFolder.."/Key System".."/"..keyInfo.FileName..ConfigurationExtension)
				if savedKeys and string.find(savedKeys,mKey) then
					Pass=true
				end
			end
		end
		if not Pass and secureMode then
			warn("Rayfield | Secure Mode: Key system requires a valid saved key. The key UI cannot be shown as it requires loading detectable assets.")
			Rayfield.Enabled=false
			return Library
		end
		if not Pass then
			local AttemptsRemaining=keyInfo.MaxAttempts or 5
			Rayfield.Enabled=false
			local KeyUI=useStudio and script.Parent:FindFirstChild('Key') or game:GetObjects("rbxassetid://11380036235")[1]
			KeyUI.Enabled=true
			if gethui then
				KeyUI.Parent=gethui()
			elseif syn and syn.protect_gui then 
				syn.protect_gui(KeyUI)
				KeyUI.Parent=CoreGui
			elseif not useStudio and CoreGui:FindFirstChild("RobloxGui") then
				KeyUI.Parent=CoreGui:FindFirstChild("RobloxGui")
			elseif not useStudio then
				KeyUI.Parent=CoreGui
			end
			if gethui then
				for _,Interface in ipairs(gethui():GetChildren()) do
					if Interface.Name==KeyUI.Name and Interface~=KeyUI then
						Interface.Enabled=false
						Interface.Name="KeyUI-Old"
					end
				end
			elseif not useStudio then
				for _,Interface in ipairs(CoreGui:GetChildren()) do
					if Interface.Name==KeyUI.Name and Interface~=KeyUI then
						Interface.Enabled=false
						Interface.Name="KeyUI-Old"
					end
				end
			end
			local KeyMain=KeyUI.Main
			KeyMain.Title.Text=keyInfo.Title or keyInfo.Name or keyInfo.Text
			KeyMain.Subtitle.Text=keyInfo.Subtitle or "Key System"
			KeyMain.NoteMessage.Text=keyInfo.Note or "No instructions"
			KeyMain.Size=UDim2.new(0,467,0,175)
			KeyMain.BackgroundTransparency=1
			KeyMain.Shadow.Image.ImageTransparency=1
			KeyMain.Title.TextTransparency=1
			KeyMain.Subtitle.TextTransparency=1
			KeyMain.KeyNote.TextTransparency=1
			KeyMain.Input.BackgroundTransparency=1
			KeyMain.Input.UIStroke.Transparency=1
			KeyMain.Input.InputBox.TextTransparency=1
			KeyMain.NoteTitle.TextTransparency=1
			KeyMain.NoteMessage.TextTransparency=1
			KeyMain.Hide.ImageTransparency=1
			tween(KeyMain,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			tween(KeyMain,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,500,0,187)})
			tween(KeyMain.Shadow.Image,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{ImageTransparency=0.5})
			task.wait(0.05)
			tween(KeyMain.Title,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{TextTransparency=0})
			tween(KeyMain.Subtitle,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=0})
			task.wait(0.05)
			tween(KeyMain.KeyNote,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=0})
			tween(KeyMain.Input,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			tween(KeyMain.Input.UIStroke,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Transparency=0})
			tween(KeyMain.Input.InputBox,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=0})
			task.wait(0.05)
			tween(KeyMain.NoteTitle,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{TextTransparency=0})
			tween(KeyMain.NoteMessage,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{TextTransparency=0})
			task.wait(0.15)
			tween(KeyMain.Hide,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{ImageTransparency=0.3})
			KeyUI.Main.Input.InputBox.FocusLost:Connect(function()
				if #KeyUI.Main.Input.InputBox.Text==0 then return end
				local keyFound=false
				local savedKey=""
				for _,MKey in ipairs(keyInfo.Key) do
					-- stricter key check
					if KeyMain.Input.InputBox.Text==MKey then
						keyFound=true
						savedKey=MKey
					end
				end
				if keyFound then
					fadeOutKeyUI(KeyMain)
					task.wait(0.51)
					Pass=true
					KeyMain.Visible=false
					if keyInfo.SaveKey and writefile then
						callSafely(writefile,RayfieldFolder.."/Key System".."/"..keyInfo.FileName..ConfigurationExtension,FoundKey)
						Library:Notify({Title="Key System",Content="The key for this script has been saved successfully.",Image=3605522284})
					end
				else
					if AttemptsRemaining==0 then
						fadeOutKeyUI(KeyMain)
						task.wait(0.45)
						Players.LocalPlayer:Kick("No Attempts Remaining")
						game:Shutdown()
					end
					KeyMain.Input.InputBox.Text=""
					AttemptsRemaining=AttemptsRemaining-1
					tween(KeyMain,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,467,0,175)})
					tween(KeyMain,TweenInfo.new(0.4,Enum.EasingStyle.Elastic),{Position=UDim2.new(0.495,0,0.5,0)})
					task.wait(0.1)
					tween(KeyMain,TweenInfo.new(0.4,Enum.EasingStyle.Elastic),{Position=UDim2.new(0.505,0,0.5,0)})
					task.wait(0.1)
					tween(KeyMain,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{Position=UDim2.new(0.5,0,0.5,0)})
					tween(KeyMain,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,500,0,187)})
				end
			end)
			KeyMain.Hide.MouseButton1Click:Connect(function()
				fadeOutKeyUI(KeyMain)
				task.wait(0.51)
				Pass=true
				Library:Destroy()
				KeyUI:Destroy()
			end)
		else
			Pass=true
		end
		repeat task.wait() until Pass
		-- Prevents animation from trying to play if the button's callback called Library:Destroy()
		if rayfieldDestroyed then return end
	end
	Notifications.Template.Visible=false
	Notifications.Visible=true
	Rayfield.Enabled=true
	task.wait(0.5)
	tween(Main,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	tween(Main.Shadow.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0.6})
	task.wait(0.1)
	tween(LoadingFrame.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})
	task.wait(0.05)
	tween(LoadingFrame.Subtitle,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})
	task.wait(0.05)
	tween(LoadingFrame.Version,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})
	task.wait(1)
	Elements.Template.LayoutOrder=100000
	Elements.Template.Visible=false
	Elements.UIPageLayout.FillDirection=Enum.FillDirection.Horizontal
	Elements.UIPageLayout.ScrollWheelInputEnabled=false
	Elements.UIPageLayout.GamepadInputEnabled=false
	Elements.UIPageLayout.TouchInputEnabled=false
	TabList.Template.Visible=false
	-- Tab
	local FirstTab=false
	local Window={}
	function Window:CreateTab(Name,Image,Ext)
		local TabPrivate={Order=0}
		local SDone=false
		local TabButton=TabList.Template:Clone()
		TabButton.Name=Name
		TabButton.Title.Text=Name
		TabButton.Parent=TabList
		TabButton.Title.TextWrapped=false
		TabButton.Size=UDim2.new(0,TabButton.Title.TextBounds.X+30,0,30)
		if Image and Image~=0 then
			local img,rectOffset,rectSize=resolveIcon(Image)
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

		-- Create Elements Page
		local TabPage=Elements.Template:Clone()
		TabPage.Name=Name
		TabPage.Visible=true

		TabPage.LayoutOrder=Ext and 10000 or #Elements:GetChildren()

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
		task.wait(0.1)
		if FirstTab or Ext then
			TabButton.BackgroundColor3=SelectedTheme.TabBackground
			TabButton.Image.ImageColor3=SelectedTheme.TabTextColor
			TabButton.Title.TextColor3=SelectedTheme.TabTextColor
			tween(TabButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0.7})
			tween(TabButton.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0.2})
			tween(TabButton.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0.2})
			tween(TabButton.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0.5})
		elseif not Ext then
			FirstTab=Name
			TabButton.BackgroundColor3=SelectedTheme.TabBackgroundSelected
			TabButton.Image.ImageColor3=SelectedTheme.SelectedTabTextColor
			TabButton.Title.TextColor3=SelectedTheme.SelectedTabTextColor
			tween(TabButton.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0})
			tween(TabButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			tween(TabButton.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})
		end

		TabButton.Interact.MouseButton1Click:Connect(function()
			if Minimised then return end
			tween(TabButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			tween(TabButton.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=1})
			tween(TabButton.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})
			tween(TabButton.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0})
			tween(TabButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.TabBackgroundSelected})
			tween(TabButton.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextColor3=SelectedTheme.SelectedTabTextColor})
			tween(TabButton.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageColor3=SelectedTheme.SelectedTabTextColor})

			for _,OtherTabButton in ipairs(TabList:GetChildren()) do
				if OtherTabButton.Name~="Template" and OtherTabButton.ClassName=="Frame" and OtherTabButton~=TabButton and OtherTabButton.Name~="Placeholder" then
					tween(OtherTabButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.TabBackground})
					tween(OtherTabButton.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextColor3=SelectedTheme.TabTextColor})
					tween(OtherTabButton.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageColor3=SelectedTheme.TabTextColor})
					tween(OtherTabButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0.7})
					tween(OtherTabButton.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0.2})
					tween(OtherTabButton.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0.2})
					tween(OtherTabButton.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0.5})
				end
			end

			if Elements.UIPageLayout.CurrentPage~=TabPage then
				Elements.UIPageLayout:JumpTo(TabPage)
			end
		end)
		
		local DefaultData={
			["Toggle"]={Type="Toggle",Name="Toggle Here",Value=false,Ext=false,Callback=function(Value) end},
			["Button"]={Type="Button",Name="Button Here",Callback=function() end,Set=function(Value) end},
			["Selector"]={Type="Selector",Name="Selector Here",Value="Option 1",Options={"Option 1","Option 2","Option 3","Option 4"},NoCap=true,Callback=function(Value) end,Set=function(Value,Index) end,Add=function(Value) end,Remove=function(Value) end},
			["Expand"]={Type="Expand",Name="Events",Active=false,List={},Callback=function() end,Add=function() end,Remove=function() end},
			["ColorPicker"]={Type="ColorPicker",Name="Color Picker Here",Color=Color3.fromRGB(163,162,165),Ext=false,Callback=function(Color) end},
			["Section"]={Type="Section",Name="Section Here",Set=function(Value) end},
			["Label"]={Type="Label",Text="Label Here",Icon=nil,Color=nil,IgnoreTheme=false},
			["Paragraph"]={Type="Paragraph",Title="Paragraph Here",["Content"]="Long Text Here",Ext=false,Set=function(Value) end},
			["Input"]={Type="Input",Name="Input Here",PlaceholderText="Type here",Value="",Ext=false,Callback=function(InputText) end},
			["Dropdown"]={Type="Dropdown",Name="Dropdown Here",Options={"Option 1","Option 2","Option 3","Option 4","Option 5","Option 6"},MultipleOptions=false,CurrentOption={},Ext=false,Callback=function(Value) end},
			["Slider"]={Type="Slider",Name="Slider Here",["Version"]=1,Increment=1,Value=1,Range={1,10},Ext=false,Callback=function(Value) end},
			["Keybind"]={Type="Keybind",Name="Keybind Here",Keybind="E",Value="E",Ext=false,Callback=function(Value) end}
		}

		local function PackTab(info,data,disabled)
			if not disabled then
				info=type(info)=="table" and info or {}
			end
			for k,v in pairs(data) do 
				local x=info[k]
				if x==nil then 
					info[k]=v 
				elseif v~=nil and typeof(x)~=typeof(v) then
					info[k]=v
				end 
			end
			return info
		end
		
		local Tab={}

		-- Button
		function Tab:CreateButton(ButtonInfo)
			ButtonInfo=PackTab(ButtonInfo,DefaultData.Button)
			local Button=Elements.Template.Button:Clone()
			ButtonInfo.Template=Button
			TabPrivate.Order+=1
			Button.LayoutOrder=TabPrivate.Order
			Button.Name=ButtonInfo.Name
			Button.Title.Text=ButtonInfo.Name
			Button.Visible=true
			Button.Parent=TabPage
			Button.BackgroundTransparency=1
			Button.UIStroke.Transparency=1
			Button.Title.TextTransparency=1
			tween(Button,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			tween(Button.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0})
			tween(Button.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
			Button.Interact.MouseButton1Click:Connect(function()
				local Success,Response=pcall(ButtonInfo.Callback)
				if not Success then
					tween(Button,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
					tween(Button.ElementIndicator,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{TextTransparency=1})
					tween(Button.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					Button.Title.Text="Callback Error"
					print("Rayfield | "..ButtonInfo.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Button.Title.Text=ButtonInfo.Name
					tween(Button,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					tween(Button.ElementIndicator,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{TextTransparency=0.9})
					tween(Button.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
				else
					if not ButtonInfo.Ext then
						SaveConfiguration(ButtonInfo.Name..'\n')
					end
					tween(Button,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
					tween(Button.ElementIndicator,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{TextTransparency=1})
					tween(Button.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					task.wait(0.2)
					tween(Button,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					tween(Button.ElementIndicator,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{TextTransparency=0.9})
					tween(Button.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
				end
			end)
			Button.MouseEnter:Connect(function()
				tween(Button,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
				tween(Button.ElementIndicator,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{TextTransparency=0.7})
			end)
			Button.MouseLeave:Connect(function()
				tween(Button,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
				tween(Button.ElementIndicator,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{TextTransparency=0.9})
			end)
			function ButtonInfo:Set(NewButton)
				Button.Title.Text=NewButton
				Button.Name=NewButton
			end
			return ButtonInfo
		end

		-- Selector
		function Tab:CreateSelector(SelectorInfo)
			SelectorInfo=PackTab(SelectorInfo,DefaultData.Selector)
			if not Elements:FindFirstChild("Template") or not Elements.Template:FindFirstChild("Selector") then warn("Rayfield | Selector not found.") return SelectorInfo end
			local Selector=Elements.Template.Selector:Clone()
			SelectorInfo.Template=Selector
			TabPrivate.Order+=1
			Selector.LayoutOrder=TabPrivate.Order
			Selector.Name=SelectorInfo.Name
			Selector.Title.Text=SelectorInfo.Name
			Selector.Visible=true
			Selector.Parent=TabPage
			Selector.BackgroundTransparency=1
			Selector.UIStroke.Transparency=1
			Selector.Title.TextTransparency=1
			tween(Selector,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			tween(Selector.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0})
			tween(Selector.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
			local PreviousButton=Selector:FindFirstChild("Previous")
			local NextButton=Selector:FindFirstChild("Next")
			local Information=Selector:FindFirstChild("Information")
			local Index=1
			if type(SelectorInfo.Options)~="table" then
				SelectorInfo.Options={"Option 1","Option 2"}
			end
			SelectorInfo.Index=type(SelectorInfo.Index)=="number" and SelectorInfo.Index or 0
			Information.Text=tostring(SelectorInfo.Value or SelectorInfo.Options[1])
			function SelectorInfo:Set(value,index)
				SelectorInfo.Value=value
				Information.Text=tostring(value)
				if index then SelectorInfo.Index=index end
				local Success,Response=pcall(function()
					if SelectorInfo.Callback then SelectorInfo.Callback(value,index) end
				end)
				if not Success then
					tween(Selector,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
					tween(Selector.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					SelectorInfo.Title.Text="Callback Error"
					print("Rayfield | "..SelectorInfo.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					SelectorInfo.Title.Text=SelectorInfo.Name
					tween(Selector,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					tween(Selector.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
				end
			end
			function SelectorInfo:Add(value)
				if not table.find(SelectorInfo.Options,value) then
					table.insert(SelectorInfo.Options,value)
					if SelectorInfo.Added then callSafely(SelectorInfo.Added,value) end
				end
			end
			function SelectorInfo:Remove(value)
				local pos=table.find(SelectorInfo.Options,value)
				if pos~=nil then
					table.remove(SelectorInfo.Options,pos)
					if SelectorInfo.Removing then callSafely(SelectorInfo.Removing,value) end
				end
			end
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
			if windowInfo.ConfigurationSaving and windowInfo.ConfigurationSaving.Enabled and SelectorInfo.Flag then
				Library.Flags[SelectorInfo.Flag]=SelectorInfo
			end
			return SelectorInfo
		end

		-- Expand
		function Tab:CreateExpand(ExpandInfo)
			ExpandInfo=PackTab(ExpandInfo,DefaultData.Expand)
			if Elements.Template:FindFirstChild("Expand") then 
				local List={}
				local Expand=Elements.Template.Expand:Clone()
				ExpandInfo.Template=Expand
				TabPrivate.Order+=1
				Expand.LayoutOrder=TabPrivate.Order
				Expand.Name=ExpandInfo.Name
				Expand.Title.Text=ExpandInfo.Name
				Expand.Visible=true
				Expand.Parent=TabPage
				function ExpandInfo:Remove(Context)
					if Context["_expandAncestryChanged"] then Context._expandAncestryChanged:Disconnect() Context._expandAncestryChanged=nil end
					local pos=table.find(List,Context) if pos then table.remove(List,Context) end
					if ExpandInfo.Removing then callSafely(ExpandInfo.Removing,Context) end
				end
				function ExpandInfo:Add(Context)
					if type(Context)=="table" and Context.Type and Context.Template and Context.Template.Parent and not table.find(List,Context) then
						local OtherTemplate=Context.Template
						OtherTemplate.Visible=ExpandInfo.Active
						table.insert(List,Context)
						local ancestryChanged;
						ancestryChanged=OtherTemplate.AncestryChanged:Connect(function(_,Parent)
							if not Parent then
								ancestryChanged:Disconnect()
								Context._expandAncestryChanged=nil
								local pos=table.find(List,Context)
								if pos then table.remove(List,pos) end
							end
						end)
						Context._expandAncestryChanged=ancestryChanged
						if ExpandInfo.Added then callSafely(ExpandInfo.Added,Context) end
					end
				end
				Expand.Interact.MouseButton1Click:Connect(function()
					if ExpandInfo.Debounce then return end
					ExpandInfo.Debounce=true
					local active=not ExpandInfo.Active
					ExpandInfo.Active=active
					for i,v in ipairs(List) do if v and v.Template and v.Template.Parent then v.Template.Visible=active end end
					callSafely(ExpandInfo.Callback,active)
					ExpandInfo.Debounce=nil
				end)
			else
				warn("Rayfield | Expand not found, replace with section.") 
				local SectionInfo=Tab:CreateSection(ExpandInfo.Name)
				for k,v in pairs(SectionInfo) do ExpandInfo[k]=v end
			end
			return ExpandInfo
		end

		-- ColorPicker
		function Tab:CreateColorPicker(ColorPickerInfo) -- by Throit
			ColorPickerInfo=PackTab(ColorPickerInfo,DefaultData.ColorPicker)
			local ColorPicker=Elements.Template.ColorPicker:Clone()
			local Background=ColorPicker.CPBackground
			local Display=Background.Display
			local Main=Background.MainCP
			local Slider=ColorPicker.ColorSlider
			ColorPickerInfo.Template=ColorPicker
			TabPrivate.Order+=1
			ColorPicker.LayoutOrder=TabPrivate.Order
			ColorPicker.ClipsDescendants=true
			ColorPicker.Name=ColorPickerInfo.Name
			ColorPicker.Title.Text=ColorPickerInfo.Name
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
			ColorPicker.Interact.MouseButton1Down:Connect(function()
				task.spawn(function()
					tween(ColorPicker,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
					tween(ColorPicker.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					task.wait(0.2)
					tween(ColorPicker,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					tween(ColorPicker.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
				end)
				if not opened then
					opened=true 
					tween(Background,TweenInfo.new(0.45,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,18,0,15)})
					task.wait(0.1)
					tween(ColorPicker,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,-10,0,120)})
					tween(Background,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,173,0,86)})
					tween(Display,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
					tween(ColorPicker.Interact,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Position=UDim2.new(0.289,0,0.5,0)})
					tween(ColorPicker.RGB,TweenInfo.new(0.8,Enum.EasingStyle.Exponential),{Position=UDim2.new(0,17,0,40)})
					tween(ColorPicker.HexInput,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Position=UDim2.new(0,17,0,73)})
					tween(ColorPicker.Interact,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(0.574,0,1,0)})
					tween(Main.MainPoint,TweenInfo.new(0.2,Enum.EasingStyle.Exponential),{ImageTransparency=0})
					tween(Main,TweenInfo.new(0.2,Enum.EasingStyle.Exponential),{ImageTransparency=SelectedTheme~=Library.Theme.Default and 0.25 or 0.1})
					tween(Background,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
				else
					opened=false
					tween(ColorPicker,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,-10,0,45)})
					tween(Background,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(0,39,0,22)})
					tween(ColorPicker.Interact,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,0,1,0)})
					tween(ColorPicker.Interact,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Position=UDim2.new(0.5,0,0.5,0)})
					tween(ColorPicker.RGB,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Position=UDim2.new(0,17,0,70)})
					tween(ColorPicker.HexInput,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Position=UDim2.new(0,17,0,90)})
					tween(Display,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
					tween(Main.MainPoint,TweenInfo.new(0.2,Enum.EasingStyle.Exponential),{ImageTransparency=1})
					tween(Main,TweenInfo.new(0.2,Enum.EasingStyle.Exponential),{ImageTransparency=1})
					tween(Background,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
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
				callSafely(ColorPickerInfo.Callback,Color3.fromHSV(h,s,v))
				local r,g,b=math.floor((h*255)+0.5),math.floor((s*255)+0.5),math.floor((v*255)+0.5)
				ColorPickerInfo.Color=Color3.fromRGB(r,g,b)
				if not ColorPickerInfo.Ext then
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
					SaveConfiguration(ColorPickerInfo.Flag..'\n'..tostring(ColorPickerInfo.Color))
				end
			end
			ColorPicker.RGB.RInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.RInput.InputBox,"R")
				callSafely(ColorPickerInfo.Callback,Color3.fromHSV(h,s,v))
			end)
			ColorPicker.RGB.GInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.GInput.InputBox,"G")
				callSafely(ColorPickerInfo.Callback,Color3.fromHSV(h,s,v))
			end)
			ColorPicker.RGB.BInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.BInput.InputBox,"B")
				callSafely(ColorPickerInfo.Callback,Color3.fromHSV(h,s,v))
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
					callSafely(ColorPickerInfo.Callback,Color3.fromHSV(h,s,v))
					local value=Color3.fromRGB(r,g,b)
					ColorPickerInfo.Color=value
					if not ColorPickerInfo.Ext then
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
					callSafely(ColorPickerInfo.Callback,Color3.fromHSV(h,s,v))
					ColorPickerInfo.Color=Color3.fromRGB(r,g,b)
					if not ColorPickerInfo.Ext then
						SaveConfiguration()
					end
				end
			end)
			ColorPicker.Destroying:Connect(function()
				if colorPickerLooped then colorPickerLooped:Disconnect() end
				if colorPickerInputEnded then colorPickerInputEnded:Disconnect() end
			end)
			if windowInfo.ConfigurationSaving then if windowInfo.ConfigurationSaving.Enabled and ColorPickerInfo.Flag then Library.Flags[ColorPickerInfo.Flag]=ColorPickerInfo end end
			function ColorPickerInfo:Set(RGBColor)
				ColorPickerInfo.Color=RGBColor h,s,v=ColorPickerInfo.Color:ToHSV() color=Color3.fromHSV(h,s,v) setDisplay()
			end
			ColorPicker.MouseEnter:Connect(function()
				tween(ColorPicker,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
			end)
			ColorPicker.MouseLeave:Connect(function()
				tween(ColorPicker,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
			end)
			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				for i,v in ipairs(ColorPicker.RGB:GetChildren()) do if v:IsA("Frame") then v.BackgroundColor3=SelectedTheme.InputBackground v.UIStroke.Color=SelectedTheme.InputStroke end end ColorPicker.HexInput.BackgroundColor3=SelectedTheme.InputBackground ColorPicker.HexInput.UIStroke.Color=SelectedTheme.InputStroke
			end)
			return ColorPickerInfo
		end

		-- Section
		function Tab:CreateSection(SectionName)
			local SectionInfo={Name=SectionName}
			SectionInfo=PackTab(SectionInfo,DefaultData.Section)
			if SDone then
				local SectionSpace=Elements.Template.SectionSpacing:Clone()
				TabPrivate.Order+=1
				SectionSpace.LayoutOrder=TabPrivate.Order
				SectionSpace.Visible=true
				SectionSpace.Parent=TabPage
			end
			SDone=true
			local Section=Elements.Template.SectionTitle:Clone()
			SectionInfo.Template=Section
			TabPrivate.Order+=1
			Section.LayoutOrder=TabPrivate.Order
			Section.Title.Text=SectionName
			Section.Visible=true
			Section.Parent=TabPage
			Section.Title.TextTransparency=1
			tween(Section.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0.4})
			function SectionInfo:Set(NewSection)
				Section.Title.Text=NewSection
				SectionInfo.Value=NewSection
			end
			return SectionInfo
		end

		-- Divider
		function Tab:CreateDivider()
			local DividerInfo={Type="Divider"}
			local Divider=Elements.Template.Divider:Clone()
			DividerInfo.Template=Divider
			TabPrivate.Order+=1
			Divider.LayoutOrder=TabPrivate.Order
			Divider.Visible=true
			Divider.Parent=TabPage
			Divider.Divider.BackgroundTransparency=1
			tween(Divider.Divider,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{BackgroundTransparency=0.85})
			function DividerInfo:Set(Value)
				Divider.Visible=Value
			end
			return DividerInfo
		end

		-- Label
		function Tab:CreateLabel(Text,Icon,Color,IgnoreTheme)
			local LabelInfo={Text=Text,Icon=Icon,Color=Color,IgnoreTheme=IgnoreTheme}
			LabelInfo=PackTab(LabelInfo,DefaultData.Label)
			local Label=Elements.Template.Label:Clone()
			LabelInfo.Template=Label
			TabPrivate.Order+=1
			Label.LayoutOrder=TabPrivate.Order
			Label.Title.Text=LabelInfo.Text
			Label.Visible=true
			Label.Parent=TabPage
			Label.BackgroundColor3=LabelInfo.Color and LabelInfo.Color or SelectedTheme.SecondaryElementBackground
			Label.UIStroke.Color=LabelInfo.Color and LabelInfo.Color or SelectedTheme.SecondaryElementStroke
			if LabelInfo.Icon then
				local img,rectOffset,rectSize=resolveIcon(LabelInfo.Icon)
				Label.Icon.Image=img
				if rectOffset then Label.Icon.ImageRectOffset=rectOffset end
				if rectSize then Label.Icon.ImageRectSize=rectSize end
			else
				Label.Icon.Image=""
			end
			if LabelInfo.Icon and Label:FindFirstChild('Icon') then
				Label.Title.Position=UDim2.new(0,45,0.5,0)
				Label.Title.Size=UDim2.new(1,-100,0,14)
				Label.Icon.Visible=true
			end

			Label.Icon.ImageTransparency=1
			Label.BackgroundTransparency=1
			Label.UIStroke.Transparency=1
			Label.Title.TextTransparency=1

			tween(Label,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=Color and 0.8 or 0})
			tween(Label.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=Color and 0.7 or 0})
			tween(Label.Icon,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0.2})
			tween(Label.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=Color and 0.2 or 0})	

			function LabelInfo:Set(Text,Icon,Color)
				local labelText=Text or LabelInfo.Text
				if labelText then
					LabelInfo.Text=labelText
					Label.Title.Text=labelText
					LabelInfo.Text=labelText
				end

				local labelColor=Color or SelectedTheme.SecondaryElementBackground
				Label.BackgroundColor3=labelColor
				Label.UIStroke.Color=labelColor
				LabelInfo.COlor=labelColor

				local labelIcon=Icon or LabelInfo.Icon
				if labelIcon and Label:FindFirstChild('Icon') then
					LabelInfo.Icon=labelIcon

					Label.Title.Position=UDim2.new(0,45,0.5,0)
					Label.Title.Size=UDim2.new(1,-100,0,14)

					local img,rectOffset,rectSize=resolveIcon(labelIcon)
					Label.Icon.Image=img
					if rectOffset then Label.Icon.ImageRectOffset=rectOffset end
					if rectSize then Label.Icon.ImageRectSize=rectSize end

					Label.Icon.Visible=true
				end
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Label.BackgroundColor3=IgnoreTheme and (Color or Label.BackgroundColor3) or SelectedTheme.SecondaryElementBackground
				Label.UIStroke.Color=IgnoreTheme and (Color or Label.BackgroundColor3) or SelectedTheme.SecondaryElementStroke
			end)

			return LabelInfo
		end

		-- Paragraph
		function Tab:CreateParagraph(ParagraphInfo)
			ParagraphInfo=PackTab(ParagraphInfo,DefaultData.Paragraph)
			local Paragraph=Elements.Template.Paragraph:Clone()
			ParagraphInfo.Template=Paragraph
			TabPrivate.Order+=1
			Paragraph.LayoutOrder=TabPrivate.Order
			Paragraph.Title.Text=ParagraphInfo.Title
			Paragraph.Content.Text=ParagraphInfo.Content
			Paragraph.Visible=true
			Paragraph.Parent=TabPage
			Paragraph.BackgroundTransparency=1
			Paragraph.UIStroke.Transparency=1
			Paragraph.Title.TextTransparency=1
			Paragraph.Content.TextTransparency=1
			Paragraph.BackgroundColor3=SelectedTheme.SecondaryElementBackground
			Paragraph.UIStroke.Color=SelectedTheme.SecondaryElementStroke
			tween(Paragraph,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			tween(Paragraph.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0})
			tween(Paragraph.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
			tween(Paragraph.Content,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
			function ParagraphInfo:Set(NewParagraphInfo)
				Paragraph.Title.Text=NewParagraphInfo.Title
				Paragraph.Content.Text=NewParagraphInfo.Content
			end
			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Paragraph.BackgroundColor3=SelectedTheme.SecondaryElementBackground
				Paragraph.UIStroke.Color=SelectedTheme.SecondaryElementStroke
			end)
			return ParagraphInfo
		end

		-- Input
		function Tab:CreateInput(InputInfo)
			InputInfo=type(InputInfo)=="table" and InputInfo or {}
			if InputInfo.CurrentValue then InputInfo.Value=InputInfo.CurrentValue InputInfo.CurrentValue=nil end
			InputInfo=PackTab(InputInfo,DefaultData.Input,true)
			local Input=Elements.Template.Input:Clone()
			InputInfo.Template=Input
			TabPrivate.Order+=1
			Input.LayoutOrder=TabPrivate.Order
			Input.Name=InputInfo.Name
			Input.Title.Text=InputInfo.Name
			Input.Visible=true
			Input.Parent=TabPage
			Input.BackgroundTransparency=1
			Input.UIStroke.Transparency=1
			Input.Title.TextTransparency=1
			Input.InputFrame.InputBox.Text=tostring(InputInfo.Value)
			Input.InputFrame.BackgroundColor3=SelectedTheme.InputBackground
			Input.InputFrame.UIStroke.Color=SelectedTheme.InputStroke
			tween(Input,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			tween(Input.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0})
			tween(Input.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
			Input.InputFrame.InputBox.PlaceholderText=InputInfo.PlaceholderText
			Input.InputFrame.Size=UDim2.new(0,Input.InputFrame.InputBox.TextBounds.X+24,0,30)
			Input.InputFrame.InputBox.FocusLost:Connect(function(enter)
				local Success,Response=pcall(InputInfo.Callback,Input.InputFrame.InputBox.Text)
				if not Success then
					tween(Input,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
					tween(Input.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					Input.Title.Text="Callback Error"
					print("Rayfield | "..InputInfo.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Input.Title.Text=InputInfo.Name
					tween(Input,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					tween(Input.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
				end
				if InputInfo.RemoveTextAfterFocusLost then Input.InputFrame.InputBox.Text="" end
				if not InputInfo.Ext then SaveConfiguration() end
			end)
			Input.MouseEnter:Connect(function()
				tween(Input,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
			end)
			Input.MouseLeave:Connect(function()
				tween(Input,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
			end)
			Input.InputFrame.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
				tween(Input.InputFrame,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Size=UDim2.new(0,Input.InputFrame.InputBox.TextBounds.X+24,0,30)})
			end)
			function InputInfo:Replace(text)
				if InputInfo.Value~=text then
					InputInfo.Value=text
					Input.InputFrame.InputBox.Text=text
					if not InputInfo.Ext then SaveConfiguration() end
				end
			end
			function InputInfo:Set(text)
				Input.InputFrame.InputBox.Text=text
				InputInfo.Value=text
				callSafely(InputInfo.Callback,text)
				if not InputInfo.Ext then SaveConfiguration() end
			end
			if windowInfo.ConfigurationSaving and windowInfo.ConfigurationSaving.Enabled and InputInfo.Flag then
				Library.Flags[InputInfo.Flag]=InputInfo
			end
			Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Input.InputFrame.BackgroundColor3=SelectedTheme.InputBackground
				Input.InputFrame.UIStroke.Color=SelectedTheme.InputStroke
			end)
			return InputInfo
		end

		-- Dropdown
		function Tab:CreateDropdown(DropdownInfo)
			DropdownInfo=PackTab(DropdownInfo,DefaultData.Dropdown)
			local Dropdown=Elements.Template.Dropdown:Clone()
			DropdownInfo.Template=Dropdown
			TabPrivate.Order+=1
			Dropdown.LayoutOrder=TabPrivate.Order
			if string.find(DropdownInfo.Name,"closed") then Dropdown.Name="Dropdown" else Dropdown.Name=DropdownInfo.Name end
			Dropdown.Title.Text=DropdownInfo.Name
			Dropdown.Visible=true
			Dropdown.Parent=TabPage
			Dropdown.List.Visible=false
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
			tween(Dropdown,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
			Dropdown.BackgroundTransparency=1
			Dropdown.UIStroke.Transparency=1
			Dropdown.Title.TextTransparency=1
			Dropdown.Size=UDim2.new(1,-10,0,45)
			tween(Dropdown,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			tween(Dropdown.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0})
			tween(Dropdown.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
			for _,ununusedoption in ipairs(Dropdown.List:GetChildren()) do if ununusedoption.ClassName=="Frame" and ununusedoption.Name~="Placeholder" then ununusedoption:Destroy() end end
			Dropdown.Toggle.Rotation=180
			Dropdown.Interact.MouseButton1Click:Connect(function()
				tween(Dropdown,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
				tween(Dropdown.UIStroke,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{Transparency=1})
				task.wait(0.1)
				tween(Dropdown,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
				tween(Dropdown.UIStroke,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{Transparency=0})
				if Dropdown.List.Visible then
					if Debounce then return end
					Debounce=true
					tween(Dropdown,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,-10,0,45)})
					for i,v in ipairs(Dropdown.List:GetChildren()) do
						if v.ClassName=="Frame" and v.Name~="Placeholder" then
							tween(v,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
							tween(v.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=1})
							tween(v.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=1})
						end
					end
					tween(Dropdown.List,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ScrollBarImageTransparency=1})
					tween(Dropdown.Toggle,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Rotation=180})	
					task.wait(0.35)
					Dropdown.List.Visible=false
					Debounce=false
				else
					tween(Dropdown,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,-10,0,180)})
					Dropdown.List.Visible=true
					tween(Dropdown.List,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ScrollBarImageTransparency=0.7})
					tween(Dropdown.Toggle,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Rotation=0})	
					for i,v in ipairs(Dropdown.List:GetChildren()) do
						if v.ClassName=="Frame" and v.Name~="Placeholder" then
							if v.Name~=Dropdown.Selected.Text then
								tween(v.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=0})
							end
							tween(v,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
							tween(v.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=0})
						end
					end
				end
			end)
			Dropdown.MouseEnter:Connect(function()
				if not Dropdown.List.Visible then
					tween(Dropdown,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
				end
			end)
			Dropdown.MouseLeave:Connect(function()
				tween(Dropdown,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
			end)
			local function SetDropdownOptions()
				for i,v in ipairs(DropdownInfo.Options) do
					local DropdownOption=Elements.Template.Dropdown.List.Template:Clone()
					DropdownOption.Name=v
					DropdownOption.Title.Text=v
					DropdownOption.Parent=Dropdown.List
					DropdownOption.Visible=true
					DropdownOption.BackgroundTransparency=1
					DropdownOption.UIStroke.Transparency=1
					DropdownOption.Title.TextTransparency=1
					DropdownOption.Interact.ZIndex=50
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
							tween(DropdownOption.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=1})
							tween(DropdownOption,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.DropdownSelected})
							Debounce=true
						end
						local Success,Response=pcall(function()
							if DropdownInfo.Callback then DropdownInfo.Callback(DropdownInfo.Option) end
						end)
						if not Success then
							tween(Dropdown,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
							tween(Dropdown.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
							Dropdown.Title.Text="Callback Error"
							print("Rayfield | "..DropdownInfo.Name.." Callback Error " ..tostring(Response))
							warn('Check docs.sirius.menu for help with Rayfield specific development.')
							task.wait(0.5)
							Dropdown.Title.Text=DropdownInfo.Name
							tween(Dropdown,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
							tween(Dropdown.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
						end
						for _,droption in ipairs(Dropdown.List:GetChildren()) do if droption.ClassName=="Frame" and droption.Name~="Placeholder" and not table.find(DropdownInfo.Option,droption.Name) then tween(droption,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.DropdownUnselected}) end end
						if not DropdownInfo.MultipleOptions then
							task.wait(0.1)
							tween(Dropdown,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,-10,0,45)})
							for _,DropdownOpt in ipairs(Dropdown.List:GetChildren()) do
								if DropdownOpt.ClassName=="Frame" and DropdownOpt.Name~="Placeholder" then
									tween(DropdownOpt,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundTransparency=1})
									tween(DropdownOpt.UIStroke,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{Transparency=1})
									tween(DropdownOpt.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=1})
								end
							end
							tween(Dropdown.List,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{ScrollBarImageTransparency=1})
							tween(Dropdown.Toggle,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Rotation=180})	
							task.wait(0.35)
							Dropdown.List.Visible=false
						end
						Debounce=false
						if not DropdownInfo.Ext then
							SaveConfiguration()
						end
					end)
					Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
						DropdownOption.UIStroke.Color=SelectedTheme.ElementStroke
					end)
				end
			end
			SetDropdownOptions()
			for _,droption in ipairs(Dropdown.List:GetChildren()) do if droption.ClassName=="Frame" and droption.Name~="Placeholder" then if not table.find(DropdownInfo.Option,droption.Name) then droption.BackgroundColor3=SelectedTheme.DropdownUnselected else droption.BackgroundColor3=SelectedTheme.DropdownSelected end Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(function() if not table.find(DropdownInfo.Option,droption.Name) then droption.BackgroundColor3=SelectedTheme.DropdownUnselected else droption.BackgroundColor3=SelectedTheme.DropdownSelected end end) end end
			function DropdownInfo:Set(NewOption)
				DropdownInfo.Option=NewOption
				if typeof(DropdownInfo.Option)=="string" then
					DropdownInfo.Option={DropdownInfo.Option}
				end
				if not DropdownInfo.MultipleOptions then
					DropdownInfo.Option={DropdownInfo.Option[1]}
				end
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
				local Success,Response=pcall(function()
					if DropdownInfo.Callback then DropdownInfo.Callback(NewOption) end
				end)
				if not Success then
					tween(Dropdown,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
					tween(Dropdown.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					Dropdown.Title.Text="Callback Error"
					print("Rayfield | "..DropdownInfo.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Dropdown.Title.Text=DropdownInfo.Name
					tween(Dropdown,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					tween(Dropdown.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
				end
				for _,droption in ipairs(Dropdown.List:GetChildren()) do
					if droption.ClassName=="Frame" and droption.Name~="Placeholder" then
						if not table.find(DropdownInfo.Option,droption.Name) then
							droption.BackgroundColor3=SelectedTheme.DropdownUnselected
						else
							droption.BackgroundColor3=SelectedTheme.DropdownSelected
						end
					end
				end
				--SaveConfiguration()
			end
			function DropdownInfo:Refresh(optionsTable) -- updates a dropdown with new options from optionsTable
				DropdownInfo.Options=optionsTable
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
			if windowInfo.ConfigurationSaving then if windowInfo.ConfigurationSaving.Enabled and DropdownInfo.Flag then Library.Flags[DropdownInfo.Flag]=DropdownInfo end end
			Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Dropdown.Toggle.ImageColor3=SelectedTheme.TextColor tween(Dropdown,TweenInfo.new(0.4,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
			end)
			return DropdownInfo
		end

		-- Keybind
		function Tab:CreateKeybind(KeybindInfo)
			KeybindInfo=type(KeybindInfo)=="table" and KeybindInfo or {}
			if KeybindInfo.CurrentKeybind then KeybindInfo.Keybind=KeybindInfo.CurrentKeybind KeybindInfo.CurrentKeybind=nil end
			KeybindInfo=PackTab(KeybindInfo,DefaultData.Keybind,true)
			local CheckingForKey=false
			local Keybind=Elements.Template.Keybind:Clone()
			KeybindInfo.Template=Keybind
			TabPrivate.Order+=1
			Keybind.LayoutOrder=TabPrivate.Order
			Keybind.Name=KeybindInfo.Name
			Keybind.Title.Text=KeybindInfo.Name
			Keybind.Visible=true
			Keybind.Parent=TabPage
			Keybind.BackgroundTransparency=1
			Keybind.UIStroke.Transparency=1
			Keybind.Title.TextTransparency=1
			Keybind.KeybindFrame.BackgroundColor3=SelectedTheme.InputBackground
			Keybind.KeybindFrame.UIStroke.Color=SelectedTheme.InputStroke
			tween(Keybind,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			tween(Keybind.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0})
			tween(Keybind.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
			Keybind.KeybindFrame.KeybindBox.Text=KeybindInfo.Keybind
			Keybind.KeybindFrame.Size=UDim2.new(0,Keybind.KeybindFrame.KeybindBox.TextBounds.X+24,0,30)
			Keybind.KeybindFrame.KeybindBox.Focused:Connect(function()
				CheckingForKey=true Keybind.KeybindFrame.KeybindBox.Text=""
			end)
			Keybind.KeybindFrame.KeybindBox.FocusLost:Connect(function()
				CheckingForKey=false
				local inputText=Keybind.KeybindFrame.KeybindBox.Text
				if inputText==nil or inputText=="" then
					Keybind.KeybindFrame.KeybindBox.Text=KeybindInfo.Keybind
					if not KeybindInfo.Ext then SaveConfiguration() end
				end
			end)
			Keybind.MouseEnter:Connect(function()
				tween(Keybind,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
			end)
			Keybind.MouseLeave:Connect(function()
				tween(Keybind,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
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
						if not KeybindInfo.Ext then SaveConfiguration() end
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
							tween(Keybind,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
							tween(Keybind.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
							Keybind.Title.Text="Callback Error"
							print("Rayfield | "..KeybindInfo.Name.." Callback Error " ..tostring(Response))
							warn('Check docs.sirius.menu for help with Rayfield specific development.')
							task.wait(0.5)
							Keybind.Title.Text=KeybindInfo.Name
							tween(Keybind,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
							tween(Keybind.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
						end
					else
						task.wait(0.25)
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
			table.insert(keybindConnections,keybindInputBegan)
			Keybind.KeybindFrame.KeybindBox:GetPropertyChangedSignal("Text"):Connect(function()
				tween(Keybind.KeybindFrame,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Size=UDim2.new(0,Keybind.KeybindFrame.KeybindBox.TextBounds.X+24,0,30)})
			end)
			function KeybindInfo:Set(NewKeybind)
				Keybind.KeybindFrame.KeybindBox.Text=tostring(NewKeybind)
				KeybindInfo.Keybind=tostring(NewKeybind)
				KeybindInfo.Value=tostring(NewKeybind)
				if KeybindInfo.CurrentKeybind then KeybindInfo.Keybind=KeybindInfo.CurrentKeybind KeybindInfo.CurrentKeybind=nil end
				if KeybindInfo.Value then KeybindInfo.Keybind=KeybindInfo.Value KeybindInfo.Value=nil end
				Keybind.KeybindFrame.KeybindBox:ReleaseFocus()
				if not KeybindInfo.Ext then SaveConfiguration() end
				if KeybindInfo.CallOnChange then callSafely(KeybindInfo.Callback,tostring(NewKeybind)) end
			end
			if windowInfo.ConfigurationSaving and windowInfo.ConfigurationSaving.Enabled and KeybindInfo.Flag then
				Library.Flags[KeybindInfo.Flag]=KeybindInfo
			end
			Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Keybind.KeybindFrame.BackgroundColor3=SelectedTheme.InputBackground
				Keybind.KeybindFrame.UIStroke.Color=SelectedTheme.InputStroke
			end)
			return KeybindInfo
		end

		-- Toggle
		function Tab:CreateToggle(ToggleInfo)
			ToggleInfo=PackTab(ToggleInfo,DefaultData.Toggle)
			local Toggle=Elements.Template.Toggle:Clone()
			ToggleInfo.Template=Toggle
			TabPrivate.Order+=1
			Toggle.LayoutOrder=TabPrivate.Order
			Toggle.Name=ToggleInfo.Name
			Toggle.Title.Text=ToggleInfo.Name
			Toggle.Visible=true
			Toggle.Parent=TabPage
			Toggle.BackgroundTransparency=1
			Toggle.UIStroke.Transparency=1
			Toggle.Title.TextTransparency=1
			Toggle.Switch.BackgroundColor3=SelectedTheme.ToggleBackground
			if SelectedTheme~=Library.Theme.Default then
				Toggle.Switch.Shadow.Visible=false
			end
			tween(Toggle,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
			tween(Toggle.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0})
			tween(Toggle.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
			if ToggleInfo.Value==true then
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
			Toggle.MouseEnter:Connect(function()
				tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
			end)
			Toggle.MouseLeave:Connect(function()
				tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
			end)
			Toggle.Interact.MouseButton1Click:Connect(function()
				local NewValue=ToggleInfo.Value
				if NewValue==true then
					NewValue=false
					ToggleInfo.Value=NewValue
					tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
					tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					tween(Toggle.Switch.Indicator,TweenInfo.new(0.45,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(1,-40,0.5,0)})
					tween(Toggle.Switch.Indicator.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleDisabledStroke})
					tween(Toggle.Switch.Indicator,TweenInfo.new(0.8,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{BackgroundColor3=SelectedTheme.ToggleDisabled})
					tween(Toggle.Switch.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleDisabledOuterStroke})
					tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})	
				else
					NewValue=true
					ToggleInfo.Value=NewValue
					tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
					tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					tween(Toggle.Switch.Indicator,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(1,-20,0.5,0)})
					tween(Toggle.Switch.Indicator.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleEnabledStroke})
					tween(Toggle.Switch.Indicator,TweenInfo.new(0.8,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{BackgroundColor3=SelectedTheme.ToggleEnabled})
					tween(Toggle.Switch.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleEnabledOuterStroke})
					tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})		
				end
				local Success,Response=pcall(ToggleInfo.Callback,NewValue)
				if not Success then
					tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
					tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					Toggle.Title.Text="Callback Error"
					print("Rayfield | "..ToggleInfo.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Toggle.Title.Text=ToggleInfo.Name
					tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
				end
				if not ToggleInfo.Ext then SaveConfiguration() end
			end)
			function ToggleInfo:Replace(NewValue)
				if NewValue then NewValue=true else NewValue=false end
				if ToggleInfo.Value~=NewValue then
					ToggleInfo.Value=NewValue
					if NewValue==true then
						tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
						tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
						tween(Toggle.Switch.Indicator,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(1,-20,0.5,0)})
						tween(Toggle.Switch.Indicator,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,12,0,12)})
						tween(Toggle.Switch.Indicator.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleEnabledStroke})
						tween(Toggle.Switch.Indicator,TweenInfo.new(0.8,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{BackgroundColor3=SelectedTheme.ToggleEnabled})
						tween(Toggle.Switch.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleEnabledOuterStroke})
						tween(Toggle.Switch.Indicator,TweenInfo.new(0.45,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,17,0,17)})	
						tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
						tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})	
					else
						tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
						tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
						tween(Toggle.Switch.Indicator,TweenInfo.new(0.45,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(1,-40,0.5,0)})
						tween(Toggle.Switch.Indicator,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,12,0,12)})
						tween(Toggle.Switch.Indicator.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleDisabledStroke})
						tween(Toggle.Switch.Indicator,TweenInfo.new(0.8,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{BackgroundColor3=SelectedTheme.ToggleDisabled})
						tween(Toggle.Switch.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleDisabledOuterStroke})
						tween(Toggle.Switch.Indicator,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,17,0,17)})
						tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
						tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})	
					end
					if not ToggleInfo.Ext then SaveConfiguration() end
				end
			end
			function ToggleInfo:Set(NewValue)
				if NewValue then NewValue=true else NewValue=false end
				ToggleInfo.Value=NewValue
				if NewValue==true then
					tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
					tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					tween(Toggle.Switch.Indicator,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(1,-20,0.5,0)})
					tween(Toggle.Switch.Indicator,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,12,0,12)})
					tween(Toggle.Switch.Indicator.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleEnabledStroke})
					tween(Toggle.Switch.Indicator,TweenInfo.new(0.8,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{BackgroundColor3=SelectedTheme.ToggleEnabled})
					tween(Toggle.Switch.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleEnabledOuterStroke})
					tween(Toggle.Switch.Indicator,TweenInfo.new(0.45,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,17,0,17)})	
					tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})	
				else
					tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
					tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					tween(Toggle.Switch.Indicator,TweenInfo.new(0.45,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(1,-40,0.5,0)})
					tween(Toggle.Switch.Indicator,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,12,0,12)})
					tween(Toggle.Switch.Indicator.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleDisabledStroke})
					tween(Toggle.Switch.Indicator,TweenInfo.new(0.8,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{BackgroundColor3=SelectedTheme.ToggleDisabled})
					tween(Toggle.Switch.UIStroke,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Color=SelectedTheme.ToggleDisabledOuterStroke})
					tween(Toggle.Switch.Indicator,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,17,0,17)})
					tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})	
				end
				local Success,Response=pcall(ToggleInfo.Callback,ToggleInfo.Value)
				if not Success then
					tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
					tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
					Toggle.Title.Text="Callback Error"
					print("Rayfield | "..ToggleInfo.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Toggle.Title.Text=ToggleInfo.Name
					tween(Toggle,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
					tween(Toggle.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
				end
				if not ToggleInfo.Ext then SaveConfiguration() end
			end
			if not ToggleInfo.Ext and windowInfo.ConfigurationSaving and windowInfo.ConfigurationSaving.Enabled and ToggleInfo.Flag then
				Library.Flags[ToggleInfo.Flag]=ToggleInfo
			end
			Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Toggle.Switch.BackgroundColor3=SelectedTheme.ToggleBackground
				if SelectedTheme~=Library.Theme.Default then
					Toggle.Switch.Shadow.Visible=false
				end
				task.wait()
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
			return ToggleInfo
		end

		-- Slider
		function Tab:CreateSlider(SliderInfo) -- V1 by Rayfield, V2, by Paazlis
			SliderInfo=type(SliderInfo)=="table" and SliderInfo or {}
			if SliderInfo.CurrentValue then SliderInfo.Value=SliderInfo.CurrentValue SliderInfo.CurrentValue=nil end
			SliderInfo=PackTab(SliderInfo,DefaultData.Slider,true)
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
			TabPrivate.Order+=1
			local ApplyTextLabel=function(label,value)
				local valueStr,suffix=Strs.ToNumberString(value),SliderInfo.Suffix
				if not Strs.IsEmpty(suffix) then label.Text=valueStr.." "..suffix else label.Text=valueStr end
			end
			if SliderInfo.Version==2 and Elements.Template:FindFirstChild("SliderPro")~=nil then
				Slider=Elements.Template.SliderPro:Clone()
				SliderInfo.Template=Slider
				Slider.LayoutOrder=TabPrivate.Order
				Slider.Name=SliderInfo.Name
				Slider.Title.Text=SliderInfo.Name
				Slider.Parent=TabPage
				local SliderPlus,SliderMinus,SliderIndicator,SliderTextBox=Slider:FindFirstChild("Plus"),Slider:FindFirstChild("Minus"),Slider:FindFirstChild("Indicator"),Slider:FindFirstChild("TextBox")
				local Bars,List={},{}
				SliderTextBox.Text=""
				SliderIndicator.Bar.Visible=false
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
						if SliderInfo.Reverse then
							nextValue=min-(max-min)*(i/total)
						else
							nextValue=min+(max-min)*(i/total)
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
				table.insert(keybindConnections,sliderInputEnded)
				function SliderInfo:Set(value,index)
					if SliderInfo.Index~=index then
						SliderInfo.Index=index
						local nextValue=value or List[index]
						SliderInfo.Value=nextValue
						UpdateMinusOrPlus()
						ApplyTextLabel(Slider.TextBox,nextValue)
						callSafely(SliderInfo.Callback,nextValue)
					end
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
					callSafely(SliderInfo.Callback,NewValue)
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
						callSafely(SliderInfo.Callback,NewValue)
					end
				end)
				SliderTextBox.FocusLost:Connect(function(enter)
					if not enter then return end 
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
						callSafely(SliderInfo.Callback,NewValue)
					end
				end)
				if windowInfo.ConfigurationSaving and windowInfo.ConfigurationSaving.Enabled and SliderInfo.Flag then
					Library.Flags[SliderInfo.Flag]=SliderInfo
				end
				Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(ApplyTheme)
			else
				Slider=Elements.Template.Slider:Clone()
				SliderInfo.Template=Slider
				Slider.LayoutOrder=TabPrivate.Order
				Slider.Name=SliderInfo.Name
				Slider.Title.Text=SliderInfo.Name
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
				tween(Slider,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
				tween(Slider.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0})
				tween(Slider.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0})	
				Slider.Main.Progress.Size=UDim2.new(0,Slider.Main.AbsoluteSize.X * ((SliderInfo.Value-SliderInfo.Range[1]) / (SliderInfo.Range[2]-SliderInfo.Range[1]))>5 and Slider.Main.AbsoluteSize.X * ((SliderInfo.Value-SliderInfo.Range[1]) / (SliderInfo.Range[2]-SliderInfo.Range[1])) or 5,1,0)
				ApplyTextLabel(Slider.Main.Information,SliderInfo.Value)
				Slider.MouseEnter:Connect(function()
					tween(Slider,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackgroundHover})
				end)
				Slider.MouseLeave:Connect(function()
					tween(Slider,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
				end)
				Slider.Main.Interact.InputBegan:Connect(function(Input)
					if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then 
						tween(Slider.Main.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
						tween(Slider.Main.Progress.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
						SLDragging=true 
					end 
				end)
				Slider.Main.Interact.InputEnded:Connect(function(Input) 
					if Input.UserInputType==Enum.UserInputType.MouseButton1 or Input.UserInputType==Enum.UserInputType.Touch then 
						tween(Slider.Main.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0.4})
						tween(Slider.Main.Progress.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0.3})
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
							tween(Slider.Main.Progress,TweenInfo.new(0.45,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Size=UDim2.new(0,Current-Slider.Main.AbsolutePosition.X,1,0)})
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
									tween(Slider,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
									tween(Slider.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
									Slider.Title.Text="Callback Error"
									print("Rayfield | "..SliderInfo.Name.." Callback Error " ..tostring(Response))
									warn('Check docs.sirius.menu for help with Rayfield specific development.')
									task.wait(0.5)
									Slider.Title.Text=SliderInfo.Name
									tween(Slider,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
									tween(Slider.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
								end

								if not SliderInfo.Ext then
									SaveConfiguration()
								end
							end
						else
							tween(Slider.Main.Progress,TweenInfo.new(0.3,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Size=UDim2.new(0,Location-Slider.Main.AbsolutePosition.X>5 and Location-Slider.Main.AbsolutePosition.X or 5,1,0)})
							Loop:Disconnect()
						end
					end)
				end)
				function SliderInfo:Set(NewValue)
					NewValue=math.clamp(NewValue,SliderInfo.Range[1],SliderInfo.Range[2])
					tween(Slider.Main.Progress,TweenInfo.new(0.45,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Size=UDim2.new(0,Slider.Main.AbsoluteSize.X * ((NewValue-SliderInfo.Range[1]) / (SliderInfo.Range[2]-SliderInfo.Range[1]))>5 and Slider.Main.AbsoluteSize.X * ((NewValue-SliderInfo.Range[1]) / (SliderInfo.Range[2]-SliderInfo.Range[1])) or 5,1,0)})
					Slider.Main.Information.Text=tostring(NewValue) .. " " .. (SliderInfo.Suffix or "")
					local Success,Response=pcall(SliderInfo.Callback,NewValue)
					if not Success then
						tween(Slider,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=Color3.fromRGB(85,0,0)})
						tween(Slider.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=1})
						Slider.Title.Text="Callback Error"
						print("Rayfield | "..SliderInfo.Name.." Callback Error " ..tostring(Response))
						warn('Check docs.sirius.menu for help with Rayfield specific development.')
						task.wait(0.5)
						Slider.Title.Text=SliderInfo.Name
						tween(Slider,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.ElementBackground})
						tween(Slider.UIStroke,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{Transparency=0})
					end
					SliderInfo.Value=NewValue
					if not SliderInfo.Ext then
						SaveConfiguration()
					end
				end
				if windowInfo.ConfigurationSaving and windowInfo.ConfigurationSaving.Enabled and SliderInfo.Flag then
					Library.Flags[SliderInfo.Flag]=SliderInfo
				end
				Rayfield.Main:GetPropertyChangedSignal("BackgroundColor3"):Connect(ApplyTheme)
			end
			return SliderInfo
		end

		-- Select
		function Tab:CreateSelect(SelectInfo)
			SelectInfo=type(SelectInfo)=="table" and SelectInfo or {}
			local DefaultInfo={Type="Select",Name="Select Here",Active=false,Value="None",Callback=function() end,Set=function() end}
			for key,value in pairs(DefaultInfo) do if SelectInfo[key]==nil then SelectInfo[key]=value end end
			if not Elements:FindFirstChild("Template") or not Elements.Template:FindFirstChild("Select") then warn("Rayfield | Select not found.") return SelectInfo end
			local TurnSysmbols={[true]="■",[false]="□"}
			local Select=Elements.Template.Select:Clone()
			SelectInfo.Template=Select
			TabPrivate.Order+=1
			Select.LayoutOrder=TabPrivate.Order
			Select.Name=SelectInfo.Name
			Select.Title.Text=SelectInfo.Name
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
					callSafely(SelectInfo.Callback,value)
				end
			end
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
			return SelectInfo
		end

		-- PlayerPicker
		function Tab:CreatePlayerPicker(PlayerPickerInfo) -- by HowToRoblox
			PlayerPickerInfo=type(PlayerPickerInfo)=="table" and PlayerPickerInfo or {}
			local DefaultInfo={Type="PlayerPicker",Name="Player Picker Here",Observe=function() return function() end end,Value="None",Callback=function() end,Set=function() end,View=function() end,Unview=function() end}
			for key,value in pairs(DefaultInfo) do if PlayerPickerInfo[key]==nil then PlayerPickerInfo[key]=value end end
			if not Elements:FindFirstChild("Template") or not Elements.Template:FindFirstChild("PlayerPicker") then warn("Rayfield | PlayerPicker not found.")  return PlayerPickerInfo end
			local success,message=pcall(function()
				if TabPrivate.FirstPlayerPicker then warn("Rayfield | You can only have one PlayerPicker in a single tab") return end
				TabPrivate.FirstPlayerPicker=true
				if not UserService then UserService=callSafely(getService,"UserService") end
				local PlayerCache={}
				local PlayerPicker=Elements.Template.PlayerPicker:Clone()
				PlayerPickerInfo.Template=PlayerPicker
				TabPrivate.Order+=1
				PlayerPicker.LayoutOrder=TabPrivate.Order
				local PlayerInfo=PlayerPicker.Info
				local PlayerLabel=PlayerInfo.List.Label
				local PlayerTemplate=PlayerPicker.List.Template
				local PlayerViews=PlayerPicker.Views
				PlayerLabel.Visible=false
				PlayerTemplate.Visible=false
				local PlayerTitles={}
				local ThisPlayer=Players.LocalPlayer
				local PlayerInstance=nil
				local SelectPlayerIndex,SelectPlayerInfo,SelectedPlayerTemplate,ViewEnabled,ViewInstance,ViewCharAddedConnection=1,nil,nil,false,nil,nil
				for i,v in pairs({{"Name","@Roblox","NameLabel"},{"Display","Roblox","DisplayLabel"},{"ID","1","IdLabel"},{"Age","Inf","AgeLabel"},{"In Game","No","InGameLabel"}}) do
					local newLabel:TextLabel=PlayerLabel:Clone()
					newLabel.Name=v[3]
					newLabel.LayoutOrder=i
					newLabel.Visible=true
					newLabel.Text=v[1]..": "..v[2]
					table.insert(PlayerTitles,newLabel)
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
						Name=userInfo.Name or 'Roblox',
						DisplayName=userInfo.DisplayName or 'Roblox',
						UserId=userId,
						Icon=userInfo.Icon,
						Age=userInfo.Age or 0,
						InServer=userInfo.InServer
					}
					if userInfo.Value~=nil and PlayerInstance~=userInfo.Value  then 
						PlayerInstance=userInfo.Value 
						PlayerPickerInfo.Value=PlayerInstance 
						newContext.IsViewing=ViewInstance~=nil and ViewInstance==PlayerInstance
						callSafely(PlayerPickerInfo.Callback,PlayerInstance,newContext)
					end
					pcall(function()
						local playerInfoFrame=PlayerInfo.List
						playerInfoFrame.Visible=false
						playerInfoFrame.NameLabel.Text='Name: @'..newContext.Name
						playerInfoFrame.DisplayLabel.Text='Display: '..newContext.DisplayName
						playerInfoFrame.IdLabel.Text='ID: '..tostring(userId)
						playerInfoFrame.AgeLabel.Text='Age: '..tostring(newContext.Age)
						playerInfoFrame.InGameLabel.Text='In Game: '..(userInfo.InServer and 'Yes' or 'No')
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
					task.wait(1)
					if player and player.Parent then
						local index=#PlayerCache+1
						PlayerCache[index]={["Index"]=index,["Value"]=player,["UserId"]=player.UserId,["Name"]=player.Name,["DisplayName"]=player.DisplayName,["Age"]=player.AccountAge}
						local cleanAddPlayer=AddPlayerFrame(player,index)
						local sortThread=task.defer(function()
							table.sort(PlayerCache,function(a,b) if a~=nil and b~=nil and a.Age~=nil and b.Age~=nil then return a.Age<b.Age else return false end end)
							for i,v in ipairs(PlayerCache) do if player and player.Parent then if v and v.Template and v.Template.Parent then v.Template.LayoutOrder=i end else break end end
						end)
						local onPlayerRemoving=callSafely(PlayerPickerInfo.Observe,player)
						return function()
							local wasCancelled=nil if coroutine.running()~=sortThread then wasCancelled=pcall(function() task.cancel(sortThread) end) end if not wasCancelled then local toClean=sortThread task.defer(function() task.cancel(toClean) end) end
							cleanAddPlayer()
							callSafely(onPlayerRemoving,player)
						end
					end
				end)
				PlayerPicker.Destroying:Connect(function()
					cleanObservePlayer() table.clear(PlayerCache) table.clear(PlayerTitles)
				end)
			end)
			if not success then warn("Rayfield | Fatal Error for PlayerPicker,",message) end
			return PlayerPickerInfo
		end

		-- ThemeButton
		function Tab:CreateThemeButton(ThemeButtonInfo) 
			if TabPrivate.FirstThemeButton then warn("Rayfield | You can only have one ThemeButton in a single tab") return end
			TabPrivate.FirstThemeButton=true
			ThemeButtonInfo=type(ThemeButtonInfo)=="table" and ThemeButtonInfo or {}
			ThemeButtonInfo.Type="ThemeButton"
			local list,index={},1
			for k,v in pairs(Library.Theme) do table.insert(list,k) end
			for i,v in ipairs(list) do local newTheme=Library.Theme[v] if newTheme and SelectedTheme==newTheme then index=i break end end
			ThemeButtonInfo.Value=list[index]
			local ButtonInfo
			ButtonInfo=Tab:CreateButton({
				Name="Change Theme: "..list[index],
				Callback=function()
					index=index+1
					if index>#list then index=1 end
					Window:ModifyTheme(list[index])
					ButtonInfo:Set(`Change Theme: {list[index]}`)
					ThemeButtonInfo.Value=list[index]
					if not ThemeButtonInfo.Ext then SaveConfiguration() end
					table.clear(list)
					for k,v in pairs(Library.Theme) do table.insert(list,k) end
				end,
			})
			function ThemeButtonInfo:Set(NewTheme)
				if type(NewTheme)=="string" then
					ThemeButtonInfo.Value=NewTheme
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
			if windowInfo.ConfigurationSaving and windowInfo.ConfigurationSaving.Enabled and ThemeButtonInfo.Flag then
				Library.Flags[ThemeButtonInfo.Flag]=ThemeButtonInfo
			end
			return ThemeButtonInfo
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
			["ThemeButton"]=Tab.CreateThemeButton,
			["Expand"]=Tab.CreateExpand,
			["Selector"]=Tab.CreateSelector,
		}

		function Tab:AddContext(ContextInfo)
			ContextInfo=type(ContextInfo)=="table" and ContextInfo or {}
			local TypeName=ContextInfo.Type
			local TabFunc=ListOfTab[ContextInfo.Type or ""]
			local MainInfo={}
			if TabFunc~=nil then
				if TypeName=="Label" then
					MainInfo=TabFunc(Tab,ContextInfo.Name or ContextInfo.Text,ContextInfo.Icon,ContextInfo.Color,ContextInfo.IgnoreTheme)
				elseif TypeName=="Section" then
					MainInfo=TabFunc(Tab,ContextInfo.Name or ContextInfo.Text)
				else
					MainInfo=TabFunc(Tab,ContextInfo)
				end
			else
				warn("Rayfield | UI not found by",TypeName)
			end
			if MainInfo~=nil then
				local ContextValue={}
				return setmetatable(ContextValue,{
					__index=function(This,Key)
						return MainInfo[Key]
					end,
					__newindex=function(This,Key,Value)
						if Key=="Parent" then
							if Value~=nil and type(Value)=="table" and getmetatable(Value) and type(Value.List)=="table" then
								if MainInfo.Parent~=Value then
									if not MainInfo.Template then return end
									MainInfo.Parent=Value
									MainInfo.Template.Visible=if Value.Active then true else false
									table.insert(Value.List,This)
								end
							else
								local lastParent=MainInfo.Parent
								MainInfo.Parent=Value
								if lastParent and type(lastParent)=="table" and getmetatable(Value) and type(Value.List)=="table" then
									local index=table.find(lastParent.List,This)
									if index then
										table.remove(lastParent.List,index)
										if MainInfo.Parent==This then
											MainInfo.Parent=true
										end
									end
									lastParent=nil
								end
							end
						else
							local originValue=MainInfo[Key]
							if type(originValue)~="function" then
								MainInfo[Key]=Value
							end
						end
					end
				})
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
	task.wait(1.1)
	tween(Main,TweenInfo.new(0.7,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut),{Size=UDim2.new(0,390,0,90)})
	task.wait(0.3)
	tween(LoadingFrame.Title,TweenInfo.new(0.2,Enum.EasingStyle.Exponential),{TextTransparency=1})
	tween(LoadingFrame.Subtitle,TweenInfo.new(0.2,Enum.EasingStyle.Exponential),{TextTransparency=1})
	tween(LoadingFrame.Version,TweenInfo.new(0.2,Enum.EasingStyle.Exponential),{TextTransparency=1})
	task.wait(0.1)
	tween(Main,TweenInfo.new(0.6,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),{Size=useMobileSizing and UDim2.new(0,500,0,275) or UDim2.new(0,500,0,475)})
	tween(Main.Shadow.Image,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{ImageTransparency=0.6})
	Topbar.BackgroundTransparency=1
	Topbar.Divider.Size=UDim2.new(0,0,0,1)
	Topbar.Divider.BackgroundColor3=SelectedTheme.ElementStroke
	Topbar.CornerRepair.BackgroundTransparency=1
	Topbar.Title.TextTransparency=1
	Topbar.Search.ImageTransparency=1
	if Topbar:FindFirstChild('Settings') then
		Topbar.Settings.ImageTransparency=1
	end
	Topbar.ChangeSize.ImageTransparency=1
	Topbar.Hide.ImageTransparency=1


	task.wait(0.5)
	Topbar.Visible=true
	tween(Topbar,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	tween(Topbar.CornerRepair,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0})
	task.wait(0.1)
	tween(Topbar.Divider,TweenInfo.new(1,Enum.EasingStyle.Exponential),{Size=UDim2.new(1,0,0,1)})
	tween(Topbar.Title,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{TextTransparency=0})
	task.wait(0.05)
	tween(Topbar.Search,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{ImageTransparency=0.8})
	task.wait(0.05)
	if Topbar:FindFirstChild('Settings') then
		tween(Topbar.Settings,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{ImageTransparency=0.8})
		task.wait(0.05)
	end
	tween(Topbar.ChangeSize,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{ImageTransparency=0.8})
	task.wait(0.05)
	tween(Topbar.Hide,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{ImageTransparency=0.8})
	task.wait(0.3)

	if dragBar then
		tween(dragBarCosmetic,TweenInfo.new(0.6,Enum.EasingStyle.Exponential),{BackgroundTransparency=0.7})
	end

	function Window:ModifyTheme(NewTheme)
		local success=pcall(ChangeTheme,NewTheme)
		if not success then
			Library:Notify({Title='Unable to Change Theme',Content='We are unable find a theme on file.',Image=4400704299})
		else
			Library:Notify({Title='Theme Changed',Content='Successfully changed theme to '..(typeof(NewTheme)=='string' and NewTheme or 'Custom Theme')..'.',Image=4483362748})
		end
	end

	local success,result=pcall(function()
		createSettings(Window)
	end)

	if not success then warn('Rayfield had an issue creating settings.') end

	-- Report after createSettings so loadSettings() has run and usageAnalytics reflects the user's saved preference
	if reporter and getSetting("System","usageAnalytics") then
		local themeName="Default"
		local newTheme=windowInfo.Theme
		if newTheme then
			if type(newTheme)=="string" then
				themeName=newTheme
			elseif type(newTheme)=="table" then
				themeName="Custom"
			end
		end

		local discordInvite=nil
		if discordInfo and discordInfo.Enabled and discordInfo.Invite and discordInfo.Invite~="" then
			local raw=tostring(discordInfo.Invite)
			-- Normalize: strip URL prefixes to extract just the invite code
			discordInvite=(raw:match("discord%.gg/([%w%-]+)") or raw:match("discord%.com/invite/([%w%-]+)") or raw):sub(1,32)
		end

		local sampleSend=false

		-- Random Sampling Test
		if not windowInfo.ScriptID and math.random()>0.4 then
			sampleSend=true
		end

		----if Settings.ScriptID then
		--reporter:windowCreated({
		--	script_name       =Settings.Name or "Unknown",
		--	script_version    =Release,
		--	interface_version =InterfaceBuild,
		--	theme             =themeName,
		--	is_mobile         =useMobileSizing and true or false,
		--	has_key_system    =Settings.KeySystem and true or false,
		--	discord_invite    =discordInvite,
		--	config_saving     =(Settings.ConfigurationSaving and Settings.ConfigurationSaving.Enabled) and true or false,
		--	script_id         =Settings.ScriptID or sampleSend and 'sid_tzfyxawonjx9' or nil,
		--	verification_token=Settings.VerificationToken,
		--})
		--end
	end

	return Window
end

local function setVisibility(visibility: boolean,notify: boolean?)
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
	setVisibility(visibility,false)
end

function Library:IsVisible(): boolean
	return not Hidden
end

local hideHotkeyConnection -- Has to be initialized here since the connection is made later in the script
function Library:Destroy()
	rayfieldDestroyed=true
	if hideHotkeyConnection then
		hideHotkeyConnection:Disconnect()
	end
	for _,connection in keybindConnections do
		connection:Disconnect()
	end
	Rayfield:Destroy()
end

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
	if #Main.Search.Input.Text==0 and searchOpen then
		task.wait(0.12)
		closeSearch()
	end
end)

Topbar.Search.MouseButton1Click:Connect(function()
	task.spawn(function()
		if searchOpen then
			closeSearch()
		else
			openSearch()
		end
	end)
end)

if Topbar:FindFirstChild('Settings') then
	Topbar.Settings.MouseButton1Click:Connect(function()
		task.spawn(function()
			for _,OtherTabButton in ipairs(TabList:GetChildren()) do
				if OtherTabButton.Name~="Template" and OtherTabButton.ClassName=="Frame" and OtherTabButton.Name~="Placeholder" then
					tween(OtherTabButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundColor3=SelectedTheme.TabBackground})
					tween(OtherTabButton.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextColor3=SelectedTheme.TabTextColor})
					tween(OtherTabButton.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageColor3=SelectedTheme.TabTextColor})
					tween(OtherTabButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{BackgroundTransparency=0.7})
					tween(OtherTabButton.Title,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{TextTransparency=0.2})
					tween(OtherTabButton.Image,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0.2})
					tween(OtherTabButton.UIStroke,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{Transparency=0.5})
				end
			end

			Elements.UIPageLayout:JumpTo(Elements['Rayfield Settings'])
		end)
	end)

end

Topbar.Hide.MouseButton1Click:Connect(function()
	setVisibility(Hidden,not useMobileSizing)
end)

hideHotkeyConnection=UserInputService.InputBegan:Connect(function(input,processed)
	if (input.KeyCode==Enum.KeyCode[getSetting("General","rayfieldOpen")]) and not processed then
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
			tween(TopbarButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0})
		end)

		TopbarButton.MouseLeave:Connect(function()
			tween(TopbarButton,TweenInfo.new(0.7,Enum.EasingStyle.Exponential),{ImageTransparency=0.8})
		end)
	end
end

function Library:LoadConfiguration()
	local config

	if debugX then
		warn("Loading Configuration")
	end

	if useStudio then
		config=[[{"Toggle1adwawd":true,"ColorPicker1awd":{"B":255,"G":255,"R":255},"Slider1dawd":100,"ColorPicfsefker1":{"B":255,"G":255,"R":255},"Slidefefsr1":80,"dawdawd":"","Input1":"hh","Keybind1":"B","Dropdown1":["Ocean"]}]]
	end

	if CEnabled then
		local notified,data=false,nil

		local success,result=pcall(function()
			if useStudio and config then
				data=LoadConfiguration(config)
				return
			end
			if isfile then 
				if callSafely(isfile,ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension) then
					data=LoadConfiguration(callSafely(readfile,ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension))
				end
			else
				notified=true
				Library:Notify({Title="Rayfield Configurations",Content="We couldn't enable Configuration Saving as you are not using software with filesystem support.",Image=4384402990})
			end
		end)

		if success and data and not notified then
			Library:Notify({Title="Rayfield Configurations",Content="The configuration file for this script has been loaded from a previous session.",Image=4384403532})
		elseif not success and not notified then
			warn('Rayfield Configurations Error | '..tostring(result))
			Library:Notify({Title="Rayfield Configurations",Content="We've encountered an issue loading your configuration correctly.\n\nCheck the Developer Console for more information.",Image=4384402990})
		end
	end

	globalLoaded=true
end

if useStudio then
	-- run w/ studio
	-- Feel free to place your own script here to see how it'd work in Roblox Studio before running it on your execution software.

	--local Window=Library:CreateWindow({
	--	Name="Rayfield Example Window",
	--	LoadingTitle="Rayfield Interface Suite",
	--	Theme='Default',
	--	Icon=0,
	--	LoadingSubtitle="by Sirius",
	--	ConfigurationSaving={
	--		Enabled=true,
	--		FolderName=nil,-- Create a custom folder for your hub/game
	--		FileName="Big Hub52"
	--	},
	--	Discord={
	--		Enabled=false,
	--		Invite="noinvitelink",-- The Discord invite code,do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
	--		RememberJoins=true -- Set this to false to make them join the discord every time they load it up
	--	},
	--	KeyInfo={
	--		Enabled=false -- Set this to true to use our key system
	--		Title="Untitled",
	--		Subtitle="Key System",
	--		Note="No method of obtaining the key is provided",
	--		FileName="Key",-- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
	--		SaveKey=true,-- The user's key will be saved,but if you change the key,they will be unable to use your script
	--		GrabKeyFromSite=false,-- If this is true,set Key below to the RAW site you would like Rayfield to get the key from
	--		Key={"Hello"} -- List of keys that will be accepted by the system,can be RAW file links (pastebin,github etc) or simple strings ("hello","key22")
	--	}
	--})

	--local Tab=Window:CreateTab("Tab Example",'key-round') -- Title,Image
	--local Tab2=Window:CreateTab("Tab Example 2",4483362458) -- Title,Image

	--local Section=Tab2:CreateSection("Section")

	--local ColorPicker=Tab2:CreateColorPicker({
	--	Name="Color Picker",
	--	Color=Color3.fromRGB(255,255,255),
	--	Flag="ColorPicfsefker1",-- A flag is the identifier for the configuration file,make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback=function(Value)
	--		-- The function that takes place every time the color picker is moved/changed
	--		-- The variable (Value) is a Color3fromRGB value based on which color is selected
	--	end
	--})

	--local Slider=Tab2:CreateSlider({
	--	Name="Slider Example",
	--	Range={0,100},
	--	Increment=10,
	--	Suffix="Bananas",
	--	CurrentValue=40,
	--	Flag="Slidefefsr1",-- A flag is the identifier for the configuration file,make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback=function(Value)
	--		-- The function that takes place when the slider changes
	--		-- The variable (Value) is a number which correlates to the value the slider is currently at
	--	end,
	--})

	--local Input=Tab2:CreateInput({
	--	Name="Input Example",
	--	CurrentValue='',
	--	PlaceholderText="Input Placeholder",
	--	Flag='dawdawd',
	--	RemoveTextAfterFocusLost=false,
	--	Callback=function(Text)
	--		-- The function that takes place when the input is changed
	--		-- The variable (Text) is a string for the value in the text box
	--	end,
	--})


	--Library:Notify({Title="Rayfield Interface",Content="Welcome to Rayfield. These-are the brand new notification design for Rayfield,with custom sizing and Rayfield calculated wait times.",Image=4483362458})

	--local Section=Tab:CreateSection("Section Example")

	--local Button=Tab:CreateButton({
	--	Name="Change Theme",
	--	Callback=function()
	--		-- The function that takes place when the button is pressed
	--		Window.ModifyTheme('DarkBlue')
	--	end,
	--})

	--local Toggle=Tab:CreateToggle({
	--	Name="Toggle Example",
	--	CurrentValue=false,
	--	Flag="Toggle1adwawd",-- A flag is the identifier for the configuration file,make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback=function(Value)
	--		-- The function that takes place when the toggle is pressed
	--		-- The variable (Value) is a boolean on whether the toggle is true or false
	--	end,
	--})

	--local ColorPicker=Tab:CreateColorPicker({
	--	Name="Color Picker",
	--	Color=Color3.fromRGB(255,255,255),
	--	Flag="ColorPicker1awd",-- A flag is the identifier for the configuration file,make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback=function(Value)
	--		-- The function that takes place every time the color picker is moved/changed
	--		-- The variable (Value) is a Color3fromRGB value based on which color is selected
	--	end
	--})

	--local Slider=Tab:CreateSlider({
	--	Name="Slider Example",
	--	Range={0,100},
	--	Increment=10,
	--	Suffix="Bananas",
	--	CurrentValue=40,
	--	Flag="Slider1dawd",-- A flag is the identifier for the configuration file,make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback=function(Value)
	--		-- The function that takes place when the slider changes
	--		-- The variable (Value) is a number which correlates to the value the slider is currently at
	--	end,
	--})

	--local Input=Tab:CreateInput({
	--	Name="Input Example",
	--	CurrentValue="Helo",
	--	PlaceholderText="Adaptive Input",
	--	RemoveTextAfterFocusLost=false,
	--	Flag='Input1',
	--	Callback=function(Text)
	--		-- The function that takes place when the input is changed
	--		-- The variable (Text) is a string for the value in the text box
	--	end,
	--})

	--local thoptions={}
	--for themename,theme in pairs(Library.Theme) do
	--	table.insert(thoptions,themename)
	--end

	--local Dropdown=Tab:CreateDropdown({
	--	Name="Theme",
	--	Options=thoptions,
	--	CurrentOption={"Default"},
	--	MultipleOptions=false,
	--	Flag="Dropdown1",-- A flag is the identifier for the configuration file,make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback=function(Options)
	--		--Window.ModifyTheme(Options[1])
	--		-- The function that takes place when the selected option is changed
	--		-- The variable (Options) is a table of strings for the current selected options
	--	end,
	--})


	--Window.ModifyTheme({
	--	TextColor=Color3.fromRGB(50,55,60),
	--	Background=Color3.fromRGB(240,245,250),
	--	Topbar=Color3.fromRGB(215,225,235),
	--	Shadow=Color3.fromRGB(200,210,220),

	--	NotificationBackground=Color3.fromRGB(210,220,230),
	--	NotificationActionsBackground=Color3.fromRGB(225,230,240),

	--	TabBackground=Color3.fromRGB(200,210,220),
	--	TabStroke=Color3.fromRGB(180,190,200),
	--	TabBackgroundSelected=Color3.fromRGB(175,185,200),
	--	TabTextColor=Color3.fromRGB(50,55,60),
	--	SelectedTabTextColor=Color3.fromRGB(30,35,40),

	--	ElementBackground=Color3.fromRGB(210,220,230),
	--	ElementBackgroundHover=Color3.fromRGB(220,230,240),
	--	SecondaryElementBackground=Color3.fromRGB(200,210,220),
	--	ElementStroke=Color3.fromRGB(190,200,210),
	--	SecondaryElementStroke=Color3.fromRGB(180,190,200),

	--	SliderBackground=Color3.fromRGB(200,220,235), -- Lighter shade
	--	SliderProgress=Color3.fromRGB(70,130,180),
	--	SliderStroke=Color3.fromRGB(150,180,220),

	--	ToggleBackground=Color3.fromRGB(210,220,230),
	--	ToggleEnabled=Color3.fromRGB(70,160,210),
	--	ToggleDisabled=Color3.fromRGB(180,180,180),
	--	ToggleEnabledStroke=Color3.fromRGB(60,150,200),
	--	ToggleDisabledStroke=Color3.fromRGB(140,140,140),
	--	ToggleEnabledOuterStroke=Color3.fromRGB(100,120,140),
	--	ToggleDisabledOuterStroke=Color3.fromRGB(120,120,130),

	--	DropdownSelected=Color3.fromRGB(220,230,240),
	--	DropdownUnselected=Color3.fromRGB(200,210,220),

	--	InputBackground=Color3.fromRGB(220,230,240),
	--	InputStroke=Color3.fromRGB(180,190,200),
	--	PlaceholderColor=Color3.fromRGB(150,150,150)
	--})

	--local Keybind=Tab:CreateKeybind({
	--	Name="Keybind Example",
	--	Keybind="Q",
	--	HoldToInteract=false,
	--	Flag="Keybind1",-- A flag is the identifier for the configuration file,make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback=function(Keybind)
	--		-- The function that takes place when the keybind is pressed
	--		-- The variable (Keybind) is a boolean for whether the keybind is being held or not (HoldToInteract needs to be true)
	--	end,
	--})

	--local Label=Tab:CreateLabel("Label Example")

	--local Label2=Tab:CreateLabel("Warning",4483362458,Color3.fromRGB(255,159,49), true)

	--local Paragraph=Tab:CreateParagraph({Title="Paragraph Example",Content="Paragraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph Example"})
end

if CEnabled and Main:FindFirstChild("Notice") then
	Main.Notice.BackgroundTransparency=1
	Main.Notice.Title.TextTransparency=1
	Main.Notice.Size=UDim2.new(0,0,0,0)
	Main.Notice.Position=UDim2.new(0.5,0,0,-100)
	Main.Notice.Visible=true
	tween(Main.Notice,TweenInfo.new(0.5,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut),{Size=UDim2.new(0,280,0,35),Position=UDim2.new(0.5,0,0,-50),BackgroundTransparency=0.5})
	tween(Main.Notice.Title,TweenInfo.new(0.5,Enum.EasingStyle.Exponential),{TextTransparency=0.1})
end
-- AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA why :(
--if not useStudio then
--	task.spawn(loadWithTimeout,"https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/refs/heads/request/boost.lua")
--end

task.delay(5,function()
	Library:LoadConfiguration()
	if Main:FindFirstChild("Notice") and Main.Notice.Visible then
		tween(Main.Notice,TweenInfo.new(0.5,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut),{Size=UDim2.new(0,100,0,25),Position=UDim2.new(0.5,0,0,-100),BackgroundTransparency=1})
		tween(Main.Notice.Title,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{TextTransparency=1})
		task.wait(0.5)
		Main.Notice.Visible=false
	end
end)

Library.Gui=Rayfield
return Library
