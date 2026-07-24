local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/refs/heads/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local Enableds, Connections = {["Skills"] = false}, {}
local SkillScroll = PlayerGui:QueryDescendants("#SkillTree > #Main > #Content")[1]
local SkillSuccessColor = Color3.new(255, 255, 255)

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
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

Window:AddButton({
	Text = "Buy All Skills",
	MethodType = "DebounceClick",
	Callback = function()
	    --[[
	      SkillScroll.Available
	      SkillScroll.Available.PriceFrame.Price.TextColor3 == Color3.new(255, 255, 255)
	      
	      SkillScroll.Hidden
	      SkillScroll.Owned
	      SkillScroll.SectionLink
	    ]]

		 for _, skillButton in ipairs(SkillScroll:GetChildren()) do
			 task.wait()
			 if skillButton:IsA("ImageButton") or skillButton:IsA("TextButton") then
				local skillName = skillButton.Name:lower()
				if skillName:find("available") then
					print(skillName)
					FireButton(skillButton)
				end
			 end
		  end
	end
})

Window:AddLabel("Version: 4")
Window:AddLabel("YouTube: Crokyreo")
