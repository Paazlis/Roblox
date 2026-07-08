local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local CashEnabled = false
local CashIndex = 0
local RebirthConnection = nil
local TrainTapConnection = nil

local function FindByPath(instance, array)
    local function Search(current, index)
		if not current then return nil end
		
        if index > #array then
            return current
        end

        local targetName = array[index]

        for _, child in ipairs(current:GetChildren()) do
            if child.Name == targetName then
                local result = Search(child, index + 1)
                
                if result then
                    return result
                end
			end
        end
        
        return nil
    end

    return Search(instance, 1)
end

-- Auto Rebirth --
--game:GetService("Players").LocalPlayer.PlayerGui["1"]["1"]["33"]["33"]["2"]["4"]["3"]["3"]["1"]
--game:GetService("Players").LocalPlayer.PlayerGui["1"]["1"]["33"]["33"]["2"]["4"]["3"]["4"]["2"]["2"]

-- Auto Tap --
-- game:GetService("Players").LocalPlayer.PlayerGui["1"]["1"]:GetChildren()[8]["1"]
-- game:GetService("Players").LocalPlayer.PlayerGui["1"]["1"]:GetChildren()[8]["1"]["1"]["3"]

local function FireButton(object)
   firesignal(object.Activated)
   firesignal(object.MouseButton1Click)
end

local Window = UI:CreateWindow({
	Name = "BE A FISH BAIT",
	Destroying = function()
	    CashEnabled = false
		if RebirthConnection then RebirthConnection:Disconnect() RebirthConnection = nil end
	    if TrainTapConnection then TrainTapConnection:Disconnect() TrainTapConnection = nil end
	end
})

Window:AddToggle({
	Text = "Auto Tap", 
	Value = false, 
	Callback = function(value)
		if TrainTapConnection then TrainTapConnection:Disconnect() TrainTapConnection = nil end
		if value then
			
		end
	end
})

Window:AddToggle({
	Text = "Collect Cash", 
	Value = false, 
	Callback = function(value)
		CashEnabled = value
		if value then
			task.spawn(function()
				while CashEnabled do
				   task.wait(2)
			       ReplicatedStorage["shared/network@globalFunctions"].collectPlotMoney:FireServer(CashIndex,tostring(LocalPlayer.UserId))
                   CashIndex += 1
				end
			end)
		end
	end
})

Window:AddToggle({
	Text = "Auto Rebirth", 
	Value = false, 
	Callback = function(value)
		if RebirthConnection then RebirthConnection:Disconnect() RebirthConnection = nil end
		if value then
		   local RebirthFrame = FindByPath(PlayerGui, {"1", "1", "33", "33", "2", "4", "3"})
           local RebirthFill = FindByPath(RebirthFrame, {"3", "1"})
           local RebirthButton = FindByPath(RebirthFrame, {"4", "2","2"})

		   print(RebirthFill:GetFullName(), RebirthFill.ClassName)

				
           RebirthConnection = RebirthFill:GetPropertyChangedSignal("Size"):Connect(function()
               if RebirthFill.Size.X.Scale >= 1 then
				  warn("rebirth")
                  FireButton(RebirthButton)
			   end
		   end)

		   print(RebirthButton:GetFullName(), RebirthButton.ClassName)
				
		   if RebirthFill.Size.X.Scale >= 1 then
			  warn("rebirth")
              FireButton(RebirthButton)
		   end
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
