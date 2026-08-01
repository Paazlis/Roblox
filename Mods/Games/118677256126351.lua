local UI=loadstring(game:HttpGet("http://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services=setmetatable({},{__index=function(_,i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players=Services.Players
local ReplicatedStorage=Services.ReplicatedStorage
local VirtualInputManager=Services.VirtualInputManager
local UserInputService=Services.UserInputService

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer:FindFirstChildOfClass("PlayerGui")

local Enableds, Connections = {["Bomb"] = false, ["Cash"] = false, ["Rebirth"] = false}, {}

local ClickPoint=UserInputService:GetMouseLocation()
local TouchPart=nil
local CollectToggle,TouchTargetSelect=nil,nil

local function FireTouch(hitPart,targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart,targetPart,1)
		task.wait()
		firetouchinterest(hitPart,targetPart,0)
	end
end

local function FireButton(button)
	if firesignal then
		firesignal(button.MouseButton1Click)
		firesignal(button.Activated)
	end
end

local function Mouse1Click(x,y)
	VirtualInputManager:SendMouseButtonEvent(x,y,0,true,game,0)
	task.wait()
	VirtualInputManager:SendMouseButtonEvent(x,y,0,false,game,0)
end

local function IsCursorPerfect(cursor)
	local currentY=cursor.Position.Y.Scale
	if currentY>=0.45 and currentY<=0.48 then
		return true
	end
	return false
end

local Window=UI:CreateWindow({
	Name="Bomb Fishing",
	Destroying=function() 
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end
	end
}) 

Window:AddToggle({
	Text="Auto Bomb", 
	Value=false,
	Callback=function(value)
		if Connections.Bomb then Connections.Bomb:Disconnect() Connections.Bomb=nil end
		Enableds.Bomb=value
		if value then
			local OtherScreen=PlayerGui.MainScreen.OtherScreen
			local StartFrame=OtherScreen.Start
			local Gameplay=OtherScreen.Gameplay
			local cursor=Gameplay.ChargeBar.how

			Connections.Bomb=cursor:GetPropertyChangedSignal("Position"):Connect(function()
				if IsCursorPerfect(cursor) and Gameplay.Visible and Enableds.Bomb then
					Mouse1Click(ClickPoint.X,ClickPoint.Y)
				end
			end)

			task.spawn(function()
				while Enableds.Bomb do
					if not Gameplay.Visible then
						FireButton(StartFrame.Button)
					end
					task.wait(1)
				end
			end)
		end
	end
})

TouchTargetSelect=Window:AddSelect({
	Text="Plot Target",
	Callback=function(target)
		if string.find(string.lower(target.Name),"touch") and TouchTargetSelect.Active then
			TouchTargetSelect.Active=false
			TouchTargetSelect.Visible=false
			TouchPart=target
		end
	end
})

local WarningCashLabel=Window:AddLabel({Text="Please sets plot target first!",TextScaled=true,Visible=false})

CollectToggle=Window:AddToggle({
	Text="Collect Cash", 
	Value=false,
	Callback=function(value)
		if not TouchPart then WarningCashLabel.Visible=true Enableds.Cash=false CollectToggle:Replace(false) task.wait(2) WarningCashLabel.Visible=false return end
		Enableds.Cash=value
		if value then
			task.spawn(function()
				while Enableds.Cash do
					if not TouchPart then WarningCashLabel.Visible=true Enableds.Cash=false CollectToggle:Replace(false) task.wait(2) WarningCashLabel.Visible=false break end
					if TouchPart then
						FireTouch(LocalPlayer.Character.Head,TouchPart)
						task.wait(1)
					end
					task.wait()
				end
			end)
		end
	end
})

Window:AddToggle({
	Text="Auto Rebirth", 
	Value=false,
	Callback=function(value)
		Enableds.Rebirth=value
		if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth=nil end
		if value then
			local RebirthFrame=PlayerGui.MainScreen.CenterScreen.Rebirth
			local RebirthButton=RebirthFrame.Rebirth.Button
			local uiGradient=RebirthFrame.Progress.CanvasGroup.Bar.UIGradient
			
			Connections.Rebirth=uiGradient:GetPropertyChangedSignal("Offset"):Connect(function()
				if uiGradient.Offset.X>=0.5 and Enableds.Rebirth then
					FireButton(RebirthButton)
				end
			end)
			
			if uiGradient.Offset.X>=0.5 and Enableds.Rebirth then
				FireButton(RebirthButton)
			end
		end
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
