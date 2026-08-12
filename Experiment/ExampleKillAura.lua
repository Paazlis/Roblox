if true then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

local HitR = nil
local function findHitRemote()
    local function search(obj)
        for _, child in pairs(obj:GetChildren()) do
            if child:IsA("RemoteFunction") or child:IsA("RemoteEvent") then
                if child.Name == "Hit" then
                    return child
                end
            end
            local found = search(child)
            if found then return found end
        end
        return nil
    end
    HitR = search(ReplicatedStorage)
    if not HitR then
        local combat = ReplicatedStorage:FindFirstChild("Packages")
        if combat then combat = combat:FindFirstChild("Knit") end
        if combat then combat = combat:FindFirstChild("Services") end
        if combat then combat = combat:FindFirstChild("CombatService") end
        if combat then
            local rf = combat:FindFirstChild("RF")
            if rf then HitR = rf:FindFirstChild("Hit") end
        end
    end
end
findHitRemote()

local DATA_FILE = "aurakill_data.json"
local SAVE = {safeList = "", targetList = ""}

local function loadData()
    pcall(function()
        if writefile and isfile(DATA_FILE) then
            local data = HttpService:JSONDecode(readfile(DATA_FILE))
            if data and type(data) == "table" then
                SAVE.safeList = data.safeList or ""
                SAVE.targetList = data.targetList or ""
            end
        end
    end)
end

local function saveData()
    pcall(function()
        if writefile then
            writefile(DATA_FILE, HttpService:JSONEncode({safeList = SAVE.safeList, targetList = SAVE.targetList}))
        end
    end)
end

loadData()

local gui = Instance.new("ScreenGui")
gui.Name = "AuraKill"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 340)
main.Position = UDim2.new(0.5, -150, 0.5, -170)
main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
main.BackgroundTransparency = 0.12
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local glow = Instance.new("Frame")
glow.Size = UDim2.new(1, 8, 1, 8)
glow.Position = UDim2.new(0, -4, 0, -4)
glow.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
glow.BackgroundTransparency = 0.8
glow.BorderSizePixel = 0
glow.Parent = main
Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 16)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
titleBar.BackgroundTransparency = 0.3
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.6, 0, 0, 22)
titleText.Position = UDim2.new(0, 12, 0, 2)
titleText.BackgroundTransparency = 1
titleText.Text = "AURA KILL"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local madeBy = Instance.new("TextLabel")
madeBy.Size = UDim2.new(0.6, 0, 0, 12)
madeBy.Position = UDim2.new(0, 12, 0, 24)
madeBy.BackgroundTransparency = 1
madeBy.Text = "Made By LEGEND"
madeBy.TextColor3 = Color3.fromRGB(150, 150, 170)
madeBy.Font = Enum.Font.Gotham
madeBy.TextSize = 8
madeBy.TextXAlignment = Enum.TextXAlignment.Left
madeBy.Parent = titleBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -56, 0.5, -12)
minBtn.Text = "−"
minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
minBtn.BackgroundTransparency = 0.3
minBtn.TextColor3 = Color3.fromRGB(160, 150, 180)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 12
minBtn.BorderSizePixel = 0
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0.5, -12)
closeBtn.Text = "✕"
closeBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 30)
closeBtn.BackgroundTransparency = 0.3
closeBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
closeBtn.MouseButton1Click:Connect(function()
    if conn then conn:Disconnect() end
    saveData()
    gui:Destroy()
end)

local drag = {dragging = false, start = nil, pos = nil, glowPos = nil}
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        drag.dragging = true
        drag.start = input.Position
        drag.pos = main.Position
        drag.glowPos = glow.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if drag.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - drag.start
        main.Position = UDim2.new(drag.pos.X.Scale, drag.pos.X.Offset + d.X, drag.pos.Y.Scale, drag.pos.Y.Offset + d.Y)
        glow.Position = UDim2.new(drag.glowPos.X.Scale, drag.glowPos.X.Offset + d.X, drag.glowPos.Y.Scale, drag.glowPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        drag.dragging = false
    end
end)

local isMinimized = false
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 300, 0, 38)}):Play()
        minBtn.Text = "+"
        for _, child in pairs(main:GetChildren()) do
            if child ~= titleBar and child ~= glow then
                child.Visible = false
            end
        end
    else
        TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 300, 0, 340)}):Play()
        minBtn.Text = "−"
        for _, child in pairs(main:GetChildren()) do
            if child ~= titleBar and child ~= glow then
                child.Visible = true
            end
        end
    end
end)

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -12, 1, -46)
content.Position = UDim2.new(0, 6, 0, 42)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 2
content.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 150)
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = main

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 4)
contentLayout.Parent = content

local togFrame = Instance.new("Frame")
togFrame.Size = UDim2.new(1, 0, 0, 42)
togFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
togFrame.BackgroundTransparency = 0.3
togFrame.BorderSizePixel = 0
togFrame.Parent = content
Instance.new("UICorner", togFrame).CornerRadius = UDim.new(0, 6)

local togLabel = Instance.new("TextLabel")
togLabel.Size = UDim2.new(0.5, 0, 1, 0)
togLabel.Position = UDim2.new(0, 12, 0, 0)
togLabel.BackgroundTransparency = 1
togLabel.Text = "ON/OFF"
togLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
togLabel.Font = Enum.Font.GothamBold
togLabel.TextSize = 13
togLabel.TextXAlignment = Enum.TextXAlignment.Left
togLabel.Parent = togFrame

local togBtn = Instance.new("TextButton")
togBtn.Size = UDim2.new(0, 65, 0, 32)
togBtn.Position = UDim2.new(1, -75, 0.5, -16)
togBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
togBtn.BackgroundTransparency = 0.2
togBtn.Text = "OFF"
togBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
togBtn.Font = Enum.Font.GothamBold
togBtn.TextSize = 13
togBtn.BorderSizePixel = 0
togBtn.Parent = togFrame
Instance.new("UICorner", togBtn).CornerRadius = UDim.new(1, 0)

local safeFrame = Instance.new("Frame")
safeFrame.Size = UDim2.new(1, 0, 0, 32)
safeFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
safeFrame.BackgroundTransparency = 0.3
safeFrame.BorderSizePixel = 0
safeFrame.Parent = content
Instance.new("UICorner", safeFrame).CornerRadius = UDim.new(0, 6)

local safeLabel = Instance.new("TextLabel")
safeLabel.Size = UDim2.new(0.35, 0, 1, 0)
safeLabel.Position = UDim2.new(0, 10, 0, 0)
safeLabel.BackgroundTransparency = 1
safeLabel.Text = "SAFELIST"
safeLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
safeLabel.Font = Enum.Font.GothamBold
safeLabel.TextSize = 9
safeLabel.TextXAlignment = Enum.TextXAlignment.Left
safeLabel.Parent = safeFrame

local safeBox = Instance.new("TextBox")
safeBox.Size = UDim2.new(0.6, 0, 0, 22)
safeBox.Position = UDim2.new(0.38, 0, 0.5, -11)
safeBox.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
safeBox.BackgroundTransparency = 0.2
safeBox.Text = SAVE.safeList
safeBox.PlaceholderText = "names (space separated)"
safeBox.TextColor3 = Color3.fromRGB(220, 220, 230)
safeBox.Font = Enum.Font.Gotham
safeBox.TextSize = 8
safeBox.BorderSizePixel = 0
safeBox.ClearTextOnFocus = false
safeBox.Parent = safeFrame
Instance.new("UICorner", safeBox).CornerRadius = UDim.new(0, 4)

local targetFrame = Instance.new("Frame")
targetFrame.Size = UDim2.new(1, 0, 0, 32)
targetFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
targetFrame.BackgroundTransparency = 0.3
targetFrame.BorderSizePixel = 0
targetFrame.Parent = content
Instance.new("UICorner", targetFrame).CornerRadius = UDim.new(0, 6)

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(0.35, 0, 1, 0)
targetLabel.Position = UDim2.new(0, 10, 0, 0)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "TARGET LIST"
targetLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
targetLabel.Font = Enum.Font.GothamBold
targetLabel.TextSize = 9
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.Parent = targetFrame

local targetBox = Instance.new("TextBox")
targetBox.Size = UDim2.new(0.6, 0, 0, 22)
targetBox.Position = UDim2.new(0.38, 0, 0.5, -11)
targetBox.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
targetBox.BackgroundTransparency = 0.2
targetBox.Text = SAVE.targetList
targetBox.PlaceholderText = "names (space separated)"
targetBox.TextColor3 = Color3.fromRGB(220, 220, 230)
targetBox.Font = Enum.Font.Gotham
targetBox.TextSize = 8
targetBox.BorderSizePixel = 0
targetBox.ClearTextOnFocus = false
targetBox.Parent = targetFrame
Instance.new("UICorner", targetBox).CornerRadius = UDim.new(0, 4)

local rangeFrame = Instance.new("Frame")
rangeFrame.Size = UDim2.new(1, 0, 0, 44)
rangeFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
rangeFrame.BackgroundTransparency = 0.3
rangeFrame.BorderSizePixel = 0
rangeFrame.Parent = content
Instance.new("UICorner", rangeFrame).CornerRadius = UDim.new(0, 6)

local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(0.5, 0, 0, 16)
rangeLabel.Position = UDim2.new(0, 10, 0, 2)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Text = "RANGE"
rangeLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.TextSize = 8
rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
rangeLabel.Parent = rangeFrame

local rangeVal = Instance.new("TextLabel")
rangeVal.Size = UDim2.new(0.3, 0, 0, 16)
rangeVal.Position = UDim2.new(0.68, 0, 0, 2)
rangeVal.BackgroundTransparency = 1
rangeVal.Text = "50"
rangeVal.TextColor3 = Color3.fromRGB(255, 50, 150)
rangeVal.Font = Enum.Font.GothamBold
rangeVal.TextSize = 8
rangeVal.TextXAlignment = Enum.TextXAlignment.Right
rangeVal.Parent = rangeFrame

local rangeTrack = Instance.new("Frame")
rangeTrack.Size = UDim2.new(0.9, 0, 0, 3)
rangeTrack.Position = UDim2.new(0.05, 0, 0.75, 0)
rangeTrack.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
rangeTrack.BorderSizePixel = 0
rangeTrack.Parent = rangeFrame
Instance.new("UICorner", rangeTrack).CornerRadius = UDim.new(1, 0)

local rangeFill = Instance.new("Frame")
rangeFill.Size = UDim2.new(1, 0, 1, 0)
rangeFill.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
rangeFill.BorderSizePixel = 0
rangeFill.Parent = rangeTrack
Instance.new("UICorner", rangeFill).CornerRadius = UDim.new(1, 0)

local rangeThumb = Instance.new("Frame")
rangeThumb.Size = UDim2.new(0, 10, 0, 10)
rangeThumb.Position = UDim2.new(1, -5, 0.5, -5)
rangeThumb.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
rangeThumb.BorderSizePixel = 0
rangeThumb.Parent = rangeTrack
Instance.new("UICorner", rangeThumb).CornerRadius = UDim.new(1, 0)

local rangeValue = 50
local rangeDragging = false
local function updateRange(pos)
    local aw = rangeTrack.AbsoluteSize.X
    if aw <= 0 then return end
    local p = math.clamp((pos.X - rangeTrack.AbsolutePosition.X) / aw, 0, 1)
    local v = math.floor(1 + p * 49)
    rangeFill.Size = UDim2.new(p, 0, 1, 0)
    rangeThumb.Position = UDim2.new(p, -5, 0.5, -5)
    rangeVal.Text = tostring(v)
    rangeValue = v
end

rangeTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        rangeDragging = true
        updateRange(input.Position)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if rangeDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateRange(input.Position)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        rangeDragging = false
    end
end)

local apsFrame = Instance.new("Frame")
apsFrame.Size = UDim2.new(1, 0, 0, 44)
apsFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
apsFrame.BackgroundTransparency = 0.3
apsFrame.BorderSizePixel = 0
apsFrame.Parent = content
Instance.new("UICorner", apsFrame).CornerRadius = UDim.new(0, 6)

local apsLabel = Instance.new("TextLabel")
apsLabel.Size = UDim2.new(0.5, 0, 0, 16)
apsLabel.Position = UDim2.new(0, 10, 0, 2)
apsLabel.BackgroundTransparency = 1
apsLabel.Text = "APS"
apsLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
apsLabel.Font = Enum.Font.Gotham
apsLabel.TextSize = 8
apsLabel.TextXAlignment = Enum.TextXAlignment.Left
apsLabel.Parent = apsFrame

local apsVal = Instance.new("TextLabel")
apsVal.Size = UDim2.new(0.3, 0, 0, 16)
apsVal.Position = UDim2.new(0.68, 0, 0, 2)
apsVal.BackgroundTransparency = 1
apsVal.Text = "10000"
apsVal.TextColor3 = Color3.fromRGB(255, 50, 150)
apsVal.Font = Enum.Font.GothamBold
apsVal.TextSize = 8
apsVal.TextXAlignment = Enum.TextXAlignment.Right
apsVal.Parent = apsFrame

local apsTrack = Instance.new("Frame")
apsTrack.Size = UDim2.new(0.9, 0, 0, 3)
apsTrack.Position = UDim2.new(0.05, 0, 0.75, 0)
apsTrack.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
apsTrack.BorderSizePixel = 0
apsTrack.Parent = apsFrame
Instance.new("UICorner", apsTrack).CornerRadius = UDim.new(1, 0)

local apsFill = Instance.new("Frame")
apsFill.Size = UDim2.new(1, 0, 1, 0)
apsFill.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
apsFill.BorderSizePixel = 0
apsFill.Parent = apsTrack
Instance.new("UICorner", apsFill).CornerRadius = UDim.new(1, 0)

local apsThumb = Instance.new("Frame")
apsThumb.Size = UDim2.new(0, 10, 0, 10)
apsThumb.Position = UDim2.new(1, -5, 0.5, -5)
apsThumb.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
apsThumb.BorderSizePixel = 0
apsThumb.Parent = apsTrack
Instance.new("UICorner", apsThumb).CornerRadius = UDim.new(1, 0)

local apsValue = 10000
local apsDragging = false
local function updateAps(pos)
    local aw = apsTrack.AbsoluteSize.X
    if aw <= 0 then return end
    local p = math.clamp((pos.X - apsTrack.AbsolutePosition.X) / aw, 0, 1)
    local v = math.floor(1 + p * 9999)
    apsFill.Size = UDim2.new(p, 0, 1, 0)
    apsThumb.Position = UDim2.new(p, -5, 0.5, -5)
    apsVal.Text = tostring(v)
    apsValue = v
end

apsTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        apsDragging = true
        updateAps(input.Position)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if apsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateAps(input.Position)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        apsDragging = false
    end
end)

local enabled = false
local conn = nil

local function isSafe(name)
    local lowerName = name:lower()
    for s in safeBox.Text:gmatch("%S+") do
        if lowerName:find(s:lower(), 1, true) then
            return true
        end
    end
    return false
end

local function isTarget(name)
    local text = targetBox.Text:lower():gsub("^%s*(.-)%s*$", "%1")

    if text == "" or text == "all" then
        return true
    end

    local lowerName = name:lower()
    for t in text:gmatch("%S+") do
        if lowerName:find(t, 1, true) then
            return true
        end
    end
    return false
end

local function doHit(hum, pos)
    if not hum or not hum.Parent then return end
    if HitR then
        pcall(function()
            HitR:InvokeServer(hum, Vector3.new(pos.X, pos.Y, pos.Z))
        end)
    end
end

togBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        togBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        togBtn.Text = "ON"
        if conn then conn:Disconnect() end
        conn = RunService.Heartbeat:Connect(function()
            if not enabled then return end
            local ch = lp.Character
            if not ch then return end
            local myhrp = ch:FindFirstChild("HumanoidRootPart")
            if not myhrp then return end
            
            local nearest = nil
            local nearDist = math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p == lp or not p.Character then continue end
                if isSafe(p.Name) then continue end
                if not isTarget(p.Name) then continue end
                
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                
                if hrp and hum and hum.Health > 0 then
                    local dist = (hrp.Position - myhrp.Position).Magnitude
                    if dist <= rangeValue and dist < nearDist then
                        nearDist = dist
                        nearest = {hum = hum, pos = hrp.Position + hrp.CFrame.LookVector * 2}
                    end
                end
            end
            
            if nearest then
                task.spawn(function()
                    doHit(nearest.hum, nearest.pos)
                end)
            end
        end)
    else
        togBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        togBtn.Text = "OFF"
        if conn then
            conn:Disconnect()
            conn = nil
        end
    end
end)

safeBox.FocusLost:Connect(function()
    SAVE.safeList = safeBox.Text
    saveData()
end)

targetBox.FocusLost:Connect(function()
    SAVE.targetList = targetBox.Text
    saveData()
end)
safeBox.Text = SAVE.safeList
targetBox.Text = SAVE.targetList

print("AURA KILL LOADED - Made By LEGEND")
