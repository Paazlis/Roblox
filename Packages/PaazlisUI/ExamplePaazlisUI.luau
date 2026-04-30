local Players=game:GetService('Players')

local LocalPlayer=Players.LocalPlayer
local SeverHopEnd=false

local ServerHopModule = loadstring(game:HttpGet"https://raw.githubusercontent.com/LeoKholYt/roblox/main/lk_serverhop.lua")()
local UI=loadstring(game:HttpGet('https://raw.githubusercontent.com/PaazlisMaswa/RobloxProject/refs/heads/main/Packages/PaazlisUI/init.luau'))()

local Window=UI:CreateWindow({
	Title='Panel',
})

local LocalDropdown=Window:AddContext({Type='Dropdown',Name='Local',Active=false})

local ServerHopButton=Window:AddContext({Type='Button',Name='Server Hop',Callback=function()
     if not SeverHopEnd then
        SeverHopEnd=true
        task.spawn(function() ServerHopModule:Teleport(game.PlaceId) end)
        UI:Notify('Server Hop','Teleporting other server...',10)
     end
end})

ServerHopButton.Parent=LocalDropdown

local RejoirnButton=Window:AddContext({Type='Button',Name='Rejoin',Callback=function()
     
end})

RejoirnButton.Parent=LocalDropdown

local ResetButton=Window:AddContext({Type='Button',Name='Reset',Callback=function()
     local character=LocalPlayer.Character
     if character then
        local humanoid=character:FindFirstChildOfClass('Humanoid')
        if humanoid then humanoid.Health=0 humanoid.MaxHealth=0 end
     end
end})

ResetButton.Parent=LocalDropdown

UI:Notify('Panel','Panel Loaded',10)
