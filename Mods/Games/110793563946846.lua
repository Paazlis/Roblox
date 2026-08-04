-- Upgrade Income --
game:GetService("Players").LocalPlayer.PlayerGui.IncomeSource.Container.Upgrade.Holder.TextButton

-- Click Stand --
local Event = game:GetService("ReplicatedStorage").Events.IncomeSource
Event:FireServer(
    "Basic_Stand"
)
workspace.Game.Plots["4"].Buttons.Basic_Stand

-- Complete Tycoon --
workspace.Game.Plots["4"].OccupiedBy.Value
workspace.Game.Plots["4"].Buttons
workspace.Game.Plots["4"].Buttons.Basic_Stand.Tips_Jar.Touch
workspace.Game.Plots["4"].Buttons.Basic_Stand.Cone_Stand.Touch

-- Phone Offer --
-- Waiting
local Event = game:GetService("ReplicatedStorage").Events.Phone
firesignal(Event.OnClientEvent)

-- Call
local Event = game:GetService("ReplicatedStorage").Events.Phone
Event:FireServer(
    "Accept",
    0
)
