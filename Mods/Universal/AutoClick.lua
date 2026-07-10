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

local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

-- SERVICES --
local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local RunService=Services.RunService
local UserInputService=Services.UserInputService
local VirtualInputManager=Services.VirtualInputManager

-- VARIABLES --
local Clicking=false
local ClickSpeed=0.01
local ClickThread=nil
local ClickPoint=UserInputService:GetMouseLocation()

local Window=UI:CreateWindow({Name="Maswa Clicker",Destroying=function()
	task.cancel(ClickThread)
end})

local Status=Window:AddLabel({Name="Point: "..tostring(ClickPoint)})

local function FastWait(duration)
	if not duration then return RunService.RenderStepped:Wait() end
	local start=tick()
	while tick()-start<duration do RunService.RenderStepped:Wait() end
	return start-tick()
end

local function SendClick(x,y)
	VirtualInputManager:SendMouseButtonEvent(x,y,0,true,game,0)
	FastWait()
	VirtualInputManager:SendMouseButtonEvent(x,y,0,false,game,0)
end

-- AUTOCLICK FUNCTION --
ClickThread=task.spawn(function()
	while true do
	    if Clicking then
		   SendClick(ClickPoint.X,ClickPoint.Y)
		   FastWait(ClickSpeed)
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

Window:AddSlider({
	Name="Click Speed",
	Range={0.001,100},
	Value=ClickSpeed,
	Callback=function(speed)
		if speed>0 then
			ClickSpeed=speed
		end
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

local Folder=Window:AddFolder("Creator")
Folder:AddLabel("YouTube: Crokyreo")
Folder:AddLabel("stav")
