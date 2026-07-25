
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local Enableds, Connections = {["Upgrade"] = false}, {}
local UpgradeScroll = PlayerGui:QueryDescendants("#SkillTree > #Main > #Content")[1]
local UpgradeSuccessColor = Color3.new(255, 255, 255)

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end


local function HandleUpgrade()
	task.spawn(function()
		while Enableds.Upgrade do
			local backButton = nil
			
			-- Loop through all children in the UpgradeScroll
			for _, child in ipairs(UpgradeScroll:GetChildren()) do
				if not Enableds.Upgrade then break end

				if child:IsA("GuiObject") then
					local state = child.Name

					if state == "Available" then
						--local priceLabel = child:QueryDescendants("#PriceFrame > #Price")[1]
						--if priceLabel.TextColor3 == UpgradeSuccessColor then

						--end
						
						-- #1 If Affordable, fire the button
						FireButton(child)
						task.wait(0.1) -- Small delay to prevent input dropping
					elseif state == "SectionLink" then
						local section = child:GetAttribute("Section")
						if section and type(section) == "string" and section == "" then
							-- #2 If OpenTab, navigate into it
							FireButton(child)
							task.wait(0.2) -- Brief wait for the UI tab to transition/load
						else
							continue
						end
						

						local backButton = nil

						-- Attempt to buy the newly revealed upgrades inside the tab
						for _, innerChild in ipairs(UpgradeScroll:GetChildren()) do
							if not Enableds.Upgrade then return end
							local innerState = innerChild.Name
							if innerState == "Available" then
								--local priceLabel = innerChild:QueryDescendants("#PriceFrame > #Price")[1]
								--if priceLabel.TextColor3 == UpgradeSuccessColor then
									
								--end
								
								-- #1 If Affordable, fire the button
								FireButton(innerChild)
								task.wait(0.1) -- Small delay to prevent input dropping
								
							elseif state == "SectionLink" and not backButton then
								local innerSection = innerChild:GetAttribute("Section")
								if innerSection and type(innerSection) == "string" and innerSection ~= "" and not backButton then
									backButton = innerChild
								end
							end
						
						end

						if not Enableds.Upgrade then return end
						
						if backButton then
							-- Exit back out to return to the main list
							FireButton(backButton)
							task.wait(0.2) -- Brief wait for UI to transition back
						end
					end

					return state
				end
			end

			if not Enableds.Upgrade then break end
			if not backButton then continue end
			
			-- Exit back out to return to the main list
			FireButton(backButton)
			task.wait(0.5) -- Loop delay to prevent crashing/rate limits
		end
	end)
end

local Window = UI:CreateWindow({
	Name = "Build a base RNG",
	Destroying = function()
		for key, value in pairs(Connections) do
			if value then
				value:Disconnect()
			end
		end

		for key, value in pairs(Enableds) do
			Enableds[key] = false
		end
	end
})

Window:AddToggle({
	Text = "Auto Upgrade",
	Value = false,
	Flag = "upgrade_enabled",
	Callback = function(value)
	    --[[
	      SkillScroll.Available
	      SkillScroll.Available.PriceFrame.Price.TextColor3 == Color3.new(255, 255, 255)
	      
	      SkillScroll.Hidden
	      SkillScroll.Owned
	      SkillScroll.SectionLink
	    ]]
		
		Enableds.Upgrade = value
		if value then
			HandleUpgrade()
		end
	end
})

Window:AddLabel("YouTube: Crokyreo")
