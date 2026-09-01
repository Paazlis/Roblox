local UI=loadstring(game:HttpGet("http://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services=setmetatable({},{__index=function(_,i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players=Services.Players
local ReplicatedStorage=Services.ReplicatedStorage

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds={["Cash"]=false,["Like"]=false,["Upgrade"]=false,["Rebirth"]=false,["BuyASMR"]=false,["BuyPart"]=false}
local Cacheds={}

local Packets={
	["RequestPlot"]=script:QueryDescendants("#GameSystems > #Packages > #Networker >> #networker > #_remotes > #PlotService > #RemoteEvent")[1]
}

local Interfaces={
	["RebirthFill"]=PlayerGui:QueryDescendants("#Frames > #RebirthFrame > #ScrollingFrame > #Bar > #Frame")[1],
	["RebirthButton"]=PlayerGui:QueryDescendants("#Frames > #RebirthFrame > #ScrollingFrame > #Buttons > #Rebirth")[1],
	["UpgradeScroll"]=PlayerGui:QueryDescendants("#Frames > #UpgradeFrame > #ScrollingFrame")[1],
	["PartScroll"]=PlayerGui:QueryDescendants("#Frames > #PartFrame > #ScrollingFrame")[1],
	["ASMRScroll"]=PlayerGui:QueryDescendants("#Frames > #ASMRFrame > #ScrollingFrame")[1]
}

local BuyTypes={"Buy ASMR","Buy Part"}

local TypeData={
	["Upgrade"]={},
	["ASMRs"]={},
	["Parts"]={}
}

for _, key in ipairs(BuyTypes) do table.insert(TypeData.Upgrade,key) end

local ActiveData={
	["Upgrade"]={
		["AllEnabled"]=true,
		["Buy ASMR"]=false,
		["Buy Part"]=false
	},
	["ASMRs"]={["AllEnabled"]=true},
	["Parts"]={["AllEnabled"]=true}
}

local InfoData={
	["Upgrade"]={},
	["ASMRs"]={},
	["Parts"]={}
}

local SuccessColor=Color3.fromRGB(0,255,0)

Cacheds.CharacterAdded=LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character=newCharacter
end)

	if Interfaces.UpgradeScroll then
		local sortUpgrades={}

		for _,layer in ipairs(Interfaces.UpgradeScroll:GetChildren()) do
			if layer and layer.Parent and layer:IsA("GuiObject") then
				local button=layer:QueryDescendants("#buttons > #buy")[1]
				if not button then continue end

				local title=layer:QueryDescendants("#info > #name")[1]
				if not title then continue end

				local key=title.Text

				if not InfoData.Upgrade[key] then
					InfoData.Upgrade[key]={
						["Button"]=button,
					}
					ActiveData.Upgrade[key]=false
					table.insert(sortUpgrades, {
						Name=key,
						Tier=layer.LayoutOrder,
					})
				end
			end
		end

		table.sort(sortUpgrades, function(a, b)
			return a.Tier<b.Tier
		end)

		for _,info in ipairs(sortUpgrades) do
			table.insert(TypeData.Upgrade,info.Name)
		end
	end

	if Interfaces.ASMRScroll then
		local sortASMRs={}
		
		for _,layer in ipairs(Interfaces.ASMRScroll:GetChildren()) do
			if layer and layer.Parent and layer:IsA("GuiObject") then
				local button=layer:QueryDescendants("#buttons > #buy")[1]
				if not button then continue end

				local title=layer:QueryDescendants("#info > #name")[1]
				if not title then continue end
				
				local stock=layer:QueryDescendants("#info > #stock")[1]
				if not stock then continue end
				
				local key=title.Text

			    if ActiveData.ASMRs[key]==nil then
					ActiveData.ASMRs[key]=false
					table.insert(sortASMRs, {
						["Button"]=button,
						["Stock"]=stock,
						["Name"]=key,
						["Tier"]=layer.LayoutOrder
					})
			    end
			end
		end

		table.sort(sortASMRs, function(a, b)
			return a.Tier<b.Tier
		end)

		for _,info in ipairs(sortASMRs) do
			table.insert(TypeData.ASMRs,info.Name)
		end

    	table.sort(sortASMRs, function(a, b)
			return a.Tier>b.Tier
		end)

	    for _,info in ipairs(sortASMRs) do
			table.insert(InfoData.ASMRs,info)
	    end
	end

	if Interfaces.PartScroll then
		local sortParts={}

		for _,layer in ipairs(Interfaces.PartScroll:GetChildren()) do
			if layer and layer.Parent and layer:IsA("GuiObject") then
				local button=layer:QueryDescendants("#buttons > #buy")[1]
				if not button then continue end

				local title=layer:QueryDescendants("#info > #name")[1]
				if not title then continue end

				local stock=layer:QueryDescendants("#info > #stock")[1]
				if not stock then continue end

				local key=title.Text

				if ActiveData.Parts[key]==nil then
					ActiveData.Parts[key]=false
					table.insert(sortParts, {
						["Button"]=button,
						["Stock"]=stock,
						["Name"]=key,
						["Tier"]=layer.LayoutOrder
					})
				end
			end
		end

		table.sort(sortParts, function(a, b)
			return a.Tier<b.Tier
		end)

		for _,info in ipairs(sortParts) do
			table.insert(TypeData.Parts,info.Name)
		end

		table.sort(sortParts, function(a, b)
			return a.Tier>b.Tier
		end)

	    for _,info in ipairs(sortParts) do
			table.insert(InfoData.Parts,info)
	    end
end

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

local function Cleanup(object)
	local objectType=typeof(object)
	if objectType=='function' then
		pcall(function() object() end)
	elseif objectType=='RBXScriptConnection' then
		object:Disconnect()
	end
	return nil
end

local function GetPlot(name)
	local plots=workspace:QueryDescendants("#Map > #Plots")[1]
	if not plots then return end
	for _, plot in ipairs(plots:GetChildren()) do
		local ownerName = plot: GetAttribute("Owner")
		if ownerName~=nil and ownerName==LocalPlayer.Name then
			return plot
		end
	end
	return nil
end

local LocalPlot=GetPlot()
local CashHitbox=nil

local function HandleCash()
	if not Enableds.Cash then return end
	CashHitbox=CashHitbox or LocalPlot:QueryDescendants("#CollectAll > #PRIMARY")[1]
	task.spawn(function()
		while Enableds.Cash do
			if Packets.RequestPlot then
				Packets.RequestPlot:FireServer("Collect")
			else
				local rootPart=Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
				if rootPart and CashHitbox then
					FireTouch(rootPart,CashHitbox)
				end
			end
			task.wait(1)
		end
	end)
end

local function HandleUpgrade()
	if not Enableds.Upgrade then return end
	task.spawn(function()
		while Enableds.Upgrade do
			for key, active in pairs(ActiveData.Upgrade) do
				if not Enableds.Upgrade then break end
				if key~="AllEnabled" and (ActiveData.Upgrade.AllEnabled==true or active==true) then
					local info=InfoData.Upgrade[key]
					if info~=nil then
						local button=info.Button
						if button~=nil and button.BackgroundColor3==SuccessColor then
							FireButton(button)
						end
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
						actives=ActiveData.ASMRs
						infos=InfoData.ASMRs
					else
						actives=ActiveData.Parts
						infos=InfoData.Parts
					end
					for _,info in ipairs(infos) do
						local key=info.Name
						local active=actives[key]
						if info~=nil and (actives.AllEnabled or active) then
							local stock=info.Stock
							local button=info.Button
							if button~=nil and stock~=nil and button.BackgroundColor3==SuccessColor and stock.TextColor3==SuccessColor then
								FireButton(button)
							end
						end
					end
				end
				task.wait()
			end
			task.wait()
		end
	end)
end

local function HandleLike()
	if not Packets.RequestPlot then return end
	local playerList=Players:GetPlayers()
	for _,player in ipairs(playerList) do
	    if player and player.Parent then
		   Packets.RequestPlot:FireServer("LikePlot",player)
	    end
	    task.wait()
	end
end

local function HandleRebirth()
	if not Enableds.Rebirth then return end
	task.spawn(function()
		while Enableds.Rebirth do
			if Interfaces.RebirthFill.Size.X.Scale>=1 then
				FireButton(Interfaces.RebirthButton)
			end
			task.wait(0.5)
		end
	end)
end

local Window=UI:CreateWindow({
	Name="Build a +1 Obby", 
	Destroying=function()
		for key,enabled in pairs(Enableds) do
			Enableds[key]=false
		end
	end
})

Window:AddToggle({
	Text="Collect Cash",
	Value=false,
	Callback=function(value)
		Enableds.Cash=value
		HandleCash()
	end
})

local ASMRDropdown=Window:AddDropdown({
	Text="ASMR Type",
	Options=#TypeData.ASMRs>0 and TypeData.ASMRs or {"No ASMR Type"},
	Option=nil,
	MultipleOptions=true,
	Callback=function(option)
		for _,key in ipairs(TypeData.ASMRs) do
			ActiveData.ASMRs[key]=table.find(option,key)~=nil
		end
		ActiveData.ASMRs.AllEnabled=#option<=0
	end
})

local PartDropdown=Window:AddDropdown({
	Text="Part Type",
	Options=#TypeData.Parts>0 and TypeData.Parts or {"No Part Type"},
	Option=nil,
	MultipleOptions=true,
	Callback=function(option)
		for _,key in ipairs(TypeData.Parts) do
			ActiveData.Parts[key]=table.find(option,key)~=nil
		end
		ActiveData.Parts.AllEnabled=#option<=0
	end
})

local UpgradeDropdown=Window:AddDropdown({
	Text="Upgrade Type",
	Options=#TypeData.Upgrade>0 and TypeData.Upgrade or {"No Upgrade Type"},
	Option=nil,
	MultipleOptions=true,
	Callback=function(option)
		for _,key in ipairs(TypeData.Upgrade) do
			ActiveData.Upgrade[key]=table.find(option,key)~=nil
		end
		ActiveData.Upgrade.AllEnabled=#option<=0
	end
})

Window:AddToggle({
	Text="Auto Upgrade",
	Value=false,
	Callback=function(value)
		Enableds.Upgrade=value
		HandleUpgrade()
	end
})

Window:AddButton({
	Text="Like",
	MethodType="DebounceClick",
	Callback=HandleLike
})

Window:AddToggle({
	Text="Auto Rebirth",
	Value=false,
	Callback=function(value)
		Enableds.Rebirth=value
		HandleRebirth()
	end
})

Window:AddLabel({
	Text="YouTube: Crokyreo",
	TextColor3=Color3.fromRGB(255,255,255)
})

Window:AddLabel({
	Text="Date: 09-01-2026",
	TextColor3=Color3.fromRGB(255,255,255)
})
