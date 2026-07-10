local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local RebirthConnection = nil
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
   local rebirthAlert = PlayerGui.Main.Left.Rebirth.Frame.Alert
   RebirthConnection = rebirthAlert:GetPropertyChangedSignal("Visible"):Connect(function()
       if rebirthAlert.Visible then
          ReplicatedStorage.RemoteHandler.Rebirth:FireServer()
	   end
   end)
   if rebirthAlert.Visible then
      ReplicatedStorage.RemoteHandler.Rebirth:FireServer()
   end
end

local Window = UI:CreateWindow({
	Name = "Vacuum Simulator",
	Destroying = function()
	    if RebirthConnection then RebirthConnection:Disconnect() RebirthConnection = nil end
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
	   if RebirthConnection then RebirthConnection:Disconnect() RebirthConnection = nil end
       if value then
		  AutoRebirth()
	   end
	end
})

Window:AddLabel("YouTube: Crokyreo")
