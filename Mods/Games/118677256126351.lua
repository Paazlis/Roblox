local UI=loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services=setmetatable({},{__index=function(_,i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})

local Players,ReplicatedStorage,VirtualInputManager,UserInputService=Services.Players,Services.ReplicatedStorage,Services.VirtualInputManager,Services.UserInputService
local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer.PlayerGui

local BombEnabled,CashEnabled,RebirthEnabled=false,false,false
local BombConnection=nil
local RebirthConnection=nil

local Window=UI:CreateWindow({Name="Bomb Fishing",Destroying=function() 
	BombEnabled,CashEnabled,RebirthEnabled=false,false,false
	if BombConnection then BombConnection:Disconnect() BombConnection=nil end
	if RebirthConnection then RebirthConnection:Disconnect() RebirthConnection=nil end
end}) 

local ClickPoint=UserInputService:GetMouseLocation()

local function FireButton(object)
	if firesignal then
		firesignal(object.MouseButton1Click)
		firesignal(object.Activated)
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

Window:AddToggle({
	Name="Auto Bomb", 
	Value=false,
	Callback=function(value)
		if BombConnection then BombConnection:Disconnect() BombConnection=nil end
		BombEnabled=value
		if value then
			local OtherScreen=PlayerGui.MainScreen.OtherScreen
			local StartFrame=OtherScreen.Start
			local Gameplay=OtherScreen.Gameplay
			local cursor=Gameplay.ChargeBar.how

			BombConnection=cursor:GetPropertyChangedSignal("Position"):Connect(function()
				if not BombEnabled then return end

				if IsCursorPerfect(cursor) and Gameplay.Visible then
					Mouse1Click(ClickPoint.X,ClickPoint.Y)
				end
			end)

			task.spawn(function()
				while BombEnabled do
					task.wait(1)
					if not Gameplay.Visible then
						FireButton(StartFrame.Button)
					end
				end
			end)
		end
	end
})

local function FireTouch(hitPart,targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart,targetPart,1)
		task.wait()
		firetouchinterest(hitPart,targetPart,0)
	end
end

local TouchPart=nil
local CollectToggle,TouchTargetSelect=nil,nil

TouchTargetSelect=Window:AddSelect({
	Name="Touch Cash Target",
	Callback=function(target)
		if string.find(string.lower(target.Name),"touch") and TouchTargetSelect.Active then
			TouchTargetSelect.Active=false
			TouchTargetSelect.Visible=false
			TouchPart=target
		end
	end
})

local WarningCashLabel=Window:AddLabel({Name="Please sets touch cash target first!",TextScaled=true,Visible=false})

CollectToggle=Window:AddToggle({
	Name="Collect Cash", 
	Value=false,
	Callback=function(value)
		if not TouchPart then WarningCashLabel.Visible=true CashEnabled=false CollectToggle:Replace(false) task.wait(2) WarningCashLabel.Visible=false return end
		CashEnabled=value
		if value then
			task.spawn(function()
				while CashEnabled do
					task.wait()
					if not TouchPart then WarningCashLabel.Visible=true CashEnabled=false CollectToggle:Replace(false) task.wait(2) WarningCashLabel.Visible=false break end
					if TouchPart then
						FireTouch(LocalPlayer.Character.Head,TouchPart)
						task.wait(1)
					end
				end
			end)
		end
	end
})

local function IsRebirthSuccess(pos)
	return pos.X>=0.5
end

Window:AddToggle({
	Name="Collect Rebirth", 
	Value=false,
	Callback=function(value)
		RebirthEnabled=value
		if RebirthConnection then RebirthConnection:Disconnect() RebirthConnection=nil end
		if value then
			local RebirthFrame=PlayerGui.MainScreen.CenterScreen.Rebirth
			local RebirthButton=RebirthFrame.Rebirth.Button
			local uiGradient=RebirthFrame.Progress.CanvasGroup.Bar.UIGradient
			
			RebirthConnection=uiGradient:GetPropertyChangedSignal("Offset"):Connect(function()
				if uiGradient.Offset.X>=0.5 and RebirthEnabled then
					FireButton(RebirthButton)
				end
			end)
			if uiGradient.Offset.X>=0.5 and RebirthEnabled then
				FireButton(RebirthButton)
			end
		end
	end
})

Window:AddLabel({
	Name="YouTube: Crokyreo"
})
