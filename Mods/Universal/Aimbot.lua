-- Load UI Library
local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau", true))()
local Window = UI:CreateWindow("Aimbot Pro")

-- Aimbot Variables
local AimbotSettings = {
    Enabled = false,
    TargetPart = "Head", -- Target body part
    MaxDistance = 500, -- Maximum target distance
    Smoothness = 5, -- Camera movement smoothness (higher = slower)
    TeamCheck = true -- Don't shoot teammates
}

-- Get local player and camera
local LocalPlayer = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Function to find closest target
local function FindClosestTarget()
    local ClosestPlayer = nil
    local ClosestDistance = math.huge
    local MousePosition = Camera.ViewportSize / 2 -- Screen center

    for _, Player in ipairs(game:GetService("Players"):GetPlayers()) do
        -- Skip self and teammates if TeamCheck is active
        if Player ~= LocalPlayer and (not AimbotSettings.TeamCheck or Player.Team ~= LocalPlayer.Team) then
            local Character = Player.Character
            if Character and Character:FindFirstChild(AimbotSettings.TargetPart) and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
                -- Check if target part is visible from camera
                local ScreenPosition, IsVisible = Camera:WorldToScreenPoint(Character[AimbotSettings.TargetPart].Position)
                if IsVisible then
                    -- Calculate distance from screen center and world distance
                    local DistanceFromCenter = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - MousePosition).Magnitude
                    local WorldDistance = (Camera.CFrame.Position - Character[AimbotSettings.TargetPart].Position).Magnitude

                    -- Select closest target within maximum distance
                    if WorldDistance <= AimbotSettings.MaxDistance and DistanceFromCenter < ClosestDistance then
                        ClosestDistance = DistanceFromCenter
                        ClosestPlayer = Character
                    end
                end
            end
        end
    end

    return ClosestPlayer
end

-- Main aimbot function that runs every frame
local AimbotConnection
local function UpdateAimbot()
    if not AimbotSettings.Enabled then return end

    local Target = FindClosestTarget()
    if Target and Target:FindFirstChild(AimbotSettings.TargetPart) then
        -- Set camera to face target with smoothness
        local TargetPosition = Target[AimbotSettings.TargetPart].Position
        local CameraCFrame = Camera.CFrame
        local NewCFrame = CFrame.new(CameraCFrame.Position, TargetPosition)
        
        -- Apply smoothness
        Camera.CFrame = CameraCFrame:Lerp(NewCFrame, 1 / AimbotSettings.Smoothness)
    end
end

-- Create UI Elements directly in Window
-- Main toggle to enable aimbot
local AimbotToggle = Window:AddToggle({
    Text = "Enable Aimbot",
    Value = false,
    Flag = "aimbot_toggle",
    Callback = function(value)
        AimbotSettings.Enabled = value
        
        -- Connect or disconnect from RunService
        if value then
            if AimbotConnection then AimbotConnection:Disconnect() end
            AimbotConnection = RunService.RenderStepped:Connect(UpdateAimbot)
        else
            if AimbotConnection then AimbotConnection:Disconnect() end
        end
    end
})

-- Dropdown to select target body part
local TargetOptions = {"Head", "Torso", "HumanoidRootPart", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}
Window:AddDropdown({
    Text = "Target Part",
    Options = TargetOptions,
    Option = {"Head"},
    Flag = "target_part",
    Callback = function(option) -- Receives the selected value from the options array directly
        AimbotSettings.TargetPart = option[1]
    end
})

-- Slider for maximum distance (with Increment)
Window:AddSlider({
    Text = "Max Distance",
    Min = 100,
    Max = math.huge,
    Value = 500,
    Increment = 1, -- Adjusts value in 50-unit steps
    Flag = "max_distance",
    Callback = function(value)
        AimbotSettings.MaxDistance = value
        print("Maximum Distance: " .. value)
    end
})

-- Slider for camera smoothness (with Increment)
Window:AddSlider({
    Text = "Camera Smoothness",
    Min = 1,
    Max = 10,
    Value = 5,
    Increment = 1, -- Adjusts value in 1-unit steps
    Flag = "smoothness",
    Callback = function(value)
        AimbotSettings.Smoothness = value
    end
})

-- Toggle for team check
Window:AddToggle({
    Text = "UseTeam",
    Value = true,
    Flag = "team_check",
    Callback = function(value)
        AimbotSettings.TeamCheck = value
    end
})
