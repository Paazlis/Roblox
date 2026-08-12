local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

local CardScroll = PlayerGui:QueryDescendants("#BingoGui > #CardArea > #Row1 > #Slot1 > #Card1 > #GridArea > #Grid")[1]

Packets.NumberCalled = ReplicatedStorage:QueryDescendants("#BingoRemotes > #NumberCalled")[1]

local function FireButton(button)
	if firesignal then
		firesignal(button.Activated)
		firesignal(button.MouseButton1Click)
	end
end

if Packets.NumberCalled then
	Connections.NumberCalled = Packets.NumberCalled.OnClientEvent:Connect(function(data)
		if data.number then
			for _, button in pairs(CardScroll:GetChildren()) do
				local title = button:FindFirstChild("Number")
				if title and title.Text:find(tostring(data.number)) then
					FireButton(button)
					break
				end
			end
		end
	end)
end
