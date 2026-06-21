-- [


-- $$$$$$$$\                   $$\      $$$$$$\  $$\ $$\           $$\       
-- $$  _____|                  $$ |    $$  __$$\ $$ |\__|          $$ |      
-- $$ |   $$$$$$\   $$$$$$$\ $$$$$$\   $$ /  \__|$$ |$$\  $$$$$$$\ $$ |  $$\ 
-- $$$$$\ \____$$\ $$  _____|\_$$  _|  $$ |      $$ |$$ |$$  _____|$$ | $$  |
-- $$  __|$$$$$$$ |\$$$$$$\    $$ |    $$ |      $$ |$$ |$$ /      $$$$$$  / 
-- $$ |  $$  __$$ | \____$$\   $$ |$$\ $$ |  $$\ $$ |$$ |$$ |      $$  _$$<  
-- $$ |  \$$$$$$$ |$$$$$$$  |  \$$$$  |\$$$$$$  |$$ |$$ |\$$$$$$$\ $$ | \$$\ 
-- \__|   \_______|\_______/    \____/  \______/ \__|\__| \_______|\__|  \__|
                                                                          
                           This was made by stav              


-- ]


local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

-- LOADING --
--local selectedTheme = "Sentinel"
--local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = UI:CreateWindow({Name="Auto Click"}) --Library.CreateLib("FastClick (By stav)", selectedTheme)

-- VARIABLES --
local Clicking = false
local ClickSpeed = 0.1

-- SERVICES --
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local mousePos = UserInputService:GetMouseLocation()

task.delay(1, function()
    mousePos = UserInputService:GetMouseLocation()
    print("apply position")
end)

-- AUTOCLICK FUNCTION --
task.spawn(function()
    while true do
        if Clicking then
            local mouseLocation = UserInputService:GetMouseLocation() - mousePos
            VirtualInputManager:SendMouseButtonEvent(mouseLocation.X, mouseLocation.Y, 0, true, game, 0)
            task.wait()
            VirtualInputManager:SendMouseButtonEvent(mouseLocation.X, mouseLocation.Y, 0, false, game, 0)
            task.wait(ClickSpeed)
        else
            task.wait()
        end
    end
end)

-- AUTOCLICKER SECTION --
Window:AddToggle({Name = "Auto Click", Callback = function(state)
    Clicking = state
end})

--[[
Basic:NewTextBox("AutoClicker Speed (s)", "Sets the speed of autoclicker", function(txt)
    local speed = tonumber(txt)
    if speed and speed > 0 then
        clickSpeed = speed
        print("Click speed set to " .. speed .. " seconds")
    else
        warn("Invalid speed input")
    end
end)


-- SETTINGS SECTION --
UI:NewKeybind("Toggle UI", "Sets the keybind to toggle UI", Enum.KeyCode.Insert, function()
    Library:ToggleUI()
end)
]]
