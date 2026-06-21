-- [


-- $$$$$$$$\                   $$\      $$$$$$\  $$\ $$\           $$\       
-- $$  _____|                  $$ |    $$  __$$\ $$ |\__|          $$ |      
-- $$ |   $$$$$$\   $$$$$$$\ $$$$$$\   $$ /  \__|$$ |$$\  $$$$$$$\ $$ |  $$\ 
-- $$$$$\ \____$$\ $$  _____|\_$$  _|  $$ |      $$ |$$ |$$  _____|$$ | $$  |
-- $$  __|$$$$$$$ |\$$$$$$\    $$ |    $$ |      $$ |$$ |$$ /      $$$$$$  / 
-- $$ |  $$  __$$ | \____$$\   $$ |$$\ $$ |  $$\ $$ |$$ |$$ |      $$  _$$<  
-- $$ |  \$$$$$$$ |$$$$$$$  |  \$$$$  |\$$$$$$  |$$ |$$ |\$$$$$$$\ $$ | \$$\ 
-- \__|   \_______|\_______/    \____/  \______/ \__|\__| \_______|\__|  \__|
                                                                          
--                         This was made by stav           


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

local location = UserInputService:GetMouseLocation()

local Status = Window:AddLabel({Name = "Location: -1, -1"})

task.delay(5, function()
    location = UserInputService:GetMouseLocation()
    Status:Set("Location: ".. tostring(location))
end)

Window:AddToggle({
    Name = "Auto Click", 
    Value = false,
    Callback = function(state)
       Clicking = state
    end
})

-- AUTOCLICK FUNCTION --
task.spawn(function()
    while true do
        if Clicking then
            VirtualInputManager:SendMouseButtonEvent(location.X, location.Y, 0, true, game, 0)
            task.wait()
            VirtualInputManager:SendMouseButtonEvent(location.X, location.Y, 0, false, game, 0)
            task.wait(ClickSpeed)
        else
            task.wait()
        end
    end
end)

Window:AddSlider({
    Name = "Click Speed",
    Range = {0.01, 10},
    Value = ClickSpeed,
    Callback = function(speed)
       ClickSpeed = speed
    end
})

Window:AddButton({
    Name = "Click Point",
    Callback = function(s)
       task.delay(2, function()
           location = UserInputService:GetMouseLocation()
           Status:Set("Location: ".. tostring(location))
       end)
    end
})

local Folder = Window:AddFolder({Name = "Creator", Open = true})
Folder:AddLabel({Name = "stav"})
Folder:AddLabel({Name = "Paazlis"})
