local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau",true))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local PickpocketGui = PlayerGui:WaitForChild("PickpocketGui")
local RootContainer = PickpocketGui:WaitForChild("Root"):WaitForChild("Container")

local Arrow = RootContainer:WaitForChild("ArrowIndicator")
local ProgressBar = RootContainer:WaitForChild("ProgressBar")

local function getPickButton()
  local mobileButton=RootContainer.KeyHint.MobileConsoleButton
  if mobileButton.Visible~=false then return mobileButton end

  local pcButton = RootContainer.KeyHint.PCButton
  return pcButton
end

local TapButton=getPickButton()

-- Store ProgressBar zones and their position bounds
local ProgressZones = {}
local ZoneCheckConnection = nil

-- Function to get all ProgressBar child zones and their X positions
local function LoadProgressZones()
    ProgressZones = {}
    for _, Zone in ipairs(ProgressBar:GetChildren()) do
        if Zone.Name:match("GreenZone") then -- Include all GreenZone elements
            local ZoneGui = Zone:IsA("GuiObject") and Zone or Zone:FindFirstChildWhichIsA("GuiObject")
            if ZoneGui then
                -- Calculate absolute X position bounds of the zone
                local AbsoluteLeft = ZoneGui.AbsolutePosition.X
                local AbsoluteRight = AbsoluteLeft + ZoneGui.AbsoluteSize.X
                table.insert(ProgressZones, {
                    MinX = AbsoluteLeft,
                    MaxX = AbsoluteRight,
                    ZoneObject = ZoneGui
                })
            end
        end
    end
end

-- Function to check if Arrow is within any ProgressZone
local function IsArrowInZone()
    local ArrowAbsoluteX = Arrow.AbsolutePosition.X + (Arrow.AbsoluteSize.X / 2) -- Use center of Arrow for accuracy
    for _, Zone in ipairs(ProgressZones) do
        if Zone and ArrowAbsoluteX >= Zone.MinX and ArrowAbsoluteX <= Zone.MaxX and Zone.ZoneObject.Visible then
            return true
        end
    end
    return false
end

local PocketEnabled = false

-- Main loop function
local function RunPickpocketTracker()
    -- Only proceed if GUI is enabled
    if not PickpocketGui.Enabled then return end
    if not PocketEnabled then return end
    
    
    -- Check Arrow position and trigger button if aligned
    if IsArrowInZone() then
        print("click pickpocket")
    
        -- Fire the button's Activated signal
        firesignal(TapButton.Activated) -- Native method to trigger button press
    end
end

-- Start/Stop tracker based on PickpocketGui.Enabled state
local function UpdateTrackerState()
    if not PocketEnabled then return end
    if PickpocketGui.Enabled then
        -- Refresh zone positions (in case UI scales/moves)
        LoadProgressZones()
        
        -- Start loop if not already running
        if not ZoneCheckConnection then
           -- ZoneCheckConnection = RunService.RenderStepped:Connect(RunPickpocketTracker)
        end
    else
        -- Stop loop if GUI is disabled
        if ZoneCheckConnection then
            ZoneCheckConnection:Disconnect()
            ZoneCheckConnection = nil
        end
    end
end

-- Initial setup and state monitoring
UpdateTrackerState()
local enabledCon=PickpocketGui:GetPropertyChangedSignal("Enabled"):Connect(UpdateTrackerState)

local arrowCon=Arrow:GetPropertyChangedSignal("AbsolutePosition"):Connect(RunPickpocketTracker)

-- Also refresh zones if ProgressBar changes size/position
local absPosCon=ProgressBar:GetPropertyChangedSignal("AbsolutePosition"):Connect(LoadProgressZones)
local abSizeCon=ProgressBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(LoadProgressZones)

local Window = UI:CreateWindow({Name="Pickpocket",Destroying=function()
      enabledCon:Disconnect()
      absPosCon:Disconnect()
      abSizeCon:Disconnect()
      PocketEnabled=false
      arrowCon:Disconnect()
      -- Stop loop if GUI is disabled
     if ZoneCheckConnection then
            ZoneCheckConnection:Disconnect()
            ZoneCheckConnection = nil
      end
end})

Window:AddToggle("Auto Pick Pocket",false,function(value)
   PocketEnabled=value
   if not value then
       -- Stop loop if GUI is disabled
        if ZoneCheckConnection then
            ZoneCheckConnection:Disconnect()
            ZoneCheckConnection = nil
        end
   else
      UpdateTrackerState()
   end
end)
