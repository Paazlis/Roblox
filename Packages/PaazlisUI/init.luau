local function Missing(t,v,f)
	return typeof(v)==t and v or f
end

getgenv=Missing("function",getgenv,function() local _getgenv=rawget(_G,"getgenv") if not _getgenv then return _G end return _getgenv end)	
cloneref,setclipboard=Missing("function",cloneref,function(v) return v end),Missing("function",setclipboard,function(x) warn(x) return x end)

local function GetService(name)
	local service=game:GetService(name)
	if cloneref then return cloneref(service) else return service end
end

-- Safe request function for universal executor support
local function RequestSafely(options)
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
	if isfolder and makefolder and not CallSafely(isfolder, folderPath) then
		CallSafely(makefolder, folderPath)
	end
end

local Services={}

for i,v in ipairs({"Players","UserInputService","TweenService","StarterGui","RunService"}) do 
	if not Services[v] then 
		local success,service=pcall(GetService,v) 
		if success and service then 
			Services[v]=service 
		end 
	end 
end

local Players,UserInputService,TweenService,StarterGui,RunService=Services["Players"],Services["UserInputService"],Services["TweenService"],Services["StarterGui"],Services["RunService"]

local Module={}
local GlobalData={
	{
		[true]="■",
		[false]="□"
	},
	{
		[true]=Color3.fromRGB(0,200,97),
		[false]=Color3.fromRGB(255,89,89)
	}
}
local Notifications={}

local LocalPlayer=Players.LocalPlayer
local Mouse=LocalPlayer:GetMouse()
local OFFSET=UDim2.new(0,100,0,50)

local TurnSysmbols,TurnColors=unpack(GlobalData)
local baseX,baseY=1024,768
local UseStudio=RunService:IsStudio()

local Utility={}

function Utility.CreateCanvas()
	local MainFrame=Instance.new("Frame")
	MainFrame.Name="Main"
	MainFrame.BackgroundColor3=Color3.fromRGB(57,59,61)
	MainFrame.BackgroundTransparency=0
	MainFrame.BorderSizePixel=0
	MainFrame.Position=UDim2.new(0.1,0,0.38,0)
	MainFrame.Size=UDim2.new(0,180,0,34)

	local MainTitle=Instance.new("TextLabel")
	MainTitle.Name="Title"
	MainTitle.BackgroundTransparency=1
	MainTitle.BorderSizePixel=0
	MainTitle.Position=UDim2.new(0,0,0,0)
	MainTitle.Size=UDim2.new(1,0,1,0)
	MainTitle.TextSize=18
	MainTitle.Font=Enum.Font.SourceSansBold
	MainTitle.TextColor3=Color3.fromRGB(248,248,248)
	MainTitle.Text="Panel"
	MainTitle.Parent=MainFrame

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
	Open.Parent=MainFrame

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
	Container.Parent=MainFrame

	local UIListLayout=Instance.new("UIListLayout")
	UIListLayout.SortOrder=Enum.SortOrder.LayoutOrder
	UIListLayout.Parent=Container

	local UIPadding=Instance.new("UIPadding")
	UIPadding.PaddingBottom=UDim.new(0,5)
	UIPadding.PaddingLeft=UDim.new(0,5)
	UIPadding.PaddingRight=UDim.new(0,5)
	UIPadding.PaddingTop=UDim.new(0,5)
	UIPadding.Parent=Container
	
	-- Button
	local Button=Instance.new("Frame")
	Button.Name="Button"
	Button.BackgroundTransparency=1
	Button.BorderSizePixel=0
	Button.Position=UDim2.new(0,0,0,0)
	Button.Size=UDim2.new(1,0,0,30)

	local InteractButton=Instance.new("TextButton")
	InteractButton.Name="Interact"
	InteractButton.BackgroundColor3=Color3.fromRGB(163,162,165)
	InteractButton.BackgroundTransparency=0
	InteractButton.BorderSizePixel=0
	InteractButton.Position=UDim2.new(0.049,0,0.123,0)
	InteractButton.Size=UDim2.new(0.9,0,0.753,0)
	InteractButton.Text=""
	InteractButton.TextStrokeTransparency=1
	InteractButton.TextTransparency=1
	InteractButton.Parent=Button
	
	local ButtonTitle=Instance.new("TextLabel")
	ButtonTitle.Name="Title"
	ButtonTitle.BackgroundTransparency=1
	ButtonTitle.BorderSizePixel=0
	ButtonTitle.Position=UDim2.new(0.049,0,0.123,0)
	ButtonTitle.Size=UDim2.new(0.9,0,0.753,0)
	ButtonTitle.Text="Button Here"
	ButtonTitle.Font=Enum.Font.SourceSansBold
	ButtonTitle.TextStrokeTransparency=1
	ButtonTitle.TextTransparency=0
	ButtonTitle.TextColor3=Color3.fromRGB(248,248,248)
	ButtonTitle.TextSize=18
	ButtonTitle.Parent=Button
	
	-- Input
	local Input=Instance.new("Frame")
	Input.Name="Input"
	Input.BackgroundTransparency=1
	Input.BorderSizePixel=0
	Input.Position=UDim2.new(0,0,0,0)
	Input.Size=UDim2.new(1,0,0,30)

	local InputBox=Instance.new("TextBox")
	InputBox.Name="InputBox"
	InputBox.BackgroundColor3=Color3.fromRGB(163,162,165)
	InputBox.BackgroundTransparency=0
	InputBox.BorderSizePixel=0
	InputBox.Position=UDim2.new(0.049,0,0.123,0)
	InputBox.Size=UDim2.new(0.9,0,0.753,0)
	InputBox.PlaceholderText="Type here"
	InputBox.Font=Enum.Font.SourceSansBold
	InputBox.TextStrokeTransparency=1
	InputBox.TextTransparency=0
	InputBox.PlaceholderColor3=Color3.fromRGB(248,248,248)
	InputBox.TextColor3=Color3.fromRGB(248,248,248)
	InputBox.TextSize=18
	InputBox.Parent=Input
	
	-- Label
	local Label=Instance.new("Frame")
	Label.Name="Label"
	Label.BackgroundTransparency=1
	Label.BorderSizePixel=0
	Label.Position=UDim2.new(0,0,0,0)
	Label.Size=UDim2.new(1,0,0,30)

	local LabelTitle=Instance.new("TextLabel")
	LabelTitle.Name="Title"
	LabelTitle.BackgroundTransparency=1
	LabelTitle.BorderSizePixel=0
	LabelTitle.Position=UDim2.new(0,0,0,0)
	LabelTitle.Size=UDim2.new(1,0,1,0)
	LabelTitle.Text="Text Here"
	LabelTitle.Font=Enum.Font.SourceSansBold
	LabelTitle.TextStrokeTransparency=1
	LabelTitle.TextTransparency=0
	LabelTitle.TextColor3=Color3.fromRGB(248,248,248)
	LabelTitle.TextSize=18
	LabelTitle.Parent=Label
	
	Label.Parent=Container
	
	-- Toggle
	local Toggle=Instance.new("Frame")
	Toggle.Name="Toggle"
	Toggle.BackgroundTransparency=1
	Toggle.BorderSizePixel=0
	Toggle.Position=UDim2.new(0,0,0,0)
	Toggle.Size=UDim2.new(1,0,0,30)

	local ToggleTitle=Instance.new("TextLabel")
	ToggleTitle.Name="Title"
	ToggleTitle.BackgroundTransparency=1
	ToggleTitle.BorderSizePixel=0
	ToggleTitle.Position=UDim2.new(0.049,0,0.123,0)
	ToggleTitle.Size=UDim2.new(0.682,0,0.753,0)
	ToggleTitle.Text="Text Here"
	ToggleTitle.Font=Enum.Font.SourceSansBold
	ToggleTitle.TextStrokeTransparency=1
	ToggleTitle.TextTransparency=0
	ToggleTitle.TextColor3=Color3.fromRGB(248,248,248)
	ToggleTitle.TextScaled=true
	ToggleTitle.Parent=Toggle

	local ToggleButton=Instance.new("TextButton")
	ToggleButton.Name="Interact"
	ToggleButton.BackgroundTransparency=1
	ToggleButton.BorderSizePixel=0
	ToggleButton.AutoButtonColor=false
	ToggleButton.Position=UDim2.new(0.767,0,0.123,0)
	ToggleButton.Size=UDim2.new(0.179,0,0.753,0)
	ToggleButton.Text="□"
	ToggleButton.Font=Enum.Font.SourceSansBold
	ToggleButton.TextStrokeTransparency=1
	ToggleButton.TextTransparency=0
	ToggleButton.TextColor3=Color3.fromRGB(248,248,248)
	ToggleButton.TextScaled=true
	ToggleButton.Parent=Toggle
	
	Toggle.Parent=Container
	
	-- Selector
	local Selector=Instance.new("Frame")
	Selector.Name="Selector"
	Selector.BackgroundTransparency=1
	Selector.BorderSizePixel=0
	Selector.Position=UDim2.new(0,0,0,0)
	Selector.Size=UDim2.new(1,0,0,30)

	local ToggleInformation=Instance.new("TextLabel")
	ToggleInformation.Name="Information"
	ToggleInformation.BackgroundTransparency=1
	ToggleInformation.BorderSizePixel=0
	ToggleInformation.Position=UDim2.new(0,0,0,0)
	ToggleInformation.Size=UDim2.new(1,0,1,0)
	ToggleInformation.Text="Option 1"
	ToggleInformation.Font=Enum.Font.SourceSansBold
	ToggleInformation.TextStrokeTransparency=1
	ToggleInformation.TextTransparency=0
	ToggleInformation.TextColor3=Color3.fromRGB(248,248,248)
	ToggleInformation.TextSize=18
	ToggleInformation.Parent=Selector

	local NextButton=Instance.new("TextButton")
	NextButton.Name="Next"
	NextButton.AutoButtonColor=false
	NextButton.BackgroundTransparency=1
	NextButton.BorderSizePixel=0
	NextButton.Position=UDim2.new(0.806,0,0,0)
	NextButton.Size=UDim2.new(0.194,0,1,0)
	NextButton.Font=Enum.Font.SourceSansBold
	NextButton.TextColor3=Color3.fromRGB(248,248,248)
	NextButton.TextTransparency=1
	NextButton.Text=""
	NextButton.Parent=Selector

	local NextTitle=Instance.new("TextLabel")
	NextTitle.Name="Title"
	NextTitle.AnchorPoint=Vector2.new(0.5,0.5)
	NextTitle.BackgroundTransparency=1
	NextTitle.BorderSizePixel=0
	NextTitle.Position=UDim2.new(0.5,0,0.5,0)
	NextTitle.Size=UDim2.new(1,0,1,0)
	NextTitle.Text=">"
	NextTitle.Font=Enum.Font.SourceSansBold
	NextTitle.TextStrokeTransparency=1
	NextTitle.TextTransparency=0
	NextTitle.TextColor3=Color3.fromRGB(248,248,248)
	NextTitle.TextScaled=true
	NextTitle.Parent=NextButton

	local PreviousButton=Instance.new("TextButton")
	PreviousButton.Name="Previous"
	PreviousButton.AutoButtonColor=false
	PreviousButton.BackgroundTransparency=1
	PreviousButton.BorderSizePixel=0
	PreviousButton.Position=UDim2.new(0,0,0,0)
	PreviousButton.Size=UDim2.new(0.194,0,1,0)
	PreviousButton.TextScaled=true
	PreviousButton.Font=Enum.Font.SourceSansBold
	PreviousButton.TextColor3=Color3.fromRGB(248,248,248)
	PreviousButton.TextTransparency=1
	PreviousButton.Text=""
	PreviousButton.Parent=Selector

	local PreviousTitle=Instance.new("TextLabel")
	PreviousTitle.Name="Title"
	PreviousTitle.AnchorPoint=Vector2.new(0.5,0.5)
	PreviousTitle.BackgroundColor3=Color3.fromRGB(163,162,165)
	PreviousTitle.BackgroundTransparency=1
	PreviousTitle.BorderSizePixel=0
	PreviousTitle.Position=UDim2.new(0.5,0,0.5,0)
	PreviousTitle.Size=UDim2.new(1,0,1,0)
	PreviousTitle.Text="<"
	PreviousTitle.Font=Enum.Font.SourceSansBold
	PreviousTitle.TextStrokeTransparency=1
	PreviousTitle.TextTransparency=0
	PreviousTitle.TextColor3=Color3.fromRGB(248,248,248)
	PreviousTitle.TextScaled=true
	PreviousTitle.Parent=PreviousButton
	
	Selector.Parent=Container
	
	-- Select
	local Select=Instance.new("Frame")
	Select.Name="Select"
	Select.BackgroundTransparency=1
	Select.BorderSizePixel=0
	Select.Position=UDim2.new(0,0,0,0)
	Select.Size=UDim2.new(1,0,0,30)

	local DisplayFrame=Instance.new("Frame")
	DisplayFrame.Name="DisplayFrame"
	DisplayFrame.BackgroundColor3=Color3.fromRGB(200,200,200)
	DisplayFrame.BackgroundTransparency=0
	DisplayFrame.BorderSizePixel=0
	DisplayFrame.Position=UDim2.new(0.41,0,0.123,0)
	DisplayFrame.Size=UDim2.new(0.539,0,0.753,0)
	DisplayFrame.Parent=Select

	local SelectButton=Instance.new("TextButton")
	SelectButton.Name="Interact"
	SelectButton.BackgroundColor3=Color3.fromRGB(0,200,97)
	SelectButton.BackgroundTransparency=0
	SelectButton.BorderSizePixel=0
	SelectButton.Position=UDim2.new(0.049,0,0.123,0)
	SelectButton.Size=UDim2.new(0.299,0,0.753,0)
	SelectButton.Font=Enum.Font.SourceSansBold
	SelectButton.TextScaled=true
	SelectButton.TextColor3=Color3.fromRGB(248,248,248)
	SelectButton.Text="Select"
	SelectButton.Parent=Select

	local AutoTextSize1=Instance.new("UITextSizeConstraint")
	AutoTextSize1.Name="AutoTextSize"
	AutoTextSize1.MaxTextSize=20
	AutoTextSize1.MinTextSize=5
	AutoTextSize1.Parent=SelectButton
	
	Select.Parent=Container
	
	-- Expand
	local Expand=Instance.new("Frame")
	Expand.Name="Expand"
	Expand.BackgroundTransparency=1
	Expand.BorderSizePixel=0
	Expand.Position=UDim2.new(0,0,0,0)
	Expand.Size=UDim2.new(1,0,0,30)

	local ExpandTitle=Instance.new("TextLabel")
	ExpandTitle.Name="Title"
	ExpandTitle.BackgroundTransparency=1
	ExpandTitle.BorderSizePixel=0
	ExpandTitle.Position=UDim2.new(0.049,0,0,0)
	ExpandTitle.Size=UDim2.new(0.757,0,1,0)
	ExpandTitle.Text="Dropdown"
	ExpandTitle.Font=Enum.Font.SourceSansBold
	ExpandTitle.TextStrokeTransparency=1
	ExpandTitle.TextTransparency=0
	ExpandTitle.TextColor3=Color3.fromRGB(248,248,248)
	ExpandTitle.TextSize=18
	ExpandTitle.Parent=Expand

	local ExpandSubtitle=Instance.new("TextLabel")
	ExpandSubtitle.Name="Subtitle"
	ExpandSubtitle.BackgroundTransparency=1
	ExpandSubtitle.BorderSizePixel=0
	ExpandSubtitle.Position=UDim2.new(0.806,0,0,0)
	ExpandSubtitle.Size=UDim2.new(0.194,0,1,0)
	ExpandSubtitle.Text="-"
	ExpandSubtitle.Font=Enum.Font.SourceSansBold
	ExpandSubtitle.TextStrokeTransparency=1
	ExpandSubtitle.TextTransparency=0
	ExpandSubtitle.TextColor3=Color3.fromRGB(248,248,248)
	ExpandSubtitle.TextSize=18
	ExpandSubtitle.Parent=Expand

	local ExpandButton=Instance.new("TextButton")
	ExpandButton.Name="Interact"
	ExpandButton.AutoButtonColor=false
	ExpandButton.BackgroundTransparency=1
	ExpandButton.BorderSizePixel=0
	ExpandButton.Position=UDim2.new(0,0,0,0)
	ExpandButton.Size=UDim2.new(1,0,1,0)
	ExpandButton.Font=Enum.Font.SourceSansBold
	ExpandButton.TextColor3=Color3.fromRGB(248,248,248)
	ExpandButton.TextTransparency=1
	ExpandButton.Parent=Expand
	
	Expand.Parent=Container
	
	return {
		["Frame"]=MainFrame,
		["Title"]=MainTitle,
		["Open"]=Open,
		["Container"]=Container,
		["UIListLayout"]=UIListLayout,
		["Label"]=Label,
		["Button"]=Button,
		["Input"]=Input,
		["Toggle"]=Toggle,
		["Selector"]=Selector,
		["Select"]=Select,
		["Expand"]=Expand
	}
end

function Utility.CreateKeyCanvas(Settings)
	local ScreenGui=Instance.new("ScreenGui")
	ScreenGui.Name="Key"
	ScreenGui.ResetOnSpawn=false

	local MainFrame=Instance.new("Frame",ScreenGui)
	MainFrame.Size=UDim2.new(0,340,0,420)
	MainFrame.Position=UDim2.new(0.5,-170,0.5,-210)
	MainFrame.BackgroundColor3=Color3.fromRGB(25,26,31)
	MainFrame.Active=true
	MainFrame.Draggable=true
	Instance.new("UICorner",MainFrame).CornerRadius=UDim.new(0,15)

	local mainStroke=Instance.new("UIStroke",MainFrame)
	mainStroke.Thickness=2
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
	Title.Font=Enum.Font.GothamBold
	Title.TextSize=16
	Instance.new("UICorner",Title).CornerRadius=UDim.new(0,15)

	local PromoText=Instance.new("TextLabel",MainFrame)
	PromoText.Size=UDim2.new(0.9,0,0,50)
	PromoText.Position=UDim2.new(0.05,0,0,50)
	PromoText.BackgroundTransparency=1
	PromoText.Text=Settings.Description or "Description"
	PromoText.TextColor3=Color3.fromRGB(0,170,255)
	PromoText.Font=Enum.Font.GothamBold
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
		DiscordBtn.Font="GothamBold"
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
			RequestSafely({Url="http://localhost:1111/discord?invite=" .. inviteCode,Method="GET"})
		end)

		currentYOffset=currentYOffset + 45
	end

	-- Instagram Button
	if Settings.ShowInstagram and Settings.InstagramURL then
		local InstaBtn=Instance.new("TextButton",MainFrame)
		InstaBtn.Size=UDim2.new(0.85,0,0,35)
		InstaBtn.Position=UDim2.new(0.075,0,0,currentYOffset)
		InstaBtn.Text="      FOLLOW INSTAGRAM"
		InstaBtn.Font="GothamBold"
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
		YTBtn.Font="GothamBold"
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
	GetKeyBtn.BackgroundColor3=Color3.fromRGB(35,35,35)
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

local UIFolder="Pazui"

local PlayerGui=LocalPlayer:WaitForChild("PlayerGui")
local CoreGui=UseStudio and GetService("CoreGui") or nil

function Utility.DeepSet(t1,t2)
	local result={}
	for k,v in t2 do
		if t1[k]~=nil and type(t1[k])==type(v) then
			if type(v)=="table" then
				result[k]=Utility.DeepChange(t1,v)
			else
				result[k]=v
			end
		end
	end
	return result
end

function Utility.SetProtectUI(v)
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

function Utility.EnableProtectUI(vName,v,oldVName,enabled)
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

function Utility.IsEmpty(s)
	if type(s)=="string" then
		if string.len(s)==0 then return true end
		local v=string.match(s,"^%s*$")
		if v==nil then return false end
		return true
	end
	return true
end

function Utility.DeepCopy(t)
	local copyTable={}
	for k,v in t do
		if type(v)=="table" then
			copyTable[k]=Utility.DeepCopy(v)
		else
			copyTable[k]=v
		end
	end
	return copyTable
end

function Utility.GrabUI(frame:Instance)
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

function Utility.ResizeUIScale(ui,screenSize,x,y,callback)
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

function Utility.UpdateTextSize(label)
	local c=#label.Text label.TextSize=if c>=90 and c<101 then 0 elseif c>=60 and c<70 then 7 elseif c>=50 and c<60 then 8 elseif c>=10 and c<20 then 10 else 14 label.TextScaled=label.TextSize<=0
end

function Utility.PackNotif(...)
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

function Utility.SetAutoResizeUI(ui,data)
	data=type(data)=="table" and data or {}
	Utility.ResizeUIScale(ui,workspace.CurrentCamera.ViewportSize,data.BaseX and data.BaseX or baseX,data.BaseY and data.BaseY or baseY,data.Callback)
	local connection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		Utility.ResizeUIScale(ui,workspace.CurrentCamera.ViewportSize,data.BaseX or baseX,data.BaseY or baseY,data.Callback)
	end)
	ui.Destroying:Connect(function() connection:Disconnect() end)
	return function() connection:Disconnect() end
end

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

function UILibrary:SetAutoResizeUI(ui,data)
	return Utility.SetAutoResizeUI(ui,data)
end

function UILibrary:SetProtectUI(ui)
	return Utility.SetProtectUI(ui)
end

function UILibrary:EnableProtectUI(vName,v,oldVName,enabled)
	return Utility.EnableProtectUI(vName,v,oldVName,enabled)
end

function UILibrary:CreateKeySystem(KeyInfo)
	if not game:IsLoaded() then game.Loaded:Wait() end
	
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
	local DefaultInfo={
		Title          ="Panel",-- The main title shown at the top of the GUI
		Description    ="Key System",-- The text shown below the title
		UseNonce       =true,-- To prevent replay attacks and request tampering.
		FileName       ="Mykey.txt",-- The name of the file where the valid key will be saved for auto-login
		FolderName     =UIFolder,-- The name of the folder where the key will be saved

		-- [1] PlatoBoost Settings
		ServiceId      =0,-- Your PlatoBoost Service ID
		PlatoSecret    ="",-- Your PlatoBoost Secret Key

		-- [2] Anti-Bypass / Global Secret Variable
		Secret         ="1234",-- This makes the script ONLY run from the key script. Even if they copy the original obfuscated script to bypass the key,they won't be able to!

		-- [3] Scripts & Links
		NoScriptURL    =false, -- If you don't want to use the script URL, you can set this to true to want to disable the script from running on the client.
		ScriptURL      =nil,-- The raw URL of your main script

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

	for k,v in pairs(DefaultInfo) do if KeyInfo[k]==nil then KeyInfo[k]=v end end

	if KeyInfo.GuiName~=DefaultInfo.GuiName and KeyInfo.OldGuiName==DefaultInfo.OldGuiName then
		KeyInfo.OldGuiName=KeyInfo.GuiName.."-Old"
	end

	KeyInfo.Type="KeySystem" KeyInfo.Pass=false KeyInfo.Rejected=false KeyInfo.Closed=false KeyInfo.Parent=true KeyInfo.WaitForKey=function() end KeyInfo.Destroy=function() end

	-------------------------------------------------------------------------------
	--! Library Json and Cryptography
	-------------------------------------------------------------------------------
	local a=2^32;local b=a-1;local function c(d,e)local f,g=0,1;while d~=0 or e~=0 do local h,i=d%2,e%2;local j=(h+i)%2;f=f+j*g;d=math.floor(d/2)e=math.floor(e/2)g=g*2 end;return f%a end;local function k(d,e,l,...)local m;if e then d=d%a;e=e%a;m=c(d,e)if l then m=k(m,l,...)end;return m elseif d then return d%a else return 0 end end;local function n(d,e,l,...)local m;if e then d=d%a;e=e%a;m=(d+e-c(d,e))/2;if l then m=n(m,l,...)end;return m elseif d then return d%a else return b end end;local function o(p)return b-p end;local function q(d,r)if r<0 then return lshift(d,-r)end;return math.floor(d%2^32/2^r)end;local function s(p,r)if r>31 or r<-31 then return 0 end;return q(p%a,r)end;local function lshift(d,r)if r<0 then return s(d,-r)end;return d*2^r%2^32 end;local function t(p,r)p=p%a;r=r%32;local u=n(p,2^r-1)return s(p,r)+lshift(u,32-r)end;local v={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function w(x)return string.gsub(x,".",function(l)return string.format("%02x",string.byte(l))end)end;local function y(z,A)local x=""for B=1,A do local C=z%256;x=string.char(C)..x;z=(z-C)/256 end;return x end;local function D(x,B)local A=0;for B=B,B+3 do A=A*256+string.byte(x,B)end;return A end;local function E(F,G)local H=64-(G+9)%64;G=y(8*G,8)F=F.."\128"..string.rep("\0",H)..G;assert(#F%64==0)return F end;local function I(J)J[1]=0x6a09e667;J[2]=0xbb67ae85;J[3]=0x3c6ef372;J[4]=0xa54ff53a;J[5]=0x510e527f;J[6]=0x9b05688c;J[7]=0x1f83d9ab;J[8]=0x5be0cd19;return J end;local function K(F,B,J)local L={}for M=1,16 do L[M]=D(F,B+(M-1)*4)end;for M=17,64 do local N=L[M-15]local O=k(t(N,7),t(N,18),s(N,3))N=L[M-2]L[M]=(L[M-16]+O+L[M-7]+k(t(N,17),t(N,19),s(N,10)))%a end;local d,e,l,P,Q,R,S,T=J[1],J[2],J[3],J[4],J[5],J[6],J[7],J[8]for B=1,64 do local O=k(t(d,2),t(d,13),t(d,22))local U=k(n(d,e),n(d,l),n(e,l))local V=(O+U)%a;local W=k(t(Q,6),t(Q,11),t(Q,25))local X=k(n(Q,R),n(o(Q),S))local Y=(T+W+X+v[B]+L[B])%a;T=S;S=R;R=Q;Q=(P+Y)%a;P=l;l=e;e=d;d=(Y+V)%a end;
	J[1]=(J[1]+d)%a;J[2]=(J[2]+e)%a;J[3]=(J[3]+l)%a;J[4]=(J[4]+P)%a;J[5]=(J[5]+Q)%a;J[6]=(J[6]+R)%a;J[7]=(J[7]+S)%a;J[8]=(J[8]+T)%a end;local function Z(F)F=E(F,#F)local J=I({})for B=1,#F,64 do K(F,B,J)end;return w(y(J[1],4)..y(J[2],4)..y(J[3],4)..y(J[4],4)..y(J[5],4)..y(J[6],4)..y(J[7],4)..y(J[8],4))end;local e;local l={["\\"]="\\",["\""]="\"",["\b"]="b",["\f"]="f",["\n"]="n",["\r"]="r",["\t"]="t"}
	local P={["/"]="/"}for Q,R in pairs(l)do P[R]=Q end;local S=function(T)return"\\"..(l[T]or string.format("u%04x",T:byte()))end;local B=function(M)return"null"end;local v=function(M,z)local _={}z=z or{}if z[M]then error("circular reference")end;z[M]=true;if rawget(M,1)~=nil or next(M)==nil then local A=0;for Q in pairs(M)do if type(Q)~="number"then error("invalid table: mixed or invalid key types")end;A=A+1 end;if A~=#M then error("invalid table: sparse array")end;for a0,R in ipairs(M)do table.insert(_,e(R,z))end;z[M]=nil;return"["..table.concat(_,",").."]"else for Q,R in pairs(M)do if type(Q)~="string"then error("invalid table: mixed or invalid key types")end;table.insert(_,e(Q,z)..":"..e(R,z))end;z[M]=nil;return"{"..table.concat(_,",").."}"end end;local g=function(M)return'"'..M:gsub('[%z\1-\31\\"]',S)..'"'end;local a1=function(M)if M~=M or M<=-math.huge or M>=math.huge then error("unexpected number value '"..tostring(M).."'")end;return string.format("%.14g",M)end;local j={["nil"]=B,["table"]=v,["string"]=g,["number"]=a1,["boolean"]=tostring}e=function(M,z)local x=type(M)local a2=j[x]if a2 then return a2(M,z)end;error("unexpected type '"..x.."'")end;local a3=function(M)return e(M)end;local a4;local N=function(...)local _={}for a0=1,select("#",...)do _[select(a0,...)]=true end;return _ end;local L=N(" ","\t","\r","\n")local p=N(" ","\t","\r","\n","]","}",",")local a5=N("\\","/",'"',"b","f","n","r","t","u")local m=N("true","false","null")local a6={["true"]=true,["false"]=false,["null"]=nil}local a7=function(a8,a9,aa,ab)for a0=a9,#a8 do if aa[a8:sub(a0,a0)]~=ab then return a0 end end;return#a8+1 end;local ac=function(a8,a9,J)local ad=1;local ae=1;for a0=1,a9-1 do ae=ae+1;if a8:sub(a0,a0)=="\n"then ad=ad+1;ae=1 end end;error(string.format("%s at line %d col %d",J,ad,ae))end;local af=function(A)local a2=math.floor;if A<=0x7f then return string.char(A)elseif A<=0x7ff then return string.char(a2(A/64)+192,A%64+128)elseif A<=0xffff then return string.char(a2(A/4096)+224,a2(A%4096/64)+128,A%64+128)elseif A<=0x10ffff then return string.char(a2(A/262144)+240,a2(A%262144/4096)+128,a2(A%4096/64)+128,A%64+128)end;error(string.format("invalid unicode codepoint '%x'",A))end;local ag=function(ah)local ai=tonumber(ah:sub(1,4),16)local aj=tonumber(ah:sub(7,10),16)if aj then return af((ai-0xd800)*0x400+aj-0xdc00+0x10000)else return af(ai)end end;local ak=function(a8,a0)local _=""local al=a0+1;local Q=al;while al<=#a8 do local am=a8:byte(al)if am<32 then ac(a8,al,"control character in string")elseif am==92 then _=_..a8:sub(Q,al-1)al=al+1;local T=a8:sub(al,al)if T=="u"then local an=a8:match("^[dD][89aAbB]%x%x\\u%x%x%x%x",al+1)or a8:match("^%x%x%x%x",al+1)or ac(a8,al-1,"invalid unicode escape in string")_=_..ag(an)al=al+#an else if not a5[T]then ac(a8,al-1,"invalid escape char '"..T.."' in string")end;_=_..P[T]end;Q=al+1 elseif am==34 then _=_..a8:sub(Q,al-1)return _,al+1 end;al=al+1 end;ac(a8,a0,"expected closing quote for string")end;local ao=function(a8,a0)local am=a7(a8,a0,p)local ah=a8:sub(a0,am-1)local A=tonumber(ah)if not A then ac(a8,a0,"invalid number '"..ah.."'")end;return A,am end;local ap=function(a8,a0)local am=a7(a8,a0,p)local aq=a8:sub(a0,am-1)if not m[aq]then ac(a8,a0,"invalid literal '"..aq.."'")end;return a6[aq],am end;local ar=function(a8,a0)local _={}local A=1;a0=a0+1;while 1 do local am;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="]"then a0=a0+1;break end;am,a0=a4(a8,a0)_[A]=am;A=A+1;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="]"then break end;if as~=","then ac(a8,a0,"expected ']' or ','")end end;return _,a0 end;local at=function(a8,a0)local _={}a0=a0+1;while 1 do local au,M;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="}"then a0=a0+1;break end;if a8:sub(a0,a0)~='"'then ac(a8,a0,"expected string for key")end;au,a0=a4(a8,a0)a0=a7(a8,a0,L,true)if a8:sub(a0,a0)~=":"then ac(a8,a0,"expected ':' after key")end;a0=a7(a8,a0+1,L,true)M,a0=a4(a8,a0)_[au]=M;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="}"then break end;if as~=","then ac(a8,a0,"expected '}' or ','")end end;return _,a0 end;local av={['"']=ak,["0"]=ao,["1"]=ao,["2"]=ao,["3"]=ao,["4"]=ao,["5"]=ao,["6"]=ao,["7"]=ao,["8"]=ao,["9"]=ao,["-"]=ao,["t"]=ap,["f"]=ap,["n"]=ap,["["]=ar,["{"]=at}a4=function(a8,a9)local as=a8:sub(a9,a9)local a2=av[as]if a2 then return a2(a8,a9)end;ac(a8,a9,"unexpected character '"..as.."'")end;local aw=function(a8)if type(a8)~="string"then error("expected argument of type string, got "..type(a8))end;local _,a9=a4(a8,a7(a8,1,L,true))a9=a7(a8,a9,L,true)if a9<=#a8 then ac(a8,a9,"trailing garbage")end;return _ end;
	local lEncode,lDecode,lDigest=a3,aw,Z;

	-------------------------------------------------------------------------------
	--! CORE FUNCTIONS (REQUESTS & VERIFICATION)
	-------------------------------------------------------------------------------
	
	--! configuration
	local FileName=KeyInfo.FileName
	local FolderName=KeyInfo.FolderName
	local ServiceId=KeyInfo.ServiceId -- your service id, this is used to identify your service.
	local PlatoSecret=KeyInfo.PlatoSecret -- make sure to obfuscate this if you want to ensure security.
	local UseNonce=KeyInfo.UseNonce -- Hidden from Config to avoid user confusion, but active for security and use a nonce to prevent replay attacks and request tampering.
	local KeySecret=KeyInfo.Secret
	local GuiName=KeyInfo.GuiName
	local OldGuiName=KeyInfo.OldGuiName
	
	--! functions
	local fStringChar,fToString,fStringSub,fOsTime,fMathRandom,fMathFloor,fGetHwid=string.char,tostring,string.sub,os.time,math.random,math.floor,gethwid or function() return LocalPlayer.UserId end
	local requestSending,cachedLink,cachedTime=false,"",0
	local host="https://api.platoboost.com"
	local verifyAccept,maxVerifyAccept=0,30
	
	-- Check server connectivity
	local CheckConnectivity=function()
		local response=RequestSafely({Url=host .. "/public/connectivity",Method="GET"})
		if not response or (response.StatusCode ~= 200 and response.StatusCode ~= 429) then
			host="https://api.platoboost.net"
		end
	end

	CheckConnectivity()

	local GenerateNonce=function()
		local str="" for _=1,16 do str=str .. fStringChar(fMathFloor(fMathRandom()*(122-97+1))+97) end return str
	end

	-- Get player's key link
	local CacheLink=function()
		if cachedTime+(10*60)<fOsTime() then
			local response=RequestSafely({
				Url=host.."/public/start",
				Method="POST",
				Body=lEncode({
					service=ServiceId,
					identifier=lDigest(fGetHwid())
				}),
				Headers={
					["Content-Type"]="application/json"
				}
			})
			local message=""
			if response.StatusCode==200 then
				local decoded=lDecode(response.Body)
				if decoded.success==true then
					cachedLink=decoded.data.url
					cachedTime=fOsTime()
					return true,cachedLink
				else
					return false,decoded.message
				end
			elseif response.StatusCode==429 then
				return false,"you are being rate limited, please wait 20 seconds and try again."
			end
			return false,"Failed to cache link."
		else
			return true,cachedLink
		end
	end

	-- Redeem player's key
	local RedeemKey=function(key)
		if UseStudio then
			local isKey=key==KeySecret
			return isKey,not isKey and "key is invalid." or nil
		else
			local textNonce=GenerateNonce()
			local endpoint=host.."/public/redeem/".. fToString(ServiceId)

			local body={
				identifier=lDigest(fGetHwid()),
				key=key
			}

			if UseNonce then
				body.nonce=textNonce
			end

			local response=RequestSafely({
				Url=endpoint,
				Method="POST",
				Body=lEncode(body),
				Headers={
					["Content-Type"]="application/json"
				}
			})

			if response.StatusCode==200 then
				local decoded=lDecode(response.Body)
				if decoded.success==true then
					if decoded.data.valid==true then
						if UseNonce then
							if decoded.data.hash==lDigest("true" .. "-" .. textNonce .. "-" .. PlatoSecret) then
								return true
							else
								return false,"failed to verify integrity."
							end    
						else
							return true;
						end
					else
						return false,"key is invalid."
					end
				else
					if fStringSub(decoded.message,1,27)=="unique constraint violation" then
						return false,"you already have an active key, please wait for it to expire before redeeming it."
					else
						return false,decoded.message
					end
				end
			elseif response.StatusCode==429 then
				return false,"you are being rate limited, please wait 20 seconds and try again."
			else
				return false,"server returned an invalid status code,please try again later."
			end
		end
	end

	-- Verify key on input
	local VerifyKey=function(key)
		if requestSending then return false end
		requestSending=true

		local textNonce=GenerateNonce()
		local endpoint=host .. "/public/whitelist/" .. fToString(ServiceId) .. "?identifier=" .. lDigest(fGetHwid()) .. "&key=" .. key

		if UseNonce then
			endpoint=endpoint .. "&nonce=" .. textNonce
		end

		local response=RequestSafely({
			Url=endpoint,
			Method="GET",
		})
		local message=""
		requestSending=false

		if response.StatusCode==200 then
			local decoded=lDecode(response.Body)
			if decoded.success==true then
				if decoded.data.valid==true then
					if UseNonce then
						if decoded.data.hash==lDigest("true" .. "-" .. textNonce .. "-" .. PlatoSecret) then
							return true
						else
							return false,"failed to verify integrity."
						end
					else
						return true;
					end
				else
					if fStringSub(key,1,4)=="KEY_" then
						return RedeemKey(key)
					else
						return false,"key is invalid."
					end
				end
			else
				return false,decoded.message
			end
		elseif response.StatusCode==429 then
			return false,"you are being rate limited, please wait 20 seconds and try again."
		else
			return false,"server returned an invalid status code, please try again later."
		end
	end

	local GetFlag=function(name)
		local textNonce=GenerateNonce()
		local endpoint=host.."/public/flag/".. fToString(ServiceId) .."?name="..name

		if UseNonce then
			endpoint=endpoint .. "&nonce=" .. textNonce
		end

		local response=RequestSafely({
			Url=endpoint,
			Method="GET",
		})
		local message=""

		if response.StatusCode==200 then
			local decoded=lDecode(response.Body)
			if decoded.success==true then
				if UseNonce then
					if decoded.data.hash==lDigest(fToString(decoded.data.value) .. "-" .. textNonce .. "-" .. PlatoSecret) then
						return decoded.data.value
					else
						return nil,"failed to verify integrity."
					end
				else
					return decoded.data.value;
				end
			else
				return nil,decoded.message
			end
		else
			return nil,"server returned an invalid status code, please try again later."
		end
	end

	-------------------------------------------------------------------------------
	--! GUI & MAIN SCRIPT EXECUTION
	-------------------------------------------------------------------------------

	local function StartScriptURL()
		-- Set secret global variable to bypass main script protection
		pcall(function() getgenv()[KeySecret]=true end)
		-- Execute main script
		if not KeyInfo.NoScriptURL then pcall(function() loadstring(game:HttpGet(KeyInfo.ScriptURL))() end) end
	end
	
	EnsureFolder(FolderName.."/Key System")

	-- Auto Check Saved Key
	if isfile and CallSafely(isfile,FolderName.."/Key System".."/"..FileName) and readfile then
		local savedKey=CallSafely(readfile,FolderName.."/Key System".."/"..FileName)
		if not Utility.IsEmpty(savedKey) then
			local success=RedeemKey(savedKey)
			if success then
				if not KeyInfo.Pass then 
					KeyInfo.Pass=true
					UILibrary:Notify({Title=KeyInfo.Title,Description="Auto-login success!",Duration=5})
					task.wait(2)
					StartScriptURL()
					return KeyInfo
				end
			else
				UILibrary:Notify({Mode="warn",Description="Saved key expired or invalid.",Duration=5})
			end
		end
	end
	
	-- Initialize Key System GUI
	local KeyTable=Utility.CreateKeyCanvas(KeyInfo)
	local KeyGui=KeyTable.Gui
	KeyGui.Name=GuiName
	KeyGui.Enabled=true
	Utility.SetProtectUI(KeyGui)
	Utility.EnableProtectUI(GuiName,KeyGui,OldGuiName,false)
	
	local cleanResizeUI=Utility.SetAutoResizeUI(KeyGui,{BaseX=baseX,BaseY=baseY})
	local CloseButton=KeyTable.CloseButton
	local VerifyButton=KeyTable.VerifyButton
	local GetKeyButton=KeyTable.GetKeyButton
	local KeyInput=KeyTable.KeyInput
	local Status=KeyTable.Status
	local SaveStatus={TextColor3=Status.TextColor3,Text=Status.Text}
	local LastStatus=SaveStatus.Text
	
	local KeyCache={}
	local ProxyKey={}
	
	local ApplyKey=function(key)
		if KeyInfo.Pass==true or KeyInfo.Rejected==true or KeyInfo.Closed==true then return end
		if Utility.IsEmpty(key) then 
			LastStatus="Enter a key!"
			Status.Text=LastStatus
			Status.TextColor3=Color3.fromRGB(255,50,50)
			task.wait(2)
			if Status.Text==LastStatus then
				Status.Text=SaveStatus.Text
				Status.TextColor3=SaveStatus.TextColor3
			end
			return 
		end
		Status.Text="Verifying..."
		task.wait(1)
		local success,message=RedeemKey(key)
		if success then
			if not KeyInfo.Pass then 
				KeyInfo.Pass=true
				if writefile then CallSafely(writefile,FolderName.."/Key System".."/"..FileName,key) end
				LastStatus="Success! Loading..."
				Status.Text=LastStatus
				Status.TextColor3=Color3.fromRGB(0,255,100)
				task.wait(2)
				KeyInfo:Destroy()
				StartScriptURL()
			end
		else
			if verifyAccept>=maxVerifyAccept then 
				KeyInfo.Rejected=true
				LastStatus="Now you are rejected for this"
				Status.Text=LastStatus
				Status.TextColor3=Color3.fromRGB(255,50,50)
				task.wait(2)
				KeyInfo:Destroy()
				return
			end
			verifyAccept+=1
			LastStatus=message
			Status.Text=LastStatus
			Status.TextColor3=Color3.fromRGB(255,50,50)
			task.wait(2)
		end
		if Status.Text==LastStatus then
			Status.Text=SaveStatus.Text
			Status.TextColor3=SaveStatus.TextColor3
		end
	end
	
	function KeyInfo:WaitForKey()
		repeat task.wait() until KeyInfo.Pass==true or KeyInfo.Rejected==true or KeyInfo.Closed==true
	end
	
	function KeyInfo:Destroy()
		setmetatable(ProxyKey,nil)
		cleanResizeUI()
		KeyGui.Name=OldGuiName
		KeyGui.Enabled=false
		local k,v=next(KeyCache)
		while v do
			KeyCache[k]=nil
			v:Disconnect()
			k,v=next(KeyCache)
		end
	end
	
	-- Logic
	KeyCache.CloseActivated=CloseButton.Activated:Connect(function() KeyInfo.Closed=true KeyInfo:Destroy() end)
	KeyCache.FocusLost=KeyInput.FocusLost:Connect(function(enter)
		if not enter then return end
		ApplyKey(KeyInput.Text)
	end)
	KeyCache.VerifyActivated=VerifyButton.Activated:Connect(function()
		ApplyKey(KeyInput.Text)
	end)
	KeyCache.GetKeyActivated=GetKeyButton.Activated:Connect(function()
		Status.Text = "Getting Link..."
		local success,response=CacheLink()
		if success then
			setclipboard(response)
			LastStatus="Link Copied!"
			Status.Text=LastStatus
			Status.TextColor3=Color3.fromRGB(0,170,255)
			task.wait(2)
		else
			LastStatus="Error: ".. tostring(response)
			Status.Text=LastStatus
			Status.TextColor3=Color3.fromRGB(255,50,50)
			task.wait(2)
		end
		if Status.Text==LastStatus then
			Status.Text=SaveStatus.Text
			Status.TextColor3=SaveStatus.TextColor3
		end
	end)

	local KeyClass={}
	ProxyKey=setmetatable(KeyClass,{
		__index=function(this,key)
			local value=KeyInfo[key]
			if value~=nil then return value end
			return nil
		end,
		__newindex=function(this,key,value) end,
	})
	return ProxyKey
end

local Gui=nil
local Canvas={}

if not getgenv().PazuiCanvas then
	Gui=Instance.new("ScreenGui")
	Gui.Name="Pazui"
	Gui.DisplayOrder=0
	Gui.ResetOnSpawn=false
	Gui.AutoLocalize=true
	Gui.ZIndexBehavior=Enum.ZIndexBehavior.Global

	local NewCanvas=Utility.CreateCanvas()
	NewCanvas.Gui=Gui
	NewCanvas.Frame.Name="Template"
	NewCanvas.Frame.Visible=false
	
	for i,v in ipairs(NewCanvas.Container:GetChildren()) do if v:IsA("Frame") then v.Visible=false end end
	
	Utility.SetAutoResizeUI(Gui,{BaseX=baseX,BaseY=baseY})
	Utility.SetProtectUI(Gui)
	
	Canvas=NewCanvas
	getgenv().PazuiCanvas=NewCanvas
else
	Canvas=getgenv().PazuiCanvas
	Gui=Canvas.Gui
end

if not getgenv().PazuiWindows then
	getgenv().PazuiWindows={}
end

UILibrary.Gui=Gui

function UILibrary:CreateWindow(WindowInfo)
	WindowInfo=Missing("table",WindowInfo,{})
	local WindowName=Missing("string",WindowInfo.Name,"None")
	local frame=Canvas.Frame:Clone()
	local container=frame:FindFirstChild("Container")
	frame.Parent=Canvas.Gui
	local Window={["Frame"]=frame}
	local ProxyWindow={}
	local CleanGrab=Utility.GrabUI(frame)
	EnsureFolder(UIFolder)
	local SelectedTheme=UILibrary.Theme.Default
	local Contexts={}
	local WindowClass={}
	frame.Title.Text=Missing("string",WindowName,frame.Title.Text)
	Window.Type="Window"
	Window.Order=0
	Window.Parent=true
	
	function Window:ModifyTheme(theme)
		local success=pcall(function()
			if type(theme)=="string" then
				SelectedTheme=UILibrary.Theme[theme]
			elseif type(theme)=="table" then
				SelectedTheme=theme
			else
				return
			end
			frame.BackgroundColor3=SelectedTheme.Background
			frame.Container.BackgroundColor3=SelectedTheme.Topbar
			frame.Title.TextColor3=SelectedTheme.TextColor
		end)
	end
	
	local lastFrame=getgenv().LastPazuiFrame
	if lastFrame and lastFrame.Position==frame.Position then
		lastFrame.Position=frame.Position+OFFSET
	end
	
	getgenv().LastPazuiFrame=frame
	
	-- Recalculate the window height
	function Window:ApplyWindowHeight()
		local height=container.UIListLayout.AbsoluteContentSize.Y+container.UIPadding.PaddingTop.Offset+container.UIPadding.PaddingBottom.Offset
		container.Size=UDim2.new(container.Size.X.Scale,container.Size.X.Offset,0,math.clamp(height,0,300))
	end
	
	-- Set the visibility of the window
	function Window:SetVisible(visible)
		container.Visible=visible
		local open=frame.Open
		open.Text=visible and "–" or "v"
		open.TextSize=visible and 30 or 18
		self:ApplyWindowHeight()
	end
	
	-- Get the visibility of the window
	function Window:IsVisible()
		return container.Visible
	end
	
	-- Hide the visibility of the window
	function Window:Hide()
		self:SetVisible(false)
	end 
	
	local ContextToParent=function(this,value,info)
		if value~=nil and type(value)=="table" and getmetatable(value) and type(value.List)=="table" and value.Parent and value.Template then
			value.Template.Visible=this.Active
			info.Parent=value
			table.insert(info.List,this)
		else
			local lastValue=info.Parent
			info.Parent=value
			if lastValue and type(lastValue)=="table" and getmetatable(lastValue) and type(lastValue.List)=="table" then
				local index=table.find(lastValue.List,this)
				if index then
					table.remove(lastValue.List,index)
				end
				lastValue=nil
			end
		end
	end
	
	-- Context
	function Window:AddContext(ContextInfo)
		ContextInfo=Missing("table",ContextInfo,{})
		local Type=Missing("string",ContextInfo.Type,"None")
		local Template=nil
		local Cache={}
		if (Type=="Button" or Type=="Input" or Type=="TextBox" or Type=="Select" or Type=="Toggle" or Type=="Selector") and type(ContextInfo.Callback)~="function" then
			ContextInfo.Callback=function(...) end
		end
		if Type=="Label" or Type=="TextLabel" then
			local Label=Canvas.Label:Clone()
			Template=Label
			Label.Title.Text=ContextInfo.Name or ContextInfo.Text or "Label Here"
			Label.Visible=true
			Label.LayoutOrder=Window.Order
			Label.Parent=container
			Window.Order+=1
			function ContextInfo:Set(Text)
				if Text then Label.Title.Text=Text end
			end
			Cache.BackgroundColor3Changed=frame:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Label.Title.TextColor3=SelectedTheme.TextColor
			end)
		elseif Type=="Button" or Type=="TextButton" then
			local Button=Canvas.Button:Clone()
			Template=Button
			Button.Title.Text=ContextInfo.Name or ContextInfo.Text or "Button Here"
			Button.Visible=true
			Button.LayoutOrder=Window.Order
			Button.Parent=container
			Window.Order+=1
			Cache.Activated=Button.Interact.Activated:Connect(function() CallSafely(ContextInfo.Callback) end)
			function ContextInfo:Set(Text)
				Button.Title.Text=Text
			end
			Cache.BackgroundColor3Changed=frame:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				if not ContextInfo.NoTheme then
					Button.Title.TextColor3=SelectedTheme.TextColor
					Button.Interact.BackgroundColor3=SelectedTheme.Button.Background
					Button.BackgroundColor3=SelectedTheme.Button.Background
				end
			end)
		elseif Type=="Input" or Type=="TextBox" then
			local Input=Canvas.Input:Clone()
			Template=Input
			local InputBox:TextBox=Input.InputBox
			InputBox.PlaceholderText=ContextInfo.PlaceholderText or "Type here"
			Input.Visible=true
			Input.LayoutOrder=Window.Order
			Input.Parent=container
			Window.Order+=1
			Cache.FocusLost=InputBox.FocusLost:Connect(function(Submit)
				if not Submit then return end
				CallSafely(ContextInfo.Callback,InputBox.Text)
			end)
			Cache.TextChanged=InputBox:GetPropertyChangedSignal("Text"):Connect(function()
				if ContextInfo.Changed then pcall(ContextInfo.Changed,InputBox.Text) end
			end)
			Cache.BackgroundColor3Changed=frame:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				InputBox.BackgroundColor3=SelectedTheme.Input.Background
				InputBox.TextColor3=SelectedTheme.TextColor
				InputBox.PlaceholderColor3=SelectedTheme.PlaceholderColor
			end)
			function ContextInfo:Set(Text)
				InputBox.Text=Text
				ContextInfo.Value=Text
				CallSafely(ContextInfo.Callback,Text)
			end
		elseif Type=="Toggle" then
			ContextInfo.Value=Missing("boolean",ContextInfo.Value,false)
			local Toggle=Canvas.Toggle:Clone()
			Template=Toggle
			Toggle.Title.Text=ContextInfo.Name or ContextInfo.Text or "Toggle Here"
			Toggle.Interact.Text=TurnSysmbols[ContextInfo.Value]
			Toggle.Visible=true
			Toggle.LayoutOrder=Window.Order
			Toggle.Parent=container
			Window.Order+=1
			Cache.Activated=Toggle.Interact.Activated:Connect(function()
				ContextInfo:Set(not ContextInfo.Value)
			end)
			function ContextInfo:Replace(Value)
				if ContextInfo.Value~=Value then
					ContextInfo.Value=Value
					Toggle.Interact.Text=TurnSysmbols[Value]
				end
			end
			function ContextInfo:Set(Value)
				ContextInfo.Value=Value
				Toggle.Interact.Text=TurnSysmbols[Value]
				CallSafely(ContextInfo.Callback,Value)
			end
			Cache.BackgroundColor3Changed=frame:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Toggle.Title.TextColor3=SelectedTheme.TextColor
				Toggle.Interact.TextColor3=SelectedTheme.TextColor
			end)
		elseif Type=="Selector" then 
			ContextInfo.NoCap=Missing("boolean",ContextInfo.NoCap,false)
			ContextInfo.Index=table.find(ContextInfo.Options,ContextInfo.Value) or 1
			ContextInfo.Value=Missing("string",ContextInfo.Value,"None")
			if type(ContextInfo.Options)~="table" or #ContextInfo.Options<=0 then
				ContextInfo.Options={"Option 1","Option 2","Option 3"}
			end
			ContextInfo.Index=table.find(ContextInfo.Options,ContextInfo.Value) or 1
			local Selector=Canvas.Selector:Clone()
			Template=Selector
			local Information=Selector:FindFirstChild("Information")
			Information.Text=tostring(ContextInfo.Value)
			Selector.Visible=true
			Selector.LayoutOrder=Window.Order
			Selector.Parent=container
			Window.Order+=1
			function ContextInfo:Set(Value,Index)
				ContextInfo.Value=Value
				Information.Text=tostring(Value)
				if Index and type(Index)=="number" then ContextInfo.Index=Index end
				CallSafely(ContextInfo.Callback,Value,Index)
			end
			function ContextInfo:Add(Value)
				if not table.find(ContextInfo.Options,Value) then
					table.insert(ContextInfo.Options,Value)
				end
			end
			function ContextInfo:Remove(Value)
				local NewIndex=table.find(ContextInfo.Options,Value)
				if NewIndex~=nil then
					table.remove(ContextInfo.Options,NewIndex)
				end
			end
			local SelectorTweenInfo=TweenInfo.new(1,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out)
			local SelectorPropertys1,SelectorPropertys2={["Size"]=UDim2.new(0.8,0,0.8,0)},{["Size"]=UDim2.new(1,0,1,0)}
			local PreviousButton=Selector:FindFirstChild("Previous")
			Cache.PreviousActivated=PreviousButton.Activated:Connect(function()
				local NewIndex,NewOptions=ContextInfo.Index,ContextInfo.Options
				if ContextInfo.NoCap then
					if NewIndex<=0 then NewIndex=1 end
					NewIndex=NewIndex<=1 and #NewOptions or NewIndex-1
				else
					NewIndex=NewIndex<=0 and 1 or NewIndex-1
					if NewIndex<=0 then NewIndex=1 end
				end
				ContextInfo.Index=NewIndex
				ContextInfo:Set(tostring(NewOptions[NewIndex]),NewIndex)
			end)
			local PreviousTitle=PreviousButton:FindFirstChild("Title")
			Cache.PreviousMouseEnter=PreviousButton.MouseEnter:Connect(function()
				TweenService:Create(PreviousTitle,SelectorTweenInfo,SelectorPropertys1):Play()
			end)
			Cache.PreviousMouseLeave=PreviousButton.MouseLeave:Connect(function()
				TweenService:Create(PreviousTitle,SelectorTweenInfo,SelectorPropertys2):Play()
			end)
			
			local NextButton=Selector:FindFirstChild("Next")
			Cache.NextActivated=NextButton.Activated:Connect(function()
				local NewIndex,NewOptions=ContextInfo.Index,ContextInfo.Options
				if NewIndex>=#NewOptions then
					NewIndex=ContextInfo.NoCap and 1 or #NewOptions
				else
					NewIndex+=1
				end
				ContextInfo.Index=NewIndex
				ContextInfo:Set(tostring(NewOptions[NewIndex]),NewIndex)
			end)
			local NextTitle=NextButton:FindFirstChild("Title")
			Cache.NextMouseEnter=NextButton.MouseEnter:Connect(function()
				TweenService:Create(NextTitle,SelectorTweenInfo,SelectorPropertys1):Play()
			end)
			Cache.NextMouseLeave=NextButton.MouseLeave:Connect(function()
				TweenService:Create(NextTitle,SelectorTweenInfo,SelectorPropertys2):Play()
			end)
			Cache.BackgroundColor3Changed=frame:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Information.TextColor3=SelectedTheme.TextColor
				NextTitle.TextColor3=SelectedTheme.TextColor
				PreviousTitle.TextColor3=SelectedTheme.TextColor
			end)
		elseif Type=="Select" then
			ContextInfo.Value=ContextInfo.Value or nil
			ContextInfo.Active=Missing("boolean",ContextInfo.Active,false)
			local Select=Canvas.Select:Clone()
			Template=Select
			local InteractButton=Select:FindFirstChild("Interact")
			InteractButton.BackgroundColor3=not ContextInfo.Active and SelectedTheme.Select.DisableColor or SelectedTheme.Select.EnableColor
			local DisplayFrame=Select:FindFirstChild("DisplayFrame")
			Select.Visible=true
			Select.LayoutOrder=Window.Order
			Select.Parent=container
			Window.Order+=1
			function ContextInfo:Set(value)
				ContextInfo.Value=value
				if type(value)=="table" then
					DisplayFrame.BackgroundColor3=value.Color or Color3.fromRGB(200,200,200)
				elseif typeof(value)=="Instance" and value:IsA("BasePart") then
					DisplayFrame.BackgroundColor3=value.Color
				end
				CallSafely(ContextInfo.Callback,value)
			end
			Cache.Activated=InteractButton.Activated:Connect(function()
				if Cache.SelectMouseClick then Cache.SelectMouseClick:Disconnect() Cache.SelectMouseClick=nil end
				local NewActive=not ContextInfo.Active
				ContextInfo.Active=NewActive
				InteractButton.BackgroundColor3=NewActive and SelectedTheme.Select.EnableColor or SelectedTheme.Select.DisableColor
				if NewActive then
					Cache.SelectMouseClick=Mouse.Button1Down:Connect(function()
						if ContextInfo.Active then
							local Target=Mouse.Target
							if not (Target and Target.Parent) then return end
							ContextInfo:Set(Target)
						end
					end)
				end
			end)
			Cache.BackgroundColor3Changed=InteractButton:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				InteractButton.BackgroundColor3=ContextInfo.Active and SelectedTheme.Select.EnableColor or SelectedTheme.Select.DisableColor
			end)
			Cache.TextColor3Changed=InteractButton:GetPropertyChangedSignal("TextColor3"):Connect(function()
				InteractButton.TextColor3=Color3.fromRGB(255,255,255)
			end)
		elseif Type=="Expand" then
			ContextInfo.Active=Missing("boolean",ContextInfo.Active,false)
			ContextInfo.List={}
			local Expand=Canvas.Expand:Clone()
			Template=Expand
			Expand.Title.Text=ContextInfo.Name or ContextInfo.Text or "Expand Here"
			Expand.Subtitle.Text=ContextInfo.Active and "v" or "–"
			Expand.Visible=true
			Expand.LayoutOrder=Window.Order
			Expand.Parent=container
			Window.Order+=1
			function ContextInfo:Set(Active)
				ContextInfo.Active=Active
				for i,v in ipairs(ContextInfo.Children) do if type(v)=="table" and v.Parent and v.Template then v.Template.Visible=Active end end
				Window:ApplyWindowHeight()
				Expand.Subtitle.Text=Active and "v" or "–"
				CallSafely(ContextInfo.Callback,Active)
			end
			function ContextInfo:Add(Value)
				if Value and getmetatable(Value) and not table.find(ContextInfo.List,Value) and Value.Template then
					Value.Template.Visible=ContextInfo.Active
					ContextInfo.Parent=Value
					table.insert(ContextInfo.List,Value)
				end
			end
			Cache.Activated=Expand.Interact.Activated:Connect(function()
				ContextInfo:Set(not ContextInfo.Active)
			end)
			Cache.BackgroundColor3Changed=frame:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Expand.Title.TextColor3=SelectedTheme.TextColor
			end)
		else
			ContextInfo.Set=function(...) end
			return ContextInfo
		end
		local ProxyContext={}
		function ContextInfo:Destroy()
			if Template then Template.Visible=false Template=nil end
			local Key,Value=next(Cache)
			while Value do
				Cache[Key]=nil
				Value:Disconnect()
				Key,Value=next(Cache)
			end
			local LastParent=ContextInfo.Parent
			ContextInfo.Parent=nil
			if LastParent and type(LastParent)=="table" and type(LastParent.List)=="table" then
				local NewIndex=table.find(LastParent.List,ProxyContext)
				if NewIndex then
					table.remove(LastParent.List,NewIndex)
				end
				LastParent=nil
			end
			if type(ContextInfo.List)=="table" then
				local k,v=next(ContextInfo.List)
				while v do
					ContextInfo.List[k]=nil
					v:Destroy()
					k,v=next(ContextInfo.List)
				end
			end
			table.clear(ContextInfo)
			if getmetatable(ProxyContext) then setmetatable(ProxyContext,nil) end
		end
		local ContextClass={}
		ProxyContext=setmetatable(ContextClass,{
			__index=function(This,Key)
				if Key=="Template" then return Template end
				if Key=="Type" then return Type end
				local Value=ContextInfo[Key]
				if Value~=nil then return Value end
				local NewTemplate=Template
				if NewTemplate and NewTemplate.Parent then
					if Key=="Text" then
						local Title=NewTemplate:FindFirstChild("Title")
						if Title and Title:IsA("TextLabel") then return Title.Text end
					elseif Key=="Visible" then
						return NewTemplate.Visible
					end
				end
				return nil
			end,
			__newindex=function(This,Key,Value)
				local no=1
				if Template and Template.Parent then
					local OriginValue=ContextInfo[Key]
					if OriginValue and type(OriginValue)~="function" and Key~="Template" and Key~="Type" and Key~="Value" and Key~="Index" then
						ContextInfo[Key]=Value
					end
					if Key=="Text" then
						local Title=Template:FindFirstChild("Title")
						if Title and Title:IsA("TextLabel") then 
							Title.Text=Value
						end
					elseif Key=="Visible" then
						Template.Visible=Value
					elseif Key=="BackgroundColor3" then
						if Type=="Button" then
							Template.Interact.BackgroundColor3=Value
						end
					elseif Key=="Value" then
						ContextInfo:Set(Value)
					elseif Key=="Parent" then
						ContextToParent(This,Value,ContextInfo)
					else
						no=0
					end
					if no==0 then
						if Type=="Label" then
							pcall(function() Template.Title[Key]=Value end)
						end
					end
				end
			end,
		})
		table.insert(Contexts,ProxyContext)
		return ProxyContext
	end
	
	-- Destroy a window
	function Window:Destroy()
		if not getmetatable(ProxyWindow) then return end
		self.Parent=nil
		setmetatable(ProxyWindow,nil)
		if CleanGrab then CleanGrab() end
		for k,v in ipairs(Contexts) do v:Destroy() end
		frame.Name=frame.Name.."-Old"
		frame.Visible=false
		table.clear(self)
	end
	
	function Window:Notify(...)
		local data=Utility.PackNotif(...)
		data.BackgroundColor=SelectedTheme.Notification.Background or data.BackgroundColor
		data.TitleColor=SelectedTheme.Notification.TitleColor or data.TitleColor
		data.DescriptionColor=SelectedTheme.Notification.DescriptionColor or data.DescriptionColor
		UILibrary:Notify(data)
	end

	Window:Hide()
	Window:ApplyWindowHeight()
	frame.Open.Activated:Connect(function()
		Window:SetVisible(not Window:IsVisible())
	end)
	Window:ModifyTheme(SelectedTheme)
	frame.Visible=true
	local WindowClass={}
	ProxyWindow=setmetatable(WindowClass,{
		__index=function(This,Key)
			if Key=="SelectedTheme" then return SelectedTheme end
			local Value=Window[Key]
			if Value~=nil then return Value end
			return nil
		end,
		__newindex=function(This,Key,Value)
			if Key=="SelectedTheme" and type(Value)=="table" then SelectedTheme=Value end
		end,
	})
	getgenv().PazuiWindows[WindowName]=ProxyWindow
	return ProxyWindow
end

function UILibrary:GetWindow(Name)
	return getgenv().PazuiWindows[Name]
end

function UILibrary:Notify(...)
	local data=Utility.PackNotif(...)
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
	local tc,dc,spacing,height,width=#title,#description,10,60,260
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
	Utility.UpdateTextSize(tl)
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
	Utility.UpdateTextSize(dl)
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
	return Utility.GrabUI(frame)
end

function UILibrary:AddTheme(name,data)
	if type(name)~="string" then return nil end
	if type(data)~="table" then return nil end
	if UILibrary.Theme[name] then return nil end
	local config=UILibrary.Theme.Default
	local newData=Utility.DeepSet(config,data)
	UILibrary.Theme[name]=newData
	UILibrary:Notify({Title="Theme Added",Description=name,Duration=15})
	return newData
end

function UILibrary:IsSecret(Key)
	local secretKey=getgenv()[Key]
	return if secretKey~=nil and secretKey==true then true else false
end

return UILibrary
