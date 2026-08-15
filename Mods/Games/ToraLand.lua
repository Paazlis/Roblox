

local UI=loadstring(game:HttpGet("http://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services=setmetatable({},{__index=function(_,i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players=Services.Players
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local VirtualInputManager = Services.VirtualInputManager

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer:FindFirstChildOfClass("PlayerGui")

local Enableds, Connections = {["Farm"] = false}, {}

local ClickPoint=UserInputService:GetMouseLocation()

local function SendClick(x,y)
	VirtualInputManager:SendMouseButtonEvent(x,y,0,true,game,0)
	task.wait()
	VirtualInputManager:SendMouseButtonEvent(x,y,0,false,game,0)
end

local function HandleFarm()
	if Connections.FarmLooped then Connections.FarmLooped:Disconnect() Connections.FarmLooped=nil end
	if not Enableds.Farm then return end

	task.delay(2, function()
		ClickPoint = UserInputService:GetMouseLocation()
	end)
	
	task.wait(2)
	if not Enableds.Farm then return end
	
	local BalapKarungGui = PlayerGui:WaitForChild("BalapKarungMeter")
	local BalapKarungCursor = BalapKarungGui:QueryDescendants("#Meter > #Content > #Needle")[1]
	local BalapKarungZone = BalapKarungGui:QueryDescendants("#Meter > #Content > #Zone")[1]
	
	local TarikTambangGui = PlayerGui:WaitForChild("TarikTambangMeter")
	local TarikTambangCursor = TarikTambangGui:QueryDescendants("#Meter > #Content > #Needle")[1]
	local TarikTambangZone = TarikTambangGui:QueryDescendants("#Meter > #Content > #Zone")[1]
	
	Connections.FarmLooped = RunService.RenderStepped:Connect(function()
		if TarikTambangGui.Enabled then
			local currentX=TarikTambangCursor.Position.X.Scale
			if currentX>=(TarikTambangZone.Position.X.Scale-0.1) and currentX<=(TarikTambangZone.Position.X.Scale+0.2) then
				SendClick(ClickPoint.X,ClickPoint.Y)
			end
		end
		
		if BalapKarungGui.Enabled then
			local currentX=BalapKarungCursor.Position.Y.Scale
			if currentX>=(BalapKarungZone.Position.Y.Scale-0.1) and currentX<=(BalapKarungZone.Position.Y.Scale+0.2) then
				SendClick(ClickPoint.X,ClickPoint.Y)
			end
		end
	end)
end


local Window=UI:CreateWindow({
	Name="Secret",
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
	Text="Auto Farm", 
	Value=false,
	Callback=function(value)
		Enableds.Farm=value
		HandleFarm()
	end
})

Window:AddLabel({
	Text = "YouTube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text = "Date: 06-22-2026",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
