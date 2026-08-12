local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local CardScroll = PlayerGui:QueryDescendants("#BingoGui > #CardArea > #Row1")[1]

local NumberCalledPacket = ReplicatedStorage:QueryDescendants("#BingoRemotes > #NumberCalled")[1]

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

if NumberCalledPacket then
	NumberCalledPacket.OnClientEvent:Connect(function(data)
		if data and data.number then
			for _, slot in ipairs(CardScroll:GetChildren()) do
			local grid = slot:QueryDescendants("#Card1 > #GridArea > #Grid")[1]
			if not grid then continue end
			for _, button in ipairs(grid:GetChildren()) do
				local title = button:FindFirstChild("Number")
				if title and title.Text:find(tostring(data.number)) then
					FireButton(button)
					break
				end
			end
			end
		end
	end)
end
