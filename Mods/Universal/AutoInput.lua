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
local Services=setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players=Services.Players
local RunService=Services.RunService
local UserInputService=Services.UserInputService
local VirtualInputManager=Services.VirtualInputManager

-- VARIABLES --
local PlayerGui=Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

local SaveEnableds,Enableds={},{["Click"]=false,["HoldClick"]=false}
local HoldDuration=2
local ClickSpeed=0.01
local ClickThread=nil
local ClickPoint=UserInputService:GetMouseLocation()
local LayerCollectorType="Default"
local Window=UI:CreateWindow({Name="Maswa Clicker",Destroying=function()
	 task.cancel(ClickThread)
	 for key, lenabled in pairs(Enableds) do
		Enableds[key]=false
	 end
end})

Window:AddLabel("Layer Collector")

Window:AddSelector({
	Options={"Default","PlayerGui","Workspace"},
	NoCap=true,
	Callback=function(value)
		LayerCollectorType=value
	end
})
local Status=Window:AddLabel({Name="Point: "..tostring(ClickPoint)})

local function GetLayerCollector()
	local layerCollector = game
	if LayerCollectorType == "PlayerGui" then
		layerCollector = PlayerGui
	elseif LayerCollectorType == "Workspace" then
		layerCollector = workspace
	end
	return layerCollector
end

local function FastWait(duration)
	if not duration then return RunService.RenderStepped:Wait() end
	local start=tick()
	while tick()-start<duration do RunService.RenderStepped:Wait() end
	return start-tick()
end

local function SendClick(x,y)
	VirtualInputManager:SendMouseButtonEvent(x,y,0,true,GetLayerCollector(),0)
	FastWait()
	VirtualInputManager:SendMouseButtonEvent(x,y,0,false,GetLayerCollector(),0)
end

local function SendHoldClick(x, y, duration)
    -- 1. Tekan dan tahan mouse (isDown = true)
    VirtualInputManager:SendMouseButtonEvent(x,y,0,true,GetLayerCollector(),0)
    
    -- 2. Tahan selama durasi yang diinginkan (misal: 2 detik)
    task.wait(duration)
    
    -- 3. Lepaskan kembali mouse (isDown = false)
    VirtualInputManager:SendMouseButtonEvent(x,y,0,false,GetLayerCollector(),0)
end

-- AUTOCLICK FUNCTION --
ClickThread=task.spawn(function()
	while true do
	    if Enableds.Click then
		   SendClick(ClickPoint.X,ClickPoint.Y)
		   FastWait(ClickSpeed)
		elseif Enableds.HoldClick then
		   SendHoldClick(ClickPoint.X,ClickPoint.Y,HoldDuration)
		   FastWait()
		else
		   task.wait()
		end
	end
end)

local AutoClickToggle=Window:AddToggle({
	Name="Auto Click",
	Value=false,
	Callback=function(state)
		Enableds.Click=state
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

Window:AddToggle({
	Name="Hold Click",
	Value=false,
	Callback=function(state)
		if state then
			SaveEnableds.Click=Enableds.Click
			AutoClickToggle:Set(false)
			task.wait(0.1)
			Enableds.HoldClick=true
		else
			Enableds.HoldClick=false
			AutoClickToggle:Set(SaveEnableds.Click)
			SaveEnableds.Click=Enableds.Click
		end
	end
})

Window:AddSlider({
	Name="Hold Duration",
	Range={1,100},
	Increment=0.01,
	Value=HoldDuration,
	Callback=function(duration)
		if duration>0 then
			HoldDuration=duration
		end
	end
})


local Folder=Window:AddFolder("Creator")
Folder:AddLabel("YouTube: Crokyreo")
Folder:AddLabel("Creator: stav")
