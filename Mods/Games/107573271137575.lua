-- workspace:GetChildren()[51].HiddenStolenItems  TheftType  workspace.Customer_Maya  workspace.Customer_Zoe

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer

local Enableds, Connections = {["NPC"] = false, ["Luggage"] = false}, {}
local CustomerList = {}
local BillboardList = {}
local ParentGui = nil

local function CreateBillboard(child, parent)
    local adonee = child:FindFirstChild("Head") or child:FindFirstChild("HumanoidRootPart") or child.PrimaryPart or child:FindFirstChildOfClass("Part")
    
    local billboard = Instance.new("BillboardGui")
		billboard.Name = "NOC_ESP"
		billboard.Size = UDim2.new(0, 150, 0, 30)
		billboard.AlwaysOnTop = true
		billboard.StudsOffset = Vector3.new(0, 2, 0)
		billboard.Adornee = adonee

		local label = Instance.new("TextLabel")
		label.Parent = billboard
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = "Theft"
		label.TextColor3 = Color3.fromRGB(255, 30, 30)
		label.TextSize = 14
		label.Font = Enum.Font.SourceSansBold

		label.TextStrokeTransparency = 0
		label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

		billboard.Parent = parent
    table.insert(BillboardList, billboard)
end

local function OnCustomerAdded(child)
   task.wait(1)
   
   if not (child and child.Parent) then return end
   if not child:IsA("Model") then return end
    
   local theftType = child:GetAttribute("TheftType")
   if theftType == nil then return end

   table.insert(CustomerList, child)
end

Connections.CustomerAdded = workspace.ChildAdded:Connect(OnCustomerAdded)

Connections.CustomerRemoved = workspace.ChildRemoved:Connect(function(child)
    local index = table.find(CustomerList, child)
    if not index then return end
    
    table.remove(CustomerList, index)
end)

task.spawn(function()
	for _, child in ipairs(workspace:GetChildren()) do
		if not (Connections.CustomerAdded and Connections.CustomerAdded.Connected) then return end
	    OnCustomerAdded(child)
	end
end)

local function SpyCustomer()
   if not Enableds.SpyCustomer then return end

   task.spawn(function() 
   while Enableds.SpyCustomer do
        task.wait(1)
        
   for _, customer in ipairs(CustomerList) do
      if not Enableds.SpyCustomer then return end
      if not (customer and customer.Parent) then continue end

	  local theftType customer:GetAttribute("TheftType")
      if theftType == nil or theftType:find("none") then continue end
	
      local toAdornee = customer:FindFirstChild("Head") or child:FindFirstChild("HumanoidRootPart") or child.PrimaryPart or child:FindFirstChildOfClass("Part")
      local fail = true

      for _, billboard in ipairs(BillboardList) do
         if not Enableds.SpyCustomer then return end
         if not (customer and customer.Parent) then break end
      
         local adornee = billboard.Adornee
         
         if not (adornee and adornee.Parent) then
            billboard.Adornee = toAdornee
            fail = false
            break
         elseif adornee:IsDescendantOf(customer) or adornee == toAdornee then
            fail = false
		 end
      end

      if not Enableds.SpyCustomer then return end
      if not (customer and customer.Parent) then continue end

      if fail then
         CreateBillboard(customer, ParentGui)
      end
   end

   end end)
end

local Window = UI:CreateWindow({
	Name = "Secure the Supermarket",
	Destroying = function()
		for key, enabled in pairs(Enableds) do
			Enableds[key] = false
		end
		
		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end
		
		if NPCFolder then
			for _, npc in ipairs(NPCFolder:GetChildren()) do UnespNpc(npc) end
		end
		
		if LuggageFolder then
			for _, luggage in ipairs(LuggageFolder:GetChildren()) do UnespLuggage(luggage) end
		end
	end
})

ParentGui = Window.Gui

Window:AddToggle({
	Text = "Spy Customer", 
	Value = false, 
	Callback = function(value)
		Enableds.SpyCustomer = value
		SpyCustomer()
	end
})

Window:AddLabel({
  Text = "YouTube: Crokyreo",
  TextColor3 = Color3.fromRGB(255, 255, 255)
})
