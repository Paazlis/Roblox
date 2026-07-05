local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local RebirthConnection = nil
local PackOptions, DecorOptions, EggOptions, SellOptions = {}, {}, {}, {}

local env = getgenv()
env.BuyEggEnabled = not env.BuyEggEnabled
env.BuyPackEnabled = not env.BuyPackEnabled
env.BuyDecorEnabled = not env.BuyDecorEnabled

local function GetBuyFrame(child)
   if child:IsA("Frame") and child:FindFirstChild("Buy") then
      return child
   end
   return nil
end

local function AutoBuyEgg()
   if not BuyEggEnabled then return end

   task.spawn(function()
       while BuyEggEnabled do
          task.wait(1)
          for _, child in ipairs(PlayerGui.Main.Shop.Canvas.Holder.Canvas.Scroll:GetChildren()) do
             task.wait()
             local frame = GetBuyFrame(child)
             if not frame then continue end
             ReplicatedStorage.Packages.net["RE/PurchaseShop"]:FireServer(frame.Name)
             -- frame.Buy
          end
       end
   end)
end

local function AutoBuyDecor()
   if not BuyDecorEnabled then return end

   task.spawn(function()
       while BuyDecorEnabled do
          task.wait(1)
          for _, child in ipairs(PlayerGui.Main.Decor.Canvas.Holder.Canvas.Scroll:GetChildren()) do
             task.wait()
             local frame = GetBuyFrame(child)
             if not frame then continue end
             ReplicatedStorage.Packages.net["RE/PurchaseDecor"]:FireServer(frame.Name)
             -- frame.Buy
          end
       end
   end)
end

local function AutoBuyPack()
   if not BuyPackEnabled then return end

   task.spawn(function()
       while BuyPackEnabled do
          task.wait(1)
          for _, child in ipairs(PlayerGui.Main.Packs.Canvas.Holder.Canvas.Scroll:GetChildren()) do
             task.wait()
             local frame = GetBuyFrame(child)
             if not frame then continue end
             ReplicatedStorage.Packages.net["RE/BuyPack"]:FireServer(frame.Name)
             -- frame.Buy
          end
       end
   end)
end

local function AutoRebirth()
  -- game:GetService("Players").LocalPlayer.PlayerGui.Main.Rebirth.Canvas.Holder.Canvas.Need.Template.CanvasGroup.Ico.ImageColor3 == 255
  -- game:GetService("Players").LocalPlayer.PlayerGui.Main.Rebirth.Canvas.Holder.Canvas.Frame.Bar.Size.X.Scale

   local rebirthButton = PlayerGui.Main.Rebirth.Canvas.Holder.Canvas.Rebirth

   if rebirthButton.Visible == true then
      ReplicatedStorage.Packages.net["RE/Rebirth"]:FireServer()
   end
    
   RebirthConnection = rebirthButton:GetPropertyChangedSignal("Visible"):Connect(function()
       if rebirthButton.Visible == true then
          ReplicatedStorage.Packages.net["RE/Rebirth"]:FireServer()
       end
   end)
end

local function GetSellFrame(child)
  if child:IsA("Frame") and child:FindFirstChild("Sell") then
      return child
   end
   return nil
end

local function AutoSell()
   -- game:GetService("Players").LocalPlayer.PlayerGui.Main.Sell.Canvas.Holder.SellAll
   -- game:GetService("Players").LocalPlayer.PlayerGui.Main.Sell.Canvas.Holder.Canvas.Scroll
   if not SellEnabled then return end
   task.spawn(function()
       while SellEnabled do
          task.wait(1)
          local CanSell = false
          for _, child in ipairs(PlayerGui.Main.Sell.Canvas.Holder.Canvas.Scroll:GetChildren()) do
             task.wait()
             local frame = GetSellFrame(child)
             if not frame or not frame.Visible then continue end
             CanSell = true
          end
          if CanSell and SellEnabled then
             ReplicatedStorage.Packages.net["RE/Sell"]:FireServer()
          end
       end
   end)
end
