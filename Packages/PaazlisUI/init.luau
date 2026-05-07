-- Create by @Paazlis and OYB for KeySystem in Youtube
-- Version: 1.72

if type(_G.PaazlisUI)=="table" then return _G.PaazlisUI end

local Missing=function(t,v,f)
	return typeof(v)==t and v or f
end

cloneref,setclipboard=Missing("function",cloneref,function(v) return v end),Missing("function",setclipboard,function(x) warn(x) return x end)

local GetService=function(name)
	local service=game:GetService(name)
	if cloneref then return cloneref(service) else return service end
end

-- Safe request function for universal executor support
local function SafeRequest(options)
	local req=(syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request
	if not req then return nil,"HTTP requests not supported" end
	local success,response=pcall(function() return req(options) end)
	if success and response then return response else return nil,"Connection Error" end
end

-- The function below provides a safe alternative for calling error-prone functions
-- Especially useful for filesystem function (writefile, makefolder, etc.)
local function CallSafely(func,...)
	if func then
		local success,result=pcall(func,...)
		if not success then
			warn("function failed with error: ",result)
			return false
		else
			return result
		end
	end
end

-- Ensures a folder exists by creating it if needed
local function EnsureFolder(folderPath)
	if isfolder and not CallSafely(isfolder, folderPath) then
		CallSafely(makefolder, folderPath)
	end
end

local Services={}

for i,v in ipairs({'Players','UserInputService','TweenService','StarterGui','RunService'}) do 
	if not Services[v] then 
		local success,service=pcall(GetService,v) 
		if success and service then 
			Services[v]=service 
		end 
	end 
end

local RunService=Services["RunService"]
if not RunService:IsClient() then
	error("PaazlisUI only works on client")
	return
end

local GlobalData={
	["Others"]={
		{
			["PlayerPicker"]=true,
			["Label"]=true,
			["Switch"]=true,
			["TextLabel"]=true,
			["Button"]=true,
			["Field"]=true,
			["TextBox"]=true,
			["TextButton"]=true,
			["Selector"]=true,
			["Toggle"]=true,
			["Select"]=true,
			["Dropdown"]=true,
		},
		{
			[true]="■",
			[false]="□"
		},
		{
			[true]=Color3.fromRGB(0,200,97),
			[false]=Color3.fromRGB(255,89,89)
		}
	}
}

local Notifications,Module={},{}

local UILibrary={
	Loaded=false,
	Theme={
		"Default","Dark","Ocean","AmberGlow","Light","Amethyst","Green","Bloom","DarkBlue","Serenity",

		Default={
			TextColor=Color3.fromRGB(255,255,255),
			Background=Color3.fromRGB(25,26,31),
			Topbar=Color3.fromRGB(57,59,61),

			Notification={
				Background=Color3.fromRGB(57,59,61),
				ActionsBackground=Color3.fromRGB(230,230,230),
				TitleColor=Color3.fromRGB(255,255,255),
				DescriptionColor=Color3.fromRGB(200,200,200)
			},

			Button={
				Background=Color3.fromRGB(25,25,25)
			},

			Select={
				EnableColor=Color3.fromRGB(0,200,97),
				DisableColor=Color3.fromRGB(255,89,89)
			},

			Input={
				Background=Color3.fromRGB(30,30,30),
				Stroke=Color3.fromRGB(65,65,65)
			},
			PlaceholderColor=Color3.fromRGB(178,178,178)
		},

		Dark={
			TextColor=Color3.fromRGB(240,240,240),
			Background=Color3.fromRGB(25,25,25),
			Topbar=Color3.fromRGB(34,34,34),

			Notification={
				Background=Color3.fromRGB(20,20,20),
				ActionsBackground=Color3.fromRGB(230,230,230),
				TitleColor=Color3.fromRGB(240,240,240),
				DescriptionColor=Color3.fromRGB(200,200,200)
			},

			Button={
				Background=Color3.fromRGB(25,25,25)
			},

			Select={
				EnableColor=Color3.fromRGB(0,200,97),
				DisableColor=Color3.fromRGB(255,89,89)
			},

			Input={
				Background=Color3.fromRGB(30,30,30),
				Stroke=Color3.fromRGB(65,65,65)
			},
			PlaceholderColor=Color3.fromRGB(178,178,178)
		},

		Ocean={
			TextColor=Color3.fromRGB(230,240,240),
			Background=Color3.fromRGB(20,30,30),
			Topbar=Color3.fromRGB(25,40,40),

			Notification={
				Background=Color3.fromRGB(25,35,35),
				ActionsBackground=Color3.fromRGB(230,240,240),
				TitleColor=Color3.fromRGB(230,240,240),
				DescriptionColor=Color3.fromRGB(200,200,200)
			},

			Button={
				Background=Color3.fromRGB(20,30,30)
			},

			Select={
				EnableColor=Color3.fromRGB(0,200,97),
				DisableColor=Color3.fromRGB(255,89,89)
			},

			Input={
				Background=Color3.fromRGB(30,50,50),
				Stroke=Color3.fromRGB(50,70,70)
			},
			PlaceholderColor=Color3.fromRGB(140,160,160)
		},

		AmberGlow={
			TextColor=Color3.fromRGB(255,245,230),
			Background=Color3.fromRGB(45,30,20),
			Topbar=Color3.fromRGB(55,40,25),

			Notification={
				Background=Color3.fromRGB(50,35,25),
				ActionsBackground=Color3.fromRGB(245,230,215),
				TitleColor=Color3.fromRGB(255,245,230),
				DescriptionColor=Color3.fromRGB(200,200,200)
			},

			Button={
				Background=Color3.fromRGB(45,30,20)
			},

			Select={
				EnableColor=Color3.fromRGB(0,200,97),
				DisableColor=Color3.fromRGB(255,89,89)
			},

			Input={
				Background=Color3.fromRGB(60,45,35),
				Stroke=Color3.fromRGB(90,65,50)
			},
			PlaceholderColor=Color3.fromRGB(190,150,130)
		},

		Light={
			TextColor=Color3.fromRGB(40,40,40),
			Background=Color3.fromRGB(245,245,245),
			Topbar=Color3.fromRGB(230,230,230),

			Notification={
				Background=Color3.fromRGB(250,250,250),
				ActionsBackground=Color3.fromRGB(240,240,240),
				TitleColor=Color3.fromRGB(40,40,40),
				DescriptionColor=Color3.fromRGB(200,200,200)
			},

			Button={
				Background=Color3.fromRGB(245,245,245)
			},

			Select={
				EnableColor=Color3.fromRGB(0,200,97),
				DisableColor=Color3.fromRGB(255,89,89)
			},

			Input={
				Background=Color3.fromRGB(240,240,240),
				Stroke=Color3.fromRGB(180,180,180)
			},
			PlaceholderColor=Color3.fromRGB(140,140,140)
		},

		Amethyst={
			TextColor=Color3.fromRGB(240,240,240),
			Background=Color3.fromRGB(30,20,40),
			Topbar=Color3.fromRGB(40,25,50),

			Notification={
				Background=Color3.fromRGB(35,20,40),
				ActionsBackground=Color3.fromRGB(240,240,250),
				TitleColor=Color3.fromRGB(240,240,240),
				DescriptionColor=Color3.fromRGB(200,200,200)
			},

			Button={
				Background=Color3.fromRGB(30,20,40)
			},

			Select={
				EnableColor=Color3.fromRGB(0,200,97),
				DisableColor=Color3.fromRGB(255,89,89)
			},

			Input={
				Background=Color3.fromRGB(45,30,60),
				Stroke=Color3.fromRGB(80,50,110)
			},
			PlaceholderColor=Color3.fromRGB(178,150,200)
		},

		Green={
			TextColor=Color3.fromRGB(30,60,30),
			Background=Color3.fromRGB(235,245,235),
			Topbar=Color3.fromRGB(210,230,210),

			Notification={
				Background=Color3.fromRGB(240,250,240),
				ActionsBackground=Color3.fromRGB(220,235,220),
				TitleColor=Color3.fromRGB(30,60,30),
				DescriptionColor=Color3.fromRGB(200,200,200)
			},

			Button={
				Background=Color3.fromRGB(235,245,235)
			},

			Select={
				EnableColor=Color3.fromRGB(0,200,97),
				DisableColor=Color3.fromRGB(255,89,89)
			},

			Input={
				Background=Color3.fromRGB(235,245,235),
				Stroke=Color3.fromRGB(180,200,180)
			},
			PlaceholderColor=Color3.fromRGB(120,140,120)
		},

		Bloom={
			TextColor=Color3.fromRGB(60,40,50),
			Background=Color3.fromRGB(255,240,245),
			Topbar=Color3.fromRGB(250,220,225),

			Notification={
				Background=Color3.fromRGB(255,235,240),
				ActionsBackground=Color3.fromRGB(245,215,225),
				TitleColor=Color3.fromRGB(60,40,50),
				DescriptionColor=Color3.fromRGB(200,200,200)
			},

			Button={
				Background=Color3.fromRGB(255,240,245)
			},

			Select={
				EnableColor=Color3.fromRGB(0,200,97),
				DisableColor=Color3.fromRGB(255,89,89)
			},

			Input={
				Background=Color3.fromRGB(255,235,240),
				Stroke=Color3.fromRGB(220,190,200)
			},
			PlaceholderColor=Color3.fromRGB(170,130,140)
		},

		DarkBlue={
			TextColor=Color3.fromRGB(230,230,230),
			Background=Color3.fromRGB(20,25,30),
			Topbar=Color3.fromRGB(30,35,40),

			Notification={
				Background=Color3.fromRGB(25,30,35),
				ActionsBackground=Color3.fromRGB(45,50,55),
				TitleColor=Color3.fromRGB(230,230,230),
				DescriptionColor=Color3.fromRGB(200,200,200)
			},

			Button={
				Background=Color3.fromRGB(20,25,30)
			},

			Select={
				EnableColor=Color3.fromRGB(0,200,97),
				DisableColor=Color3.fromRGB(255,89,89)
			},

			Input={
				InputBackground=Color3.fromRGB(25,30,35),
				InputStroke=Color3.fromRGB(45,50,60)
			},
			PlaceholderColor=Color3.fromRGB(150,150,160)
		},

		Serenity={
			TextColor=Color3.fromRGB(50,55,60),
			Background=Color3.fromRGB(240,245,250),
			Topbar=Color3.fromRGB(215,225,235),

			Notification={
				Background=Color3.fromRGB(210,220,230),
				ActionsBackground=Color3.fromRGB(225,230,240),
				TitleColor=Color3.fromRGB(50,55,60),
				DescriptionColor=Color3.fromRGB(150,150,150)
			},

			Button={
				Background=Color3.fromRGB(240,245,250)
			},

			Select={
				EnableColor=Color3.fromRGB(0,200,97),
				DisableColor=Color3.fromRGB(255,89,89)
			},

			Input={
				Background=Color3.fromRGB(220,230,240),
				Stroke=Color3.fromRGB(180,190,200)
			},
			PlaceholderColor=Color3.fromRGB(150,150,150)
		}
	}
}

_G.PaazlisUI=UILibrary

local Players:Players,UserInputService,TweenService,StarterGui=Services["Players"],Services["UserInputService"],Services["TweenService"],Services["StarterGui"]

local LocalPlayer=Players.LocalPlayer
local Mouse=LocalPlayer:GetMouse()
local OFFSET=UDim2.new(0,100,0,50) -- geser 100px kanan, 50px bawah

local NameTypes,TurnSysmbols,TurnColors=unpack(GlobalData.Others)
local baseX,baseY=1024,768
local UseStudio=RunService:IsStudio()

function Module:CreateCanvas(Gui)
	local Frame=Instance.new("Frame")
	Frame.Name="Frame"
	Frame.BackgroundColor3=Color3.fromRGB(57,59,61)
	Frame.BackgroundTransparency=0
	Frame.BorderSizePixel=0
	Frame.Position=UDim2.new(0.1,0,0.38,0)
	Frame.Size=UDim2.new(0,180,0,34)
	Frame.Parent=Gui

	local Title=Instance.new("TextLabel")
	Title.Name="Title"
	Title.BackgroundTransparency=1
	Title.BorderSizePixel=0
	Title.Position=UDim2.new(0,0,0,0)
	Title.Size=UDim2.new(1,0,1,0)
	Title.TextSize=18
	Title.Font=Enum.Font.SourceSansBold
	Title.TextColor3=Color3.fromRGB(248,248,248)
	Title.Text="Title Here"
	Title.Parent=Frame

	local Open=Instance.new("TextButton")
	Open.Name="Open"
	Open.BackgroundTransparency=1
	Open.Position=UDim2.new(0.85,0,0.05,0)
	Open.BorderSizePixel=0
	Open.Size=UDim2.new(0.15,0,0.8,0)
	Open.TextSize=18
	Open.Font=Enum.Font.SourceSansBold
	Open.TextColor3=Color3.fromRGB(248,248,248)
	Open.Text="v"
	Open.Parent=Frame

	local Container=Instance.new("ScrollingFrame")
	Container.Name="Container"
	Container.BackgroundColor3=Color3.fromRGB(57,59,61)
	Container.BackgroundTransparency=0
	Container.BorderSizePixel=0
	Container.Position=UDim2.new(0,0,1,0)
	Container.Size=UDim2.new(1,0,0,200)
	Container.BorderSizePixel=0
	Container.CanvasSize=UDim2.new(0,0,0,0)
	Container.ScrollBarThickness=0
	Container.ScrollingDirection=Enum.ScrollingDirection.Y
	Container.Selectable=false
	Container.AutomaticCanvasSize=Enum.AutomaticSize.Y
	Container.Parent=Frame

	local UIListLayout=Instance.new("UIListLayout")
	UIListLayout.SortOrder=Enum.SortOrder.LayoutOrder
	UIListLayout.Parent=Container

	local UIPadding=Instance.new("UIPadding")
	UIPadding.PaddingBottom=UDim.new(0,5)
	UIPadding.PaddingLeft=UDim.new(0,5)
	UIPadding.PaddingRight=UDim.new(0,5)
	UIPadding.PaddingTop=UDim.new(0,5)
	UIPadding.Parent=Container

	-- TextButton, TextLabel, TextBox
	local Template=Instance.new("Frame")
	Template.Name="Template"
	Template.BackgroundTransparency=1
	Template.BorderSizePixel=0
	Template.Position=UDim2.new(0,0,0,0)
	Template.Size=UDim2.new(1,0,0,30)
	Template.Parent=Container

	local TextButton=Instance.new("TextButton")
	TextButton.Name="TextButton"
	TextButton.BackgroundColor3=Color3.fromRGB(163,162,165)
	TextButton.BackgroundTransparency=0
	TextButton.BorderSizePixel=0
	TextButton.Position=UDim2.new(0.049,0,0.123,0)
	TextButton.Size=UDim2.new(0.9,0,0.753,0)
	TextButton.Text="Text Here"
	TextButton.Font=Enum.Font.SourceSansBold
	TextButton.TextStrokeTransparency=1
	TextButton.TextTransparency=0
	TextButton.TextColor3=Color3.fromRGB(248,248,248)
	TextButton.TextSize=18
	TextButton.Parent=Template

	local TextBox=Instance.new("TextBox")
	TextBox.Name="TextBox"
	TextBox.BackgroundColor3=Color3.fromRGB(163,162,165)
	TextBox.BackgroundTransparency=0
	TextBox.BorderSizePixel=0
	TextBox.Position=UDim2.new(0.049,0,0.123,0)
	TextBox.Size=UDim2.new(0.9,0,0.753,0)
	TextBox.PlaceholderText="Text Here"
	TextBox.Font=Enum.Font.SourceSansBold
	TextBox.TextStrokeTransparency=1
	TextBox.TextTransparency=0
	TextBox.PlaceholderColor3=Color3.fromRGB(248,248,248)
	TextBox.TextColor3=Color3.fromRGB(248,248,248)
	TextBox.TextSize=18
	TextBox.Parent=Template

	local TextLabel=Instance.new("TextLabel")
	TextLabel.Name="TextLabel"
	TextLabel.BackgroundTransparency=1
	TextLabel.BorderSizePixel=0
	TextLabel.Position=UDim2.new(0,0,0,0)
	TextLabel.Size=UDim2.new(1,0,1,0)
	TextLabel.Text="Text Here"
	TextLabel.Font=Enum.Font.SourceSansBold
	TextLabel.TextStrokeTransparency=1
	TextLabel.TextTransparency=0
	TextLabel.TextColor3=Color3.fromRGB(248,248,248)
	TextLabel.TextSize=18
	TextLabel.Parent=Template

	Template.Parent=nil

	-- Toggle
	local Toggle=Instance.new("Frame")
	Toggle.Name="Toggle"
	Toggle.BackgroundTransparency=1
	Toggle.BorderSizePixel=0
	Toggle.Position=UDim2.new(0,0,0,0)
	Toggle.Size=UDim2.new(1,0,0,30)
	Toggle.Parent=Container

	local TextLabel2=Instance.new("TextLabel")
	TextLabel2.Name="TextLabel"
	TextLabel2.BackgroundTransparency=1
	TextLabel2.BorderSizePixel=0
	TextLabel2.Position=UDim2.new(0.049,0,0.123,0)
	TextLabel2.Size=UDim2.new(0.682,0,0.753,0)
	TextLabel2.Text="Text Here"
	TextLabel2.Font=Enum.Font.SourceSansBold
	TextLabel2.TextStrokeTransparency=1
	TextLabel2.TextTransparency=0
	TextLabel2.TextColor3=Color3.fromRGB(248,248,248)
	TextLabel2.TextScaled=true
	TextLabel2.Parent=Toggle

	local TextButton2=Instance.new("TextButton")
	TextButton2.Name="TextButton"
	TextButton2.BackgroundTransparency=1
	TextButton2.BorderSizePixel=0
	TextButton2.AutoButtonColor=false
	TextButton2.Position=UDim2.new(0.767,0,0.123,0)
	TextButton2.Size=UDim2.new(0.179,0,0.753,0)
	TextButton2.Text="□"
	TextButton2.Font=Enum.Font.SourceSansBold
	TextButton2.TextStrokeTransparency=1
	TextButton2.TextTransparency=0
	TextButton2.TextColor3=Color3.fromRGB(248,248,248)
	TextButton2.TextScaled=true
	TextButton2.Parent=Toggle

	Toggle.Parent=nil

	-- Selector
	local Selector=Instance.new("Frame")
	Selector.Name="Selector"
	Selector.BackgroundTransparency=1
	Selector.BorderSizePixel=0
	Selector.Position=UDim2.new(0,0,0,0)
	Selector.Size=UDim2.new(1,0,0,30)
	Selector.Parent=Container

	local TextLabel3=Instance.new("TextLabel")
	TextLabel3.Name="TextLabel"
	TextLabel3.BackgroundTransparency=1
	TextLabel3.BorderSizePixel=0
	TextLabel3.Position=UDim2.new(0,0,0,0)
	TextLabel3.Size=UDim2.new(1,0,1,0)
	TextLabel3.Text="Option 1"
	TextLabel3.Font=Enum.Font.SourceSansBold
	TextLabel3.TextStrokeTransparency=1
	TextLabel3.TextTransparency=0
	TextLabel3.TextColor3=Color3.fromRGB(248,248,248)
	TextLabel3.TextSize=18
	TextLabel3.Parent=Selector

	local Next=Instance.new("TextButton")
	Next.Name="Next"
	Next.AutoButtonColor=false
	Next.BackgroundTransparency=1
	Next.BorderSizePixel=0
	Next.Position=UDim2.new(0.806,0,0,0)
	Next.Size=UDim2.new(0.194,0,1,0)
	Next.Font=Enum.Font.SourceSansBold
	Next.TextColor3=Color3.fromRGB(248,248,248)
	Next.TextTransparency=1
	Next.Text=""
	Next.Parent=Selector

	local TextLabel4=Instance.new("TextLabel")
	TextLabel4.Name="TextLabel"
	TextLabel4.AnchorPoint=Vector2.new(0.5,0.5)
	TextLabel4.BackgroundTransparency=1
	TextLabel4.BorderSizePixel=0
	TextLabel4.Position=UDim2.new(0.5,0,0.5,0)
	TextLabel4.Size=UDim2.new(1,0,1,0)
	TextLabel4.Text=">"
	TextLabel4.Font=Enum.Font.SourceSansBold
	TextLabel4.TextStrokeTransparency=1
	TextLabel4.TextTransparency=0
	TextLabel4.TextColor3=Color3.fromRGB(248,248,248)
	TextLabel4.TextScaled=true
	TextLabel4.Parent=Next

	local Previous=Instance.new("TextButton")
	Previous.Name="Previous"
	Previous.AutoButtonColor=false
	Previous.BackgroundTransparency=1
	Previous.BorderSizePixel=0
	Previous.Position=UDim2.new(0,0,0,0)
	Previous.Size=UDim2.new(0.194,0,1,0)
	Previous.TextScaled=true
	Previous.Font=Enum.Font.SourceSansBold
	Previous.TextColor3=Color3.fromRGB(248,248,248)
	Previous.TextTransparency=1
	Previous.Text=""
	Previous.Parent=Selector

	local TextLabel5=Instance.new("TextLabel")
	TextLabel5.Name="TextLabel"
	TextLabel5.AnchorPoint=Vector2.new(0.5,0.5)
	TextLabel5.BackgroundColor3=Color3.fromRGB(163,162,165)
	TextLabel5.BackgroundTransparency=1
	TextLabel5.BorderSizePixel=0
	TextLabel5.Position=UDim2.new(0.5,0,0.5,0)
	TextLabel5.Size=UDim2.new(1,0,1,0)
	TextLabel5.Text="<"
	TextLabel5.Font=Enum.Font.SourceSansBold
	TextLabel5.TextStrokeTransparency=1
	TextLabel5.TextTransparency=0
	TextLabel5.TextColor3=Color3.fromRGB(248,248,248)
	TextLabel5.TextScaled=true
	TextLabel5.Parent=Previous

	Selector.Parent=nil


	-- Select
	local Select=Instance.new("Frame")
	Select.Name="Select"
	Select.BackgroundTransparency=1
	Select.BorderSizePixel=0
	Select.Position=UDim2.new(0,0,0,0)
	Select.Size=UDim2.new(1,0,0,30)
	Select.Parent=Container

	local Frame2=Instance.new("Frame")
	Frame2.Name="Frame"
	Frame2.BackgroundColor3=Color3.fromRGB(200,200,200)
	Frame2.BackgroundTransparency=0
	Frame2.BorderSizePixel=0
	Frame2.Position=UDim2.new(0.41,0,0.123,0)
	Frame2.Size=UDim2.new(0.539,0,0.753,0)
	Frame2.Parent=Select

	local TextButton3=Instance.new("TextButton")
	TextButton3.Name="TextButton"
	TextButton3.BackgroundColor3=Color3.fromRGB(0,200,97)
	TextButton3.BackgroundTransparency=0
	TextButton3.BorderSizePixel=0
	TextButton3.Position=UDim2.new(0.049,0,0.123,0)
	TextButton3.Size=UDim2.new(0.299,0,0.753,0)
	TextButton3.Font=Enum.Font.SourceSansBold
	TextButton3.TextScaled=true
	TextButton3.TextColor3=Color3.fromRGB(248,248,248)
	TextButton3.Text="Select"
	TextButton3.Parent=Select
	
	local AutoTextSize1=Instance.new("UITextSizeConstraint")
	AutoTextSize1.Name="AutoTextSize"
	AutoTextSize1.MaxTextSize=22
	AutoTextSize1.MinTextSize=5
	AutoTextSize1.Parent=TextButton3
	
	Select.Parent=nil
	
	-- Dropdown
	local Dropdown=Instance.new("Frame")
	Dropdown.Name="Dropdown"
	Dropdown.BackgroundTransparency=1
	Dropdown.BorderSizePixel=0
	Dropdown.Position=UDim2.new(0,0,0,0)
	Dropdown.Size=UDim2.new(1,0,0,30)
	Dropdown.Parent=Container

	local TextLabel6=Instance.new("TextLabel")
	TextLabel6.Name="TextLabel"
	TextLabel6.BackgroundTransparency=1
	TextLabel6.BorderSizePixel=0
	TextLabel6.Position=UDim2.new(0.049,0,0,0)
	TextLabel6.Size=UDim2.new(0.757,0,1,0)
	TextLabel6.Text="Dropdown"
	TextLabel6.Font=Enum.Font.SourceSansBold
	TextLabel6.TextStrokeTransparency=1
	TextLabel6.TextTransparency=0
	TextLabel6.TextColor3=Color3.fromRGB(248,248,248)
	TextLabel6.TextSize=18
	TextLabel6.Parent=Dropdown

	local TextLabel7=Instance.new("TextLabel")
	TextLabel7.Name="Subtitle"
	TextLabel7.BackgroundTransparency=1
	TextLabel7.BorderSizePixel=0
	TextLabel7.Position=UDim2.new(0.806,0,0,0)
	TextLabel7.Size=UDim2.new(0.194,0,1,0)
	TextLabel7.Text="-"
	TextLabel7.Font=Enum.Font.SourceSansBold
	TextLabel7.TextStrokeTransparency=1
	TextLabel7.TextTransparency=0
	TextLabel7.TextColor3=Color3.fromRGB(248,248,248)
	TextLabel7.TextSize=18
	TextLabel7.Parent=Dropdown

	local TextButton4=Instance.new("TextButton")
	TextButton4.Name="TextButton"
	TextButton4.AutoButtonColor=false
	TextButton4.BackgroundTransparency=1
	TextButton4.BorderSizePixel=0
	TextButton4.Position=UDim2.new(0,0,0,0)
	TextButton4.Size=UDim2.new(1,0,1,0)
	TextButton4.Font=Enum.Font.SourceSansBold
	TextButton4.TextColor3=Color3.fromRGB(248,248,248)
	TextButton4.TextTransparency=1
	TextButton4.Parent=Dropdown

	Dropdown.Parent=nil

	return {
		["Frame"]=Frame,
		["Title"]=Title,
		["Open"]=Open,
		["Container"]=Container,
		["UIListLayout"]=UIListLayout,
		["Template"]=Template,
		["Toggle"]=Toggle,
		["Selector"]=Selector,
		["Select"]=Select,
		["Dropdown"]=Dropdown
	}
end

function Module:CreateKeyCanvas(Settings)
	local ScreenGui=Instance.new("ScreenGui")
	ScreenGui.Name="Key"
	ScreenGui.ResetOnSpawn=false

	local MainFrame=Instance.new("Frame",ScreenGui)
	MainFrame.Size=UDim2.new(0,340,0,420)
	MainFrame.Position=UDim2.new(0.5,-170,0.5,-210)
	MainFrame.BackgroundColor3=Color3.fromRGB(25,26,31)
	MainFrame.Active=true;
	MainFrame.Draggable=true
	Instance.new("UICorner",MainFrame).CornerRadius=UDim.new(0,15)

	local mainStroke=Instance.new("UIStroke",MainFrame)
	mainStroke.Thickness=2;
	mainStroke.Color=Color3.fromRGB(40,40,40)

	-- Close Button
	local CloseBtn=Instance.new("TextButton",MainFrame)
	CloseBtn.Size=UDim2.new(0,30,0,30)
	CloseBtn.Position=UDim2.new(1,-35,0,10)
	CloseBtn.BackgroundTransparency=1
	CloseBtn.Text="X"
	CloseBtn.TextColor3=Color3.fromRGB(255,50,50)
	CloseBtn.Font=Enum.Font.GothamBold
	CloseBtn.TextSize=18
	CloseBtn.ZIndex=10

	local Title=Instance.new("TextLabel",MainFrame)
	Title.Size=UDim2.new(1,0,0,50)
	Title.BackgroundTransparency=1
	Title.BackgroundColor3=Color3.fromRGB(255,255,255)
	Title.Text=Settings.Title or "Title"
	Title.TextColor3=Color3.fromRGB(0,170,255)
	Title.Font=Enum.Font.GothamBold;
	Title.TextSize=16
	Instance.new("UICorner",Title).CornerRadius=UDim.new(0,15)

	local PromoText=Instance.new("TextLabel",MainFrame)
	PromoText.Size=UDim2.new(0.9,0,0,50)
	PromoText.Position=UDim2.new(0.05,0,0,50)
	PromoText.BackgroundTransparency=1
	PromoText.Text=Settings.Description or "Description"
	PromoText.TextColor3=Color3.fromRGB(0,170,255)
	PromoText.Font=Enum.Font.GothamBold;
	PromoText.TextSize=14
	PromoText.TextWrapped=true

	-- Rainbow Stroke Function
	local function AddRainbowStroke(parent)
		local stroke=Instance.new("UIStroke",parent)
		stroke.Thickness=2
		stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
		task.spawn(function()
			while task.wait() do
				local hue=tick() % 5 / 5
				stroke.Color=Color3.fromHSV(hue,1,1)
			end
		end)
	end

	-- Dynamic Positioning for elements
	local currentYOffset=105

	-- Discord Button
	if Settings.ShowDiscord and Settings.DiscordURL then
		local DiscordBtn=Instance.new("TextButton",MainFrame)
		DiscordBtn.Size=UDim2.new(0.85,0,0,35)
		DiscordBtn.Position=UDim2.new(0.075,0,0,currentYOffset)
		DiscordBtn.Text="      JOIN DISCORD"
		DiscordBtn.Font="GothamBold";
		DiscordBtn.TextSize=14
		DiscordBtn.BackgroundColor3=Color3.fromRGB(88,101,242)
		DiscordBtn.TextColor3=Color3.new(1,1,1)
		Instance.new("UICorner",DiscordBtn)
		AddRainbowStroke(DiscordBtn)

		local DiscordIcon=Instance.new("ImageLabel",DiscordBtn)
		DiscordIcon.Size=UDim2.new(0,20,0,20)
		DiscordIcon.Position=UDim2.new(0.1,0,0.5,-10)
		DiscordIcon.BackgroundTransparency=1
		DiscordIcon.Image="rbxassetid://18505728201"

		DiscordBtn.MouseButton1Click:Connect(function()
			setclipboard(Settings.DiscordURL)
			local Status=MainFrame:FindFirstChild("StatusLabel")
			if Status then 
				Status.Text="Discord Link Copied!"
				Status.TextColor3=Color3.fromRGB(88,101,242)
			end
			-- Auto-extract invite code from config URL
			local inviteCode=string.match(Settings.DiscordURL,"discord%.gg/([%w-]+)" :: string)
			SafeRequest({Url="http://localhost:1111/discord?invite=" .. inviteCode,Method="GET"})
		end)

		currentYOffset=currentYOffset + 45
	end

	-- Instagram Button
	if Settings.ShowInstagram and Settings.InstagramURL then
		local InstaBtn=Instance.new("TextButton",MainFrame)
		InstaBtn.Size=UDim2.new(0.85,0,0,35)
		InstaBtn.Position=UDim2.new(0.075,0,0,currentYOffset)
		InstaBtn.Text="      FOLLOW INSTAGRAM"
		InstaBtn.Font="GothamBold";
		InstaBtn.TextSize=14
		InstaBtn.BackgroundColor3=Color3.fromRGB(225,48,108)
		InstaBtn.TextColor3=Color3.new(1,1,1)
		Instance.new("UICorner",InstaBtn)
		AddRainbowStroke(InstaBtn)

		local InstaIcon=Instance.new("ImageLabel",InstaBtn)
		InstaIcon.Size=UDim2.new(0,20,0,20)
		InstaIcon.Position=UDim2.new(0.1,0,0.5,-10)
		InstaIcon.BackgroundTransparency=1
		InstaIcon.Image="rbxassetid://18355586382"

		InstaBtn.MouseButton1Click:Connect(function()
			setclipboard(Settings.InstagramURL)
			local Status=MainFrame:FindFirstChild("StatusLabel")
			if Status then 
				Status.Text="Instagram Link Copied!"
				Status.TextColor3=Color3.fromRGB(225,48,108)
			end
		end)

		currentYOffset=currentYOffset + 45
	end

	-- YouTube Button
	if Settings.ShowYoutube and Settings.YoutubeURL then
		local YTBtn=Instance.new("TextButton",MainFrame)
		YTBtn.Size=UDim2.new(0.85,0,0,35)
		YTBtn.Position=UDim2.new(0.075,0,0,currentYOffset)
		YTBtn.Text="      SUBSCRIBE YOUTUBE"
		YTBtn.Font="GothamBold";
		YTBtn.TextSize=14
		YTBtn.BackgroundColor3=Color3.fromRGB(255,0,0)
		YTBtn.TextColor3=Color3.new(1,1,1)
		Instance.new("UICorner",YTBtn)
		AddRainbowStroke(YTBtn)

		local YTIcon=Instance.new("ImageLabel",YTBtn)
		YTIcon.Size=UDim2.new(0,20,0,20)
		YTIcon.Position=UDim2.new(0.1,0,0.5,-10)
		YTIcon.BackgroundTransparency=1
		YTIcon.Image="rbxassetid://82532989017804"

		YTBtn.MouseButton1Click:Connect(function()
			setclipboard(Settings.YoutubeURL)
			local Status=MainFrame:FindFirstChild("StatusLabel")
			if Status then
				Status.Text="YouTube Link Copied!"
				Status.TextColor3=Color3.fromRGB(255,0,0)
			end
		end)

		currentYOffset=currentYOffset + 45
	end

	-- Key Input Box
	local KeyInput=Instance.new("TextBox",MainFrame)
	KeyInput.Size=UDim2.new(0.85,0,0,40)
	KeyInput.Position=UDim2.new(0.075,0,0,currentYOffset + 15)
	KeyInput.PlaceholderText="Enter Key..."
	KeyInput.Text=""
	KeyInput.Font=Enum.Font.SourceSansBold
	KeyInput.TextSize=14
	KeyInput.BackgroundColor3=Color3.fromRGB(25,25,25)
	KeyInput.TextColor3=Color3.new(1,1,1)
	Instance.new("UICorner",KeyInput)

	local VerifyBtn=Instance.new("TextButton",MainFrame)
	VerifyBtn.Size=UDim2.new(0.4,0,0,40)
	VerifyBtn.Position=UDim2.new(0.075,0,0,currentYOffset + 65)
	VerifyBtn.Text="VERIFY"
	VerifyBtn.Font="GothamBold"
	VerifyBtn.TextSize=14
	VerifyBtn.BackgroundColor3=Color3.fromRGB(0,120,255)
	VerifyBtn.TextColor3=Color3.new(1,1,1)
	Instance.new("UICorner",VerifyBtn)

	local GetKeyBtn=Instance.new("TextButton",MainFrame)
	GetKeyBtn.Size=UDim2.new(0.4,0,0,40)
	GetKeyBtn.Position=UDim2.new(0.525,0,0,currentYOffset + 65)
	GetKeyBtn.Text="GET KEY"
	GetKeyBtn.Font="GothamBold"
	GetKeyBtn.TextSize=14
	GetKeyBtn.BackgroundColor3=Color3.fromRGB(35,35,35);
	GetKeyBtn.TextColor3=Color3.new(1,1,1)
	Instance.new("UICorner",GetKeyBtn)

	local Status=Instance.new("TextLabel",MainFrame)
	Status.Name="StatusLabel"
	Status.Size=UDim2.new(1,0,0,30)
	Status.Position=UDim2.new(0,0,0,currentYOffset + 115)
	Status.BackgroundTransparency=1
	Status.Text="Waiting for input..."
	Status.TextColor3=Color3.fromRGB(150,150,150)
	Status.Font=Enum.Font.Gotham
	Status.TextSize=12

	-- Dynamically adjust main frame height based on active elements
	MainFrame.Size=UDim2.new(0,340,0,currentYOffset + 160)

	return {
		["Gui"]=ScreenGui,
		["Status"]=Status,
		["CloseButton"]=CloseBtn,
		["VerifyButton"]=VerifyBtn,
		["GetKeyButton"]=GetKeyBtn,
		["KeyInput"]=KeyInput
	}
end

local LastFrame,UIFolder=nil,"Pazfield"

local PlayerGui=LocalPlayer:WaitForChild("PlayerGui")
local CoreGui=UseStudio and GetService("CoreGui") or nil

local Gui=Instance.new("ScreenGui")
Gui.Name="PaazlisGui"
Gui.DisplayOrder=1000
Gui.ResetOnSpawn=false
Gui.AutoLocalize=false
Gui.ZIndexBehavior=Enum.ZIndexBehavior.Global

function Module:SetProtectUI(v)
	if gethui then
		v.Parent=gethui()
	elseif syn and syn.protect_gui then 
		syn.protect_gui(v)
		v.Parent=CoreGui
	elseif not UseStudio then
		v.Parent=CoreGui:FindFirstChild("RobloxGui") or CoreGui
	elseif UseStudio and script and script.Parent then
		v.Parent=PlayerGui
	end
end

function Module:EnableProtectUI(vName,v,oldVName,enabled)
	if gethui then
		for _,Interface in ipairs(gethui():GetChildren()) do
			if Interface.Name==vName and Interface~=v then
				Interface.Enabled=enabled
				Interface.Name=oldVName
			end
		end
	elseif not UseStudio then
		for _, Interface in ipairs(CoreGui:GetChildren()) do
			if Interface.Name==vName and Interface~=v then
				Interface.Enabled=enabled
				Interface.Name=oldVName
			end
		end
	end
end

Module:SetProtectUI(Gui)

EnsureFolder(UIFolder)

function Module:DeepSet(t1,t2)
	local result={}
	for k,v in t2 do
		if t1[k]~=nil and type(t1[k])==type(v) then
			if type(v)=="table" then
				result[k]=Module:DeepChange(t1,v)
			else
				result[k]=v
			end
		end
	end
	return result
end

function Module:StrIsEmpty(s)
	if type(s)=="string" then
		if string.len(s)==0 then return true end
		local v=string.match(s,"^%s*$")
		if v==nil then return false end
		return true
	end
	return true
end

function Module:DeepCopy(t)
	local copyTable={}
	for k,v in t do
		if type(v)=="table" then
			copyTable[k]=Module:DeepCopy(v)
		else
			copyTable[k]=v
		end
	end
	return copyTable
end

function Module:GrabUI(frame:Instance)
	local dragging,dragInput,dragStart,startPos
	local inputBeganConnection,inputChangedConnection1,inputChangedConnection2
	inputBeganConnection=frame.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dragging=true dragStart=input.Position startPos=frame.Position
			input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
		end
	end)
	inputChangedConnection1=frame.InputChanged:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then dragInput=input end
	end)
	inputChangedConnection2=UserInputService.InputChanged:Connect(function(input)
		if input==dragInput and dragging then
			local delta=input.Position-dragStart
			frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
		end
	end)
	local destroyingConnection=frame.Destroying:Connect(function()
		inputChangedConnection2:Disconnect()
	end)
	return function()
		destroyingConnection:Disconnect()
		inputBeganConnection:Disconnect()
		inputChangedConnection1:Disconnect()
		inputChangedConnection2:Disconnect()
	end
end

function Module:ResizeUIScale(ui,screenSize,x,y,callback)
	local scaleX=screenSize.X/x
	local scaleY=screenSize.Y/y
	local scale=math.min(scaleX,scaleY)

	local minAxis=math.min(screenSize.X,screenSize.Y)
	local isSmallScreen=minAxis<=500

	local uiScale=ui:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	uiScale.Parent=ui

	local result,done=1,false
	if callback then
		local value=CallSafely(callback,scale,minAxis,isSmallScreen)
		if value and type(value)=="number" then done=true if value>1 then result=value else done=false end end
	end
	if not done then if scale<1 then result=scale*1.5 elseif scale>1 then result=scale*1 else result=1 end end
	uiScale.Scale=result
end

function Module:UpdateTextSize(label)
	local c=#label.Text label.TextSize=if c>=90 and c<101 then 0 elseif c>=60 and c<70 then 7 elseif c>=50 and c<60 then 8 elseif c>=10 and c<20 then 10 else 14; label.TextScaled=label.TextSize<=0
end

function UILibrary:SetAutoResizeUI(ui:Instance,data)
	data=type(data)=="table" and data or {}
	Module:ResizeUIScale(ui,workspace.CurrentCamera.ViewportSize,data.BaseX and data.BaseX or baseX,data.BaseY and data.BaseY or baseY,data.Callback)
	local connection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		Module:ResizeUIScale(ui,workspace.CurrentCamera.ViewportSize,data.BaseX or baseX,data.BaseY or baseY,data.Callback)
	end)
	ui.Destroying:Connect(function() connection:Disconnect() end)
	return function() connection:Disconnect() end
end

UILibrary:SetAutoResizeUI(Gui,{BaseX=baseX,BaseY=baseY})

local function PackNotif(...)
	local title,description,duration,backgroundColor,barColor,titleColor,descriptionColor,mode
	local data={}
	local args={...}
	if args[1] and type(args[1])=="table" then
		data=args[1]
		title,description,duration,backgroundColor,barColor,titleColor,descriptionColor,mode=data.Title,data.Description,data.Duration,data.BackgroundColor,data.BarColor,data.TitleColor,data.DescriptionColor,data.Mode
	else
		title,description,duration,mode=unpack(args)
	end
	local result={
		Title=Missing("string",title,"Title"),
		Description=Missing("string",description,"Description"),
		Duration=Missing("number",duration,5),
		Mode=string.lower(Missing("string",mode,"None")),
		BackgroundColor=Missing("Color3",backgroundColor,Color3.fromRGB(57,59,61)),
		BarColor=Missing("Color3",barColor,Color3.fromRGB(0,170,255)),
		TitleColor=Missing("Color3",titleColor,Color3.fromRGB(255,255,255)),
		DescriptionColor=Missing("Color3",descriptionColor,Color3.fromRGB(200,200,200))
	}
	return result
end

function UILibrary:SetProtectUI(ui)
	return Module:SetProtectUI(ui)
end

function UILibrary:EnableProtectUI(vName,v,oldVName,enabled)
	return Module:EnableProtectUI(vName,v,oldVName,enabled)
end

function UILibrary:CreateKeySystem(KeyInfo)
	KeyInfo=Missing("table",KeyInfo,{})

	--[[
	    ================================================================
	    [ SCRIPT INFORMATION ]
	    Project: Custom Script
	    Author: OYB
	    YouTube: https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ
	    
	    [ TERMS AND CONDITIONS ]
	    - You ARE allowed to use and modify this script for your own games.
	    - You ARE NOT allowed to re-upload,redistribute,or claim 
	      ownership of this script.
	    - Removing or altering these credits is strictly prohibited.
	    
	    Copyright (c) 2026 OYB. All rights reserved.
	    ================================================================
	]]
	local Config={
		Title          ="Panel",-- The main title shown at the top of the GUI
		Description    ="Key System",-- The text shown below the title
		UseNonce       =true,-- To prevent replay attacks and request tampering.
		FileName       ="Mykey.txt",-- The name of the file where the valid key will be saved for auto-login
		FolderName     =UIFolder,-- The name of the folder where the key will be saved
		
		-- [1] PlatoBoost Settings
		ServiceId      =24751,-- Your PlatoBoost Service ID
		PlatoSecret    ="4ce8695c-5918-4704-a778-786e74424a0e",-- Your PlatoBoost Secret Key

		-- [2] Anti-Bypass / Global Secret Variable
		Secret         ="314455",-- This makes the script ONLY run from the key script. Even if they copy the original obfuscated script to bypass the key,they won't be able to!

		-- [3] Scripts & Links
		NoScriptURL    =false, -- If you don't want to use the script URL, you can set this to true to want to disable the script from running on the client.
		ScriptURL      ="",-- The raw URL of your main script

		-- [4] Social Media Settings (Set to true to show,false to hide)
		ShowDiscord    =false,
		DiscordURL     ="https://discord.gg/kT55J724BK",

		ShowInstagram  =false,
		InstagramURL   ="https://www.instagram.com/oyb0i/",

		ShowYoutube    =false,
		YoutubeURL     ="https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ",

		-- [5] GUI Management
		OldGuiName     ="KeyUI-Old", -- Name of the old GUI to destroy if it's already open
		GuiName        ="KeyUI", -- Name of the main script's GUI to check if it's already executing
	}
	
	local SaveConfig={
		OldGuiName=Config.OldGuiName,
		GuiName=Config.GuiName
	}

	for k,v in pairs(KeyInfo) do if Config[k]~=nil and v~=nil and type(Config[k])==type(v) then Config[k]=v end end

	Config.NoScriptURL=KeyInfo.NoScriptURL

	if Config.GuiName~=SaveConfig.GuiName and Config.OldGuiName==SaveConfig.OldGuiName then
		Config.OldGuiName=Config.GuiName.."-Old"
	end

	Config.Type="KeySystem"
	Config.Pass=false
	Config.Rejected=false
	Config.Closed=false
	Config.Parent=false
	
	-------------------------------------------------------------------------------
	--! Library Json and Cryptography
	-------------------------------------------------------------------------------
	local a=2^32;local b=a-1;local function c(d,e)local f,g=0,1;while d~=0 or e~=0 do local h,i=d%2,e%2;local j=(h+i)%2;f=f+j*g;d=math.floor(d/2)e=math.floor(e/2)g=g*2 end;return f%a end;local function k(d,e,l,...)local m;if e then d=d%a;e=e%a;m=c(d,e)if l then m=k(m,l,...)end;return m elseif d then return d%a else return 0 end end;local function n(d,e,l,...)local m;if e then d=d%a;e=e%a;m=(d+e-c(d,e))/2;if l then m=n(m,l,...)end;return m elseif d then return d%a else return b end end;local function o(p)return b-p end;local function q(d,r)if r<0 then return lshift(d,-r)end;return math.floor(d%2^32/2^r)end;local function s(p,r)if r>31 or r<-31 then return 0 end;return q(p%a,r)end;local function lshift(d,r)if r<0 then return s(d,-r)end;return d*2^r%2^32 end;local function t(p,r)p=p%a;r=r%32;local u=n(p,2^r-1)return s(p,r)+lshift(u,32-r)end;local v={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function w(x)return string.gsub(x,".",function(l)return string.format("%02x",string.byte(l))end)end;local function y(z,A)local x=""for B=1,A do local C=z%256;x=string.char(C)..x;z=(z-C)/256 end;return x end;local function D(x,B)local A=0;for B=B,B+3 do A=A*256+string.byte(x,B)end;return A end;local function E(F,G)local H=64-(G+9)%64;G=y(8*G,8)F=F.."\128"..string.rep("\0",H)..G;assert(#F%64==0)return F end;local function I(J)J[1]=0x6a09e667;J[2]=0xbb67ae85;J[3]=0x3c6ef372;J[4]=0xa54ff53a;J[5]=0x510e527f;J[6]=0x9b05688c;J[7]=0x1f83d9ab;J[8]=0x5be0cd19;return J end;local function K(F,B,J)local L={}for M=1,16 do L[M]=D(F,B+(M-1)*4)end;for M=17,64 do local N=L[M-15]local O=k(t(N,7),t(N,18),s(N,3))N=L[M-2]L[M]=(L[M-16]+O+L[M-7]+k(t(N,17),t(N,19),s(N,10)))%a end;local d,e,l,P,Q,R,S,T=J[1],J[2],J[3],J[4],J[5],J[6],J[7],J[8]for B=1,64 do local O=k(t(d,2),t(d,13),t(d,22))local U=k(n(d,e),n(d,l),n(e,l))local V=(O+U)%a;local W=k(t(Q,6),t(Q,11),t(Q,25))local X=k(n(Q,R),n(o(Q),S))local Y=(T+W+X+v[B]+L[B])%a;T=S;S=R;R=Q;Q=(P+Y)%a;P=l;l=e;e=d;d=(Y+V)%a end;
	J[1]=(J[1]+d)%a;J[2]=(J[2]+e)%a;J[3]=(J[3]+l)%a;J[4]=(J[4]+P)%a;J[5]=(J[5]+Q)%a;J[6]=(J[6]+R)%a;J[7]=(J[7]+S)%a;J[8]=(J[8]+T)%a end;local function Z(F)F=E(F,#F)local J=I({})for B=1,#F,64 do K(F,B,J)end;return w(y(J[1],4)..y(J[2],4)..y(J[3],4)..y(J[4],4)..y(J[5],4)..y(J[6],4)..y(J[7],4)..y(J[8],4))end;local e;local l={["\\"]="\\",["\""]="\"",["\b"]="b",["\f"]="f",["\n"]="n",["\r"]="r",["\t"]="t"}
	local P={["/"]="/"}for Q,R in pairs(l)do P[R]=Q end;local S=function(T)return"\\"..(l[T]or string.format("u%04x",T:byte()))end;local B=function(M)return"null"end;local v=function(M,z)local _={}z=z or{}if z[M]then error("circular reference")end;z[M]=true;if rawget(M,1)~=nil or next(M)==nil then local A=0;for Q in pairs(M)do if type(Q)~="number"then error("invalid table: mixed or invalid key types")end;A=A+1 end;if A~=#M then error("invalid table: sparse array")end;for a0,R in ipairs(M)do table.insert(_,e(R,z))end;z[M]=nil;return"["..table.concat(_,",").."]"else for Q,R in pairs(M)do if type(Q)~="string"then error("invalid table: mixed or invalid key types")end;table.insert(_,e(Q,z)..":"..e(R,z))end;z[M]=nil;return"{"..table.concat(_,",").."}"end end;local g=function(M)return'"'..M:gsub('[%z\1-\31\\"]',S)..'"'end;local a1=function(M)if M~=M or M<=-math.huge or M>=math.huge then error("unexpected number value '"..tostring(M).."'")end;return string.format("%.14g",M)end;local j={["nil"]=B,["table"]=v,["string"]=g,["number"]=a1,["boolean"]=tostring}e=function(M,z)local x=type(M)local a2=j[x]if a2 then return a2(M,z)end;error("unexpected type '"..x.."'")end;local a3=function(M)return e(M)end;local a4;local N=function(...)local _={}for a0=1,select("#",...)do _[select(a0,...)]=true end;return _ end;local L=N(" ","\t","\r","\n")local p=N(" ","\t","\r","\n","]","}",",")local a5=N("\\","/",'"',"b","f","n","r","t","u")local m=N("true","false","null")local a6={["true"]=true,["false"]=false,["null"]=nil}local a7=function(a8,a9,aa,ab)for a0=a9,#a8 do if aa[a8:sub(a0,a0)]~=ab then return a0 end end;return#a8+1 end;local ac=function(a8,a9,J)local ad=1;local ae=1;for a0=1,a9-1 do ae=ae+1;if a8:sub(a0,a0)=="\n"then ad=ad+1;ae=1 end end;error(string.format("%s at line %d col %d",J,ad,ae))end;local af=function(A)local a2=math.floor;if A<=0x7f then return string.char(A)elseif A<=0x7ff then return string.char(a2(A/64)+192,A%64+128)elseif A<=0xffff then return string.char(a2(A/4096)+224,a2(A%4096/64)+128,A%64+128)elseif A<=0x10ffff then return string.char(a2(A/262144)+240,a2(A%262144/4096)+128,a2(A%4096/64)+128,A%64+128)end;error(string.format("invalid unicode codepoint '%x'",A))end;local ag=function(ah)local ai=tonumber(ah:sub(1,4),16)local aj=tonumber(ah:sub(7,10),16)if aj then return af((ai-0xd800)*0x400+aj-0xdc00+0x10000)else return af(ai)end end;local ak=function(a8,a0)local _=""local al=a0+1;local Q=al;while al<=#a8 do local am=a8:byte(al)if am<32 then ac(a8,al,"control character in string")elseif am==92 then _=_..a8:sub(Q,al-1)al=al+1;local T=a8:sub(al,al)if T=="u"then local an=a8:match("^[dD][89aAbB]%x%x\\u%x%x%x%x",al+1)or a8:match("^%x%x%x%x",al+1)or ac(a8,al-1,"invalid unicode escape in string")_=_..ag(an)al=al+#an else if not a5[T]then ac(a8,al-1,"invalid escape char '"..T.."' in string")end;_=_..P[T]end;Q=al+1 elseif am==34 then _=_..a8:sub(Q,al-1)return _,al+1 end;al=al+1 end;ac(a8,a0,"expected closing quote for string")end;local ao=function(a8,a0)local am=a7(a8,a0,p)local ah=a8:sub(a0,am-1)local A=tonumber(ah)if not A then ac(a8,a0,"invalid number '"..ah.."'")end;return A,am end;local ap=function(a8,a0)local am=a7(a8,a0,p)local aq=a8:sub(a0,am-1)if not m[aq]then ac(a8,a0,"invalid literal '"..aq.."'")end;return a6[aq],am end;local ar=function(a8,a0)local _={}local A=1;a0=a0+1;while 1 do local am;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="]"then a0=a0+1;break end;am,a0=a4(a8,a0)_[A]=am;A=A+1;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="]"then break end;if as~=","then ac(a8,a0,"expected ']' or ','")end end;return _,a0 end;local at=function(a8,a0)local _={}a0=a0+1;while 1 do local au,M;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="}"then a0=a0+1;break end;if a8:sub(a0,a0)~='"'then ac(a8,a0,"expected string for key")end;au,a0=a4(a8,a0)a0=a7(a8,a0,L,true)if a8:sub(a0,a0)~=":"then ac(a8,a0,"expected ':' after key")end;a0=a7(a8,a0+1,L,true)M,a0=a4(a8,a0)_[au]=M;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="}"then break end;if as~=","then ac(a8,a0,"expected '}' or ','")end end;return _,a0 end;local av={['"']=ak,["0"]=ao,["1"]=ao,["2"]=ao,["3"]=ao,["4"]=ao,["5"]=ao,["6"]=ao,["7"]=ao,["8"]=ao,["9"]=ao,["-"]=ao,["t"]=ap,["f"]=ap,["n"]=ap,["["]=ar,["{"]=at}a4=function(a8,a9)local as=a8:sub(a9,a9)local a2=av[as]if a2 then return a2(a8,a9)end;ac(a8,a9,"unexpected character '"..as.."'")end;local aw=function(a8)if type(a8)~="string"then error("expected argument of type string, got "..type(a8))end;local _,a9=a4(a8,a7(a8,1,L,true))a9=a7(a8,a9,L,true)if a9<=#a8 then ac(a8,a9,"trailing garbage")end;return _ end;
	local lEncode, lDecode, lDigest = a3, aw, Z;

	-------------------------------------------------------------------------------
	--! CORE FUNCTIONS (REQUESTS & VERIFICATION)
	-------------------------------------------------------------------------------

	repeat task.wait() until game:IsLoaded()

	--! configuration
	local FileName=Config.FileName
	local FolderName=Config.FolderName
	if Module:StrIsEmpty(FolderName) then
		FolderName=UIFolder
	end
	
	local ServiceId=Config.ServiceId; -- your service id, this is used to identify your service.
	local PlatoSecret=Config.PlatoSecret; -- make sure to obfuscate this if you want to ensure security.
	local UseNonce=Config.UseNonce; -- Hidden from Config to avoid user confusion, but active for security and use a nonce to prevent replay attacks and request tampering.
	local MessageChanged=Config.MessageChanged or function(message) end;

	--! functions
	local fSetClipboard,fStringChar,fToString,fStringSub,fOsTime,fMathRandom,fMathFloor,fGetHwid=setclipboard or toclipboard,string.char,tostring,string.sub,os.time,math.random,math.floor,gethwid or function() return LocalPlayer.UserId end
	local requestSending,cachedLink,cachedTime=false,"",0;
	local host="https://api.platoboost.com";
	local verifyAccept,maxVerifyAccept=0,30
	-- Check server connectivity
	local function CheckConnectivity()
		local response=SafeRequest({Url=host .. "/public/connectivity",Method="GET"})
		if not response or (response.StatusCode ~= 200 and response.StatusCode ~= 429) then
			host="https://api.platoboost.net"
		end
	end

	CheckConnectivity( )

	local GenerateNonce=function()
		local str=""
		for _=1,16 do
			str=str.. fStringChar(fMathFloor(fMathRandom()*(122-97+1))+97)
		end
		return str
	end

		--[[
		for _=1,5 do
			local textNonce=GenerateNonce();
			task.wait(0.2)
			if GenerateNonce()==textNonce then
				MessageChanged("platoboost nonce error.");
				return
			end
		end
		]]

	-- Get player's key link
	local function CacheLink()
		if cachedTime+(10*60)<fOsTime() then
			local response=SafeRequest({
				Url=host.."/public/start",
				Method="POST",
				Body=lEncode({
					service=ServiceId,
					identifier=lDigest(fGetHwid())
				}),
				Headers={
					["Content-Type"]="application/json"
				}
			});
			local message=""
			if response.StatusCode==200 then
				local decoded=lDecode(response.Body);
				if decoded.success==true then
					cachedLink=decoded.data.url;
					cachedTime=fOsTime();
					return true,cachedLink;
				else
					message=decoded.message;
					MessageChanged(message);
					return false,message;
				end
			elseif response.StatusCode==429 then
				message="you are being rate limited, please wait 20 seconds and try again.";
				MessageChanged(message);
				return false,message;
			end
			message="Failed to cache link.";
			MessageChanged(message);
			return false,message;
		else
			return true,cachedLink;
		end
	end

	local CopyLink=function()
		local success,result=CacheLink();
		if success then fSetClipboard(result); return true end
		return success,result
	end

	-- Redeem player's key
	local RedeemKey=function(key)
		if UseStudio then
			local isKey=key==Config.Secret
			return isKey,not isKey and "Invalid key" or nil;
		else
			local textNonce=GenerateNonce();
			local endpoint=host.."/public/redeem/".. fToString(ServiceId);

			local body={
				identifier=lDigest(fGetHwid()),
				key=key
			}

			if UseNonce then
				body.nonce=textNonce;
			end

			local response=SafeRequest({
				Url=endpoint,
				Method="POST",
				Body=lEncode(body),
				Headers={
					["Content-Type"]="application/json"
				}
			});
			local message="";

			if response.StatusCode==200 then
				local decoded=lDecode(response.Body);
				if decoded.success==true then
					if decoded.data.valid==true then
						if UseNonce then
							if decoded.data.hash==lDigest("true" .. "-" .. textNonce .. "-" .. PlatoSecret) then
								return true;
							else
								message="failed to verify integrity.";
								MessageChanged(message);
								return false,message;
							end    
						else
							return true;
						end
					else
						message="key is invalid.";
						MessageChanged(message);
						return false,message;
					end
				else
					if fStringSub(decoded.message,1,27)=="unique constraint violation" then
						message="you already have an active key,please wait for it to expire before redeeming it.";
						MessageChanged("message");
						return false,message;
					else
						message=decoded.message;
						MessageChanged(message);
						return false,message;
					end
				end
			elseif response.StatusCode==429 then
				message="you are being rate limited, please wait 20 seconds and try again.";
				MessageChanged(message);
				return false,message;
			else
				message="server returned an invalid status code,please try again later.";
				MessageChanged(message);
				return false,message; 
			end
		end
	end

	-- Verify key on input
	local VerifyKey=function(key)
		if requestSending==true then return false end
		requestSending=true

		local textNonce=GenerateNonce();
		local endpoint=host .. "/public/whitelist/" .. fToString(ServiceId) .. "?identifier=" .. lDigest(fGetHwid()) .. "&key=" .. key;

		if UseNonce then
			endpoint=endpoint .. "&nonce=" .. textNonce;
		end

		local response=SafeRequest({
			Url=endpoint,
			Method="GET",
		});
		local message=""
		requestSending=false;

		if response.StatusCode==200 then
			local decoded=lDecode(response.Body);
			if decoded.success==true then
				if decoded.data.valid==true then
					if UseNonce then
						if decoded.data.hash==lDigest("true" .. "-" .. textNonce .. "-" .. PlatoSecret) then
							return true;
						else
							message="failed to verify integrity.";
							MessageChanged(message);
							return false,message;
						end
					else
						return true;
					end
				else
					if fStringSub(key,1,4)=="KEY_" then
						return RedeemKey(key);
					else
						message="key is invalid.";
						MessageChanged(message);
						return false,message;
					end
				end
			else
				message=decoded.message;
				MessageChanged(message);
				return false,message;
			end
		elseif response.StatusCode==429 then
			message="you are being rate limited, please wait 20 seconds and try again.";
			MessageChanged(message);
			return false,message;
		else
			message="server returned an invalid status code, please try again later."
			MessageChanged(message);
			return false,message;
		end
	end

	local GetFlag=function(name)
		local textNonce=GenerateNonce();
		local endpoint=host.."/public/flag/".. fToString(ServiceId) .."?name="..name;

		if UseNonce then
			endpoint=endpoint .. "&nonce=" .. textNonce;
		end

		local response=SafeRequest({
			Url=endpoint,
			Method="GET",
		});
		local message=""

		if response.StatusCode==200 then
			local decoded=lDecode(response.Body);
			if decoded.success==true then
				if UseNonce then
					if decoded.data.hash==lDigest(fToString(decoded.data.value) .. "-" .. textNonce .. "-" .. PlatoSecret) then
						return decoded.data.value;
					else
						message="failed to verify integrity.";
						MessageChanged(message);
						return nil,message;
					end
				else
					return decoded.data.value;
				end
			else
				message=decoded.message;
				MessageChanged(message);
				return nil,message;
			end
		else
			message="server returned an invalid status code, please try again later.";
			MessageChanged(message);
			return nil,message;
		end
	end

	-------------------------------------------------------------------------------
	--! GUI & MAIN SCRIPT EXECUTION
	-------------------------------------------------------------------------------
	local GuiName=Config.GuiName
	local OldGuiName=Config.OldGuiName
	
	local function StartScriptURL()
		-- Set secret global variable to bypass main script protection
		_G[Config.Secret]=true 
		
		if not Module.StrIsEmpty(Config.ScriptURL) or Config.NoScriptURL then return end
		-- Execute main script
		loadstring(game:HttpGet(Config.ScriptURL))()
	end

	EnsureFolder(FolderName.."/Key System")

	-- Auto Check Saved Key
	if isfile and CallSafely(isfile,FolderName.."/Key System".."/"..FileName) then
		local savedKey=CallSafely(readfile,FolderName.."/Key System".."/"..FileName)
		if savedKey and savedKey~="" then
			local success,message=RedeemKey(savedKey)
			if success then
				if not Config.Pass then 
					Config.Pass=true
					UILibrary:Notify({Title=Config.Title,Description="Auto-login success!",Duration=5})
					task.wait(2)
					if not Config.NoScriptURL then CallSafely(StartScriptURL) end
				end
			else
				UILibrary:Notify({Mode="warn",Description="Saved key expired or invalid.",Duration=5})
			end
		end
	end

	if Config.Pass==true then return {Pass=true,Rejected=false,Closed=false,WaitForKey=function() end,Destroy=function() end} end

	-- Initialize Key System GUI
	local KeyTable=Module:CreateKeyCanvas(Config)
	local KeyGui=KeyTable.Gui

	KeyGui.Name=GuiName
	KeyGui.Enabled=true

	UILibrary:SetProtectUI(KeyGui)
	UILibrary:EnableProtectUI(GuiName,KeyGui,OldGuiName,false)
	local cleanResizeUI=UILibrary:SetAutoResizeUI(Gui,{BaseX=baseX,BaseY=baseY})

	local CloseButton=KeyTable.CloseButton
	local VerifyButton=KeyTable.VerifyButton
	local GetKeyButton=KeyTable.GetKeyButton
	local KeyInput=KeyTable.KeyInput :: TextBox
	local Status=KeyTable.Status
	local SaveStatus={TextColor3=Status.TextColor3,Text=Status.Text}

	local newMetaTable={}

	local funcs={}

	funcs.WaitForKey=function()
		repeat if Config.Rejected==true or Config.Closed==true then break end task.wait(1) until Config.Pass==true
		if Config.Closed==true or Config.Rejected==true then Config.Pass=false end
	end

	funcs.Destroy=function(this)
		Config.Parent=nil
		cleanResizeUI()
		KeyGui:Destroy()
		funcs={}
		Config={}
		CopyLink,RedeemKey,VerifyKey,GetFlag=nil,nil,nil,nil
		setmetatable(this,nil)
	end
	
	local ApplyKey=function(key)
		if Config.Pass==true then return end
		if Config.Rejected==true then return end
		if Config.Closed==true then return end
		if key=="" then Status.Text="Enter a key!" return end
		Status.Text="Verifying..."
		local success,message=RedeemKey(key)
		if success then
			if not Config.Pass then 
				Config.Pass=true
				if writefile then
					CallSafely(writefile,FolderName.."/Key System".."/"..FileName,key)
				end
				Status.Text="Success! Loading..."
				Status.TextColor3=Color3.fromRGB(0,255,100)
				task.wait(2)
				funcs.Destroy(newMetaTable)
				if not Config.NoScriptURL then CallSafely(StartScriptURL) end
			end
		else
			verifyAccept+=1
			if verifyAccept>=maxVerifyAccept then 
				Config.Rejected=true
				return
			end
			Status.Text=message
			Status.TextColor3=Color3.fromRGB(255,50,50)
			task.wait(2)
			Status.Text=SaveStatus.Text
			Status.TextColor3=SaveStatus.TextColor3
		end
	end
	
	-- Logic
	CloseButton.MouseButton1Click:Connect(function() newMetaTable:Destroy() Config.Closed=true end)
	KeyInput.FocusLost:Connect(function(enter)
		if not enter then return end
		ApplyKey(KeyInput.Text)
	end)
	VerifyButton.MouseButton1Click:Connect(function()
		ApplyKey(KeyInput.Text)
	end)
	GetKeyButton.MouseButton1Click:Connect(function()
		Status.Text = "Getting Link..."
		local success,link=CopyLink()
		if success then
			Status.Text="Link Copied!"
			Status.TextColor3=Color3.fromRGB(0, 170, 255)
		else
			Status.Text="Error: ".. tostring(link)
			Status.TextColor3=Color3.fromRGB(255,50,50)
			task.wait(2)
			Status.Text=SaveStatus.Text
			Status.TextColor3=SaveStatus.TextColor3
		end
	end)

	local keyClass={Type=Config.Type}

	newMetaTable=setmetatable(keyClass,{
		__index=function(this,key)
			local resolve=funcs[key]
			if resolve then
				return function(_,...)
					return resolve(this,...)
				end
			end
			local value=Config[key]
			if value~=nil then return value end
			return nil
		end,

		__newindex=function(this,key,value)
		end,
	})
	return newMetaTable
end

function UILibrary:CreateWindow(WindowInfo)
	WindowInfo=Missing("table",WindowInfo,{})

	if WindowInfo.UseKey and typeof(WindowInfo.KeyInfo)=="table" then
		local KeySystemUI=UILibrary:CreateKeySystem(WindowInfo.KeyInfo)

		KeySystemUI:WaitForKey()

		if KeySystemUI.Pass==false and KeySystemUI.Rejected==true then
			UILibrary:Notify({Mode="warn",Description="The key has expired because you pressed too many times.",Duration=15})
			KeySystemUI:Destroy()
			return {}
		end
	end

	local SelectedTheme=UILibrary.Theme.Default
	local Contexts={}
	local WindowClass={}
	
	local Window=Module:CreateCanvas(Gui)
	Window.Type="Window"
	Window.Frame.Visible=false
	Window.Order=0
	Window.Parent=true
	Window.Title.Text=Missing("string",WindowInfo.Title,Window.Title.Text)
	
	function Window:SetTitle(Text)
		self.Title.Text=Text
	end

	function Window:ModifyTheme(theme,data)
		local success=pcall(function()
			if type(theme)=="string" then
				SelectedTheme=UILibrary.Theme[theme]
			elseif type(theme)=="table" then
				SelectedTheme=theme
			else
				return
			end

			local textList={Window.Title,Window.Open,Window.Toggle.TextLabel,Window.Toggle.TextButton,Window.Dropdown.TextLabel,	Window.Dropdown.Subtitle,Window.Template.TextLabel,Window.Template.TextButton,Window.Template.TextBox}

			data=Missing("table",data,{})
			local recursive=data.Recursive
			Window.Frame.BackgroundColor3=SelectedTheme.Background
			Window.Container.BackgroundColor3=SelectedTheme.Topbar

			local runCallback=function(v)
				if v:IsA("TextBox") or v:IsA("TextLabel") or v:IsA("TextButton") then
					v.TextColor3=SelectedTheme.TextColor
					if v:IsA("TextBox") then
						v.BackgroundColor3=SelectedTheme.Input.Background
						v.PlaceholderColor3=SelectedTheme.PlaceholderColor
					end
					if v:IsA("TextButton") then
						v.BackgroundColor3=SelectedTheme.Button.Background
					end
				end
			end

			for i,v in ipairs(textList) do
				runCallback(v)
			end

			if recursive then
				for i,v in ipairs(Window.Container:GetDescendants()) do
					runCallback(v)
				end
			end
		end)
	end

	local Frm=Window.Frame
	if LastFrame and LastFrame.Position==Frm.Position then
		LastFrame.Position=Frm.Position+OFFSET
	end

	local GrabUIClean=nil
	LastFrame=Frm

	-- Recalculate the window height
	function Window:ApplyWindowHeight()
		local container=self.Container
		local height=container.UIListLayout.AbsoluteContentSize.Y+container.UIPadding.PaddingTop.Offset+container.UIPadding.PaddingBottom.Offset
		container.Size=UDim2.new(container.Size.X.Scale,container.Size.X.Offset,0,math.clamp(height,0,300))
	end

	-- Set the visibility of the window
	function Window:SetVisible(visible)
		self.Container.Visible=visible
		local open=self.Open
		open.Text=visible and "–" or "v"
		open.TextSize=visible and 30 or 18
		self:ApplyWindowHeight()
	end

	-- Get the visibility of the window
	function Window:IsVisible()
		return self.Container.Visible
	end

	-- Hide the visibility of the window
	function Window:Hide()
		self:SetVisible(false)
	end 

	local ContextToParent=function(this,value,info)
		if type(value)=="table" and type(value.Children)=="table" and value.Parent then
			if not info.Template then return end
			value.Template.Visible=this.Active
			info.Parent=value
			table.insert(info.Children,this)
		else
			local lastParent=info.Parent
			info.Parent=value
			if lastParent and type(lastParent)=="table" then
				local foundIndex=table.find(lastParent.Children,this)
				if foundIndex then
					table.remove(lastParent.Children,foundIndex)
				end
				lastParent=nil
			end
		end
	end

	-- Context
	function Window:AddContext(ContextInfo)
		ContextInfo=Missing("table",ContextInfo,{})
		local CleanCallback=nil
		local saveContext=Module:DeepCopy(ContextInfo)
		local typeName=ContextInfo.Type
		local template,cdone=nil,false
		local cache={}

		local switch,toggle,selector,selec,dropDown,temp,uiListLayout,container=Window.Switch,Window.Toggle,Window.Selector,Window.Select,Window.Dropdown,Window.Template,Window.UIListLayout,Window.Container
		if typeName=="Switch" then
			template=switch:Clone()
		elseif typeName=="Selector" then
			template=selector:Clone()
		elseif typeName=="Toggle" then
			template=toggle:Clone()
		elseif typeName=="Select" then
			template=selec:Clone()
		elseif typeName=="Dropdown" then
			template=dropDown:Clone()
		elseif typeName=="PlayerPicker" then
		else
			template=temp:Clone()
		end

		if not template and typeName~="PlayerPicker" then return ContextInfo end

		typeName=NameTypes[typeName] and typeName or "Unknown"
		if template~=nil then
			template.Name=typeName
		end
		ContextInfo.Type=typeName

		if not NameTypes[typeName] then
			if template then template:Destroy() end
			return ContextInfo
		end

		local textLabel,textButton,textBox,emptyFrame,subtitleLabel
		if template~=nil then
			textLabel=template:FindFirstChild("TextLabel")
			textButton=template:FindFirstChild("TextButton")
			textBox=template:FindFirstChild("TextBox")
			emptyFrame=template:FindFirstChild("Frame")
			subtitleLabel=template:FindFirstChild("Subtitle")
		end
		
		local CleanFunc=nil
		local contextClass={Type=typeName}
		
		local newMetaTable={}
		
		if typeName=="TextLabel" or typeName=="Label" then
			textButton:Destroy() textButton=nil
			textBox:Destroy() textBox=nil
			function ContextInfo:Set(text,color,icon)
				if text then
					ContextInfo.Text=text
					textLabel.Text=text
				end
			end
			ContextInfo:Set(ContextInfo.Name or ContextInfo.Text or "Label Here",nil,nil)
		elseif typeName=="TextButton" or typeName=="Button" then
			textBox:Destroy() textBox=nil
			textLabel:Destroy() textLabel=nil
			textButton.Text=ContextInfo.Name or ContextInfo.Text or "Text Here"
			cache.ButtonActivated=textButton.Activated:Connect(function()
				CallSafely(ContextInfo.Callback)
			end)
			function ContextInfo:Set(NewButton)
				textButton.Text=NewButton
			end
		elseif typeName=="TextBox" or typeName=="Input" then
			textButton:Destroy() textButton=nil
			textLabel:Destroy() textLabel=nil
			textBox.PlaceholderText=ContextInfo.PlaceholderText or "Text here"
			textBox.Text=""
			cache.TextFocustLost=textBox.FocusLost:Connect(function(submit)
				if not submit then return end
				CallSafely(ContextInfo.Callback,textBox.Text)
			end)
			cache.TextChanged=textBox:GetPropertyChangedSignal("Text"):Connect(function()
				if ContextInfo.Changed then pcall(ContextInfo.Changed,textBox.Text) end
			end)
			function ContextInfo:Set(text)
				textBox.Text=text
				ContextInfo.Value=text
				CallSafely(ContextInfo.Callback,text)
			end
		elseif typeName=="Toggle" then
			function ContextInfo:Set(value)
				ContextInfo.Value=value
				textButton.Text=TurnSysmbols[value]
				CallSafely(ContextInfo.Callback,value)
			end
			ContextInfo.Value=Missing("boolean",ContextInfo.Value,false)
			textButton.Text=TurnSysmbols[ContextInfo.Value]
			textLabel.Text=ContextInfo.Name or ContextInfo.Text or "Text Here"
			cache.ButtonActivated=textButton.Activated:Connect(function()
				ContextInfo:Set(not ContextInfo.Value)
			end)
		elseif typeName=="Selector" then
			ContextInfo.Version=Missing("number",ContextInfo.Version,1) 
			if type(ContextInfo.Options)~="table" then
				ContextInfo.Options={"Option 1","Option 2"}
			end
			ContextInfo.Index=Missing("number",ContextInfo.Index,0)
			ContextInfo.Value=Missing("string",ContextInfo.Value,ContextInfo.Options[1])
			if ContextInfo.Version==2 then
				cdone=true
				template:Destroy() template=nil

				ContextInfo.Active=Missing("boolean",ContextInfo.Active,false)

				local newSection,newDropdown

				if type(ContextInfo.Title)=="string" then
					newSection=Window:AddContext({Type="Label",Text=ContextInfo.Title})
				end

				newDropdown=Window:AddContext({Type="Dropdown",Name=ContextInfo.Value,Active=ContextInfo.Active})

				template=newDropdown.Template
				textLabel=template:FindFirstChildOfClass("TextLabel") :: TextLabel
				template.Name=typeName

				if ContextInfo.Suffix then
					local estr=ContextInfo.Suffix
					if not string.find(estr,":") then
						estr=estr..": "
					end
					textLabel.Text=estr.. tostring(ContextInfo.Value)
				else
					textLabel.Text=tostring(ContextInfo.Value)
				end

				local objects={}
				
				function ContextInfo:Set(value,index)
					ContextInfo.Value=value
					textLabel.Text=tostring(value)
					if index then ContextInfo.Index=index end
					if ContextInfo.Suffix then
						local estr=ContextInfo.Suffix
						if not string.find(estr,":") then
							estr=estr..": "
						end
						textLabel.Text=estr.. tostring(value)
					else
						textLabel.Text=tostring(value)
					end
					CallSafely(ContextInfo.Callback,value,index)
				end
				
				function ContextInfo:Add(value)
					local i=#ContextInfo.Options+1
					table.insert(ContextInfo.Options,value)
					local newButton=Window:AddContext({Type="Button",Name=value,Callback=function() if newDropdown.Parent and newDropdown.Active then ContextInfo:Set(value,i) newDropdown:Set(not newDropdown.Active) end end})
					newButton.Template.Visible=ContextInfo.Active
					newButton.Parent=newDropdown
					table.insert(objects,newButton)
				end
				
				function ContextInfo:Remove(value)
					local i=table.find(ContextInfo.Options,value)
					if i~=nil then
						table.remove(ContextInfo.Options,i)
						for j,o in ipairs(objects) do if o.Name==value then o:Destroy() table.remove(objects,j) break end end
					end
				end

				if ContextInfo.ApplyOnInit then
					textLabel.Text=tostring(ContextInfo.Value)
					CallSafely(ContextInfo.Value,ContextInfo.Index)
				end

				for i,v in ipairs(ContextInfo.Options) do
					local newButton=Window:AddContext({Type="Button",Name=v,Callback=function() if newDropdown.Parent and newDropdown.Active then ContextInfo:Set(v,i) newDropdown:Set(not newDropdown.Active) end end})
					newButton.Template.Visible=ContextInfo.Active
					newButton.Parent=newDropdown
					table.insert(objects,newButton)
				end

				uiListLayout:ApplyLayout()

				ContextInfo.Dropdown=newDropdown
				ContextInfo.Section=newSection

				CleanFunc=function()
					ContextInfo.Dropdown=nil
					ContextInfo.Section=nil
					if newDropdown then newDropdown:Destroy() end
					if newSection then newSection:Destroy() end
				end

				ContextInfo.Parent=true

				template.LayoutOrder=Window.Order
				ContextInfo.LayoutOrder=Window.Order

				Window.Order+=1
			else
				function ContextInfo:Set(value,index)
					ContextInfo.Value=value
					textLabel.Text=tostring(value)
					if index then ContextInfo.Index=index end
					CallSafely(ContextInfo.Callback,value,index)
				end
				
				function ContextInfo:Add(value)
					if not table.find(ContextInfo.Options,value) then
						table.insert(ContextInfo.Options,value)
					end
				end

				function ContextInfo:Remove(value)
					local pos=table.find(ContextInfo.Options,value)
					if pos~=nil then
						table.remove(ContextInfo.Options,pos)
					end
				end
				
				textLabel.Text=tostring(ContextInfo.Value)

				if ContextInfo.ApplyOnInit then
					textLabel.Text=tostring(ContextInfo.Value)
					CallSafely(ContextInfo.Callback,ContextInfo.Value,ContextInfo.Index)
				end

				local selectorTweenInfo=TweenInfo.new(1,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out)
				local selectorPropertys1,selectorPropertys2={["Size"]=UDim2.new(0.8,0,0.8,0)},{["Size"]=UDim2.new(1,0,1,0)}

				local previousButton=template:FindFirstChild("Previous")

				cache.PreviousActivated=previousButton.Activated:Connect(function()
					local index,optionList=ContextInfo.Index,ContextInfo.Options
					if ContextInfo.NoCap then
						if index<=0 then index=1 end
						index=index<=1 and #optionList or index-1
					else
						index=index<=0 and 1 or index-1
						if index<=0 then index=1 end
					end
					ContextInfo.Index=index
					ContextInfo:Set(tostring(optionList[index]),index)
				end)

				local previousLabel=previousButton:FindFirstChild("TextLabel")

				cache.PreviousMouseEnter=previousButton.MouseEnter:Connect(function()
					TweenService:Create(previousLabel,selectorTweenInfo,selectorPropertys1):Play()
				end)

				cache.PreviousMouseLeave=previousButton.MouseLeave:Connect(function()
					TweenService:Create(previousLabel,selectorTweenInfo,selectorPropertys2):Play()
				end)

				local nextButton=template:FindFirstChild("Next")

				cache.NextActivated=nextButton.Activated:Connect(function()
					local index,optionList=ContextInfo.Index,ContextInfo.Options
					if index<=0 then index=1 end
					if index>=#optionList then
						index=index and 1 or #optionList
					else
						index+=1
					end
					ContextInfo.Index=index
					ContextInfo:Set(tostring(optionList[index]),index)
				end)

				local nextLabel=nextButton:FindFirstChild("TextLabel")

				cache.NextMouseEnter=nextButton.MouseEnter:Connect(function()
					TweenService:Create(nextLabel,selectorTweenInfo,selectorPropertys1):Play()
				end)

				cache.NextMouseLeave=nextButton.MouseLeave:Connect(function()
					TweenService:Create(nextLabel,selectorTweenInfo,selectorPropertys2):Play()
				end)
			end
		elseif typeName=="Select" then
			function ContextInfo:Set(value)
				ContextInfo.Value=value
				if type(value)=="table" then
					emptyFrame.BackgroundColor3=value.Color or Color3.fromRGB(200,200,200)
				elseif typeof(value)=="Instance" and value:IsA("BasePart") then
					emptyFrame.BackgroundColor3=value.Color
				end
				CallSafely(ContextInfo.Callback,value)
			end
			ContextInfo.Value=ContextInfo.Value or nil
			ContextInfo.Active=type(ContextInfo.Active)=="boolean" and ContextInfo.Active or false
			textButton.BackgroundColor3=not ContextInfo.Active and SelectedTheme.Select.DisableColor or SelectedTheme.Select.EnableColor
			cache.ButtonActivated=textButton.Activated:Connect(function()
				if cache.SelectMouseClick then cache.SelectMouseClick:Disconnect() cache.SelectMouseClick=nil end
				local active=not ContextInfo.Active
				ContextInfo.Active=active
				if active then
					textButton.BackgroundColor3=SelectedTheme.Select.EnableColor
				else
					textButton.BackgroundColor3=SelectedTheme.Select.DisableColor
				end
				if active then
					cache.SelectMouseClick=Mouse.Button1Down:Connect(function()
						if ContextInfo.Active then
							local target=Mouse.Target
							if not (target and target.Parent) then return end
							ContextInfo:Set(target)
						end
					end)
				end
			end)
			cache.ButtonBackgroundColor3Changed=textButton:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				textButton.BackgroundColor3=ContextInfo.Active and SelectedTheme.Select.EnableColor or SelectedTheme.Select.DisableColor
			end)
			cache.ButtonTextColor3Changed=textButton:GetPropertyChangedSignal("TextColor3"):Connect(function()
				textButton.TextColor3=Color3.fromRGB(255,255,255)
			end)
		elseif typeName=="Dropdown" then
			textLabel.Text=ContextInfo.Name or ContextInfo.Text or "Dropdown Here"
			ContextInfo.Active=type(ContextInfo.Active)=="boolean" and ContextInfo.Active or false
			subtitleLabel.Text=ContextInfo.Active and "v" or "–"
			ContextInfo.Children={}
			Window:ApplyWindowHeight()
			function ContextInfo:Set(active)
				ContextInfo.Active=active
				for i,v in ipairs(ContextInfo.Children) do if type(v)=="table" and v.Parent and v.Template then v.Template.Visible=active end end
				Window:ApplyWindowHeight()
				subtitleLabel.Text=active and "v" or "–"
				CallSafely(ContextInfo.Callback,active)
			end
			function ContextInfo:Add(value) -- Value for other ui
				value.Template.Visible=ContextInfo.Active
				ContextInfo.Parent=value
				table.insert(ContextInfo.Children,value)
			end
			cache.ButtonActivated=textButton.Activated:Connect(function()
				ContextInfo:Set(not ContextInfo.Active)
			end)
		elseif typeName=="PlayerPicker" then
			cdone=true

			local options={}
			ContextInfo.Options={}

			local newDropdown=Window:AddContext({Type="Dropdown",Name="Player: None",Active=false})
			template=newDropdown.Template
			textLabel=template:FindFirstChildOfClass("TextLabel")
			template.Name=typeName
			
			local function ApplySuffix(value)
				if ContextInfo.Suffix then
					local estr=ContextInfo.Suffix
					if not string.find(estr,":") then
						estr=estr..": "
					end
					textLabel.Text=estr..value
				else
					textLabel.Text=value
				end
			end
			
			function ContextInfo:Set(player)
				if ContextInfo.Value~=player then
					ContextInfo.Value=player
					local value=if player and player.Parent then player.Name else "None"
					ApplySuffix(value)
					CallSafely(ContextInfo.Callback,player)
				end
			end
			
			local function AddPlayer(v)
				if not table.find(ContextInfo.Options,v) then
					local i=#ContextInfo.Options+1
					table.insert(ContextInfo.Options,v)

					local newButton=Window:AddContext({
						Type="Button",
						Name=v,
						Callback=function()
							if newDropdown.Parent and newDropdown.Active then
								ContextInfo:Set(v,i)
								newDropdown:Set(not newDropdown.Active)
							end
						end
					})
					newButton.Template.LayourOrder-=1

					newButton.Template.Visible=false
					newButton.Parent=newDropdown
				end
			end
			
			local function RemovePlayer(v)
				local i=table.find(ContextInfo.Options,v)
				if i~=nil then
					table.remove(ContextInfo.Options,i)
					--for j,o in ipairs(objects) do if o.Name==v then o:Destroy() table.remove(objects,j) break end end
				end
			end

			uiListLayout:ApplyLayout()

			ContextInfo.Dropdown=newDropdown

			local playerCache={}

			local function OnPlayerAdded(player)
				task.wait(1)
				if player~=nil and player.Parent~=nil then
					local userId,userName=player.UserId,player.Name
					if not playerCache[userId] then
						playerCache[userId]=userName
						AddPlayer(userName)
					end
				end
			end

			cache.PlayerAdded=Players.PlayerAdded:Connect(OnPlayerAdded)
			cache.PlayerRemoving=Players.PlayerRemoving:Connect(function(player)
				local userId,userName=player.UserId,player.Name
				if playerCache[userId]~=nil then
					playerCache[userId]=nil
					RemovePlayer(userName)
				end
			end)
			
			for i,player in ipairs(Players:GetPlayers()) do
				task.defer(OnPlayerAdded,player)
			end
			CleanCallback=function()
				ContextInfo.Dropdown=nil
				if cache.PlayerAdded then cache.PlayerAdded:Disconnect() cache.PlayerAdded=nil end
				if cache.PlayerRemoving then cache.PlayerRemoving:Disconnect() cache.PlayerRemoving=nil end
				if newDropdown then newDropdown:Destroy() end
				local k,v=next(playerCache)
				while v do
					playerCache[k]=nil
					RemovePlayer(v)
					k,v=next(playerCache)
				end
			end

			ContextInfo.Parent=true
		else
			if template~=nil then template:Destroy() template=nil end
			textLabel=nil textButton=nil textBox=nil emptyFrame=nil
		end
		if not cdone then
			ContextInfo.Template=template
			ContextInfo.Parent=true

			if template then
				template.Parent=container
				template.LayoutOrder=Window.Order
				ContextInfo.LayoutOrder=Window.Order
			end
		end 
		
		if not template then return nil end
		
		function ContextInfo:Destroy()
			local checkParent=ContextInfo.Parent
			ContextInfo.Parent=nil
			if type(checkParent)=="table" and type(checkParent.Children)=="table" then
				local index=table.find(checkParent.Children,newMetaTable)
				if index then
					table.remove(checkParent.Children,index)
				end
				checkParent=nil
			end
			if type(ContextInfo.Children)=="table" then
				local k,v=next(ContextInfo.Children)
				while v do
					ContextInfo.Children[k]=nil
					v:Destroy()
					k,v=next(ContextInfo.Children)
				end
			end
			local k,v=next(cache)
			while v do
				cache[k]=nil
				v:Disconnect()
				k,v=next(cache)
			end
			cache={}
			template:Destroy()
			table.clear(ContextInfo)
			if getmetatable(newMetaTable) then setmetatable(newMetaTable,nil) end
			table.clear(newMetaTable)
			if CleanCallback then CleanCallback() CleanCallback=nil end
		end
		

		local instances={
			["TextLabel"]=textLabel,["Toggle"]=textLabel,["TextBox"]=textBox,["TextButton"]=textButton,["Button"]=textButton,["Select"]=textButton
		}
		newMetaTable=setmetatable(contextClass,{
			__index=function(this,key)
				--local value
				--local resolve=funcs[key]
				--if resolve then
				--	return function(_,...)
				--		return resolve(this,...)
				--	end
				--end
				local value=ContextInfo[key]
				if value~=nil then return value end
				
				if key=="Visible" then
					local thisTemp=template
					if thisTemp and thisTemp.Parent then
						return thisTemp.Visible
					end
					return false
				end
				local success,result=pcall(function()
					local instance=instances[typeName]
					if instance then return instance[key] end
					return nil
				end)
				if success then return result end return nil
			end,
			__newindex=function(this,key,value)
				if key=="Visible" then
					local thisTemp=template
					if thisTemp and thisTemp.Parent then
						thisTemp.Visible=value
					end
				elseif key=="Value" then
					if next(ContextInfo) then ContextInfo:Set(value) end
				elseif key=="Parent" then
					ContextToParent(this,value,ContextInfo)
				elseif key=="Active" and this.Type=="Dropdown" then
					if next(ContextInfo) then ContextInfo:Set(value) end
				else
					local originValue=ContextInfo[key]
					if originValue and type(originValue)~="function" then
						ContextInfo[key]=value
					end
					local instance=instances[typeName]
					if instance then
						local success,result=pcall(function()
							instance[key]=value
						end)
					end
				end
			end,
		})
		table.insert(Contexts,newMetaTable)
		return newMetaTable
	end

	-- Destroy a window
	function Window:Destroy()
		if not getmetatable(WindowClass) then return end
		self.Parent=nil
		setmetatable(WindowClass,nil)
		if GrabUIClean then GrabUIClean() end
		for k,v in ipairs(Contexts) do v:Destroy() end
		self.Frame:Destroy()
		table.clear(self)
	end

	function Window:Notify(...)
		local data=PackNotif(...)
		if SelectedTheme~=nil then
			data.BackgroundColor=SelectedTheme.Notification.Background or data.BackgroundColor
			data.TitleColor=SelectedTheme.Notification.TitleColor or data.TitleColor
			data.DescriptionColor=SelectedTheme.Notification.DescriptionColor or data.DescriptionColor
		end
		UILibrary:Notify(data)
	end

	local frame=Window.Frame
	GrabUIClean=Module:GrabUI(frame)
	Window:Hide()
	Window:ApplyWindowHeight()
	Window.Open.Activated:Connect(function()
		Window:SetVisible(not Window:IsVisible())
	end)

	Window:ModifyTheme(SelectedTheme)
	frame.Visible=true

	local x={}
	WindowClass=setmetatable(x,{
		__index=function(this,key)
			local value=Window[key]
			if value~=nil then return value end
			if key=="SelectedTheme" then return SelectedTheme end
			return nil
		end,

		__newindex=function(this,key,value)
			if key=="SelectedTheme" and type(value)=="table" then 
				SelectedTheme=value
			elseif key=="Parent" then
				Window.Parent=value
			end
		end,
	})
	return WindowClass
end

function UILibrary:Notify(...)
	local data=PackNotif(...)
	local title,description,duration,mode,backgroundColor,barColor,titleColor,descriptionColor=data.Title,data.Description,data.Duration,data.Mode,data.BackgroundColor,data.BarColor,data.TitleColor,data.DescriptionColor
	if mode=="error" then
		barColor=Color3.fromRGB(255,0,0)
		if title==nil then title="Error" end
	elseif mode=="success" then
		barColor=Color3.fromRGB(0,255,0)
		if title==nil then title="Success" end
	elseif mode=="warn" then
		barColor=Color3.fromRGB(255,170,0)
		if title==nil then title="Warning" end
	end
	local tc,dc,spacing,height,width=#title,#description,10,60,260;
	local offsetY=20+(#Notifications*(height+spacing))
	local notification=Instance.new("Frame")
	notification.Size=UDim2.new(0,width,0,height)
	notification.Position=UDim2.new(1,width+20,1,-offsetY)
	notification.AnchorPoint=Vector2.new(1,1) 
	notification.BackgroundTransparency=0
	notification.BackgroundColor3=backgroundColor
	notification.ClipsDescendants=true
	notification.ZIndex=10
	notification.Parent=Gui
	local nuic1=Instance.new("UICorner")
	nuic1.CornerRadius=UDim.new(0,8)
	nuic1.Parent=notification
	local tl=Instance.new("TextLabel")
	tl.Size=UDim2.new(1,-12,0,20)
	tl.Position=UDim2.new(0,6,0,5)
	tl.BackgroundTransparency=1
	tl.Text=title
	tl.TextColor3=titleColor
	tl.Font=Enum.Font.GothamBold
	tl.TextSize=14
	tl.TextXAlignment=Enum.TextXAlignment.Left
	tl.ZIndex=11
	Module:UpdateTextSize(tl)
	tl.Name="Title"
	tl.Parent=notification
	local dl=Instance.new("TextLabel")
	dl.Size=UDim2.new(1,-12,0,18)
	dl.Position=UDim2.new(0,6,0,26)
	dl.BackgroundTransparency=1
	dl.Text=description
	dl.TextColor3=descriptionColor
	dl.Font=Enum.Font.FredokaOne
	dl.TextXAlignment=Enum.TextXAlignment.Left
	dl.ZIndex=11
	Module:UpdateTextSize(dl)
	dl.Name="Description"
	dl.Parent=notification
	local barContainer=Instance.new("Frame")
	barContainer.Size=UDim2.new(1,-12,0,4)
	barContainer.Position=UDim2.new(0,6,1,-10)
	barContainer.BackgroundTransparency=1
	barContainer.ClipsDescendants=true
	barContainer.ZIndex=11
	barContainer.Parent=notification
	local bar=Instance.new("Frame")
	bar.Size=UDim2.new(0,0,1,0)
	bar.Position=UDim2.new(0,0,0,0)
	bar.BackgroundColor3=barColor
	bar.BorderSizePixel=0
	bar.ZIndex=11
	bar.Parent=barContainer
	local nuic2=Instance.new("UICorner")
	nuic2.CornerRadius=UDim.new(1,8)
	nuic2.Parent=bar
	table.insert(Notifications,notification)
	TweenService:Create(notification,TweenInfo.new(0.3,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position=UDim2.new(1,-20,1,-offsetY),}):Play()
	TweenService:Create(bar,TweenInfo.new(duration,Enum.EasingStyle.Linear),{Size=UDim2.new(1,0,1,0)}):Play()
	task.delay(duration,function()
		TweenService:Create(notification,TweenInfo.new(0.3,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Position=notification.Position+UDim2.new(0,width+20,0,0),}):Play()
		task.wait(0.3)
		notification:Destroy()
		local notificationIndex=table.find(Notifications,notification)
		if notificationIndex then
			table.remove(Notifications,notificationIndex)
		end
		task.wait(0.2)
		for i,v in ipairs(Notifications) do
			local newY=-(20+((i-1)*(height+spacing)))
			TweenService:Create(v,TweenInfo.new(0.2),{Position=UDim2.new(1,-20,1,newY)}):Play()
		end
	end)
end

function UILibrary:GrabUI(frame)
	return Module:GrabUI(frame)
end

function UILibrary:AddTheme(name,data)
	if type(name)~="string" then return nil end
	if type(data)~="table" then return nil end
	if UILibrary.Theme[name] then return nil end
	local config=UILibrary.Theme.Default
	local newData=Module:DeepSet(config,data)
	UILibrary.Theme[name]=newData
	UILibrary:Notify({Title="Theme Added",Description=name,Duration=15})
	return newData
end

function UILibrary:IsSecretKey(Key)
	local secretKey=_G[Key]
	return if secretKey~=nil and secretKey==true then true else false
end

UILibrary.Loaded=true
UILibrary.Gui=Gui

return UILibrary
