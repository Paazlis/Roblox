-- Load UI Library
local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

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
