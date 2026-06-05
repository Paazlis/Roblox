local Services = setmetatable({},{__index = function(_,i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local LocalPlayer = Players.LocalPlayer

local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function CallSafely(func,...)
	if func then
		local success, result = pcall(func, ...)
		if not success then
			return false
		end
		return result
	end
	return nil
end

local SimpleUI = {}

function SimpleUI:Create(className, properties)
	properties = typeof(properties) == "table" and properties or {}
	local obj = Instance.new(className)
	for property, value in next, properties do
		obj[property] = value
	end
	return obj
end

local function UIComponents(targetContainer)
	local elements = {}

	function elements:AddToggle(options)
		options = typeof(options) == "table" and options or {}
		options.Type = "Toggle"
		options.Name = options.Name or "Toggle"
		options.Value = options.Value or false
		
		local toggleBtn = SimpleUI:Create("TextButton", {
			Parent = targetContainer,
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = Color3.fromRGB(45, 45, 52),
			Text = "   " .. options.Name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBlack,
			TextSize = 12,
			BorderSizePixel = 0,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		local indicator = SimpleUI:Create("Frame", {
			Parent = toggleBtn,
			Size = UDim2.new(0, 38, 0, 18),
			Position = UDim2.new(1, -46, 0.5, -9),
			BackgroundColor3 = Color3.fromRGB(75, 75, 85),
			BorderSizePixel = 0
		})

		local indicatorText = SimpleUI:Create("TextLabel", {
			Parent = indicator,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "OFF",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBlack,
			TextSize = 9
		})

		function options:Set(value)
			self.Value = value
			local targetColor = value and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(75, 75, 85)
			TweenService:Create(indicator, TWEEN_INFO, {BackgroundColor3 = targetColor}):Play()
			indicatorText.Text = value and "ON" or "OFF"
		    CallSafely(options.Callback, options.Value)
        end

		toggleBtn.MouseButton1Click:Connect(function()
			options:Set(not options.Value)
		end)

		options:Set(options.Value)
		return options
	end

	function elements:AddButton(options)
		options = typeof(options) == "table" and options or {}
		options.Type = "Button"
		options.Name = options.Name or "Button"
		
		local button = SimpleUI:Create("TextButton", {
			Parent = targetContainer,
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = Color3.fromRGB(65, 65, 75),
			Text = options.Name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBlack,
			TextSize = 12,
			BorderSizePixel = 0
		})

		function options:Set(value)
			self.Text = value
			button.Text = value
		end

		button.MouseButton1Click:Connect(function()
			CallSafely(options.Callback)
		end)

		options:Set(options.Name)
		return options
	end

	function elements:AddSlider(options)
		options = typeof(options) == "table" and options or {}
		options.Type = "Slider"
		options.Name = options.Name or "Slider"
		options.Range = options.Range or {0, 100}
		options.Value = options.Value or options.Range[1]
		
		local min, max = options.Range[1], options.Range[2]
		
		local sliderFrame = SimpleUI:Create("Frame", {
			Parent = targetContainer,
			Size = UDim2.new(1, 0, 0, 45),
			BackgroundTransparency = 1
		})
		
		local label = SimpleUI:Create("TextLabel", {
			Parent = sliderFrame,
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Text = options.Name .. ": " .. options.Value,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBlack,
			TextSize = 12,
			BorderSizePixel = 0
		})
		
		local track = SimpleUI:Create("TextButton", {
			Parent = sliderFrame,
			Size = UDim2.new(1, 0, 0, 10),
			Position = UDim2.new(0, 0, 0, 25),
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0
		})
		
		local fill = SimpleUI:Create("Frame", {
			Parent = track,
			BackgroundColor3 = Color3.fromRGB(60, 150, 200),
			Size = UDim2.new(0, 0, 1, 0),
			BorderSizePixel = 0
		})

		function options:Set(value)
			self.Value = math.clamp(value, min, max)
			local percentage = (self.Value - min) / (max - min)
			fill.Size = UDim2.new(percentage, 0, 1, 0)
			label.Text = self.Name .. ": " .. self.Value
		    CallSafely(options.Callback, val)
        end

		track.MouseButton1Down:Connect(function()
			local mouse = LocalPlayer:GetMouse()
			local percentage = math.clamp((mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			local val = math.floor(min + ((max - min) * percentage))
			options:Set(val)
		end)

		options:Set(options.Value)
		return options
	end

	function elements:AddLabel(options)
		options = typeof(options) == "table" and options or (typeof(options) == "string" and {Name = options} or {})
		options.Type = "Label"
		options.Name = options.Name or "Label"

		local label = SimpleUI:Create("TextLabel", {
			Parent = targetContainer,
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundTransparency = 1,
			Text = " " .. options.Name,
			TextColor3 = Color3.fromRGB(180, 180, 190),
			Font = Enum.Font.GothamBlack,
			TextSize = 11,
			BorderSizePixel = 0,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		function options:Set(value)
			self.Text = value
			label.Text = " " .. value
		end

		options:Set(options.Name)
		return options
	end

	function elements:AddFolder(options)
		options = typeof(options) == "table" and options or (typeof(options) == "string" and {Name = options} or {})
		options.Type = "Folder"
		options.Name = options.Name or "Folder"
		options.Open = typeof(options.Open) == "boolean" and options.Open or false

		local folderFrame = SimpleUI:Create("Frame", {
			Parent = targetContainer,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1
		})

		SimpleUI:Create("UIListLayout", {
			Parent = folderFrame,
			Padding = UDim.new(0, 5),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		local folderHeader = SimpleUI:Create("Frame", {
			Parent = folderFrame,
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundColor3 = Color3.fromRGB(45, 45, 52),
			BorderSizePixel = 0
		})

		local folderArrow = SimpleUI:Create("TextButton", {
			Parent = folderHeader,
			Size = UDim2.new(0, 28, 1, 0),
			BackgroundTransparency = 1,
			Text = "▶",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBlack,
			TextSize = 12
		})

		local folderTitle = SimpleUI:Create("TextLabel", {
			Parent = folderHeader,
			Size = UDim2.new(1, -28, 1, 0),
			Position = UDim2.new(0, 28, 0, 0),
			BackgroundTransparency = 1,
			Text = options.Name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBlack,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		local childContainer = SimpleUI:Create("Frame", {
			Parent = folderFrame,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Visible = false
		})

		SimpleUI:Create("UIListLayout", {
			Parent = childContainer,
			Padding = UDim.new(0, 5),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		function options:Set(value)
			self.Open = value
			childContainer.Visible = value
			folderArrow.Text = value and "▼" or "▶"
		end

		folderArrow.MouseButton1Click:Connect(function()
			options:Set(not options.Open)
		end)

		options:Set(options.Open)

		local childElements = UIComponents(childContainer)
		for k, v in next, childElements do
			options[k] = v
		end

		return options
	end
	
	return elements
end

function SimpleUI:CreateWindow(config)
	config = typeof(config) == "table" and config or {}
	
	local Window = {}
	Window.MaxHeight = config.MaxHeight or 320
	Window.Size = config.Size or UDim2.new(0, 240, 0, 40)

	local gui = SimpleUI:Create("ScreenGui", {
		Name = config.Name or "SimpleUIWindow",
		ResetOnSpawn = false
	})

	local parent = Services.CoreGui
	if syn and syn.protect_gui then
		syn.protect_gui(gui)
	elseif get_hidden_gui then
		get_hidden_gui(gui)
	elseif gethui then
		parent = gethui(gui)
	else
		LocalPlayer:Kick("Error: protect_gui function not found")
		return
	end
	gui.Parent = parent

	local mainFrame = SimpleUI:Create("Frame", {
		Parent = gui,
		Size = Window.Size,
		Position = UDim2.new(0, 20, 0, 20),
		BackgroundColor3 = Color3.fromRGB(30, 30, 35),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Active = true
	})

	local titleBar = SimpleUI:Create("Frame", {
		Parent = mainFrame,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1
	})

	local titleArrow = SimpleUI:Create("TextButton", {
		Parent = titleBar,
		Size = UDim2.new(0, 40, 1, 0),
		BackgroundTransparency = 1,
		Text = "▼",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBlack,
		TextSize = 12
	})

	local titleLabel = SimpleUI:Create("TextLabel", {
		Parent = titleBar,
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.new(0, 40, 0, 0),
		BackgroundTransparency = 1,
		Text = config.Name or "Menu",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBlack,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local scrollFrame = SimpleUI:Create("ScrollingFrame", {
		Parent = mainFrame,
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, 40),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110),
		ClipsDescendants = true,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})

	local contentHolder = SimpleUI:Create("Frame", {
		Parent = scrollFrame,
		Size = UDim2.new(1, -16, 0, 0),
		Position = UDim2.new(0, 6, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1
	})

	SimpleUI:Create("UIListLayout", {
		Parent = contentHolder,
		Padding = UDim.new(0, 6),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local isMinimized = false
	
	local function updateWindowSize(animated)
		local contentHeight = contentHolder.AbsoluteSize.Y
		local targetMainSize, targetScrollSize
		
		if isMinimized then
			targetMainSize = UDim2.new(0, Window.Size.X.Offset, 0, 40)
			targetScrollSize = UDim2.new(1, 0, 0, 0)
		else
			local allowedContentHeight = math.min(contentHeight + 6, Window.MaxHeight - 40)
			targetMainSize = UDim2.new(0, Window.Size.X.Offset, 0, 40 + allowedContentHeight)
			targetScrollSize = UDim2.new(1, 0, 0, allowedContentHeight)
		end
		
		if animated then
			TweenService:Create(mainFrame, TWEEN_INFO, {Size = targetMainSize}):Play()
			TweenService:Create(scrollFrame, TWEEN_INFO, {Size = targetScrollSize}):Play()
		else
			mainFrame.Size = targetMainSize
			scrollFrame.Size = targetScrollSize
		end
	end

	contentHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHolder.AbsoluteSize.Y + 6)
		updateWindowSize(true)
	end)

	titleArrow.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		titleArrow.Text = isMinimized and "▶" or "▼"
		updateWindowSize(true)
	end)

	local dragging, dragInput, dragStart, startPos

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position

			local connection
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					connection:Disconnect()
				end
			end)
		end
	end)

	titleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	local BaseComponents = UIComponents(contentHolder)
	for k, v in next, BaseComponents do
		Window[k] = v
	end
	Window.Container = contentHolder

	return Window
end

return SimpleUI
