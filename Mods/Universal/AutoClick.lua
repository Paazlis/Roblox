-- [


-- $$$$$$$$\                   $$\       $$$$$$\  $$\ $$\           $$\       
-- $$  _____|                  $$ |     $$  __$$\ $$ |\__|          $$ |      
-- $$ |   $$$$$$\   $$$$$$$\ $$$$$$\    $$ /  \__|$$ |$$\  $$$$$$$\ $$ |  $$\ 
-- $$$$$\ \____$$\ $$  _____|\_$$  _|   $$ |      $$ |$$ |$$  _____|$$ | $$  |
-- $$  __|$$$$$$$ |\$$$$$$\    $$ |     $$ |      $$ |$$ |$$ /      $$$$$$  / 
-- $$ |  $$  __$$ | \____$$\   $$ |$$\  $$ |  $$\ $$ |$$ |$$ |      $$  _$$<  
-- $$ |  \$$$$$$$ |$$$$$$$  |  \$$$$  | \$$$$$$  |$$ |$$ |\$$$$$$$\ $$ | \$$\ 
-- \__|   \_______|\_______/    \____/   \______/ \__|\__| \_______|\__|  \__|

--                         This was made by stav and Crokyreo          


-- ]

local Services=setmetatable({},{
	__index=function(_,i) 
		return cloneref and cloneref(game:GetService(i)) or game:GetService(i) 
	end
})

local UI=loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

-- SERVICES --
local RunService=Services.RunService
local UserInputService=Services.UserInputService
local VirtualInputManager=Services.VirtualInputManager

-- VARIABLES --
local Clicking=false
local ClickSpeed=0.01
local ClickThread=nil
local ClickPoint=UserInputService:GetMouseLocation()
local WaitType="Default"
local SuperActive=false
local MouseWaitDisabled=false

local Window=UI:CreateWindow({Name="Maswa Clicker",Destroying=function()
	WaitType="Default"
	MouseWaitDisabled=false
	SuperActive=false
	task.cancel(ClickThread)
end})

local Status=Window:AddLabel({Name="Point: "..tostring(ClickPoint)})

local function ChooseWait(duration)
	if SuperActive then
		return RunService.RenderStepped:Wait()
	else
		if WaitType and WaitType=="Fast" then
			if not duration then return RunService.RenderStepped:Wait() end
			local start=tick()
			while tick()-start<duration do RunService.RenderStepped:Wait() end
			return start-duration
		else
			return task.wait(duration)
		end
	end
end

local function Mouse1Click(x,y)
	VirtualInputManager:SendMouseButtonEvent(x,y,0,true,game,0)
	if MouseWaitDisabled then
		ChooseWait()
	else
		task.wait()
	end
	VirtualInputManager:SendMouseButtonEvent(x,y,0,false,game,0)
end

-- AUTOCLICK FUNCTION --
ClickThread=task.spawn(function()
	while true do
		if Clicking then
			Mouse1Click(ClickPoint.X,ClickPoint.Y)
			ChooseWait(ClickSpeed)
		else
			task.wait()
		end
	end
end)

Window:AddToggle({
	Name="Auto Click",
	Value=false,
	Callback=function(state)
		Clicking=state
	end
})

local ClickSpeedSlider=Window:AddSlider({
	Name="Click Speed",
	Range={0.001,100},
	Value=ClickSpeed,
	Callback=function(speed)
		ClickSpeed=speed
	end
})

Window:AddButton({
	Name="Click Point",
	Callback=function(s)
		task.delay(2,function()
			ClickPoint=UserInputService:GetMouseLocation()
			Status:Set("Point: ".. tostring(ClickPoint))
		end)
	end
})

Window:AddToggle({
	Name="Mouse Wait Disabled",
	Value=false,
	Callback=function(value)
		MouseWaitDisabled=value
	end
})

Window:AddSelector({
	Name="Wait Type",
	Options={"Default","Fast","Super"},
	Value=WaitType,
	Callback=function(value)
		WaitType=value
		SuperActive=value=="Super"
		ClickSpeedSlider.Visible=value~="Super"
	end
})

local Folder=Window:AddFolder("Creator",true)
Folder:AddLabel("YouTube: Crokyreo")
Folder:AddLabel("stav")
