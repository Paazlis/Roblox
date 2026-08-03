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

local Window=UI:CreateWindow({
   Name="Auto Input",
   Destroying=function()
	  task.cancel(ClickThread)
	  for key, enabled in pairs(Enableds) do
		 Enableds[key]=false
	  end
   end
})

local ClickInputData={}

Window:AddToggle({
	Text="Click Input",
	Value=true,
	Callback=function(value)
		Enableds.ClickInput=value
		if value then
			for key, value in pairs(ClickInputData) do
			   if not Enableds.ClickInput then break end
			   if value then
				  value.Visible = true
			   end
			end
		else
			for key, value in pairs(ClickInputData) do
			   if Enableds.ClickInput then break end
			   if value then
				  value.Visible = false
			   end
			end
		end
	end
})

ClickInputData.ClickLabel=Window:AddLabel({
	Text="Click Point: "..tostring(ClickPoint),
	TextScaled=true
})

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
    VirtualInputManager:SendMouseButtonEvent(x,y,0,true,GetLayerCollector(),0)
    task.wait(duration)
    VirtualInputManager:SendMouseButtonEvent(x,y,0,false,GetLayerCollector(),0)
end

-- Click Function --
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

ClickInputData.ClickToggle=Window:AddToggle({
	Name="Auto Click",
	Value=false,
	Callback=function(state)
		Enableds.Click=state
	end
})

ClickInputData.ClickSlider=Window:AddSlider({
	Name="Click Speed",
	Range={0.001,100},
	Value=ClickSpeed,
	Callback=function(speed)
		if speed>0 then
			ClickSpeed=speed
		end
	end
})

ClickInputData.ClickButton=Window:AddButton({
	Name="Click Point",
	Callback=function(s)
		task.delay(2,function()
			ClickPoint=UserInputService:GetMouseLocation()
			ClickInputData.ClickLabel:Set("Point: ".. tostring(ClickPoint))
		end)
	end
})

ClickInputData.HoldToggle=Window:AddToggle({
	Name="Hold Click",
	Value=false,
	Callback=function(state)
		if state then
			SaveEnableds.Click=Enableds.Click
			ClickInputData.ClickToggle:Set(false)
			task.wait(0.1)
			Enableds.HoldClick=true
		else
			Enableds.HoldClick=false
			ClickInputData.ClickToggle:Set(SaveEnableds.Click)
			SaveEnableds.Click=Enableds.Click
		end
	end
})

ClickInputData.HoldSlider=Window:AddSlider({
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

local SwipeInputData={}

Window:AddToggle({
	Text="Swipe Input",
	Value=true,
	Callback=function(value)
		Enableds.SwipeInput=value
		if value then
			for key, value in pairs(SwipeInputData) do
			   if not Enableds.SwipeInput then break end
			   if value then
				  value.Visible = true
			   end
			end
		else
			for key, value in pairs(SwipeInputData) do
			   if Enableds.SwipeInput then break end
			   if value then
				  value.Visible = false
			   end
			end
		end
	end
})

local swipeType = "Linear"
local swipeSpeed = 5

-- Koordinat Layar
local startX, endX, yPos = 300, 600, 400
local centerX, centerY, radius = 450, 400, 150

SwipeInputData.SwipeSelector=Window:AddSelector({
	Text = "Swipe Type",
	Options = {"Linear", "Circular"},
	Value = "Linear",
	Callback = function(value: string)
		swipeType = value
	end
})

SwipeInputData.SwipeSlider=Window:AddSlider({
	Text = "Swipe Speed",
	Range = {1, 10},
	Value = 5,
	Increment = 0.1,
	Callback = function(value: number)
		swipeSpeed = value
	end
})

SwipeInputData.SwipeToggle=Window:AddToggle({
	Text = "Auto Swipe",
	Value = false,
	Callback = function(value: boolean)
		Enableds.Swipe = value

		if value then
			task.spawn(function()
				-- Move to initial position and hold left click
				VirtualInputManager:SendMouseMoveEvent(startX, yPos, game)
				task.wait(0.1)
				VirtualInputManager:SendMouseButtonEvent(startX, yPos, 0, true, game, 1)
				task.wait(0.05)

				local currentX = startX
				local direction = 1
				local currentAngle = 0

				while Enableds.Swipe do
					if swipeType == "Linear" then
						-- Hitung langkah berdasar slider (contoh: speed 5 = step 50px)
						local step = swipeSpeed * 10
						currentX = currentX + (step * direction)

						if currentX >= endX then
							direction = -1
							currentX = endX
						elseif currentX <= startX then
							direction = 1
							currentX = startX
						end

						VirtualInputManager:SendMouseMoveEvent(math.round(currentX), yPos, game)

					elseif swipeType == "Circular" then
						-- Hitung kecepatan putaran sudut berdasar slider
						local angleStep = swipeSpeed * 0.04
						currentAngle = currentAngle + angleStep

						local x = centerX + (radius * math.cos(currentAngle))
						local y = centerY + (radius * math.sin(currentAngle))

						VirtualInputManager:SendMouseMoveEvent(math.round(x), math.round(y), game)
					end

					task.wait()
				end

				-- Release mouse button when toggle is turned OFF
				VirtualInputManager:SendMouseButtonEvent(startX, yPos, 0, false, game, 1)
			end)
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
Window:AddLabel("Creator: stav")
