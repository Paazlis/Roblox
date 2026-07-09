local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local RebirthEnabled = false
local SellConnection = nil

local function AutoSell()
   local sellLabel = PlayerGui.Main.Left.Backpack.Frame.TextLabel.Shadow
  
   SellConnection = sellLabel:GetPropertyChangedSignal("TextColor3"):Connect(function()
      if sellLabel.TextColor3 == Color3.fromRGB(255, 68, 68) then
         ReplicatedStorage.RemoteHandler.Sell:FireServer()
      end
   end)

   if sellLabel.TextColor3 == Color3.fromRGB(255, 68, 68) then
      ReplicatedStorage.RemoteHandler.Sell:FireServer()
   end
end

local function AutoRebirth()
   if not RebirthEnabled then return end
  
   task.spawn(function()
       while RebirthEnabled do
          task.wait(1)
          
          local maxRequire = 0
          local currentRequire = 0
          
          for _, item in ipairs(items:GetChildren()) do
             if item:IsA("Frame") and item.Visible then
                maxRequire += 1
            
                local completed = item:FindFirstChild("Completed")
                if completed and completed.Visible then
                   currentRequire += 1
                end
             end
          end

          if currentRequire >= maxRequire and PlayerGui.Main.Center.Rebirth.Main.Requirements.Cash.Fill.Size.X.Scale >= 1 and RebirthEnabled then
              ReplicatedStorage.RemoteHandler.Rebirth:FireServer()
          end
       end
   end)
end

local Window = UI:CreateWindow({
	Name = "Vacuum Simulator",
	Destroying = function()
	    RebirthEnabled = false
	    if SellConnection then SellConnection:Disconnect() SellConnection = nil end
	end
})

Window:AddToggle({
	Text = "Auto Sell", 
	Value = false, 
	Callback = function(value)
		 if SellConnection then SellConnection:Disconnect() SellConnection = nil end
		 if value then
			  AutoSell()
		 end
	end
})

Window:AddToggle({
	Text = "Auto Rebirth", 
	Value = false, 
	Callback = function(value)
		 RebirthEnabled = value
     AutoRebirth()
	end
})

Window:AddLabel("YouTube: Crokyreo")
