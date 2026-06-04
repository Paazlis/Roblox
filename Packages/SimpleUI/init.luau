local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ==========================================
-- 1. SIMPLEUI LIBRARY
-- ==========================================
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
		-- Normalize Options and Track Type Properties
		options = typeof(options) == "table" and options or {}
		options.Type = "Toggle"
		options.Name = options.Name or "Toggle"
		options.CurrentValue = options.CurrentValue or false
        if typeof(options.Version) ~= "number" then
           options.Version = 1
        end

		local state = options.CurrentValue

        if options.Version == 1 then
        -- Upgraded sleek base container button
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

		-- Compact visual pill indicator status switch
		local indicator = SimpleUI:Create("Frame", {
			Parent = toggleBtn,
			Size = UDim2.new(0, 38, 0, 18),
			Position = UDim2.new(1, -46, 0.5, -9),
			BackgroundColor3 = state and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(75, 75, 85),
			BorderSizePixel = 0
		})

		local indicatorText = SimpleUI:Create("TextLabel", {
			Parent = indicator,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = state and "ON" or "OFF",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBlack,
			TextSize = 9
		})

		toggleBtn.MouseButton1Click:Connect(function()
			state = not state
			
			-- Smoothly tween color transition for visual premium polish
			local targetColor = state and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(75, 75, 85)
			TweenService:Create(indicator, TWEEN_INFO, {BackgroundColor3 = targetColor}):Play()
			indicatorText.Text = state and "ON" or "OFF"

			if options.Callback then options.Callback(state) end
		end)
        else
		local toggleBtn = SimpleUI:Create("TextButton", {
			Parent = targetContainer,
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = state and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(200, 60, 60),
			Text = options.Name .. ": " .. (state and "ON" or "OFF"),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBlack, -- Updated Font
			TextSize = 12,
			BorderSizePixel = 0
		})

		toggleBtn.MouseButton1Click:Connect(function()
			state = not state
			toggleBtn.Text = options.Name .. ": " .. (state and "ON" or "OFF")
			toggleBtn.BackgroundColor3 = state and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(200, 60, 60)
			if options.Callback then options.Callback(state) end
		end)
        end
		return toggleBtn
	end

	function elements:AddButton(options)
		-- Normalize Options and Track Type Properties
		options = typeof(options) == "table" and options or {}
		options.Type = "Button"
		options.Name = options.Name or "Button"
		
		local button = SimpleUI:Create("TextButton", {
			Parent = targetContainer,
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = Color3.fromRGB(65, 65, 75),
			Text = options.Name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBlack, -- Updated Font
			TextSize = 12,
			BorderSizePixel = 0
		})

		button.MouseButton1Click:Connect(function()
			if options.Callback then options.Callback() end
		end)
		return button
	end

	function elements:AddSlider(options)
		-- Normalize Options and Track Type Properties
		options = typeof(options) == "table" and options or {}
		options.Type = "Slider"
		options.Name = options.Name or "Slider"
		options.Range = options.Range or {0, 100}
		options.CurrentValue = options.CurrentValue or options.Range[1]
		
		local min, max = options.Range[1], options.Range[2]
		local val = options.CurrentValue
		
		local sliderFrame = SimpleUI:Create("Frame", {
			Parent = targetContainer,
			Size = UDim2.new(1, 0, 0, 45),
			BackgroundTransparency = 1
		})
		
		local label = SimpleUI:Create("TextLabel", {
			Parent = sliderFrame,
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Text = options.Name .. ": " .. val,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBlack, -- Updated Font
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
			Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
			BorderSizePixel = 0
		})

		track.MouseButton1Down:Connect(function()
			local mouse = LocalPlayer:GetMouse()
			local percentage = math.clamp((mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			val = math.floor(min + ((max - min) * percentage))
			
			fill.Size = UDim2.new(percentage, 0, 1, 0)
			label.Text = options.Name .. ": " .. val
			if options.Callback then options.Callback(val) end
		end)
		return sliderFrame
	end

	function elements:AddLabel(options)
		-- Normalize Options and Track Type Properties
		options = typeof(options) == "table" and options or (typeof(options) == "string" and {Name = options} or {})
		options.Type = "Label"
		options.Name = options.Name or "Label"

		local label = SimpleUI:Create("TextLabel", {
			Parent = targetContainer,
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundTransparency = 1,
			Text = " " .. options.Name,
			TextColor3 = Color3.fromRGB(180, 180, 190),
			Font = Enum.Font.GothamBlack, -- Updated Font
			TextSize = 11,
			BorderSizePixel = 0,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		return label
	end

	function elements:AddFolder(options)
		-- Normalize Options and Track Type Properties (Accepts raw string or complex table layout)
		options = typeof(options) == "table" and options or (typeof(options) == "string" and {Name = options} or {})
		options.Type = "Folder"
		options.Name = options.Name or "Folder"

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

		local folderHeader = SimpleUI:Create("TextButton", {
			Parent = folderFrame,
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundColor3 = Color3.fromRGB(45, 45, 52),
			Text = "  ▶  " .. options.Name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			BorderSizePixel = 0,
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

		SimpleUI:Create("UIPadding", {
			Parent = childContainer,
			PaddingLeft = UDim.new(0, 0),
			PaddingRight = UDim.new(0, 0)
		})

		local folderOpen = false
		folderHeader.MouseButton1Click:Connect(function()
			folderOpen = not folderOpen
			childContainer.Visible = folderOpen
			folderHeader.Text = (folderOpen and "  ▼  " or "  ▶  ") .. options.Name
		end)

		return UIComponents(childContainer)
	end
	
	return elements
end

function SimpleUI:CreateWindow(config)
	local gui = SimpleUI:Create("ScreenGui", {
		Name = config.Name or "SimpleUIWindow",
		ResetOnSpawn = false
	})
    
    local parent = game:GetService("CoreGui")

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
		Size = UDim2.new(0, 240, 0, 320),
		Position = UDim2.new(0, 20, 0, 20),
		BackgroundColor3 = Color3.fromRGB(30, 30, 35),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Active = true
	})

	local title = SimpleUI:Create("TextButton", {
		Parent = mainFrame,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "   " .. (config.Name or "Menu"),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		BorderSizePixel = 0,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local scrollFrame = SimpleUI:Create("ScrollingFrame", {
		Parent = mainFrame,
		Size = UDim2.new(1, 0, 0, 275),
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

	contentHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHolder.AbsoluteSize.Y + 10)
	end)

	-- --- DRAG / CONTENT TWEEN MINIMIZE CONTROLLER ---
	local dragging, dragInput, dragStart, startPos
	local isMinimized = false

	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position

			local connection
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					connection:Disconnect()
					
					if (input.Position - dragStart).Magnitude < 5 then
						isMinimized = not isMinimized
						
						local targetMainSize = isMinimized and UDim2.new(0, 240, 0, 40) or UDim2.new(0, 240, 0, 320)
						local targetScrollSize = isMinimized and UDim2.new(1, 0, 0, 0) or UDim2.new(1, 0, 0, 275)
						
						TweenService:Create(mainFrame, TWEEN_INFO, {Size = targetMainSize}):Play()
						TweenService:Create(scrollFrame, TWEEN_INFO, {Size = targetScrollSize}):Play()
					end
				end
			end)
		end
	end)

	title.InputChanged:Connect(function(input)
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

	local Window = UIComponents(contentHolder)
	Window.Container = contentHolder

	return Window
end

return SimpleUI
