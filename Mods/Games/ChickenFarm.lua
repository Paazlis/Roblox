local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Paazlis/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local EggAdded = nil
local DepositEnabled, UpgradeEnabled, MergeEnabled, CashEnabled = false, false, false, false

local function FireTouch(hitPart, targetPart)
   if firetouchinterest then
      firetouchinterest(hitPart, targetPart, 1)
      task.wait()
      firetouchinterest(hitPart, targetPart, 0)
   end
end

local Window = UI:CreateWindow({Name = "Chicken Farm", Destroying = function()
     if EggAdded then EggAdded:Disconnect() EggAdded = nil end
     DepositEnabled, UpgradeEnabled, MergeEnabled, CashEnabled = false, false, false, false
end})

Window:AddToggle({
	Name = "Collect Egg",
    Value = false,
	Callback = function(value)
     if EggAdded then EggAdded:Disconnect() EggAdded = nil end
     if value then
        EggAdded = workspace.Eggs.ChildAdded:Connect(function(model)
            task.wait(1)
            if model.Parent then
               local targetPart = model:FindFirstChild("Part")
               if targetPart and LocalPlayer.Character then
                  FireTouch(LocalPlayer.Character.PrimaryPart, targetPart)
               end
            end
        end)
        for i, model in ipairs(workspace.Eggs:GetChildren()) do
            if model.Parent then
               local targetPart = model:FindFirstChild("Part")
               if targetPart and LocalPlayer.Character then
                  FireTouch(LocalPlayer.Character.PrimaryPart, targetPart)
               end
            end
        end
     end
  end
})

local function getPlot()
   for i, v in ipairs(workspace.Plots:GetChildren()) do
      if v.Name == LocalPlayer.Name then return v end
   end
end

local Plot = getPlot()

Window:AddToggle({
	Name = "Auto Deposit",
    Value = false,
	Callback = function(value)
     DepositEnabled = value
     if value then
        task.spawn(function()
            while DepositEnabled do
               task.wait(1)
               if Plot then
                  local targetPart = Plot.Buttons.DepositEggs.Hitbox
                  if targetPart and LocalPlayer.Character then
                     FireTouch(LocalPlayer.Character.PrimaryPart, targetPart)
                  end
			   end
            end
        end)
     end
  end
})

Window:AddToggle({
	Name = "Auto Merge",
    Value = false,
	Callback = function(value)
     MergeEnabled = value
     if value then
        task.spawn(function()
            while MergeEnabled do
               task.wait(1)
			   if Plot then
                  local targetPart = Plot.Buttons.MergeChickens.Button
                  if targetPart and LocalPlayer.Character then
                     FireTouch(LocalPlayer.Character.PrimaryPart, targetPart)
                  end
			   end
            end
        end)
     end
  end
})

Window:AddToggle({
	Name = "Collect Cash",
    Value = false,
	Callback = function(value)
     CashEnabled = value
     if value then
        task.spawn(function()
            while CashEnabled do
               task.wait(1)
			   if Plot then
                  local targetPart = Plot.Buttons.CollectMoney.Button
                  if targetPart and LocalPlayer.Character then
                     FireTouch(LocalPlayer.Character.PrimaryPart, targetPart)
                  end
			   end
            end
        end)
     end
  end
})

Window:AddToggle({
	Name = "Upgrade All",
    Value = false,
	Callback = function(value)
     UpgradeEnabled = value
     if value then
        task.spawn(function()
            while UpgradeEnabled do
               task.wait(1)
			   if Plot then
                  for i, model in ipairs(Plot.Buttons.BuyChickens:GetChildren()) do
                     local targetPart = model:FindFirstChild("Button")
                     if targetPart and LocalPlayer.Character then
                        FireTouch(LocalPlayer.Character.PrimaryPart, targetPart)
                     end
                  end
			   end
            end
        end)
     end
  end
})

Window:AddLabel("YouTube: Crokyreo")
