-- Load UI Library
local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Window = UI:CreateWindow("Aimbot Pro")

-- Aimbot Variables
local AimbotSettings = {
    Enabled = false,
    TargetPart = "Head",
    MaxDistance = 10000,
    Smoothness = 5,
    TeamCheck = true,
    WallCheck = true
}

-- Get core services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Function to check if line of sight is clear
local function IsTargetVisible(targetPart)
    if not AimbotSettings.WallCheck then return true end

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.IgnoreWater = true

    local rayResult = Workspace:Raycast(
        Camera.CFrame.Position,
        (targetPart.Position - Camera.CFrame.Position).Unit * (targetPart.Position - Camera.CFrame.Position).Magnitude,
        rayParams
    )

    return rayResult and rayResult.Instance == targetPart
end

-- Function to find closest valid target
local function FindClosestTarget()
    local ClosestPlayer = nil
    local ClosestDistance = math.huge
    local MousePosition = Camera.ViewportSize / 2

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and (not AimbotSettings.TeamCheck or Player.Team ~= LocalPlayer.Team) then
            local Character = Player.Character
            if Character and Character:FindFirstChild(AimbotSettings.TargetPart) and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
                local TargetPart = Character[AimbotSettings.TargetPart]
                local WorldDistance = (Camera.CFrame.Position - TargetPart.Position).Magnitude
                
                if WorldDistance <= AimbotSettings.MaxDistance then
                    local ScreenPosition, IsOnScreen = Camera:WorldToScreenPoint(TargetPart.Position)
                    if IsOnScreen and IsTargetVisible(TargetPart) then
                        local DistanceFromCenter = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - MousePosition).Magnitude
                        if DistanceFromCenter < ClosestDistance then
                            ClosestDistance = DistanceFromCenter
                            ClosestPlayer = Character
                        end
                    end
                end
            end
        end
    end

    return ClosestPlayer
end

-- Main aimbot function
local AimbotConnection
local function UpdateAimbot()
    if not AimbotSettings.Enabled then return end

    local Target = FindClosestTarget()
    if Target and Target:FindFirstChild(AimbotSettings.TargetPart) then
        local TargetPosition = Target[AimbotSettings.TargetPart].Position
        local CameraCFrame = Camera.CFrame
        local NewCFrame = CFrame.new(CameraCFrame.Position, TargetPosition)
        
        Camera.CFrame = CameraCFrame:Lerp(NewCFrame, 1 / AimbotSettings.Smoothness)
    end
end

-- Create UI Elements
-- Main aimbot toggle
local AimbotToggle = Window:AddToggle({
    Text = "Enable Aimbot",
    Value = false,
    Flag = "aimbot_toggle",
    Callback = function(value)
        AimbotSettings.Enabled = value
        
        if value then
            if AimbotConnection then AimbotConnection:Disconnect() end
            AimbotConnection = RunService.RenderStepped:Connect(UpdateAimbot)
        else
            if AimbotConnection then AimbotConnection:Disconnect() end
        end
    end
})

-- Target part dropdown
local TargetOptions = {"Head", "Torso", "HumanoidRootPart", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}
Window:AddDropdown({
    Text = "Target Part",
    Options = TargetOptions,
    Option = "Head",
    Flag = "target_part",
    Callback = function(selectedValue)
        AimbotSettings.TargetPart = selectedValue
    end
})

-- Maximum distance slider (set to 10000 max)
Window:AddSlider({
    Text = "Maximum Distance",
    Min = 100,
    Max = 10000,
    Value = 10000,
    Increment = 100,
    Flag = "max_distance",
    Callback = function(value)
        AimbotSettings.MaxDistance = value
    end
})

-- Camera smoothness slider
Window:AddSlider({
    Text = "Camera Smoothness",
    Min = 1,
    Max = 10,
    Value = 5,
    Increment = 1,
    Flag = "smoothness",
    Callback = function(value)
        AimbotSettings.Smoothness = value
    end
})

-- Team check toggle
Window:AddToggle({
    Text = "Don't Shoot Teammates",
    Value = true,
    Flag = "team_check",
    Callback = function(value)
        AimbotSettings.TeamCheck = value
    end
})

-- Wall check toggle
Window:AddToggle({
    Text = "Enable Wall Check",
    Value = true,
    Flag = "wall_check",
    Callback = function(value)
        AimbotSettings.WallCheck = value
    end
})

Window:AddLabel("YouTube: Crokyreo")

--[[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- CONFIG DEFAULTS (tweak these for performance)
local DEFAULT_KEY = Enum.KeyCode.E -- default shown in UI
local DEFAULT_LOCK = 100 -- 0..100 (100=slowest, 0=fastest)
local DEFAULT_RANGE = 1000 -- 0..1000 studs
local MAX_RANGE = 1000
local MAX_LOCK = 100

-- PERFORMANCE TUNABLES (lower AIM_RATE + higher NPC_REFRESH_INTERVAL => less CPU)
local NPC_REFRESH_INTERVAL = 1.0 -- seconds: how often we rebuild the NPC cache (was 0.6)
local AIM_RATE = 20 -- Hz: how often the aim updates (was 30)

-- If you put your NPC models inside workspace.NPCs (recommended), set this to "NPCs".
-- If nil or not found the script will scan workspace descendants (slower).
local NPC_FOLDER_NAME = "NPCs" -- set to nil to scan whole workspace (not recommended for big games)

-- State
local enabled = false
local lockValue = DEFAULT_LOCK
local rangeValue = DEFAULT_RANGE
local TOGGLE_KEY = DEFAULT_KEY
local listeningForKey = false

-- NPC cache
local npcCache = {}
local lastNpcRefresh = 0

-- Helper: clamp
local function clamp(v, a, b)
    if v < a then return a end
    if v > b then return b end
    return v
end

-- Is this model a player character?
local function isPlayerCharacter(model)
    if not model then return false end
    return Players:GetPlayerFromCharacter(model) ~= nil
end

-- Rebuild npc cache (runs infrequently)
local function rebuildNpcCache()
    local newCache = {}
    local searchRoot = workspace
    if NPC_FOLDER_NAME and workspace:FindFirstChild(NPC_FOLDER_NAME) then
        searchRoot = workspace:FindFirstChild(NPC_FOLDER_NAME)
    end

    -- If the searchRoot is the folder, iterate its children (faster) otherwise use GetDescendants
    if searchRoot == workspace then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                if not isPlayerCharacter(obj) and obj ~= player.Character then
                    table.insert(newCache, obj)
                end
            end
        end
    else
        for _, obj in ipairs(searchRoot:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                if not isPlayerCharacter(obj) and obj ~= player.Character then
                    table.insert(newCache, obj)
                end
            end
        end
    end

    npcCache = newCache
end

-- GUI creation (single-file, modern look)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimbotGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 360, 0, 180)
main.Position = UDim2.new(0, 20, 0, 120)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
main.BorderSizePixel = 0
main.AnchorPoint = Vector2.new(0,0)
main.Parent = screenGui
main.ClipsDescendants = true

local uICorner = Instance.new("UICorner")
uICorner.CornerRadius = UDim.new(0, 12)
uICorner.Parent = main

-- Topbar (draggable)
local topbar = Instance.new("Frame")
topbar.Name = "Topbar"
topbar.Size = UDim2.new(1, 0, 0, 36)
topbar.BackgroundTransparency = 1
topbar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 1, 0)
title.Position = UDim2.new(0, 6, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Aimbot — NPC Edition"
title.TextColor3 = Color3.fromRGB(240,240,240)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topbar

-- Draggable behavior
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Row helper
local function newRow(y)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -12, 0, 40)
    row.Position = UDim2.new(0, 6, 0, 36 + (y-1) * 42)
    row.BackgroundTransparency = 1
    row.Parent = main
    return row
end

-- Aimbot Toggle area
local row1 = newRow(1)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 180, 1, 0)
toggleBtn.Position = UDim2.new(0, 0, 0, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(28,28,30)
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = true
toggleBtn.Text = "Aimbot: OFF"
toggleBtn.Font = Enum.Font.GothamSemibold
toggleBtn.TextSize = 14
toggleBtn.TextColor3 = Color3.fromRGB(220,220,220)
toggleBtn.Parent = row1
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0,8)
btnCorner.Parent = toggleBtn

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(0, 140, 1, 0)
keyLabel.Position = UDim2.new(1, -150, 0, 0)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = string.format("key: %s", tostring(TOGGLE_KEY):gsub("Enum.KeyCode.",""))
keyLabel.Font = Enum.Font.Gotham
keyLabel.TextSize = 12
keyLabel.TextColor3 = Color3.fromRGB(180,180,180)
keyLabel.TextXAlignment = Enum.TextXAlignment.Right
keyLabel.Parent = row1

local changeKeyBtn = Instance.new("TextButton")
changeKeyBtn.Size = UDim2.new(0, 80, 1, 0)
changeKeyBtn.Position = UDim2.new(0, 190, 0, 0)
changeKeyBtn.BackgroundColor3 = Color3.fromRGB(36,36,38)
changeKeyBtn.Text = "Change Key"
changeKeyBtn.Font = Enum.Font.Gotham
changeKeyBtn.TextSize = 12
changeKeyBtn.TextColor3 = Color3.fromRGB(220,220,220)
changeKeyBtn.Parent = row1
local ckCorner = Instance.new("UICorner")
ckCorner.CornerRadius = UDim.new(0,8)
ckCorner.Parent = changeKeyBtn

local listeningLabel = Instance.new("TextLabel")
listeningLabel.Size = UDim2.new(0, 120, 1, 0)
listeningLabel.Position = UDim2.new(0, 280, 0, 0)
listeningLabel.BackgroundTransparency = 1
listeningLabel.Text = ""
listeningLabel.Font = Enum.Font.Gotham
listeningLabel.TextSize = 12
listeningLabel.TextColor3 = Color3.fromRGB(200,80,80)
listeningLabel.Parent = row1

-- Generic slider builder (visual slider with draggable thumb + textbox)
local function createSlider(parent, labelText, min, max, default)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 130, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(200,200,200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(0, 170, 0, 10)
    sliderBar.Position = UDim2.new(0, 140, 0, 15)
    sliderBar.BackgroundColor3 = Color3.fromRGB(48,48,50)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = container
    local barCorner = Instance.new("UICorner")
    barCorner.Parent = sliderBar

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 14, 0, 18)
    thumb.Position = UDim2.new(1, -7, 0, -4)
    thumb.BackgroundColor3 = Color3.fromRGB(170,170,170)
    thumb.Parent = sliderBar
    local tCorner = Instance.new("UICorner")
    tCorner.Parent = thumb

    local valueBox = Instance.new("TextBox")
    valueBox.Size = UDim2.new(0, 64, 0, 22)
    valueBox.Position = UDim2.new(1, -74, 0, 9)
    valueBox.Text = tostring(default)
    valueBox.ClearTextOnFocus = false
    valueBox.Font = Enum.Font.Gotham
    valueBox.TextSize = 12
    valueBox.TextColor3 = Color3.fromRGB(10,10,10)
    valueBox.BackgroundColor3 = Color3.fromRGB(230,230,230)
    valueBox.Parent = container
    local vbCorner = Instance.new("UICorner")
    vbCorner.Parent = valueBox

    -- compute position from value
    local function setValue(v)
        v = clamp(math.floor(v+0.5), min, max)
        valueBox.Text = tostring(v)
        local alpha = (v - min) / math.max(1, max - min)
        thumb.Position = UDim2.new(alpha, -7, 0, -4)
        return v
    end

    -- drag logic
    local dragging = false
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local function onMove(move)
                if move.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                    local absPos = move.Position.x
                    local barPos = sliderBar.AbsolutePosition.X
                    local barSize = sliderBar.AbsoluteSize.X
                    local rel = clamp((absPos - barPos) / math.max(1, barSize), 0, 1)
                    local newVal = min + rel * (max - min)
                    setValue(newVal)
                end
            end
            local moveConn
            moveConn = UserInputService.InputChanged:Connect(onMove)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if moveConn then moveConn:Disconnect() end
                end
            end)
        end
    end)

    -- textbox input handling & limit
    valueBox.FocusLost:Connect(function(enterPressed)
        local n = tonumber(valueBox.Text)
        if not n then
            valueBox.Text = tostring(default)
            return
        end
        n = clamp(math.floor(n+0.5), min, max)
        valueBox.Text = tostring(n)
    end)

    -- initialize
    setValue(default)

    return {
        Container = container,
        SetValue = setValue,
        GetValue = function()
            return tonumber(valueBox.Text) or default
        end,
        ValueBox = valueBox
    }
end

-- Lock strength slider (0..100)
local row2 = newRow(2)
local lockSlider = createSlider(row2, "Lock-on Strength", 0, MAX_LOCK, DEFAULT_LOCK)
lockSlider.Container.Parent = row2

-- Range slider (0..1000)
local row3 = newRow(3)
local rangeSlider = createSlider(row3, "Aimbot Range (studs)", 0, MAX_RANGE, DEFAULT_RANGE)
rangeSlider.Container.Parent = row3

-- Wire up toggle button
local function updateToggleUI()
    toggleBtn.Text = "Aimbot: " .. (enabled and "ON" or "OFF")
    if enabled then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40,120,255)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(28,28,30)
    end
    keyLabel.Text = string.format("key: %s", tostring(TOGGLE_KEY):gsub("Enum.KeyCode.",""))
end

toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    updateToggleUI()
end)

-- Keybind changing logic
changeKeyBtn.MouseButton1Click:Connect(function()
    listeningForKey = true
    listeningLabel.Text = "Press any key..."
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gp)
        if input.UserInputType == Enum.UserInputType.Keyboard and listeningForKey then
            TOGGLE_KEY = input.KeyCode
            listeningForKey = false
            listeningLabel.Text = ""
            updateToggleUI()
            conn:Disconnect()
        end
    end)
end)

-- Keybind to toggle (global)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if listeningForKey then return end -- don't toggle while setting key
    if input.KeyCode == TOGGLE_KEY and not gameProcessed then
        enabled = not enabled
        updateToggleUI()
    end
end)

-- Efficient nearest search: early reject by squared distance
local function findNearestNPC(origin, maxRange)
    local nearest, nearestDistSq = nil, maxRange * maxRange + 1
    local originV3 = origin
    for _, model in ipairs(npcCache) do
        if model and model.Parent then
            local hrp = model:FindFirstChild("HumanoidRootPart")
            local hum = model:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dSq = (hrp.Position - originV3).Magnitude ^ 2
                if dSq <= maxRange * maxRange and dSq < nearestDistSq then
                    nearest = hrp
                    nearestDistSq = dSq
                end
            end
        end
    end
    return nearest
end

-- Main aim loop (throttled)
local aimAccumulator = 0
local aimInterval = 1 / math.max(1, AIM_RATE)

-- initial cache build
rebuildNpcCache()
lastNpcRefresh = tick()

local heartbeatConn
heartbeatConn = RunService.RenderStepped:Connect(function(dt)
    -- refresh slider values
    lockValue = clamp(lockSlider.GetValue(), 0, MAX_LOCK)
    rangeValue = clamp(rangeSlider.GetValue(), 0, MAX_RANGE)

    -- refresh NPC cache occasionally (expensive operation done infrequently)
    local now = tick()
    if now - lastNpcRefresh >= NPC_REFRESH_INTERVAL then
        rebuildNpcCache()
        lastNpcRefresh = now
    end

    if not enabled then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    aimAccumulator = aimAccumulator + dt
    if aimAccumulator < aimInterval then return end
    aimAccumulator = aimAccumulator - aimInterval

    local origin = player.Character.HumanoidRootPart.Position
    local target = findNearestNPC(origin, rangeValue)
    if not target then return end

    -- compute smoothing factor (higher lockValue = slower)
    local alpha = 1 - (lockValue / MAX_LOCK)
    alpha = clamp(alpha, 0.02, 1)

    -- aim camera towards target smoothly
    local camPos = camera.CFrame.Position
    local toTarget = target.Position - camPos
    local dir = toTarget.Unit
    -- Only update if target direction changed noticeably
    local dot = camera.CFrame.LookVector:Dot(dir)
    if dot < 0.999999 then
        local goalCFrame = CFrame.new(camPos, target.Position)
        camera.CFrame = camera.CFrame:Lerp(goalCFrame, alpha)
    end
end)

-- Cleanup on character removing
player.CharacterRemoving:Connect(function()
    -- nothing special needed; connections persist until local player leaves
end)

-- Finalize UI defaults
updateToggleUI()

print("Aimbot GUI loaded. Toggle key: ", tostring(TOGGLE_KEY))

]]
