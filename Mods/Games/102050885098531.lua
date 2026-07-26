local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualInputManager=Services.VirtualInputManager

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Packets = {
  ["Click"] = ReplicatedStorage:QueryDescendants("#Remotes > #Click")[1]
}
local CaseTypes, CaseButtons = {}, {}
local Enableds, Connections = {["Click"] = false, ["Rebirth"] = false, ["Case"] = false}, {}
local RebirthFrame, RebirthFill, RebirthButton = PlayerGui:QueryDescendants("#Rebirth > #Container > #Background > #Content")[1], nil, nil
local CriticalGui = PlayerGui:FindFirstChild("CritUI")
local CaseScroll = PlayerGui:QueryDescendants("#CasesShop > #Container > #Background > #Content")[1]
local CasesGui = PlayerGui:FindFirstChild("CasesUi")
local CaseType = "Crystal Case"
local ClickPoint = Vector2.new(500, 500)

if RebirthFrame then
   RebirthFill, RebirthButton = RebirthFrame:QueryDescendants("#Bar > #CanvasGroup > #InsideBar")[1], RebirthFrame:FindFirstChild("ClaimBtn")
end

if CaseScroll then
	for _, caseLayer in ipairs(CaseScroll:GetChildren()) do
		local titleLabel = caseLayer:FindFirstChild("ItemName")
		if not titleLabel then continue end

		local buyButton = caseLayer:FindFirstChild("Buy")
		if not buyButton then continue end
		
		local caseKey = titleLabel.Text
		if CaseButtons[caseKey] ~= nil then continue end

		CaseButtons[caseKey] = buyButton
		
		if not table.find(CaseTypes,caseKey) then
			table.insert(CaseTypes,caseKey)
		end
	end
end

local function SendClick(x,y)
	VirtualInputManager:SendMouseButtonEvent(x,y,0,true,game,0)
	task.wait()
	VirtualInputManager:SendMouseButtonEvent(x,y,0,false,game,0)
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function IsFillRunFull(fill)
	if fill.Position.X.Scale >= 0 then
		return true
	end
	return false
end

local function HandleClick()
  task.spawn(function()
      while Enableds.Click do
         Packets.Click:FireServer()
		 task.wait()
      end
  end)
end

local function HandleCase()
  task.spawn(function()
      while Enableds.Case do
		 local buyCaseButton = CaseButtons[CaseType]
		 if buyCaseButton then
		    FireButton(buyCaseButton)
			repeat task.wait() until not Enableds.Case or CasesGui.Enabled
			if Enableds.Case then
				SendClick(ClickPoint.X, ClickPoint.Y)
			end
		    repeat task.wait() until not Enableds.Case or not CasesGui.Enabled
		 end
         task.wait(1)
      end
  end)
end

local function FireRebirth()
	if Enableds.Rebirth and IsFillRunFull(RebirthFill) then
		FireButton(RebirthButton)
		if not CasesGui then return end
		repeat task.wait() until not Enableds.Rebirth or CasesGui.Enabled
		if Enableds.Rebirth then
	       SendClick(ClickPoint.X, ClickPoint.Y)
		end
	end
end

local function HandleRebirth()
   Connections.Rebirth = RebirthFill:GetPropertyChangedSignal("Position"):Connect(FireRebirth)

   task.spawn(function()
	   while Enableds.Rebirth do
		   FireRebirth()
		   task.wait(1)
	   end
   end)
end

local function HandleCritical()
   Connections.CriticalAdded = CriticalGui.ChildAdded:Connect(function(child)
	   if not Enableds.Critical then return end
	   if child:IsA("TextButton") or child:IsA("ImageButton") then
		  FireButton(child)
	   end
   end)

   for _, child in ipairs(CriticalGui:GetChildren()) do
	  if not Enableds.Critical then break end
	  if child:IsA("TextButton") or child:IsA("ImageButton") then
	     FireButton(child)
	  end
   end
end

local Window = UI:CreateWindow({
	Name = "Butterfly Legends",
	Destroying = function()
		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end

		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
	end
})

Window:AddToggle({
	Text = "Fast Flip",
	Value = false,
	Flag = "flip_enabled",
	Callback = function(value)
		value = false
		Enableds.Click = value
		if value then 
			 HandleClick()
		end
	end
})

Window:AddToggle({
	Text = "X3 Flip",
	Value = false,
	Flag = "critical_enabled",
	Callback = function(value)
		value = false
		Enableds.Critical = value
		if Connections.CriticalAdded then Connections.CriticalAdded:Disconnect() Connections.CriticalAdded = nil end
		if value then
			HandleCritical()
		end
	end
})

Window:AddDropdown({
	Text = "Case Type",
	Options = CaseTypes,
	Option = nil,
	MultipleOptions = false,
	Flag = "case_options",
	Callback = function(option)
		CaseType = option[1] or "None"
	end
})

Window:AddToggle({
	Text = "Open Case",
	Value = false,
	Flag = "case_enabled",
	Callback = function(value)
		Enableds.Case = value
		if value then
		   HandleCase()
		end
	end
})

Window:AddToggle({
	Text = "Auto Rebirth",
	Value = false,
	Flag = "rebirth_enabled",
	Callback = function(value)
		value = false
		Enableds.Rebirth = value
		if Connections.Rebirth then Connections.Rebirth:Disconnect() Connections.Rebirth = nil end
		if value then
			HandleRebirth()
		end
	end
})

--Window:AddLabel("YouTube: Crokyreo")
