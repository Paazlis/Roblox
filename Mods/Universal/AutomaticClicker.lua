local Services=setmetatable({},{
	__index=function(_,i) 
		return cloneref and cloneref(game:GetService(i)) or game:GetService(i) 
	end
})

local UI=loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()
local RunService=Services.RunService
local UserInputService=Services.UserInputService
local VirtualInputManager=Services.VirtualInputManager

local function FastWait(duration)
	if not duration then return RunService.RenderStepped:Wait() end
	local start=tick()
	while tick()-start<duration do RunService.RenderStepped:Wait() end
	return start-duration
end

local ClickSpeed=0.2
local AutoClickEnabled=false
local MouseLocation=nil

local ClickThread=task.defer(function()
   FastWait(1)
   MouseLocation=UserInputService:GetMouseLocation()
   while true do
      if AutoClickEnabled then
          FastWait(ClickSpeed)
          VirtualInputManager:SendMouseButtonEvent(MouseLocation.X,MouseLocation.Y,0,false,game,0)
      else
          FastWait(0.1)
      end
   end
end

local Window=UI:CreateWindow({Name="Void Clicker",Destroying=function() 
     task.cancel(ClickThread)
end})

Window:AddLabel({Name="Default = 0.2"})

Window:AddInput({Name="Click Speed",Callback=function(value)
     local speed=tonumber(value)
     if speed and speed>0 then
        ClickSpeed=speed
     end
end})
  
Window:AddToggle({Name="Auto Click",Callback=function(value)
     AutoClickEnabled=value
end})

Window:AddToggle({Name="Cursor Point",Callback=function(value)
     MouseLocation=UserInputService:GetMouseLocation()
end})
