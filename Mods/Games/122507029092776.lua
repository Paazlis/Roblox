local UI=loadstring(game:HttpGet("http://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services=setmetatable({},{__index=function(_,i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players=Services.Players
local ReplicatedStorage=Services.ReplicatedStorage

local Cleans,Enableds={},{["Upgrade"]=true,["Rebirth"]=false,["BuyASMR"]=false,["BuyPart"]=false}

local LocalPlayer=Players.LocalPlayer
local PlayerGui=Players:FindFirstChildOfClass("PlayerGui")

local Interfaces={
    ["RebirthFill"]=PlayerGui:QueryDescendants("Frames > #RebirthFrame > #ScrollingFrame > #Bar > #Frame")[1],
    ["RebirthButton"]=PlayerGui:QueryDescendants("Frames > #RebirthFrame > #ScrollingFrame > #Buttons > #Rebirth")[1],
    ["UpgradeScroll"]=PlayerGui:QueryDescendants("Frames > #UpgradeFrame > #ScrollingFrame")[1]
}

local UpgradeUpgradeActives={}
game:GetService("Players").LocalPlayer.PlayerGui.Frames.UpgradeFrame.ScrollingFrame
game:GetService("Players").LocalPlayer.PlayerGui.Frames.UpgradeFrame.ScrollingFrame.MaxPlacement.info.name
game:GetService("Players").LocalPlayer.PlayerGui.Frames.UpgradeFrame.ScrollingFrame.ObbySize.buttons.buy.BackgroundColor3 == Color3.fromRGB(0, 255, 0)

local function ObserveChild(instance,callback,noInitial)
	local childAddedConnection:RBXScriptConnection
	local childCache:{[Instance]:()->()}={}
	
	local function OnChildRemoved(child:Instance)
		local childInfo=childCache[child]
		if childInfo==nil then return end
		childCache[child]=nil
		childInfo.AncestryChanged:Disconnect()
		local cleanup=childInfo.Cleanup
		if cleanup==nil or type(cleanup)~="function" then return end
		task.spawn(cleanup,child)
	end

	local function OnChildAdded(child:Instance?)
		if childAddedConnection.Connected and child~=nil and child.Parent~=nil then
			local cleanup=callback(child)
			if cleanup~=nil and type(cleanup)=="function" then
				if childAddedConnection.Connected and child~=nil and child.Parent~=nil then
					local childInfo={["Cleanup"]=cleanup}
					childInfo.AncestryChanged=child.AncestryChanged:Connect(function(_,parent)
						if not (parent~=nil and child:IsDescendantOf(instance)) then
							OnChildRemoved(child)
						end
					end)
					childCache[child]=childInfo
				else
					task.spawn(cleanup,child)
				end
			end
		end
	end

	-- Listen for changes:
	childAddedConnection=instance.ChildAdded:Connect(OnChildAdded)
	
	-- Initial:
	task.defer(function()
		if not childAddedConnection.Connected or noInitial then return end
		local children=instance:GetChildren()
		for i,child in ipairs(children) do
			if not childAddedConnection.Connected then break end
			task.defer(OnChildAdded,child)
		end
	end)

	-- Cleanup:
	return function()
		childAddedConnection:Disconnect()
		local child=next(childCache)
		while child do
			OnChildRemoved(child)
			child=next(childCache)
		end
	end
end

local function GetPlot()
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


local Plot=GetPlot()

Interfaces.RebirthFill

local function HandleRebirth()
    if Enableds.Rebirth then return end

    local 
    local RebirthButton = 
    
    task.spawn(function()
        while Enableds.Rebirth do
            if 
            task.wait()
        end
    end)
end

workspace.Map.Plots.Plot_2 -- Owner string 

-- Collect Cash --
workspace.Map.Plots.Plot_2.CollectAll.PRIMARY

local Event = game:GetService("ReplicatedStorage").GameSystems.Packages.Networker["leifstout_networker@0.3.0"].networker._remotes.PlotService.RemoteEvent
Event:FireServer(
    "Collect"
)

-- Auto Upgrade --

-- Buy Part --
game:GetService("Players").LocalPlayer.PlayerGui.Frames.PartFrame.ScrollingFrame
game:GetService("Players").LocalPlayer.PlayerGui.Frames.PartFrame.ScrollingFrame["Big Wedge"].info.name
game:GetService("Players").LocalPlayer.PlayerGui.Frames.PartFrame.ScrollingFrame["Big Wedge"].info.stock.TextColor3 == Color3.fromRGB(0, 255, 0)
game:GetService("Players").LocalPlayer.PlayerGui.Frames.PartFrame.ScrollingFrame["Big Wedge"].buttons.buy.BackgroundColor3 == Color3.fromRGB(0, 255, 0)

-- Buy ASMR --
game:GetService("Players").LocalPlayer.PlayerGui.Frames.ASMRFrame.ScrollingFrame["67 Keyboard"].buttons.buy.BackgroundColor3 == Color3.fromRGB(0, 255, 0)
game:GetService("Players").LocalPlayer.PlayerGui.Frames.ASMRFrame.ScrollingFrame["67 Keyboard"].info.name
game:GetService("Players").LocalPlayer.PlayerGui.Frames.ASMRFrame.ScrollingFrame["67 Keyboard"].info.stock.TextColor3 == Color3.fromRGB(0, 255, 0)

-- Like Button --
local Event = game:GetService("ReplicatedStorage").GameSystems.Packages.Networker["leifstout_networker@0.3.0"].networker._remotes.PlotService.RemoteEvent
Event:FireServer(
    "LikePlot",
    game:GetService("Players").hermans121314
)

-- Auto Rebirth --
