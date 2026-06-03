local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. MODULAR UI LIBRARY WITH TREE STRUCTURE
-- ==========================================
local SimpleUI = {}

-- Internal helper to style text/buttons consistently
local function applyUIStyle(instance, text, isBold)
	instance.Text = text
	instance.TextColor3 = Color3.fromRGB(255, 255, 255)
	instance.Font = isBold and Enum.Font.GothamBold or Enum.Font.GothamSemibold
	instance.TextSize = 12
	instance.BorderSizePixel = 0
end

-- Shared element generators used by both Windows and Folders
local function UIComponents(targetContainer)
	local elements = {}

	function elements:CreateToggle(options)
		local state = options.CurrentValue or false
		
		local toggleBtn = Instance.new("TextButton", targetContainer)
		toggleBtn.Size = UDim2.new(1, -15, 0, 30)
		toggleBtn.BackgroundColor3 = state and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(200, 60, 60)
		applyUIStyle(toggleBtn, options.Name .. ": " .. (state and "ON" or "OFF"), false)

		toggleBtn.MouseButton1Click:Connect(function()
			state = not state
			toggleBtn.Text = options.Name .. ": " .. (state and "ON" or "OFF")
			toggleBtn.BackgroundColor3 = state and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(200, 60, 60)
			if options.Callback then options.Callback(state) end
		end)
		return toggleBtn
	end

	function elements:CreateButton(options)
		local button = Instance.new("TextButton", targetContainer)
		button.Size = UDim2.new(1, -15, 0, 30)
		button.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
		applyUIStyle(button, options.Name, false)

		button.MouseButton1Click:Connect(function()
			if options.Callback then options.Callback() end
		end)
		return button
	end

	function elements:CreateSlider(options)
		local min, max = options.Range[1], options.Range[2]
		local val = options.CurrentValue or min
		
		local sliderFrame = Instance.new("Frame", targetContainer)
		sliderFrame.Size = UDim2.new(1, -15, 0, 45)
		sliderFrame.BackgroundTransparency = 1
		
		local label = Instance.new("TextLabel", sliderFrame)
		label.Size = UDim2.new(1, 0, 0, 20)
		label.BackgroundTransparency = 1
		applyUIStyle(label, options.Name .. ": " .. val, false)
		
		local track = Instance.new("TextButton", sliderFrame)
		track.Size = UDim2.new(1, 0, 0, 10)
		track.Position = UDim2.new(0, 0, 0, 25)
		track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		track.Text = ""
		track.AutoButtonColor = false
		track.BorderSizePixel = 0
		
		local fill = Instance.new("Frame", track)
		fill.BackgroundColor3 = Color3.fromRGB(60, 150, 200)
		fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
		fill.BorderSizePixel = 0

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
	
	return elements
end

function SimpleUI:CreateWindow(config)
	local gui = Instance.new("ScreenGui")
	gui.Name = config.Name or "SimpleUIWindow"
	gui.ResetOnSpawn = false
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	-- Main background Frame
	local mainFrame = Instance.new("Frame", gui)
	mainFrame.Size = UDim2.new(0, 230, 0, 300) -- Fixed vertical panel height
	mainFrame.Position = UDim2.new(0, 20, 0, 20)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Active = true 

	-- Header / Minimize Bar
	local title = Instance.new("TextButton", mainFrame)
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.AutoButtonColor = false
	applyUIStyle(title, "  " .. (config.Name or "Menu"), true)
	title.TextXAlignment = Enum.TextXAlignment.Left

	-- Scrolling Content Area
	local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
	scrollFrame.Size = UDim2.new(1, 0, 1, -45)
	scrollFrame.Position = UDim2.new(0, 0, 0, 40)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 4
	scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Dynamically scales scroll space

	local globalLayout = Instance.new("UIListLayout", scrollFrame)
	globalLayout.Padding = UDim.new(0, 6)
	globalLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	globalLayout.SortOrder = Enum.SortOrder.LayoutOrder

	-- --- DRAG & MINIMIZE CONTROLLER ---
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
						mainFrame.Size = isMinimized and UDim2.new(0, 230, 0, 40) or UDim2.new(0, 230, 0, 300)
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

	-- Base Object Construction
	local Window = UIComponents(scrollFrame)
	Window.Container = scrollFrame

	-- Tree Node Generation: AddFolder Function
	function Window:AddFolder(folderName)
		local folderFrame = Instance.new("Frame", self.Container)
		folderFrame.Size = UDim2.new(1, 0, 0, 0)
		folderFrame.AutomaticSize = Enum.AutomaticSize.Y
		folderFrame.BackgroundTransparency = 1

		local folderLayout = Instance.new("UIListLayout", folderFrame)
		folderLayout.Padding = UDim.new(0, 4)
		folderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		folderLayout.SortOrder = Enum.SortOrder.LayoutOrder

		-- Dropdown Toggle Banner
		local folderHeader = Instance.new("TextButton", folderFrame)
		folderHeader.Size = UDim2.new(1, -15, 0, 26)
		folderHeader.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
		applyUIStyle(folderHeader, "▶  " .. folderName, true)
		folderHeader.TextXAlignment = Enum.TextXAlignment.Left

		-- Nested Child Container
		local childContainer = Instance.new("Frame", folderFrame)
		childContainer.Size = UDim2.new(1, 0, 0, 0)
		childContainer.AutomaticSize = Enum.AutomaticSize.Y
		childContainer.BackgroundTransparency = 1
		childContainer.Visible = false -- Hidden by default

		local childLayout = Instance.new("UIListLayout", childContainer)
		childLayout.Padding = UDim.new(0, 5)
		childLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

		-- Handle Tree Collapsing
		local folderOpen = false
		folderHeader.MouseButton1Click:Connect(function()
			folderOpen = not folderOpen
			childContainer.Visible = folderOpen
			folderHeader.Text = (folderOpen and "▼  " or "▶  ") .. folderName
		end)

		-- Return a unique UI component hub bound inside this specific folder
		return UIComponents(childContainer)
	end

	return Window
end

return SimpleUI
