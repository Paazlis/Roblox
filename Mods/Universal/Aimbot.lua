-- Load UI Library
local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau", true))()
local Window = UI:CreateWindow("Aimbot Pro")

-- Aimbot Variables
local AimbotSettings = {
    Enabled = false,
    TargetPart = "Head", -- Target body part
    Smoothness = 5, -- Camera movement smoothness (higher = slower)
    TeamCheck = true, -- Don't shoot teammates
    WallCheck = true -- Ignore targets blocked by walls/objects
}

-- Get core services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Function to check if line of sight is clear (wall check)
local function IsTargetVisible(targetPart)
    if not AimbotSettings.WallCheck then return true end -- Skip check if disabled

    -- Raycast parameters to ignore local player and camera
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.IgnoreWater = true

    -- Cast ray from camera to target part
    local rayResult = Workspace:Raycast(
        Camera.CFrame.Position,
        (targetPart.Position - Camera.CFrame.Position).Unit * (targetPart.Position - Camera.CFrame.Position).Magnitude,
        rayParams
    )

    -- Return true only if ray hits the target part (no walls in between)
    return rayResult and rayResult.Instance == targetPart
end

-- Function to find closest valid target (no distance limit)
local function FindClosestTarget()
    local ClosestPlayer = nil
    local ClosestDistance = math.huge
    local MousePosition = Camera.ViewportSize / 2 -- Screen center

    for _, Player in ipairs(Players:GetPlayers()) do
        -- Skip self and teammates if TeamCheck is active
        if Player ~= LocalPlayer and (not AimbotSettings.TeamCheck or Player.Team ~= LocalPlayer.Team) then
            local Character = Player.Character
            if Character and Character:FindFirstChild(AimbotSettings.TargetPart) and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
                local TargetPart = Character[AimbotSettings.TargetPart]
                
                -- Check if target is visible on screen and has clear line of sight
                local ScreenPosition, IsOnScreen = Camera:WorldToScreenPoint(TargetPart.Position)
                if IsOnScreen and IsTargetVisible(TargetPart) then
                    -- Calculate distance from screen center (no world distance cap)
                    local DistanceFromCenter = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - MousePosition).Magnitude

                    -- Select closest target based on screen center distance
                    if DistanceFromCenter < ClosestDistance then
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
    Text = "Auto Aimbot",
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
    Callback = function(option)
        AimbotSettings.TargetPart = option[1]
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
    Text = "Team Check",
    Value = true,
    Flag = "team_check",
    Callback = function(value)
        AimbotSettings.TeamCheck = value
    end
})

-- Toggle for wall check
Window:AddToggle({
    Text = "Wall Check",
    Value = true,
    Flag = "wall_check",
    Callback = function(value)
        AimbotSettings.WallCheck = value
    end
})
