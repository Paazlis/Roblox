local PLUGIN_NAME='Downloader'
local MAX_CAP=math.huge

local Missing=function(t,v,f) return type(v)==t and v or f end
setclipboard,cloneref=Missing('function',setclipboard,function(text) warn(text) end),Missing('function',cloneref,function(v) return v end)

local Services=setmetatable({},{__index=function(_,i)  return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})

local Workspace,Players,UserInputService,RunService,ReplicatedFirst,ReplicatedStorage,SoundService,Lighting,Teams,InsertService,StarterGui,StarterPack,HttpService=Services.Workspace,Services.Players,Services.UserInputService,Services.RunService,Services.ReplicatedFirst,Services.ReplicatedStorage,Services.SoundService,Services.Lighting,Services.Teams,Services.InsertService,Services.StarterGui,Services.StarterPack,Services.HttpService
local Window=nil

local Tabler=loadstring(game:HttpGet('https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Tabler/init.luau'))()
local Instancer=loadstring(game:HttpGet('https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Instancer/init.luau'))()
local Strs=loadstring(game:HttpGet('https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Strs/init.luau'))()
local UI=loadstring(game:HttpGet('https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau'))()

local LocalPlayer=Players.LocalPlayer :: Player
local PlayerGui=LocalPlayer.PlayerGui
local Mouse=LocalPlayer:GetMouse()
local SaveMouseIcon=Mouse.Icon

local IsEnums,IsEmpty,IsStrings,GetLines,ToPersentase,GetProperties,IsAlive,IsAs,AddInstance,CopyInstanceWith,GetInstanceProperty,CreateVariable,ConvertMeshPartToSpecialMesh,GetAncestorsAndSelf,SetChildrenParent,AddPose=nil,Strs.IsEmpty,Strs.IsStrings,Strs.GetLines,Strs.ToPersentase,Tabler.GetProperties,Instancer.IsAlive,Instancer.IsAs,Instancer.AddInstance,Instancer.CopyInstanceWith,Instancer.GetInstanceProperty,Instancer.CreateVariable,Instancer.ConvertMeshPartToSpecialMesh,Instancer.GetAncestorsAndSelf,Instancer.SetChildrenParent,nil
local MathHuge,MathFloor,MathMax,StringFormat,StringSplit,StringSub,StringFind,StringGmatch,TableInsert,TableRemove,TableConcat,TableFind,TableClear,Color3FromRGB,InstanceNew=math.huge,math.floor,math.max,string.format,string.split,string.sub,string.find,string.gmatch,table.insert,table.remove,table.concat,table.find,table.clear,Color3.fromRGB,Instance.new
local TopSelectButton,StatusLabel,LoaderLabel,ResetButton,DestroyButton,TextBox,SelectorGrabTypeButton,SelectorAnimationButton,SelectorFPSButton,AddButton,InitializeButton,InstalButton,RecordButton,StopButton

task.spawn(function()
	if LocalPlayer.AccountAge>=1000 then
		StarterGui:SetCore("SendNotification",{
			Title = ''..PLUGIN_NAME..' Warning ',
			Text = "This script is dangerous! Please make alt account only!",
			Duration = 10
		})
	end
end)

IsEnums=function(enum1,enum2)
	for i,v in ipairs(enum2) do if enum1==v then return true end end return false
end

AddPose=function(name,cframe,parent)
	local pose=Instance.new('Pose') pose.Name=name pose.CFrame=cframe pose.Parent=parent
end

local Outliner=Instance.new('SelectionBox') Outliner.Name='Selection' Outliner.Color3=Color3.fromRGB(25,153,255) Outliner.LineThickness=0.1 Outliner.SurfaceColor3=Color3.fromRGB(255,255,255) Outliner.SurfaceTransparency=1 Outliner.Transparency=0 Outliner.Adornee=nil Outliner.Visible=false

local GlobalData={
	['Locals']={
		['Instance']={
			['Prefix']='e',
			['Value']='Instance.new'
		},
		['Color3']={
			['Prefix']='frRGB',
			['Value']='Color3.fromRGB'
		},
		['Vector2']={
			['Prefix']='V2',
			['Value']='Vector2.new'
		},
		['Vector3']={ 
			['Prefix']='V3',
			['Value']='Vector3.new'
		},
		['Vector4']={ 
			['Prefix']='V4',
			['Value']='Vector4.new'
		},
		['CFrame']={
			['Prefix']='CF',
			['Value']='CFrame.new'
		},
		['UDim2']={
			['Prefix']='UD2',
			['Value']='UDim2.new'
		},
		['UDim']={
			['Prefix']='UD',
			['Value']='UDim.new'
		},
		['BrickColor']={
			['Prefix']='BC',
			['Value']='BrickColor.new'
		},
		['Rect2D']={
			['Prefix']='R2D',
			['Value']='Rect.new'
		},
		['Font']={
			['Prefix']={
				'Fnt',
				'FfrId',
				'FfrName'
			},
			['Value']={
				'Font.new',
				'Font.fromId',
				'Font.fromName',
			},
			['Length']=3
		},
		['NumberRange']={
			['Prefix']='NR',
			['Value']='NumberRange.new'
		},
		['FloatRange']={
			['Prefix']='FR',
			['Value']='FloatRange.new'
		},
		['PhysicalProperties']={
			['Prefix']='PhyProp',
			['Value']='PhysicalProperties.new'
		},
		['ColorSequence']={
			['Prefix']='CSeq',
			['Value']='ColorSequence.new'
		},
		['NumberSequence']={
			['Prefix']='NSeq',
			['Value']='NumberSequence.new'
		},
		['FloatSequence']={
			['Prefix']='FSeq',
			['Value']='FloatSequence.new'
		},
		['ColorSequenceKeypoint']={
			['Prefix']='CSeqKey',
			['Value']='ColorSequenceKeypoint.new'
		},
		['NumberSequenceKeypoint']={
			['Prefix']='NSeqKey',
			['Value']='NumberSequenceKeypoint.new'
		},
		['FloatSequenceKeypoint']={
			['Prefix']='FSeqKey',
			['Value']='FloatSequenceKeypoint.new'
		}
	},
	['Fonts']={
		Akronim=12187368317,
		AreYouSerious=12187363616,
		Audiowide=12187360881,
		Barlow=12187372847,
		Barrio=12187371991,
		Blaka=12187365104,
		BungeeInline=12187370000,
		BungeeShade=12187367666,
		CaesarDressing=12187368843,
		Cairo=12187377099,
		Caveat=12187369802,
		Codystar=12187363887,
		Damion=12187607722,
		DancingScript=8764312106,
		Eater=12187372382,
		FasterOne=12187370928,
		FingerPaint=12187375716,
		FiraSans=12187374954,
		Frijole=12187375194,
		FuzzyBubbles=11322590111,
		GreatVibes=12187375958,
		Hind=12187361116,
		HindSiliguri=12187361378,
		IBMPlexSansJP=12187364147,
		Inter=12187365364,
		IrishGrover=12187376910,
		Italianno=12187374273,
		Kanit=12187373592,
		Kings=12187371622,
		LaBelleAurore=12187607116,
		Lato=11598289817,
		LibreBaskerville=12187365769,
		Lobster=8836875837,
		Lora=12187366657,
		MPLUSRounded1c=12188570269,
		Marhey=12187364648,
		Monofett=12187606783,
		Monoton=12187374098,
		Montserrat=11702779517,
		Mukta=12187365559,
		Mulish=12187372629,
		NanumGothic=12187361718,
		Nosifer=12187377325,
		NothingYouCouldDo=12187367901,
		NotoSans=12187370747,
		NotoSansHK=12187362892,
		NotoSerifHK=12187366846,
		NotoSerifJP=12187369639,
		NotoSerifSC=12187376739,
		NotoSerifTC=12187368093,
		NunitoSans=12187363368,
		OpenSans=11598121416,
		PTSans=12187606934,
		PTSerif=12187606624,
		Pacifico=12187367362,
		Parisienne=12187361943,
		PlayfairDisplay=12187374765,
		Poppins=11702779409,
		Prompt=12187607287,
		Quicksand=12187371324,
		Rajdhani=12187375422,
		Raleway=11702779240,
		RobotoSlab=12187368625,
		Rubik=12187365977,
		RubikBurned=12187363148,
		RubikIso=12187362120,
		RubikMarkerHatch=12187367066,
		RubikMaze=12187366475,
		RubikWetPaint=12187369046,
		Rye=12187372175,
		SedgwickAveDisplay=12187376357,
		ShadowsIntoLight=12187607493,
		Silkscreen=12187371840,
		Sono=12187374537,
		SonoMonospace=12187362578,
		Tajawal=12187377588,
		Tangerine=12187376545,
		Teko=12187376174,
		UnicaOne=12187364842,
		WorkSans=12187373327,
		Yellowtail=12187373881
	},
	['Explorers']={
		['Event']={Workspace,ReplicatedStorage,ReplicatedFirst},
		['Sound']={Workspace,ReplicatedStorage,SoundService,LocalPlayer},
		['Lighting']={Lighting},
		['GuiColor']={PlayerGui,ReplicatedStorage},
		['Effect']={Workspace,ReplicatedStorage},
		['Name']={Workspace,ReplicatedStorage,Players,Teams,ReplicatedFirst,StarterPack},
		['Icon']={Workspace,ReplicatedStorage,PlayerGui,Teams,ReplicatedFirst}
	},
	['Others']={
		{'None','Building','Gui','Lighting','Sound','Tool','Icon','GuiIcon','MouseIcon','Animation','Team','Event','Texture','Decal','Beam','Trail','Name','GuiColor','PartColor'},
		{'None','Animation'},
		{'Motor','Bone'},
		{'12 FPS','24 FPS','30 FPS','60 FPS','120 FPS','240 FPS','Unlimited'},
		{'1','2','3','4','5','6','7','8','9','0'},
		{'RemoteEvent','RemoteFunction','BindableEvent','BindableFunction','UnreliableRemoteEvent'},
		{'Sky','BloomEffect','ColorCorrectionEffect','SunRaysEffect','Atmosphere','BlurEffect'},
		{'ScreenGui','Frame','ImageLabel','TextLabel','ImageButton','TextButton','ScrollingFrame','TextBox'},
		{'BackgroundColor3','ImageColor3','BorderColor3','Color','Color3','Value','BrickColor'},
		{'Name','Value','Message','Text','Print','DisplayName'},
		{'BackgroundColor3','ImageColor3','BorderColor3','Color','Color3','Value','BrickColor'},
		{'Texture','Icon','TextureId','Image','HoverImage'}
	},
	['Propertys']={}
}

GlobalData.Propertys.Constraint=[[
Attachment
	bool Archivable
	string Name
	Object Parent
	bool Visible
	Vector3 Position
	Vector3 Orientation
SpringConstraint
	bool Archivable
	string Name
	Object Parent
	number Coils
	BrickColor Color
	number Radius
	number Thickness
	bool Visible
	bool Enabled
	Object Attachment0
	Object Attachment1
	number Damping
	number FreeLength
	bool LimitsEnabled
	number MaxLength
	number MaxLength
	number MaxForce
	number Stiffness
Weld
	bool Archivable
	string Name
	Object Parent
	CFrame C0
	CFrame C1
	Object Part0
	Object Part1
	bool Enabled
WeldConstraint
	bool Archivable
	string Name
	Object Parent
	Object Part0
	Object Part1
	bool Enabled
]]

GlobalData.Propertys.Gui=[[
ScreenGui
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ LayerCollector ]
	bool Enabled
	ZIndexBehavior ZIndexBehavior
-	[ ScreenGui ]
	int DisplayOrder
	bool ResetOnSpawn
BillboardGui
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ LayerCollector ]
	bool Enabled
	ZIndexBehavior ZIndexBehavior
-	[ BillboardGui ]
	bool Active
	Object Adornee
	bool AlwaysOnTop
	Vector3 ExtentsOffset
	Vector3 ExtentsOffsetWorldSpace
	float LightInfluence
	float MaxDistance
	Object PlayerToHideFrom
	UDim2 Size
	Vector2 SizeOffset
	Vector3 StudsOffset
	Vector3 StudsOffsetWorldSpace
Frame
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ GuiObject ]
	bool Active
	Vector2 AnchorPoint
	Color3 BackgroundColor3
	float BackgroundTransparency
	Color3 BorderColor3
	int BorderSizePixel
	bool ClipsDescendants
	bool Draggable
	int LayoutOrder
	Object NextSelectionDown
	Object NextSelectionLeft
	Object NextSelectionRight
	Object NextSelectionUp
	UDim2 Position
	float Rotation
	bool Selectable
	Object SelectionImageObject
	UDim2 Size
	SizeConstraint SizeConstraint
	bool Visible
	int ZIndex
	bool ClipsDescendants
-	[ Frame ]
	FrameStyle Style
ImageButton
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ GuiObject ]
	bool Active
	Vector2 AnchorPoint
	Color3 BackgroundColor3
	float BackgroundTransparency
	Color3 BorderColor3
	int BorderSizePixel
	bool ClipsDescendants
	bool Draggable
	int LayoutOrder
	Object NextSelectionDown
	Object NextSelectionLeft
	Object NextSelectionRight
	Object NextSelectionUp
	UDim2 Position
	float Rotation
	bool Selectable
	Object SelectionImageObject
	UDim2 Size
	SizeConstraint SizeConstraint
	bool Visible
	int ZIndex
	bool ClipsDescendants
-	[ GuiButton ]
	bool AutoButtonColor
	bool Modal
	bool Selected
	ButtonStyle Style
-	[ ImageButton ]
	Content Image
	Color3 ImageColor3
	Vector2 ImageRectOffset
	Vector2 ImageRectSize
	float ImageTransparency
	ScaleType ScaleType
	Rect2D SliceCenter
	float SliceScale
	UDim2 TileSize
ImageLabel
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ GuiObject ]
	bool Active
	Vector2 AnchorPoint
	Color3 BackgroundColor3
	float BackgroundTransparency
	Color3 BorderColor3
	int BorderSizePixel
	bool ClipsDescendants
	bool Draggable
	int LayoutOrder
	Object NextSelectionDown
	Object NextSelectionLeft
	Object NextSelectionRight
	Object NextSelectionUp
	UDim2 Position
	float Rotation
	bool Selectable
	Object SelectionImageObject
	UDim2 Size
	SizeConstraint SizeConstraint
	bool Visible
	int ZIndex
	bool ClipsDescendants
-	[ ImageLabel ]
	Content Image
	Color3 ImageColor3
	Vector2 ImageRectOffset
	Vector2 ImageRectSize
	float ImageTransparency
	ScaleType ScaleType
	Rect2D SliceCenter
	float SliceScale
	UDim2 TileSize
ScrollingFrame
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ GuiObject ]
	bool Active
	Vector2 AnchorPoint
	Color3 BackgroundColor3
	float BackgroundTransparency
	Color3 BorderColor3
	int BorderSizePixel
	bool ClipsDescendants
	bool Draggable
	int LayoutOrder
	Object NextSelectionDown
	Object NextSelectionLeft
	Object NextSelectionRight
	Object NextSelectionUp
	UDim2 Position
	float Rotation
	bool Selectable
	Object SelectionImageObject
	UDim2 Size
	SizeConstraint SizeConstraint
	bool Visible
	int ZIndex
	bool ClipsDescendants
-	[ ScrollingFrame ]
	Content BottomImage
	Vector2 CanvasPosition
	UDim2 CanvasSize
	ScrollBarInset HorizontalScrollBarInset
	Content MidImage
	int ScrollBarThickness
	bool ScrollingEnabled
	Content TopImage
	ScrollBarInset VerticalScrollBarInset
	VerticalScrollBarPosition VerticalScrollBarPosition
SurfaceGui
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ LayerCollector ]
	bool Enabled
	ZIndexBehavior ZIndexBehavior
-	[ SurfaceGui ]
	bool Active
	Object Adornee
	bool AlwaysOnTop
	Vector2 CanvasSize
	NormalId Face
	float LightInfluence
	float ToolPunchThroughDistance
	float ZOffset
TextBox
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ GuiObject ]
	bool Active
	Vector2 AnchorPoint
	Color3 BackgroundColor3
	float BackgroundTransparency
	Color3 BorderColor3
	int BorderSizePixel
	bool ClipsDescendants
	bool Draggable
	int LayoutOrder
	Object NextSelectionDown
	Object NextSelectionLeft
	Object NextSelectionRight
	Object NextSelectionUp
	UDim2 Position
	float Rotation
	bool Selectable
	Object SelectionImageObject
	UDim2 Size
	SizeConstraint SizeConstraint
	bool Visible
	int ZIndex
	bool ClipsDescendants
-	[ TextBox ]
	bool ClearTextOnFocus
	Font FontFace
	float LineHeight
	bool MultiLine
	Color3 PlaceholderColor3
	string PlaceholderText
	bool ShowNativeInput
	string Text
	Color3 TextColor3
	bool TextScaled
	float TextSize
	Color3 TextStrokeColor3
	float TextStrokeTransparency
	float TextTransparency
	bool TextWrapped
	TextXAlignment TextXAlignment
	TextYAlignment TextYAlignment
TextButton
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ GuiObject ]
	bool Active
	Vector2 AnchorPoint
	Color3 BackgroundColor3
	float BackgroundTransparency
	Color3 BorderColor3
	int BorderSizePixel
	bool ClipsDescendants
	bool Draggable
	int LayoutOrder
	Object NextSelectionDown
	Object NextSelectionLeft
	Object NextSelectionRight
	Object NextSelectionUp
	UDim2 Position
	float Rotation
	bool Selectable
	Object SelectionImageObject
	UDim2 Size
	SizeConstraint SizeConstraint
	bool Visible
	int ZIndex
	bool ClipsDescendants
-	[ GuiButton ]
	bool AutoButtonColor
	bool Modal
	bool Selected
	ButtonStyle Style
-	[ TextButton ]
	Font FontFace
	float LineHeight
	string Text
	Color3 TextColor3
	bool TextScaled
	float TextSize
	Color3 TextStrokeColor3
	float TextStrokeTransparency
	float TextTransparency
	bool TextWrapped
	TextXAlignment TextXAlignment
	TextYAlignment TextYAlignment
TextLabel
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ GuiObject ]
	bool Active
	Vector2 AnchorPoint
	Color3 BackgroundColor3
	float BackgroundTransparency
	Color3 BorderColor3
	int BorderSizePixel
	bool ClipsDescendants
	bool Draggable
	int LayoutOrder
	Object NextSelectionDown
	Object NextSelectionLeft
	Object NextSelectionRight
	Object NextSelectionUp
	UDim2 Position
	float Rotation
	bool Selectable
	Object SelectionImageObject
	UDim2 Size
	SizeConstraint SizeConstraint
	bool Visible
	int ZIndex
	bool ClipsDescendants
-	[ TextLabel ]
	Font FontFace
	float LineHeight
	string Text
	Color3 TextColor3
	bool TextScaled
	float TextSize
	Color3 TextStrokeColor3
	float TextStrokeTransparency
	float TextTransparency
	bool TextWrapped
	TextXAlignment TextXAlignment
	TextYAlignment TextYAlignment
UIAspectRatioConstraint
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UIAspectRatioConstraint ]
	float AspectRatio
	AspectType AspectType
	DominantAxis DominantAxis
UIGridLayout
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UIGridStyleLayout ]
	FillDirection FillDirection
	HorizontalAlignment HorizontalAlignment
	SortOrder SortOrder
	VerticalAlignment VerticalAlignment
-	[ UIGridLayout ]
	UDim2 CellPadding
	UDim2 CellSize
	int FillDirectionMaxCells
	StartCorner StartCorner
UIListLayout
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UIGridStyleLayout ]
	FillDirection FillDirection
	HorizontalAlignment HorizontalAlignment
	SortOrder SortOrder
	VerticalAlignment VerticalAlignment
-	[ UIListLayout ]
	UDim Padding
UIPadding
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UIPadding ]
	UDim PaddingBottom
	UDim PaddingLeft
	UDim PaddingRight
	UDim PaddingTop
UIPageLayout
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UIGridStyleLayout ]
	FillDirection FillDirection
	HorizontalAlignment HorizontalAlignment
	SortOrder SortOrder
	VerticalAlignment VerticalAlignment
-	[ UIPageLayout ]
	bool Animated
	bool Circular
	EasingDirection EasingDirection
	EasingStyle EasingStyle
	bool GamepadInputEnabled
	UDim Padding
	bool ScrollWheelInputEnabled
	bool TouchInputEnabled
	float TweenTime
UIScale
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UIScale ]
	float Scale
UISizeConstraint
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UISizeConstraint ]
	Vector2 MaxSize
	Vector2 MinSize
UITableLayout
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UIGridStyleLayout ]
	FillDirection FillDirection
	HorizontalAlignment HorizontalAlignment
	SortOrder SortOrder
	VerticalAlignment VerticalAlignment
-	[ UITableLayout ]
	bool FillEmptySpaceColumns
	bool FillEmptySpaceRows
	TableMajorAxis MajorAxis
	UDim2 Padding
UITextSizeConstraint
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UITextSizeConstraint ]
	int MaxTextSize
	int MinTextSize
ViewportFrame
	Color3 Ambient
	Color3 LightColor
	Vector3 LightDirection
	Object SelectionImageObject
	float BackgroundTransparency
	Vector2 AnchorPoint
	Color3 BackgroundColor3
	int BorderSizePixel
	Color3 BorderColor3
	Object CurrentCamera
	int LayoutOrder
	string Name
	Object Parent
	UDim2 Position
	int Rotation
	bool Visible
	int ZIndex
	bool ClipsDescendants
	Color3 ImageColor3
	float ImageTransparency
UIGradient
	ColorSequence Color
	Vector2 Offset
	int Rotation
	NumberSequence Transparency
	string Name
	Object Parent
	bool Archivable
UICorner
	UDim CornerRadius
	string Name
	Object Parent
	bool Archivable
UIStroke
	ApplyStrokeMode ApplyStrokeMode
	Color3 Color
	LineJoinMode LineJoinMode
	number Thickness
	number Transparency
	bool Enabled
	string Name
	Object Parent
	bool Archivable
]]

GlobalData.Propertys.Building=[[
SpecialMesh
	bool Archivable
	string Name
	Object Parent
	string MeshId
	MeshType MeshType
	string TextureId
	Vector3 Scale
	Vector3 Offset
	Color3 VertexColor
WedgePart
	bool Archivable
	string Name
	Object Parent
	BrickColor BrickColor
	Color3 Color
	Material Material
	number Reflectance
	number Transparency
	Vector3 Size
	Vector3 Position
	Vector3 Rotation
	bool CanCollide
	bool Anchored
	PhysicalProperties CustomPhysicalProperties
CornerWedgePart
	bool Archivable
	string Name
	Object Parent
	BrickColor BrickColor
	Color3 Color
	Material Material
	number Reflectance
	number Transparency
	Vector3 Size
	Vector3 Position
	Vector3 Rotation
	bool CanCollide
	bool Anchored
	PhysicalProperties CustomPhysicalProperties
TrussPart
	bool Archivable
	string Name
	Object Parent
	BrickColor BrickColor
	Color3 Color
	Material Material
	number Reflectance
	number Transparency
	Vector3 Size
	Vector3 Position
	Vector3 Rotation
	bool CanCollide
	bool Anchored
	PhysicalProperties CustomPhysicalProperties
	Style Style
Part
	bool Archivable
	string Name
	Object Parent
	Color3 Color
	Material Material
	number Reflectance
	number Transparency
	Vector3 Size
	Vector3 Position
	Vector3 Rotation
	bool CanCollide
	bool Anchored
	PhysicalProperties CustomPhysicalProperties
	PartType Shape
MeshPart
	bool Archivable
	string Name
	Object Parent
]]

GlobalData.Propertys.Animation=[[
Motor6D
	bool Archivable
	string Name
	Object Parent
	Object Part0
	Object Part1
	CFrame Transform
Bone
	bool Archivable
	string Name
	Object Parent
	CFrame Transform
	CFrame CFrame
KeyframeSequence
	bool Archivable
	string Name
	Object Parent
Keyframe
	bool Archivable
	string Name
	Object Parent
	float Time
Pose
	bool Archivable
	string Name
	Object Parent
	CFrame CFrame
	EnumItem EasingStyle
	EnumItem EasingDirection
]]

GlobalData.Propertys.Value=[[
BoolValue
	bool Archivable
	string Name
	Object Parent
	bool Value
StringValue
	bool Archivable
	string Name
	Object Parent
	string Value
NumberValue
	bool Archivable
	string Name
	Object Parent
	number Value
FloatValue
	bool Archivable
	string Name
	Object Parent
	float Value
IntValue
	bool Archivable
	string Name
	Object Parent
	int Value
ObjectValue
	bool Archivable
	string Name
	Object Parent
	Object Value
Vector2Value
	bool Archivable
	string Name
	Object Parent
	Vector2 Value
Vector3Value
	bool Archivable
	string Name
	Object Parent
	Vector3 Value
Vector4Value
	bool Archivable
	string Name
	Object Parent
	Vector4 Value
CFrameValue
	bool Archivable
	string Name
	Object Parent
	CFrame Value
Color3Value
	bool Archivable
	string Name
	Object Parent
	Color3 Value
BrickColorValue
	bool Archivable
	string Name
	Object Parent
	BrickColor Value
]]

GlobalData.Propertys.Signal=[[
BindableEvent
	bool Archivable
	string Name
	Object Parent
BindableFunction
	bool Archivable
	string Name
	Object Parent
RemoteEvent
	bool Archivable
	string Name
	Object Parent
UnreliableRemoteEvent
	bool Archivable
	string Name
	Object Parent
RemoteFunction
	bool Archivable
	string Name
	Object Parent
]]

local REFERENCE_PROPERTY=[[
Configuration
	bool Archivable
	string Name
	Object Parent
Folder
	bool Archivable
	string Name
	Object Parent
Model
	bool Archivable
	string Name
	Object Parent
	Object PrimaryPart
Tool
	bool Archivable
	string Name
	Object Parent
	string ToolTip
	string TextureId
	Object PrimaryPart
	bool CanBeDropped
	bool ManualActivationOnly
	bool RequiresHandle
	bool Enabled
Beam
	bool Archivable
	string Name
	Object Parent
	ColorSequence Color
	bool Enabled
	number LightEmission
	number LightInfluence
	string Texture
	number TextureLength
	TextureMode TextureMode
	number TextureSpeed
	NumberSequence Transparency
	number ZOffset
	number CurveSize0
	number CurveSize1
	bool FaceCamera
	number Segments
	number Width0
	number Width1
Trail
	bool Archivable
	string Name
	Object Parent
	ColorSequence Color
	bool FaceCamera
	number LightEmission
	number LightInfluence
	string Texture
	number TextureLength
	TextureMode TextureMode
	NumberSequence Transparency
	bool Enabled
	number Lifetime
	number MaxLength
	number MinLength
	number WidthScale
ParticleEmitter
	bool Archivable
	string Name
	Object Parent
	ColorSequence Color
	number LightEmission
	number LightInfluence
	EnumItem Orientation
	NumberSequence Size
	NumberSequence Squash
	string Texture
	NumberSequence Transparency
	number ZOffset
	Vector3 Acceleration
	EnumItem EmissionDirection
	bool Enabled
	NumberRange Lifetime
	NumberRange Rotation
	NumberRange RotSpeed
	NumberRange Speed
	number Rate
	Vector2 SpreadAngle
	number Rate
	EnumItem Shape
	number ShapePartial
	EnumItem ShapeInOut
	EnumItem ShapeStyle
	EnumItem FlipbookLayout
	bool FlipbookBlendFrames
	number FlipbookFramerate
	EnumItem FlipbookMode
	number FlipbookSizeX
	number FlipbookSizeY
	EnumItem FlipbookLayout
	bool FlipbookStartRandom
	Vector3 Acceleration
	number TimeScale
	number VelocityInheritance
	number WindAffectsDrag
Team
	bool Archivable
	string Name
	Object Parent
	BrickColor TeamColor
Texture
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ Texture ]
	Color3 Color3
	number OffsetStudsU
	number OffsetStudsV
	number StudsPerTileU
	number StudsPerTileV
	string Texture
	number Transparency
	number ZIndex
	NormalId Face
Decal
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ Decal ]
	NormalId Face
	Color3 Color3
	string Texture
AudioPlayer
	bool Archivable
	string Name
	Object Parent
	string Asset
	bool AutoLoad
	bool AutoPlay
	bool Looping
	number Volume
Sound
	bool Archivable
	string Name
	Object Parent
	string SoundId
	bool Looped
	bool Playing
	number Volume
	number RollOffMaxDistance
	number RollOffMinDistance
	RollOffMode RollOffMode
	bool PlaybackRegionsEnabled
	number PlaybackSpeed
	number TimePosition
Sky
	bool Archivable
	string Name
	Object Parent
	bool CelestialBodiesShown
	number MoonAngularSize
	string MoonTextureId
	string SkyboxBk
	string SkyboxDn
	string SkyboxFt
	string SkyboxLf
	string SkyboxRt
	string SkyboxUp
	number StarCount
	number SunAngularSize
	string SunTextureId
ColorCorrectionEffect
	bool Archivable
	string Name
	Object Parent
	bool Enabled
	number Brightness
	number Contrast
	number Saturation
	Color3 TintColor
BlurEffect
	bool Archivable
	string Name
	Object Parent
	bool Enabled
	number Size
SunRaysEffect
	bool Archivable
	string Name
	Object Parent
	bool Enabled
	number Intensity
	number Spread
DepthOfFieldEffect
	bool Archivable
	string Name
	Object Parent
	bool Enabled
	number FarIntensity
	number FocusDistance
	number InFocusRadius
	number NearIntensity
BloomEffect
	bool Archivable
	string Name
	Object Parent
	bool Enabled
	number Intensity
	number Size
	number Threshold
Atmosphere
	bool Archivable
	string Name
	Object Parent
	number Density
	number Offset
	Color3 Color
	Color3 Decay
	number Glare
]] .. GlobalData.Propertys.Building .. GlobalData.Propertys.Gui .. GlobalData.Propertys.Constraint .. GlobalData.Propertys.Animation .. GlobalData.Propertys.Value .. GlobalData.Propertys.Signal

local LocalData,FontData,ExplorerData,FPSRateData=GlobalData.Locals,GlobalData.Fonts,GlobalData.Explorers,{
	['12 FPS']=1/12,
	['24 FPS']=1/24,
	['30 FPS']=1/30,
	['60 FPS']=1/60,
	['120 FPS']=1/120,
	['240 FPS']=1/240,
}

local SafeData={}
do
	SafeData['bool']=function(value) return tostring(value) end
	SafeData['boolean']=SafeData['bool']
	SafeData['float']=function(value) return Strs.ToNumber(value,2) end
	SafeData['int']=function(value) return tostring(MathFloor(value)) end
	SafeData['number']=function(value) return Strs.ToNumber(value,3) end
	SafeData['string']=function(value) return "\'"..value:gsub("[\"\\]","\\%1"):gsub("\n","\\\\n").."\'" end
	
	SafeData['EnumItem']=SafeData['bool']
	SafeData['TextureMode']=SafeData['bool']
	SafeData['LineJoinMode']=SafeData['bool']
	SafeData['ApplyStrokeMode']=SafeData['bool']
	SafeData['Style']=SafeData['bool']
	SafeData['MeshType']=SafeData['bool']
	SafeData['Material']=SafeData['bool']
	SafeData['PartType']=SafeData['bool']
	SafeData['RollOffMode']=SafeData['bool']
	SafeData['AspectType']=SafeData['bool']
	SafeData['ButtonStyle']=SafeData['bool']
	SafeData['Content']=SafeData['bool']
	SafeData['DominantAxis']=SafeData['bool']
	SafeData['EasingDirection']=SafeData['bool']
	SafeData['EasingStyle']=SafeData['bool']
	SafeData['FillDirection']=SafeData['bool']
	SafeData['Font']=function(value) return string.format("Fnt('%s',%s,%s)",value.Family,tostring(value.Weight),tostring(value.Style)) end
	SafeData['FrameStyle']=SafeData['bool']
	SafeData['HorizontalAlignment']=SafeData['bool']
	SafeData['NormalId']=SafeData['bool']
	SafeData['ScaleType']=SafeData['bool']
	SafeData['ScrollBarInset']=SafeData['bool']
	SafeData['SizeConstraint']=SafeData['bool']
	SafeData['SortOrder']=SafeData['bool']
	SafeData['StartCorner']=SafeData['bool']
	SafeData['TableMajorAxis']=SafeData['bool']
	SafeData['TextXAlignment']=SafeData['bool']
	SafeData['TextYAlignment']=SafeData['bool']
	SafeData['VerticalAlignment']=SafeData['bool']
	SafeData['VerticalScrollBarPosition']=SafeData['bool']
	SafeData['ZIndexBehavior']=SafeData['bool']
	SafeData['InlineAlignment']=SafeData['bool']

	SafeData['Object']=function(value)
		local hierarchy=''
		local previousObjectUsedBrackets=true

		for object in GetAncestorsAndSelf(value) do
			local safeName=''
			local shouldUseBrackets=false
			local currentHierarchy=''

			if #object.Name==0 then
				shouldUseBrackets=true
			else
				if object.Name:match("[%a_ ]+")~=object.Name then
					shouldUseBrackets=true
				end
			end

			if shouldUseBrackets then
				safeName=object.Name:gsub("[\"\\]","\\%1"):gsub("\n","\\\\n")
			end

			if object==game and previousObjectUsedBrackets then
				hierarchy='game'..hierarchy
				break
			elseif object==game and not previousObjectUsedBrackets then
				if hierarchy=='StarterGui' then
					currentHierarchy='game.StarterGui'
				elseif hierarchy=='PlayerGui' then
					currentHierarchy='game.StarterGui'
				elseif hierarchy=='workspace' then
					currentHierarchy='workspace'
				else
					currentHierarchy=hierarchy
				end
				hierarchy=currentHierarchy
				break
			elseif shouldUseBrackets and previousObjectUsedBrackets then
				previousObjectUsedBrackets=true
				hierarchy="[\""..safeName.."\"]"..hierarchy
			elseif shouldUseBrackets and not previousObjectUsedBrackets then
				previousObjectUsedBrackets=true
				hierarchy="[\""..safeName.."\"]".."."..hierarchy
			elseif (not shouldUseBrackets) and previousObjectUsedBrackets then
				previousObjectUsedBrackets=false
				hierarchy=object.Name..hierarchy
			elseif (not shouldUseBrackets) and (not previousObjectUsedBrackets) then
				previousObjectUsedBrackets=false
				if object==StarterGui or hierarchy=='StarterGui' then
					currentHierarchy='game.StarterGui'
				elseif object==PlayerGui or hierarchy=='PlayerGui' then
					currentHierarchy='game.StarterGui'
				elseif object==workspace or hierarchy=='workspace' then
					currentHierarchy='workspace'
				else
					currentHierarchy=object.Name..'.'..hierarchy
				end
				hierarchy=currentHierarchy
			end
		end

		return hierarchy
	end
	
	SafeData['PhysicalProperties']=function(value)
		return ('PhyProp(%s,%s,%s,%s,%s)'):format(Strs.ToNumber(value.Density,3),Strs.ToNumber(value.Friction,3),Strs.ToNumber(value.Elasticity,3),Strs.ToNumber(value.FrictionWeight,3),Strs.ToNumber(value.ElasticityWeight,3))
	end
	SafeData['Rect2D']=function(value)
		return 'R2D('..tostring(value):gsub('\n',''):gsub(' ','')..')'
	end
	SafeData['BrickColor']=function(value)
		return ('BC(%i,%i,%i)'):format(value.r*255,value.g*255,value.b*255);
	end
	SafeData['Color3']=function(value)
		return ('frRGB(%i,%i,%i)'):format(value.R*255,value.G*255,value.B*255);
	end
	SafeData['UDim']=function(value)
		local t={}
		for i,v in ipairs({value.Scale,value.Offset})  do
			t[i]=Strs.ToNumber(v,3)
		end
		local s=table.concat(t,',')
		return 'UD('..s..')'
	end
	SafeData['UDim2']=function(value)
		local t={}
		for i,v in ipairs({value.X.Scale,value.X.Offset,value.Y.Scale,value.Y.Offset}) do
			t[i]=Strs.ToNumber(v,3)
		end
		local s=table.concat(t,',')
		return 'UD2('..s..')'
	end
	SafeData['Vector2']=function(value)
		local t={}
		for i,v in ipairs({value.X,value.Y})  do
			t[i]=Strs.ToNumber(v,3)
		end
		local s=table.concat(t,',')
		return 'V2('..s..')'
	end
	SafeData['Vector3']=function(value)
		local t={}
		for i,v in ipairs({value.X,value.Y,value.Z})  do
			t[i]=Strs.ToNumber(v,3)
		end
		local s=table.concat(t,',')
		return 'V3('..s..')'
	end
	SafeData['Vector4']=function(value)
		local list={value.X,value.Y,value.Z,value.W or value.A}
		local results={}
		for i,v in ipairs(list)  do
			results[i]=Strs.ToNumber(v,3)
		end
		local s=table.concat(results,',')
		return 'V4('..s..')'
	end
	SafeData['CFrame']=function(value)
		local list=string.split(tostring(value):gsub('\n',''):gsub(' ',''),',')
		local results={}
		for i,v in ipairs(list)  do
			results[i]=Strs.ToNumber(v,3)
		end
		local s=table.concat(results,',')
		return 'CF('..s..')'
	end

	SafeData['NumberRange']=function(value)
		return ('NR(%s,%s)'):format(Strs.ToNumber(value.Min),Strs.ToNumber(value.Max))
	end
	SafeData['FloatRange']=function(value)
		return ('FR(%s,%s)'):format(Strs.ToNumber(value.Min),Strs.ToNumber(value.Max))
	end

	SafeData['ColorSequenceKeypoint']=function(value)
		return ('CSeqKey(%s,%s)'):format(Strs.ToNumber(value.Time),SafeData['Color3'](value.Value));
	end
	SafeData['NumberSequenceKeypoint']=function(value)
		return ('NSeqKey(%s,%s)'):format(Strs.ToNumber(value.Time),Strs.ToNumber(value.Value))
	end
	SafeData['FloatSequenceKeypoint']=function(value)
		return ('FSeqKey(%s,%s)'):format(Strs.ToNumber(value.Time),Strs.ToNumber(value.Value))
	end

	SafeData['ColorSequence']=function(value)
		local t={}
		for i,v in ipairs(value.Keypoints) do t[i]=SafeData['ColorSequenceKeypoint'](v)..(i<=#value.Keypoints-1 and ',' or '') end
		local s=''
		for i,v in ipairs(t) do s=s..v end
		return ('CSeq({%s})'):format(s)
	end
	SafeData['NumberSequence']=function(value)
		local t={}
		for i,v in ipairs(value.Keypoints) do t[i]=SafeData['NumberSequenceKeypoint'](v)..(i<=#value.Keypoints-1 and ',' or '') end
		local s=''
		for i,v in ipairs(t) do s=s..v end
		return ('NSeq({%s})'):format(s)
	end
	SafeData['FloatSequence']=function(value)
		local t={}
		for i,v in ipairs(value.Keypoints) do  t[i]=SafeData['FloatSequenceKeypoint'](v)..(i<=#value.Keypoints-1 and ',' or '') end
		local s=''
		for i,v in ipairs(t) do s=s..v end
		return ('FSeq({%s})'):format(s)
	end
end

local RegisteredClasses,ObjectClasses={},{}
local GrabTypeList,BannedGrabTypeList,RecordAnimTypeList,FPSTypeList,NumericList,EventClasses,LightingClasses,UIClasses,ColorProperties,TextProperties,UIColorProperties,IconProperties=unpack(GlobalData.Others)
local GrabTypeCache,BuildingCache,GuiCache,ToolCache,MouseIconCache,InstalCache,Cache={},{},{},{},{},{},{}

local GrabType,RecordAnimType,FPSType,LastStatus=GrabTypeList[1],'','',''
local RecordAnimConnection,PlayerGuiAdded,BuildingTarget,GuiTarget,ToolTarget,InstalTarget,GrabberModel=nil,nil,nil,nil,nil,nil,nil
local Destroyed,Debounce,IsInput,IsRecordAnim=false,false,false,false
local BuildingIndex,TotalBuilding=0,0

local function CreateClasses(properties)
	local className,templateObject,classList,registeredList=nil,nil,{},{}
	for line in GetLines(properties) do
		if StringSub(line,1,1)~='-' then
			if StringSub(line,1,1)=='	' then
				if templateObject then
					local space=StringFind(line,' ')
					if not tonumber(space) then return end
					local dataType=StringSub(line,2,space-1)
					local propertyName=StringSub(line,space+1,#line)
					local propertyValue,propertyType=nil,nil
					local success,err=pcall(function() propertyValue=templateObject[propertyName] end) 
					if not success then
						warn('['..PLUGIN_NAME..'] Unknown property '..className..'.'..propertyName..' will be ignored.')
						continue
					end
					propertyType=typeof(propertyValue)
					if propertyType=='EnumItem' then
						dataType=propertyType
					end

					if SafeData[dataType]==nil then
						warn('['..PLUGIN_NAME..'] Unhandled data type '..dataType..' '..className..'.'..propertyName..' will be ignored.')
						continue
					end
					classList[className][propertyName]={
						DataType=dataType,
						DefaultValue=propertyValue
					}
					TableInsert(classList[className],propertyName)
				end
			else
				if templateObject then templateObject:Destroy() templateObject=nil end
				className=line
				if not pcall(function() InstanceNew(className):Destroy() end) then
					warn('['..PLUGIN_NAME..'] Unknown class '..line..'  will be ignored.')
					continue
				end
				if classList[className] then
					warn('['..PLUGIN_NAME..'] '..className..'class is already registered.')
					continue
				end
				TableInsert(registeredList,className)
				templateObject=InstanceNew(className)
				classList[className]={}
			end
		end
	end
	if templateObject then templateObject:Destroy() templateObject=nil end
	className=nil
	return classList,registeredList
end

ObjectClasses,RegisteredClasses=CreateClasses(REFERENCE_PROPERTY)

REFERENCE_PROPERTY=nil
GUI_PROPERTY=nil

local Module={Parent=false}

function Module:SetStatus(mode,...)
	if mode==1 or mode==0 then
		local message,cooldown=...
		if not message or type(message)~='string' then return end
		LastStatus=message
		StatusLabel.Text=message
		if mode==0 then return end
		if cooldown then task.wait(tonumber(cooldown) or 2) end
		if StatusLabel.Text==LastStatus then
			StatusLabel.Text='Status'
		end
	elseif mode==2 then
		local v,max=...
		if v==-1 then
			LoaderLabel.Text=tostring(max)..'/'..tostring(max)..' 100%'
		elseif v==-2 then
			LoaderLabel.Text='(0/0) 0%'
		else
			local persentase=ToPersentase(v,max,2,true)
			LoaderLabel.Text=tostring(v)..'/'..tostring(max)..' '..persentase
		end
	end
end

function Module:SetUpdate(mode,...)
	if mode==1 then
		TableClear(GrabTypeCache)
		TableClear(BuildingCache)
		TableClear(GuiCache)
		TableClear(ToolCache)
		TableClear(MouseIconCache)
		TableClear(InstalCache)
		GrabType=GrabTypeList[1]
		BuildingTarget=nil
		InstalTarget=nil
		GuiTarget=nil
		ToolTarget=nil
		if RecordAnimConnection then RecordAnimConnection:Disconnect() RecordAnimConnection=nil end
		RecordAnimType=RecordAnimTypeList[1]
		IsRecordAnim=false
		if PlayerGuiAdded then PlayerGuiAdded:Disconnect() PlayerGuiAdded=nil end
		if SelectorGrabTypeButton and SelectorGrabTypeButton.Parent then
			SelectorGrabTypeButton.Value=GrabTypeList[1]
		end
		if GrabberModel then GrabberModel:Destroy() GrabberModel=nil end
		if Window.Parent then
			StatusLabel.Text='Status'
			LoaderLabel.Text='(0/0) 0%'
		end
		self:SetUpdate(2)
		self:SetUpdate(3)
	elseif mode==2 then
		local target=...
		if Outliner.Parent then
			local isTarget=target~=nil
			Outliner.Adornee=target
			Outliner.Visible=isTarget 
		end
	elseif mode==3 then
		for i,v in ipairs({DestroyButton,ResetButton}) do v.Visible=GrabType=='None' end
		local isAnimation,isBuilding=GrabType=='Animation',GrabType=='Building' or GrabType=='Animation'
		TopSelectButton.Visible=isBuilding
		self:SetUpdate(isBuilding and 2 or 0)
		if PlayerGuiAdded then PlayerGuiAdded:Disconnect() PlayerGuiAdded=nil end
		TextBox.Visible=isBuilding
		TextBox.PlaceholderText=isBuilding and 'Building Index' or ''
		AddButton.Visible=GrabType~='None'
		if isBuilding then
			MainLabel.Text='Total Building: '..tostring(BuildingIndex)
		elseif GrabType=='Gui' then
			local originText,lastText="Use dex/explorer and Add StringValue and named 'Instal' to any ScreenGui in PlayerGui",''
			MainLabel.Text=originText
			PlayerGuiAdded=PlayerGui.DescendantAdded:Connect(function(child)
				if child:IsA('StringValue') and child.Name=='Instal' then
					local isGui,gui=false,child.Parent
					if gui then isGui=gui:IsA('ScreenGui') if isGui then GuiTarget=gui child:Destroy() end end
					lastText=isGui and 'Successfully' or 'An Error Occured'
					MainLabel.Text=lastText
					task.wait(2)
					if MainLabel.Text==lastText then
						MainLabel.Text=originText
					end
				end
			end)
		else
			MainLabel.Text=''
		end
		MainLabel.TextScaled=GrabType=='Gui'
		MainLabel.Visible=isBuilding or GrabType=='Gui'
		if StopButton and getmetatable(StopButton) then StopButton.Visible=GrabType=='Building' end
		for i,v in ipairs({RecordButton,SelectorAnimationButton,SelectorFPSButton}) do 
			v.Visible=isAnimation
		end
	end
end

function Module:GetGrabData(mode)
	mode=tostring(mode)
	StatusLabel.Text=mode
	task.wait(2)

	local newModel=InstanceNew('Model') 
	newModel.Name=mode

	local s,sLen,maxSLen,maxSound,canSRemoved='',0,100,200,true
	local needle=nil
	local actives,needles,explorers={},{},ExplorerData[mode] or {}

	if mode=='Texture' or mode=='Effect' or mode=='Decal' or mode=='Trail' or mode=='Beam' then
		explorers=ExplorerData['Effect']
	elseif mode=='Team' then
		explorers={Teams}
	end

	local function OnImageIdCallback(propertyType,propertyValue)
		if propertyType~='string' then return end 
		local k=propertyValue
		if actives[k] then return end
		actives[k]=true 
		StatusLabel.Text=mode..': '..tostring(k)
		s=s..k..',' 
		if sLen>=maxSLen then s=s..'\n' end 
		sLen=(sLen+1)%maxSLen 
		RunService.Stepped:Wait() 
	end

	local function IsCopyInstance(v)
		local name,className,k=v.Name,v.ClassName,nil
		if className=='Team' and mode=='Team' then 
			k=name..'_'..tostring(v.TeamColor)
		elseif className=='Decal' and mode=='Decal' then
			k=v.Texture 
		elseif className=='Trail' and mode=='Trail' then
			k=v.Texture 
		elseif className=='Beam' and mode=='Beam' then
			k=v.Texture 
		elseif className=='Texture' and mode=='Texture' then
			k=v.Texture
		elseif IsAs(v,EventClasses) and mode=='Event' then
			k=name..'_'..className
		end 
		if k~=nil and not actives[k] then
			actives[k]=true 
			StatusLabel.Text=mode..': '..name
			return true
		end
		return false
	end

	if mode=='Sound' then
		local soundIds={}
		CopyInstanceWith(explorers,ObjectClasses,newModel,function(v) 
			local name,className,key=v.Name,v.ClassName,nil 
			if className=='Sound' then key=v.SoundId elseif className=='AudioPlayer' then key=v.Asset end 
			if key~=nil and not actives[key] then 
				actives[key]=true StatusLabel.Text=mode..': '..className..' '..name
				TableInsert(soundIds,{name,needle}) 
				return true 
			end
			return false 
		end)
		if #soundIds>=maxSound then 
			StatusLabel.Text=tostring(#soundIds)..' Sound Sound is Dangerous!'
			task.wait(2)
			StatusLabel.Text=''
			newModel:ClearAllChildren()
			s='\n local SoundIds={'
			for i,v in ipairs(soundIds) do
				RunService.Stepped:Wait() 
				StatusLabel.Text=mode..': '..v[2]
				if i==#soundIds then 
					s=s.."{'"..v[1].."'"..",".."'"..v[2].."'}"
				else 
					s=s.."{'"..v[1].."'"..",".."'"..v[2].."'},"
				end 
				sLen=(sLen+1)%maxSLen 
				if sLen==0 then s=s.."\n" end  
			end
			s=s.."}\n"
			s=s.. [[for i,v in ipairs(SoundIds) do local nv=e('Sound') nv.Name=v[1] nv.SoundId=v[2] nv.Parent=%s end]] .."\n"
			canSRemoved=false
		end
		TableClear(soundIds)
	elseif mode=='Lighting' then
		local newLighting=InstanceNew("Model")
		newLighting.Name='Lighting'
		newLighting.Parent=newModel

		local newAmbient=InstanceNew("Color3Value")
		newAmbient.Name='Ambient'
		newAmbient.Value=Lighting.Ambient
		newAmbient.Parent=newLighting

		local newBrightness=InstanceNew('NumberValue')
		newBrightness.Name='Brightness'
		newBrightness.Value=Lighting.Brightness
		newBrightness.Parent=newLighting

		local newColorShift_Bottom=InstanceNew('Color3Value')
		newColorShift_Bottom.Name='ColorShift_Bottom'
		newColorShift_Bottom.Value=Lighting.ColorShift_Bottom
		newColorShift_Bottom.Parent=newLighting

		local newColorShift_Top=InstanceNew('Color3Value')
		newColorShift_Top.Name='ColorShift_Top'
		newColorShift_Top.Value=Lighting.ColorShift_Top
		newColorShift_Top.Parent=newLighting

		local newEnvironmentDiffuseScale=InstanceNew('NumberValue')
		newEnvironmentDiffuseScale.Name='EnvironmentDiffuseScale'
		newEnvironmentDiffuseScale.Value=Lighting.EnvironmentDiffuseScale
		newEnvironmentDiffuseScale.Parent=newLighting

		local newEnvironmentSpecularScale=InstanceNew('NumberValue')
		newEnvironmentSpecularScale.Name='EnvironmentSpecularScale'
		newEnvironmentSpecularScale.Value=Lighting.EnvironmentSpecularScale
		newEnvironmentSpecularScale.Parent=newLighting

		local newGlobalShadows=InstanceNew('BoolValue')
		newGlobalShadows.Name='GlobalShadows'
		newGlobalShadows.Value=Lighting.GlobalShadows
		newGlobalShadows.Parent=newLighting

		local newOutdoorAmbient=InstanceNew('Color3Value')
		newOutdoorAmbient.Name='OutdoorAmbient'
		newOutdoorAmbient.Value=Lighting.OutdoorAmbient
		newOutdoorAmbient.Parent=newLighting

		local newShadowSoftness=InstanceNew('NumberValue')
		newShadowSoftness.Name='ShadowSoftness'
		newShadowSoftness.Value=Lighting.ShadowSoftness
		newShadowSoftness.Parent=newLighting

		local newClockTime=InstanceNew('NumberValue')
		newClockTime.Name='ClockTime'
		newClockTime.Value=Lighting.ClockTime
		newClockTime.Parent=newLighting

		local newGeographicLatitude=InstanceNew('NumberValue')
		newGeographicLatitude.Name='GeographicLatitude'
		newGeographicLatitude.Value=Lighting.GeographicLatitude
		newGeographicLatitude.Parent=newLighting

		local newExposureCompensation=InstanceNew('NumberValue')
		newExposureCompensation.Name='ExposureCompensation'
		newExposureCompensation.Value=Lighting.ExposureCompensation
		newExposureCompensation.Parent=newLighting

		StatusLabel.Text=mode..': '..newLighting.Name
		task.wait(2)

		CopyInstanceWith(explorers,ObjectClasses,newModel,function(v) if IsAs(v,LightingClasses) then  StatusLabel.Text=mode..': '..v.Name return true end return false end)
	elseif mode=='Event' then
		CopyInstanceWith(explorers,ObjectClasses,newModel,IsCopyInstance)
	elseif mode=='Team' then
		CopyInstanceWith(explorers,ObjectClasses,newModel,IsCopyInstance)
	elseif mode=='Texture' then
		CopyInstanceWith(explorers,ObjectClasses,newModel,IsCopyInstance)
	elseif mode=='Decal' then
		CopyInstanceWith(explorers,ObjectClasses,newModel,IsCopyInstance)
	elseif mode=='Trail' then
		CopyInstanceWith(explorers,ObjectClasses,newModel,IsCopyInstance)
	elseif mode=='Beam' then
		CopyInstanceWith(explorers,ObjectClasses,newModel,IsCopyInstance)
	elseif mode=='GuiColor' then
		for j,k in ipairs(explorers) do for i,v in ipairs(k:GetDescendants()) do if IsAs(v,UIClasses) then GetInstanceProperty(v,UIColorProperties,function(dataType,propertyValue) if dataType=='Color3' or dataType=='BrickColor' then needle=dataType..'_'..tostring(propertyValue) if not actives[needle] then actives[needle]=true StatusLabel.Text=mode..': '..tostring(propertyValue) if dataType=='BrickColor' then s=s..tostring(propertyValue)..',' else s=s..SafeData['Color3'](propertyValue)..',' end if sLen>=maxSLen then s=s..'\n' end sLen=(sLen+1) % maxSLen RunService.Stepped:Wait() end end end) end end end
	elseif mode=='PartColor' then
		for i,v in ipairs(Workspace:GetDescendants()) do if v:IsA('BasePart') then GetInstanceProperty(v,ColorProperties,function(dataType,propertyValue) if dataType=='Color3' or dataType=='BrickColor' then needle=dataType..'_'..tostring(propertyValue) if not actives[needle] then actives[needle]=true StatusLabel.Text=mode..': '..tostring(propertyValue) if dataType=='BrickColor' then s=s..tostring(propertyValue)..',' else s=s..SafeData['Color3'](propertyValue)..',' end if sLen>=maxSLen then s=s..'\n' end sLen=(sLen+1) % maxSLen RunService.Stepped:Wait() end end end) end end
	elseif mode=='Name'  then
		for j,k in ipairs(explorers) do for i,v in ipairs(k:GetDescendants()) do GetInstanceProperty(v,TextProperties,function(dataType,propertyValue,propertyName) if dataType=='string' then local nameFilter='' for v in StringGmatch(propertyValue,"[%w]") do if not IsStrings(v,NumericList) then nameFilter=nameFilter..v end end if #nameFilter==0 then return end local isA=false pcall(function() isA=v:IsA(nameFilter) end) if isA or #nameFilter==0 then return end local newInstance=InstanceNew(v.ClassName) local instanceValue=nil pcall(function() instanceValue=newInstance[propertyName] end) if instanceValue and instanceValue==nameFilter then newInstance:Destroy() return end if not actives[nameFilter] then actives[nameFilter]=true StatusLabel.Text=mode..': '..nameFilter s=s..nameFilter..',' if sLen>=maxSLen then s=s..'\n' end sLen=(sLen+1)%maxSLen RunService.Stepped:Wait() end end end) end end
	elseif mode=='MouseIcon' then
		if next(MouseIconCache) then for v,k in pairs(MouseIconCache) do StatusLabel.Text=mode..': '..v s=s..v..',' if sLen>=maxSLen then s=s..'\n' end sLen=(sLen+1)%maxSLen RunService.Stepped:Wait() end end
	elseif mode=='Icon' then
		for j,k in ipairs(explorers) do for i,v in ipairs(k:GetDescendants()) do GetInstanceProperty(v,IconProperties,OnImageIdCallback) end end
	elseif mode=='GuiIcon' then
		for i,v in ipairs(PlayerGui:GetDescendants()) do GetInstanceProperty(v,IconProperties,OnImageIdCallback) end
	elseif mode=='Tool' then
		ToolTarget=nil
		if not next(ToolCache) then  for i,v in ipairs(ReplicatedStorage:GetDescendants()) do if v.ClassName=='Tool' then StatusLabel.Text=mode TableInsert(ToolCache,v:Clone()) RunService.Stepped:Wait() end end end
		if next(ToolCache) then for i,v in ipairs(ToolCache) do if v and v.Parent==nil then StatusLabel.Text=mode..': '..v.Name v.Parent=newModel RunService.Stepped:Wait() end end TableClear(ToolCache) end
	elseif mode=='Gui' then
		GuiTarget=nil
		if next(GuiCache) then for v,k in pairs(GuiCache) do local cv=v:Clone() if cv and cv.Parent==nil then StatusLabel.Text=mode..': '..cv.Name cv.Parent=newModel end RunService.Stepped:Wait() end TableClear(GuiCache) end
	elseif mode=='Building' then
		BuildingTarget=nil 
		if next(BuildingCache) then for v,k in pairs(BuildingCache) do local cv=v:Clone() if cv and cv.Parent==nil then StatusLabel.Text=mode..': '..cv.Name cv.Parent=newModel end RunService.Stepped:Wait() end TableClear(BuildingCache) end
	else
		return false,nil
	end

	local isModel,modelChildren=false,newModel:GetChildren()
	if #s>0 then
		local ns=mode~='Sound' and 'local '..mode..'s=[['..s..']]' or s
		if #ns>=2000 then
			LastStatus='This '..mode..' string is too long! and '..tostring(#ns)
			StatusLabel.Text=LastStatus
			task.wait(2)
		end
		if canSRemoved then
			newModel:SetAttribute('Coding',true)
		end
		InstalCache[mode]={ns}
		isModel=false
	elseif #s<=0 and not next(modelChildren) then
		self:SetStatus(0,mode..' Has Empty')
		newModel:Destroy()
		newModel=nil
		task.wait(2)
	else
		isModel=true
	end
	s='' sLen=0 needle=nil actives,explorers,needles={},{},{}
	return isModel,newModel
end

function Module:Initialize()
	if Debounce then return end
	Debounce=true
	StatusLabel.Text='Initialize'
	task.wait(2)
	self:SetUpdate(2)
	if GrabberModel then GrabberModel:Destroy() GrabberModel=nil end
	local newInstance=InstanceNew('Model')
	newInstance.Name='InstalModel'
	if next(GrabTypeCache) then
		for k,v in pairs(GrabTypeCache) do 
			RunService.Stepped:Wait() 
			local isGroup,newGroup=self:GetGrabData(k) 
			if newGroup then
				newGroup.Parent=newInstance 
				if isGroup then
					InstalCache[k]=newGroup:GetChildren() 
				end
			end
		end
	elseif GrabType then
		local isGroup,newGroup=self:GetGrabData(GrabType) 
		if newGroup then
			newGroup.Parent=newInstance
			if isGroup then
				InstalCache[GrabType]=newGroup:GetChildren() 
			end
		end
	end
	if next(InstalCache) then
		local length=#newInstance:GetDescendants()+1
		if length>=MAX_CAP then LastStatus=tostring(length)..'Object is Dangerous!' else LastStatus='Grab '..tostring(length)..' Object' end
		StatusLabel.Text=LastStatus
		task.wait(2)
		GrabberModel=newInstance
		InstalTarget=newInstance
		self:SetStatus(0,'Successfully')
	else
		self:SetStatus(0,'An Error Occured')
	end
	task.wait(2)
	self:SetStatus(0,'Status')
	Debounce=false
end

function Module:Scan(instance,func,list)
	if list==nil then 
		local descendants=instance:GetDescendants() 
		list={Count=0,Max=#descendants} 
	end
	local children=instance:GetChildren()
	for i,v in ipairs(children) do
		task.wait(1/240)
		local className,parent=v.ClassName,v.Parent
		if v:IsA('SurfaceAppearance') then
			task.wait(1/240)
			local folder,dv=InstanceNew('Folder'),InstanceNew('SurfaceAppearance')
			pcall(function()
				folder.Name='SurfaceAppearance'
				if v.ColorMap~=dv.ColorMap then
					AddInstance('StringValue',{Name='ColorMap',Value=v.ColorMap,Parent=folder})
				end
				if v.MetalnessMap~=dv.MetalnessMap then
					AddInstance('StringValue',{Name='MetalnessMap',Value=v.MetalnessMap,Parent=folder})
				end
				if v.NormalMap~=dv.NormalMap then
					AddInstance('StringValue',{Name='NormalMap',Value=v.NormalMap,Parent=folder})
				end
				if v.RoughnessMap~=dv.RoughnessMap then
					AddInstance('StringValue',{Name='RoughnessMap',Value=v.RoughnessMap,Parent=folder})
				end
				if v.Color~=dv.Color then
					AddInstance('Color3Value',{Name='Color',Value=v.Color,Parent=folder})
				end
				if v.AlphaMode~=dv.AlphaMode then
					AddInstance('StringValue',{Name='AlphaMode',Value=SafeData['EnumItem'](v.AlphaMode),Parent=folder})
				end
				if v.EmissiveStrength~=dv.EmissiveStrength then
					AddInstance('NumberValue',{Name='EmissiveStrength',Value=v.EmissiveStrength,Parent=folder})
				end
				if v.EmissiveMaskContent~=dv.EmissiveMaskContent then
					AddInstance('StringValue',{Name='EmissiveMaskContent',Value=SafeData['Content'](v.EmissiveMaskContent),Parent=folder})
				end
			end)
			dv:Destroy()
			local folderChildren=folder:GetChildren()
			if #folderChildren<=0 then
				folder:Destroy()
			else
				v:Destroy()
				list.Count+=1
				list.Max+=(#folderChildren+1)
				if parent==nil then folder:Destroy() continue end
				folder.Parent=parent
			end
		end
		local info=ObjectClasses[className]
		if not info then
			list.Max-=1
			SetChildrenParent(v,parent)
			v:Destroy()
			func(list.Count,nil,list.Max)
			continue
		end
		list.Count+=1
		func(list.Count,v,list.Max)
		if #v:GetChildren()>0 then
			self:Scan(v,func,list)
		end
	end
end

function Module:Starting(instance,func)
	self:Scan(instance,func)
	local progress,maxProgress,waitCount,meshParts=0,0,0,{}
	local packList={instance:FindFirstChild('Building'),instance:FindFirstChild('Tool'),instance:FindFirstChild('Gui')}
	for _,model in ipairs(packList) do if model then local descendants=model:GetDescendants() for _,value in ipairs(descendants) do if value:IsA('MeshPart') then maxProgress+=1 TableInsert(meshParts,value) end end end end
	if next(meshParts) then
		maxProgress+=#meshParts
		for i,v in ipairs(meshParts) do 
			progress+=2 
			waitCount=(waitCount+1)%30 
			if waitCount==0 then 
				RunService.Stepped:Wait()
			end 
			ConvertMeshPartToSpecialMesh(v) 
			func(progress,v,maxProgress) 
		end 
	else
		maxProgress=#instance:GetDescendants()
	end
	func(maxProgress,nil,maxProgress) 
end

function Module:Creating(instance,visualInstance,data,func)
	local selections,variables,objectives,advencedVariables={},{},{},{}
	local count,progress,maxProgress,waitCount=0,0,0,0
	local descendants=instance:GetDescendants()
	for mode,list in pairs(data) do for j,k in ipairs(list) do if type(k)=='string' then maxProgress+=1 end end end
	maxProgress+=#descendants
	for i,v in ipairs(descendants) do
		if IsStrings(v.ClassName,RegisteredClasses) then 
			progress+=1
			waitCount=(waitCount+1)%30
			if waitCount==0 then task.wait(1/240) end 
			count=count+1
			CreateVariable(v,variables)
			objectives[variables[v]]=v
			advencedVariables[v]=string.format("%s[\'%s\']","V",count)
			TableInsert(selections,v)
			func(progress,v,maxProgress)
		end
	end
	for mode,list in pairs(data) do
		for i,k in ipairs(list) do
			if type(k)~='string' then continue end
			progress+=1
			waitCount=(waitCount+1)%30
			if waitCount==0 then RunService.Stepped:Wait() end 
			local v=visualInstance:FindFirstChild(mode)
			if v then
				local coding=v:GetAttribute('Coding')
				local variable=advencedVariables[v]
				if variable then
					if coding~=nil and coding==true then
						advencedVariables[v]=nil
						local instanceIndex=TableFind(selections,v)
						if instanceIndex then TableRemove(selections,instanceIndex) end
						local otherVariable=variables[v]
						if otherVariable then
							variables[v]=nil
							objectives[otherVariable]=nil
						end
						count-=1
						TableInsert(selections,k)
						v:Destroy()
					else
						TableInsert(selections,string.format(k,variable))
					end
				end
			end
			func(progress,k,maxProgress)
		end
	end
	func(maxProgress,nil,maxProgress) 
	return selections,variables,objectives,advencedVariables
end

function Module:Process(selections,variables,objectives,targets,instance,func)
	local isLimit=#selections>=MAX_CAP
	local textLocal,textCoding,textProperty,textInstance,sPrefix,sValue='','','','local V={\n','',''
	local isProperty=false
	local foundLocals,localCache={},{}
	local progress,maxProgress,instanceIndex,maxInstance=0,#selections,0,0
	func(progress,nil,maxProgress)
	for i,v in ipairs(selections) do if not v or typeof(v)~='Instance' then continue end maxInstance+=1 end
	for i,v in ipairs(selections) do
		if v then
			RunService.Stepped:Wait()
			progress+=1
			if type(v)=='string' then
				textCoding=textCoding..v..'\n'
			else
				instanceIndex+=1
				if LocalData['Instance'] and not foundLocals['Instance'] then
					foundLocals['Instance']=true
					table.insert(foundLocals,'Instance')
				end
				local variable,name,className=variables[v],v.Name,v.ClassName
				local isPart=v:IsA('BasePart')
				local data=InstalCache[name]
				if LocalData['Instance'] and not foundLocals['Instance'] then
					foundLocals['Instance']=true
					table.insert(foundLocals,'Instance')
				end
				local instanceStr=string.sub(variable,2,#variable).."=e('"..className.."')"
				textInstance=textInstance..(instanceIndex==maxInstance and instanceStr or instanceStr..',') 
				if not isLimit then textProperty=textProperty..'\n' end
				local needle,actives,defaultPropertyAdds=nil,{},{}
				local particleEmitter=v:IsA('ParticleEmitter') and v or nil
				if particleEmitter~=nil then
					pcall(function()
						local rv=nil
						if particleEmitter.FlipbookLayout==Enum.ParticleFlipbookLayout.None then
							rv={'FlipbookBlendFrames','FlipbookFramerate','FlipbookMode','FlipbookSizeY','FlipbookSizeX','FlipbookStartRandom'}
						elseif IsEnums(particleEmitter.FlipbookLayout,{Enum.ParticleFlipbookLayout.Grid2x2,Enum.ParticleFlipbookLayout.Grid4x4,Enum.ParticleFlipbookLayout.Grid8x8}) then
							rv={'FlipbookSizeY','FlipbookSizeX'}
						end
						if rv then for j,k in ipairs(rv) do if not defaultPropertyAdds[k] then defaultPropertyAdds[k]=true end end end
					end)
				end
				for propertyName,property in GetProperties(ObjectClasses[className]) do
					RunService.Stepped:Wait()
					local propertyType,propertyValue,propertyDefaultValue=property.DataType,nil,property.DefaultValue
					local success,err=pcall(function() propertyValue=v[propertyName] end)
					if not success then continue end
					if defaultPropertyAdds[propertyName] then
						propertyValue=propertyDefaultValue
					end
					if isLimit and propertyType=='string' and propertyName=='Name' then propertyValue=propertyDefaultValue end
					if propertyValue==propertyDefaultValue then continue end
					if isLimit and (propertyType=='CFrame' or propertyType=='PhysicalProperties') then continue end
					if isLimit and (propertyType=='string' or propertyType=='bool') and (propertyName=='Name' or (isPart and propertyName=='Anchored')) then continue end
					if isLimit and propertyType=='boolean' and propertyName=='Archivable' then continue end
					needle=propertyType..'_'..propertyName 
					if actives[needle] then continue end 
					actives[needle]=true
					isProperty=false
					if LocalData[propertyType] and not foundLocals[propertyType] then
						foundLocals[propertyType]=true
						table.insert(foundLocals,propertyType)
						local secondPropertyType=''
						if propertyType=='ColorSequence' or propertyType=='NumberSequence' or propertyType=='FloatSequence' then
							secondPropertyType=propertyType..'Keypoint'
						end
						if #secondPropertyType~=0 and not foundLocals[secondPropertyType] then
							foundLocals[secondPropertyType]=true
							table.insert(foundLocals,secondPropertyType)
						end
					end
					if IsStrings(propertyType,{'number','float','int','short','double'}) and type(propertyValue)=='number' then 
						isProperty=true
						if propertyValue~=propertyValue then
							textProperty=textProperty..variable..'.'..propertyName..'=0/0;'
						elseif propertyValue>=MathHuge then
							textProperty=textProperty..variable..'.'..propertyName..'=math.huge;'
						elseif propertyValue<=-MathHuge then
							textProperty=textProperty..variable..'.'..propertyName..'=-math.huge;'
						else
							isProperty=false 
						end
					elseif propertyType=='Object' and propertyName=='Parent' and v.Parent==instance then 
						isProperty=true 
						textProperty=textProperty..variable..'.Parent=workspace;'
					end
					if not isProperty then
						if propertyType=='Object' then
							if variables[propertyValue] then
								textProperty=textProperty..variable..'.'..propertyName..'='..variables[propertyValue]..';'
							elseif variables[v] then
								textProperty=textProperty..variable..'.'..propertyName..'='..variables[v]..';'
							else
								warn('['..PLUGIN_NAME..'] PROCESS FAILED: Object '..name..' '..className..'.'..propertyName..' '..tostring(objectives[targets[propertyValue]]))
							end
						else
							local result=nil
							local success,err=pcall(function() result=SafeData[propertyType](propertyValue) end)
							if not success or result==nil then
								warn('['..PLUGIN_NAME..'] PROCESS FAILED: '..propertyValue..' '..className..'.'..propertyName)
							else
								textProperty=textProperty..variable..'.'..propertyName..'='..result..';'
							end
						end
					end
				end
			end
			func(progress,v,maxProgress)
		end
	end
	textInstance=textInstance..'\n}'
	for i,k in ipairs(foundLocals) do
		local v=LocalData[k] 
		if v then
			RunService.Stepped:Wait()
			local prefix,value,vLength=v.Prefix,v.Value,v.Length
			if type(vLength)=='number' then
				for j=1,vLength do
					local prefix2,value2=prefix[j],value[j]
					if prefix2~=nil and value2~=nil then
						table.insert(localCache,{prefix2,value2})
					end
				end
				continue
			end
			table.insert(localCache,{prefix,value})
		end
	end
	for i,v in ipairs(localCache) do
		RunService.Stepped:Wait()
		local prefix,value=v[1],v[2]
		if i==#localCache then
			sPrefix=sPrefix..prefix
			sValue=sValue..value
		else
			sPrefix=sPrefix..prefix..','
			sValue=sValue..value..','
		end
	end
	TableClear(localCache) TableClear(foundLocals)
	func(maxProgress,nil,maxProgress)
	if #sPrefix>0 then
		textLocal=textLocal..'local '..sPrefix..'='
	else
		textLocal=textLocal..'local Empty='
	end
	if #sValue>0 then
		textLocal=textLocal..sValue
	else
		textLocal=textLocal..'1'
	end
	if not isLimit then textLocal=textLocal..'\n' end
	local text=textLocal..textInstance..textProperty
	if #textCoding>0 then text=textLocal..textInstance..textCoding..textProperty end
	return text
end

function Module:Convert(data,target)
	local lastTime=tick()

	local visualInstance=InstanceNew('Model')
	visualInstance.Name='Visual'
	target.Parent=visualInstance

	StatusLabel.Text='Starting Object'
	self:Starting(target,function(i,v,length) StatusLabel.Text='Starting Object' self:SetStatus(2,i,length) end)
	task.wait(2)

	local length=#target:GetDescendants()+1
	if length>=MAX_CAP then LastStatus=tostring(length)..' Object is Dangerous!' else LastStatus='Grab '..tostring(length)..' Object' end
	StatusLabel.Text=LastStatus
	task.wait(2)

	StatusLabel.Text='Create Object'
	local selections,variables,objectives,advencedVariables=self:Creating(visualInstance,target,data,function(i,v,length) StatusLabel.Text='Create Object' self:SetStatus(2,i,length) end)
	task.wait(2)

	StatusLabel.Text='Process Object'
	local text=self:Process(selections,advencedVariables,objectives,variables,visualInstance,function(i,v,length) StatusLabel.Text='Process Object' self:SetStatus(2,i,length) end)
	task.wait(2)

	target.Parent=nil
	visualInstance:Destroy()
	StatusLabel.Text='Complete'
	task.wait(2)
	StatusLabel.Text='Text Length: '..tostring(#text)
	task.wait(2)
	return text
end

function Module:Instal()
	StatusLabel.Text='Instal' 
	self:SetUpdate(2) 
	task.wait(2)
	if not next(InstalCache) or not InstalTarget then self:SetStatus(1,'Target Has Empty',2) return end
	if Debounce then return end
	Debounce=true
	local success,result=pcall(function() return self:Convert(InstalCache,InstalTarget) end)
	if Destroyed then return end
	if success and type(result)=='string' then
		setclipboard(result)
		StatusLabel.Text='Copied To Clipboard!'
	else
		StatusLabel.Text='An Error Occured'
		warn('['..PLUGIN_NAME..']',result)
	end
	task.wait(10)
	StatusLabel.Text='Status'
	LoaderLabel.Text='(0/0) 0%'
	if GrabberModel then GrabberModel:Destroy() GrabberModel=nil end
	TableClear(InstalCache)
	self:SetUpdate(1)
	task.wait(2)
	Debounce=false
end

function Module:Add()
	if IsStrings(GrabType,BannedGrabTypeList) then 
		self:SetStatus(1,'This type not allowed',2) 
		return 
	end
	if GrabType=='Building' then
		if not BuildingTarget then self:SetStatus(1,'Building Target Has Empty',2) return end
		if BuildingCache[BuildingTarget] then self:SetStatus(1,'Building Already Added',2) return end
		BuildingCache[BuildingTarget]=true
		BuildingTarget=nil
		if not GrabTypeCache[GrabType] then GrabTypeCache[GrabType]=true end
	elseif GrabType=='MouseIcon' then
		local newMouse=LocalPlayer:GetMouse()
		local mouseIconTarget=newMouse.Icon
		if not mouseIconTarget or #tostring(mouseIconTarget)==0 then self:SetStatus(1,'MouseIcon Target Has Empty',2) return end
		if MouseIconCache[mouseIconTarget] then 
			self:SetStatus(1,'MouseIcon Already Added',2) 
			return 
		end
		MouseIconCache[mouseIconTarget]=true
		if not GrabTypeCache[GrabType] then GrabTypeCache[GrabType]=true end
	elseif GrabType=='Tool' then
		local newCharacter=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local isTool=false
		for i,v in ipairs(newCharacter:GetChildren()) do if v:IsA('Tool') then isTool=true TableInsert(ToolCache,v:Clone()) end end
		if not isTool then self:SetStatus(1,'Tool Target Has Empty',2) return end
		if not GrabTypeCache[GrabType] then GrabTypeCache[GrabType]=true end
	elseif GrabType=='Gui' then
		if not GuiTarget then self:SetStatus(1,'Gui Target Has Empty',2) return end
		if GuiCache[GuiTarget] then self:SetStatus(1,'Gui Already Added',2) return end
		GuiCache[GuiTarget]=true 
		GuiTarget=nil
		if not GrabTypeCache[GrabType] then GrabTypeCache[GrabType]=true end
	else
		if GrabTypeCache[GrabType] then self:SetStatus(1,'Already Added',2) return end GrabTypeCache[GrabType]=true
	end
	self:SetStatus(1,'Successfully',2)
end

function Module:Reset()
	self:SetUpdate(1)
end

function Module:Destroy()
	if Destroyed then return end
	Destroyed=true
	Window:Destroy()
	Outliner:Destroy()
	self:SetUpdate(1)
	local k,v=next(Cache)
	while v do
		Cache[k]=nil
		v:Disconnect()
		k,v=next(Cache)
	end
end

function Module:Stop()
	if GrabType=='Building' then
		local model=BuildingTarget
		if not IsAlive(model) then self:SetStatus(1,'No Building Target',2) return end
		local animators=model:QueryDescendants('Animator')
		if not next(animators) then self:SetStatus(1,'Animator not found',2) return end
		for i,k in ipairs(animators) do local playingTracks=k:GetPlayingAnimationTracks() for j,v in ipairs(playingTracks) do v.TimePosition=0 v:Stop() end end
		self:SetStatus(1,'Stop Complete',2)
	end
end

function Module:Record()
	if GrabType=='Animation' then
		if IsRecordAnim then self:SetStatus(1,'Waiting',2) return end
		local model=BuildingTarget
		if not IsAlive(model) then self:SetStatus(1,'No Building Target',2) return end
		local animators=model:QueryDescendants('Animator')
		if not next(animators) then self:SetStatus(1,'Animator not found',2) return end
		local animator=animators[1]
		if not animator then self:SetStatus(1,'Animator not found',2) return end
		if RecordAnimType=='None' then
			self:SetStatus(1,'An Error Occured',2)
			return
		end
		local playingTracks=animator:GetPlayingAnimationTracks()
		if #playingTracks==0 then self:SetStatus(1,'No Animation Playing',2) return end
		if IsRecordAnim then return end
		IsRecordAnim=true
		local fpsMode,recordAnimMode=FPSType,RecordAnimType
		local targetTrack=playingTracks[1]
		local duration=targetTrack.Length
		if fpsMode=='240 FPS' or fpsMode=='Unlimited' then
			StatusLabel.TextScaled=true
			self:SetStatus(1,'Warning: This FPS will cause problems',2)
			StatusLabel.TextScaled=false
		end
		local animSaves=model:FindFirstChild('AnimSaves') or Instance.new('ObjectValue')
		animSaves.Name='AnimSaves'
		animSaves.Parent=model
		local keyframeSequence=Instance.new('KeyframeSequence')
		keyframeSequence.Name='Record_' .. os.time()
		keyframeSequence.Parent=animSaves
		local bones,motors={},{}
		if recordAnimMode=='Bone' then bones=model:QueryDescendants('Bone') else motors=model:QueryDescendants('Motor6D') end
		local startTime=os.clock()
		targetTrack.TimePosition=0 
		local frameRate,elapsed=FPSRateData[fpsMode] or 1/30,0
		RecordAnimConnection=RunService.Stepped:Connect(function()
			if not IsAlive(model) then if IsRecordAnim then IsRecordAnim=false if RecordAnimConnection then RecordAnimConnection:Disconnect() RecordAnimConnection=nil end Module:SetStatus(1,'Record Failed',2) end end
			if fpsMode=='Unlimited' then elapsed=os.clock()-startTime else elapsed=elapsed+frameRate end
			if elapsed<=duration then
				StatusLabel.Text='Recording...'
				local keyframe=Instance.new('Keyframe') 
				keyframe.Time=elapsed
				if recordAnimMode=='Bone' then
					for i,v in ipairs(bones) do AddPose(v.Name,v.Transform,keyframe) end
				else
					for i,v in ipairs(motors) do AddPose(v.Part1.Name,v.Transform,keyframe) end
				end
				keyframe.Parent=keyframeSequence
			else
				if IsRecordAnim then IsRecordAnim=false if RecordAnimConnection then RecordAnimConnection:Disconnect() RecordAnimConnection=nil end  Module:SetStatus(1,'Record Complete',2) end
			end
		end)
	end
end

do
	local function OnCharacterToolAdded(character)
		if Cache.CharacterToolAdded then Cache.CharacterToolAdded:Disconnect() Cache.CharacterToolAdded=nil end
		Cache.CharacterToolAdded=character.ChildAdded:Connect(function(child)
			if child:IsA('Tool') then ToolTarget=child end
		end)
	end

	OnCharacterToolAdded(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
	Cache.CharacterAdded=LocalPlayer.CharacterAdded:Connect(OnCharacterToolAdded)
end

Window=UI:CreateWindow({
	Name='Instal',
	Destroying=function()
		Module:Destroy() 
	end
})
Outliner.Parent=Window.Gui
StatusLabel=Window:AddLabel('Status')
LoaderLabel=Window:AddLabel('(0/0) 0%')

SelectorGrabTypeButton=Window:AddSelector({
	Options=GrabTypeList,
	Value=GrabTypeList[1],
	NoCap=true,
	ApplyOnInit=true,
	Callback=function(value,key) 
		GrabType=value Module:SetUpdate(3) 
	end
})

local TargetDebounce=false
TopSelectButton=Window:AddSelect({
	Visible=false,
	Callback=function(target) 
		if not IsInput and IsStrings(GrabType,{'Building','Animation'}) then 
			if not TargetDebounce then
				TargetDebounce=true
				if target then
					BuildingIndex=0
					local current=target
					while current and current.Parent and current.Parent~=workspace do
						current=current.Parent
						BuildingIndex=BuildingIndex+1 

						if TotalBuilding>0 and BuildingIndex>=TotalBuilding then
							target=current
							break
						end
					end
					if Window.Parent then
						MainLabel.Text='Total Building: '..tostring(BuildingIndex)
						StatusLabel.Text=target.Name..' | '..target.ClassName..' | '..tostring(#target:GetChildren())
					end
					Module:SetUpdate(2,target)
					BuildingTarget=target
				else
					BuildingIndex=0
					if Window.Parent then
						MainLabel.Text='Total Building: 0'
						StatusLabel.Text='Status'
					end
					Module:SetUpdate(2)
					BuildingTarget=nil
				end
				task.wait(1)
				TargetDebounce=false
			end
		end
	end,
	Deactivated=function() Module:SetUpdate(2) Module:SetStatus(1,StatusLabel.Text) end
})

SelectorAnimationButton=Window:AddSelector({
	Visible=false,
	Options=RecordAnimTypeList,
	Value=RecordAnimTypeList[1],
	NoCap=true,Callback=function(value,key) 
		RecordAnimType=value 
	end
})
SelectorFPSButton=Window:AddSelector({
	Visible=false,
	Options=FPSTypeList,
	Value=FPSTypeList[1],
	NoCap=true,
	Callback=function(value,key) 
		FPSType=value 
	end
})
MainLabel=Window:AddLabel({
	Text='',
	Visible=false,
	TextScaled=true
})
TextBox=Window:AddInput({
	Name="Typing",
	PlaceholderText='Type here',
	Visible=false,
	Callback=function(text)
		local amount=tonumber(text)
		if amount then
			if IsStrings(GrabType,{'Building','Animation'}) then 
				TotalBuilding=MathMax(amount,0)
				TextBox.Text=tostring(TotalBuilding)
			end
		else
			TextBox.Text='Please enter the number'
			task.wait(2)
			TextBox.Text=''
		end
	end
})
RecordButton=Window:AddButton({
	Text='Record',
	Visible=false,
	Callback=function() 
		Module:Record() 
	end
})
StopButton=Window:AddButton({
	Text='Stop',
	Visible=false,
	Callback=function() 
		Module:Stop() 
	end
})
AddButton=Window:AddButton({
	Text='Add',
	Visible=false,
	Callback=function() 
		Module:Add() 
	end
})
InitializeButton=Window:AddButton({
	Text='Initialize',
	Callback=function() 
		Module:Initialize() 
	end
})
InstalButton=Window:AddButton({
	Text='Instal',
	MethodType='DoubleClick',
	Callback=function() 
		Module:Instal() 
	end
})
ResetButton=Window:AddButton({
	Text='Reset',
	MethodType='DoubleClick',
	Callback=function() 
		Module:Reset() 
	end
})
DestroyButton=Window:AddButton({
	Text='Destroy',
	MethodType='DoubleClick',
	Callback=function() 
		Module:Destroy() 
	end
})

Window:AddLabel('YouTube: Crokyreo')
Window:AddLabel('Version: 36')

Module.Parent=true
