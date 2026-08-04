--                         This was made by stav and Crokyreo 

local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services=setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players=Services.Players
local RunService=Services.RunService
local UserInputService=Services.UserInputService
local VirtualInputManager=Services.VirtualInputManager

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer:FindFirstChildOfClass("PlayerGui")

local SaveEnableds,Enableds,Threads={},{["Click"]=false,["HoldClick"]=false},{}

local HoldDuration=2
local ClickSpeed=0.01
local ClickThread=nil
local ClickPoint=UserInputService:GetMouseLocation()
local LayerCollectorType="Default"

local SwipeInfo = {
	X = ClickPoint.X,
	Y = ClickPoint.Y,
	CurrentX = ClickPoint.X,
	EasingStyle = "Linear",
	Speed = 5,
	Radius = 150,
	Direction = 1,
	CurrentAngle = 0
}

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

local function SendHoldClick(x, y, duration)
	VirtualInputManager:SendMouseButtonEvent(x,y,0,true,game,0)
	task.wait(duration)
	VirtualInputManager:SendMouseButtonEvent(x,y,0,false,game,0)
end

local function SendSwipe(swipeInfo)
	local cX, cY = swipeInfo.X, swipeInfo.Y
	local speed = swipeInfo.Speed or 10
	local multiplier = 1
	local easingStyle = tostring(swipeInfo.EasingStyle or "Circular")

	if easingStyle == "Linear" then
		multiplier = swipeInfo.Multiplier or 10

		local dynamicStartX = cX - swipeInfo.Radius
		local dynamicEndX = cX + swipeInfo.Radius

		local step = speed * multiplier
		swipeInfo.CurrentX = swipeInfo.CurrentX + (step * swipeInfo.Direction)

		if swipeInfo.CurrentX >= dynamicEndX then
			swipeInfo.Direction = -1
			swipeInfo.CurrentX = dynamicEndX
		elseif swipeInfo.CurrentX <= dynamicStartX then
			swipeInfo.Direction = 1
			swipeInfo.CurrentX = dynamicStartX
		end

		VirtualInputManager:SendMouseMoveEvent(math.round(swipeInfo.CurrentX), math.round(cY), game)
	elseif easingStyle == "Circular" then
		multiplier = swipeInfo.Multiplier or 0.04

		local angleStep = speed * swipeInfo.Multiplier
		swipeInfo.CurrentAngle = swipeInfo.CurrentAngle + angleStep

		local x = cX + (swipeInfo.Radius * math.cos(swipeInfo.CurrentAngle))
		local y = cY + (swipeInfo.Radius * math.sin(swipeInfo.CurrentAngle))

		VirtualInputManager:SendMouseMoveEvent(math.round(x), math.round(y), game)
	end
end

local function HandleSwipe()
	if Threads.Swipe and coroutine.status(Threads.Swipe)~="dead" then task.cancel(Threads.Swipe) Threads.Swipe=nil end
	if Enableds.Swipe then
		local startX, startY = ClickPoint.X - SwipeInfo.Radius, ClickPoint.Y

		VirtualInputManager:SendMouseMoveEvent(startX, startY, game)
		task.wait(0.1)
		VirtualInputManager:SendMouseButtonEvent(startX, startY, 0, true, game, 1)
		task.wait(0.05)

		SwipeInfo.CurrentX = startX
		SwipeInfo.Direction = 1
		SwipeInfo.CurrentAngle = 0
		
		Threads.Swipe = task.spawn(function()
			while Enableds.Swipe do
				SwipeInfo.X, SwipeInfo.Y = ClickPoint.X, ClickPoint.Y
				SendSwipe(SwipeInfo)
				task.wait()
			end
		end)
	else
		VirtualInputManager:SendMouseButtonEvent(math.round(ClickPoint.X), math.round(ClickPoint.Y), 0, false, game, 1)
	end
end

local Window=UI:CreateWindow({
	Name="Auto Input V13",
	Destroying=function()
		task.cancel(ClickThread)
		for key, enabled in pairs(Enableds) do
			Enableds[key]=false
		end
	end
})

local Status=Window:AddLabel({
	Text="Point: "..tostring(ClickPoint),
	TextScaled=true
})

Window:AddButton({
	Name="Point",
	Callback=function(s)
		task.delay(2,function()
			ClickPoint=UserInputService:GetMouseLocation()
			SwipeInfo.X, SwipeInfo.Y = ClickPoint.X, ClickPoint.Y
			Status:Set("Point: ".. tostring(ClickPoint))
		end)
	end
})

local ClickInputFolder=Window:AddFolder({
	Text="Click Input",
	Open=false
})

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

ClickInputFolder:AddSlider({
	Name="Click Speed",
	Range={0.001,100},
	Value=ClickSpeed,
	Callback=function(speed)
		if speed>0 then
			ClickSpeed=speed
		end
	end
})

local ClickToggle=ClickInputFolder:AddToggle({
	Name="Auto Click",
	Value=false,
	Callback=function(state)
		Enableds.Click=state
	end
})

ClickInputFolder:AddSlider({
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

ClickInputFolder:AddToggle({
	Name="Hold Click",
	Value=false,
	Callback=function(state)
		if state then
			SaveEnableds.Click=Enableds.Click
			ClickToggle:Set(false)
			task.wait(0.1)
			Enableds.HoldClick=true
		else
			Enableds.HoldClick=false
			ClickToggle:Set(SaveEnableds.Click)
			SaveEnableds.Click=Enableds.Click
		end
	end
})

local SwipeInputFolder=Window:AddFolder({
	Text="Swipe Input",
	Open=false
})

SwipeInputFolder:AddSelector({
	Text = "Swipe Type",
	Options = {"Linear", "Circular"},
	Value = "Linear",
	Callback = function(value)
		SwipeInfo.EasingStyle = value
	end
})

SwipeInputFolder:AddSlider({
	Text = "Swipe Speed",
	Range = {1, 25},
	Value = 10,
	Increment = 0.01,
	Callback = function(value)
		SwipeInfo.Speed = value
	end
})

SwipeInputFolder:AddSlider({
	Text = "Swipe Radius",
	Range = {1, 200},
	Value = 150,
	Increment = 0.01,
	Callback = function(value)
		SwipeInfo.Radius = value
	end
})

SwipeInputFolder:AddToggle({
	Text = "Auto Swipe",
	Value = false,
	Callback = function(value)
		Enableds.Swipe = value
		HandleSwipe()
	end
})

Window:AddLabel("YouTube: Crokyreo")
Window:AddLabel("Creator: stav")

task.delay(5, function()
	ClickPoint=UserInputService:GetMouseLocation()
	SwipeInfo.X, SwipeInfo.Y = ClickPoint.X, ClickPoint.Y
	Status:Set("Point: ".. tostring(ClickPoint))
end)
