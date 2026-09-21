local UI=loadstring(game:HttpGet("http://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services=setmetatable({},{__index=function(_,i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players=Services.Players
local ReplicatedStorage=Services.ReplicatedStorage

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds={["Upgrade"]=false,["Rebirth"]=false,["Place"]=false,["ClaimIndex"]=false,["OpenEgg"]=false}

local Packets={
	["Rebirth"]=ReplicatedStorage:QueryDescendants("#Remotes > #Game > #Rebirth")[1],
	["Buy"]=ReplicatedStorage:QueryDescendants("#Remotes > #Game > #BuyWithCash")[1],
	["Upgrade"]=ReplicatedStorage:QueryDescendants("#Remotes > #Game > #Plot > #Upgrades")[1],
	["Hatch"]=ReplicatedStorage:QueryDescendants("#Remotes > #Game > #Hatch")[1],
	["ClaimIndex"]=ReplicatedStorage:QueryDescendants("#Remotes > #Game > #ClaimIndexReward")[1],
}

local Interfaces={
	["RebirthFill"]=PlayerGui:QueryDescendants("#Main > #Rebirth >> #ProgressBarFrame > #ProgressBar")[1],
	-- PlayerGui.Main.Rebirth.Segment2.ProgressBarFrame.ProgressBar
	["PlaceBestButton"]=PlayerGui:QueryDescendants("#Main > #PetsTracker > #PlaceBest")[1],
	["GearScroll"]=PlayerGui:QueryDescendants("#Main > #Shop > #Holders > #Gears")[1],
	["FoodScroll"]=PlayerGui:QueryDescendants("#Main > #Shop > #Holders #Food")[1],
	["ClaimIndexButton"]=PlayerGui:QueryDescendants("#Main > #Index > #PetProgress > #Claim")[1],
}

local BuyTypes={"Buy Foods","Buy Gears"}

local TypeData={
	["Upgrade"]={"Hatch Lucky",BuyTypes[1],BuyTypes[2]},
	["Gears"]={},
	["Foods"]={}
}

local ActiveData={
	["Upgrade"]={
		["AllEnabled"]=true,
		["Hatch Lucky"]=false,
		[BuyTypes[1]]=false,
		[BuyTypes[2]]=false
	},
	["Gears"]={["AllEnabled"]=true},
	["Foods"]={["AllEnabled"]=true}
}

local InfoData={
	["Upgrade"]={},
	["Gears"]={},
	["Foods"]={}
}

local FailColor=Color3.fromRGB(255,45,45)

if Interfaces.GearScroll then
	local sortGears={}

	for _,layer in ipairs(Interfaces.GearScroll:GetChildren()) do
		if layer and layer.Parent and layer:IsA("GuiObject") then
			local button=layer:QueryDescendants("#CashPayment > #Frame > #Dollar")[1]
			if not button then continue end

			local stock=layer:QueryDescendants("#ProductExpander > #Price")[1]
			if not stock then continue end

			local key=layer.Name

			if ActiveData.Gears[key]==nil then
				ActiveData.Gears[key]=false
				table.insert(sortGears, {
					["Args"]={"Gears",layer.Name},
					["Button"]=button,
					["Stock"]=stock,
					["Name"]=key,
					["Tier"]=layer.LayoutOrder
				})
			end
		end
	end

	table.sort(sortGears, function(a, b)
		return a.Tier<b.Tier
	end)

	for _,info in ipairs(sortGears) do
		table.insert(TypeData.Gears,info.Name)
	end

	table.sort(sortGears, function(a, b)
		return a.Tier>b.Tier
	end)

	for _,info in ipairs(sortGears) do
		table.insert(InfoData.Gears,info)
	end
end

if Interfaces.FoodScroll then
	local sortFoods={}

	for _,layer in ipairs(Interfaces.FoodScroll:GetChildren()) do
		if layer and layer.Parent and layer:IsA("GuiObject") then
			local button=layer:QueryDescendants("#CashPayment > #Frame > #Dollar")[1]
			if not button then continue end

			local stock=layer:QueryDescendants("#ProductExpander > #Price")[1]
			if not stock then continue end

			local key=layer.Name

			if ActiveData.Foods[key]==nil then
				ActiveData.Foods[key]=false
				table.insert(sortFoods, {
					["Args"]={"Food",layer.Name},
					["Button"]=button,
					["Stock"]=stock,
					["Name"]=key,
					["Tier"]=layer.LayoutOrder
				})
			end
		end
	end

	table.sort(sortFoods, function(a, b)
		return a.Tier<b.Tier
	end)

	for _,info in ipairs(sortFoods) do
		table.insert(TypeData.Foods,info.Name)
	end

	table.sort(sortFoods, function(a, b)
		return a.Tier>b.Tier
	end)

	for _,info in ipairs(sortFoods) do
		table.insert(InfoData.Foods,info)
	end
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local PlotsFolder=nil

local function GetPlots()
	PlotsFolder=PlotsFolder or workspace:FindFirstChild("Plots")
	if not PlotsFolder then return {} end
	local results={}
	for _,plot in ipairs(PlotsFolder:GetChildren()) do
		if plot and plot.Parent then
			table.insert(results,{["OwnerUserId"]=plot:GetAttribute("NestsOwnerLoaded"),["Instance"]=plot,["Baseplate"]=plot:FindFirstChild("Baseplate")})
		end
	end
	return results
end

local function FindFirstPlot(ownerUserId)
	local results=GetPlots()
	while #results>0 do
		local info=table.remove(results)
		if info.OwnerUserId~=nil and info.OwnerUserId==ownerUserId then
			return info.Instance
		end
		task.wait()
	end
	return nil
end

local Plot=FindFirstPlot(LocalPlayer.UserId)
local PlotEggs,PlotBaseplate=nil,nil
if Plot then
	PlotBaseplate=Plot:FindFirstChild("Baseplate")
	PlotEggs=Plot:FindFirstChild("Eggs")
end

local Window=UI:CreateWindow({
	Name="Ride A Pet", 
	ConfigInfo={Enabled=true,Path="Crokyreo/RideAPet/configs.json"},
	Destroying=function()
		for key,enabled in pairs(Enableds) do
			Enableds[key]=false
		end
	end
})

Interfaces.HatchToggle=Window:AddToggle({
	Text="Auto Hatch",
	Value=false,
	Flag="hatch_enabled",
	Callback=function(value)
		Enableds.OpenEgg=value
		if not Enableds.OpenEgg then return end
		if not (PlotEggs and Packets.Hatch) then Enableds.OpenEgg=false Interfaces.HatchToggle:Replace(false) return end
		task.spawn(function()
			while Enableds.OpenEgg do
				local children=PlotEggs:GetChildren()
				while #children>0 do
					task.wait()
					if not Enableds.OpenEgg then break end
					local egg=table.remove(children)
					if egg and egg.Parent then
						local attributes=egg:GetAttributes()
						local eggKey,ownerUserId=attributes.EggKey,attributes.OwnerUserId
						if eggKey~=nil then
							Packets.Hatch:FireServer({EggKey=eggKey})
						end
					end
				end
				task.wait(1)
			end
		end)
	end
})

Interfaces.GearDropdown=Window:AddDropdown({
	Text="Gear Type",
	Options=#TypeData.Gears>0 and TypeData.Gears or {"No Gear Type"},
	Option=nil,
	Multi=true,
	Flag="gear_options",
	Callback=function(option)
		for _,key in ipairs(TypeData.Gears) do
			ActiveData.Gears[key]=table.find(option,key)~=nil
		end
		ActiveData.Gears.AllEnabled=#option<=0
	end
})

Interfaces.FoodDropdown=Window:AddDropdown({
	Text="Food Type",
	Options=#TypeData.Foods>0 and TypeData.Foods or {"No Food Type"},
	Option=nil,
	Multi=true,
	Flag="food_options",
	Callback=function(option)
		for _,key in ipairs(TypeData.Foods) do
			ActiveData.Foods[key]=table.find(option,key)~=nil
		end
		ActiveData.Foods.AllEnabled=#option<=0
	end
})

Interfaces.UpgradeDropdown=Window:AddDropdown({
	Text="Upgrade Type",
	Options=#TypeData.Upgrade>0 and TypeData.Upgrade or {"No Upgrade Type"},
	Option=nil,
	Multi=true,
	Flag="upgrade_options",
	Callback=function(option)
		for _,key in ipairs(TypeData.Upgrade) do
			ActiveData.Upgrade[key]=table.find(option,key)~=nil
		end
		ActiveData.Upgrade.AllEnabled=#option<=0
	end
})

for _,dropdown in ipairs({Interfaces.GearDropdown,Interfaces.FoodDropdown}) do
	dropdown.Visible=false
end

Window:AddSelector({
	Text=nil,
	Options={"Upgrade","Food","Gear"},
	NoCap=false,
	Flag="chosen_data",
	Callback=function(key)
		for _,dropdown in ipairs({Interfaces.UpgradeDropdown,Interfaces.GearDropdown,Interfaces.FoodDropdown}) do
			dropdown.Visible=false
		end
		local dropdown=Interfaces[key.."Dropdown"]
		if dropdown then dropdown.Visible=true end
	end
})

Window:AddToggle({
	Text="Auto Upgrade",
	Value=false,
	Flag="upgrade_enabled",
	Callback=function(value)
		Enableds.Upgrade=value
		if not Enableds.Upgrade then return end
		task.spawn(function()
			while Enableds.Upgrade do
				for key, active in pairs(ActiveData.Upgrade) do
					if not Enableds.Upgrade then break end
					if key~="AllEnabled" and (ActiveData.Upgrade.AllEnabled==true or active==true) then
						if key=="Hatch Lucky" and Packets.Upgrade then
							Packets.Upgrade:FireServer("Max")
							task.wait(3)
						end
					end
					task.wait()
				end
				task.wait()
			end
		end)
		task.spawn(function()
			while Enableds.Upgrade do
				for _,mode in ipairs(BuyTypes) do
					local active=ActiveData.Upgrade[mode]
					if not Enableds.Upgrade then break end
					if active then
						local actives,infos={},{}
						if mode==BuyTypes[1] then
							actives=ActiveData.Foods
							infos=InfoData.Foods
						else
							actives=ActiveData.Gears
							infos=InfoData.Gears
						end
						for _,info in ipairs(infos) do
							local key=info.Name
							local active=actives[key]
							if info~=nil and (actives.AllEnabled or active) then
								local stock=info.Stock
								local button=info.Button
								local args=info.Args
								if stock~=nil and stock.TextColor3~=FailColor then
									if Packets.Buy then
										Packets.Buy:FireServer(args[1],args[2])
									else
										FireButton(button)
									end
								end
							end
							task.wait()
						end
					end
					task.wait()
				end
				task.wait()
			end
		end)
	end
})

Interfaces.PlaceToggle=Window:AddToggle({
	Text="Place Best",
	Value=false,
	Flag="place_enabled",
	Callback=function(value)
		Enableds.Place=value
		if not Enableds.Place then return end
		if not Interfaces.PlaceBestButton then Enableds.Place=false Interfaces.PlaceToggle:Replace(false) return end
		task.spawn(function()
			while Enableds.Place do
				FireButton(Interfaces.PlaceBestButton)
				task.wait(3)
			end
		end)
	end
})

Interfaces.RebirthToggle=Window:AddToggle({
	Text="Auto Rebirth",
	Value=false,
	Flag="rebirth_enabled",
	Callback=function(value)
		Enableds.Rebirth=value
		if not Enableds.Rebirth then return end
		if not (Interfaces.RebirthFill and Packets.Rebirth) then Enableds.Rebirth=false Interfaces.RebirthToggle:Replace(false) return end
		task.spawn(function()
			while Enableds.Rebirth do
				if Interfaces.RebirthFill.Size.X.Scale>=1 then
					if Packets.Rebirth then
						Packets.Rebirth:FireServer()
					end
				end
				task.wait()
			end
		end)
	end
})

Interfaces.ClaimIndexToggle=Window:AddToggle({
	Text="Claim Index",
	Value=false,
	Flag="claim_index_enabled",
	Callback=function(value)
		Enableds.ClaimIndex=value
		if not Enableds.ClaimIndex then return end
		if not (Interfaces.ClaimIndexButton and Packets.ClaimIndex) then Enableds.ClaimIndex=false Interfaces.ClaimIndexToggle:Replace(false) return end
		task.spawn(function()
			while Enableds.ClaimIndex do
				if Interfaces.ClaimIndexButton.Visible==true then
					if Packets.ClaimIndex then
						Packets.ClaimIndex:FireServer()
					end
				end
				task.wait()
			end
		end)
	end
})

Window:AddLinkButton({
	Text="Donate 💖",
	Link="https://link-target.net/6690566/TlR2vuR2JR4F",
})

Window:AddLabel({
	Text="YouTube: Crokyreo",
	TextColor3=Color3.fromRGB(255,255,255)
})

Window:LoadConfig()
