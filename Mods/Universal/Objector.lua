local Services=setmetatable({},{__index=function(_,i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})

local UI=loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()
local Players,StarterGui,RunService=Services.Players,Services.StarterGui,Services.RunService

local LocalPlayer=Players.LocalPlayer
local Character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds,Connections,Values={["Raycast"]=false},{},{Angle = 0.97}

local Mouse=LocalPlayer:GetMouse()

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character=newCharacter
end)

local function Missing(s,v,f)
	if typeof(v)==s then return v end return f
end

local function Notify(title,description,duration)
	StarterGui:SetCore("SendNotification",{Title=title,Text=description,Duration=duration or 5})
end

setclipboard=Missing("function",setclipboard,function(s) print(s) end)


local Window=UI:CreateWindow({
	Name="Objector",
	Destroying=function()
		for key,enabled in pairs(Enableds) do
			Enableds[key]=false
		end
		for key,connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end
	end
})

local PartFolder=Window:AddFolder({
	Text = "Part", 
	Open = false
})

PartFolder:AddButton({
	Text="Copy Position",
	Callback=function() 
		local cf=Character:GetPivot()
		local pos=cf.Position
		setclipboard(tostring(pos.X)..","..tostring(pos.Y)..","..tostring(pos.Z))
		Notify("Part Position","Copy To Clipboard!")
	end
})

PartFolder:AddButton({
	Text="Copy CFrame",
	Callback=function() 
		local cf=Character:GetPivot()
		setclipboard(tostring(cf))
		Notify("Part CFrame","Copy To Clipboard!")
	end
})

local MouseFolder=Window:AddFolder("Mouse")

local MousePointLabel=MouseFolder:AddLabel({
	Text="Click Point: "..tostring(Mouse.X)..","..tostring(Mouse.Y)
})

MouseFolder:AddButton({
	Name="Copy Mouse Location",
	Callback=function()
		task.delay(1,function()
			local x,y=Mouse.X,Mouse.Y
			setclipboard(tostring(x)..","..tostring(y))
			MousePointLabel:Set("Click Point: "..tostring(x)..","..tostring(y))
			Notify("Mouse Location","Copy To Clipboard!")
		end)
	end
})

local RaycastFolder=Window:AddFolder({
	Text = "Raycast", 
	Open = false
})

local CurrentLabel = RaycastFolder:AddLabel({
	Text = "Current: None",
	TextScaled = true
})

local CurrentDebounce,LastDebounce=false,false
local CurrentTarget,LastTarget=nil,nil

RaycastFolder:AddSelect({
	Text="Current Target",
	Callback=function(target)
		if CurrentDebounce then return end
		CurrentDebounce = true
		
		if target then
			CurrentLabel:Set("Current: "..target:GetFullName()) 
			CurrentTarget=target
		end
		
		task.wait(0.1)
		CurrentDebounce = false
	end
})

local LastLabel = RaycastFolder:AddLabel({
	Text = "Last: None",
	TextScaled = true
})

RaycastFolder:AddSelect({
	Text="Last Target",
	Callback=function(target)
		if LastDebounce then return end
		LastDebounce = true
		
		if target then
			LastLabel:Set("Last: "..target:GetFullName()) 
			LastTarget=target
		end

		task.wait(0.1)
		LastDebounce = false
	end
})

RaycastFolder:AddSlider({
	Text="Angle",
	Range={-1,1},
	Increment=0.01,
	Value=0.97,
	Callback=function(value)
		Values.Angle=value
	end
})

local RaycastStatus=RaycastFolder:AddLabel({
	Text="Status: None",
	TextColor3=Color3.fromRGB(255, 255, 255)
})

RaycastFolder:AddToggle({
	Text="Auto Raycast",
	Callback=function(value)
		if Connections.RaycastLooped then Connections.RaycastLooped:Disconnect() Connections.RaycastLooped=nil end
		Enableds.Raycast=value
		if value then
			Connections.RaycastLooped = RunService.RenderStepped:Connect(function()
				if not Enableds.Raycast then return end
				if not CurrentTarget then return end
				if not LastTarget then return end
				
				local lastPosition = LastTarget.Position
				local currentPosition = CurrentTarget.Position
				local currentLookVector = CurrentTarget.CFrame.LookVector.Unit
				local directionToLast = (lastPosition - currentPosition).Unit

				local dotProduct = currentLookVector:Dot(directionToLast)

				if dotProduct >= Values.Angle then
					RaycastStatus:Set("Status: Yes")
				else
					RaycastStatus:Set("Status: No")
				end
			end)
		end
	end
})

Window:AddButton({
	Name="Destroy",
	MethodType = "DoubleClick",
	Callback=function() 
		Window:Destroy() 
	end
})

Window:AddLabel({
	Text="Youtube: Crokyreo",
	TextColor3 = Color3.fromRGB(255, 255, 255)
})
