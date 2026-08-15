

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

	local dba = false
	local dbc = false
	Connections.FarmLooped = RunService.RenderStepped:Connect(function()
		-- Script Tarik Tambang (Sumbu X / Horizontal)
		if TarikTambangGui.Enabled then
			-- Titik X jarum di layar (Pixel)
			-- Ditambah setengah AbsoluteSize agar pembacaan berada tepat di tengah-tengah jarum
			local cursorX = TarikTambangCursor.AbsolutePosition.X + (TarikTambangCursor.AbsoluteSize.X / 2)
			
			-- AbsolutePosition selalu menghitung titik paling kiri dari GUI tanpa peduli AnchorPoint
			local minX = TarikTambangZone.AbsolutePosition.X
			local maxX = minX + TarikTambangZone.AbsoluteSize.X
			
			if cursorX >= minX and cursorX <= maxX then
				if dba then return end
				dba = true 
				SendClick(ClickPoint.X, ClickPoint.Y)
				task.wait(0.1)
				dba = false
			end
		end
		
		-- Script Balap Karung (Sumbu Y / Vertikal)
		if BalapKarungGui.Enabled then
			-- Titik Y jarum di layar (Pixel)
			-- Ditambah setengah AbsoluteSize agar pembacaan berada tepat di tengah-tengah jarum
			local cursorY = BalapKarungCursor.AbsolutePosition.Y + (BalapKarungCursor.AbsoluteSize.Y / 2)
			
			-- AbsolutePosition selalu menghitung titik paling atas dari GUI tanpa peduli AnchorPoint
			local minY = BalapKarungZone.AbsolutePosition.Y
			local maxY = minY + BalapKarungZone.AbsoluteSize.Y
			
			if cursorY >= minY and cursorY <= maxY then
				if dbc then return end
				dbc = true  
				SendClick(ClickPoint.X, ClickPoint.Y)
				task.wait(0.1)
				dbc = false
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
