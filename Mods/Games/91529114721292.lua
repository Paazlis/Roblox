local UI=loadstring(game:HttpGet("http://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services=setmetatable({},{__index=function(_,i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players=Services.Players
local ReplicatedStorage=Services.ReplicatedStorage

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer.PlayerGui
local Character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Connections, Enableds = {}, {["Cash"] = false}

local Plot=nil
local FootballerFolder=nil
local CashToggle=nil

local function FireButton(object)
	if firesignal then
		firesignal(object.MouseButton1Click)
		firesignal(object.Activated)
	end
end

Connections.CharacterAdded=LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character=newCharacter
end)

local Window=UI:CreateWindow({
	Name="Soccer Manager Tycoon",
	Destroying=function() 
     for key,enabled in pairs(Enableds) do
         Enableds[key]=false
     end

     for key,connection in pairs(Connections) do
        if connection then
           connection:Disconnect()
        end
     end
  end
}) 

local function FireTouch(hitPart, targetPart)
	if firetouchinterest then
		firetouchinterest(hitPart, targetPart, 1)
		task.wait()
		firetouchinterest(hitPart, targetPart, 0)
	end
end

Window:AddSelect({
	Text =" Plot Target",
	Callback=function(target)
    -- workspace.Plots.PlayerPlot1
    -- workspace.Plots.PlayerPlot1.Footballers
    -- workspace.Plots.PlayerPlot1.Footballers:GetChildren()[2]
    -- workspace.Plots.PlayerPlot1.Footballers
    
     local current = target
     while current ~= nil and current ~= workspace do
        if current:FindFirstChild("Footballers") ~= nil then
           break
        end
        current = current.Parent
     end
    
		 if current:FindFirstChild("Footballers") ~= nil then
        Plot = current
        FootballerFolder = Plot:FindFirstChild("Footballers")
     end
	end
})

local WarningPlotLabel = Window:AddLabel({Name="Please sets plot target first!",TextScaled=true,Visible=false})

CashToggle=Window:AddToggle({
	Text="Collect Cash", 
	Value=false,
	Callback=function(value)
		if not Plot then WarningPlotLabel.Visible=true Enableds.Cash = false CashToggle:Replace(false) task.wait(2) WarningPlotLabel.Visible=false return end
		Enableds.Cash=value
		if value then
			task.spawn(function()
				while Enableds.Cash do
					task.wait(0.5)
            
          for _, footballer in pairs(FootballerFolder:GetChildren()) do
             task.wait()
             local footballerCharacter = footballer:FindFirstChild("Player")
             if not footballerCharacter then continue end

             local footballerHitbox = footballerCharacter.PrimaryPart
             if not footballerHitbox then continue end

             if not Enableds.Cash then break end
             FireTouch(Character.PrimaryPart, footballerHitbox)
          end
				end
			end)
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
