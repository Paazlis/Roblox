--[[
   ToraIsMe | Inspired from here
   akipox | Programming
   Gemini AI | Just help and fix
]]

local Services=setmetatable({},{
	__index=function(_,i) 
		return cloneref and cloneref(game:GetService(i)) or game:GetService(i) 
	end
})

local Players=Services.Players
local RunService=Services.RunService
local UserInputService=Services.UserInputService
local TweenService=Services.TweenService

local LocalPlayer=Players.LocalPlayer
local OFFSET=UDim2.new(0,100,0,50)

local Strs=loadstring(game:HttpGet("https://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/Strs/init.luau"))()

local function IsUIOverlapping(ui1,ui2)
	local pos1,size1=ui1.AbsolutePosition,ui1.AbsoluteSize
	local pos2,size2=ui2.AbsolutePosition,ui2.AbsoluteSize

	local isNotOverlapping=
		(pos1.X+size1.X<pos2.X) or
		(pos2.X+size2.X<pos1.X) or
		(pos1.Y+size1.Y<pos2.Y) or
		(pos2.Y+size2.Y<pos1.Y)
	return not isNotOverlapping
end

local function Create(className,properties)
	properties=typeof(properties)=="table" and properties or {}
	local obj=Instance.new(className)
	for property,value in next,properties do
		obj[property]=value
	end
	return obj
end

local function CallSafely(func,...)
	if func then 
		local success,result=pcall(func,...) 
		if not success then 
			warn("function failed with error:",result)
			return false 
		else 
			return result 
		end 
	end
end

local function ConnectDestroying(instance,func)
	task.defer(function()
		if not (instance and instance.Parent) then func() return end
		instance.Destroying:Connect(func)
		local lastName=instance.Name
		if instance.ClassName=="ScreenGui" then
			if instance and instance.Parent and not instance.Enabled and instance.Name~=lastName then func() return end
			local connection
			connection=instance:GetPropertyChangedSignal("Enabled"):Connect(function()
				if instance and instance.Parent and not instance.Enabled and instance.Name~=lastName then connection:Disconnect() func() end
			end)
		end
	end)
end

local function Tween(instance,tweenInfo,properties)
	TweenService:Create(instance,tweenInfo,properties):Play()
end

local Library={Flags={}}

local function GetComponents(Window)
	local gui,targetContainer=Window.Gui,Window.Container

	local elements={}
	
	function elements:AddButton(options)
		options=typeof(options)=="table" and options or {}
		options.Type="Button"
		options.Name=options.Name or "Button"
		options.Text=options.Text or options.Title or options.Name
		options.Callback=typeof(options.Callback) and options.Callback or function() end

		local main=Create("Frame",{
			Name=options.Type,
			Size=UDim2.new(1,0,0,30),
			BackgroundTransparency=1,
			BorderSizePixel=0,
			Parent=targetContainer
		})

		local title=Create("TextLabel",{
			Name="Title",
			ZIndex=2,
			AnchorPoint=Vector2.new(0.5,0.5),
			Position=UDim2.new(0.5,0,0.5,0),
			Size=UDim2.new(1,0,1,0),
			BackgroundTransparency=1,
			BorderSizePixel=0,
			Text=options.Text,
			TextColor3=Color3.fromRGB(255,255,255),
			Font=Enum.Font.GothamBlack,
			TextSize=12,
			Parent=main
		})

		local round=Create("ImageLabel",{
			Name="Round",
			AnchorPoint=Vector2.new(0.5,0.5),
			Position=UDim2.new(0.5,0,0.5,0),
			Size=UDim2.new(1,0,1,0),
			BackgroundTransparency=1,
			BorderSizePixel=0,
			Image="rbxassetid://3570695787",
			ImageColor3=Color3.fromRGB(40,40,40),
			ScaleType=Enum.ScaleType.Slice,
			SliceCenter=Rect.new(100,100,100,100),
			SliceScale=0.02,
			Parent=main
		})

		function options:Set(text)
			options.Text=text
			title.Text=text
		end

		local inContact,clicking=false,false
		
		local inputBegan=main.InputBegan:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				clicking=true
				Tween(round,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageColor3=Color3.fromRGB(255,65,65)})
				CallSafely(options.Callback)
			end
			if input.UserInputType==Enum.UserInputType.MouseMovement then
				inContact=true
				Tween(round,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageColor3=Color3.fromRGB(60,60,60)})
			end
		end)

		local inputEnded=main.InputEnded:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				clicking=false
				if inContact then
					Tween(round,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageColor3=Color3.fromRGB(60,60,60)})
				else
					Tween(round,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageColor3=Color3.fromRGB(40,40,40)})
				end
			end
			if input.UserInputType==Enum.UserInputType.MouseMovement then
				inContact=false
				if not clicking then
					Tween(round,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageColor3=Color3.fromRGB(40,40,40)})
				end
			end
		end)
		
		ConnectDestroying(gui,function()
			inputBegan:Disconnect()
			inputEnded:Disconnect()
		end)
		
		return setmetatable({},{
			__index=function(_,i)
				if i=="Visible" then 
					return main.Visible
				end
				return options[i]
			end,
			__newindex=function(_,i,v)
				if i ~= "Set" then
					options[i]=v
				end
				if i=="Visible" then
					main.Visible=v
				elseif i=="Text" or i=="Title" then
					title.Text=v
				end

			end
		})
	end

	function elements:AddToggle(options)
		options=typeof(options)=="table" and options or {}
		options.Type="Toggle"
		options.Name=options.Name or "Toggle"
		options.Text=options.Text or options.Title or options.Name
		options.Value=options.Value or false
		options.Callback=typeof(options.Callback) and options.Callback or function() end
		options.NoClean=options.NoClean or false
		if typeof(options.Version)~="number" then
			options.Version=1
		end
		
		local inContact,title,tickboxOutline=false,nil,nil
		
		local main=Create("Frame",{
			Name=options.Type,
			BackgroundTransparency=1,
			BorderSizePixel=0,
			Size=UDim2.new(1,0,0,30),
			Parent=targetContainer
		})
		
		if options.Version==0 then
			title=Create("TextLabel",{
				Name="Title",
				ZIndex=2,
				AnchorPoint=Vector2.new(0.5,0.5),
				Position=UDim2.new(0.5,0,0.5,0),
				Size=UDim2.new(1,0,1,0),
				BackgroundTransparency=1,
				BorderSizePixel=0,
				Text=options.Text,
				TextColor3=Color3.fromRGB(255,255,255),
				Font=Enum.Font.GothamBlack,
				TextSize=12,
				Parent=main
			})

			local round=Create("ImageLabel",{
				Name="Round",
				AnchorPoint=Vector2.new(0.5,0.5),
				Position=UDim2.new(0.5,0,0.5,0),
				Size=UDim2.new(1,0,1,0),
				BackgroundTransparency=1,
				BorderSizePixel=0,
				Image="rbxassetid://3570695787",
				ImageColor3=Color3.fromRGB(40,40,40),
				ScaleType=Enum.ScaleType.Slice,
				SliceCenter=Rect.new(100,100,100,100),
				SliceScale=0.02,
				Parent=main
			})

			function options:Set(value)
				self.Value=value
				if options.Flag then
					Library.Flags[options.Flag]=value
				end
				title.Text=options.Name .. ": " .. (value and "ON" or "OFF")
				Tween(round,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageColor3=value and Color3.fromRGB(60,200,60) or Color3.fromRGB(200,60,60)})
				CallSafely(options.Callback,value)
			end
		elseif options.Version==2 then
			title=Create("TextLabel",{
				Name="Title",
				ZIndex=2,
				AnchorPoint=Vector2.new(0.5,0.5),
				Position=UDim2.new(0.5,0,0.5,0),
				Size=UDim2.new(1,0,1,0),
				BackgroundTransparency=1,
				BorderSizePixel=0,
				Text=" "..options.Text,
				TextColor3=Color3.fromRGB(255,255,255),
				Font=Enum.Font.GothamBlack,
				TextSize=12,
				TextXAlignment=Enum.TextXAlignment.Left,
				Parent=main
			})

			local indicator=Create("Frame",{
				Name="Indicator",
				Size=UDim2.new(0,38,0,18),
				Position=UDim2.new(1,-39,0.5,-9),
				BackgroundColor3=options.Value and Color3.fromRGB(60,200,60) or Color3.fromRGB(75,75,85),
				BorderSizePixel=0,
				Parent=main
			})

			local indicatorText=Create("TextLabel",{
				Name="Title",
				Size=UDim2.new(1,0,1,0),
				BackgroundTransparency=1,
				Text=options.Value and "ON" or "OFF",
				TextColor3=Color3.fromRGB(255,255,255),
				Font=Enum.Font.GothamBlack,
				TextSize=9,
				Parent=indicator
			})

			function options:Set(value)
				self.Value=value
				if options.Flag then
					Library.Flags[options.Flag]=value
				end
				local targetColor=value and Color3.fromRGB(60,200,60) or Color3.fromRGB(75,75,85)
				Tween(indicator,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundColor3=targetColor})
				indicatorText.Text=options.Value and "ON" or "OFF"
				CallSafely(options.Callback,value)
			end
		else
			title=Create("TextLabel",{
				Name="Title",
				ZIndex=2,
				AnchorPoint=Vector2.new(0.5,0.5),
				Position=UDim2.new(0.5,0,0.5,0),
				Size=UDim2.new(1,0,1,0),
				BackgroundTransparency=1,
				BorderSizePixel=0,
				Text=" "..options.Text,
				TextColor3=Color3.fromRGB(255,255,255),
				Font=Enum.Font.GothamBlack,
				TextSize=12,
				TextXAlignment=Enum.TextXAlignment.Left,
				Parent=main
			})

			tickboxOutline=Create("ImageLabel",{
				Position=UDim2.new(1,-6,0,4),
				Size=UDim2.new(-1,10,1,-10),
				SizeConstraint=Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency=1,
				Image="rbxassetid://3570695787",
				ImageColor3=options.Value and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100),
				ScaleType=Enum.ScaleType.Slice,
				SliceCenter=Rect.new(100,100,100,100),
				SliceScale=0.02,
				Parent=main
			})

			local tickboxInner=Create("ImageLabel",{
				Position=UDim2.new(0,2,0,2),
				Size=UDim2.new(1,-4,1,-4),
				BackgroundTransparency=1,
				Image="rbxassetid://3570695787",
				ImageColor3=options.Value and Color3.fromRGB(255,255,255) or Color3.fromRGB(20,20,20),
				ScaleType=Enum.ScaleType.Slice,
				SliceCenter=Rect.new(100,100,100,100),
				SliceScale=0.02,
				Parent=tickboxOutline
			})

			local checkmarkHolder=Create("Frame",{
				Position=UDim2.new(0,4,0,4),
				Size=options.Value and UDim2.new(1,-8,1,-8) or UDim2.new(0,0,1,-8),
				BackgroundTransparency=1,
				ClipsDescendants=true,
				Parent=tickboxOutline
			})

			local checkmark=Create("ImageLabel",{
				Size=UDim2.new(1,0,1,0),
				SizeConstraint=Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency=1,
				Image="rbxassetid://4919148038",
				ImageColor3=Color3.fromRGB(20,20,20),
				Parent=checkmarkHolder
			})

			function options:Set(value)
				if value then value=true else value=false end
				self.Value=value
				if self.Flag then
					Library.Flags[self.Flag]=value
				end
				checkmarkHolder:TweenSize(value and UDim2.new(1,-8,1,-8) or UDim2.new(0,0,1,-8),"Out","Quad",0.2,true)
				Tween(tickboxInner,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageColor3=value and Color3.fromRGB(255,255,255) or Color3.fromRGB(20,20,20)})
				Tween(tickboxOutline,TweenInfo.new(value and 0.2 or 0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageColor3=value and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100)})
				if not value then
					Tween(tickboxOutline,TweenInfo.new(inContact and 0.2 or 0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageColor3=inContact and Color3.fromRGB(140,140,140) or Color3.fromRGB(100,100,100)})
				end
				CallSafely(self.Callback,value)
			end
		end
		
		if options.Flag then
			Library.Flags[options.Flag]=options
		end
		
		local inputBegan=main.InputBegan:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				options:Set(not options.Value)
			end
			if input.UserInputType==Enum.UserInputType.MouseMovement then
				inContact=true
				if not options.Value and tickboxOutline~=nil then
					Tween(tickboxOutline,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageColor3=Color3.fromRGB(140,140,140)})
				end
			end
		end)
		
		local inputEnded=main.InputEnded:connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseMovement then
				if not options.Value and tickboxOutline ~= nil then
					Tween(tickboxOutline,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageColor3=Color3.fromRGB(100,100,100)})
				end
			end
		end)
		
		ConnectDestroying(gui,function()
			inputBegan:Disconnect()
			inputEnded:Disconnect()
			if options.NoClean then return end
			options:Set(false)
		end)
		
		return setmetatable({},{
			__index=function(_,i)
				if i=="Visible" then 
					return main.Visible
				end
				return options[i]
			end,
			__newindex=function(_,i,v)
				if i ~= "Set" then
					options[i]=v
				end
				if i=="Visible" then
					main.Visible=v
				elseif i=="Text" or i=="Title" then
					title.Text=v
				end

			end
		})
	end

	function elements:AddSlider(options)
		options=typeof(options)=="table" and options or {}
		options.Type="Slider"
		options.Name=options.Name or "Slider"
		options.Text=options.Text or options.Title or options.Name
		options.Range=options.Range or {0,100}
		options.Value=typeof(options.Value)=="number" and options.Value or options.Range[1]

		local main=Create("Frame",{
			Name=options.Type,
			Size=UDim2.new(1,0,0,45),
			BackgroundTransparency=1,
			Parent=targetContainer
		})

		local title=Create("TextLabel",{
			Name="Title",
			Size=UDim2.new(1,0,0,20),
			BackgroundTransparency=1,
			Text=options.Text .. ": " .. options.Value,
			TextColor3=Color3.fromRGB(255,255,255),
			Font=Enum.Font.GothamBlack,-- Updated Font
			TextSize=12,
			BorderSizePixel=0,
			Parent=main
		})

		local track=Create("Frame",{
			Name="Track",
			BackgroundColor3=Color3.fromRGB(50,50,50),
			BorderSizePixel=0,
			Size=UDim2.new(1,0,0,10),
			Position=UDim2.new(0,0,0,25),
			Parent=main,
		})

		local fill=Create("Frame",{
			Name="Fill",
			BackgroundColor3=Color3.fromRGB(60,150,200),
			Size=UDim2.new((options.Value-options.Range[1]) / (options.Range[2]-options.Range[1]),0,1,0),
			BorderSizePixel=0,
			Parent=track
		})

		function options:Set(value)
			local min,max=options.Range[1],options.Range[2]
			value=math.clamp(value,min,max)
			self.Value=value
			local percentage=(value-min)/(max-min)
			fill.Size=UDim2.new(percentage,0,1,0)
			title.Text=self.Name .. ": " .. Strs.T(value)
			CallSafely(options.Callback,value)
		end
		
		options:Set(options.Value)
		
		if options.Flag then
			Library.Flags[options.Flag]=options
		end
		
		local inputBegan=main.InputBegan:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				local min,max=options.Range[1],options.Range[2]
				local mouse=LocalPlayer:GetMouse()
				local percentage=math.clamp((mouse.X-track.AbsolutePosition.X) / track.AbsoluteSize.X,0,1)
				local value=math.floor(min+((max-min)*percentage))
				options:Set(value)
			end
		end)

		ConnectDestroying(gui,function()
			inputBegan:Disconnect()
		end)
		
		return setmetatable({},{
			__index=function(_,i)
				if i=="Visible" then 
					return main.Visible
				end
				return options[i]
			end,
			__newindex=function(_,i,v)
				if i ~= "Set" then
					options[i]=v
				end
				if i=="Visible" then
					main.Visible=v
				elseif i=="Text" or i=="Title" then
					title.Text=v
				end

			end
		})
	end

	function elements:AddLabel(options)
		-- Normalize Options and Track Type Properties
		options=typeof(options)=="table" and options or (typeof(options)=="string" and {Name=options} or {})
		options.Type="Label"
		options.Name=options.Name or "Label"
		options.Text=options.Text or options.Title or options.Name

		local main=Create("Frame",{
			Name=options.Type,
			Size=UDim2.new(1,0,0,24),
			BackgroundTransparency=1,
			Parent=targetContainer
		})

		local title=Create("TextLabel",{
			Name="Title",
			ZIndex=2,
			AnchorPoint=Vector2.new(0.5,0.5),
			Position=UDim2.new(0.5,0,0.5,0),
			Size=UDim2.new(1,0,1,0),
			BackgroundTransparency=1,
			BorderSizePixel=0,
			Text=options.Text,
			TextColor3=Color3.fromRGB(180,180,190),
			Font=Enum.Font.GothamBlack,
			TextSize=12,
			TextXAlignment=Enum.TextXAlignment.Left,
			Parent=main
		})
		
		function options:Set(text)
			title.Text=text
		end

		return setmetatable({},{
			__index=function(_,i)
				if i=="Visible" then 
					return main.Visible
				end
				return options[i]
			end,
			__newindex=function(_,i,v)
				if i ~= "Set" then
					options[i]=v
				end
				if i=="Visible" then
					main.Visible=v
				elseif i=="Text" or i=="Title" then
					title.Text=v
				end

			end
		})
	end

	function elements:AddFolder(options)
		options=typeof(options)=="table" and options or (typeof(options)=="string" and {Name=options} or {})
		options.Type="Folder"
		options.Name=options.Name or "Folder"
		options.Open=options.Open or false
		options.NoClean=options.NoClean or false
		
		local main=Create("Frame",{
			Name=options.Type,
			Parent=targetContainer,
			Size=UDim2.new(1,0,0,0),
			AutomaticSize=Enum.AutomaticSize.Y,
			BackgroundTransparency=1
		})

		Create("UIListLayout",{
			Parent=main,
			Padding=UDim.new(0,5),
			HorizontalAlignment=Enum.HorizontalAlignment.Center,
			SortOrder=Enum.SortOrder.LayoutOrder
		})

		local title=Create("TextLabel",{
			Name="Title",
			Size=UDim2.new(1,0,0,28),
			BackgroundColor3=Color3.fromRGB(45,45,52),
			Text=options.Name,
			TextColor3=Color3.fromRGB(255,255,255),
			Font=Enum.Font.GothamBold,
			TextSize=12,
			BorderSizePixel=0,
			TextXAlignment=Enum.TextXAlignment.Center,
			Parent=main
		})

		local closeHolder=Create("Frame",{
			Name="Close",
			Position=UDim2.new(1,0,0,0),
			Size=UDim2.new(-1,0,1,0),
			SizeConstraint=Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency=1,
			Parent=title
		})

		local close=Create("ImageLabel",{
			Name="Icon",
			AnchorPoint=Vector2.new(0.5,0.5),
			Position=UDim2.new(0.5,0,0.5,0),
			Size=UDim2.new(1,-20,1,-20),
			BackgroundTransparency=1,
			Rotation=options.Open and 90 or 180,
			Image="rbxassetid://4918373417",
			ImageColor3=Color3.fromRGB(255,255,255),
			ScaleType=Enum.ScaleType.Fit,
			Parent=closeHolder
		})

		local folderContainer=Create("Frame",{
			Name="Container",
			Size=UDim2.new(1,0,0,0),
			AutomaticSize=Enum.AutomaticSize.Y,
			BackgroundTransparency=1,
			Visible=false,
			Parent=main
		})

		Create("UIListLayout",{
			Padding=UDim.new(0,5),
			HorizontalAlignment=Enum.HorizontalAlignment.Center,
			SortOrder=Enum.SortOrder.LayoutOrder,
			Parent=folderContainer
		})

		Create("UIPadding",{
			PaddingLeft=UDim.new(0,0),
			PaddingRight=UDim.new(0,0),
			Parent=folderContainer,
		})
		
		function options:Set(open)
			if open then open=true else open=false end
			self.Open=open
			Tween(close,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Rotation=open and 90 or 180})
			folderContainer.Visible=open
		end
		
		if options.Flag then
			Library.Flags[options.Flag]=options
		end
		
		local inputBegan=closeHolder.InputBegan:connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				options:Set(not options.Open)
			end
		end)
		
		ConnectDestroying(gui,function()
			inputBegan:Disconnect()
			if options.NoClean then return end
			options:Set(false)
		end)
		
		local newElements=GetComponents({Gui=gui,Container=folderContainer})

		return setmetatable({},{
			__index=function(_,i)
				if i=="Visible" then 
					return main.Visible
				end
				return newElements[i] or options[i]
			end,
			__newindex=function(_,i,v)
				if i ~= "Set" then
					options[i]=v
				end
				if i=="Visible" then
					main.Visible=v
				elseif i=="Text" or i=="Title" then
					title.Text=v
				end

			end
		})
	end
	
	return elements
end

function Library:MakeDraggable(bar,frame)
	local dragging,dragInput,dragStart,startPos

	local inputBegan=bar.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dragging=true
			dragStart=input.Position
			startPos=frame.Position

			local connection
			connection=input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging=false
					connection:Disconnect()
				end
			end)
		end
	end)

	local inputChanged2=bar.InputChanged:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
			dragInput=input
		end
	end)

	local inputChanged1=UserInputService.InputChanged:Connect(function(input)
		if input==dragInput and dragging then
			local delta=input.Position-dragStart
			frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
		end
	end)

	return function()
		inputChanged1:Disconnect()
		inputChanged2:Disconnect()
		inputBegan:Disconnect()
	end
end

function Library:GetProtectGui(gui)
	local parentGui=nil

	if syn and syn.protect_gui then
		syn.protect_gui(gui)
	elseif get_hidden_gui then
		get_hidden_gui(gui)
	elseif gethui then
		parentGui=gethui(gui) 
	else
		LocalPlayer:Kick("Error: protect_gui function not found")
		return nil
	end

	return parentGui or Services.CoreGui
end


function Library:CreateWindow(config)
	config=typeof(config)=="table" and config or {}

	local Window={}
	Window.Name=config.Name or "Sampluy"
	Window.OldName=config.Name.."-Old"
	Window.Text=config.Text or config.Name or "Panel"
	Window.MaxHeight=config.MaxHeight or 320
	Window.Size=config.Size or UDim2.new(0,230,0,40)
	Window.Open=config.Open or true

	local gui=Create("ScreenGui",{
		Name=Window.Name,
		ResetOnSpawn=false
	})

	local protectGui=Library:GetProtectGui(gui)
	
	for _,interface in ipairs(protectGui:GetChildren()) do
		if interface.Name==Window.Name and interface~=gui then
			interface.Enabled=false
			interface.Name=Window.OldName
		end
	end

	gui.Parent=protectGui
	
	local mainFrame=Create("ImageLabel",{
		Name="Main",
		BackgroundTransparency=1,
		BorderSizePixel=0,
		Size=Window.Size,
		Position=UDim2.new(0,20,0,20),
		Image="rbxassetid://3570695787",
		ImageColor3=Color3.fromRGB(10,10,10),
		ScaleType=Enum.ScaleType.Slice,
		SliceCenter=Rect.new(100,100,100,100),
		SliceScale=0.04,
		ClipsDescendants=true,
		Parent=gui
	})
	
	for _,interface in ipairs(protectGui:GetChildren()) do
		if interface~=gui then
			for _,lastMainFrame in ipairs(interface:GetChildren()) do
				if lastMainFrame.ClassName=="ImageLabel" and lastMainFrame.Name=="Main" and IsUIOverlapping(mainFrame,lastMainFrame) then
					lastMainFrame.Position=mainFrame.Position+OFFSET
				end
			end
		end
	end
	
	local titleBar=Create("TextLabel",{
		Size=UDim2.new(1,0,0,40),
		BackgroundTransparency=1,
		BorderSizePixel=0,
		Text=Window.Text,
		TextColor3=Color3.fromRGB(255,255,255),
		Font=Enum.Font.LuckiestGuy,
		TextSize=12,
		Parent=mainFrame
	})

	local closeHolder=Create("Frame",{
		Name="Close",
		Position=UDim2.new(1,0,0,0),
		Size=UDim2.new(-1,0,1,0),
		SizeConstraint=Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency=1,
		Parent=titleBar
	})

	local close=Create("ImageLabel",{
		Name="Icon",
		AnchorPoint=Vector2.new(0.5,0.5),
		Position=UDim2.new(0.5,0,0.5,0),
		Size=UDim2.new(1,-Window.Size.Y.Offset-10,1,-Window.Size.Y.Offset-10),
		BackgroundTransparency=1,
		Rotation=Window.Open and 90 or 180,
		Image="rbxassetid://4918373417",
		ImageColor3=Color3.fromRGB(255,255,255),
		ScaleType=Enum.ScaleType.Fit,
		Parent=closeHolder
	})

	local scrollFrame=Create("ScrollingFrame",{
		Size=UDim2.new(1,0,0,0),
		Position=UDim2.new(0,0,0,40),
		BackgroundTransparency=0,
		BackgroundColor3=Color3.fromRGB(20,20,20),
		BorderSizePixel=0,
		ScrollBarThickness=4,
		ScrollBarImageColor3=Color3.fromRGB(100,100,110),
		ClipsDescendants=true,
		CanvasSize=UDim2.new(0,0,0,0),
		Parent=mainFrame
	})

	local contentHolder=Create("Frame",{
		AnchorPoint=Vector2.new(0.5,0),
		Size=UDim2.new(1,-16,0,0),
		Position=UDim2.new(0.5,0,0,0),
		AutomaticSize=Enum.AutomaticSize.Y,
		BackgroundTransparency=1,
		Parent=scrollFrame
	})

	Create("UIListLayout",{
		Parent=contentHolder,
		Padding=UDim.new(0,6),
		HorizontalAlignment=Enum.HorizontalAlignment.Center,
		SortOrder=Enum.SortOrder.LayoutOrder
	})

	local function UpdateWindowSize(animated)
		local contentHeight=contentHolder.AbsoluteSize.Y
		local targetMainSize,targetScrollSize

		if not Window.Open then
			targetMainSize=Window.Size
			targetScrollSize=UDim2.new(1,0,0,0)
		else
			local allowedContentHeight=math.min(contentHeight+6,Window.MaxHeight-Window.Size.Y.Offset)
			targetMainSize=UDim2.new(Window.Size.X.Scale,Window.Size.X.Offset,Window.Size.Y.Scale,Window.Size.Y.Offset+allowedContentHeight)
			targetScrollSize=UDim2.new(1,0,0,allowedContentHeight)
		end

		if animated then
			Tween(mainFrame,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=targetMainSize})
			Tween(scrollFrame,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=targetScrollSize})
		else
			mainFrame.Size=targetMainSize
			scrollFrame.Size=targetScrollSize
		end
	end
	
	local absoluteSizeChanged=contentHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		scrollFrame.CanvasSize=UDim2.new(0,0,0,contentHolder.AbsoluteSize.Y+6)
		UpdateWindowSize(true)
	end)
	
	local inputBegan=closeHolder.InputBegan:connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			Window.Open=not Window.Open
			Tween(close,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Rotation=Window.Open and 90 or 180})
			UpdateWindowSize(true)
		end
	end)
	
	local cleanDraggable=Library:MakeDraggable(titleBar,mainFrame)
	ConnectDestroying(gui,function()
		cleanDraggable()
		inputBegan:Disconnect()
		Window.Open=false
		Tween(close,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Rotation=180})
		UpdateWindowSize(false)
		task.wait(0.2)
		absoluteSizeChanged:Disconnect()
	end)

	Window.Container=contentHolder
	Window.Gui=gui
	
	function Window:Destroy()
		gui.Enabled=false
		gui.Name=Window.OldName
	end
	
	local baseComponents=GetComponents(Window)
	for k,v in next,baseComponents do
		Window[k]=v
	end
	return Window
end

return Library
