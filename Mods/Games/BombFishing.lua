local UI=loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services=setmetatable({},{__index=function(_,i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})

local Players,ReplicatedStorage,VirtualInputManager,UserInputService=Services.Players,Services.ReplicatedStorage,Services.VirtualInputManager,Services.UserInputService
local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer.PlayerGui

local BombEnabled,CashEnabled=false,false
local BombCon=nil
local BombCompleted=false

local Window=UI:CreateWindow({Name="Bomb Fishing",Destroying=function() 
	BombEnabled,CashEnabled=false,false 
	BombCompleted=false
	if BombCon then BombCon:Disconnect() BombCon=nil end
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

Window:AddToggle({
	Name="Auto Bomb", 
	Value=false,
	Callback=function(value)
		if BombCon then BombCon:Disconnect() BombCon=nil end
		BombEnabled=value
		BombCompleted=false
			
		if value then
			local OtherScreen=PlayerGui.MainScreen.OtherScreen
			local StartFrame=OtherScreen.Start --> .Position (0.5, 0, 1.5 -> 1 when button click, 0) .Button
			local Gameplay=OtherScreen.Gameplay --> When visible active and start perfect luck
			local how=Gameplay.ChargeBar.how --> target lucky is 0.452 y scale
			
			BombCon=how:GetPropertyChangedSignal("Position"):Connect(function()
				if not BombEnabled then return end
				
				if how.Position.Y.Scale>=0.450 and Gameplay.Visible then
					Mouse1Click(ClickPoint.X,ClickPoint.Y)
					BombCompleted=true
				end
			end)
			
			task.spawn(function()
				while BombEnabled do
					task.wait(1)
					if not Gameplay.Visible then
						BombCompleted=false
						FireButton(StartFrame.Button)
						repeat task.wait() until BombCompleted==true
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
local CollectToggle=nil


Window:AddLabel("Touch Cash Target")

Window:AddSelect({
	Name="Touch Cash Target",
	Callback=function(target)
		if string.find(string.lower(target.Name),"touch") then
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

Window:AddLabel({
	Name="YouTube: Crokyreo"
})
